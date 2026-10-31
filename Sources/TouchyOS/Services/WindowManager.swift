import Foundation
import AppKit
import Carbon
import ApplicationServices

// MARK: - Window Manager
@MainActor
class WindowManager: ObservableObject {
    static let shared = WindowManager()

    @Published var windows: [WindowInfo] = []
    @Published var frontmostWindow: WindowInfo?
    @Published var isAnimating: Bool = false

    private var accessibilityObserver: AXObserver?
    private var refreshTimer: Timer?

    private init() {
        setupAccessibilityObserver()
        startWindowMonitoring()
    }

    // MARK: - Window Discovery
    func refreshWindows() {
        let windowList = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as? [[String: Any]] ?? []

        var newWindows: [WindowInfo] = []

        for windowDict in windowList {
            guard let windowId = windowDict[kCGWindowNumber as String] as? CGWindowID,
                  let ownerName = windowDict[kCGWindowOwnerName as String] as? String,
                  let boundsDict = windowDict[kCGWindowBounds as String] as? [String: Any],
                  let x = boundsDict["X"] as? CGFloat,
                  let y = boundsDict["Y"] as? CGFloat,
                  let width = boundsDict["Width"] as? CGFloat,
                  let height = boundsDict["Height"] as? CGFloat,
                  let layer = windowDict[kCGWindowLayer as String] as? Int,
                  let isOnScreen = windowDict[kCGWindowIsOnscreen as String] as? Bool else {
                continue
            }

            let windowTitle = windowDict[kCGWindowName as String] as? String ?? ""
            let appBundleId = windowDict[kCGWindowOwnerPID as String].flatMap { pid in
                getBundleIdentifier(for: pid as! pid_t)
            }

            // Filter out system windows and tiny windows
            if width < 50 || height < 50 { continue }
            if layer < 0 { continue } // Skip desktop/background windows

            let window = WindowInfo(
                id: windowId,
                ownerName: ownerName,
                windowTitle: windowTitle,
                bounds: CGRect(x: x, y: y, width: width, height: height),
                layer: layer,
                isOnScreen: isOnScreen,
                appBundleIdentifier: appBundleId
            )

            newWindows.append(window)
        }

        // Sort by layer (frontmost first) then by recent use
        newWindows.sort { $0.layer > $1.layer }

        self.windows = newWindows
        self.frontmostWindow = newWindows.first
    }

    private func getBundleIdentifier(for pid: pid_t) -> String? {
        let app = NSRunningApplication(processIdentifier: pid)
        return app?.bundleIdentifier
    }

    // MARK: - Window Actions
    func performAction(_ action: WindowAction) {
        switch action {
        case .close(let windowId):
            closeWindow(windowId)
        case .minimize(let windowId):
            minimizeWindow(windowId)
        case .maximize(let windowId):
            maximizeWindow(windowId)
        case .move(let windowId, let point):
            moveWindow(windowId, to: point)
        case .resize(let windowId, let size):
            resizeWindow(windowId, to: size)
        case .snap(let windowId, let position):
            snapWindow(windowId, to: position)
        case .bringToFront(let windowId):
            bringToFront(windowId)
        case .sendToBack(let windowId):
            sendToBack(windowId)
        case .toggleFullscreen(let windowId):
            toggleFullscreen(windowId)
        case .switchToApp(let bundleId):
            switchToApp(bundleId)
        case .showAppSwitcher:
            showAppSwitcher()
        case .showMissionControl:
            showMissionControl()
        case .showLaunchpad:
            showLaunchpad()
        }
    }

    private func closeWindow(_ windowId: CGWindowID) {
        // Send CMD+W to close window
        sendKeyShortcut(key: "w", modifiers: .command)
    }

    private func minimizeWindow(_ windowId: CGWindowID) {
        sendKeyShortcut(key: "m", modifiers: .command)
    }

    private func maximizeWindow(_ windowId: CGWindowID) {
        // Double-click title bar or use green button
        if let axWindow = getAXUIElement(for: windowId) {
            if let zoomButton = findZoomButton(in: axWindow) {
                AXUIElementPerformAction(zoomButton, kAXPressAction as CFString)
            }
        }
    }

    private func moveWindow(_ windowId: CGWindowID, to point: CGPoint) {
        guard let axWindow = getAXUIElement(for: windowId) else { return }
        var position = CGPoint(x: point.x, y: point.y)
        let cfValue = AXValueCreate(.cgPoint, &position)!
        AXUIElementSetAttributeValue(axWindow, kAXPositionAttribute as CFString, cfValue)
    }

    private func resizeWindow(_ windowId: CGWindowID, to size: CGSize) {
        guard let axWindow = getAXUIElement(for: windowId) else { return }
        var newSize = CGSize(width: size.width, height: size.height)
        let cfValue = AXValueCreate(.cgSize, &newSize)!
        AXUIElementSetAttributeValue(axWindow, kAXSizeAttribute as CFString, cfValue)
    }

    private func snapWindow(_ windowId: CGWindowID, to position: SnapPosition) {
        guard let _ = windows.first(where: { $0.id == windowId }),
              let screen = NSScreen.main else { return }

        let screenFrame = screen.visibleFrame
        let newFrame = calculateSnapFrame(for: position, screenFrame: screenFrame)

        moveWindow(windowId, to: newFrame.origin)
        resizeWindow(windowId, to: newFrame.size)
    }

    func calculateSnapFrame(for position: SnapPosition, screenFrame: CGRect) -> CGRect {
        let padding: CGFloat = 8
        let width = screenFrame.width - padding * 2
        let height = screenFrame.height - padding * 2
        let halfWidth = width / 2
        let halfHeight = height / 2
        let thirdWidth = width / 3

        switch position {
        case .leftHalf:
            return CGRect(x: screenFrame.minX + padding, y: screenFrame.minY + padding, width: halfWidth, height: height)
        case .rightHalf:
            return CGRect(x: screenFrame.midX + padding/2, y: screenFrame.minY + padding, width: halfWidth, height: height)
        case .topHalf:
            return CGRect(x: screenFrame.minX + padding, y: screenFrame.midY + padding/2, width: width, height: halfHeight)
        case .bottomHalf:
            return CGRect(x: screenFrame.minX + padding, y: screenFrame.minY + padding, width: width, height: halfHeight)
        case .topLeft:
            return CGRect(x: screenFrame.minX + padding, y: screenFrame.midY + padding/2, width: halfWidth, height: halfHeight)
        case .topRight:
            return CGRect(x: screenFrame.midX + padding/2, y: screenFrame.midY + padding/2, width: halfWidth, height: halfHeight)
        case .bottomLeft:
            return CGRect(x: screenFrame.minX + padding, y: screenFrame.minY + padding, width: halfWidth, height: halfHeight)
        case .bottomRight:
            return CGRect(x: screenFrame.midX + padding/2, y: screenFrame.minY + padding, width: halfWidth, height: halfHeight)
        case .fullScreen:
            return CGRect(x: screenFrame.minX + padding, y: screenFrame.minY + padding, width: width, height: height)
        case .center:
            let w = width * 0.8
            let h = height * 0.8
            return CGRect(x: screenFrame.midX - w/2, y: screenFrame.midY - h/2, width: w, height: h)
        case .leftThird:
            return CGRect(x: screenFrame.minX + padding, y: screenFrame.minY + padding, width: thirdWidth, height: height)
        case .centerThird:
            return CGRect(x: screenFrame.minX + padding + thirdWidth, y: screenFrame.minY + padding, width: thirdWidth, height: height)
        case .rightThird:
            return CGRect(x: screenFrame.minX + padding + thirdWidth * 2, y: screenFrame.minY + padding, width: thirdWidth, height: height)
        }
    }

    private func bringToFront(_ windowId: CGWindowID) {
        guard let axWindow = getAXUIElement(for: windowId) else { return }
        AXUIElementPerformAction(axWindow, kAXRaiseAction as CFString)
    }

    private func sendToBack(_ windowId: CGWindowID) {
        // No direct AX action, but we can minimize then restore others
        minimizeWindow(windowId)
    }

    private func toggleFullscreen(_ windowId: CGWindowID) {
        sendKeyShortcut(key: "f", modifiers: [.command, .control])
    }

    private func switchToApp(_ bundleId: String) {
        if let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first {
            app.activate(options: [.activateIgnoringOtherApps])
        }
    }

    private func showAppSwitcher() {
        // CMD+TAB
        sendKeyShortcut(key: "\t", modifiers: .command)
    }

    private func showMissionControl() {
        // F3 or CTRL+UP
        sendKeyShortcut(keyCode: 0x60, modifiers: .control) // F3
    }

    private func showLaunchpad() {
        // F4 or pinch gesture
        sendKeyShortcut(keyCode: 0x61, modifiers: []) // F4
    }

    // MARK: - Accessibility
    private func setupAccessibilityObserver() {
        let pid = getpid()
        var observer: AXObserver?
        let callback: AXObserverCallback = { _, element, notification, _ in
            Task { @MainActor in
                WindowManager.shared.handleAXNotification(element: element, notification: notification as String)
            }
        }

        if AXObserverCreate(pid, callback, &observer) == .success {
            self.accessibilityObserver = observer

            // Add notifications for window changes
            if let frontmost = NSWorkspace.shared.frontmostApplication {
                let appElement = AXUIElementCreateApplication(frontmost.processIdentifier)
                let notifications: [String] = [
                    "AXWindowCreated",
                    "AXWindowClosed",
                    "AXWindowMoved",
                    "AXWindowResized",
                    "AXMainWindowChanged",
                    "AXFocusedWindowChanged"
                ]

                for notification in notifications {
                    AXObserverAddNotification(observer!, appElement, notification as CFString, Unmanaged.passUnretained(self).toOpaque())
                }
            }
        }
    }

    private func handleAXNotification(element: AXUIElement, notification: String) {
        refreshWindows()
    }

    private func getAXUIElement(for windowId: CGWindowID) -> AXUIElement? {
        let windowList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, windowId) as? [[String: Any]] ?? []
        guard let windowDict = windowList.first,
              let pid = windowDict[kCGWindowOwnerPID as String] as? pid_t else {
            return nil
        }

        let appElement = AXUIElementCreateApplication(pid)
        var windowsRef: CFArray?
        let result = AXUIElementCopyAttributeValues(
            appElement,
            kAXWindowsAttribute as CFString,
            0,
            100,
            &windowsRef
        )

        guard result == .success, let windows = windowsRef as? [AXUIElement] else { return nil }

        for window in windows {
            var idValue: CGWindowID = 0
            var idCFType: CFTypeRef?
            if AXUIElementCopyAttributeValue(window, "AXWindowNumber" as CFString, &idCFType) == .success,
               let idNumber = idCFType as? NSNumber {
                idValue = CGWindowID(idNumber.intValue)
                if idValue == windowId {
                    return window
                }
            }
        }

        return nil
    }

    private func findZoomButton(in window: AXUIElement) -> AXUIElement? {
        var buttonsRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(window, kAXZoomButtonAttribute as CFString, &buttonsRef) == .success,
              let buttonsRef = buttonsRef,
              CFGetTypeID(buttonsRef) == AXUIElementGetTypeID() else {
            return nil
        }
        return (buttonsRef as! AXUIElement)
    }

    // MARK: - Keyboard Shortcuts
    private func sendKeyShortcut(key: String, modifiers: NSEvent.ModifierFlags) {
        let source = CGEventSource(stateID: .hidSystemState)

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCodeForString(key), keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCodeForString(key), keyDown: false)

        let cgFlags = CGEventFlags(rawValue: UInt64(modifiers.rawValue))
        keyDown?.flags = cgFlags
        keyUp?.flags = cgFlags

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    private func sendKeyShortcut(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        let source = CGEventSource(stateID: .hidSystemState)

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)

        let cgFlags = CGEventFlags(rawValue: UInt64(modifiers.rawValue))
        keyDown?.flags = cgFlags
        keyUp?.flags = cgFlags

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    private func keyCodeForString(_ string: String) -> UInt16 {
        // Simplified key code mapping
        let keyMap: [String: UInt16] = [
            "a": 0x00, "s": 0x01, "d": 0x02, "f": 0x03, "h": 0x04, "g": 0x05, "z": 0x06, "x": 0x07,
            "c": 0x08, "v": 0x09, "b": 0x0B, "q": 0x0C, "w": 0x0D, "e": 0x0E, "r": 0x0F, "y": 0x10,
            "t": 0x11, "1": 0x12, "2": 0x13, "3": 0x14, "4": 0x15, "6": 0x16, "5": 0x17, "=": 0x18,
            "9": 0x19, "7": 0x1A, "-": 0x1B, "8": 0x1C, "0": 0x1D, "]": 0x1E, "[": 0x21, "p": 0x23,
            "o": 0x1F, "i": 0x22, "u": 0x20, "l": 0x25, "j": 0x26, "'": 0x27, "k": 0x28, ";": 0x29,
            "\\": 0x2A, ",": 0x2B, "/": 0x2C, "n": 0x2D, "m": 0x2E, ".": 0x2F, "`": 0x32,
            "\t": 0x30, " ": 0x31
        ]
        return keyMap[string.lowercased()] ?? 0
    }

    // MARK: - Window Monitoring
    private func startWindowMonitoring() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshWindows()
            }
        }
        refreshWindows()
    }

    deinit {
        refreshTimer?.invalidate()
        if let observer = accessibilityObserver {
            let appElement = AXUIElementCreateApplication(getpid())
            let notifications = [
                "AXWindowCreated",
                "AXWindowClosed",
                "AXWindowMoved",
                "AXWindowResized",
                "AXMainWindowChanged",
                "AXFocusedWindowChanged"
            ]
            for notification in notifications {
                AXObserverRemoveNotification(observer, appElement, notification as CFString)
            }
        }
    }
}