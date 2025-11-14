import SwiftUI

// MARK: - Models
enum CertificationStatus: String {
    case halal = "Halal"
    case doubtful = "Doubtful"
    case haram = "Haram"
    case unknown = "Unknown"

    var tint: Color {
        switch self {
        case .halal: return Brand.green
        case .doubtful: return .orange
        case .haram: return .red
        case .unknown: return .gray
        }
    }
}

struct VerifiedItem: Identifiable {
    let id = UUID()
    let name: String
    let brand: String
    let upc: String
    let status: CertificationStatus
    let lastChecked: Date
}

enum ProductCategory: String, CaseIterable, Identifiable {
    case food = "Food"
    case cosmetics = "Cosmetics"
    case pharma = "Pharma"
    case personal = "Personal Care"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .cosmetics: return "hand.raised.fill"
        case .pharma: return "pills.fill"
        case .personal: return "face.smiling"
        }
    }
}

// MARK: - Sample data for Home
enum SampleData {
    static let recent: [VerifiedItem] = [
        .init(name: "Olive Oil",          brand: "PureLife",    upc: "0123456789012", status: .halal,    lastChecked: .now),
        .init(name: "Vitamin D Tablets",  brand: "WellnessCo",  upc: "0987654321098", status: .doubtful, lastChecked: .now.addingTimeInterval(-3600)),
        .init(name: "Moisturizing Cream", brand: "SoftGlow",    upc: "1122334455667", status: .unknown,  lastChecked: .now.addingTimeInterval(-7200))
    ]
}
