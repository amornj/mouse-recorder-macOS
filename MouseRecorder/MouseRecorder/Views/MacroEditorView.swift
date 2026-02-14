import SwiftUI

/// Detail view for editing a single macro's properties and steps.
struct MacroEditorView: View {
    @EnvironmentObject var viewModel: MacroListViewModel
    let macroId: String

    private var macroBinding: Binding<Macro> {
        Binding(
            get: { viewModel.macros.first { $0.id == macroId } ?? Macro() },
            set: { newValue in
                if let index = viewModel.macros.firstIndex(where: { $0.id == macroId }) {
                    viewModel.macros[index] = newValue
                    viewModel.autoSave()
                }
            }
        )
    }

    private var macro: Macro {
        viewModel.macros.first { $0.id == macroId } ?? Macro()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Macro properties
            macroPropertiesSection

            Divider()

            // Steps list
            stepsSection
        }
    }

    // MARK: - Macro Properties

    private var macroPropertiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Macro Name", text: Binding(
                        get: { macro.name },
                        set: { viewModel.updateMacroName($0, macroId: macroId) }
                    ))
                    .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Hotkey")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("", selection: Binding(
                        get: { macro.hotkey },
                        set: { viewModel.updateMacroHotkey($0, macroId: macroId) }
                    )) {
                        Text("None").tag("")
                        ForEach(Constants.availableHotkeys, id: \.self) { key in
                            Text(key).tag(key)
                        }
                    }
                    .frame(width: 130)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Repeat (0 = ∞)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        TextField("", value: Binding(
                            get: { macro.repeatCount },
                            set: { viewModel.updateMacroRepeatCount($0, macroId: macroId) }
                        ), format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)

                        Stepper("", value: Binding(
                            get: { macro.repeatCount },
                            set: { viewModel.updateMacroRepeatCount($0, macroId: macroId) }
                        ), in: 0...10000)
                        .labelsHidden()
                    }
                }
            }
        }
        .padding()
    }

    // MARK: - Steps Section

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Steps")
                    .font(.headline)

                Spacer()

                addStepMenu
            }
            .padding(.horizontal)
            .padding(.top, 8)

            if macro.steps.isEmpty {
                VStack {
                    Spacer()
                    Text("No steps added yet")
                        .foregroundColor(.secondary)
                    Text("Use the + button to add steps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach(Array(macro.steps.enumerated()), id: \.element.id) { index, step in
                        StepRowView(
                            step: step,
                            index: index,
                            macroId: macroId
                        )
                    }
                }
                .listStyle(.inset)
            }
        }
    }

    private var addStepMenu: some View {
        Menu {
            Button("Left Click") {
                viewModel.addStep(type: .leftClick, toMacroId: macroId)
            }
            Button("Keyboard Shortcut") {
                viewModel.addStep(type: .keyboardShortcut, toMacroId: macroId)
            }
            Button("Wait") {
                viewModel.addStep(type: .wait, toMacroId: macroId)
            }
        } label: {
            Label("Add Step", systemImage: "plus")
        }
    }
}
