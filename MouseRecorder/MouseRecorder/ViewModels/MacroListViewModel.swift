import Foundation
import Combine
import SwiftUI

/// Main view model managing macro list, selection, playback, and persistence.
@MainActor
final class MacroListViewModel: ObservableObject {
    @Published var macros: [Macro] = []
    @Published var selectedMacroId: String?
    @Published var isPlaying: Bool = false
    @Published var statusText: String = "Ready"
    @Published var isAccessibilityGranted: Bool = false
    @Published var currentStepIndex: Int? = nil
    @Published var playingMacroId: String? = nil

    let macroStore = MacroStore()
    let macroPlayer = MacroPlayer()
    let hotkeyService = HotkeyService()
    let accessibilityService = AccessibilityService()
    let overlayController = OverlayWindowController()

    private var cancellables = Set<AnyCancellable>()

    var selectedMacro: Macro? {
        get { macros.first { $0.id == selectedMacroId } }
        set {
            if let newValue, let index = macros.firstIndex(where: { $0.id == newValue.id }) {
                macros[index] = newValue
                autoSave()
            }
        }
    }

    init() {
        loadMacros()
        setupBindings()
    }

    private func setupBindings() {
        // Forward player state
        macroPlayer.$isPlaying
            .assign(to: &$isPlaying)

        macroPlayer.$statusText
            .assign(to: &$statusText)

        macroPlayer.$currentStepIndex
            .assign(to: &$currentStepIndex)

        macroPlayer.$playingMacroId
            .assign(to: &$playingMacroId)

        // Forward accessibility state so SwiftUI views update
        accessibilityService.$isGranted
            .assign(to: &$isAccessibilityGranted)

        // Hotkey callbacks
        hotkeyService.onMacroHotkeyPressed = { [weak self] macroId in
            guard let self else { return }
            Task { @MainActor in
                self.playMacro(id: macroId)
            }
        }

        hotkeyService.onStopHotkeyPressed = { [weak self] in
            self?.stopPlayback()
        }
    }

    // MARK: - Persistence

    func loadMacros() {
        macros = macroStore.load()
        hotkeyService.registerAllHotkeys(macros: macros)
    }

    func autoSave() {
        macroStore.save(macros)
        hotkeyService.registerAllHotkeys(macros: macros)
    }

    // MARK: - Macro CRUD

    func addMacro() {
        let macro = Macro()
        macros.append(macro)
        selectedMacroId = macro.id
        autoSave()
    }

    func deleteMacro(id: String) {
        hotkeyService.unregisterMacroHotkey(macroId: id)
        macros.removeAll { $0.id == id }
        if selectedMacroId == id {
            selectedMacroId = macros.first?.id
        }
        autoSave()
    }

    func deleteSelectedMacro() {
        guard let id = selectedMacroId else { return }
        deleteMacro(id: id)
    }

    // MARK: - Step Operations

    func addStep(type: StepType, toMacroId macroId: String) {
        guard let index = macros.firstIndex(where: { $0.id == macroId }) else { return }
        let step = MacroStep(type: type)
        macros[index].steps.append(step)
        autoSave()
    }

    func deleteStep(stepId: UUID, fromMacroId macroId: String) {
        guard let macroIndex = macros.firstIndex(where: { $0.id == macroId }) else { return }
        macros[macroIndex].steps.removeAll { $0.id == stepId }
        autoSave()
    }

    func moveStepUp(stepId: UUID, inMacroId macroId: String) {
        guard let macroIndex = macros.firstIndex(where: { $0.id == macroId }) else { return }
        guard let stepIndex = macros[macroIndex].steps.firstIndex(where: { $0.id == stepId }),
              stepIndex > 0 else { return }
        macros[macroIndex].steps.swapAt(stepIndex, stepIndex - 1)
        autoSave()
    }

    func moveStepDown(stepId: UUID, inMacroId macroId: String) {
        guard let macroIndex = macros.firstIndex(where: { $0.id == macroId }) else { return }
        guard let stepIndex = macros[macroIndex].steps.firstIndex(where: { $0.id == stepId }),
              stepIndex < macros[macroIndex].steps.count - 1 else { return }
        macros[macroIndex].steps.swapAt(stepIndex, stepIndex + 1)
        autoSave()
    }

    func updateStep(stepId: UUID, inMacroId macroId: String, update: (inout MacroStep) -> Void) {
        guard let macroIndex = macros.firstIndex(where: { $0.id == macroId }),
              let stepIndex = macros[macroIndex].steps.firstIndex(where: { $0.id == stepId }) else { return }
        update(&macros[macroIndex].steps[stepIndex])
        autoSave()
    }

    // MARK: - Macro Field Updates

    func updateMacroName(_ name: String, macroId: String) {
        guard let index = macros.firstIndex(where: { $0.id == macroId }) else { return }
        macros[index].name = name
        autoSave()
    }

    func updateMacroHotkey(_ hotkey: String, macroId: String) {
        guard let index = macros.firstIndex(where: { $0.id == macroId }) else { return }

        // Check for hotkey conflicts
        if !hotkey.isEmpty && hotkeyService.isHotkeyInUse(hotkey, excludingMacroId: macroId) {
            statusText = "Warning: Hotkey \(hotkey) is already assigned to another macro"
        }

        macros[index].hotkey = hotkey
        autoSave()
    }

    func updateMacroRepeatCount(_ count: Int, macroId: String) {
        guard let index = macros.firstIndex(where: { $0.id == macroId }) else { return }
        macros[index].repeatCount = max(0, count)
        autoSave()
    }

    // MARK: - Playback

    func playMacro(id: String) {
        guard !isPlaying else { return }
        guard accessibilityService.isGranted else {
            statusText = "Accessibility permission required"
            return
        }
        guard let macro = macros.first(where: { $0.id == id }),
              !macro.steps.isEmpty else { return }
        macroPlayer.play(macro)
    }

    func playSelectedMacro() {
        guard let id = selectedMacroId else { return }
        playMacro(id: id)
    }

    func stopPlayback() {
        macroPlayer.stop()
    }

    // MARK: - Import/Export

    func importMacros() {
        guard let imported = macroStore.showImportPanel() else { return }
        macros.append(contentsOf: imported)
        autoSave()
    }

    func exportMacros() {
        _ = macroStore.showExportPanel(macros: macros)
    }

    func exportSelectedMacro() {
        guard let macro = selectedMacro else { return }
        _ = macroStore.showExportPanel(macros: [macro])
    }

    // MARK: - Position Picker

    func pickPosition(for stepId: UUID, inMacroId macroId: String) {
        Task {
            if let point = await overlayController.pickPosition() {
                updateStep(stepId: stepId, inMacroId: macroId) { step in
                    step.x = Int(point.x)
                    step.y = Int(point.y)
                }
            }
        }
    }
}
