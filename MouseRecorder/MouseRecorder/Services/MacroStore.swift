import Foundation
import AppKit

/// Handles JSON persistence of macros to ~/Library/Application Support/MouseRecorder/.
final class MacroStore {
    private let fileManager = FileManager.default

    private var storageDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent(Constants.appSupportSubdirectory)
    }

    private var macrosFileURL: URL {
        storageDirectory.appendingPathComponent(Constants.macrosFileName)
    }

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }()

    private let decoder = JSONDecoder()

    /// Ensure the storage directory exists.
    private func ensureDirectory() throws {
        if !fileManager.fileExists(atPath: storageDirectory.path) {
            try fileManager.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
        }
    }

    /// Load macros from the default storage location.
    func load() -> [Macro] {
        guard fileManager.fileExists(atPath: macrosFileURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: macrosFileURL)
            return try decoder.decode([Macro].self, from: data)
        } catch {
            print("Failed to load macros: \(error)")
            return []
        }
    }

    /// Save macros to the default storage location.
    func save(_ macros: [Macro]) {
        do {
            try ensureDirectory()
            let data = try encoder.encode(macros)
            try data.write(to: macrosFileURL, options: .atomic)
        } catch {
            print("Failed to save macros: \(error)")
        }
    }

    /// Import macros from an external file. Assigns new UUIDs to prevent conflicts.
    func importFromFile(at url: URL) -> [Macro]? {
        do {
            let data = try Data(contentsOf: url)
            var macros = try decoder.decode([Macro].self, from: data)
            // Assign new IDs on import (matching Windows behavior)
            macros = macros.map { macro in
                var m = macro
                m.id = UUID().uuidString
                return m
            }
            return macros
        } catch {
            print("Failed to import macros: \(error)")
            return nil
        }
    }

    /// Export macros to a file chosen by the user.
    func exportToFile(_ macros: [Macro], at url: URL) -> Bool {
        do {
            let data = try encoder.encode(macros)
            try data.write(to: url, options: .atomic)
            return true
        } catch {
            print("Failed to export macros: \(error)")
            return false
        }
    }

    /// Show an open panel for importing macros.
    @MainActor
    func showImportPanel() -> [Macro]? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.title = "Import Macros"

        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        return importFromFile(at: url)
    }

    /// Show a save panel for exporting macros.
    @MainActor
    func showExportPanel(macros: [Macro]) -> Bool {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "macros.json"
        panel.title = "Export Macros"

        guard panel.runModal() == .OK, let url = panel.url else { return false }
        return exportToFile(macros, at: url)
    }
}
