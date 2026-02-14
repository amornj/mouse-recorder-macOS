import Foundation

enum Constants {
    static let appName = "Mouse Recorder"
    static let macrosFileName = "macros.json"
    static let appSupportSubdirectory = "MouseRecorder"

    static let emergencyStopKey = "F12"
    static let defaultDelayMs = 500
    static let defaultRepeatCount = 1

    static let clickMoveDelay: UInt64 = 30_000_000   // 30ms in nanoseconds
    static let clickDownDelay: UInt64 = 20_000_000    // 20ms in nanoseconds
    static let waitCheckInterval: UInt64 = 100_000_000 // 100ms in nanoseconds

    static let accessibilityPollInterval: TimeInterval = 2.0

    static let availableHotkeys: [String] = {
        var keys: [String] = []
        // F1–F11 (F12 reserved for stop)
        for i in 1...11 {
            keys.append("F\(i)")
        }
        // Ctrl+F1–Ctrl+F12
        for i in 1...12 {
            keys.append("Ctrl+F\(i)")
        }
        // Ctrl+1–Ctrl+9
        for i in 1...9 {
            keys.append("Ctrl+\(i)")
        }
        return keys
    }()
}
