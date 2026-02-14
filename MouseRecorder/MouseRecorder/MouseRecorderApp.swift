import SwiftUI

@main
struct MouseRecorderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 0) {
                if !appDelegate.viewModel.isAccessibilityGranted {
                    AccessibilityBannerView()
                }
                MainView()
            }
            .environmentObject(appDelegate.viewModel)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 800, height: 500)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Macro") {
                    appDelegate.viewModel.addMacro()
                }
                .keyboardShortcut("n")
            }

            CommandGroup(after: .newItem) {
                Button("Import Macros...") {
                    appDelegate.viewModel.importMacros()
                }
                .keyboardShortcut("i")

                Button("Export All Macros...") {
                    appDelegate.viewModel.exportMacros()
                }
                .keyboardShortcut("e")
            }

            CommandGroup(replacing: .pasteboard) {
                Button("Delete Macro") {
                    appDelegate.viewModel.deleteSelectedMacro()
                }
                .keyboardShortcut(.delete)
                .disabled(appDelegate.viewModel.selectedMacroId == nil)
            }
        }
    }
}
