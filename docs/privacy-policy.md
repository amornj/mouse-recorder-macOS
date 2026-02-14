---
layout: default
title: Privacy Policy - Mouse Recorder for macOS
---

# Privacy Policy

**Last updated: February 14, 2026**

## Overview

Mouse Recorder for macOS ("the App") is designed with privacy as a core principle. The App operates entirely on your local machine and does not collect, store, or transmit any personal data.

## Data Collection

**The App does not collect any data.** Specifically:

- No analytics or telemetry
- No crash reports sent to external servers
- No user tracking or identification
- No network requests of any kind
- No cookies or local tracking identifiers

## Data Storage

The App stores macro data locally on your device at:
```
~/Library/Application Support/MouseRecorder/macros.json
```

This file contains only the macro configurations you create (step types, coordinates, key names, text, and timing values). It is stored in plain JSON format and is never transmitted anywhere.

## Accessibility Permission

The App requests macOS Accessibility permission to:
- Simulate mouse clicks at specified screen coordinates
- Simulate keyboard input for shortcut and text automation
- Register global hotkeys for macro playback

This permission is used **solely** for the macro playback functionality. The App does not monitor, record, or log any user input. The App does not read content from other applications.

## Third-Party Services

The App uses no third-party services, SDKs, or frameworks that collect data. The only external dependency ([HotKey](https://github.com/soffes/HotKey)) is an open-source library for registering keyboard shortcuts that operates entirely locally.

## Children's Privacy

The App does not collect any information from anyone, including children under the age of 13.

## Changes to This Policy

If this privacy policy is updated, the changes will be posted on this page with an updated date. Since the App collects no data, significant changes are unlikely.

## Contact

If you have questions about this privacy policy, please open an issue on the [GitHub repository](https://github.com/amornj/mouse-recorder-macOS/issues).
