import Foundation

struct Macro: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var hotkey: String
    var repeatCount: Int
    var steps: [MacroStep]

    init(
        id: String = UUID().uuidString,
        name: String = "New Macro",
        hotkey: String = "",
        repeatCount: Int = Constants.defaultRepeatCount,
        steps: [MacroStep] = []
    ) {
        self.id = id
        self.name = name
        self.hotkey = hotkey
        self.repeatCount = repeatCount
        self.steps = steps
    }

    var repeatDisplayText: String {
        repeatCount == 0 ? "∞" : "\(repeatCount)"
    }

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case hotkey = "Hotkey"
        case repeatCount = "RepeatCount"
        case steps = "Steps"
    }
}
