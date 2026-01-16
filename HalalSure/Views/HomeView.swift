import SwiftUI
import UIKit

// MARK: - Navigation Route
private enum Route: Hashable {
    case category(String)
}

// ======================================================
// HomeView — header rail + seamless Popular marquee
// Grid categories with navigation + scan FAB
// Pulls "Popular" labels via local proxy (optional)
// ======================================================
struct HomeView: View {
    @State private var path: [Route] = []

    @State private var query: String = ""
    @State private var recent: [VerifiedItem] = SampleData.recent
    @State private var showingScanner = false

    // web-fed popular items (fallback to assets if empty)
    @State private var popularFromWeb: [PopularItem] = []

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottomTrailing) {
                BackgroundSurface()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {

                        // Header
                        HeroHeaderRail()

                        // Search
                        SearchPill(query: $query)
                            .padding(.horizontal, 16)

                        // ===== Popular (auto-scrolling, seamless, tappable) =====
                        let chosen = uniqueByTitle(popularFromWeb.isEmpty ? PopularItem.demo : popularFromWeb)
                        PopularTickerLoop(
                            items: chosen,
                            speed: 8,      // points per second
                            spacing: 10
                        ) { item in
                            let catTitle = destinationCategory(for: item.title)
                            path.append(.category(catTitle))
                        }
                        .padding(.top, 2)

                        // Categories
                        VStack(spacing: 8) {
                            SectionTitle("Categories")
                                .padding(.horizontal, 16)

                            CategoryGridTwoColumn(categories: VisualCategory.foodTiles) { selected in
                                path.append(.category(selected.title))
                            }
                            .padding(.horizontal, 16)
                        }

                        // Recents
                        if !recent.isEmpty {
                            HStack {
                                SectionTitle("Recent verifications")
                                Spacer()
                                Button {
                                    withAnimation(.easeInOut) { recent.removeAll() }
                                } label: {
                                    Label("Clear", systemImage: "trash")
                                        .labelStyle(.titleAndIcon)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal, 16)

                            VStack(spacing: 10) {
                                ForEach(recent) { item in
                                    RecentRowCard(item: item)
                                        .padding(.horizontal, 16)
                                }
                            }
                        }

                        Color.clear.frame(height: 110) // space for FAB + tab bar
                    }
                    .padding(.top, 6)
                }

                // Floating Scan FAB
                ScanFAB { showingScanner = true }
                    .padding(.trailing, 18)
                    .padding(.bottom, 34)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .principal) { EmptyView() } }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .category(let title):
                    CategoryProductsView(categoryTitle: title)
                }
            }
        }
        .tint(Brand.green)
        .sheet(isPresented: $showingScanner) {
            ScannerView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .task { await loadPopularFromWeb() }
    }

    // MARK: - Remote Popular (via local PHP proxy)
    @MainActor
    private func loadPopularFromWeb() async {
        guard let url = URL(string:
            "http://localhost/halalsure-api/proxy.php?url=https://hmacanada.org/halal-check/"
        ) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let resp = try JSONDecoder().decode(HalalProxyResponse.self, from: data)
            let labels = extractPopularLabels(from: resp.html)

            var mapped: [PopularItem] = labels.compactMap { label in
                let key = label.lowercased()
                if let m = siteToAssetMap[key] {
                    return PopularItem(title: m.title, imageName: m.imageName)
                }
                return nil
            }

            mapped = uniqueByTitle(mapped)

            if !mapped.isEmpty {
                popularFromWeb = mapped
            }
        } catch {
            print("Popular fetch/parsing failed:", error.localizedDescription)
        }
    }

    private func extractPopularLabels(from html: String) -> [String] {
        guard let range = html.range(of: "Popular Categories", options: .caseInsensitive) else {
            return []
        }
        let tail = html[range.upperBound...]
        let window = String(tail.prefix(600))

        let candidates = [
            "Cheese","Pizza","Croissant","Croissants","Yogurt","Chocolate",
            "Beans","Lentils","Lentis","Juice","Spice","Spices","Soft Drinks",
            "Chips","Cookies","Beverages","Drinks"
        ]

        var found: [String] = []
        for w in candidates {
            if window.range(of: w, options: .caseInsensitive) != nil {
                if w.lowercased() == "croissant" &&
                    !found.contains(where: { $0.caseInsensitiveCompare("Croissants") == .orderedSame }) {
                    found.append("Croissants")
                } else if !found.contains(where: { $0.caseInsensitiveCompare(w) == .orderedSame }) {
                    found.append(w)
                }
            }
        }

        let preferred = ["Cheese","Pizza","Croissants","Yogurt","Chocolate","Beans","Lentils","Juice","Spices","Soft Drinks","Chips","Cookies","Drinks","Beverages"]
        let ordered = preferred.filter { p in found.contains(where: { $0.caseInsensitiveCompare(p) == .orderedSame }) }
        return ordered.isEmpty ? found : ordered
    }

    // NOTE: Cheese label shows as "Cake" (asset stays "cheese")
    private var siteToAssetMap: [String:(title: String, imageName: String)] {
        [
            "cheese":        ("Cake","cheese"),
            "pizza":         ("Pizza","pizza"),
            "croissant":     ("Croissants","crosissant"),
            "croissants":    ("Croissants","crosissant"),
            "juice":         ("Juice","juice"),
            "soft drinks":   ("Drinks","drink"),
            "drinks":        ("Drinks","drink"),
            "chips":         ("Chips","chips"),
            "cookies":       ("Cookies","cookies")
        ]
    }

    private func uniqueByTitle(_ items: [PopularItem]) -> [PopularItem] {
        var seen = Set<String>()
        var out: [PopularItem] = []
        for it in items {
            let key = it.title.lowercased()
            if !seen.contains(key) {
                seen.insert(key)
                out.append(it)
            }
        }
        return out
    }

    private func destinationCategory(for popularTitle: String) -> String {
        let t = popularTitle.lowercased()
        if ["drink","drinks","juice"].contains(t) { return "Beverages" }
        if ["chips","cookies","pizza","croissants"].contains(t) { return "Snack Products" }
        if ["cake"].contains(t) { return "Baked Goods" }
        return "All Products"
    }
}

// ===== Proxy JSON model =====
private struct HalalProxyResponse: Decodable {
    let status: Int
    let url: String
    let html: String
}

// ===============================
// Background (subtle pattern + glow)
// ===============================
private struct BackgroundSurface: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .top, endPoint: .bottom
            )

            RadialGradient(
                colors: [Brand.green.opacity(0.14), .clear],
                center: .topLeading, startRadius: 20, endRadius: 420
            )
            .ignoresSafeArea()

            GeometryReader { proxy in
                let w = proxy.size.width, h = proxy.size.height
                Canvas { ctx, _ in
                    let spacing: CGFloat = 26
                    let dot = Path(ellipseIn: CGRect(x: 0, y: 0, width: 1.6, height: 1.6))
                    let cx = Int(w / spacing) + 2, cy = Int(h / spacing) + 2
                    ctx.opacity = 0.045
                    for i in 0..<cx {
                        for j in 0..<cy {
                            let t = CGAffineTransform(translationX: CGFloat(i) * spacing,
                                                      y: CGFloat(j) * spacing)
                            ctx.fill(dot.applying(t), with: .color(.black))
                        }
                    }
                }
            }
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

// ===============================
// Accent-Rail header card (compact)
// ===============================
private struct HeroHeaderRail: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Brand.green.opacity(0.35),
                                         Brand.green.opacity(0.14)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.9
                        )
                )
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)

            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [Brand.green, Brand.green.opacity(0.75)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 6, height: 64)
                    .padding(.leading, 10)

                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Brand.green, Brand.green.opacity(0.85)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .overlay(Circle().stroke(.white.opacity(0.28), lineWidth: 0.7))
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Trust. Tech. Transparency.")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text("HalalSure")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Brand.green, Brand.green.opacity(0.72)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )

                    Text("Scan or search to verify halal-friendly products.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 6)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .padding(.horizontal, 16)
    }
}

// ===============================
// Search pill
// ===============================
private struct SearchPill: View {
    @Binding var query: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Search products or UPC…", text: $query)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            if !query.isEmpty {
                Button { withAnimation { query = "" } } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Capsule().fill(.ultraThinMaterial))
        .overlay(Capsule().strokeBorder(.black.opacity(0.08), lineWidth: 0.8))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// ===============================
// Section title
// ===============================
private struct SectionTitle: View {
    var text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(.title2, design: .rounded).weight(.semibold))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// ===============================
// Visual categories model
// ===============================
struct VisualCategory: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let tag: String
}

extension VisualCategory {
    static let foodTiles: [VisualCategory] = [
        .init(title: "All Products",   imageName: "cat_all",        tag: "all"),
        .init(title: "Baked Goods",    imageName: "cat_baked",      tag: "baked"),
        .init(title: "Dairy Products", imageName: "cat_dairy",      tag: "dairy"),
        .init(title: "Snack Products", imageName: "cat_snack",      tag: "snacks"),
        .init(title: "Frozen Foods",   imageName: "cat_frozen",     tag: "frozen"),
        .init(title: "Beverages",      imageName: "cat_beverages",  tag: "beverages"),
        .init(title: "Condiments",     imageName: "cat_condiments", tag: "condiments"),
        .init(title: "Other Products", imageName: "cat_other",      tag: "other")
    ]
}

// ===============================
// Category Grid (2 columns) — uses onSelect to push
// ===============================
private struct CategoryGridTwoColumn: View {
    let categories: [VisualCategory]
    var onSelect: (VisualCategory) -> Void

    private let cols = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        LazyVGrid(columns: cols, spacing: 14) {
            ForEach(categories) { cat in
                Button { onSelect(cat) } label: {
                    CategoryTileCard(cat: cat)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// ===============================
// Category tile — plain view (no internal nav)
// ===============================
private struct CategoryTileCard: View {
    let cat: VisualCategory

    private let innerCorner: CGFloat = 16
    private let outerCorner: CGFloat = 20
    private let maxImageHeight: CGFloat = 145

    var body: some View {
        VStack(spacing: 8) {
            if let raw = UIImage(named: cat.imageName) {
                let ui = raw.trimmedTransparentPixels(padding: 8)
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: maxImageHeight)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: innerCorner, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: innerCorner, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: innerCorner)
                    .fill(Brand.green.opacity(0.10))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(Brand.green)
                    )
                    .frame(height: 112)
            }

            Text(cat.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.88)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: outerCorner, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: outerCorner, style: .continuous)
                .stroke(.white.opacity(0.32), lineWidth: 0.6)
        )
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 5)
        .contentShape(Rectangle())
    }
}

// ===============================
// Floating Scan FAB (compact, pulsing)
// ===============================
private struct ScanFAB: View {
    var action: () -> Void
    @State private var pulse = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 22, weight: .bold))
                .padding(18)
                .background(
                    Circle().fill(
                        LinearGradient(colors: [Brand.green, Brand.green.opacity(0.85)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                )
                .foregroundStyle(.white)
                .shadow(color: Brand.green.opacity(0.40), radius: 14, x: 0, y: 8)
                .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 0.8))
                .scaleEffect(pulse ? 1.04 : 1.0)
                .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: pulse)
        }
        .buttonStyle(.plain)
        .onAppear { pulse = true }
        .accessibilityLabel("Scan a barcode")
    }
}

// ===============================
// Recent item row
// ===============================
private struct RecentRowCard: View {
    let item: VerifiedItem
    var badgeColor: Color {
        switch item.status {
        case .halal:    return Brand.green
        case .doubtful: return .orange
        case .haram:    return .red
        case .unknown:  return .gray
        }
    }
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(badgeColor.opacity(0.14))
                Image(systemName:
                        item.status == .halal ? "checkmark.seal.fill" :
                        item.status == .doubtful ? "questionmark.circle.fill" :
                        item.status == .haram ? "xmark.octagon.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(badgeColor)
                .font(.system(size: 18, weight: .semibold))
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.headline).foregroundStyle(.primary)
                Text("\(item.brand)  •  #\(item.upc)")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Text(item.status.rawValue)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(badgeColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(badgeColor.opacity(0.12)))
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(.white.opacity(0.25), lineWidth: 0.8))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// ===============================
// ===== Popular pieces =====
// ===============================
struct PopularItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let imageName: String
}

extension PopularItem {
    // Cheese → Cake label (asset stays "cheese")
    static let demo: [PopularItem] = [
        .init(title: "Drink",       imageName: "drink"),
        .init(title: "Juice",       imageName: "juice"),
        .init(title: "Pizza",       imageName: "pizza"),
        .init(title: "Croissants",  imageName: "crosissant"),
        .init(title: "Chips",       imageName: "chips"),
        .init(title: "Cake",        imageName: "cheese"),
        .init(title: "Cookies",     imageName: "cookies")
    ]
}

// Measure width of one sequence (for seamless loop)
private struct WidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 1
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}
private struct WidthReader: View {
    var body: some View {
        GeometryReader { geo in
            Color.clear.preference(key: WidthKey.self, value: geo.size.width)
        }
    }
}

// ===== Timer-driven, tappable infinite marquee =====
private struct PopularTickerLoop: View {
    let items: [PopularItem]
    var speed: CGFloat = 24     // points per second
    var spacing: CGFloat = 10
    var onTap: (PopularItem) -> Void

    @State private var contentWidth: CGFloat = 1
    @State private var offsetX: CGFloat = 0

    // 60 FPS ticker
    private let ticker = Timer.publish(every: 1.0/60.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title with green bar
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Brand.green)
                    .frame(width: 4, height: 18)
                Text("Popular Categories")
                    .font(.title3.weight(.semibold))
                Spacer()
            }
            .padding(.horizontal, 16)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // copy A
                    HStack(spacing: spacing) {
                        ForEach(items) { it in
                            Button { onTap(it) } label: {
                                PopularChip(item: it)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .offset(x: offsetX)

                    // copy B (placed right after A)
                    HStack(spacing: spacing) {
                        ForEach(items) { it in
                            Button { onTap(it) } label: {
                                PopularChip(item: it)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .offset(x: offsetX + max(contentWidth + spacing, 1))
                }
                .frame(width: geo.size.width, alignment: .leading)
                .clipped()
                // Measure one sequence width (behind, non-interactive)
                .background(
                    HStack(spacing: spacing) {
                        ForEach(items) { PopularChip(item: $0) }
                    }
                    .background(WidthReader())
                    .opacity(0.001)
                    .allowsHitTesting(false)
                )
                .onPreferenceChange(WidthKey.self) { w in
                    if w > 0 { contentWidth = w }
                }
                .onReceive(ticker) { _ in
                    let loop = max(contentWidth + spacing, 1)
                    // move left; if fully off-screen, wrap
                    offsetX -= speed / 60.0
                    if offsetX <= -loop { offsetX += loop }
                }
            }
            .frame(height: 118)
            .padding(.horizontal, 16)
        }
    }
}

// ====== CHIP: image + label (Button-friendly) ======
private struct PopularChip: View {
    let item: PopularItem
    private let chipWidth: CGFloat = 80

    var body: some View {
        VStack(spacing: 4) {
            if let ui = UIImage(named: item.imageName) {
                Image(uiImage: ui)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
                    .frame(height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 3)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Brand.green.opacity(0.12))
                    .overlay(Image(systemName: "photo").font(.title3).foregroundStyle(Brand.green))
                    .frame(height: 70)
            }

            Text(item.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(width: chipWidth)
        }
        .frame(width: chipWidth)
        .contentShape(Rectangle())
    }
}

// ===============================
// UIImage helper — trims transparent edges
// ===============================
extension UIImage {
    func trimmedTransparentPixels(padding: CGFloat = 6) -> UIImage {
        guard let cgImage = self.cgImage,
              let dataProvider = cgImage.dataProvider,
              let dataCopy = dataProvider.data,
              let bytes = CFDataGetBytePtr(dataCopy) else { return self }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = cgImage.bytesPerRow
        let bitsPerPixel = cgImage.bitsPerPixel
        let bytesPerPixel = bitsPerPixel / 8
        guard bytesPerPixel >= 4 else { return self } // need alpha

        var minX = width, minY = height, maxX = 0, maxY = 0
        for y in 0..<height {
            let row = bytes + y * bytesPerRow
            for x in 0..<width {
                let pixel = row + x * bytesPerPixel
                let a = pixel[3] // BGRA
                if a != 0 {
                    if x < minX { minX = x }
                    if x > maxX { maxX = x }
                    if y < minY { minY = y }
                    if y > maxY { maxY = y }
                }
            }
        }
        if maxX < minX || maxY < minY { return self }

        let pad = Int(padding * self.scale)
        let cropX = max(minX - pad, 0)
        let cropY = max(minY - pad, 0)
        let cropW = min(maxX - minX + 1 + pad * 2, width - cropX)
        let cropH = min(maxY - minY + 1 + pad * 2, height - cropY)

        guard let cropped = cgImage.cropping(to: CGRect(x: cropX, y: cropY, width: cropW, height: cropH)) else {
            return self
        }
        return UIImage(cgImage: cropped, scale: self.scale, orientation: self.imageOrientation)
    }
}
