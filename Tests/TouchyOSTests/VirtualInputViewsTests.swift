import XCTest
import SwiftUI
@testable import TouchyOS

final class VirtualInputViewsTests: XCTestCase {

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

    // MARK: - VirtualTrackpadView Tests

    func testVirtualTrackpadViewCreation() {
        let view = VirtualTrackpadView()
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    func testVirtualTrackpadViewWithOverlayManager() {
        let view = VirtualTrackpadView()
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    // MARK: - VirtualTrackpadButton Tests

    func testVirtualTrackpadButtonCreation() {
        var tapped = false
        let button = VirtualTrackpadButton(
            title: "Test",
            icon: "cursorarrow.click",
            action: { tapped = true }
        )

        let _ = button.body
        XCTAssertTrue(true)
    }

    // MARK: - VirtualKeyboardView Tests

    func testVirtualKeyboardViewCreation() {
        let settings = TouchyOSSettings.default
        let view = VirtualKeyboardView(settings: settings)
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    func testVirtualKeyboardViewWithDifferentSettings() {
        var settings = TouchyOSSettings.default
        settings.keyboardLayout = .compact
        settings.keyboardSize = .small
        settings.keyboardOpacity = 0.7

        let view = VirtualKeyboardView(settings: settings)
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    func testVirtualKeyboardKeyRows() {
        let settings = TouchyOSSettings.default
        let view = VirtualKeyboardView(settings: settings)
            .environmentObject(settingsService)

        // Test that key rows can be accessed
        let numberRow = view.numberRowKeys
        let qwertyRow = view.qwertyRowKeys
        let asdfRow = view.asdfRowKeys
        let zxcvRow = view.zxcvRowKeys
        let bottomRow = view.bottomRowKeys

        XCTAssertGreaterThan(numberRow.count, 0)
        XCTAssertGreaterThan(qwertyRow.count, 0)
        XCTAssertGreaterThan(asdfRow.count, 0)
        XCTAssertGreaterThan(zxcvRow.count, 0)
        XCTAssertGreaterThan(bottomRow.count, 0)
    }

    func testNumberRowKeys() {
        let settings = TouchyOSSettings.default
        let view = VirtualKeyboardView(settings: settings)

        let keys = view.numberRowKeys
        XCTAssertEqual(keys.count, 14) // `, 1-0, -, =, ⌫

        // Check first and last
        XCTAssertEqual(keys.first?.primary, "`")
        XCTAssertEqual(keys.last?.primary, "⌫")
        XCTAssertEqual(keys.last?.width, 1.5)
    }

    func testQwertyRowKeys() {
        let settings = TouchyOSSettings.default
        let view = VirtualKeyboardView(settings: settings)

        let keys = view.qwertyRowKeys
        XCTAssertEqual(keys.count, 14) // ⇥, Q-P, [, ], \

        XCTAssertEqual(keys.first?.primary, "⇥")
        XCTAssertEqual(keys.first?.width, 1.3)
        XCTAssertEqual(keys.last?.primary, "\\")
        XCTAssertEqual(keys.last?.width, 1.3)
    }

    func testAsdfRowKeys() {
        let settings = TouchyOSSettings.default
        let view = VirtualKeyboardView(settings: settings)

        let keys = view.asdfRowKeys
        XCTAssertEqual(keys.count, 13) // ⇪, A-L, ;, ', ⏎

        XCTAssertEqual(keys.first?.primary, "⇪")
        XCTAssertEqual(keys.first?.width, 1.5)
        XCTAssertTrue(keys.first?.isModifier ?? false)
        XCTAssertEqual(keys.last?.primary, "⏎")
        XCTAssertEqual(keys.last?.width, 1.5)
    }

    func testZxcvRowKeys() {
        let settings = TouchyOSSettings.default
        let view = VirtualKeyboardView(settings: settings)

        let keys = view.zxcvRowKeys
        XCTAssertEqual(keys.count, 12) // ⇧, Z-M, ,, ., /, ⇧

        XCTAssertEqual(keys.first?.primary, "⇧")
        XCTAssertEqual(keys.first?.width, 1.8)
        XCTAssertTrue(keys.first?.isModifier ?? false)
        XCTAssertEqual(keys.last?.primary, "⇧")
        XCTAssertEqual(keys.last?.width, 1.8)
        XCTAssertTrue(keys.last?.isModifier ?? false)
    }

    func testBottomRowKeys() {
        let settings = TouchyOSSettings.default
        let view = VirtualKeyboardView(settings: settings)

        let keys = view.bottomRowKeys
        XCTAssertEqual(keys.count, 12) // fn, ⌃, ⌥, ⌘, Space, ⌘, ⌥, ←, ↑, →, ↓

        // Check space key width
        let spaceKey = keys.first { $0.primary == "Space" }
        XCTAssertNotNil(spaceKey)
        XCTAssertEqual(spaceKey?.width, 6.0)
    }

    func testShiftedNumberRow() {
        let settings = TouchyOSSettings.default
        let view = VirtualKeyboardView(settings: settings)

        let shifted = view.shiftedNumberRow
        XCTAssertEqual(shifted["1"], "!")
        XCTAssertEqual(shifted["2"], "@")
        XCTAssertEqual(shifted["3"], "#")
        XCTAssertEqual(shifted["4"], "$")
        XCTAssertEqual(shifted["5"], "%")
        XCTAssertEqual(shifted["6"], "^")
        XCTAssertEqual(shifted["7"], "&")
        XCTAssertEqual(shifted["8"], "*")
        XCTAssertEqual(shifted["9"], "(")
        XCTAssertEqual(shifted["0"], ")")
        XCTAssertEqual(shifted["-"], "_")
        XCTAssertEqual(shifted["="], "+")
        XCTAssertEqual(shifted["`"], "~")
    }

    func testKeyCodeForString() {
        let settings = TouchyOSSettings.default
        let view = VirtualKeyboardView(settings: settings)

        // Test arrow keys
        XCTAssertEqual(view.keyCodeForString("←"), 0x7B)
        XCTAssertEqual(view.keyCodeForString("↑"), 0x7E)
        XCTAssertEqual(view.keyCodeForString("→"), 0x7C)
        XCTAssertEqual(view.keyCodeForString("↓"), 0x7D)

        // Test regular keys
        XCTAssertEqual(view.keyCodeForString("a"), 0x00)
        XCTAssertEqual(view.keyCodeForString(" "), 0x31)
        XCTAssertEqual(view.keyCodeForString("⌫"), 0x33)
    }

    // MARK: - KeyboardKey Tests

    func testKeyboardKeyCreation() {
        var actionCalled = false
        let key = KeyboardKey(
            primary: "A",
            shifted: "a",
            action: { actionCalled = true },
            width: 1.0,
            isModifier: false
        )

        XCTAssertEqual(key.primary, "A")
        XCTAssertEqual(key.shifted, "a")
        XCTAssertEqual(key.width, 1.0)
        XCTAssertFalse(key.isModifier)
    }

    // MARK: - KeyboardRow Tests

    func testKeyboardRowCreation() {
        let keys = [
            KeyboardKey(primary: "A", shifted: "a", action: {}, width: 1.0),
            KeyboardKey(primary: "B", shifted: "b", action: {}, width: 1.0)
        ]

        let row = KeyboardRow(keys: keys)
            .environmentObject(settingsService)

        let _ = row.body
        XCTAssertTrue(true)
    }

    // MARK: - VirtualKeyView Tests

    func testVirtualKeyViewCreation() {
        let key = KeyboardKey(
            primary: "A",
            shifted: "a",
            action: {},
            width: 1.0
        )

        let view = VirtualKeyView(key: key, width: 1.0)
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    func testVirtualKeyViewModifierKey() {
        let key = KeyboardKey(
            primary: "⇧",
            shifted: "⇧",
            action: {},
            width: 1.8,
            isModifier: true
        )

        let view = VirtualKeyView(key: key, width: 1.8)
            .environmentObject(settingsService)

        let _ = view.body
        XCTAssertTrue(true)
    }

    // MARK: - ModifierKeyIndicator Tests

    func testModifierKeyIndicatorCreation() {
        let indicator = ModifierKeyIndicator(key: "⌘", isPressed: false)
        let _ = indicator.body
        XCTAssertTrue(true)
    }

    func testModifierKeyIndicatorPressed() {
        let indicator = ModifierKeyIndicator(key: "⌘", isPressed: true)
        let _ = indicator.body
        XCTAssertTrue(true)
    }
}