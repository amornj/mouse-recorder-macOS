import AppKit
import HotKey
import Carbon

struct HotkeyBinding {
    let key: Key
    let modifiers: NSEvent.ModifierFlags

    /// Parse a hotkey string like "F6", "Ctrl+F1", "Ctrl+1" into Key + modifiers.
    static func parse(_ hotkeyString: String) -> HotkeyBinding? {
        guard !hotkeyString.isEmpty else { return nil }

        let parts = hotkeyString.split(separator: "+").map { String($0).trimmingCharacters(in: .whitespaces) }
        guard !parts.isEmpty else { return nil }

        var modifiers: NSEvent.ModifierFlags = []
        var keyName: String?

        for part in parts {
            switch part.lowercased() {
            case "ctrl", "control":
                modifiers.insert(.control)
            case "alt", "option":
                modifiers.insert(.option)
            case "shift":
                modifiers.insert(.shift)
            case "win", "cmd", "command":
                modifiers.insert(.command)
            default:
                keyName = part
            }
        }

        guard let name = keyName, let key = keyFromName(name) else { return nil }
        return HotkeyBinding(key: key, modifiers: modifiers)
    }

    private static func keyFromName(_ name: String) -> Key? {
        switch name.lowercased() {
        // Function keys
        case "f1": return .f1
        case "f2": return .f2
        case "f3": return .f3
        case "f4": return .f4
        case "f5": return .f5
        case "f6": return .f6
        case "f7": return .f7
        case "f8": return .f8
        case "f9": return .f9
        case "f10": return .f10
        case "f11": return .f11
        case "f12": return .f12
        case "f13": return .f13
        case "f14": return .f14
        case "f15": return .f15
        case "f16": return .f16
        case "f17": return .f17
        case "f18": return .f18
        case "f19": return .f19
        case "f20": return .f20

        // Numbers
        case "0": return .zero
        case "1": return .one
        case "2": return .two
        case "3": return .three
        case "4": return .four
        case "5": return .five
        case "6": return .six
        case "7": return .seven
        case "8": return .eight
        case "9": return .nine

        // Letters
        case "a": return .a
        case "b": return .b
        case "c": return .c
        case "d": return .d
        case "e": return .e
        case "f": return .f
        case "g": return .g
        case "h": return .h
        case "i": return .i
        case "j": return .j
        case "k": return .k
        case "l": return .l
        case "m": return .m
        case "n": return .n
        case "o": return .o
        case "p": return .p
        case "q": return .q
        case "r": return .r
        case "s": return .s
        case "t": return .t
        case "u": return .u
        case "v": return .v
        case "w": return .w
        case "x": return .x
        case "y": return .y
        case "z": return .z

        // Special keys
        case "space": return .space
        case "tab": return .tab
        case "return", "enter": return .return
        case "escape", "esc": return .escape
        case "delete", "backspace": return .delete
        case "forwarddelete": return .forwardDelete
        case "home": return .home
        case "end": return .end
        case "pageup": return .pageUp
        case "pagedown": return .pageDown
        case "up": return .upArrow
        case "down": return .downArrow
        case "left": return .leftArrow
        case "right": return .rightArrow

        default: return nil
        }
    }
}
