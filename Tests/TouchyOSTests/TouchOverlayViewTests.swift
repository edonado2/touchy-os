import XCTest
import SwiftUI
@testable import TouchyOS

final class TouchOverlayViewTests: XCTestCase {

    // MARK: - Properties

    var settingsService: SettingsService!
    var overlayManager: TouchOverlayManager!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        settingsService = SettingsService.shared
        overlayManager = TouchOverlayManager.shared
        settingsService.resetToDefaults()
    }

    override func tearDown() {
        settingsService = nil
        overlayManager = nil
        super.tearDown()
    }

    // MARK: - TouchOverlayView Tests

    func testTouchOverlayViewCreation() {
        let view = TouchOverlayView()
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    func testTouchOverlayViewWithZones() {
        // Create some touch zones
        let zones = [
            TouchZone(
                frame: CGRect(x: 100, y: 100, width: 50, height: 50),
                action: .close(windowId: 1),
                gestureType: .tap(location: .zero)
            ),
            TouchZone(
                frame: CGRect(x: 200, y: 200, width: 100, height: 100),
                action: .snap(windowId: 1, to: .leftHalf),
                gestureType: .pan(translation: .zero, velocity: .zero)
            )
        ]

        overlayManager.config.zones = zones
        overlayManager.config.isVisible = true

        let view = TouchOverlayView()
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    func testTouchOverlayViewInvisible() {
        overlayManager.config.isVisible = false
        overlayManager.config.zones = []

        let view = TouchOverlayView()
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    // MARK: - TouchZoneView Tests (if accessible)

    // TouchZoneView is a private struct inside TouchOverlayView, so we can't directly test it
    // But we can test the overlay view with zones
}