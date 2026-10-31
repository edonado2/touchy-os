import XCTest
@testable import TouchyOS

final class AppDelegateTests: XCTestCase {

    // MARK: - Properties

    var appDelegate: AppDelegate!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()
    }

    override func tearDown() {
        appDelegate = nil
        super.tearDown()
    }

    // MARK: - AppDelegate Tests

    func testAppDelegateCreation() {
        XCTAssertNotNil(appDelegate)
    }

    func testApplicationDidFinishLaunching() {
        let notification = Notification(name: NSApplication.didFinishLaunchingNotification)

        // This should not crash
        appDelegate.applicationDidFinishLaunching(notification)

        // Verify status item was created
        XCTAssertNotNil(appDelegate.statusItem)
        XCTAssertNotNil(appDelegate.popover)
    }

    func testSetupStatusItem() {
        appDelegate.setupStatusItem()

        XCTAssertNotNil(appDelegate.statusItem)
        XCTAssertNotNil(appDelegate.popover)
        XCTAssertNotNil(appDelegate.statusItem?.button)
        XCTAssertEqual(appDelegate.statusItem?.button?.image?.name(), "hand.tap.fill")
    }

    func testSetupContextualMenu() {
        appDelegate.setupContextualMenu()

        XCTAssertNotNil(appDelegate.statusMenu)
        XCTAssertGreaterThan(appDelegate.statusMenu?.items.count ?? 0, 0)

        // Check for expected menu items
        let titles = appDelegate.statusMenu?.items.map { $0.title } ?? []
        XCTAssertTrue(titles.contains("Enable Touch Mode"))
        XCTAssertTrue(titles.contains("Show Virtual Keyboard"))
        XCTAssertTrue(titles.contains("Show Virtual Trackpad"))
        XCTAssertTrue(titles.contains("Snap Window Left"))
        XCTAssertTrue(titles.contains("Snap Window Right"))
        XCTAssertTrue(titles.contains("Mission Control"))
        XCTAssertTrue(titles.contains("App Switcher"))
        XCTAssertTrue(titles.contains("Settings..."))
        XCTAssertTrue(titles.contains("About TouchyOS"))
        XCTAssertTrue(titles.contains("Quit TouchyOS"))
    }

    func testUpdateMenuStates() {
        appDelegate.setupStatusItem()
        appDelegate.setupContextualMenu()

        // Should not crash
        appDelegate.updateMenuStates()

        // Check toggle item state
        if let toggleItem = appDelegate.statusMenu?.items.first(where: { $0.action == #selector(AppDelegate.toggleTouchMode(_:)) }) {
            XCTAssertEqual(toggleItem.state, .off) // Default is disabled after reset
        }
    }

    func testToggleTouchMode() {
        appDelegate.setupStatusItem()
        appDelegate.setupContextualMenu()

        let initialState = SettingsService.shared.isEnabled

        // Toggle
        appDelegate.toggleTouchMode(NSMenuItem())

        XCTAssertNotEqual(SettingsService.shared.isEnabled, initialState)

        // Toggle back
        appDelegate.toggleTouchMode(NSMenuItem())

        XCTAssertEqual(SettingsService.shared.isEnabled, initialState)
    }

    func testShowVirtualKeyboard() {
        appDelegate.showVirtualKeyboard(NSMenuItem())
        // Should not crash
    }

    func testShowVirtualTrackpad() {
        appDelegate.showVirtualTrackpad(NSMenuItem())
        // Should not crash
    }

    func testSnapWindowLeft() {
        appDelegate.snapWindowLeft(NSMenuItem())
        // Should not crash
    }

    func testSnapWindowRight() {
        appDelegate.snapWindowRight(NSMenuItem())
        // Should not crash
    }

    func testShowMissionControl() {
        appDelegate.showMissionControl(NSMenuItem())
        // Should not crash
    }

    func testShowAppSwitcher() {
        appDelegate.showAppSwitcher(NSMenuItem())
        // Should not crash
    }

    func testOpenSettings() {
        appDelegate.openSettings(NSMenuItem())
        // Should not crash
    }

    func testShowAbout() {
        appDelegate.showAbout(NSMenuItem())
        // Should not crash
    }

    func testQuitApp() {
        appDelegate.quitApp(NSMenuItem())
        // Should not crash (though it would terminate the app in real use)
    }

    func testOpenSettingsWindow() {
        appDelegate.openSettingsWindow()

        // Should create settings window
        XCTAssertNotNil(appDelegate.settingsWindow)
        XCTAssertEqual(appDelegate.settingsWindow?.title, "TouchyOS Settings")
    }

    func testApplicationWillTerminate() {
        let notification = Notification(name: NSApplication.willTerminateNotification)

        // Should not crash
        appDelegate.applicationWillTerminate(notification)
    }
}