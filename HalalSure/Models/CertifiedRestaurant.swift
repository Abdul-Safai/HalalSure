import Foundation
import CoreLocation

struct CertifiedRestaurant: Identifiable, Hashable, Equatable {
    // Identity
    let id: UUID

    // Basics
    var name: String
    var city: String
    var address: String

    // Optional metadata
    var phone: String?
    var imageName: String?

    // Optional location (so you can show a map pin when available)
    var latitude: Double?
    var longitude: Double?

    init(
        id: UUID = UUID(),
        name: String,
        city: String,
        address: String,
        phone: String? = nil,
        imageName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.city = city
        self.address = address
        self.phone = phone
        self.imageName = imageName
        self.latitude = latitude
        self.longitude = longitude
    }

    /// Convenience computed property for MapKit
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
