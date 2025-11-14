import SwiftUI

// Modern recent card
struct RecentCard: View {
    let item: VerifiedItem

    var body: some View {
        SoftCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(item.status.tint.opacity(0.14))
                    Image(systemName:
                          item.status == .halal ? "checkmark.seal.fill" :
                          item.status == .haram ? "xmark.seal.fill" :
                          item.status == .doubtful ? "questionmark.circle.fill" :
                          "exclamationmark.triangle.fill")
                        .foregroundStyle(item.status.tint)
                }
                .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                    HStack(spacing: 8) {
                        Text(item.brand).foregroundStyle(.secondary)
                        Text("•")
                        Text("#\(item.upc)").foregroundStyle(.secondary)
                    }
                    .font(.caption)
                }
                Spacer()
                Text(item.status.rawValue)
                    .font(.footnote).bold()
                    .foregroundStyle(item.status.tint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(item.status.tint.opacity(0.12), in: Capsule())
            }
        }
    }
}

// (Optional) legacy chips if you want this variant instead of SelectableChip
struct CategoryChips: View {
    @Binding var selected: ProductCategory?
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(ProductCategory.allCases) { cat in
                    let isSel = selected == cat
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                            selected = (isSel ? nil : cat)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: cat.icon)
                            Text(cat.rawValue)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(isSel ? Brand.green.opacity(0.18) : Brand.bgSoft, in: Capsule())
                        .overlay(Capsule().stroke(Brand.green.opacity(0.35), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
