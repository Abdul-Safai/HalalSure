import SwiftUI

struct ScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isTorchOn = false
    @State private var lastCode: String? = nil

    var body: some View {
        VStack(spacing: 16) {

            // Grab handle row
            Capsule()
                .fill(.secondary.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 6)
                .accessibilityHidden(true)

            // Title row
            HStack {
                Text("Scan barcode")
                    .font(.headline)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Close scanner")
            }
            .padding(.horizontal)

            // Camera preview placeholder (replace with AVCaptureVideoPreviewLayer)
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                    )

                // Scanning frame
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(.green, style: StrokeStyle(lineWidth: 3, dash: [10, 8]))
                    .frame(width: 240, height: 160)
                    .overlay(
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.green)
                    )
            }
            .frame(height: 260)
            .padding(.horizontal)

            // Controls + last result
            HStack(spacing: 14) {
                Button {
                    isTorchOn.toggle()
                    // TODO: hook to AVCaptureDevice torch
                } label: {
                    Label(isTorchOn ? "Torch on" : "Torch off",
                          systemImage: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                        .labelStyle(.titleAndIcon)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule().fill(Color(.secondarySystemBackground))
                        )
                }

                Spacer()

                if let code = lastCode {
                    Text("Last: \(code)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal)

            // Primary action (simulate scan result)
            Button {
                // Simulate a found code; replace with delegate/callback later
                lastCode = "012345678905"
                // Optionally dismiss after capture:
                // dismiss()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "viewfinder")
                    Text("Simulate Scan")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(Capsule().fill(.green))
                .foregroundStyle(.white)
            }

            Spacer(minLength: 8)
        }
        .padding(.bottom, 12)
        .background(.ultraThinMaterial) // sheet-friendly, not full opaque
    }
}
