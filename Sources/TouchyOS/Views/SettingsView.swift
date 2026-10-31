import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var settingsService: SettingsService
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: SettingsTab = .general

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            tabBar

            Divider()

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    switch selectedTab {
                    case .general:
                        GeneralSettingsView()
                    case .gestures:
                        GestureSettingsView()
                    case .windows:
                        WindowSettingsView()
                    case .input:
                        InputSettingsView()
                    case .appearance:
                        AppearanceSettingsView()
                    case .advanced:
                        AdvancedSettingsView()
                    }
                }
                .padding(24)
            }

            Divider()

            // Bottom bar
            bottomBar
        }
        .frame(minWidth: 500, minHeight: 600)
    }

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(SettingsTab.allCases) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 16, weight: .medium))

                            Text(tab.title)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            selectedTab == tab ?
                            Color.accentColor.opacity(0.1) : Color.clear
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 56)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var bottomBar: some View {
        HStack {
            Button("Reset to Defaults") {
                settingsService.resetToDefaults()
            }
            .controlSize(.regular)

            Spacer()

            Button("Done") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
            .controlSize(.regular)
        }
        .padding()
    }
}

// MARK: - Settings Tabs
enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case gestures = "Gestures"
    case windows = "Windows"
    case input = "Input"
    case appearance = "Appearance"
    case advanced = "Advanced"

    var id: String { rawValue }

    var title: String { rawValue }

    var icon: String {
        switch self {
        case .general: return "gear"
        case .gestures: return "hand.tap"
        case .windows: return "macwindow"
        case .input: return "keyboard"
        case .appearance: return "paintbrush"
        case .advanced: return "wrench.and.screwdriver"
        }
    }
}

// MARK: - General Settings
struct GeneralSettingsView: View {
    @EnvironmentObject var settingsService: SettingsService

    var body: some View {
        SettingsSection(title: "General") {
            Toggle("Enable TouchyOS", isOn: $settingsService.isEnabled)
                .help("Master switch for all touch features")

            VStack(alignment: .leading, spacing: 8) {
                Text("Touch Sensitivity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Low")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Slider(value: $settingsService.touchSensitivity, in: 0.5...2.0, step: 0.1)

                    Text("High")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text("Adjust how sensitive touch targets are")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Gesture Sensitivity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Low")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Slider(value: $settingsService.gestureSensitivity, in: 0.5...2.0, step: 0.1)

                    Text("High")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Toggle("Show Touch Visualizer", isOn: $settingsService.showTouchVisualizer)
                .help("Show visual feedback for touch interactions")
        }
    }
}

// MARK: - Gesture Settings
struct GestureSettingsView: View {
    @EnvironmentObject var settingsService: SettingsService

    var body: some View {
        SettingsSection(title: "Edge Gestures") {
            Toggle("Enable Edge Gestures", isOn: $settingsService.enableEdgeGestures)
                .help("Swipe from screen edges for quick actions")

            VStack(alignment: .leading, spacing: 8) {
                Text("Snap Threshold")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Near")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Slider(value: Binding(
                        get: { settingsService.settings.snapThreshold },
                        set: { settingsService.settings.snapThreshold = $0 }
                    ), in: 20...200, step: 10)

                    Text("Far")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }

        SettingsSection(title: "Multi-Finger Gestures") {
            Toggle("Three Finger Swipe", isOn: Binding(
                get: { settingsService.settings.enableThreeFingerSwipe },
                set: { settingsService.settings.enableThreeFingerSwipe = $0 }
            ))
            .help("Swipe up for Mission Control, down for App Switcher")

            Toggle("Four Finger Swipe", isOn: Binding(
                get: { settingsService.settings.enableFourFingerSwipe },
                set: { settingsService.settings.enableFourFingerSwipe = $0 }
            ))
            .help("Swipe left/right to switch desktops")
        }

        SettingsSection(title: "Timing") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Long Press Duration")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Short")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Slider(value: Binding(
                        get: { settingsService.settings.longPressDuration },
                        set: { settingsService.settings.longPressDuration = $0 }
                    ), in: 0.2...1.5, step: 0.1)

                    Text("Long")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Double Tap Interval")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Fast")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Slider(value: Binding(
                        get: { settingsService.settings.doubleTapInterval },
                        set: { settingsService.settings.doubleTapInterval = $0 }
                    ), in: 0.15...0.5, step: 0.05)

                    Text("Slow")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Window Settings
struct WindowSettingsView: View {
    @EnvironmentObject var settingsService: SettingsService

    var body: some View {
        SettingsSection(title: "Window Snapping") {
            Toggle("Enable Window Snap", isOn: $settingsService.enableWindowSnap)
                .help("Drag windows to edges to snap them")

            VStack(alignment: .leading, spacing: 8) {
                Text("Default Snap Positions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(SnapPosition.allCases, id: \.self) { position in
                        SnapPositionToggle(position: position)
                    }
                }
            }
        }

        SettingsSection(title: "Window Behavior") {
            Toggle("Animate Window Changes", isOn: Binding(
                get: { settingsService.settings.animationDuration > 0 },
                set: { settingsService.settings.animationDuration = $0 ? 0.25 : 0 }
            ))

            VStack(alignment: .leading, spacing: 8) {
                Text("Animation Duration")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Fast")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Slider(value: Binding(
                        get: { settingsService.settings.animationDuration },
                        set: { settingsService.settings.animationDuration = $0 }
                    ), in: 0...0.5, step: 0.05)

                    Text("Slow")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Input Settings
struct InputSettingsView: View {
    @EnvironmentObject var settingsService: SettingsService

    var body: some View {
        SettingsSection(title: "Virtual Trackpad") {
            Toggle("Enable Virtual Trackpad", isOn: $settingsService.enableVirtualTrackpad)
                .help("Show on-screen trackpad for precise cursor control")
        }

        SettingsSection(title: "Virtual Keyboard") {
            Toggle("Enable Virtual Keyboard", isOn: $settingsService.enableVirtualKeyboard)
                .help("Show on-screen keyboard with macOS shortcuts")

            Picker("Keyboard Layout", selection: Binding(
                get: { settingsService.settings.keyboardLayout },
                set: { settingsService.settings.keyboardLayout = $0 }
            )) {
                ForEach(KeyboardLayout.allCases) { layout in
                    Text(layout.rawValue).tag(layout)
                }
            }
            .pickerStyle(.segmented)

            Picker("Keyboard Size", selection: Binding(
                get: { settingsService.settings.keyboardSize },
                set: { settingsService.settings.keyboardSize = $0 }
            )) {
                ForEach(KeyboardSize.allCases) { size in
                    Text(size.rawValue).tag(size)
                }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 8) {
                Text("Keyboard Opacity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Slider(value: Binding(
                    get: { settingsService.settings.keyboardOpacity },
                    set: { settingsService.settings.keyboardOpacity = $0 }
                ), in: 0.5...1.0, step: 0.05)
            }
        }
    }
}

// MARK: - Appearance Settings
struct AppearanceSettingsView: View {
    @EnvironmentObject var settingsService: SettingsService

    var body: some View {
        SettingsSection(title: "Theme") {
            Picker("App Theme", selection: $settingsService.theme) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.rawValue).tag(theme)
                }
            }
            .pickerStyle(.segmented)
        }

        SettingsSection(title: "Accent Color") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                ForEach(Color.touchAccentColors.sorted(by: { $0.key < $1.key }), id: \.key) { name, color in
                    AccentColorButton(
                        name: name,
                        color: color,
                        isSelected: settingsService.accentColor == name
                    ) {
                        settingsService.accentColor = name
                    }
                }
            }
        }

        SettingsSection(title: "Corner Radius") {
            VStack(alignment: .leading, spacing: 8) {
                Text("UI Corner Radius")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Sharp")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Slider(value: Binding(
                        get: { settingsService.settings.cornerRadius },
                        set: { settingsService.settings.cornerRadius = $0 }
                    ), in: 0...24, step: 2)

                    Text("Rounded")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Advanced Settings
struct AdvancedSettingsView: View {
    @EnvironmentObject var settingsService: SettingsService

    var body: some View {
        SettingsSection(title: "Feedback") {
            Toggle("Haptic Feedback", isOn: Binding(
                get: { settingsService.settings.hapticFeedbackEnabled },
                set: { settingsService.settings.hapticFeedbackEnabled = $0 }
            ))

            Toggle("Sound Feedback", isOn: Binding(
                get: { settingsService.settings.soundFeedbackEnabled },
                set: { settingsService.settings.soundFeedbackEnabled = $0 }
            ))
        }

        SettingsSection(title: "Overlay") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Overlay Opacity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Slider(value: Binding(
                    get: { settingsService.settings.overlayOpacity },
                    set: { settingsService.settings.overlayOpacity = $0 }
                ), in: 0.3...1.0, step: 0.05)
            }
        }

        SettingsSection(title: "Accessibility") {
            Button("Open Accessibility Settings") {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
            .help("Grant accessibility permissions for window management")

            Button("Check Permissions") {
                checkAccessibilityPermissions()
            }
        }

        SettingsSection(title: "Debug") {
            Button("Refresh Windows") {
                WindowManager.shared.refreshWindows()
            }

            Button("Show Touch Zones") {
                // Debug action
            }
        }
    }

    private func checkAccessibilityPermissions() {
        let trusted = AXIsProcessTrusted()
        let alert = NSAlert()
        alert.messageText = trusted ? "Accessibility Enabled" : "Accessibility Not Enabled"
        alert.informativeText = trusted ? "TouchyOS has accessibility access." : "Please grant accessibility access in System Settings."
        alert.runModal()
    }
}

// MARK: - Helper Views
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
        }
    }
}

struct SnapPositionToggle: View {
    let position: SnapPosition
    @EnvironmentObject var settingsService: SettingsService

    var isEnabled: Bool {
        settingsService.settings.defaultSnapPositions.contains(position)
    }

    var body: some View {
        Button(action: {
            var positions = settingsService.settings.defaultSnapPositions
            if positions.contains(position) {
                positions.removeAll { $0 == position }
            } else {
                positions.append(position)
            }
            settingsService.settings.defaultSnapPositions = positions
        }) {
            VStack(spacing: 4) {
                Image(systemName: position.icon)
                    .font(.title3)
                Text(position.shortName)
                    .font(.caption2)
            }
            .foregroundColor(isEnabled ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isEnabled ? Color.accentColor : Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// SnapPosition already conforms to CaseIterable via the enum declaration

extension SnapPosition {
    var icon: String {
        switch self {
        case .leftHalf: return "rectangle.lefthalf.filled"
        case .rightHalf: return "rectangle.righthalf.filled"
        case .topHalf: return "rectangle.tophalf.filled"
        case .bottomHalf: return "rectangle.bottomhalf.filled"
        case .topLeft: return "square.topleft.filled"
        case .topRight: return "square.topright.filled"
        case .bottomLeft: return "square.bottomleft.filled"
        case .bottomRight: return "square.bottomright.filled"
        case .fullScreen: return "rectangle.fill"
        case .center: return "square.dashed"
        case .leftThird: return "rectangle.split.3x1.fill"
        case .centerThird: return "rectangle.split.3x1"
        case .rightThird: return "rectangle.split.3x1.fill"
        }
    }

    var shortName: String {
        switch self {
        case .leftHalf: return "Left"
        case .rightHalf: return "Right"
        case .topHalf: return "Top"
        case .bottomHalf: return "Bottom"
        case .topLeft: return "TL"
        case .topRight: return "TR"
        case .bottomLeft: return "BL"
        case .bottomRight: return "BR"
        case .fullScreen: return "Full"
        case .center: return "Center"
        case .leftThird: return "⅓L"
        case .centerThird: return "⅓C"
        case .rightThird: return "⅓R"
        }
    }
}

struct AccentColorButton: View {
    let name: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 3)
                )
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundColor(color.isDark ? .white : .black)
                        .opacity(isSelected ? 1 : 0)
                )
        }
        .buttonStyle(.plain)
    }
}

extension Color {
    var isDark: Bool {
        // Simple luminance check
        let nsColor = NSColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance < 0.5
    }
}