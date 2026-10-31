# TouchyOS

A native macOS app designed for touchscreen MacBooks that adapts the window system and operating system to be more comfortable for touch users, inspired by iOS/iPadOS.

## Features

- **Menu Bar Integration**: Runs as a menu bar app with quick access to touch features
- **Background Execution**: Runs continuously in the background (LSUIElement)
- **Touch-Optimized Window Controls**: Larger touch targets for close, minimize, maximize buttons
- **Gesture-Based Window Management**:
  - Swipe from edges to snap windows
  - Three-finger swipe for Mission Control / App Switcher
  - Four-finger swipe to switch desktops
  - Pinch to resize windows
  - Drag to move windows
- **Virtual Trackpad**: On-screen trackpad for precise cursor control
- **Virtual Keyboard**: Full on-screen keyboard with macOS modifier keys (⌘, ⌥, ⌃, ⇧)
- **Window Snapping**: Drag windows to edges/corners to snap (iPadOS-style)
- **Touch Visualizer**: Visual feedback for touch interactions
- **Customizable Settings**: Extensive configuration options

## Requirements

- macOS 14.0 (Sonoma) or later
- Touchscreen MacBook (or any Mac for testing)
- Accessibility permissions (required for window management)

## Installation

### From Source

```bash
git clone https://github.com/yourusername/touchy-os.git
cd touchy-os
./build.sh
open .build/release/TouchyOS.app
```

### Grant Permissions

On first launch, TouchyOS will request accessibility permissions. Grant them in:
**System Settings → Privacy & Security → Accessibility → TouchyOS**

## Usage

### Menu Bar
Click the TouchyOS icon in the menu bar to access:
- Toggle touch mode on/off
- Show virtual keyboard/trackpad
- Quick window snapping
- Mission Control / App Switcher
- Open windows list
- Settings

### Touch Gestures

| Gesture | Action |
|---------|--------|
| Tap window button | Close/Minimize/Maximize |
| Drag title bar | Move window |
| Drag from edge | Snap window |
| Pinch on window | Resize window |
| 3-finger swipe up | Mission Control |
| 3-finger swipe down | App Switcher |
| 4-finger swipe left/right | Switch desktops |
| Long press window | Window controls menu |
| Double tap title bar | Toggle fullscreen |

### Virtual Trackpad
- Click/tap for left click
- Two-finger tap for right click
- Drag to move cursor
- Scroll with two fingers

### Virtual Keyboard
- Tap keys to type
- Modifier keys (⌘, ⌥, ⌃, ⇧) toggle on/off
- Function keys available in bottom row
- Arrow keys for navigation

## Configuration

Access settings from the menu bar → Settings. Configure:

- **General**: Enable/disable touch mode, sensitivity
- **Gestures**: Edge gestures, multi-finger gestures, timing
- **Windows**: Snapping behavior, animation
- **Input**: Virtual trackpad/keyboard, layout, size
- **Appearance**: Theme, accent color, corner radius
- **Advanced**: Haptic feedback, overlay opacity, debug

## Architecture

```
TouchyOS/
├── Sources/TouchyOS/
│   ├── TouchyOSApp.swift          # App entry point
│   ├── Models/
│   │   └── TouchModels.swift      # Data models
│   ├── Services/
│   │   ├── WindowManager.swift    # Window management via Accessibility API
│   │   ├── TouchOverlayManager.swift  # Touch handling & overlays
│   │   └── SettingsService.swift  # Settings persistence
│   ├── Views/
│   │   ├── MenuBarView.swift      # Menu bar popover
│   │   ├── SettingsView.swift     # Settings window
│   │   ├── TouchOverlayView.swift # Touch visualization
│   │   └── VirtualInputViews.swift # Trackpad & keyboard
│   └── Resources/
│       ├── Info.plist
│       └── TouchyOS.entitlements
├── Package.swift
└── build.sh
```

## Technical Details

### Window Management
Uses macOS Accessibility API (AXUIElement) to:
- Enumerate windows via CGWindowListCopyWindowInfo
- Perform actions (move, resize, close, minimize, etc.)
- Observe window changes via AXObserver

### Touch Handling
- Global event monitor for gesture events
- Custom gesture recognizer for multi-touch
- Touch zones overlaid on windows

### Background Execution
- LSUIElement = true in Info.plist
- No dock icon, only menu bar presence
- Runs continuously monitoring for touch events

## Known Limitations

1. Requires Accessibility permissions for window management
2. Some gestures may conflict with system gestures
3. Virtual keyboard doesn't support all international layouts yet
4. Window snapping works best with standard windows

## Future Enhancements

- [ ] Stage Manager integration
- [ ] Custom gesture recording
- [ ] Per-app touch settings
- [ ] Apple Pencil support
- [ ] Touch-friendly menu bar replacement
- [ ] On-screen Dock alternative
- [ ] Split View controller for iPadOS-style multitasking

## License

MIT License - see LICENSE file for details

## Acknowledgments

- Inspired by iPadOS touch interactions
- Built with SwiftUI and AppKit
- Uses macOS Accessibility API for window management