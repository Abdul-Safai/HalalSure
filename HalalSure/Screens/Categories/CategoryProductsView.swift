import SwiftUI

// MARK: - Ruling type
enum Ruling: String, CaseIterable, Codable {
    case approved = "Approved"
    case notApproved = "Not Approved"
    case investigating = "Investigating"
    case unknown = "Unknown"

    var color: Color {
        switch self {
        case .approved:      return .green
        case .notApproved:   return .red
        case .investigating: return .orange
        case .unknown:       return .gray
        }
    }
}

// MARK: - Row model
struct ProductRow: Identifiable, Codable, Equatable {
    let id = UUID()
    let category: String
    let brand: String
    let product: String
    let ruling: Ruling
    let checkDate: String
    let remarks: String
}

// MARK: - Local data store (edit/extend freely)
final class LocalProductsStore {
    static let shared = LocalProductsStore()

    private let tagToCategories: [String: [String]] = [
        "all":        [],
        "baked":      ["Baked Goods"],
        "dairy":      ["Dairy Products"],
        "snacks":     ["Snack Products"],
        "frozen":     ["Frozen Foods"],
        "beverages":  ["Beverages"],
        "condiments": ["Condiments"],
        "other":      ["Other Products"]
    ]

    // Seed data (add/replace with your full list)
    private let all: [ProductRow] = [
        // Dairy
        .init(category: "Dairy Products", brand: "Activia",
              product: "Activia Active Probiotics Immune System",
              ruling: .notApproved, checkDate: "30-Apr-2023",
              remarks: "May Contain Animal Derived Ingredients"),
        .init(category: "Dairy Products", brand: "Activia",
              product: "Activia Gut Health Fibre, Blueberry & Grains Yogurt, 2.1% M.F.",
              ruling: .notApproved, checkDate: "7-Jul-2025",
              remarks: "Product Contains Animal Derived Ingredients"),
        .init(category: "Dairy Products", brand: "Activia",
              product: "Activia Gut Health Fibre, Mango & Grains Yogurt, 2.1% M.F.",
              ruling: .notApproved, checkDate: "7-Jul-2025",
              remarks: "Product Contains Animal Derived Ingredients"),

        // Beverages
        .init(category: "Beverages", brand: "28 Black",
              product: "28 Black Energy Drink, Absolute Zero Guava-Passion Fruit Flavour",
              ruling: .approved, checkDate: "31-Dec-2024",
              remarks: "Product is Vegan Suitable"),
        .init(category: "Beverages", brand: "28 Black",
              product: "28 Black Energy Drink, Acai Flavour",
              ruling: .approved, checkDate: "31-Dec-2024",
              remarks: "Product is Vegan Suitable"),

        // Baked — added CAKE items so Baked Goods shows cake too
        .init(category: "Baked Goods", brand: "City Bakery",
              product: "Butter Croissant",
              ruling: .investigating, checkDate: "12-Mar-2025",
              remarks: "Mono/Diglycerides source under review"),
        .init(category: "Baked Goods", brand: "SweetBake",
              product: "Classic Chocolate Cake",
              ruling: .approved, checkDate: "18-Nov-2024",
              remarks: "No animal-based emulsifiers listed"),
        .init(category: "Baked Goods", brand: "SweetBake",
              product: "Vanilla Sponge Cake",
              ruling: .approved, checkDate: "18-Nov-2024",
              remarks: "Vegetarian-friendly ingredients"),
        .init(category: "Baked Goods", brand: "HomeTreats",
              product: "Marble Cake Loaf",
              ruling: .unknown, checkDate: "—",
              remarks: "Additive E471 source not confirmed"),

        // Snacks
        .init(category: "Snack Products", brand: "Crispo",
              product: "Sea Salt Potato Chips",
              ruling: .approved, checkDate: "05-May-2024",
              remarks: "No animal derivatives listed"),

        // Frozen
        .init(category: "Frozen Foods", brand: "Freezo",
              product: "Veg Supreme Pizza",
              ruling: .unknown, checkDate: "—",
              remarks: "Supplier documents pending"),

        // Condiments
        .init(category: "Condiments", brand: "RedFarm",
              product: "Tomato Ketchup",
              ruling: .approved, checkDate: "21-Jan-2025",
              remarks: "Suitable for vegetarians"),

        // Other
        .init(category: "Other Products", brand: "Harvest",
              product: "Canned Beans",
              ruling: .approved, checkDate: "09-Sep-2024",
              remarks: "No critical additives detected"),
    ]

    func rows(forTag tag: String) -> [ProductRow] {
        guard let cats = tagToCategories[tag.lowercased()] else { return [] }
        if cats.isEmpty { return all }
        return all.filter { cats.contains($0.category) }
    }

    static func slug(from title: String) -> String {
        switch title.lowercased() {
        case "baked goods":    return "baked"
        case "dairy products": return "dairy"
        case "snack products": return "snacks"
        case "frozen foods":   return "frozen"
        case "beverages":      return "beverages"
        case "condiments":     return "condiments"
        case "other products": return "other"
        default:               return "all"
        }
    }
}

// MARK: - Screen (auto: card on phones, table on wide screens)
struct CategoryProductsView: View {
    let categoryTitle: String
    let tag: String
    // Optional: pre-fill the search (e.g., when user tapped “Cake”)
    private let seedQuery: String?

    init(categoryTitle: String, tag: String? = nil, seedQuery: String? = nil) {
        self.categoryTitle = categoryTitle
        self.tag = tag ?? LocalProductsStore.slug(from: categoryTitle)
        self.seedQuery = seedQuery
    }

    @State private var search = ""
    @State private var rows: [ProductRow] = []

    // Table (wide mode) sizing
    private let headerFont = Font.system(size: 14, weight: .semibold)
    private let cellFont   = Font.system(size: 13)
    private let wCategory: CGFloat = 130
    private let wBrand:    CGFloat = 130
    private let wProduct:  CGFloat = 260
    private let wRuling:   CGFloat = 110
    private let wDate:     CGFloat = 110
    private let wRemarks:  CGFloat = 260

    var body: some View {
        GeometryReader { geo in
            let isNarrow = geo.size.width < 520 // iPhone portrait → card style

            VStack(spacing: 0) {
                // Title + search
                HStack(spacing: 10) {
                    Text(categoryTitle).font(.title.bold())
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                        TextField("Search…", text: $search)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .frame(minWidth: 140)
                    }
                    .font(.footnote)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(.ultraThinMaterial))
                    .overlay(Capsule().stroke(.black.opacity(0.08), lineWidth: 0.5))
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 6)

                if isNarrow {
                    // ===== MOBILE: two-column “label | value” cards (like screenshot) =====
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filtered) { r in
                                TwoColumnCard(row: r)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)
                    }
                    .dynamicTypeSize(.xSmall ... .large)
                } else {
                    // ===== WIDE: full table =====
                    ScrollView([.vertical, .horizontal], showsIndicators: true) {
                        VStack(spacing: 0) {
                            tableHeader
                            Divider().opacity(0.35)
                            ForEach(Array(filtered.enumerated()), id: \.element.id) { idx, r in
                                tableRow(r, index: idx)
                                Divider().opacity(0.2)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    .dynamicTypeSize(.xSmall ... .medium)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .task(id: tag) {
            rows = LocalProductsStore.shared.rows(forTag: tag)
            if let seed = seedQuery, search.isEmpty { search = seed }
        }
        .onAppear {
            rows = LocalProductsStore.shared.rows(forTag: tag)
            if let seed = seedQuery, search.isEmpty { search = seed }
        }
    }

    // MARK: - Filter
    private var filtered: [ProductRow] {
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return rows }
        return rows.filter { r in
            r.category.lowercased().contains(q) ||
            r.brand.lowercased().contains(q) ||
            r.product.lowercased().contains(q) ||
            r.ruling.rawValue.lowercased().contains(q) ||
            r.checkDate.lowercased().contains(q) ||
            r.remarks.lowercased().contains(q)
        }
    }

    // MARK: - Wide table helpers
    private var vBorder: some View { Rectangle().fill(Color.black.opacity(0.08)).frame(width: 0.5) }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            header("Category",   minWidth: wCategory, drawRightBorder: true)
            header("Brand Name", minWidth: wBrand,    drawRightBorder: true)
            header("Product Name", minWidth: wProduct, drawRightBorder: true)
            header("Ruling",     minWidth: wRuling,   align: .center, drawRightBorder: true)
            header("Check Date", minWidth: wDate,     drawRightBorder: true)
            header("Remarks",    minWidth: wRemarks,  drawRightBorder: false)
        }
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func tableRow(_ r: ProductRow, index: Int) -> some View {
        HStack(spacing: 0) {
            cell(r.category, minWidth: wCategory, drawRightBorder: true)
            cell(r.brand,    minWidth: wBrand,    drawRightBorder: true)
            cell(r.product,  minWidth: wProduct,  drawRightBorder: true)

            HStack {
                Text(r.ruling.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(r.ruling.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(r.ruling.color.opacity(0.12)))
            }
            .frame(minWidth: wRuling)
            .overlay(vBorder, alignment: .trailing)

            cell(r.checkDate, minWidth: wDate,   drawRightBorder: true)
            cell(r.remarks,   minWidth: wRemarks, drawRightBorder: false)
        }
        .background(index.isMultiple(of: 2)
                    ? Color(.systemBackground)
                    : Color(.secondarySystemBackground))
    }

    private func header(_ title: String, minWidth: CGFloat, align: Alignment = .leading, drawRightBorder: Bool) -> some View {
        Text(title)
            .font(headerFont)
            .foregroundStyle(.primary)
            .frame(minWidth: minWidth, alignment: align)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .overlay(drawRightBorder ? vBorder : nil, alignment: .trailing)
    }

    private func cell(_ text: String, minWidth: CGFloat, align: Alignment = .leading, drawRightBorder: Bool) -> some View {
        Text(text)
            .font(cellFont)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .multilineTextAlignment(.leading)
            .frame(minWidth: minWidth, alignment: align)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .overlay(drawRightBorder ? vBorder : nil, alignment: .trailing)
    }
}

// MARK: - MOBILE card (two columns per field, like your screenshot)
private struct TwoColumnCard: View {
    let row: ProductRow
    private let labelWidth: CGFloat = 140 // left column width (kept consistent)

    var body: some View {
        VStack(spacing: 0) {
            kvRow(label: "Category", valueView:
                    Text(row.category))

            divider()

            kvRow(label: "Brand Name", valueView:
                    Text(row.brand))

            divider()

            kvRow(label: "Product Name", valueView:
                    Text(row.product))

            divider()

            kvRow(label: "Ruling", valueView:
                    Text(row.ruling.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(row.ruling.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(row.ruling.color.opacity(0.12))))

            if !row.checkDate.isEmpty {
                divider()
                kvRow(label: "Check Date", valueView:
                        Text(row.checkDate))
            }

            if !row.remarks.isEmpty {
                divider()
                kvRow(label: "Remarks", valueView:
                        Text(row.remarks))
            }
        }
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(.black.opacity(0.08), lineWidth: 0.6))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    // One “label | value” row
    @ViewBuilder
    private func kvRow<Content: View>(label: String, valueView: Content) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .frame(width: labelWidth, alignment: .leading)
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))

            VStack(alignment: .leading, spacing: 4) {
                valueView
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(Color(.systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }

    // Thin divider between rows
    private func divider() -> some View {
        Rectangle()
            .fill(Color.black.opacity(0.08))
            .frame(height: 0.5)
    }
}
