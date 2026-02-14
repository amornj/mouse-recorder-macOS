import SwiftUI

/// View shown when Accessibility permission has not been granted.
struct AccessibilityPromptView: View {
    @EnvironmentObject var viewModel: MacroListViewModel

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hand.raised.circle")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Accessibility Permission Required")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Mouse Recorder needs Accessibility permission to simulate mouse clicks and keyboard input for macro playback.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .frame(maxWidth: 400)

            VStack(alignment: .leading, spacing: 8) {
                Text("To grant permission:")
                    .font(.headline)

                HStack(alignment: .top) {
                    Text("1.")
                    Text("Click the button below to open System Settings")
                }
                HStack(alignment: .top) {
                    Text("2.")
                    Text("Find \"Mouse Recorder\" in the list")
                }
                HStack(alignment: .top) {
                    Text("3.")
                    Text("Toggle the switch to enable access")
                }
            }
            .font(.body)
            .frame(maxWidth: 400, alignment: .leading)

            Button("Open Accessibility Settings") {
                viewModel.accessibilityService.requestPermission()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            if viewModel.accessibilityService.isGranted {
                Label("Permission Granted!", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                HStack(spacing: 6) {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Waiting for permission...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
