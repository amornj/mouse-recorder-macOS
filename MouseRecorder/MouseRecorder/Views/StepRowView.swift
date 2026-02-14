import SwiftUI

/// Row view for displaying and editing a single macro step.
struct StepRowView: View {
    @EnvironmentObject var viewModel: MacroListViewModel
    let step: MacroStep
    let index: Int
    let macroId: String

    @State private var showingKeyCaptureSheet = false

    private var isActiveStep: Bool {
        viewModel.playingMacroId == macroId && viewModel.currentStepIndex == index
    }

    var body: some View {
        HStack(spacing: 12) {
            // Step number
            Text("\(index + 1)")
                .font(.caption)
                .fontWeight(isActiveStep ? .bold : .regular)
                .foregroundColor(isActiveStep ? .accentColor : .secondary)
                .frame(width: 20)

            // Active indicator
            if isActiveStep {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
            }

            // Step type icon
            stepIcon

            // Step content (fixed width for column alignment)
            stepContent
                .frame(width: 320, alignment: .leading)

            // Note
            TextField("Note", text: Binding(
                get: { step.note },
                set: { newNote in
                    viewModel.updateStep(stepId: step.id, inMacroId: macroId) { s in
                        s.note = newNote
                    }
                }
            ))
            .textFieldStyle(.plain)
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(minWidth: 80, idealWidth: 150)

            // Step actions
            stepActions
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isActiveStep ? Color.accentColor.opacity(0.12) : Color.clear)
                .shadow(color: isActiveStep ? Color.accentColor.opacity(0.3) : .clear, radius: 4, x: 0, y: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isActiveStep)
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
        case .doubleClick:
            Image(systemName: "cursorarrow.click.2")
                .foregroundColor(.blue)
        case .rightClick:
            Image(systemName: "cursorarrow.click")
                .foregroundColor(.purple)
        case .keyboardShortcut:
            Image(systemName: "keyboard")
                .foregroundColor(.green)
        case .keystroke:
            Image(systemName: "character.cursor.ibeam")
                .foregroundColor(.teal)
        case .typeText:
            Image(systemName: "text.cursor")
                .foregroundColor(.indigo)
        case .wait:
            Image(systemName: "clock")
                .foregroundColor(.orange)
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step.type {
        case .leftClick:
            coordinateEditor(label: "Click at")
        case .doubleClick:
            coordinateEditor(label: "Double click at")
        case .rightClick:
            coordinateEditor(label: "Right click at")

        case .keyboardShortcut:
            HStack(spacing: 8) {
                Text(step.keys.isEmpty ? "No keys set" : step.keys.joined(separator: " + "))
                    .foregroundColor(step.keys.isEmpty ? .secondary : .primary)

                Button("Capture") {
                    showingKeyCaptureSheet = true
                }
                .buttonStyle(.bordered)
            }

        case .keystroke:
            HStack(spacing: 8) {
                Text("Key:")
                    .foregroundColor(.secondary)
                Picker("", selection: Binding(
                    get: { step.keys.first ?? "" },
                    set: { newKey in
                        viewModel.updateStep(stepId: step.id, inMacroId: macroId) { s in
                            s.keys = newKey.isEmpty ? [] : [newKey]
                        }
                    }
                )) {
                    Text("Select...").tag("")
                    Section("Letters") {
                        ForEach(Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map(String.init), id: \.self) { k in
                            Text(k).tag(k)
                        }
                    }
                    Section("Numbers") {
                        ForEach(Array("0123456789").map(String.init), id: \.self) { k in
                            Text(k).tag(k)
                        }
                    }
                    Section("Special") {
                        ForEach(["Space", "Tab", "Enter", "Escape", "Delete", "Up", "Down", "Left", "Right", "PageUp", "PageDown", "Home", "End"], id: \.self) { k in
                            Text(k).tag(k)
                        }
                    }
                    Section("Function") {
                        ForEach((1...12).map { "F\($0)" }, id: \.self) { k in
                            Text(k).tag(k)
                        }
                    }
                }
                .frame(width: 130)
            }

        case .typeText:
            HStack(spacing: 8) {
                Text("Text:")
                    .foregroundColor(.secondary)
                TextField("Enter text to type", text: Binding(
                    get: { step.text },
                    set: { newText in
                        viewModel.updateStep(stepId: step.id, inMacroId: macroId) { s in
                            s.text = newText
                        }
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(minWidth: 200)
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

    private func coordinateEditor(label: String) -> some View {
        HStack(spacing: 8) {
            Text(label)
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
