import Foundation

enum StepType: String, Codable, CaseIterable {
    case leftClick = "LeftClick"
    case keyboardShortcut = "KeyboardShortcut"
    case wait = "Wait"
}

struct MacroStep: Codable, Identifiable, Equatable {
    let id: UUID
    var type: StepType
    var x: Int
    var y: Int
    var keys: [String]
    var delayMs: Int

    var displayText: String {
        switch type {
        case .leftClick:
            return "Left Click at (\(x), \(y))"
        case .keyboardShortcut:
            return keys.isEmpty ? "Keyboard Shortcut" : keys.joined(separator: " + ")
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
        delayMs: Int = Constants.defaultDelayMs
    ) {
        self.id = id
        self.type = type
        self.x = x
        self.y = y
        self.keys = keys
        self.delayMs = delayMs
    }

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case x = "X"
        case y = "Y"
        case keys = "Keys"
        case delayMs = "DelayMs"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.type = try container.decode(StepType.self, forKey: .type)
        self.x = try container.decodeIfPresent(Int.self, forKey: .x) ?? 0
        self.y = try container.decodeIfPresent(Int.self, forKey: .y) ?? 0
        self.keys = try container.decodeIfPresent([String].self, forKey: .keys) ?? []
        self.delayMs = try container.decodeIfPresent(Int.self, forKey: .delayMs) ?? Constants.defaultDelayMs
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(keys, forKey: .keys)
        try container.encode(delayMs, forKey: .delayMs)
    }
}
