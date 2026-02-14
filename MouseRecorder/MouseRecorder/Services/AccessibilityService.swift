import AppKit
import Combine

/// Manages Accessibility permission checks and polling.
final class AccessibilityService: ObservableObject {
    @Published var isGranted: Bool = false

    private var pollTimer: Timer?

    init() {
        isGranted = AXIsProcessTrusted()
    }

    /// Check current accessibility permission status.
    func checkPermission() -> Bool {
        isGranted = AXIsProcessTrusted()
        return isGranted
    }

    /// Prompt the user to grant accessibility permission and start polling.
    func requestPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
        startPolling()
    }

    /// Poll every 2 seconds until permission is granted.
    func startPolling() {
        stopPolling()
        pollTimer = Timer.scheduledTimer(withTimeInterval: Constants.accessibilityPollInterval, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.checkPermission() {
                self.stopPolling()
            }
        }
    }

    func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    deinit {
        stopPolling()
    }
}
