---
layout: default
title: Support - Mouse Recorder for macOS
---

# Support

## Frequently Asked Questions

### How do I grant Accessibility permission?

1. Open **System Settings** > **Privacy & Security** > **Accessibility**
2. Click the **+** button or find **Mouse Recorder** in the list
3. Toggle the switch to enable access
4. If the app doesn't appear, try quitting and reopening it

### Macros aren't playing / clicks aren't working

- Verify Accessibility permission is granted (see above)
- Make sure no other app is intercepting the hotkey
- Check that the target application is in the foreground when using click steps

### F12 stop isn't working

F12 is registered as a global hotkey. On Mac laptops, you may need to hold the **fn** key to press F12, or change the system setting:
- System Settings > Keyboard > "Use F1, F2, etc. keys as standard function keys"

### Hotkey not triggering

- Ensure the hotkey isn't already assigned to another macro or system function
- Some hotkeys (like F1–F4) may conflict with macOS system shortcuts (Mission Control, Spotlight, etc.)
- Try using Ctrl+F1 through Ctrl+F12 to avoid conflicts

### Position picker shows wrong coordinates

- Coordinates use the top-left origin (0,0 is top-left of the primary display)
- On multi-monitor setups, coordinates extend across all screens
- Make sure the target window is in the same position when recording and playing

### Imported macros from Windows don't work correctly

- Mouse coordinates may differ between Windows and macOS due to different screen resolutions and scaling
- Keyboard shortcuts using Windows-specific keys (Win key) map to Command on macOS
- Step types added in the macOS version (Double Click, Right Click, Keystroke, Type Text) are not available in the Windows version

### Where are my macros stored?

Macros are saved as JSON at:
```
~/Library/Application Support/MouseRecorder/macros.json
```

You can back up this file manually or use the Export feature.

## Reporting Issues

If you encounter a bug or have a feature request, please open an issue on GitHub:

[Open an Issue](https://github.com/amornj/mouse-recorder-macOS/issues)

When reporting a bug, please include:
- macOS version
- Steps to reproduce the issue
- Expected vs actual behavior

## Contact

For other inquiries, open a GitHub issue or discussion.
