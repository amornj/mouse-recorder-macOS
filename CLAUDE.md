# Mouse Recorder macOS

macOS port of [Mouse Recorder](https://github.com/amornj/mouse-recorder) (originally Windows WPF/C#).

## Tech Stack
- **Language**: Swift 5.9+
- **UI**: SwiftUI (macOS 13+ deployment target)
- **Architecture**: MVVM (ObservableObject / @Published / @StateObject)
- **Dependencies**: [HotKey](https://github.com/soffes/HotKey) v0.2.1 (global hotkeys via Carbon API)
- **Build**: Swift Package Manager (Package.swift in MouseRecorder/)
- **No App Sandbox** - required for CGEventPost accessibility API

## Project Structure
```
MouseRecorder/
├── Package.swift                           # SPM manifest with HotKey dependency
├── MouseRecorder/
│   ├── MouseRecorderApp.swift              # @main SwiftUI app entry point
│   ├── AppDelegate.swift                   # NSApplicationDelegate (status bar, permissions)
│   ├── Models/                             # Codable data models (PascalCase JSON keys)
│   ├── ViewModels/                         # ObservableObject view models
│   ├── Views/                              # SwiftUI views + NSWindow overlay
│   ├── Services/                           # MacroStore, MacroPlayer, simulators, hotkeys
│   └── Utilities/                          # CGKeyCodeMap, ModifierFlagMapping, Constants
└── MouseRecorderTests/                     # Unit tests
```

## Build & Run
```bash
cd MouseRecorder
swift build
swift run
# Or open in Xcode: open Package.swift
```

## Key Design Decisions
- **JSON format**: Maintains exact compatibility with Windows version using PascalCase CodingKeys
- **Accessibility**: Requires macOS Accessibility permission (AXIsProcessTrusted) for CGEventPost
- **Hotkeys**: F1-F11, Ctrl+F1-F12, Ctrl+1-9 available; F12 is permanent emergency stop
- **Persistence**: ~/Library/Application Support/MouseRecorder/macros.json
- **Coordinate system**: CGEvent uses top-left origin (same as Windows), no Y-flip needed
- **Modifier mapping**: Windows Ctrl→macOS Control, Alt→Option, Win→Command

## Testing
```bash
cd MouseRecorder
swift test
```
