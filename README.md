# Mouse Recorder for macOS

A native macOS application for automating mouse clicks and keyboard shortcuts via user-defined macros.

Built with Swift / SwiftUI — runs on macOS 13 Ventura and later.

macOS port of [Mouse Recorder for Windows](https://github.com/amornj/mouse-recorder).

## Features

- **Macro editor** — create sequences of left-clicks, keyboard shortcuts, and wait delays
- **Position picker** — fullscreen crosshair overlay to capture exact screen coordinates
- **Keyboard shortcut capture** — press any key combination to record it as a step
- **Global hotkeys** — assign macros to F1–F11 or Ctrl+key combos, trigger from any application
- **Emergency stop** — press F12 to immediately halt a running macro
- **Loop / repeat** — run a macro N times or infinitely (set repeat to 0)
- **Import / export** — share macros as JSON files (cross-platform compatible with Windows version)
- **Menu bar icon** — minimize to menu bar, hotkeys remain active in the background
- **Auto-save** — macros persist automatically to `~/Library/Application Support/MouseRecorder/macros.json`
- **Accessibility permission** — guided setup for macOS Accessibility permission

## Requirements

- **To run**: macOS 13 Ventura or later, Accessibility permission granted
- **To build**: Xcode 15+ with Swift 5.9+

## Build

1. Clone the repository
2. Open `MouseRecorder/MouseRecorder.xcodeproj` in Xcode
3. SPM will resolve the [HotKey](https://github.com/soffes/HotKey) dependency automatically
4. Build and run with `Cmd+R`

Or from command line:
```bash
cd MouseRecorder
xcodebuild -scheme MouseRecorder -configuration Release build
```

## Macro JSON Format

Macros are stored as JSON and can be imported/exported. The format is compatible with the Windows version:

```json
[
  {
    "Id": "uuid-string",
    "Name": "My Macro",
    "Hotkey": "F6",
    "RepeatCount": 1,
    "Steps": [
      { "Type": "LeftClick", "X": 500, "Y": 300, "Keys": [], "DelayMs": 500 },
      { "Type": "Wait", "X": 0, "Y": 0, "Keys": [], "DelayMs": 1000 },
      { "Type": "KeyboardShortcut", "X": 0, "Y": 0, "Keys": ["Ctrl", "C"], "DelayMs": 500 }
    ]
  }
]
```

## macOS Notes

- **Accessibility permission** is required for simulating mouse clicks and keyboard input. The app will prompt you to enable it in System Settings > Privacy & Security > Accessibility.
- **Function keys** (F1–F12) default to system functions on Mac keyboards. You may need to hold `fn` or change the setting in System Settings > Keyboard.
- **Modifier mapping** from Windows: Ctrl → Control, Alt → Option, Win → Command.
- **No App Sandbox** — the app requires unsandboxed access for `CGEventPost` to work. It is not distributed via the Mac App Store.

## License

MIT
