import XCTest
@testable import TouchyOS

final class TouchModelsTests: XCTestCase {

    // MARK: - WindowInfo Tests

    func testWindowInfoCreation() {
        let window = WindowInfo(
            id: 12345,
            ownerName: "TestApp",
            windowTitle: "Test Window",
            bounds: CGRect(x: 100, y: 100, width: 800, height: 600),
            layer: 0,
            isOnScreen: true,
            appBundleIdentifier: "com.test.app"
        )

        XCTAssertEqual(window.id, 12345)
        XCTAssertEqual(window.ownerName, "TestApp")
        XCTAssertEqual(window.windowTitle, "Test Window")
        XCTAssertEqual(window.bounds, CGRect(x: 100, y: 100, width: 800, height: 600))
        XCTAssertEqual(window.layer, 0)
        XCTAssertTrue(window.isOnScreen)
        XCTAssertEqual(window.appBundleIdentifier, "com.test.app")
    }

    func testWindowInfoDisplayTitle() {
        let windowWithTitle = WindowInfo(
            id: 1, ownerName: "Safari", windowTitle: "Google Search",
            bounds: .zero, layer: 0, isOnScreen: true, appBundleIdentifier: nil
        )
        XCTAssertEqual(windowWithTitle.displayTitle, "Safari - Google Search")

        let windowWithoutTitle = WindowInfo(
            id: 2, ownerName: "Finder", windowTitle: "",
            bounds: .zero, layer: 0, isOnScreen: true, appBundleIdentifier: nil
        )
        XCTAssertEqual(windowWithoutTitle.displayTitle, "Finder")
    }

    func testWindowInfoEquatable() {
        let window1 = WindowInfo(id: 1, ownerName: "A", windowTitle: "T", bounds: .zero, layer: 0, isOnScreen: true, appBundleIdentifier: nil)
        let window2 = WindowInfo(id: 1, ownerName: "B", windowTitle: "T", bounds: .zero, layer: 0, isOnScreen: true, appBundleIdentifier: nil)
        let window3 = WindowInfo(id: 2, ownerName: "A", windowTitle: "T", bounds: .zero, layer: 0, isOnScreen: true, appBundleIdentifier: nil)

        XCTAssertEqual(window1, window2) // Same ID
        XCTAssertNotEqual(window1, window3) // Different ID
    }

    // MARK: - SnapPosition Tests

    func testSnapPositionAllCases() {
        let allCases = SnapPosition.allCases
        XCTAssertEqual(allCases.count, 13)

        let expectedCases: [SnapPosition] = [
            .leftHalf, .rightHalf, .topHalf, .bottomHalf,
            .topLeft, .topRight, .bottomLeft, .bottomRight,
            .fullScreen, .center, .leftThird, .centerThird, .rightThird
        ]

        for expected in expectedCases {
            XCTAssertTrue(allCases.contains(expected))
        }
    }

    func testSnapPositionRawValues() {
        XCTAssertEqual(SnapPosition.leftHalf.rawValue, "leftHalf")
        XCTAssertEqual(SnapPosition.rightHalf.rawValue, "rightHalf")
        XCTAssertEqual(SnapPosition.fullScreen.rawValue, "fullScreen")
        XCTAssertEqual(SnapPosition.center.rawValue, "center")
        XCTAssertEqual(SnapPosition.leftThird.rawValue, "leftThird")
        XCTAssertEqual(SnapPosition.centerThird.rawValue, "centerThird")
        XCTAssertEqual(SnapPosition.rightThird.rawValue, "rightThird")
    }

    func testSnapPositionCodable() throws {
        let position = SnapPosition.leftHalf
        let encoder = JSONEncoder()
        let data = try encoder.encode(position)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SnapPosition.self, from: data)
        XCTAssertEqual(position, decoded)
    }

    func testSnapPositionIdentifiable() {
        let position = SnapPosition.leftHalf
        XCTAssertEqual(position.id, "leftHalf")
    }

    func testSnapPositionIcon() {
        XCTAssertEqual(SnapPosition.leftHalf.icon, "rectangle.lefthalf.filled")
        XCTAssertEqual(SnapPosition.rightHalf.icon, "rectangle.righthalf.filled")
        XCTAssertEqual(SnapPosition.fullScreen.icon, "rectangle.fill")
        XCTAssertEqual(SnapPosition.center.icon, "square.dashed")
    }

    func testSnapPositionShortName() {
        XCTAssertEqual(SnapPosition.leftHalf.shortName, "Left")
        XCTAssertEqual(SnapPosition.rightHalf.shortName, "Right")
        XCTAssertEqual(SnapPosition.fullScreen.shortName, "Full")
        XCTAssertEqual(SnapPosition.center.shortName, "Center")
        XCTAssertEqual(SnapPosition.leftThird.shortName, "⅓L")
        XCTAssertEqual(SnapPosition.centerThird.shortName, "⅓C")
        XCTAssertEqual(SnapPosition.rightThird.shortName, "⅓R")
    }

    // MARK: - TouchGestureType Tests

    func testTouchGestureTypeEquality() {
        let tap1 = TouchGestureType.tap(location: CGPoint(x: 100, y: 200))
        let tap2 = TouchGestureType.tap(location: CGPoint(x: 100, y: 200))
        let tap3 = TouchGestureType.tap(location: CGPoint(x: 150, y: 200))

        XCTAssertEqual(tap1, tap2)
        XCTAssertNotEqual(tap1, tap3)
    }

    func testTouchGestureTypeCases() {
        let tap = TouchGestureType.tap(location: .zero)
        let doubleTap = TouchGestureType.doubleTap(location: .zero)
        let longPress = TouchGestureType.longPress(location: .zero, duration: 0.5)
        let pan = TouchGestureType.pan(translation: CGSize(width: 10, height: 10), velocity: CGSize(width: 5, height: 5))
        let pinch = TouchGestureType.pinch(scale: 1.5, velocity: 0.5)
        let rotate = TouchGestureType.rotate(rotation: 0.5, velocity: 0.1)
        let swipe = TouchGestureType.swipe(direction: .up)
        let edgeSwipe = TouchGestureType.edgeSwipe(edge: .left, translation: 50)

        // Just verify they can be created
        XCTAssertNotNil(tap)
        XCTAssertNotNil(doubleTap)
        XCTAssertNotNil(longPress)
        XCTAssertNotNil(pan)
        XCTAssertNotNil(pinch)
        XCTAssertNotNil(rotate)
        XCTAssertNotNil(swipe)
        XCTAssertNotNil(edgeSwipe)
    }

    // MARK: - SwipeDirection Tests

    func testSwipeDirectionCases() {
        XCTAssertEqual(SwipeDirection.allCases.count, 4)
        XCTAssertTrue(SwipeDirection.allCases.contains(.up))
        XCTAssertTrue(SwipeDirection.allCases.contains(.down))
        XCTAssertTrue(SwipeDirection.allCases.contains(.left))
        XCTAssertTrue(SwipeDirection.allCases.contains(.right))
    }

    // MARK: - Edge Tests

    func testEdgeCases() {
        XCTAssertEqual(Edge.allCases.count, 4)
        XCTAssertTrue(Edge.allCases.contains(.top))
        XCTAssertTrue(Edge.allCases.contains(.bottom))
        XCTAssertTrue(Edge.allCases.contains(.left))
        XCTAssertTrue(Edge.allCases.contains(.right))
    }

    // MARK: - WindowAction Tests

    func testWindowActionCases() {
        let close = WindowAction.close(windowId: 1)
        let minimize = WindowAction.minimize(windowId: 1)
        let maximize = WindowAction.maximize(windowId: 1)
        let move = WindowAction.move(windowId: 1, to: CGPoint(x: 100, y: 100))
        let resize = WindowAction.resize(windowId: 1, to: CGSize(width: 800, height: 600))
        let snap = WindowAction.snap(windowId: 1, to: .leftHalf)
        let bringToFront = WindowAction.bringToFront(windowId: 1)
        let sendToBack = WindowAction.sendToBack(windowId: 1)
        let toggleFullscreen = WindowAction.toggleFullscreen(windowId: 1)
        let switchToApp = WindowAction.switchToApp(bundleId: "com.test.app")
        let showAppSwitcher = WindowAction.showAppSwitcher
        let showMissionControl = WindowAction.showMissionControl
        let showLaunchpad = WindowAction.showLaunchpad

        // Just verify they can be created
        XCTAssertNotNil(close)
        XCTAssertNotNil(minimize)
        XCTAssertNotNil(maximize)
        XCTAssertNotNil(move)
        XCTAssertNotNil(resize)
        XCTAssertNotNil(snap)
        XCTAssertNotNil(bringToFront)
        XCTAssertNotNil(sendToBack)
        XCTAssertNotNil(toggleFullscreen)
        XCTAssertNotNil(switchToApp)
        XCTAssertNotNil(showAppSwitcher)
        XCTAssertNotNil(showMissionControl)
        XCTAssertNotNil(showLaunchpad)
    }

    // MARK: - TouchZone Tests

    func testTouchZoneCreation() {
        let zone = TouchZone(
            frame: CGRect(x: 0, y: 0, width: 100, height: 100),
            action: .close(windowId: 1),
            gestureType: .tap(location: .zero)
        )

        XCTAssertEqual(zone.frame, CGRect(x: 0, y: 0, width: 100, height: 100))
        XCTAssertEqual(zone.action, .close(windowId: 1))
        XCTAssertEqual(zone.gestureType, .tap(location: .zero))
        XCTAssertFalse(zone.isActive)
    }

    // MARK: - VirtualKey Tests

    func testVirtualKeyCreation() {
        let key = VirtualKey(
            key: "a",
            display: "A",
            modifiers: [],
            frame: CGRect(x: 0, y: 0, width: 40, height: 40)
        )

        XCTAssertEqual(key.key, "a")
        XCTAssertEqual(key.display, "A")
        XCTAssertEqual(key.modifiers, [])
        XCTAssertEqual(key.frame, CGRect(x: 0, y: 0, width: 40, height: 40))
        XCTAssertFalse(key.isPressed)
    }

    // MARK: - VirtualTrackpadState Tests

    func testVirtualTrackpadStateDefault() {
        let state = VirtualTrackpadState()

        XCTAssertFalse(state.isActive)
        XCTAssertEqual(state.startLocation, .zero)
        XCTAssertEqual(state.currentLocation, .zero)
        XCTAssertFalse(state.isClicking)
        XCTAssertEqual(state.scrollAccumulator, .zero)
    }

    // MARK: - TouchyOSSettings Tests

    func testTouchyOSSettingsDefaults() {
        let settings = TouchyOSSettings.default

        XCTAssertTrue(settings.isEnabled)
        XCTAssertEqual(settings.touchSensitivity, 1.0)
        XCTAssertEqual(settings.gestureSensitivity, 1.0)
        XCTAssertTrue(settings.showTouchVisualizer)
        XCTAssertTrue(settings.enableVirtualTrackpad)
        XCTAssertTrue(settings.enableVirtualKeyboard)
        XCTAssertTrue(settings.enableEdgeGestures)
        XCTAssertTrue(settings.enableWindowSnap)
        XCTAssertEqual(settings.snapThreshold, 50)
        XCTAssertEqual(settings.longPressDuration, 0.5)
        XCTAssertEqual(settings.doubleTapInterval, 0.3)
        XCTAssertEqual(settings.menuBarIconSize, 22)
        XCTAssertEqual(settings.overlayOpacity, 0.8)
        XCTAssertTrue(settings.hapticFeedbackEnabled)
        XCTAssertFalse(settings.soundFeedbackEnabled)
    }

    func testTouchyOSSettingsDefaultSnapPositions() {
        let settings = TouchyOSSettings.default
        XCTAssertEqual(settings.defaultSnapPositions.count, 3)
        XCTAssertTrue(settings.defaultSnapPositions.contains(.leftHalf))
        XCTAssertTrue(settings.defaultSnapPositions.contains(.rightHalf))
        XCTAssertTrue(settings.defaultSnapPositions.contains(.fullScreen))
    }

    func testTouchyOSSettingsCodable() throws {
        var settings = TouchyOSSettings.default
        settings.isEnabled = false
        settings.touchSensitivity = 1.5

        let encoder = JSONEncoder()
        let data = try encoder.encode(settings)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(TouchyOSSettings.self, from: data)

        XCTAssertEqual(settings.isEnabled, decoded.isEnabled)
        XCTAssertEqual(settings.touchSensitivity, decoded.touchSensitivity)
    }

    // MARK: - KeyboardLayout Tests

    func testKeyboardLayoutCases() {
        XCTAssertEqual(KeyboardLayout.allCases.count, 4)
        XCTAssertTrue(KeyboardLayout.allCases.contains(.standard))
        XCTAssertTrue(KeyboardLayout.allCases.contains(.compact))
        XCTAssertTrue(KeyboardLayout.allCases.contains(.split))
        XCTAssertTrue(KeyboardLayout.allCases.contains(.macShortcuts))
    }

    func testKeyboardLayoutRawValues() {
        XCTAssertEqual(KeyboardLayout.standard.rawValue, "Standard")
        XCTAssertEqual(KeyboardLayout.compact.rawValue, "Compact")
        XCTAssertEqual(KeyboardLayout.split.rawValue, "Split")
        XCTAssertEqual(KeyboardLayout.macShortcuts.rawValue, "Mac Shortcuts")
    }

    // MARK: - KeyboardSize Tests

    func testKeyboardSizeCases() {
        XCTAssertEqual(KeyboardSize.allCases.count, 3)
        XCTAssertTrue(KeyboardSize.allCases.contains(.small))
        XCTAssertTrue(KeyboardSize.allCases.contains(.medium))
        XCTAssertTrue(KeyboardSize.allCases.contains(.large))
    }

    // MARK: - AppTheme Tests

    func testAppThemeCases() {
        XCTAssertEqual(AppTheme.allCases.count, 3)
        XCTAssertTrue(AppTheme.allCases.contains(.light))
        XCTAssertTrue(AppTheme.allCases.contains(.dark))
        XCTAssertTrue(AppTheme.allCases.contains(.system))
    }

    // MARK: - TouchOverlayConfig Tests

    func testTouchOverlayConfigDefault() {
        let config = TouchOverlayConfig()

        XCTAssertFalse(config.isVisible)
        XCTAssertTrue(config.zones.isEmpty)
        XCTAssertEqual(config.virtualTrackpad, VirtualTrackpadState())
        XCTAssertTrue(config.virtualKeyboard.isEmpty)
        XCTAssertTrue(config.activeGestures.isEmpty)
        XCTAssertEqual(config.lastTouchLocation, .zero)
        XCTAssertNil(config.touchStartTime)
    }
}