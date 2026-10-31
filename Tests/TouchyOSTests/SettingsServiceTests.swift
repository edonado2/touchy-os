import XCTest
@testable import TouchyOS

final class SettingsServiceTests: XCTestCase {

    // MARK: - Properties

    var settingsService: SettingsService!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        // Use a fresh instance for each test
        // Note: SettingsService is a singleton, so we'll test the shared instance
        settingsService = SettingsService.shared
        // Reset to defaults before each test
        settingsService.resetToDefaults()
    }

    override func tearDown() {
        settingsService = nil
        super.tearDown()
    }

    // MARK: - Singleton Tests

    func testSharedInstance() {
        let instance1 = SettingsService.shared
        let instance2 = SettingsService.shared
        XCTAssertTrue(instance1 === instance2)
    }

    // MARK: - Default Settings Tests

    func testDefaultSettings() {
        XCTAssertTrue(settingsService.isEnabled)
        XCTAssertEqual(settingsService.touchSensitivity, 1.0)
        XCTAssertEqual(settingsService.gestureSensitivity, 1.0)
        XCTAssertTrue(settingsService.showTouchVisualizer)
        XCTAssertTrue(settingsService.enableVirtualTrackpad)
        XCTAssertTrue(settingsService.enableVirtualKeyboard)
        XCTAssertTrue(settingsService.enableEdgeGestures)
        XCTAssertTrue(settingsService.enableWindowSnap)
        XCTAssertEqual(settingsService.settings.snapThreshold, 50)
        XCTAssertEqual(settingsService.settings.longPressDuration, 0.5)
        XCTAssertEqual(settingsService.settings.doubleTapInterval, 0.3)
    }

    // MARK: - isEnabled Tests

    func testIsEnabledToggle() {
        XCTAssertTrue(settingsService.isEnabled)

        settingsService.isEnabled = false
        XCTAssertFalse(settingsService.isEnabled)
        XCTAssertFalse(settingsService.settings.isEnabled)

        settingsService.isEnabled = true
        XCTAssertTrue(settingsService.isEnabled)
        XCTAssertTrue(settingsService.settings.isEnabled)
    }

    // MARK: - Touch Sensitivity Tests

    func testTouchSensitivityRange() {
        settingsService.touchSensitivity = 0.5
        XCTAssertEqual(settingsService.touchSensitivity, 0.5)

        settingsService.touchSensitivity = 2.0
        XCTAssertEqual(settingsService.touchSensitivity, 2.0)
    }

    // MARK: - Gesture Sensitivity Tests

    func testGestureSensitivityRange() {
        settingsService.gestureSensitivity = 0.5
        XCTAssertEqual(settingsService.gestureSensitivity, 0.5)

        settingsService.gestureSensitivity = 2.0
        XCTAssertEqual(settingsService.gestureSensitivity, 2.0)
    }

    // MARK: - Show Touch Visualizer Tests

    func testShowTouchVisualizerToggle() {
        XCTAssertTrue(settingsService.showTouchVisualizer)

        settingsService.showTouchVisualizer = false
        XCTAssertFalse(settingsService.showTouchVisualizer)
        XCTAssertFalse(settingsService.settings.showTouchVisualizer)
    }

    // MARK: - Virtual Trackpad Tests

    func testEnableVirtualTrackpadToggle() {
        XCTAssertTrue(settingsService.enableVirtualTrackpad)

        settingsService.enableVirtualTrackpad = false
        XCTAssertFalse(settingsService.enableVirtualTrackpad)
        XCTAssertFalse(settingsService.settings.enableVirtualTrackpad)
    }

    // MARK: - Virtual Keyboard Tests

    func testEnableVirtualKeyboardToggle() {
        XCTAssertTrue(settingsService.enableVirtualKeyboard)

        settingsService.enableVirtualKeyboard = false
        XCTAssertFalse(settingsService.enableVirtualKeyboard)
        XCTAssertFalse(settingsService.settings.enableVirtualKeyboard)
    }

    // MARK: - Edge Gestures Tests

    func testEnableEdgeGesturesToggle() {
        XCTAssertTrue(settingsService.enableEdgeGestures)

        settingsService.enableEdgeGestures = false
        XCTAssertFalse(settingsService.enableEdgeGestures)
        XCTAssertFalse(settingsService.settings.enableEdgeGestures)
    }

    // MARK: - Window Snap Tests

    func testEnableWindowSnapToggle() {
        XCTAssertTrue(settingsService.enableWindowSnap)

        settingsService.enableWindowSnap = false
        XCTAssertFalse(settingsService.enableWindowSnap)
        XCTAssertFalse(settingsService.settings.enableWindowSnap)
    }

    // MARK: - Theme Tests

    func testThemeChange() {
        XCTAssertEqual(settingsService.theme, .system)

        settingsService.theme = .light
        XCTAssertEqual(settingsService.theme, .light)
        XCTAssertEqual(settingsService.settings.theme, .light)

        settingsService.theme = .dark
        XCTAssertEqual(settingsService.theme, .dark)
        XCTAssertEqual(settingsService.settings.theme, .dark)
    }

    // MARK: - Accent Color Tests

    func testAccentColorChange() {
        XCTAssertEqual(settingsService.accentColor, "blue")

        settingsService.accentColor = "red"
        XCTAssertEqual(settingsService.accentColor, "red")
        XCTAssertEqual(settingsService.settings.accentColor, "red")

        settingsService.accentColor = "green"
        XCTAssertEqual(settingsService.accentColor, "green")
    }

    // MARK: - Corner Radius Tests

    func testCornerRadiusRange() {
        settingsService.settings.cornerRadius = 0
        XCTAssertEqual(settingsService.settings.cornerRadius, 0)

        settingsService.settings.cornerRadius = 24
        XCTAssertEqual(settingsService.settings.cornerRadius, 24)
    }

    // MARK: - Animation Duration Tests

    func testAnimationDurationRange() {
        settingsService.settings.animationDuration = 0
        XCTAssertEqual(settingsService.settings.animationDuration, 0)

        settingsService.settings.animationDuration = 0.5
        XCTAssertEqual(settingsService.settings.animationDuration, 0.5)
    }

    // MARK: - Keyboard Layout Tests

    func testKeyboardLayoutChange() {
        XCTAssertEqual(settingsService.settings.keyboardLayout, .standard)

        settingsService.settings.keyboardLayout = .compact
        XCTAssertEqual(settingsService.settings.keyboardLayout, .compact)

        settingsService.settings.keyboardLayout = .split
        XCTAssertEqual(settingsService.settings.keyboardLayout, .split)

        settingsService.settings.keyboardLayout = .macShortcuts
        XCTAssertEqual(settingsService.settings.keyboardLayout, .macShortcuts)
    }

    // MARK: - Keyboard Size Tests

    func testKeyboardSizeChange() {
        XCTAssertEqual(settingsService.settings.keyboardSize, .medium)

        settingsService.settings.keyboardSize = .small
        XCTAssertEqual(settingsService.settings.keyboardSize, .small)

        settingsService.settings.keyboardSize = .large
        XCTAssertEqual(settingsService.settings.keyboardSize, .large)
    }

    // MARK: - Keyboard Opacity Tests

    func testKeyboardOpacityRange() {
        settingsService.settings.keyboardOpacity = 0.5
        XCTAssertEqual(settingsService.settings.keyboardOpacity, 0.5)

        settingsService.settings.keyboardOpacity = 1.0
        XCTAssertEqual(settingsService.settings.keyboardOpacity, 1.0)
    }

    // MARK: - Overlay Opacity Tests

    func testOverlayOpacityRange() {
        settingsService.settings.overlayOpacity = 0.3
        XCTAssertEqual(settingsService.settings.overlayOpacity, 0.3)

        settingsService.settings.overlayOpacity = 1.0
        XCTAssertEqual(settingsService.settings.overlayOpacity, 1.0)
    }

    // MARK: - Haptic Feedback Tests

    func testHapticFeedbackToggle() {
        XCTAssertTrue(settingsService.settings.hapticFeedbackEnabled)

        settingsService.settings.hapticFeedbackEnabled = false
        XCTAssertFalse(settingsService.settings.hapticFeedbackEnabled)
    }

    // MARK: - Sound Feedback Tests

    func testSoundFeedbackToggle() {
        XCTAssertFalse(settingsService.settings.soundFeedbackEnabled)

        settingsService.settings.soundFeedbackEnabled = true
        XCTAssertTrue(settingsService.settings.soundFeedbackEnabled)
    }

    // MARK: - Three/Four Finger Swipe Tests

    func testThreeFingerSwipeToggle() {
        XCTAssertTrue(settingsService.settings.enableThreeFingerSwipe)

        settingsService.settings.enableThreeFingerSwipe = false
        XCTAssertFalse(settingsService.settings.enableThreeFingerSwipe)
    }

    func testFourFingerSwipeToggle() {
        XCTAssertTrue(settingsService.settings.enableFourFingerSwipe)

        settingsService.settings.enableFourFingerSwipe = false
        XCTAssertFalse(settingsService.settings.enableFourFingerSwipe)
    }

    // MARK: - Reset to Defaults Tests

    func testResetToDefaults() {
        // Change multiple settings
        settingsService.isEnabled = false
        settingsService.touchSensitivity = 2.0
        settingsService.theme = .light
        settingsService.accentColor = "red"
        settingsService.settings.keyboardLayout = .compact

        // Reset
        settingsService.resetToDefaults()

        // Verify all back to defaults
        XCTAssertTrue(settingsService.isEnabled)
        XCTAssertEqual(settingsService.touchSensitivity, 1.0)
        XCTAssertEqual(settingsService.theme, .system)
        XCTAssertEqual(settingsService.accentColor, "blue")
        XCTAssertEqual(settingsService.settings.keyboardLayout, .standard)
    }

    // MARK: - Persistence Tests

    func testSettingsPersistence() {
        // Change a setting
        settingsService.isEnabled = false
        settingsService.touchSensitivity = 1.5

        // Create a new instance (simulates app restart)
        // Since it's a singleton, we can't easily test this, but we can verify the data was saved
        let userDefaults = UserDefaults.standard
        let data = userDefaults.data(forKey: "TouchyOSSettings")
        XCTAssertNotNil(data)

        if let data = data,
           let decoded = try? JSONDecoder().decode(TouchyOSSettings.self, from: data) {
            XCTAssertFalse(decoded.isEnabled)
            XCTAssertEqual(decoded.touchSensitivity, 1.5)
        } else {
            XCTFail("Settings should be persisted")
        }
    }

    // MARK: - Snap Threshold Tests

    func testSnapThresholdRange() {
        settingsService.settings.snapThreshold = 20
        XCTAssertEqual(settingsService.settings.snapThreshold, 20)

        settingsService.settings.snapThreshold = 200
        XCTAssertEqual(settingsService.settings.snapThreshold, 200)
    }

    // MARK: - Long Press Duration Tests

    func testLongPressDurationRange() {
        settingsService.settings.longPressDuration = 0.2
        XCTAssertEqual(settingsService.settings.longPressDuration, 0.2)

        settingsService.settings.longPressDuration = 1.5
        XCTAssertEqual(settingsService.settings.longPressDuration, 1.5)
    }

    // MARK: - Double Tap Interval Tests

    func testDoubleTapIntervalRange() {
        settingsService.settings.doubleTapInterval = 0.15
        XCTAssertEqual(settingsService.settings.doubleTapInterval, 0.15)

        settingsService.settings.doubleTapInterval = 0.5
        XCTAssertEqual(settingsService.settings.doubleTapInterval, 0.5)
    }

    // MARK: - Default Snap Positions Tests

    func testDefaultSnapPositionsModification() {
        var positions = settingsService.settings.defaultSnapPositions
        positions.append(.topHalf)
        settingsService.settings.defaultSnapPositions = positions

        XCTAssertEqual(settingsService.settings.defaultSnapPositions.count, 4)
        XCTAssertTrue(settingsService.settings.defaultSnapPositions.contains(.topHalf))
    }
}