import SwiftUI

@main
struct MouseRecorderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = MacroListViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if viewModel.accessibilityService.isGranted {
                    MainView()
                } else {
                    AccessibilityPromptView()
                }
            }
            .environmentObject(viewModel)
            .onAppear {
                appDelegate.viewModel = viewModel
                appDelegate.statusBarController.setup(viewModel: viewModel)
            }
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 800, height: 500)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Macro") {
                    viewModel.addMacro()
                }
                .keyboardShortcut("n")
            }

            CommandGroup(after: .newItem) {
                Button("Import Macros...") {
                    viewModel.importMacros()
                }
                .keyboardShortcut("i")

                Button("Export All Macros...") {
                    viewModel.exportMacros()
                }
                .keyboardShortcut("e")
            }

            CommandGroup(replacing: .pasteboard) {
                Button("Delete Macro") {
                    viewModel.deleteSelectedMacro()
                }
                .keyboardShortcut(.delete)
                .disabled(viewModel.selectedMacroId == nil)
            }
        }
    }
}
