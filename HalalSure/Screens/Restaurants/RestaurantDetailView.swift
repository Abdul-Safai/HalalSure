import SwiftUI
import CoreLocation

struct RestaurantsByCityList: View {
    /// Dictionary of city -> restaurants
    let data: [String: [CertifiedRestaurant]]

    var body: some View {
        List {
            ForEach(data.keys.sorted(), id: \.self) { city in
                Section(header: Text(city).font(.headline)) {
                    ForEach(data[city] ?? []) { r in
                        NavigationLink {
                            RestaurantDetailView(restaurant: r)
                        } label: {
                            Text(r.name)
                                .font(.body)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Certified Restaurants")
    }
}
