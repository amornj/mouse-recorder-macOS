import CoreGraphics
import Foundation

/// Simulates keyboard input using CGEvent API.
enum KeyboardSimulator {
    /// Simulate a keyboard shortcut from a list of key names (e.g., ["Ctrl", "C"]).
    /// Modifier keys are held down, non-modifier keys are pressed, then all released in reverse order.
    static func simulateShortcut(keys: [String]) {
        let source = CGEventSource(stateID: .hidSystemState)

        // Separate modifiers and regular keys
        var modifierFlags = CGEventFlags()
        var pressOrder: [(keyCode: CGKeyCode, isModifier: Bool)] = []

        for keyName in keys {
            guard let keyCode = CGKeyCodeMap.keyCode(for: keyName) else { continue }

            if ModifierFlagMapping.isModifier(keyName) {
                if let flag = ModifierFlagMapping.flags(for: keyName) {
                    modifierFlags.insert(flag)
                }
                pressOrder.append((keyCode, true))
            } else {
                pressOrder.append((keyCode, false))
            }
        }

        // Press all keys down in order
        for (keyCode, isModifier) in pressOrder {
            if let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true) {
                if !isModifier {
                    event.flags = modifierFlags
                }
                event.post(tap: .cghidEventTap)
            }
        }

        // Release all keys in reverse order
        for (keyCode, isModifier) in pressOrder.reversed() {
            if let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) {
                if !isModifier {
                    event.flags = modifierFlags
                }
                event.post(tap: .cghidEventTap)
            }
        }
    }
}
