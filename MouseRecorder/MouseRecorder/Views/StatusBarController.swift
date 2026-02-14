import AppKit
import SwiftUI

/// Manages the NSStatusItem (menu bar icon) and its menu.
@MainActor
final class StatusBarController {
    private var statusItem: NSStatusItem?
    private weak var viewModel: MacroListViewModel?

    func setup(viewModel: MacroListViewModel) {
        self.viewModel = viewModel

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "record.circle", accessibilityDescription: "Mouse Recorder")
        }

        updateMenu()
    }

    func updateMenu() {
        let menu = NSMenu()

        let showItem = NSMenuItem(title: "Show Window", action: #selector(showWindow), keyEquivalent: "")
        showItem.target = self
        menu.addItem(showItem)

        menu.addItem(NSMenuItem.separator())

        let stopItem = NSMenuItem(title: "Stop Macro", action: #selector(stopMacro), keyEquivalent: "")
        stopItem.target = self
        stopItem.isEnabled = viewModel?.isPlaying ?? false
        menu.addItem(stopItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit Mouse Recorder", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc private func showWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.isVisible || $0.canBecomeMain }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            // If no window is visible, the app delegate will handle it
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    @objc private func stopMacro() {
        viewModel?.stopPlayback()
    }

    @objc private func quitApp() {
        viewModel?.stopPlayback()
        NSApp.terminate(nil)
    }
}
