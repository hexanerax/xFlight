//
//  FlightResultsView.swift
//  xFlight Watch App
//
//  Created by Shubhankar Singh on 8/2/26.
//

import SwiftUI

struct FlightResult: Identifiable, Codable, Equatable {
    let id: UUID
    let faFlightId: String
    let flightNumber: String
    let origin: String
    let destination: String
    let depTime: String
    let arrTime: String
    let scheduledOutDate: Date?
    let status: String
    let phase: FlightPhase
}

struct FlightResultsView: View {
    let query: String
    @Binding var savedFlights: [FlightResult]
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var results: [FlightResult] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text(error)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if results.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text("No flights found")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(results) { result in
                        Button {
                            if !savedFlights.contains(where: { $0.flightNumber == result.flightNumber }) {
                                savedFlights.append(result)
                            }
                            onAdd()
                        } label: {
                            FlightResultCard(result: result)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("'" + query + "'")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .task {
            await loadResults()
        }
    }

    private func loadResults() async {
        isLoading = true
        errorMessage = nil
        do {
            results = try await AeroAPIService.searchFlights(ident: query)
        } catch AeroAPIError.httpError(let code) {
            errorMessage = "Server error (\(code))"
        } catch {
            errorMessage = "Could not load flights"
        }
        isLoading = false
    }
}

struct FlightResultCard: View {
    let result: FlightResult

    private var timeLabel: String {
        if result.phase != .checkIn { return "LIVE" }
        guard let depDate = result.scheduledOutDate else { return result.depTime }
        let cal = Calendar.current
        let days = cal.dateComponents([.day],
                                      from: cal.startOfDay(for: Date()),
                                      to: cal.startOfDay(for: depDate)).day ?? 0
        return days > 0 ? "+\(days)d" : result.depTime
    }

    private var statusColor: Color {
        switch result.status {
        case "ON-TIME":   return .green
        case "DELAYED":   return .yellow
        case "CANCELLED": return .red
        default:          return .secondary
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // Top row — flight number + status
            HStack {
                Text(result.flightNumber)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer()

                Text(result.status)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(statusColor)
            }

            // Bottom row — origin -> destination + time
            HStack(alignment: .bottom) {
                HStack(spacing: 4) {
                    Text(result.origin)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text(result.destination)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                Text(timeLabel)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(red: 30/255, green: 30/255, blue: 30/255), lineWidth: 2)
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
    }
}

#Preview {
    NavigationStack {
        FlightResultsView(query: "AAL", savedFlights: .constant([]), onAdd: {})
    }
}
