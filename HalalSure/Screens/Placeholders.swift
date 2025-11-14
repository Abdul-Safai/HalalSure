import SwiftUI

struct ScannerPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "barcode.viewfinder").font(.system(size: 48))
            Text("Scanner Coming Soon").font(.title3).bold()
            Text("We’ll use VisionKit/DataScanner for instant barcode capture.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct ProductDetailPlaceholder: View {
    let item: VerifiedItem
    var body: some View {
        List {
            Section("Product") {
                LabeledContent("Name", value: item.name)
                LabeledContent("Brand", value: item.brand)
                LabeledContent("UPC", value: item.upc)
            }
            Section("Verification") {
                LabeledContent("Status", value: item.status.rawValue)
                LabeledContent("Last Checked", value: item.lastChecked.formatted())
            }
            Section("Notes") {
                Text("Authority details and certificate will appear here.")
            }
        }
        .navigationTitle("Verification")
    }
}

struct LearnPlaceholderView: View {
    let title: String
    var body: some View {
        ScrollView {
            Text("""
            \(title)

            • Ingredients and sources
            • Cross-contamination risk
            • Certification bodies and validity
            """)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Learn")
    }
}

struct ReportPlaceholderView: View {
    @State private var text = ""
    var body: some View {
        Form {
            Section("Describe the issue") {
                TextField("Tell us what’s wrong…", text: $text, axis: .vertical)
                    .lineLimit(4...8)
            }
            Section {
                Button("Submit") { /* TODO: send to backend */ }
            }
        }
        .navigationTitle("Report an issue")
    }
}
