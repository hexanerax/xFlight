import Foundation

enum AeroAPIError: Error {
    case httpError(Int)
    case noData
}

struct AeroAPIService {

    private static let baseURL = "https://aeroapi.flightaware.com/aeroapi"

    private static func makeRequest(url: URL) -> URLRequest {
        var req = URLRequest(url: url)
        req.setValue(Secrets.aeroAPIKey, forHTTPHeaderField: "x-apikey")
        return req
    }

    // MARK: - Search

    static func searchFlights(ident: String) async throws -> [FlightResult] {
        let flights = try await fetchFlights(ident: ident)
        let now = Date()
        return flights.compactMap { f -> FlightResult? in
            let depDate = f.scheduled_out.flatMap { parseDate($0) }
            let isScheduledFuture = depDate.map { $0 > now } ?? false
            // "Airborne" = has taken off (actual_off set) but not yet landed (actual_in nil),
            // OR AeroAPI explicitly says Active/progress > 0.
            // Excludes Arrived/Cancelled regardless of other fields.
            // Does NOT use actual_out (pushback) — it stays set after landing.
            let isAirborne = f.actual_in == nil
                && f.status != "Arrived"
                && f.status != "Cancelled"
                && (f.status == "Active" || f.actual_off != nil || (f.progress_percent ?? 0) > 0)
            guard isScheduledFuture || isAirborne else { return nil }
            let originTZ = AirportTimezones.resolve(iata: f.origin?.code_iata, apiTimezone: f.origin?.timezone)
            let destTZ   = AirportTimezones.resolve(iata: f.destination?.code_iata, apiTimezone: f.destination?.timezone)
            let arrRaw   = f.estimated_in ?? f.scheduled_in
            return FlightResult(
                id: UUID(),
                faFlightId: f.fa_flight_id,
                flightNumber: f.ident,
                origin: f.origin?.code_iata ?? "???",
                destination: f.destination?.code_iata ?? "???",
                depTime: timeFormatted(f.scheduled_out, timeFmt: makeTimeFmt(timezone: originTZ)),
                arrTime: timeFormatted(arrRaw, timeFmt: makeTimeFmt(timezone: destTZ)),
                scheduledOutDate: f.scheduled_out.flatMap { parseDate($0) },
                status: searchStatus(f),
                phase: searchPhase(f)
            )
        }
        .sorted { ($0.scheduledOutDate ?? .distantFuture) < ($1.scheduledOutDate ?? .distantFuture) }
    }

    // MARK: - Detail
    //
    // Searches by ident (same endpoint as search, guaranteed format) then selects
    // the best flight in priority order:
    //   1. An exact fa_flight_id match that is airborne or has a future departure
    //   2. Any currently airborne flight for that ident
    //   3. The fa_flight_id match regardless of phase
    //   4. The first result

    static func fetchFlightDetail(faFlightId: String, ident: String) async throws -> FlightDetail {
        let flights = try await fetchFlights(ident: ident)
        guard !flights.isEmpty else { throw AeroAPIError.noData }

        let now = Date()

        let exactMatch = flights.first(where: { $0.fa_flight_id == faFlightId })
        let exactIsStale: Bool = {
            guard let f = exactMatch,
                  let rawOut = f.scheduled_out,
                  let dep = parseDate(rawOut) else { return false }
            // Stale = scheduled/past departure still showing as not-airborne
            return dep < now && !isAirborneSignal(f) && f.actual_in == nil
        }()

        let best: APIFlight
        if let exact = exactMatch, !exactIsStale {
            best = exact
        } else if let active = flights.first(where: { isAirborneSignal($0) && $0.actual_in == nil }) {
            best = active
        } else if let exact = exactMatch {
            best = exact
        } else {
            best = flights[0]
        }

        return buildDetail(from: best, now: now)
    }

    // MARK: - Shared fetch

    private static func fetchFlights(ident: String) async throws -> [APIFlight] {
        guard var comps = URLComponents(string: "\(baseURL)/flights/\(ident)") else {
            throw AeroAPIError.noData
        }
        comps.queryItems = [URLQueryItem(name: "max_pages", value: "1")]
        guard let url = comps.url else { throw AeroAPIError.noData }

        let (data, response) = try await URLSession.shared.data(for: makeRequest(url: url))
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw AeroAPIError.httpError(http.statusCode)
        }
        return try JSONDecoder().decode(FlightsEnvelope.self, from: data).flights
    }

    private static func buildDetail(from f: APIFlight, now: Date) -> FlightDetail {
        let originTZ = AirportTimezones.resolve(iata: f.origin?.code_iata, apiTimezone: f.origin?.timezone)
        let destTZ   = AirportTimezones.resolve(iata: f.destination?.code_iata, apiTimezone: f.destination?.timezone)
        let depFmt   = makeTimeFmt(timezone: originTZ)
        let arrFmt   = makeTimeFmt(timezone: destTZ)
        let phase = detailPhase(f, now: now)
        let status = detailStatus(f, phase: phase)
        return FlightDetail(
            status: status,
            phase: phase,
            gateOrigin: f.gate_origin ?? "--",
            gateDestination: f.gate_destination ?? "--",
            baggageClaim: f.baggage_claim ?? "--",
            timeUntilDep: countdown(to: f.scheduled_out, minutesBefore: 45, now: now),
            timeRemaining: countdown(to: f.estimated_in, now: now),
            scheduledOut: timeFormatted(f.scheduled_out, timeFmt: depFmt),
            estimatedIn: timeFormatted(f.estimated_in, timeFmt: arrFmt),
            actualIn: timeFormatted(f.actual_in, timeFmt: arrFmt)
        )
    }

    // MARK: - Airborne signal

    private static func isAirborneSignal(_ f: APIFlight) -> Bool {
        (f.progress_percent ?? 0) > 0
            || f.actual_out != nil
            || f.actual_off != nil
            || f.status == "Active"
    }

    // MARK: - Phase helpers

    private static func searchPhase(_ f: APIFlight) -> FlightPhase {
        if f.cancelled == true || f.status == "Cancelled" { return .checkIn }
        if f.status == "Arrived" || f.actual_in != nil || f.progress_percent == 100 { return .arrived }
        let isAirborne = f.actual_in == nil
            && f.status != "Arrived"
            && (f.status == "Active" || f.actual_off != nil || (f.progress_percent ?? 0) > 0)
        return isAirborne ? .cruise : .checkIn
    }

    private static func detailPhase(_ f: APIFlight, now: Date) -> FlightPhase {
        if f.cancelled == true { return .checkIn }
        if f.actual_in != nil || f.progress_percent == 100 || f.status == "Arrived" { return .arrived }
        if isAirborneSignal(f) {
            if let rawIn = f.estimated_in, let eta = parseDate(rawIn) {
                return eta.timeIntervalSince(now) <= 30 * 60 ? .arriving : .cruise
            }
            return .cruise
        }
        return .checkIn
    }

    // MARK: - Status helpers

    private static func searchStatus(_ f: APIFlight) -> String {
        if f.cancelled == true { return "CANCELLED" }
        if f.status == "Delayed" { return "DELAYED" }
        return "ON-TIME"
    }

    private static func detailStatus(_ f: APIFlight, phase: FlightPhase) -> String {
        if f.cancelled == true { return "CANCELLED" }
        if phase == .arrived    { return "LANDED" }
        let dep = f.departure_delay ?? 0
        let arr = f.arrival_delay ?? 0
        return (dep > 900 || arr > 900) ? "DELAYED" : "ON-TIME"
    }

    // MARK: - Formatting helpers

    // Tries plain ISO 8601 first, then with fractional seconds — AeroAPI sometimes
    // returns "2026-08-02T12:25:00.000Z" which the default formatter rejects.
    private static func parseDate(_ raw: String) -> Date? {
        let plain = ISO8601DateFormatter()
        if let d = plain.date(from: raw) { return d }
        let frac = ISO8601DateFormatter()
        frac.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return frac.date(from: raw)
    }

    private static func makeTimeFmt(timezone: TimeZone = .current) -> DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        fmt.amSymbol = "AM"
        fmt.pmSymbol = "PM"
        fmt.timeZone = timezone
        return fmt
    }

    private static func timeFormatted(_ raw: String?, timeFmt: DateFormatter) -> String {
        guard let raw, let d = parseDate(raw) else { return "--:--" }
        return timeFmt.string(from: d)
    }

    private static func countdown(to raw: String?, minutesBefore: Int = 0, now: Date) -> String {
        guard let raw, let target = parseDate(raw) else { return "--" }
        let deadline = target.addingTimeInterval(-Double(minutesBefore) * 60)
        let secs = deadline.timeIntervalSince(now)
        guard secs > 0 else { return "--" }
        let mins = Int(secs / 60)
        let h = mins / 60
        let m = mins % 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }
}

// MARK: - Detail model

struct FlightDetail {
    let status: String
    let phase: FlightPhase
    let gateOrigin: String
    let gateDestination: String
    let baggageClaim: String
    let timeUntilDep: String
    let timeRemaining: String
    let scheduledOut: String
    let estimatedIn: String
    let actualIn: String
}

// MARK: - Decodable models

private struct FlightsEnvelope: Decodable {
    let flights: [APIFlight]
}

private struct APIFlight: Decodable {
    let fa_flight_id: String
    let ident: String
    let origin: APIAirport?
    let destination: APIAirport?
    let scheduled_out: String?
    let estimated_out: String?
    let actual_out: String?
    let actual_off: String?
    let scheduled_in: String?
    let estimated_in: String?
    let actual_in: String?
    let status: String?
    let progress_percent: Int?
    let gate_origin: String?
    let gate_destination: String?
    let baggage_claim: String?
    let departure_delay: Int?
    let arrival_delay: Int?
    let cancelled: Bool?
}

private struct APIAirport: Decodable {
    let code_iata: String?
    let timezone: String?
}
