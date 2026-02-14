import SwiftUI

/// Compact banner shown when Accessibility permission has not been granted.
struct AccessibilityBannerView: View {
    @EnvironmentObject var viewModel: MacroListViewModel
    @State private var dismissed = false

    var body: some View {
        if !dismissed {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)

                Text("Accessibility permission required for playback and position picking.")
                    .font(.callout)

                Spacer()

                Button("Open Settings") {
                    viewModel.accessibilityService.requestPermission()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)

                Button {
                    dismissed = true
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
            }
            .padding(10)
            .background(Color.orange.opacity(0.1))
        }
    }
}
