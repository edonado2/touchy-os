import Foundation
import SwiftUI

// MARK: - Settings Service
@MainActor
class SettingsService: ObservableObject {
    static let shared = SettingsService()

    @Published var settings: TouchyOSSettings = .default {
        didSet {
            saveSettings()
            applySettings()
        }
    }

    private init() {
        loadSettings()
    }

    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "TouchyOSSettings"),
           let decoded = try? JSONDecoder().decode(TouchyOSSettings.self, from: data) {
            self.settings = decoded
        }
    }

    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "TouchyOSSettings")
        }
    }

    private func applySettings() {
        // Apply settings to managers
        TouchOverlayManager.shared.settings = settings
        TouchOverlayManager.shared.saveSettings()

        // Update window manager settings
        // WindowManager.shared.updateSettings(settings)
    }

    func resetToDefaults() {
        settings = .default
    }

    // MARK: - Convenience Properties
    var isEnabled: Bool {
        get { settings.isEnabled }
        set { settings.isEnabled = newValue }
    }

    var touchSensitivity: CGFloat {
        get { settings.touchSensitivity }
        set { settings.touchSensitivity = newValue }
    }

    var gestureSensitivity: CGFloat {
        get { settings.gestureSensitivity }
        set { settings.gestureSensitivity = newValue }
    }

    var showTouchVisualizer: Bool {
        get { settings.showTouchVisualizer }
        set { settings.showTouchVisualizer = newValue }
    }

    var enableVirtualTrackpad: Bool {
        get { settings.enableVirtualTrackpad }
        set { settings.enableVirtualTrackpad = newValue }
    }

    var enableVirtualKeyboard: Bool {
        get { settings.enableVirtualKeyboard }
        set { settings.enableVirtualKeyboard = newValue }
    }

    var enableEdgeGestures: Bool {
        get { settings.enableEdgeGestures }
        set { settings.enableEdgeGestures = newValue }
    }

    var enableWindowSnap: Bool {
        get { settings.enableWindowSnap }
        set { settings.enableWindowSnap = newValue }
    }

    var theme: AppTheme {
        get { settings.theme }
        set { settings.theme = newValue }
    }

    var accentColor: String {
        get { settings.accentColor }
        set { settings.accentColor = newValue }
    }
}

// MARK: - Color Extension for Accent Colors
extension Color {
    static let touchAccentColors: [String: Color] = [
        "blue": .blue,
        "purple": .purple,
        "pink": .pink,
        "red": .red,
        "orange": .orange,
        "yellow": .yellow,
        "green": .green,
        "mint": .mint,
        "teal": .teal,
        "cyan": .cyan,
        "indigo": .indigo,
        "gray": .gray
    ]

    static func accentColor(from name: String) -> Color {
        return touchAccentColors[name] ?? .blue
    }
}