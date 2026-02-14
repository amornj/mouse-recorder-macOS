import Foundation

enum StepType: String, Codable, CaseIterable {
    case leftClick = "LeftClick"
    case doubleClick = "DoubleClick"
    case rightClick = "RightClick"
    case keyboardShortcut = "KeyboardShortcut"
    case keystroke = "Keystroke"
    case typeText = "TypeText"
    case wait = "Wait"
}

struct MacroStep: Codable, Identifiable, Equatable {
    let id: UUID
    var type: StepType
    var x: Int
    var y: Int
    var keys: [String]
    var delayMs: Int
    var text: String
    var note: String

    var displayText: String {
        switch type {
        case .leftClick:
            return "Left Click at (\(x), \(y))"
        case .doubleClick:
            return "Double Click at (\(x), \(y))"
        case .rightClick:
            return "Right Click at (\(x), \(y))"
        case .keyboardShortcut:
            return keys.isEmpty ? "Keyboard Shortcut" : keys.joined(separator: " + ")
        case .keystroke:
            return keys.isEmpty ? "Keystroke" : "Press \(keys.first ?? "")"
        case .typeText:
            let preview = text.prefix(30)
            return text.isEmpty ? "Type Text" : "Type \"\(preview)\(text.count > 30 ? "…" : "")\""
        case .wait:
            return "Wait \(delayMs) ms"
        }
    }

    init(
        id: UUID = UUID(),
        type: StepType,
        x: Int = 0,
        y: Int = 0,
        keys: [String] = [],
        delayMs: Int = Constants.defaultDelayMs,
        text: String = "",
        note: String = ""
    ) {
        self.id = id
        self.type = type
        self.x = x
        self.y = y
        self.keys = keys
        self.delayMs = delayMs
        self.text = text
        self.note = note
    }

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case x = "X"
        case y = "Y"
        case keys = "Keys"
        case delayMs = "DelayMs"
        case text = "Text"
        case note = "Note"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.type = try container.decode(StepType.self, forKey: .type)
        self.x = try container.decodeIfPresent(Int.self, forKey: .x) ?? 0
        self.y = try container.decodeIfPresent(Int.self, forKey: .y) ?? 0
        self.keys = try container.decodeIfPresent([String].self, forKey: .keys) ?? []
        self.delayMs = try container.decodeIfPresent(Int.self, forKey: .delayMs) ?? Constants.defaultDelayMs
        self.text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
        self.note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(keys, forKey: .keys)
        try container.encode(delayMs, forKey: .delayMs)
        try container.encode(text, forKey: .text)
        try container.encode(note, forKey: .note)
    }
}
