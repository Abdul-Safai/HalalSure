import SwiftUI
import MapKit
import CoreLocation

struct RestaurantDetailView: View {
    let restaurant: CertifiedRestaurant
    @Environment(\.openURL) private var openURL

    // Fallback if coordinate is missing (Toronto)
    private var coordinate: CLLocationCoordinate2D {
        restaurant.coordinate ?? CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832)
    }

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(center: coordinate,
                           span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }

    private var displayPhone: String {
        if let p = restaurant.phone, !p.trimmingCharacters(in: .whitespaces).isEmpty {
            return p
        }
        return "Not provided"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                // Image (optional)
                if let imgName = restaurant.imageName,
                   let ui = UIImage(named: imgName) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.25), lineWidth: 0.8))
                }

                // Basic info
                VStack(alignment: .leading, spacing: 6) {
                    Text(restaurant.name)
                        .font(.title2.bold())
                    Text(restaurant.city)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(restaurant.address)
                        .font(.subheadline)
                }

                // Map with a marker (uses safe fallback coordinate)
                Map(initialPosition: .region(region)) {
                    Marker(restaurant.name, coordinate: coordinate)
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.black.opacity(0.08), lineWidth: 0.6))

                // Contact row
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundStyle(.secondary)
                        Text(displayPhone)
                    }

                    HStack(spacing: 10) {
                        Button {
                            callRestaurant()
                        } label: {
                            Label("Call", systemImage: "phone")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(restaurant.phone?.isEmpty ?? true)

                        Button {
                            openInMaps()
                        } label: {
                            Label("Open in Maps", systemImage: "map")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle(restaurant.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Actions
    private func callRestaurant() {
        guard let raw = restaurant.phone?
                .filter({ "0123456789+".contains($0) }),
              !raw.isEmpty,
              let url = URL(string: "tel://\(raw)") else { return }
        openURL(url)
    }

    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = restaurant.name
        item.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}
