import CoreGraphics

/// Maps modifier key names to CGEventFlags for keyboard simulation.
enum ModifierFlagMapping {
    static let modifierKeys: Set<String> = ["Ctrl", "Control", "Alt", "Option", "Shift", "Win", "Command", "Cmd"]

    static func isModifier(_ keyName: String) -> Bool {
        modifierKeys.contains(keyName)
    }

    static func flags(for keyName: String) -> CGEventFlags? {
        switch keyName {
        case "Ctrl", "Control":
            return .maskControl
        case "Alt", "Option":
            return .maskAlternate
        case "Shift":
            return .maskShift
        case "Win", "Command", "Cmd":
            return .maskCommand
        default:
            return nil
        }
    }

    /// Combine modifier flags from a list of key names.
    static func combinedFlags(for keys: [String]) -> CGEventFlags {
        var result = CGEventFlags()
        for key in keys {
            if let flag = flags(for: key) {
                result.insert(flag)
            }
        }
        return result
    }
}
