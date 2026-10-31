import SwiftUI

// MARK: - Virtual Trackpad View
struct VirtualTrackpadView: View {
    @StateObject var overlayManager = TouchOverlayManager.shared
    @EnvironmentObject var settingsService: SettingsService
    @State private var dragStart: CGPoint?
    @State private var currentPosition: CGPoint = .zero
    @State private var isDragging = false
    @State private var clickCount = 0
    @State private var lastClickTime: Date?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "trackpad.fill")
                    .foregroundColor(.accentColor)
                Text("Virtual Trackpad")
                    .font(.headline)
                Spacer()
                Button(action: { overlayManager.hideVirtualTrackpad() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Trackpad area
            ZStack {
                RoundedRectangle(cornerRadius: settingsService.settings.cornerRadius)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: settingsService.settings.cornerRadius)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )

                // Cursor indicator
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 12, height: 12)
                    .position(currentPosition)
                    .opacity(isDragging ? 1 : 0.5)

                // Click indicator
                if isDragging {
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 2)
                        .frame(width: 30, height: 30)
                        .position(currentPosition)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            dragStart = value.location
                            handleClick(at: value.location)
                        }
                        currentPosition = value.location
                        handleDrag(to: value.location)
                    }
                    .onEnded { value in
                        isDragging = false
                        dragStart = nil
                        handleDragEnd(at: value.location)
                    }
            )

            // Button area
            HStack(spacing: 20) {
                VirtualTrackpadButton(
                    title: "Left Click",
                    icon: "cursorarrow.click",
                    action: { simulateClick(button: .left) }
                )

                VirtualTrackpadButton(
                    title: "Right Click",
                    icon: "cursorarrow.click.2",
                    action: { simulateClick(button: .right) }
                )

                VirtualTrackpadButton(
                    title: "Scroll",
                    icon: "scroll",
                    action: { /* Scroll mode toggle */ }
                )
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(settingsService.settings.cornerRadius)
        .shadow(radius: 20)
    }

    private func handleClick(at location: CGPoint) {
        let now = Date()
        if let lastClick = lastClickTime, now.timeIntervalSince(lastClick) < 0.3 {
            clickCount += 1
        } else {
            clickCount = 1
        }
        lastClickTime = now
    }

    private func handleDrag(to location: CGPoint) {
        guard let start = dragStart else { return }
        let deltaX = (location.x - start.x) * 3 // Sensitivity multiplier
        let deltaY = -(location.y - start.y) * 3 // Invert Y for screen coordinates
        _ = CGPoint(x: deltaX, y: deltaY) // Used for future cursor movement

        let event = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: NSEvent.mouseLocation, mouseButton: .left)
        event?.post(tap: .cghidEventTap)
    }

    private func handleDragEnd(at location: CGPoint) {
        // Handle click if minimal movement
        if let start = dragStart {
            let distance = hypot(location.x - start.x, location.y - start.y)
            if distance < 10 {
                if clickCount >= 2 {
                    simulateClick(button: .left, count: 2)
                } else {
                    simulateClick(button: .left)
                }
            }
        }
        clickCount = 0
    }

    private func simulateClick(button: CGMouseButton, count: Int = 1) {
        let location = NSEvent.mouseLocation

        for _ in 0..<count {
            let down = CGEvent(mouseEventSource: nil, mouseType: button == .left ? .leftMouseDown : .rightMouseDown, mouseCursorPosition: location, mouseButton: button)
            let up = CGEvent(mouseEventSource: nil, mouseType: button == .left ? .leftMouseUp : .rightMouseUp, mouseCursorPosition: location, mouseButton: button)

            down?.post(tap: .cghidEventTap)
            up?.post(tap: .cghidEventTap)

            if count > 1 {
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
    }
}

// MARK: - Virtual Trackpad Button
struct VirtualTrackpadButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Virtual Keyboard View
struct VirtualKeyboardView: View {
    @EnvironmentObject var settingsService: SettingsService
    @State private var shiftPressed = false
    @State private var ctrlPressed = false
    @State private var altPressed = false
    @State private var cmdPressed = false
    @State private var fnPressed = false

    let settings: TouchyOSSettings
    let targetAppBundleId: String?

    private var keyboardScale: CGFloat {
        switch settingsService.settings.keyboardSize {
        case .small: return 0.75
        case .medium: return 1.0
        case .large: return 1.3
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "keyboard.fill")
                    .foregroundColor(.accentColor)
                Text("Virtual Keyboard")
                    .font(.headline)
                Spacer()

                // Modifier key indicators
                HStack(spacing: 4 * keyboardScale) {
                    ModifierKeyIndicator(key: "⌘", isPressed: cmdPressed)
                    ModifierKeyIndicator(key: "⌥", isPressed: altPressed)
                    ModifierKeyIndicator(key: "⌃", isPressed: ctrlPressed)
                    ModifierKeyIndicator(key: "⇧", isPressed: shiftPressed)
                    ModifierKeyIndicator(key: "fn", isPressed: fnPressed)
                }

                Button(action: { closeKeyboard() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16 * keyboardScale)
            .padding(.vertical, 12 * keyboardScale)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Keyboard
            VStack(spacing: 6 * keyboardScale) {
                // Row 1: Numbers
                KeyboardRow(keys: numberRowKeys)

                // Row 2: QWERTY
                KeyboardRow(keys: qwertyRowKeys)

                // Row 3: ASDF
                KeyboardRow(keys: asdfRowKeys)

                // Row 4: ZXCV
                KeyboardRow(keys: zxcvRowKeys)

                // Row 5: Modifiers + Space
                KeyboardRow(keys: bottomRowKeys)
            }
            .padding(12 * keyboardScale)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(settingsService.settings.cornerRadius)
        .shadow(radius: 20)
        .opacity(settings.keyboardOpacity)
    }

    // MARK: - Key Definitions
    private var numberRowKeys: [KeyboardKey] {
        let keys = ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "⌫"]
        return keys.map { key in
            KeyboardKey(
                primary: key,
                shifted: shiftedNumberRow[key] ?? key,
                action: { sendKey(key) },
                width: key == "⌫" ? 1.5 : 1.0
            )
        }
    }

    private var qwertyRowKeys: [KeyboardKey] {
        let keys = ["⇥", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]", "\\"]
        return keys.map { key in
            KeyboardKey(
                primary: key,
                shifted: key.lowercased(),
                action: { sendKey(key) },
                width: key == "⇥" ? 1.3 : (key == "\\" ? 1.3 : 1.0)
            )
        }
    }

    private var asdfRowKeys: [KeyboardKey] {
        let keys = ["⇪", "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "⏎"]
        return keys.map { key in
            KeyboardKey(
                primary: key,
                shifted: key.lowercased(),
                action: { sendKey(key) },
                width: key == "⇪" ? 1.5 : (key == "⏎" ? 1.5 : 1.0),
                isModifier: key == "⇪"
            )
        }
    }

    private var zxcvRowKeys: [KeyboardKey] {
        let keys = ["⇧", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/", "⇧"]
        return keys.map { key in
            KeyboardKey(
                primary: key,
                shifted: key.lowercased(),
                action: { sendKey(key) },
                width: key == "⇧" ? 1.8 : 1.0,
                isModifier: key == "⇧"
            )
        }
    }

    private var bottomRowKeys: [KeyboardKey] {
        [
            KeyboardKey(primary: "fn", shifted: "fn", action: { fnPressed.toggle() }, width: 1.2, isModifier: true),
            KeyboardKey(primary: "⌃", shifted: "⌃", action: { ctrlPressed.toggle() }, width: 1.2, isModifier: true),
            KeyboardKey(primary: "⌥", shifted: "⌥", action: { altPressed.toggle() }, width: 1.2, isModifier: true),
            KeyboardKey(primary: "⌘", shifted: "⌘", action: { cmdPressed.toggle() }, width: 1.2, isModifier: true),
            KeyboardKey(primary: "Space", shifted: "Space", action: { sendKey(" ") }, width: 6.0),
            KeyboardKey(primary: "⌘", shifted: "⌘", action: { cmdPressed.toggle() }, width: 1.2, isModifier: true),
            KeyboardKey(primary: "⌥", shifted: "⌥", action: { altPressed.toggle() }, width: 1.2, isModifier: true),
            KeyboardKey(primary: "←", shifted: "←", action: { sendKey("←") }, width: 1.0),
            KeyboardKey(primary: "↑", shifted: "↑", action: { sendKey("↑") }, width: 1.0),
            KeyboardKey(primary: "→", shifted: "→", action: { sendKey("→") }, width: 1.0),
            KeyboardKey(primary: "↓", shifted: "↓", action: { sendKey("↓") }, width: 1.0),
        ]
    }

    private let shiftedNumberRow: [String: String] = [
        "`": "~", "1": "!", "2": "@", "3": "#", "4": "$", "5": "%",
        "6": "^", "7": "&", "8": "*", "9": "(", "0": ")", "-": "_", "=": "+"
    ]

    // MARK: - Actions
    private func sendKey(_ key: String) {
        // Send key with modifiers
        let modifiers = getActiveModifiers()
        sendKeyEvent(key: key, modifiers: modifiers)

        // Auto-release modifiers after key press (except caps lock)
        if key != "⇪" {
            ctrlPressed = false
            altPressed = false
            cmdPressed = false
        }
        if key != "⇧" {
            shiftPressed = false
        }
    }

    private func getActiveModifiers() -> NSEvent.ModifierFlags {
        var modifiers: NSEvent.ModifierFlags = []
        if shiftPressed { modifiers.insert(.shift) }
        if ctrlPressed { modifiers.insert(.control) }
        if altPressed { modifiers.insert(.option) }
        if cmdPressed { modifiers.insert(.command) }
        return modifiers
    }

    private func sendKeyEvent(key: String, modifiers: NSEvent.ModifierFlags) {
        // Activate target app first to ensure keys go to the right place
        if let bundleId = targetAppBundleId,
           let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first {
            app.activate(options: [])
            // Small delay to let app become key
            Thread.sleep(forTimeInterval: 0.01)
        }

        let source = CGEventSource(stateID: .hidSystemState)
        let keyCode = keyCodeForString(key)

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)

        let cgFlags = CGEventFlags(rawValue: UInt64(modifiers.rawValue))
        keyDown?.flags = cgFlags
        keyUp?.flags = cgFlags

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    private func keyCodeForString(_ string: String) -> UInt16 {
        let keyMap: [String: UInt16] = [
            "`": 0x32, "1": 0x12, "2": 0x13, "3": 0x14, "4": 0x15, "5": 0x17,
            "6": 0x16, "7": 0x1A, "8": 0x1C, "9": 0x19, "0": 0x1D, "-": 0x1B, "=": 0x18,
            "⌫": 0x33, "⇥": 0x30, "q": 0x0C, "w": 0x0D, "e": 0x0E, "r": 0x0F,
            "t": 0x11, "y": 0x10, "u": 0x20, "i": 0x22, "o": 0x1F, "p": 0x23,
            "[": 0x21, "]": 0x1E, "\\": 0x2A, "⇪": 0x39, "a": 0x00, "s": 0x01,
            "d": 0x02, "f": 0x03, "g": 0x05, "h": 0x04, "j": 0x26, "k": 0x28,
            "l": 0x25, ";": 0x29, "'": 0x27, "⏎": 0x24, "⇧": 0x38, "z": 0x06,
            "x": 0x07, "c": 0x08, "v": 0x09, "b": 0x0B, "n": 0x2D, "m": 0x2E,
            ",": 0x2B, ".": 0x2F, "/": 0x2C, "fn": 0x3F, "⌃": 0x3B, "⌥": 0x3A,
            "⌘": 0x37, " ": 0x31
        ]
        // Handle arrow keys specially
        let lower = string.lowercased()
        if lower == "←" || lower == "left" { return 0x7B }
        if lower == "↑" || lower == "up" { return 0x7E }
        if lower == "→" || lower == "right" { return 0x7C }
        if lower == "↓" || lower == "down" { return 0x7D }
        return keyMap[lower] ?? 0
    }

    private func closeKeyboard() {
        TouchOverlayManager.shared.hideVirtualKeyboard()
    }
}

// MARK: - Keyboard Key Model
struct KeyboardKey: Identifiable {
    let id = UUID()
    let primary: String
    let shifted: String
    let action: () -> Void
    let width: CGFloat
    var isModifier: Bool = false
}

// MARK: - Keyboard Row
struct KeyboardRow: View {
    let keys: [KeyboardKey]
    @EnvironmentObject var settingsService: SettingsService
    @State private var shiftPressed = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(keys) { key in
                VirtualKeyView(key: key, width: key.width)
            }
        }
    }
}

// MARK: - Virtual Key View
struct VirtualKeyView: View {
    let key: KeyboardKey
    let width: CGFloat
    @EnvironmentObject var settingsService: SettingsService
    @State private var isPressed = false

    var body: some View {
        Button(action: key.action) {
            Text(key.primary)
                .font(.system(size: keyFontSize, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, keyVerticalPadding)
                .background(keyBackground)
                .cornerRadius(8)
                .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .buttonStyle(.plain)
        .frame(width: keyWidth)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.05)) {
                isPressed = pressing
            }
        }, perform: {})
    }

    private var keyboardScale: CGFloat {
        switch settingsService.settings.keyboardSize {
        case .small: return 0.75
        case .medium: return 1.0
        case .large: return 1.3
        }
    }

    private var keyFontSize: CGFloat {
        let baseSize: CGFloat = key.primary.count == 1 ? 18 : 12
        return baseSize * keyboardScale
    }

    private var keyVerticalPadding: CGFloat {
        return 10 * keyboardScale
    }

    private var keyWidth: CGFloat {
        let baseWidth: CGFloat = 44
        return baseWidth * width * keyboardScale
    }

    private var keyBackground: some View {
        Group {
            if key.isModifier {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.accentColor, lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Modifier Key Indicator
struct ModifierKeyIndicator: View {
    let key: String
    let isPressed: Bool

    var body: some View {
        Text(key)
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundColor(isPressed ? .white : .primary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isPressed ? Color.accentColor : Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
    }
}