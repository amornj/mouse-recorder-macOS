import CoreGraphics
import Foundation

/// Simulates mouse clicks using CGEvent API.
enum MouseSimulator {
    /// Move the mouse to the given coordinates and perform a left click.
    /// Coordinates use top-left origin (matching Windows behavior).
    static func leftClick(at point: CGPoint) async {
        let source = CGEventSource(stateID: .hidSystemState)

        // Move mouse to position
        if let moveEvent = CGEvent(mouseEventSource: source, mouseType: .mouseMoved,
                                   mouseCursorPosition: point, mouseButton: .left) {
            moveEvent.post(tap: .cghidEventTap)
        }

        // Brief delay after move (30ms, matching Windows)
        try? await Task.sleep(nanoseconds: Constants.clickMoveDelay)

        // Mouse down
        if let downEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown,
                                   mouseCursorPosition: point, mouseButton: .left) {
            downEvent.post(tap: .cghidEventTap)
        }

        // Brief delay between down and up (20ms, matching Windows)
        try? await Task.sleep(nanoseconds: Constants.clickDownDelay)

        // Mouse up
        if let upEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp,
                                 mouseCursorPosition: point, mouseButton: .left) {
            upEvent.post(tap: .cghidEventTap)
        }
    }
}
