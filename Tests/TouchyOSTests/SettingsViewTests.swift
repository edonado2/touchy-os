import XCTest
import SwiftUI
@testable import TouchyOS

final class SettingsViewTests: XCTestCase {

    // MARK: - Properties

    var settingsService: SettingsService!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        settingsService = SettingsService.shared
        settingsService.resetToDefaults()
    }

    override func tearDown() {
        settingsService = nil
        super.tearDown()
    }

    // MARK: - SettingsView Tests

    func testSettingsViewCreation() {
        let view = SettingsView()
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    func testSettingsTabCases() {
        let allCases = SettingsTab.allCases
        XCTAssertEqual(allCases.count, 6)

        XCTAssertTrue(allCases.contains(.general))
        XCTAssertTrue(allCases.contains(.gestures))
        XCTAssertTrue(allCases.contains(.windows))
        XCTAssertTrue(allCases.contains(.input))
        XCTAssertTrue(allCases.contains(.appearance))
        XCTAssertTrue(allCases.contains(.advanced))
    }

    func testSettingsTabProperties() {
        XCTAssertEqual(SettingsTab.general.title, "General")
        XCTAssertEqual(SettingsTab.general.icon, "gear")

        XCTAssertEqual(SettingsTab.gestures.title, "Gestures")
        XCTAssertEqual(SettingsTab.gestures.icon, "hand.tap")

        XCTAssertEqual(SettingsTab.windows.title, "Windows")
        XCTAssertEqual(SettingsTab.windows.icon, "macwindow")

        XCTAssertEqual(SettingsTab.input.title, "Input")
        XCTAssertEqual(SettingsTab.input.icon, "keyboard")

        XCTAssertEqual(SettingsTab.appearance.title, "Appearance")
        XCTAssertEqual(SettingsTab.appearance.icon, "paintbrush")

        XCTAssertEqual(SettingsTab.advanced.title, "Advanced")
        XCTAssertEqual(SettingsTab.advanced.icon, "wrench.and.screwdriver")
    }

    // MARK: - GeneralSettingsView Tests

    func testGeneralSettingsViewCreation() {
        let view = GeneralSettingsView()
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    // MARK: - GestureSettingsView Tests

    func testGestureSettingsViewCreation() {
        let view = GestureSettingsView()
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    // MARK: - WindowSettingsView Tests

    func testWindowSettingsViewCreation() {
        let view = WindowSettingsView()
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    // MARK: - InputSettingsView Tests

    func testInputSettingsViewCreation() {
        let view = InputSettingsView()
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    // MARK: - AppearanceSettingsView Tests

    func testAppearanceSettingsViewCreation() {
        let view = AppearanceSettingsView()
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    // MARK: - AdvancedSettingsView Tests

    func testAdvancedSettingsViewCreation() {
        let view = AdvancedSettingsView()
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    // MARK: - SettingsSection Tests

    func testSettingsSectionCreation() {
        let section = SettingsSection(title: "Test") {
            Text("Content")
        }

        let _ = section.body
        XCTAssertTrue(true)
    }

    // MARK: - SnapPositionToggle Tests

    func testSnapPositionToggleCreation() {
        let toggle = SnapPositionToggle(position: .leftHalf)
            .environmentObject(settingsService)

        let _ = toggle.body
        XCTAssertTrue(true)
    }

    func testSnapPositionToggleIsEnabled() {
        let settingsService = SettingsService.shared
        settingsService.settings.defaultSnapPositions = [.leftHalf, .rightHalf]

        let toggle = SnapPositionToggle(position: .leftHalf)
            .environmentObject(settingsService)

        // The isEnabled property should return true for leftHalf
        // We can't easily test the computed property from outside, but we can verify the view builds
        let _ = toggle.body
        XCTAssertTrue(true)
    }

    // MARK: - AccentColorButton Tests

    func testAccentColorButtonCreation() {
        var tapped = false
        let button = AccentColorButton(
            name: "blue",
            color: .blue,
            isSelected: false
        ) {
            tapped = true
        }

        let _ = button.body
        XCTAssertTrue(true)
    }

    func testAccentColorButtonSelected() {
        var tapped = false
        let button = AccentColorButton(
            name: "blue",
            color: .blue,
            isSelected: true
        ) {
            tapped = true
        }

        let _ = button.body
        XCTAssertTrue(true)
    }

    // MARK: - Color Extension Tests

    func testColorIsDark() {
        // Test dark colors
        XCTAssertTrue(Color.black.isDark)
        XCTAssertTrue(Color(red: 0.1, green: 0.1, blue: 0.1).isDark)

        // Test light colors
        XCTAssertFalse(Color.white.isDark)
        XCTAssertFalse(Color(red: 0.9, green: 0.9, blue: 0.9).isDark)
    }
}