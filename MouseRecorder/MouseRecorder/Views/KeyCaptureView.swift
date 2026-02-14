import SwiftUI
import AppKit

/// Modal sheet for capturing keyboard combinations.
struct KeyCaptureView: View {
    let onComplete: ([String]?) -> Void

    @State private var capturedKeys: [String] = []
    @State private var displayText: String = "Press a key combination..."
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Capture Keyboard Shortcut")
                .font(.headline)

            Text("Press the key combination you want to assign")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(displayText)
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor, lineWidth: 2)
                )

            HStack {
                Button("Cancel") {
                    onComplete(nil)
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("OK") {
                    onComplete(capturedKeys.isEmpty ? nil : capturedKeys)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(capturedKeys.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400)
        .background(KeyCaptureEventView(onKeysCaptured: { keys in
            capturedKeys = keys
            displayText = keys.joined(separator: " + ")
        }))
    }
}

/// NSView wrapper to capture keyboard events via NSEvent monitor.
struct KeyCaptureEventView: NSViewRepresentable {
    let onKeysCaptured: ([String]) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = KeyCaptureNSView()
        view.onKeysCaptured = onKeysCaptured
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

final class KeyCaptureNSView: NSView {
    var onKeysCaptured: (([String]) -> Void)?
    private var monitor: Any?

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)

        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
            return nil // Consume the event
        }
    }

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow == nil, let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }

    private func handleKeyEvent(_ event: NSEvent) {
        var keys: [String] = []

        // Check modifiers
        let modifiers = event.modifierFlags
        if modifiers.contains(.control) { keys.append("Ctrl") }
        if modifiers.contains(.option) { keys.append("Alt") }
        if modifiers.contains(.shift) { keys.append("Shift") }
        if modifiers.contains(.command) { keys.append("Command") }

        // Get the main key
        if let keyName = keyNameFromEvent(event) {
            keys.append(keyName)
        } else {
            // Don't report pure modifier presses
            return
        }

        onKeysCaptured?(keys)
    }

    private func keyNameFromEvent(_ event: NSEvent) -> String? {
        let keyCode = event.keyCode

        // Map key codes to names
        let keyCodeMap: [UInt16: String] = [
            // Letters
            0x00: "A", 0x01: "S", 0x02: "D", 0x03: "F", 0x04: "H",
            0x05: "G", 0x06: "Z", 0x07: "X", 0x08: "C", 0x09: "V",
            0x0B: "B", 0x0C: "Q", 0x0D: "W", 0x0E: "E", 0x0F: "R",
            0x10: "Y", 0x11: "T", 0x20: "U", 0x22: "I", 0x1F: "O",
            0x23: "P", 0x25: "L", 0x26: "J", 0x28: "K", 0x2D: "N",
            0x2E: "M",

            // Numbers
            0x12: "1", 0x13: "2", 0x14: "3", 0x15: "4", 0x17: "5",
            0x16: "6", 0x1A: "7", 0x1C: "8", 0x19: "9", 0x1D: "0",

            // Function keys
            0x7A: "F1", 0x78: "F2", 0x63: "F3", 0x76: "F4",
            0x60: "F5", 0x61: "F6", 0x62: "F7", 0x64: "F8",
            0x65: "F9", 0x6D: "F10", 0x67: "F11", 0x6F: "F12",

            // Special keys
            0x24: "Enter", 0x30: "Tab", 0x31: "Space",
            0x33: "Delete", 0x75: "ForwardDelete",
            0x35: "Escape",
            0x73: "Home", 0x77: "End",
            0x74: "PageUp", 0x79: "PageDown",
            0x7E: "Up", 0x7D: "Down", 0x7B: "Left", 0x7C: "Right",

            // Symbols
            0x1B: "-", 0x18: "=",
            0x21: "[", 0x1E: "]",
            0x2A: "\\", 0x29: ";", 0x27: "'",
            0x2B: ",", 0x2F: ".", 0x2C: "/", 0x32: "`",
        ]

        // Skip pure modifier key presses
        let modifierKeyCodes: Set<UInt16> = [
            0x3B, 0x3E, // Left/Right Control
            0x3A, 0x3D, // Left/Right Option
            0x38, 0x3C, // Left/Right Shift
            0x37, 0x36, // Left/Right Command
            0x3F,       // Function key
        ]

        if modifierKeyCodes.contains(keyCode) {
            return nil
        }

        return keyCodeMap[keyCode]
    }
}
