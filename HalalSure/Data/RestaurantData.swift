import Foundation
import CoreLocation

/// Static seed data for the “Certified Halal Restaurants” section.
enum RestaurantData {
    static let sampleByCity: [String: [CertifiedRestaurant]] = [
        "Toronto": [
            CertifiedRestaurant(
                name: "Paramount Fine Foods",
                city: "Toronto",
                address: "253 Yonge St, Toronto, ON",
                phone: "(416) 555-0123",
                imageName: "rest_paramount",   // add image to Assets or set nil
                latitude: 43.6541,
                longitude: -79.3802
            ),
            CertifiedRestaurant(
                name: "Lazeez Shawarma",
                city: "Toronto",
                address: "475 Yonge St, Toronto, ON",
                phone: "(416) 555-0456",
                imageName: "rest_lazeez",
                latitude: 43.6622,
                longitude: -79.3833
            )
        ],
        "Brampton": [
            CertifiedRestaurant(
                name: "Taza Xpress",
                city: "Brampton",
                address: "80 Pertosa Dr, Brampton, ON",
                phone: "(905) 555-0199",
                imageName: "rest_taza",
                latitude: 43.6562,
                longitude: -79.7659
            ),
            CertifiedRestaurant(
                name: "Pita Land",
                city: "Brampton",
                address: "25 Peel Centre Dr, Brampton, ON",
                phone: "(905) 555-0117",
                imageName: "rest_pitaland",
                latitude: 43.7170,
                longitude: -79.7214
            )
        ],
        "Mississauga": [
            CertifiedRestaurant(
                name: "Masala Bites",
                city: "Mississauga",
                address: "3050 Confederation Pkwy, Mississauga, ON",
                phone: "(905) 555-0147",
                imageName: "rest_masalabites",
                latitude: 43.5900,
                longitude: -79.6441
            ),
            CertifiedRestaurant(
                name: "Karachi Grill",
                city: "Mississauga",
                address: "2232 Dundas St E, Mississauga, ON",
                phone: "(905) 555-0188",
                imageName: "rest_karachigrill",
                latitude: 43.6110,
                longitude: -79.5740
            )
        ]
    ]
}
