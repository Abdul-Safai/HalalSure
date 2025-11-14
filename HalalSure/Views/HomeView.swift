import SwiftUI

struct HomeView: View {
    @State private var query: String = ""
    @State private var showingScanner = false
    @State private var recent: [VerifiedItem] = SampleData.recent
    @State private var selectedCategory: ProductCategory? = nil
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // HERO TITLE
                    HeroTitle(
                        title: "HalalSure",
                        subtitle: "Verify with confidence",
                        icon: "checkmark.shield.fill"
                    )
                    .padding(.top, 4)

                    // SEARCH (modern pill)
                    SearchBar(query: $query)
                        .onSubmit {
                            // TODO: navigate to SearchResultsView(query, selectedCategory)
                        }

                    // SCAN CTA
                    Button { showingScanner = true } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Brand.green.opacity(scheme == .dark ? 0.28 : 0.18))
                                    .frame(width: 56, height: 56)
                                Image(systemName: "barcode.viewfinder")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(Brand.green)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Scan a barcode").font(.headline)
                                Text("Instantly verify halal status")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Brand.bgSoft)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Brand.green.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: Brand.green.opacity(0.12), radius: 20, x: 0, y: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(.white.opacity(0.3), lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showingScanner) {
                        ScannerPlaceholderView()
                            .presentationDetents([.medium, .large])
                    }

                    // CATEGORIES
                    Text("Quick categories")
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(ProductCategory.allCases) { cat in
                                SelectableChip(
                                    title: cat.rawValue,
                                    systemImage: cat.icon,
                                    isSelected: selectedCategory == cat
                                ) {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                        selectedCategory = (selectedCategory == cat ? nil : cat)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 2)
                    }

                    // RECENTS
                    if !recent.isEmpty {
                        HStack {
                            Text("Recent verifications")
                                .font(.system(.title3, design: .rounded).weight(.semibold))
                            Spacer()
                            Button {
                                withAnimation(.easeInOut) { recent.removeAll() }
                            } label: {
                                Label("Clear", systemImage: "trash")
                                    .labelStyle(.titleAndIcon)
                            }
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        }

                        VStack(spacing: 12) {
                            ForEach(recent) { item in
                                NavigationLink {
                                    ProductDetailPlaceholder(item: item)
                                } label: {
                                    RecentCard(item: item)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button("Remove from recents") {
                                        withAnimation(.easeInOut) {
                                            recent.removeAll { $0.id == item.id }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // TRUST & EDUCATION
                    SoftCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Data aligned with recognized halal authorities", systemImage: "checkmark.shield")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 14) {
                                NavigationLink {
                                    LearnPlaceholderView(title: "What makes a product halal?")
                                } label: {
                                    Label("Learn", systemImage: "book.closed")
                                }

                                NavigationLink {
                                    ReportPlaceholderView()
                                } label: {
                                    Label("Report an issue", systemImage: "exclamationmark.bubble")
                                }
                            }
                            .font(.subheadline)
                        }
                    }

                }
                .padding(16)
            }
            .background(
                LinearGradient(colors: [Brand.green.opacity(0.06), Color.clear],
                               startPoint: .top, endPoint: .center)
                    .ignoresSafeArea()
            )
            .navigationTitle("") // hide default nav title (Hero shows it)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
        }
    }
}

// MARK: - Subviews

private struct SearchBar: View {
    @Binding var query: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Search products or UPC…", text: $query)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            if !query.isEmpty {
                Button {
                    withAnimation { query = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Brand.stroke, lineWidth: 1)
        )
        .shadow(color: Brand.shadow, radius: 12, x: 0, y: 6)
    }
}

private struct HeroTitle: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Brand.green, Brand.green.opacity(0.75)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Brand.green.opacity(0.18), radius: 20, x: 0, y: 10)

            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(.white.opacity(0.22))
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(subtitle.uppercased())
                        .font(.caption2).bold()
                        .foregroundStyle(.white.opacity(0.85))
                        .tracking(0.5)

                    Text(title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
}
