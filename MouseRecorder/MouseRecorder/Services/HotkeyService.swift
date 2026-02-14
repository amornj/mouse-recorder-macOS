import AppKit
import HotKey
import Combine

/// Manages global hotkey registration for macros using the HotKey SPM package.
@MainActor
final class HotkeyService: ObservableObject {
    /// Callback when a macro's hotkey is pressed. Passes the macro ID.
    var onMacroHotkeyPressed: ((String) -> Void)?
    /// Callback when the emergency stop hotkey (F12) is pressed.
    var onStopHotkeyPressed: (() -> Void)?

    private var macroHotkeys: [String: HotKey] = [:]  // macroId -> HotKey
    private var macroHotkeyStrings: [String: String] = [:]  // macroId -> hotkeyString
    private var stopHotkey: HotKey?

    init() {
        registerStopHotkey()
    }

    /// Register the F12 emergency stop hotkey.
    private func registerStopHotkey() {
        stopHotkey = HotKey(key: .f12, modifiers: [])
        stopHotkey?.keyDownHandler = { [weak self] in
            self?.onStopHotkeyPressed?()
        }
    }

    /// Register a hotkey for a specific macro.
    func registerMacroHotkey(macroId: String, hotkeyString: String) {
        // Unregister existing hotkey for this macro
        unregisterMacroHotkey(macroId: macroId)

        guard let binding = HotkeyBinding.parse(hotkeyString) else { return }

        let hotkey = HotKey(key: binding.key, modifiers: binding.modifiers)
        hotkey.keyDownHandler = { [weak self] in
            self?.onMacroHotkeyPressed?(macroId)
        }
        macroHotkeys[macroId] = hotkey
        macroHotkeyStrings[macroId] = hotkeyString
    }

    /// Unregister a specific macro's hotkey.
    func unregisterMacroHotkey(macroId: String) {
        macroHotkeys.removeValue(forKey: macroId)
        macroHotkeyStrings.removeValue(forKey: macroId)
    }

    /// Register hotkeys for all macros.
    func registerAllHotkeys(macros: [Macro]) {
        // Clear all existing macro hotkeys
        macroHotkeys.removeAll()

        for macro in macros {
            guard !macro.hotkey.isEmpty else { continue }
            registerMacroHotkey(macroId: macro.id, hotkeyString: macro.hotkey)
        }
    }

    /// Unregister all macro hotkeys (stop hotkey remains).
    func unregisterAll() {
        macroHotkeys.removeAll()
        macroHotkeyStrings.removeAll()
    }

    /// Check if a hotkey string is already in use by another macro.
    func isHotkeyInUse(_ hotkeyString: String, excludingMacroId: String) -> Bool {
        guard !hotkeyString.isEmpty else { return false }
        for (macroId, str) in macroHotkeyStrings where macroId != excludingMacroId {
            if str == hotkeyString { return true }
        }
        return false
    }

    deinit {
        macroHotkeys.removeAll()
        stopHotkey = nil
    }
}
