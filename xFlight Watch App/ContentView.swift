//
//  ContentView.swift
//  xFlight Watch App
//
//  Created by Shubhankar Singh on 8/2/26.
//

import SwiftUI

struct ContentView: View {
    @State private var savedFlights: [FlightResult] = {
        guard let data = UserDefaults.standard.data(forKey: "savedFlights"),
              let flights = try? JSONDecoder().decode([FlightResult].self, from: data)
        else { return [] }
        return flights
    }()
    @State private var showAddFlight: Bool = false

    private func persist() {
        if let data = try? JSONEncoder().encode(savedFlights) {
            UserDefaults.standard.set(data, forKey: "savedFlights")
        }
    }

    var body: some View {
        Group {
            if savedFlights.isEmpty {
                // Empty state
                VStack(spacing: 8) {
                    Image("graphic_main_empty")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 176, height: 83)
                    
                    Text("Tap + to add a Flight")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                List {
                    ForEach(savedFlights.indices, id: \.self) { i in
                        NavigationLink {
                            FlightDetailView(flight: $savedFlights[i])
                        } label: {
                            FlightCard(
                                flightNumber: savedFlights[i].flightNumber,
                                origin: savedFlights[i].origin,
                                destination: savedFlights[i].destination,
                                arrTime: savedFlights[i].arrTime,
                                status: savedFlights[i].status,
                                phase: savedFlights[i].phase
                            )
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }
                    .onDelete { indexSet in
                        savedFlights.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .onChange(of: savedFlights) { persist() }
        .navigationTitle("xFlight")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showAddFlight = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddFlight) {
            NavigationStack {
                AddFlightView(savedFlights: $savedFlights, onAdd: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showAddFlight = false
                    }
                })
            }
        }
    }
}

struct FlightCard: View {
    let flightNumber: String
    let origin: String
    let destination: String
    let arrTime: String
    let status: String
    let phase: FlightPhase

    private var statusColor: Color {
        switch status {
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
                Text(flightNumber)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(status)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(statusColor)
            }
            
            // Bottom row — origin -> destination + dep time
            HStack(alignment: .bottom) {
                HStack(spacing: 2) {
                    Text(origin)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text(destination)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                Spacer()

                HStack(spacing: 2) {
                    Image(systemName: "airplane.arrival")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(arrTime)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(.horizontal, 12)
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
        ContentView()
    }
}
