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

    /// Simulate a single keystroke (press and release one key, no modifiers).
    static func simulateKeystroke(keyName: String) {
        guard let keyCode = CGKeyCodeMap.keyCode(for: keyName) else { return }
        let source = CGEventSource(stateID: .hidSystemState)

        if let downEvent = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true) {
            downEvent.post(tap: .cghidEventTap)
        }
        if let upEvent = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) {
            upEvent.post(tap: .cghidEventTap)
        }
    }

    /// Type a string of text character by character using CGEvent Unicode input.
    static func typeText(_ text: String, delayPerChar: UInt64 = 10_000_000) async {
        let source = CGEventSource(stateID: .hidSystemState)

        for char in text {
            let utf16 = Array(String(char).utf16)
            if let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true) {
                event.keyboardSetUnicodeString(stringLength: utf16.count, unicodeString: utf16)
                event.post(tap: .cghidEventTap)
            }
            if let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false) {
                event.post(tap: .cghidEventTap)
            }
            // Small delay between characters for reliability
            try? await Task.sleep(nanoseconds: delayPerChar)
        }
    }
}
