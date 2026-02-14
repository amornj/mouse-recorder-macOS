import AppKit
import SwiftUI

/// Manages the fullscreen overlay window for position picking.
@MainActor
final class OverlayWindowController: ObservableObject {
    @Published var isShowing = false

    private var overlayWindow: NSWindow?
    private var continuation: CheckedContinuation<CGPoint?, Never>?

    /// Show the overlay and wait for user to click a position or press Escape.
    func pickPosition() async -> CGPoint? {
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            showOverlay()
        }
    }

    private func showOverlay() {
        // Get the combined frame of all screens
        let screens = NSScreen.screens
        guard !screens.isEmpty else {
            continuation?.resume(returning: nil)
            continuation = nil
            return
        }

        var unionFrame = screens[0].frame
        for screen in screens.dropFirst() {
            unionFrame = unionFrame.union(screen.frame)
        }

        let overlayView = OverlayView(
            onPositionSelected: { [weak self] point in
                self?.dismiss(with: point)
            },
            onCancelled: { [weak self] in
                self?.dismiss(with: nil)
            }
        )

        let window = NSWindow(
            contentRect: unionFrame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.level = .screenSaver
        window.isOpaque = false
        window.backgroundColor = NSColor.black.withAlphaComponent(0.3)
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.acceptsMouseMovedEvents = true
        window.contentView = NSHostingView(rootView: overlayView)
        window.setFrame(unionFrame, display: true)
        window.makeKeyAndOrderFront(nil)

        // Set crosshair cursor
        NSCursor.crosshair.push()

        overlayWindow = window
        isShowing = true
    }

    private func dismiss(with point: CGPoint?) {
        NSCursor.pop()
        overlayWindow?.orderOut(nil)
        overlayWindow = nil
        isShowing = false
        continuation?.resume(returning: point)
        continuation = nil
    }
}
