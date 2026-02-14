import SwiftUI
import AppKit

/// SwiftUI view for the fullscreen position-picker overlay with crosshair.
struct OverlayView: NSViewRepresentable {
    let onPositionSelected: (CGPoint) -> Void
    let onCancelled: () -> Void

    func makeNSView(context: Context) -> OverlayNSView {
        let view = OverlayNSView()
        view.onPositionSelected = onPositionSelected
        view.onCancelled = onCancelled
        return view
    }

    func updateNSView(_ nsView: OverlayNSView, context: Context) {}
}

/// AppKit view that handles mouse tracking and drawing crosshair.
final class OverlayNSView: NSView {
    var onPositionSelected: ((CGPoint) -> Void)?
    var onCancelled: (() -> Void)?

    private var mouseLocation: CGPoint = .zero
    private var trackingArea: NSTrackingArea?

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
        updateTrackingArea()
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        updateTrackingArea()
    }

    private func updateTrackingArea() {
        if let existing = trackingArea {
            removeTrackingArea(existing)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseMoved, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseMoved(with event: NSEvent) {
        mouseLocation = event.locationInWindow
        needsDisplay = true
    }

    override func mouseDown(with event: NSEvent) {
        // Convert from NSView coordinates (bottom-left origin) to screen coordinates (top-left origin for CGEvent)
        let windowPoint = event.locationInWindow
        guard let screen = window?.screen ?? NSScreen.main else { return }
        let screenFrame = screen.frame
        let screenPoint = CGPoint(
            x: windowPoint.x + (window?.frame.origin.x ?? 0),
            y: screenFrame.height - (windowPoint.y + (window?.frame.origin.y ?? 0))
        )
        onPositionSelected?(screenPoint)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape
            onCancelled?()
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else { return }

        let lineWidth: CGFloat = 1.0
        let crosshairColor = NSColor.red

        // Draw crosshair lines
        context.setStrokeColor(crosshairColor.cgColor)
        context.setLineWidth(lineWidth)

        // Vertical line
        context.move(to: CGPoint(x: mouseLocation.x, y: 0))
        context.addLine(to: CGPoint(x: mouseLocation.x, y: bounds.height))
        context.strokePath()

        // Horizontal line
        context.move(to: CGPoint(x: 0, y: mouseLocation.y))
        context.addLine(to: CGPoint(x: bounds.width, y: mouseLocation.y))
        context.strokePath()

        // Convert to screen coordinates for display
        let screenX = mouseLocation.x + (window?.frame.origin.x ?? 0)
        let screenY: CGFloat
        if let screen = window?.screen ?? NSScreen.main {
            screenY = screen.frame.height - (mouseLocation.y + (window?.frame.origin.y ?? 0))
        } else {
            screenY = mouseLocation.y
        }

        // Draw coordinate label
        let coordText = "(\(Int(screenX)), \(Int(screenY)))"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .medium),
            .foregroundColor: NSColor.white,
            .backgroundColor: NSColor.black.withAlphaComponent(0.7),
        ]
        let string = NSAttributedString(string: coordText, attributes: attributes)
        let textSize = string.size()

        // Position label offset from cursor, keeping on screen
        var labelX = mouseLocation.x + 15
        var labelY = mouseLocation.y + 15
        if labelX + textSize.width > bounds.width {
            labelX = mouseLocation.x - textSize.width - 15
        }
        if labelY + textSize.height > bounds.height {
            labelY = mouseLocation.y - textSize.height - 15
        }

        string.draw(at: CGPoint(x: labelX, y: labelY))
    }
}
