import SwiftUI
import UIKit

// MARK: - Brand tokens (with fallback if the asset is missing)
enum Brand {
    // Try the asset "BrandGreen"; if not found, fallback to the hex.
    static let green: Color = {
        if let ui = UIColor(named: "BrandGreen") {
            return Color(ui)
        } else {
            // Fallback: #0E9F45
            return Color(red: 0.055, green: 0.623, blue: 0.271)
        }
    }()

    static let bgSoft = Color(.secondarySystemBackground)
    static let stroke = Color.gray.opacity(0.14)
    static let shadow = Color.black.opacity(0.08)
}

// MARK: - Reusable soft card
struct SoftCard<Content: View>: View {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 18
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(Brand.bgSoft, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Brand.stroke, lineWidth: 1)
            )
            .shadow(color: Brand.shadow, radius: 16, x: 0, y: 8)
    }
}

// MARK: - Selectable chip
struct SelectableChip: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? Brand.green.opacity(0.18) : Brand.bgSoft)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Brand.green.opacity(0.35), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
    }
}
