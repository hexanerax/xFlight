# xFlight

A standalone watchOS app for tracking flights from your wrist. Add a flight, search results, and see live status and details, powered by the [FlightAware AeroAPI](https://www.flightaware.com/aeroapi/).

## Requirements

- Xcode (with the watchOS SDK)
- A FlightAware AeroAPI key

## Setup

1. Clone the repo and open `xFlight.xcodeproj`.
2. Copy the secrets template and add your key:

   ```bash
   cp "xFlight Watch App/Secrets.swift.template" "xFlight Watch App/Secrets.swift"
   ```

   Then set `aeroAPIKey` in `Secrets.swift`. This file is gitignored and must never be committed.
3. Select the `xFlight Watch App` scheme and run it on an Apple Watch simulator or device.

## Project layout

| File | Purpose |
| --- | --- |
| `xFlightApp.swift` | App entry point |
| `ContentView.swift` | Main list of tracked flights |
| `AddFlightView.swift` | Add a flight to track |
| `FlightResultsView.swift` | Search results |
| `FlightDetailVIew.swift` | Flight detail screen |
| `AeroAPIService.swift` | FlightAware AeroAPI client |
| `AirportTimezones.swift` | Airport timezone lookups |

## License

MIT, see [LICENSE](LICENSE).
