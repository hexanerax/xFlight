//
//  AddFlightView.swift
//  xFlight Watch App
//
//  Created by Shubhankar Singh on 8/2/26.
//

import SwiftUI

struct AddFlightView: View {
    @State private var query: String = ""
    @State private var navigate: Bool = false
    @Binding var savedFlights: [FlightResult]
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {

            // Search bar
            TextField("eg. AAL341", text: $query)
                .font(.system(size: 16, design: .rounded))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black)
                )
                .padding(.horizontal, 4)
                .onSubmit {
                    if !query.isEmpty {
                        navigate = true
                    }
                }

            // Empty state
            VStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.secondary)
                Text("Search for Flight Numbers")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.top, 8)
        .navigationTitle("Add Flight")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .navigationDestination(isPresented: $navigate) {
            FlightResultsView(query: query, savedFlights: $savedFlights, onAdd: onAdd)
        }
    }
}

#Preview {
    NavigationStack {
        AddFlightView(savedFlights: .constant([]), onAdd: {})
    }
}
