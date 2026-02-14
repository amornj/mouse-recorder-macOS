import SwiftUI

/// Row view for displaying and editing a single macro step.
struct StepRowView: View {
    @EnvironmentObject var viewModel: MacroListViewModel
    let step: MacroStep
    let index: Int
    let macroId: String

    @State private var showingKeyCaptureSheet = false

    var body: some View {
        HStack(spacing: 12) {
            // Step number
            Text("\(index + 1)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 20)

            // Step type icon
            stepIcon

            // Step content
            stepContent

            Spacer()

            // Step actions
            stepActions
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingKeyCaptureSheet) {
            KeyCaptureView { keys in
                if let keys {
                    viewModel.updateStep(stepId: step.id, inMacroId: macroId) { s in
                        s.keys = keys
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var stepIcon: some View {
        switch step.type {
        case .leftClick:
            Image(systemName: "cursorarrow.click")
                .foregroundColor(.blue)
        case .keyboardShortcut:
            Image(systemName: "keyboard")
                .foregroundColor(.green)
        case .wait:
            Image(systemName: "clock")
                .foregroundColor(.orange)
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step.type {
        case .leftClick:
            HStack(spacing: 8) {
                Text("Click at")
                    .foregroundColor(.secondary)

                HStack(spacing: 4) {
                    Text("X:")
                        .foregroundColor(.secondary)
                    TextField("X", value: Binding(
                        get: { step.x },
                        set: { newX in
                            viewModel.updateStep(stepId: step.id, inMacroId: macroId) { s in
                                s.x = newX
                            }
                        }
                    ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 70)
                }

                HStack(spacing: 4) {
                    Text("Y:")
                        .foregroundColor(.secondary)
                    TextField("Y", value: Binding(
                        get: { step.y },
                        set: { newY in
                            viewModel.updateStep(stepId: step.id, inMacroId: macroId) { s in
                                s.y = newY
                            }
                        }
                    ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 70)
                }

                Button("Pick") {
                    viewModel.pickPosition(for: step.id, inMacroId: macroId)
                }
                .buttonStyle(.bordered)
            }

        case .keyboardShortcut:
            HStack(spacing: 8) {
                Text(step.keys.isEmpty ? "No keys set" : step.keys.joined(separator: " + "))
                    .foregroundColor(step.keys.isEmpty ? .secondary : .primary)

                Button("Capture") {
                    showingKeyCaptureSheet = true
                }
                .buttonStyle(.bordered)
            }

        case .wait:
            HStack(spacing: 8) {
                Text("Wait")
                    .foregroundColor(.secondary)
                TextField("ms", value: Binding(
                    get: { step.delayMs },
                    set: { newDelay in
                        viewModel.updateStep(stepId: step.id, inMacroId: macroId) { s in
                            s.delayMs = max(0, newDelay)
                        }
                    }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 80)
                Text("ms")
                    .foregroundColor(.secondary)
            }
        }
    }

    private var stepActions: some View {
        HStack(spacing: 4) {
            Button(action: {
                viewModel.moveStepUp(stepId: step.id, inMacroId: macroId)
            }) {
                Image(systemName: "chevron.up")
            }
            .buttonStyle(.borderless)
            .disabled(index == 0)

            Button(action: {
                viewModel.moveStepDown(stepId: step.id, inMacroId: macroId)
            }) {
                Image(systemName: "chevron.down")
            }
            .buttonStyle(.borderless)

            Button(action: {
                viewModel.deleteStep(stepId: step.id, fromMacroId: macroId)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.borderless)
        }
    }
}
