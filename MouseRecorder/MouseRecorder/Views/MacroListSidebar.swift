import SwiftUI

/// Sidebar showing the list of macros with hotkey badges.
struct MacroListSidebar: View {
    @EnvironmentObject var viewModel: MacroListViewModel

    var body: some View {
        List(selection: $viewModel.selectedMacroId) {
            ForEach(viewModel.macros) { macro in
                MacroRow(macro: macro)
                    .tag(macro.id)
                    .contextMenu {
                        Button("Play") { viewModel.playMacro(id: macro.id) }
                            .disabled(viewModel.isPlaying)
                        Button("Export") {
                            _ = viewModel.macroStore.showExportPanel(macros: [macro])
                        }
                        Divider()
                        Button("Delete", role: .destructive) {
                            viewModel.deleteMacro(id: macro.id)
                        }
                    }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200)
    }
}

struct MacroRow: View {
    let macro: Macro

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(macro.name)
                    .font(.body)
                    .lineLimit(1)

                Text("\(macro.steps.count) step\(macro.steps.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !macro.hotkey.isEmpty {
                Text(macro.hotkey)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.15))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 2)
    }
}
