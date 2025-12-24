import SwiftUI
import UIKit

// MARK: - Certification Status
enum CertificationStatus: String {
    case halal = "Halal"
    case doubtful = "Doubtful"
    case haram = "Haram"
    case unknown = "Unknown"

    var tint: Color {
        switch self {
        case .halal:    return Brand.green
        case .doubtful: return .orange
        case .haram:    return .red
        case .unknown:  return .gray
        }
    }
}

// MARK: - Verified Item
struct VerifiedItem: Identifiable {
    let id = UUID()
    let name: String
    let brand: String
    let upc: String
    let status: CertificationStatus
    let lastChecked: Date
}

// MARK: - Product Category (with images)
enum ProductCategory: String, CaseIterable, Identifiable {
    case food        = "Food"
    case cosmetics   = "Cosmetics"
    case pharma      = "Pharma"
    case personal    = "Personal Care"

    var id: String { rawValue }

    /// SF Symbol fallback if the asset image is missing.
    var icon: String {
        switch self {
        case .food:       return "fork.knife"
        case .cosmetics:  return "hand.raised.fill"
        case .pharma:     return "pills.fill"
        case .personal:   return "face.smiling"
        }
    }

    /// Asset image names. Add square images to Assets.xcassets with these names.
    var imageName: String {
        switch self {
        case .food:       return "cat_food"
        case .cosmetics:  return "cat_cosmetics"
        case .pharma:     return "cat_pharma"
        case .personal:   return "cat_personal"
        }
    }

    /// Convenience accessor for SwiftUI Image if present.
    var image: Image? {
        UIImage(named: imageName).map { Image(uiImage: $0) }
    }
}

// MARK: - Sample Data
enum SampleData {
    static let recent: [VerifiedItem] = [
        .init(name: "Olive Oil",
              brand: "PureLife",
              upc: "0123456789012",
              status: .halal,
              lastChecked: .now),

        .init(name: "Vitamin D Tablets",
              brand: "WellnessCo",
              upc: "0987654321098",
              status: .doubtful,
              lastChecked: .now.addingTimeInterval(-3600)),

        .init(name: "Moisturizing Cream",
              brand: "SoftGlow",
              upc: "1122334455667",
              status: .unknown,
              lastChecked: .now.addingTimeInterval(-7200))
    ]
}
