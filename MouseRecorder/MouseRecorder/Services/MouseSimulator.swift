import CoreGraphics
import Foundation

/// Simulates mouse clicks using CGEvent API.
enum MouseSimulator {
    /// Move the mouse to the given coordinates and perform a left click.
    static func leftClick(at point: CGPoint) async {
        await moveMouse(to: point)
        try? await Task.sleep(nanoseconds: Constants.clickMoveDelay)
        await click(at: point, downType: .leftMouseDown, upType: .leftMouseUp, button: .left, clickCount: 1)
    }

    /// Move the mouse to the given coordinates and perform a double left click.
    static func doubleClick(at point: CGPoint) async {
        await moveMouse(to: point)
        try? await Task.sleep(nanoseconds: Constants.clickMoveDelay)
        // First click
        await click(at: point, downType: .leftMouseDown, upType: .leftMouseUp, button: .left, clickCount: 1)
        try? await Task.sleep(nanoseconds: Constants.clickDownDelay)
        // Second click with clickCount=2
        await click(at: point, downType: .leftMouseDown, upType: .leftMouseUp, button: .left, clickCount: 2)
    }

    /// Move the mouse to the given coordinates and perform a right click.
    static func rightClick(at point: CGPoint) async {
        await moveMouse(to: point)
        try? await Task.sleep(nanoseconds: Constants.clickMoveDelay)
        await click(at: point, downType: .rightMouseDown, upType: .rightMouseUp, button: .right, clickCount: 1)
    }

    // MARK: - Private

    private static func moveMouse(to point: CGPoint) async {
        let source = CGEventSource(stateID: .hidSystemState)
        if let moveEvent = CGEvent(mouseEventSource: source, mouseType: .mouseMoved,
                                   mouseCursorPosition: point, mouseButton: .left) {
            moveEvent.post(tap: .cghidEventTap)
        }
    }

    private static func click(at point: CGPoint, downType: CGEventType, upType: CGEventType,
                              button: CGMouseButton, clickCount: Int64) async {
        let source = CGEventSource(stateID: .hidSystemState)

        if let downEvent = CGEvent(mouseEventSource: source, mouseType: downType,
                                   mouseCursorPosition: point, mouseButton: button) {
            downEvent.setIntegerValueField(.mouseEventClickState, value: clickCount)
            downEvent.post(tap: .cghidEventTap)
        }

        try? await Task.sleep(nanoseconds: Constants.clickDownDelay)

        if let upEvent = CGEvent(mouseEventSource: source, mouseType: upType,
                                 mouseCursorPosition: point, mouseButton: button) {
            upEvent.setIntegerValueField(.mouseEventClickState, value: clickCount)
            upEvent.post(tap: .cghidEventTap)
        }
    }
}
