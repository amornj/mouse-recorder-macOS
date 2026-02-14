import CoreGraphics

/// Maps key name strings to macOS CGKeyCode values for CGEvent keyboard simulation.
enum CGKeyCodeMap {
    private static let keyMap: [String: CGKeyCode] = [
        // Letters
        "A": 0x00, "S": 0x01, "D": 0x02, "F": 0x03, "H": 0x04,
        "G": 0x05, "Z": 0x06, "X": 0x07, "C": 0x08, "V": 0x09,
        "B": 0x0B, "Q": 0x0C, "W": 0x0D, "E": 0x0E, "R": 0x0F,
        "Y": 0x10, "T": 0x11, "U": 0x20, "I": 0x22, "O": 0x1F,
        "P": 0x23, "L": 0x25, "J": 0x26, "K": 0x28, "N": 0x2D,
        "M": 0x2E,

        // Numbers
        "0": 0x1D, "1": 0x12, "2": 0x13, "3": 0x14, "4": 0x15,
        "5": 0x17, "6": 0x16, "7": 0x1A, "8": 0x1C, "9": 0x19,

        // Function keys
        "F1": 0x7A, "F2": 0x78, "F3": 0x63, "F4": 0x76,
        "F5": 0x60, "F6": 0x61, "F7": 0x62, "F8": 0x64,
        "F9": 0x65, "F10": 0x6D, "F11": 0x67, "F12": 0x6F,
        "F13": 0x69, "F14": 0x6B, "F15": 0x71, "F16": 0x6A,
        "F17": 0x40, "F18": 0x4F, "F19": 0x50, "F20": 0x5A,

        // Modifiers
        "Ctrl": 0x3B, "Control": 0x3B,
        "Shift": 0x38,
        "Alt": 0x3A, "Option": 0x3A,
        "Win": 0x37, "Command": 0x37, "Cmd": 0x37,

        // Navigation
        "Return": 0x24, "Enter": 0x24,
        "Tab": 0x30,
        "Space": 0x31,
        "Delete": 0x33, "Backspace": 0x33,
        "ForwardDelete": 0x75,
        "Escape": 0x35, "Esc": 0x35,
        "Home": 0x73,
        "End": 0x77,
        "PageUp": 0x74,
        "PageDown": 0x79,

        // Arrow keys
        "Up": 0x7E, "Down": 0x7D, "Left": 0x7B, "Right": 0x7C,

        // Punctuation / symbols
        "-": 0x1B, "=": 0x18,
        "[": 0x21, "]": 0x1E,
        "\\": 0x2A,
        ";": 0x29, "'": 0x27,
        ",": 0x2B, ".": 0x2F,
        "/": 0x2C, "`": 0x32,
    ]

    static func keyCode(for name: String) -> CGKeyCode? {
        // Try exact match first, then case-insensitive
        if let code = keyMap[name] {
            return code
        }
        // Try uppercase single letter
        if name.count == 1, let code = keyMap[name.uppercased()] {
            return code
        }
        // Try case-insensitive lookup
        let lower = name.lowercased()
        for (key, value) in keyMap {
            if key.lowercased() == lower {
                return value
            }
        }
        return nil
    }

    /// Reverse lookup: CGKeyCode -> key name
    static func keyName(for code: CGKeyCode) -> String? {
        // Prefer common names
        let preferred: [CGKeyCode: String] = [
            0x3B: "Ctrl", 0x38: "Shift", 0x3A: "Alt", 0x37: "Command",
            0x24: "Return", 0x30: "Tab", 0x31: "Space", 0x33: "Delete",
            0x35: "Escape",
        ]
        if let name = preferred[code] {
            return name
        }
        for (key, value) in keyMap where value == code {
            return key
        }
        return nil
    }
}
