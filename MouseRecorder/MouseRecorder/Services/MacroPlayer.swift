import Foundation
import Combine

/// Async macro playback engine with cancellation support.
@MainActor
final class MacroPlayer: ObservableObject {
    @Published var isPlaying = false
    @Published var statusText = "Ready"

    private var playbackTask: Task<Void, Never>?

    /// Start playing a macro. Prevents concurrent execution.
    func play(_ macro: Macro) {
        guard !isPlaying else { return }

        isPlaying = true
        statusText = "Playing: \(macro.name)"

        playbackTask = Task {
            await executePlayback(macro)
            isPlaying = false
            statusText = "Ready"
        }
    }

    /// Stop current playback.
    func stop() {
        playbackTask?.cancel()
        playbackTask = nil
        isPlaying = false
        statusText = "Stopped"
    }

    private func executePlayback(_ macro: Macro) async {
        let repeatCount = macro.repeatCount
        let isInfinite = repeatCount == 0
        var iteration = 0

        while isInfinite || iteration < repeatCount {
            guard !Task.isCancelled else { return }

            for (index, step) in macro.steps.enumerated() {
                guard !Task.isCancelled else { return }

                statusText = "Playing: \(macro.name) — Step \(index + 1)/\(macro.steps.count)"
                await executeStep(step)
            }

            iteration += 1
        }
    }

    private func executeStep(_ step: MacroStep) async {
        switch step.type {
        case .leftClick:
            await MouseSimulator.leftClick(at: CGPoint(x: step.x, y: step.y))

        case .keyboardShortcut:
            KeyboardSimulator.simulateShortcut(keys: step.keys)

        case .wait:
            await interruptibleWait(ms: step.delayMs)
        }
    }

    /// Wait in small increments so cancellation is responsive.
    private func interruptibleWait(ms: Int) async {
        let totalNs = UInt64(ms) * 1_000_000
        var elapsed: UInt64 = 0
        let chunk = Constants.waitCheckInterval

        while elapsed < totalNs {
            guard !Task.isCancelled else { return }
            let remaining = totalNs - elapsed
            let sleepTime = min(chunk, remaining)
            try? await Task.sleep(nanoseconds: sleepTime)
            elapsed += sleepTime
        }
    }
}
