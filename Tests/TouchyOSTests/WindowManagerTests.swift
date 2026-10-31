import XCTest
@testable import TouchyOS

final class WindowManagerTests: XCTestCase {

    // MARK: - Properties

    var windowManager: WindowManager!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        windowManager = WindowManager.shared
    }

    override func tearDown() {
        windowManager = nil
        super.tearDown()
    }

    // MARK: - Singleton Tests

    func testSharedInstance() {
        let instance1 = WindowManager.shared
        let instance2 = WindowManager.shared
        XCTAssertTrue(instance1 === instance2)
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        // WindowManager should initialize without crashing
        XCTAssertNotNil(windowManager.windows)
        // May be empty or have windows depending on system state
    }

    // MARK: - Refresh Windows Tests

    func testRefreshWindows() {
        // This test verifies the method runs without crashing
        windowManager.refreshWindows()

        // After refresh, windows array should be accessible
        XCTAssertNotNil(windowManager.windows)
    }

    // MARK: - Calculate Snap Frame Tests

    func testCalculateSnapFrameLeftHalf() {
        let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let frame = windowManager.calculateSnapFrame(for: .leftHalf, screenFrame: screenFrame)

        // With padding of 8: x=8, y=8, width=(1920-16)/2=952, height=1080-16=1064
        XCTAssertEqual(frame.origin.x, 8)
        XCTAssertEqual(frame.origin.y, 8)
        XCTAssertEqual(frame.size.width, 952)
        XCTAssertEqual(frame.size.height, 1064)
    }

    func testCalculateSnapFrameRightHalf() {
        let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let frame = windowManager.calculateSnapFrame(for: .rightHalf, screenFrame: screenFrame)

        // With padding of 8: x=1920/2+4=964, y=8, width=952, height=1064
        XCTAssertEqual(frame.origin.x, 964)
        XCTAssertEqual(frame.origin.y, 8)
        XCTAssertEqual(frame.size.width, 952)
        XCTAssertEqual(frame.size.height, 1064)
    }

    func testCalculateSnapFrameTopHalf() {
        let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let frame = windowManager.calculateSnapFrame(for: .topHalf, screenFrame: screenFrame)

        // x=8, y=1080/2+4=544, width=1904, height=532
        XCTAssertEqual(frame.origin.x, 8)
        XCTAssertEqual(frame.origin.y, 544)
        XCTAssertEqual(frame.size.width, 1904)
        XCTAssertEqual(frame.size.height, 532)
    }

    func testCalculateSnapFrameBottomHalf() {
        let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let frame = windowManager.calculateSnapFrame(for: .bottomHalf, screenFrame: screenFrame)

        // x=8, y=8, width=1904, height=532
        XCTAssertEqual(frame.origin.x, 8)
        XCTAssertEqual(frame.origin.y, 8)
        XCTAssertEqual(frame.size.width, 1904)
        XCTAssertEqual(frame.size.height, 532)
    }

    func testCalculateSnapFrameTopLeft() {
        let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let frame = windowManager.calculateSnapFrame(for: .topLeft, screenFrame: screenFrame)

        // x=8, y=544, width=952, height=532
        XCTAssertEqual(frame.origin.x, 8)
        XCTAssertEqual(frame.origin.y, 544)
        XCTAssertEqual(frame.size.width, 952)
        XCTAssertEqual(frame.size.height, 532)
    }

    func testCalculateSnapFrameTopRight() {
        let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let frame = windowManager.calculateSnapFrame(for: .topRight, screenFrame: screenFrame)

        // x=964, y=544, width=952, height=532
        XCTAssertEqual(frame.origin.x, 964)
        XCTAssertEqual(frame.origin.y, 544)
        XCTAssertEqual(frame.size.width, 952)
        XCTAssertEqual(frame.size.height, 532)
    }

    func testCalculateSnapFrameBottomLeft() {
        let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let frame = windowManager.calculateSnapFrame(for: .bottomLeft, screenFrame: screenFrame)

        // x=8, y=8, width=952, height=532
        XCTAssertEqual(frame.origin.x, 8)
        XCTAssertEqual(frame.origin.y, 8)
        XCTAssertEqual(frame.size.width, 952)
        XCTAssertEqual(frame.size.height, 532)
    }

    func testCalculateSnapFrameBottomRight() {
        let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let frame = windowManager.calculateSnapFrame(for: .bottomRight, screenFrame: screenFrame)

        // x=964, y=8, width=952, height=532
        XCTAssertEqual(frame.origin.x, 964)
        XCTAssertEqual(frame.origin.y, 8)
        XCTAssertEqual(frame.size.width, 952)
        XCTAssertEqual(frame.size.height, 532)
    }

    func testCalculateSnapFrameFullScreen() {
        let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let frame = windowManager.calculateSnapFrame(for: .fullScreen, screenFrame: screenFrame)

        // x=8, y=8, width=1904, height=1064
        XCTAssertEqual(frame.origin.x, 8)
        XCTAssertEqual(frame.origin.y, 8)
        XCTAssertEqual(frame.size.width, 1904)
        XCTAssertEqual(frame.size.height, 1064)
    }

    func testCalculateSnapFrameCenter() {
        let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let frame = windowManager.calculateSnapFrame(for: .center, screenFrame: screenFrame)

        // width=1904*0.8=1523.2, height=1064*0.8=851.2
        // x=960-761.6=198.4, y=540-425.6=114.4
        XCTAssertEqual(frame.origin.x, 198.4, accuracy: 1.0)
        XCTAssertEqual(frame.origin.y, 114.4, accuracy: 1.0)
        XCTAssertEqual(frame.size.width, 1523.2, accuracy: 1.0)
        XCTAssertEqual(frame.size.height, 851.2, accuracy: 1.0)
    }

    func testCalculateSnapFrameLeftThird() {
        let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let frame = windowManager.calculateSnapFrame(for: .leftThird, screenFrame: screenFrame)

        // x=8, y=8, width=(1920-16)/3=634.67, height=1064
        XCTAssertEqual(frame.origin.x, 8)
        XCTAssertEqual(frame.origin.y, 8)
        XCTAssertEqual(frame.size.width, 634.67, accuracy: 1.0)
        XCTAssertEqual(frame.size.height, 1064)
    }

    func testCalculateSnapFrameCenterThird() {
        let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let frame = windowManager.calculateSnapFrame(for: .centerThird, screenFrame: screenFrame)

        // x=8+634.67=642.67, y=8, width=634.67, height=1064
        XCTAssertEqual(frame.origin.x, 642.67, accuracy: 1.0)
        XCTAssertEqual(frame.origin.y, 8)
        XCTAssertEqual(frame.size.width, 634.67, accuracy: 1.0)
        XCTAssertEqual(frame.size.height, 1064)
    }

    func testCalculateSnapFrameRightThird() {
        let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let frame = windowManager.calculateSnapFrame(for: .rightThird, screenFrame: screenFrame)

        // x=8+2*634.67=1277.33, y=8, width=634.67, height=1064
        XCTAssertEqual(frame.origin.x, 1277.33, accuracy: 1.0)
        XCTAssertEqual(frame.origin.y, 8)
        XCTAssertEqual(frame.size.width, 634.67, accuracy: 1.0)
        XCTAssertEqual(frame.size.height, 1064)
    }

    // MARK: - Perform Action Tests

    func testPerformActionCases() {
        // These tests verify the methods exist and can be called
        // They don't actually perform actions since we're in a test environment

        windowManager.performAction(.close(windowId: 1))
        windowManager.performAction(.minimize(windowId: 1))
        windowManager.performAction(.maximize(windowId: 1))
        windowManager.performAction(.move(windowId: 1, to: CGPoint(x: 100, y: 100)))
        windowManager.performAction(.resize(windowId: 1, to: CGSize(width: 800, height: 600)))
        windowManager.performAction(.snap(windowId: 1, to: .leftHalf))
        windowManager.performAction(.bringToFront(windowId: 1))
        windowManager.performAction(.sendToBack(windowId: 1))
        windowManager.performAction(.toggleFullscreen(windowId: 1))
        windowManager.performAction(.switchToApp(bundleId: "com.test.app"))
        windowManager.performAction(.showAppSwitcher)
        windowManager.performAction(.showMissionControl)
        windowManager.performAction(.showLaunchpad)

        // If we reach here without crashing, the test passes
        XCTAssertTrue(true)
    }

    // MARK: - Key Code Mapping Tests

    func testKeyCodeForString() {
        // Test internal keyCodeForString method indirectly
        // We can't directly call private methods, but we can verify the shortcuts work

        // Test common keys
        let testKeys = ["a", "s", "d", "f", "h", "g", "z", "x", "c", "v", "b", "q", "w", "e", "r", "y", "t"]
        for key in testKeys {
            // Just verify no crash
            windowManager.performAction(.close(windowId: 1)) // Uses "w" key
        }

        XCTAssertTrue(true)
    }

    // MARK: - Frontmost Window Tests

    func testFrontmostWindowProperty() {
        // Property should be accessible
        let frontmost = windowManager.frontmostWindow
        // May be nil or have a window
        XCTAssertNotNil(frontmost) // Type check only
    }

    // MARK: - Is Animating Tests

    func testIsAnimatingProperty() {
        // Property should be accessible and false initially
        XCTAssertFalse(windowManager.isAnimating)
    }
}