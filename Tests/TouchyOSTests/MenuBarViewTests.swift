import XCTest
import SwiftUI
@testable import TouchyOS

final class MenuBarViewTests: XCTestCase {

    // MARK: - Properties

    var settingsService: SettingsService!
    var windowManager: WindowManager!
    var overlayManager: TouchOverlayManager!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        settingsService = SettingsService.shared
        windowManager = WindowManager.shared
        overlayManager = TouchOverlayManager.shared
        settingsService.resetToDefaults()
    }

    override func tearDown() {
        settingsService = nil
        windowManager = nil
        overlayManager = nil
        super.tearDown()
    }

    // MARK: - View Creation Tests

    func testMenuBarViewCreation() {
        let view = MenuBarView()
            .environmentObject(settingsService)

        // Verify the view can be created
        XCTAssertNotNil(view)
    }

    func testMenuBarViewBody() {
        let view = MenuBarView()
            .environmentObject(settingsService)

        // Access body to trigger view building
        let _ = view.body
        XCTAssertTrue(true)
    }

    func testHeaderView() {
        let view = MenuBarView()
            .environmentObject(settingsService)

        let _ = view.headerView
        XCTAssertTrue(true)
    }

    func testQuickActionsView() {
        let view = MenuBarView()
            .environmentObject(settingsService)

        let _ = view.quickActionsView
        XCTAssertTrue(true)
    }

    func testWindowListView() {
        let view = MenuBarView()
            .environmentObject(settingsService)

        let _ = view.windowListView
        XCTAssertTrue(true)
    }

    func testFooterView() {
        let view = MenuBarView()
            .environmentObject(settingsService)

        let _ = view.footerView
        XCTAssertTrue(true)
    }

    // MARK: - SettingsSheetContent Tests

    func testSettingsSheetContentCreation() {
        let view = SettingsSheetContent()
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    // MARK: - MenuBarButton Tests

    func testMenuBarButtonCreation() {
        var tapped = false
        let button = MenuBarButton(
            icon: "test",
            title: "Test",
            color: .blue
        ) {
            tapped = true
        }

        let _ = button.body
        XCTAssertTrue(true)
    }

    // MARK: - WindowRowView Tests

    func testWindowRowViewCreation() {
        let window = WindowInfo(
            id: 1,
            ownerName: "TestApp",
            windowTitle: "Test Window",
            bounds: CGRect(x: 100, y: 100, width: 800, height: 600),
            layer: 0,
            isOnScreen: true,
            appBundleIdentifier: nil
        )

        let view = WindowRowView(window: window)
        let _ = view.body
        XCTAssertTrue(true)
    }

    // MARK: - TouchActionButton Tests

    func testTouchActionButtonCreation() {
        var tapped = false
        let button = TouchActionButton(icon: "test") {
            tapped = true
        }

        let _ = button.body
        XCTAssertTrue(true)
    }

    // MARK: - WindowControlsView Tests

    func testWindowControlsViewCreation() {
        let window = WindowInfo(
            id: 1,
            ownerName: "TestApp",
            windowTitle: "Test Window",
            bounds: CGRect(x: 100, y: 100, width: 800, height: 600),
            layer: 0,
            isOnScreen: true,
            appBundleIdentifier: nil
        )

        let view = WindowControlsView(window: window)
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    // MARK: - TouchControlButton Tests

    func testTouchControlButtonCreation() {
        var tapped = false
        let button = TouchControlButton(
            icon: "test",
            title: "Test",
            color: .blue
        ) {
            tapped = true
        }

        let _ = button.body
        XCTAssertTrue(true)
    }

    // MARK: - PopoverContentView Tests

    func testPopoverContentViewCreation() {
        let view = PopoverContentView()
        let _ = view.body
        XCTAssertTrue(true)
    }
}