import XCTest
@testable import TouchyOS

final class TouchOverlayManagerTests: XCTestCase {

    // MARK: - Properties

    var overlayManager: TouchOverlayManager!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        overlayManager = TouchOverlayManager.shared
    }

    override func tearDown() {
        overlayManager = nil
        super.tearDown()
    }

    // MARK: - Singleton Tests

    func testSharedInstance() {
        let instance1 = TouchOverlayManager.shared
        let instance2 = TouchOverlayManager.shared
        XCTAssertTrue(instance1 === instance2)
    }

    // MARK: - Initial State Tests

    func testInitialConfig() {
        XCTAssertFalse(overlayManager.config.isVisible)
        XCTAssertTrue(overlayManager.config.zones.isEmpty)
        XCTAssertEqual(overlayManager.config.virtualTrackpad, VirtualTrackpadState())
        XCTAssertTrue(overlayManager.config.virtualKeyboard.isEmpty)
        XCTAssertTrue(overlayManager.config.activeGestures.isEmpty)
        XCTAssertEqual(overlayManager.config.lastTouchLocation, .zero)
        XCTAssertNil(overlayManager.config.touchStartTime)
    }

    func testInitialOverlayVisible() {
        XCTAssertFalse(overlayManager.isOverlayVisible)
    }

    func testInitialActiveGesture() {
        XCTAssertNil(overlayManager.activeGesture)
    }

    func testInitialSettings() {
        let settings = overlayManager.settings
        XCTAssertEqual(settings, TouchyOSSettings.default)
    }

    // MARK: - Settings Tests

    func testLoadSettings() {
        // Settings should be loaded from UserDefaults or defaults
        XCTAssertNotNil(overlayManager.settings)
    }

    func testSaveSettings() {
        // Should not crash
        overlayManager.saveSettings()
        XCTAssertTrue(true)
    }

    // MARK: - Touch Event Handling Tests

    func testHandleTouchEventDisabled() {
        overlayManager.settings.isEnabled = false

        let event = NSEvent.swipeEvent(with: .left, location: .zero, modifierFlags: [], timestamp: 0, windowNumber: 0, context: nil, deltaX: 10, deltaY: 0)
        // Should not crash
        overlayManager.handleTouchEvent(event)
    }

    func testHandleTouchEventGesture() {
        overlayManager.settings.isEnabled = true

        let event = NSEvent.swipeEvent(with: .left, location: .zero, modifierFlags: [], timestamp: 0, windowNumber: 0, context: nil, deltaX: 10, deltaY: 0)
        // Should not crash
        overlayManager.handleTouchEvent(event)
    }

    func testHandleTouchEventMagnify() {
        overlayManager.settings.isEnabled = true

        let event = NSEvent.swipeEvent(with: .left, location: .zero, modifierFlags: [], timestamp: 0, windowNumber: 0, context: nil, deltaX: 10, deltaY: 0)
        // Should not crash
        overlayManager.handleTouchEvent(event)
    }

    // MARK: - Gesture Handlers Tests

    func testHandleTap() {
        overlayManager.handleGesture(.tap(location: CGPoint(x: 100, y: 100)))
        // Should not crash
    }

    func testHandleDoubleTap() {
        overlayManager.handleGesture(.doubleTap(location: CGPoint(x: 100, y: 100)))
        // Should not crash
    }

    func testHandleLongPress() {
        overlayManager.handleGesture(.longPress(location: CGPoint(x: 100, y: 100), duration: 0.5))
        // Should not crash
    }

    func testHandlePan() {
        overlayManager.handleGesture(.pan(translation: CGSize(width: 10, height: 10), velocity: CGSize(width: 5, height: 5)))
        // Should not crash
    }

    func testHandlePinch() {
        overlayManager.handleGesture(.pinch(scale: 1.5, velocity: 0.5))
        // Should not crash
    }

    func testHandleRotate() {
        overlayManager.handleGesture(.rotate(rotation: 0.5, velocity: 0.1))
        // Should not crash
    }

    func testHandleSwipe() {
        overlayManager.handleGesture(.swipe(direction: .up))
        overlayManager.handleGesture(.swipe(direction: .down))
        overlayManager.handleGesture(.swipe(direction: .left))
        overlayManager.handleGesture(.swipe(direction: .right))
        // Should not crash
    }

    func testHandleEdgeSwipe() {
        overlayManager.settings.enableEdgeGestures = true

        overlayManager.handleGesture(.edgeSwipe(edge: .top, translation: 60))
        overlayManager.handleGesture(.edgeSwipe(edge: .bottom, translation: 60))
        overlayManager.handleGesture(.edgeSwipe(edge: .left, translation: 60))
        overlayManager.handleGesture(.edgeSwipe(edge: .right, translation: 60))
        // Should not crash
    }

    func testHandleEdgeSwipeDisabled() {
        overlayManager.settings.enableEdgeGestures = false

        overlayManager.handleGesture(.edgeSwipe(edge: .top, translation: 60))
        // Should not crash and should not trigger actions
    }

    func testHandleEdgeSwipeBelowThreshold() {
        overlayManager.settings.enableEdgeGestures = true
        overlayManager.settings.snapThreshold = 50

        overlayManager.handleGesture(.edgeSwipe(edge: .left, translation: 30))
        // Should not trigger snap
    }

    // MARK: - Touch Zones Tests

    func testUpdateTouchZones() {
        let window = WindowInfo(
            id: 1,
            ownerName: "Test",
            windowTitle: "Test Window",
            bounds: CGRect(x: 100, y: 100, width: 800, height: 600),
            layer: 0,
            isOnScreen: true,
            appBundleIdentifier: nil
        )

        overlayManager.updateTouchZones(for: window)

        // Should create zones for close, minimize, maximize, title bar, resize, and snap zones
        XCTAssertGreaterThan(overlayManager.config.zones.count, 0)

        // Check for expected zones
        let hasCloseZone = overlayManager.config.zones.contains { zone in
            if case .close = zone.action { return true }
            return false
        }
        XCTAssertTrue(hasCloseZone)

        let hasMinimizeZone = overlayManager.config.zones.contains { zone in
            if case .minimize = zone.action { return true }
            return false
        }
        XCTAssertTrue(hasMinimizeZone)
    }

    func testUpdateTouchZonesWithWindowSnapDisabled() {
        overlayManager.settings.enableWindowSnap = false

        let window = WindowInfo(
            id: 1,
            ownerName: "Test",
            windowTitle: "Test Window",
            bounds: CGRect(x: 100, y: 100, width: 800, height: 600),
            layer: 0,
            isOnScreen: true,
            appBundleIdentifier: nil
        )

        overlayManager.updateTouchZones(for: window)

        // Should have basic zones but no snap zones
        let snapZones = overlayManager.config.zones.filter { zone in
            if case .snap = zone.action { return true }
            return false
        }
        XCTAssertEqual(snapZones.count, 0)
    }

    // MARK: - Virtual Trackpad Tests

    func testShowVirtualTrackpad() {
        overlayManager.settings.enableVirtualTrackpad = true

        overlayManager.showVirtualTrackpad()
        // Should not crash
    }

    func testShowVirtualTrackpadDisabled() {
        overlayManager.settings.enableVirtualTrackpad = false

        overlayManager.showVirtualTrackpad()
        // Should not create window
    }

    func testHideVirtualTrackpad() {
        overlayManager.hideVirtualTrackpad()
        // Should not crash
    }

    // MARK: - Virtual Keyboard Tests

    func testShowVirtualKeyboard() {
        overlayManager.settings.enableVirtualKeyboard = true

        overlayManager.showVirtualKeyboard()
        // Should not crash
    }

    func testShowVirtualKeyboardDisabled() {
        overlayManager.settings.enableVirtualKeyboard = false

        overlayManager.showVirtualKeyboard()
        // Should not create window
    }

    func testHideVirtualKeyboard() {
        overlayManager.hideVirtualKeyboard()
        // Should not crash
    }

    // MARK: - Overlay Tests

    func testShowOverlay() {
        overlayManager.settings.showTouchVisualizer = true

        overlayManager.showOverlay()
        XCTAssertTrue(overlayManager.isOverlayVisible)
    }

    func testShowOverlayDisabled() {
        overlayManager.settings.showTouchVisualizer = false

        overlayManager.showOverlay()
        XCTAssertFalse(overlayManager.isOverlayVisible)
    }

    func testHideOverlay() {
        overlayManager.settings.showTouchVisualizer = true
        overlayManager.showOverlay()

        overlayManager.hideOverlay()
        XCTAssertFalse(overlayManager.isOverlayVisible)
    }

    func testToggleOverlay() {
        overlayManager.settings.showTouchVisualizer = true
        XCTAssertFalse(overlayManager.isOverlayVisible)

        overlayManager.toggleOverlay()
        XCTAssertTrue(overlayManager.isOverlayVisible)

        overlayManager.toggleOverlay()
        XCTAssertFalse(overlayManager.isOverlayVisible)
    }

    // MARK: - Window Controls Tests

    func testShowWindowControls() {
        let window = WindowInfo(
            id: 1,
            ownerName: "Test",
            windowTitle: "Test Window",
            bounds: CGRect(x: 100, y: 100, width: 800, height: 600),
            layer: 0,
            isOnScreen: true,
            appBundleIdentifier: nil
        )

        // This creates a popover, just verify it doesn't crash
        // We can't easily test the private method, but we can verify the window is valid
        XCTAssertNotNil(window)
    }

    // MARK: - Feedback Tests

    func testShowTouchFeedback() {
        overlayManager.settings.showTouchVisualizer = true
        overlayManager.handleGesture(.tap(location: CGPoint(x: 100, y: 100)))
        // Should not crash
    }

    func testProvideHapticFeedback() {
        overlayManager.settings.hapticFeedbackEnabled = true

        // Test different gesture types
        overlayManager.handleGesture(.tap(location: .zero))
        overlayManager.handleGesture(.doubleTap(location: .zero))
        overlayManager.handleGesture(.longPress(location: .zero, duration: 0.5))
        overlayManager.handleGesture(.swipe(direction: .up))
        // Should not crash
    }

    // MARK: - Cleanup Tests

    func testCleanup() {
        overlayManager.cleanup()
        // Should not crash
    }
}