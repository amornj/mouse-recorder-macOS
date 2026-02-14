import SwiftUI

/// Main application window with NavigationSplitView (sidebar + detail).
struct MainView: View {
    @EnvironmentObject var viewModel: MacroListViewModel

    var body: some View {
        NavigationSplitView {
            MacroListSidebar()
        } detail: {
            if let macroId = viewModel.selectedMacroId,
               viewModel.macros.contains(where: { $0.id == macroId }) {
                MacroEditorView(macroId: macroId)
            } else {
                Text("Select or create a macro")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: viewModel.addMacro) {
                    Label("New Macro", systemImage: "plus")
                }

                Button(action: viewModel.deleteSelectedMacro) {
                    Label("Delete", systemImage: "trash")
                }
                .disabled(viewModel.selectedMacroId == nil)

                Divider()

                Button(action: viewModel.playSelectedMacro) {
                    Label("Play", systemImage: "play.fill")
                }
                .disabled(viewModel.selectedMacroId == nil || viewModel.isPlaying)

                Button(action: viewModel.stopPlayback) {
                    Label("Stop", systemImage: "stop.fill")
                }
                .disabled(!viewModel.isPlaying)

                Divider()

                Button(action: viewModel.importMacros) {
                    Label("Import", systemImage: "square.and.arrow.down")
                }

                Button(action: viewModel.exportMacros) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .disabled(viewModel.macros.isEmpty)
            }
        }
        .frame(minWidth: 700, minHeight: 400)
        .overlay(alignment: .bottom) {
            StatusBarView()
        }
    }
}

/// Bottom status bar showing current status and F12 hint.
struct StatusBarView: View {
    @EnvironmentObject var viewModel: MacroListViewModel

    var body: some View {
        HStack {
            Text(viewModel.statusText)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Text("F12 = Emergency Stop")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(.bar)
    }
}
