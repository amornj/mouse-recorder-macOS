import AppKit
import SwiftUI

/// NSApplicationDelegate handling app lifecycle, status bar, and window management.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let viewModel = MacroListViewModel()
    let statusBarController = StatusBarController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController.setup(viewModel: viewModel)

        // Check accessibility on launch
        if !viewModel.accessibilityService.checkPermission() {
            viewModel.accessibilityService.startPolling()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't quit when window is closed - stay in menu bar
        return false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Show window when dock icon is clicked
        if !flag {
            for window in NSApp.windows {
                if window.canBecomeMain {
                    window.makeKeyAndOrderFront(nil)
                    break
                }
            }
        }
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        viewModel.stopPlayback()
        viewModel.hotkeyService.unregisterAll()
    }
}
