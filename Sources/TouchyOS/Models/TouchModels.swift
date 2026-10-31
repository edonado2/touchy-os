import Foundation
import AppKit
import Carbon

// MARK: - Window Model
struct WindowInfo: Identifiable, Equatable {
    let id: CGWindowID
    let ownerName: String
    let windowTitle: String
    let bounds: CGRect
    let layer: Int
    let isOnScreen: Bool
    let appBundleIdentifier: String?

    var displayTitle: String {
        return windowTitle.isEmpty ? ownerName : "\(ownerName) - \(windowTitle)"
    }

    var appIcon: NSImage? {
        guard let bundleId = appBundleIdentifier,
              let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            return NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kGenericApplicationIcon)))
        }
        return NSWorkspace.shared.icon(forFile: appUrl.path)
    }
}

// MARK: - Touch Gesture Types
enum TouchGestureType {
    case tap(location: CGPoint)
    case doubleTap(location: CGPoint)
    case longPress(location: CGPoint, duration: TimeInterval)
    case pan(translation: CGPoint, velocity: CGPoint)
    case pinch(scale: CGFloat, velocity: CGFloat)
    case rotate(rotation: CGFloat, velocity: CGFloat)
    case swipe(direction: SwipeDirection)
    case edgeSwipe(edge: Edge, translation: CGFloat)
}

enum SwipeDirection {
    case up, down, left, right
}

enum Edge {
    case top, bottom, left, right
}

// MARK: - Window Management Actions
enum WindowAction {
    case close(windowId: CGWindowID)
    case minimize(windowId: CGWindowID)
    case maximize(windowId: CGWindowID)
    case move(windowId: CGWindowID, to: CGPoint)
    case resize(windowId: CGWindowID, to: CGSize)
    case snap(windowId: CGWindowID, to: SnapPosition)
    case bringToFront(windowId: CGWindowID)
    case sendToBack(windowId: CGWindowID)
    case toggleFullscreen(windowId: CGWindowID)
    case switchToApp(bundleId: String)
    case showAppSwitcher
    case showMissionControl
    case showLaunchpad
}

enum SnapPosition: String, Codable, CaseIterable {
    case leftHalf
    case rightHalf
    case topHalf
    case bottomHalf
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case fullScreen
    case center
    case leftThird
    case centerThird
    case rightThird
}

// MARK: - Touch Zone
struct TouchZone: Identifiable {
    let id = UUID()
    let frame: CGRect
    let action: WindowAction
    let gestureType: TouchGestureType
    var isActive: Bool = false
}

// MARK: - Virtual Input
struct VirtualKey: Identifiable {
    let id = UUID()
    let key: String
    let display: String
    let modifiers: NSEvent.ModifierFlags
    let frame: CGRect
    var isPressed: Bool = false
}

struct VirtualTrackpadState {
    var isActive: Bool = false
    var startLocation: CGPoint = .zero
    var currentLocation: CGPoint = .zero
    var isClicking: Bool = false
    var scrollAccumulator: CGPoint = .zero
}

// MARK: - Settings
struct TouchyOSSettings: Codable {
    var isEnabled: Bool = true
    var touchSensitivity: CGFloat = 1.0
    var gestureSensitivity: CGFloat = 1.0
    var showTouchVisualizer: Bool = true
    var enableVirtualTrackpad: Bool = true
    var enableVirtualKeyboard: Bool = true
    var enableEdgeGestures: Bool = true
    var enableWindowSnap: Bool = true
    var snapThreshold: CGFloat = 50
    var longPressDuration: TimeInterval = 0.5
    var doubleTapInterval: TimeInterval = 0.3
    var menuBarIconSize: CGFloat = 22
    var overlayOpacity: CGFloat = 0.8
    var hapticFeedbackEnabled: Bool = true
    var soundFeedbackEnabled: Bool = false

    // Window management
    var defaultSnapPositions: [SnapPosition] = [.leftHalf, .rightHalf, .fullScreen]
    var enableThreeFingerSwipe: Bool = true
    var enableFourFingerSwipe: Bool = true

    // Virtual keyboard
    var keyboardLayout: KeyboardLayout = .standard
    var keyboardSize: KeyboardSize = .medium
    var keyboardOpacity: CGFloat = 0.9

    // Appearance
    var theme: AppTheme = .system
    var accentColor: String = "blue"
    var cornerRadius: CGFloat = 12
    var animationDuration: Double = 0.25

    static let `default` = TouchyOSSettings()
}

enum KeyboardLayout: String, Codable, CaseIterable, Identifiable {
    case standard = "Standard"
    case compact = "Compact"
    case split = "Split"
    case macShortcuts = "Mac Shortcuts"

    var id: String { rawValue }
}

enum KeyboardSize: String, Codable, CaseIterable, Identifiable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"

    var id: String { rawValue }
}

enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"

    var id: String { rawValue }
}

// MARK: - Touch Overlay Configuration
struct TouchOverlayConfig {
    var isVisible: Bool = false
    var zones: [TouchZone] = []
    var virtualTrackpad: VirtualTrackpadState = VirtualTrackpadState()
    var virtualKeyboard: [VirtualKey] = []
    var activeGestures: [TouchGestureType] = []
    var lastTouchLocation: CGPoint = .zero
    var touchStartTime: Date?
}