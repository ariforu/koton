import SwiftUI
import UIKit
struct Country: Identifiable, Codable, Hashable {
    var id: String { code }
    let name: String
    let code: String
    let emoji: String
    let unicode: String
    let image: URL?
}

struct ContentView: View {
    @State private var countries: [Country] = []
    @State private var isLoading = true
    let service = ClickstreamService()
    var body: some View {
        VStack {
            Text("⚽ Arijit's Flag Shop ⚽")
                .font(.largeTitle)
        }
        VStack {
            if isLoading {
                ProgressView("Loading…")
            } else {
                ScrollView {
                    Grid(alignment: .center, horizontalSpacing: 3, verticalSpacing: 3) {
                        ForEach(countries.chunked(into: 3), id: \.self) { row in
                            GridRow {
                                ForEach(row) { country in
                                    VStack {
                                        Button {
                                            // ✅ Handle click here (e.g., navigate, open link, etc.)
                                            print("Tapped \(country.name)")

                                            Task {
                                                do {
                                                    let ack = try await service.sendClickstream(
                                                        deviceID: UIDevice.current.identifierForVendor?.uuidString ?? "device-id-not-available",
                                                        eventID: UUID().uuidString,
                                                        eventTime: Int64(Date().timeIntervalSince1970),
                                                        productID: "\(country.name) Flag",
                                                        eventType: "tap",
                                                        userID: "iphone-user-02",
                                                        recordTime: Int64(Date().timeIntervalSince1970)
                                                    )
                                                    print("✅ Ack from server:", ack.success, ack.message)
                                                } catch {
                                                    print("❌ gRPC error:", error)
                                                }
                                            }
                                        } label: {
                                        AsyncImage(url: country.image) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(maxWidth: 120, maxHeight: 120)
                                            default:
                                                Text(country.emoji)
                                                    .font(.largeTitle)
                                            }
                                        }
                                    }
                                        Text(country.name)
                                            .font(.caption)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .padding(4)
                                }
                                // Fill remaining columns if row < 3
                                if row.count < 3 {
                                    ForEach(0..<(3 - row.count), id: \.self) { _ in
                                        Color.clear.frame(height: 1)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .task { await loadCountries() }
    }

    func loadCountries() async {
        guard let url = URL(string: "https://cdn.jsdelivr.net/npm/country-flag-emoji-json@2.0.0/dist/index.json") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            countries = try JSONDecoder().decode([Country].self, from: data)
        } catch {
            print("❌ Failed to load: \(error)")
        }
        isLoading = false
    }
}

// Helper to group countries into rows of 3
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    ContentView()
}

