//
//  FlightDetailView.swift
//  xFlight
//
//  Created by Shubhankar Singh on 8/2/26.
//

import SwiftUI

enum FlightPhase: Codable {
    case checkIn, cruise, arriving, arrived
}

struct FlightDetailView: View {

    @Binding var flight: FlightResult
    @State private var detail: FlightDetail? = nil
    @State private var isLoading = false

    private var currentPhase: FlightPhase {
        detail?.phase ?? flight.phase
    }

    private var currentStatus: String {
        detail?.status ?? flight.status
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if isLoading {
                ProgressView()
            } else {
                VStack(spacing: 0) {

                    // Flight illustration
                    Image(illustrationName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 176, height: 83)
                        .clipped()
                        .id(currentPhase)
                        .transition(.opacity)

                    // Gate row
                    HStack {
                        HStack(spacing: 4) {
                            if currentPhase == .checkIn {
                                HStack(spacing: 2) {
                                    Image(systemName: "door.right.hand.open")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.yellow)

                                    Text(detail?.timeUntilDep ?? "--")
                                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                                        .fixedSize()
                                        .foregroundStyle(.yellow)
                                }
                                .transition(.opacity)
                            } else if currentPhase == .cruise {
                                HStack(spacing: 2) {
                                    Image(systemName: "airplane.path.dotted")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.yellow)

                                    Text(detail?.timeRemaining ?? "--")
                                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                                        .fixedSize()
                                        .foregroundStyle(.yellow)
                                }
                                .transition(.opacity)
                            }

                            // Pill
                            if currentPhase != .cruise && !(currentPhase == .checkIn && pillText == "--") {
                                HStack(spacing: 4) {
                                    if currentPhase == .arrived {
                                        Image(systemName: "briefcase.fill")
                                            .font(.system(size: 11, weight: .semibold))
                                    }
                                    Text(pillText)
                                }
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundStyle(.yellow)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Capsule().stroke(.yellow, lineWidth: 1))
                                .fixedSize()
                                .id("pill-\(currentPhase)")
                                .transition(.opacity)
                            }

                            Spacer()
                        }

                        Spacer()

                        // Right
                        Text(phaseLabel)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .id("label-\(currentPhase)")
                            .transition(.opacity)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Destination Row
                    HStack {
                        HStack(spacing: 2) {
                            Text(flight.origin)
                                .font(.system(size: 24, weight: .medium, design: .monospaced))
                            Image(systemName: "arrow.up.forward.circle.fill")
                                .font(.system(size: 13, weight: .medium))
                        }
                        Spacer()
                        Image(ellipsisName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 27, height: 29)
                            .clipped()
                            .id("ellipsis-\(currentPhase)")
                            .transition(.opacity)
                        Spacer()
                        HStack(spacing: 2) {
                            Image(systemName: "arrow.down.right.circle.fill")
                                .font(.system(size: 13, weight: .medium))
                            Text(flight.destination)
                                .font(.system(size: 24, weight: .medium, design: .monospaced))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Bottom Row
                    HStack {
                        HStack(spacing: 2) {
                            Image(systemName: bottomIcon)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(statusColor)
                                .id("airplane-\(currentPhase)")
                                .transition(.opacity)

                            Text(bottomText)
                                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                                .fixedSize()
                                .foregroundStyle(statusColor)
                                .id("time-\(currentPhase)")
                                .transition(.opacity)
                        }

                        Spacer()

                        Text(currentStatus)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundStyle(statusColor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .navigationTitle(flight.flightNumber)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                isLoading = true
                if let d = try? await AeroAPIService.fetchFlightDetail(faFlightId: flight.faFlightId, ident: flight.flightNumber) {
                    detail = d
                    flight = FlightResult(
                        id: flight.id,
                        faFlightId: flight.faFlightId,
                        flightNumber: flight.flightNumber,
                        origin: flight.origin,
                        destination: flight.destination,
                        depTime: flight.depTime,
                        arrTime: d.estimatedIn != "--:--" ? d.estimatedIn : flight.arrTime,
                        scheduledOutDate: flight.scheduledOutDate,
                        status: d.status,
                        phase: d.phase
                    )
                }
                isLoading = false
            }
        }
    }

    // MARK: - Computed properties

    private var statusColor: Color {
        switch currentStatus {
        case "DELAYED":   return .yellow
        case "CANCELLED": return .red
        default:          return .green
        }
    }

    private var illustrationName: String {
        switch currentPhase {
        case .checkIn:  return "graphic_check-in"
        case .cruise:   return "graphic_cruise"
        case .arriving: return "graphic_arriving"
        case .arrived:  return "graphic_arrived"
        }
    }

    private var phaseLabel: String {
        switch currentPhase {
        case .checkIn:  return "CHECK-IN"
        case .cruise:   return "CRUISE"
        case .arriving: return "ARRIVING"
        case .arrived:  return "ARRIVED"
        }
    }

    private var pillText: String {
        switch currentPhase {
        case .checkIn:  return detail?.gateOrigin ?? "--"
        case .arriving: return detail?.gateDestination ?? "--"
        case .arrived:  return detail?.baggageClaim ?? "--"
        case .cruise:   return ""
        }
    }

    private var ellipsisName: String {
        switch currentPhase {
        case .checkIn:  return "ellipsis_1"
        case .cruise:   return "ellipsis_2"
        case .arriving: return "ellipsis_2"
        case .arrived:  return "ellipsis_3"
        }
    }

    private var bottomIcon: String {
        switch currentPhase {
        case .checkIn:  return "airplane.departure"
        case .cruise:   return "airplane.arrival"
        case .arriving: return "airplane.arrival"
        case .arrived:  return "airplane.landed"
        }
    }

    private var bottomText: String {
        switch currentPhase {
        case .checkIn:  return detail?.scheduledOut ?? flight.depTime
        case .cruise:   return detail?.estimatedIn ?? "--:--"
        case .arriving: return detail?.estimatedIn ?? "--:--"
        case .arrived:  return detail?.actualIn ?? "--:--"
        }
    }
}

#Preview {
    NavigationStack {
        FlightDetailView(flight: .constant(FlightResult(
            id: UUID(),
            faFlightId: "AAL341-preview",
            flightNumber: "AAL341",
            origin: "JFK",
            destination: "LAX",
            depTime: "12:25 PM",
            arrTime: "3:10 PM",
            scheduledOutDate: nil,
            status: "ON-TIME",
            phase: .checkIn
        )))
    }
}
