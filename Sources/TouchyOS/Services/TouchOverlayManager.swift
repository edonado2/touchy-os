import Foundation
import AppKit
import Carbon
import SwiftUI

// MARK: - Touch Overlay Manager
@MainActor
class TouchOverlayManager: ObservableObject {
    static let shared = TouchOverlayManager()

    @Published var config: TouchOverlayConfig = TouchOverlayConfig()
    @Published var isOverlayVisible: Bool = false
    @Published var activeGesture: TouchGestureType?

    private var overlayWindow: TouchOverlayWindow?
    private var virtualTrackpadWindow: VirtualTrackpadWindow?
    private var virtualKeyboardWindow: VirtualKeyboardWindow?
    private var gestureRecognizer: TouchGestureRecognizer?
    var settings: TouchyOSSettings = .default

    private init() {
        setupGestureRecognizer()
        loadSettings()
    }

    // MARK: - Setup
    private func setupGestureRecognizer() {
        gestureRecognizer = TouchGestureRecognizer { [weak self] gesture in
            Task { @MainActor in
                self?.handleGesture(gesture)
            }
        }
    }

    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "TouchyOSSettings"),
           let decoded = try? JSONDecoder().decode(TouchyOSSettings.self, from: data) {
            self.settings = decoded
        }
    }

    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "TouchyOSSettings")
        }
    }

    // MARK: - Touch Event Handling
    func handleTouchEvent(_ event: NSEvent) {
        guard settings.isEnabled else { return }

        switch event.type {
        case .gesture, .magnify, .swipe, .rotate, .beginGesture, .endGesture:
            gestureRecognizer?.processEvent(event)
        default:
            break
        }
    }

    private func handleGesture(_ gesture: TouchGestureType) {
        activeGesture = gesture

        switch gesture {
        case .tap(let location):
            handleTap(at: location)
        case .doubleTap(let location):
            handleDoubleTap(at: location)
        case .longPress(let location, let duration):
            handleLongPress(at: location, duration: duration)
        case .pan(let translation, let velocity):
            handlePan(translation: translation, velocity: velocity)
        case .pinch(let scale, let velocity):
            handlePinch(scale: scale, velocity: velocity)
        case .rotate(let rotation, let velocity):
            handleRotate(rotation: rotation, velocity: velocity)
        case .swipe(let direction):
            handleSwipe(direction: direction)
        case .edgeSwipe(let edge, let translation):
            handleEdgeSwipe(edge: edge, translation: translation)
        }

        // Provide haptic feedback
        if settings.hapticFeedbackEnabled {
            provideHapticFeedback(for: gesture)
        }

        // Clear active gesture after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.activeGesture = nil
        }
    }

    // MARK: - Gesture Handlers
    private func handleTap(at location: CGPoint) {
        // Check if tap is on a touch zone
        if let zone = config.zones.first(where: { $0.frame.contains(location) }) {
            WindowManager.shared.performAction(zone.action)
            showTouchFeedback(at: location)
        }
    }

    private func handleDoubleTap(at location: CGPoint) {
        // Double tap on title bar area to maximize
        if let window = WindowManager.shared.windows.first(where: {
            $0.bounds.contains(location) && location.y > $0.bounds.maxY - 40
        }) {
            WindowManager.shared.performAction(.toggleFullscreen(windowId: window.id))
        }
    }

    private func handleLongPress(at location: CGPoint, duration: TimeInterval) {
        // Show context menu or window controls
        if let window = WindowManager.shared.windows.first(where: { $0.bounds.contains(location) }) {
            showWindowControls(for: window, at: location)
        }
    }

    private func handlePan(translation: CGPoint, velocity: CGPoint) {
        // Move window with one finger drag on title bar area
        if let window = WindowManager.shared.frontmostWindow {
            let newOrigin = CGPoint(
                x: window.bounds.origin.x + translation.x,
                y: window.bounds.origin.y + translation.y
            )
            WindowManager.shared.performAction(.move(windowId: window.id, to: newOrigin))
        }
    }

    private func handlePinch(scale: CGFloat, velocity: CGFloat) {
        // Pinch to zoom/resize window
        if let window = WindowManager.shared.frontmostWindow {
            let newSize = CGSize(
                width: window.bounds.width * scale,
                height: window.bounds.height * scale
            )
            WindowManager.shared.performAction(.resize(windowId: window.id, to: newSize))
        }
    }

    private func handleRotate(rotation: CGFloat, velocity: CGFloat) {
        // Rotate not typically used for windows, could be for rotation lock
    }

    private func handleSwipe(direction: SwipeDirection) {
        switch direction {
        case .up:
            if settings.enableThreeFingerSwipe {
                WindowManager.shared.performAction(.showMissionControl)
            }
        case .down:
            if settings.enableThreeFingerSwipe {
                WindowManager.shared.performAction(.showAppSwitcher)
            }
        case .left:
            if settings.enableFourFingerSwipe {
                // Switch to next desktop
                sendKeyShortcut(keyCode: 0x7C, modifiers: [.control]) // Right arrow
            }
        case .right:
            if settings.enableFourFingerSwipe {
                // Switch to previous desktop
                sendKeyShortcut(keyCode: 0x7B, modifiers: [.control]) // Left arrow
            }
        }
    }

    private func handleEdgeSwipe(edge: Edge, translation: CGFloat) {
        guard settings.enableEdgeGestures else { return }

        switch edge {
        case .bottom:
            // Show dock/app switcher
            if translation > 50 {
                WindowManager.shared.performAction(.showAppSwitcher)
            }
        case .top:
            // Show menu bar / mission control
            if translation > 50 {
                WindowManager.shared.performAction(.showMissionControl)
            }
        case .left:
            // Snap to left
            if let window = WindowManager.shared.frontmostWindow,
               translation > settings.snapThreshold {
                WindowManager.shared.performAction(.snap(windowId: window.id, to: .leftHalf))
            }
        case .right:
            // Snap to right
            if let window = WindowManager.shared.frontmostWindow,
               translation > settings.snapThreshold {
                WindowManager.shared.performAction(.snap(windowId: window.id, to: .rightHalf))
            }
        }
    }

    // MARK: - Touch Zones
    func updateTouchZones(for window: WindowInfo) {
        var zones: [TouchZone] = []
        let bounds = window.bounds
        let buttonSize: CGFloat = 44 // Touch-friendly size
        let padding: CGFloat = 8

        // Close button (top-left)
        zones.append(TouchZone(
            frame: CGRect(x: bounds.minX + padding, y: bounds.maxY - buttonSize - padding, width: buttonSize, height: buttonSize),
            action: .close(windowId: window.id),
            gestureType: .tap(location: .zero)
        ))

        // Minimize button
        zones.append(TouchZone(
            frame: CGRect(x: bounds.minX + padding + buttonSize + 4, y: bounds.maxY - buttonSize - padding, width: buttonSize, height: buttonSize),
            action: .minimize(windowId: window.id),
            gestureType: .tap(location: .zero)
        ))

        // Maximize/Zoom button
        zones.append(TouchZone(
            frame: CGRect(x: bounds.minX + padding + (buttonSize + 4) * 2, y: bounds.maxY - buttonSize - padding, width: buttonSize, height: buttonSize),
            action: .maximize(windowId: window.id),
            gestureType: .tap(location: .zero)
        ))

        // Title bar drag area (large area for moving)
        zones.append(TouchZone(
            frame: CGRect(x: bounds.minX + buttonSize * 3 + padding * 4, y: bounds.maxY - 40, width: bounds.width - buttonSize * 3 - padding * 4 - 100, height: 40),
            action: .move(windowId: window.id, to: .zero), // Placeholder, actual move handled by pan
            gestureType: .pan(translation: .zero, velocity: .zero)
        ))

        // Resize handle (bottom-right)
        zones.append(TouchZone(
            frame: CGRect(x: bounds.maxX - buttonSize - padding, y: bounds.minY + padding, width: buttonSize, height: buttonSize),
            action: .resize(windowId: window.id, to: .zero), // Placeholder
            gestureType: .pan(translation: .zero, velocity: .zero)
        ))

        // Snap zones (appear on drag)
        if settings.enableWindowSnap {
            let snapPositions: [SnapPosition] = [.leftHalf, .rightHalf, .topHalf, .bottomHalf, .fullScreen]
            for (index, position) in snapPositions.enumerated() {
                let snapFrame = WindowManager.shared.calculateSnapFrame(for: position, screenFrame: NSScreen.main?.visibleFrame ?? .zero)
                zones.append(TouchZone(
                    frame: snapFrame.insetBy(dx: -20, dy: -20),
                    action: .snap(windowId: window.id, to: position),
                    gestureType: .pan(translation: .zero, velocity: .zero)
                ))
            }
        }

        config.zones = zones
    }

    // MARK: - Virtual Trackpad
    func showVirtualTrackpad(at location: CGPoint? = nil) {
        guard settings.enableVirtualTrackpad else { return }

        if virtualTrackpadWindow == nil {
            virtualTrackpadWindow = VirtualTrackpadWindow()
        }

        let screenFrame = NSScreen.main?.visibleFrame ?? .zero
        let trackpadSize = CGSize(width: 300, height: 200)
        let x = location?.x ?? screenFrame.midX - trackpadSize.width / 2
        let y = location?.y ?? screenFrame.minY + 100

        virtualTrackpadWindow?.setFrameOrigin(NSPoint(x: x, y: y))
        // Show without becoming key window (don't steal focus)
        virtualTrackpadWindow?.orderFront(nil)
    }

    func hideVirtualTrackpad() {
        virtualTrackpadWindow?.orderOut(nil)
    }

    // MARK: - Virtual Keyboard
    private var keyboardTargetAppBundleId: String?
    private var keyboardMouseMonitor: Any?

    func showVirtualKeyboard() {
        guard settings.enableVirtualKeyboard else { return }

        // Remember the frontmost app (the one user wants to type in)
        keyboardTargetAppBundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier

        if virtualKeyboardWindow == nil {
            virtualKeyboardWindow = VirtualKeyboardWindow(settings: settings, targetAppBundleId: keyboardTargetAppBundleId)
        } else {
            virtualKeyboardWindow?.targetAppBundleId = keyboardTargetAppBundleId
        }

        // Position at bottom center of screen
        if let window = virtualKeyboardWindow,
           let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let windowFrame = window.frame
            let x = screenFrame.midX - windowFrame.width / 2
            let y = screenFrame.minY + 20 // 20pts from bottom
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }

        // Show without becoming key window (don't steal focus)
        virtualKeyboardWindow?.orderFront(nil)

        // Install global mouse monitor to instantly re-activate target app on any click
        installKeyboardMouseMonitor()
    }

    func hideVirtualKeyboard() {
        virtualKeyboardWindow?.orderOut(nil)
        removeKeyboardMouseMonitor()
    }

    private func installKeyboardMouseMonitor() {
        removeKeyboardMouseMonitor()
        keyboardMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { [weak self] event in
            guard let self = self,
                  let window = self.virtualKeyboardWindow,
                  let bundleId = self.keyboardTargetAppBundleId,
                  let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first else { return }

            // Check if click is on the keyboard window
            let locationInWindow = window.convertFromScreen(NSRect(origin: event.locationInWindow, size: .zero)).origin
            if window.frame.contains(locationInWindow) {
                // Instantly re-activate target app before it can lose focus
                app.activate(options: [])
            }
        }
    }

    private func removeKeyboardMouseMonitor() {
        if let monitor = keyboardMouseMonitor {
            NSEvent.removeMonitor(monitor)
            keyboardMouseMonitor = nil
        }
    }

    // MARK: - Overlay Window
    func showOverlay() {
        guard settings.showTouchVisualizer else { return }

        if overlayWindow == nil {
            overlayWindow = TouchOverlayWindow()
        }

        overlayWindow?.makeKeyAndOrderFront(nil)
        isOverlayVisible = true
    }

    func hideOverlay() {
        overlayWindow?.orderOut(nil)
        isOverlayVisible = false
    }

    func toggleOverlay() {
        if isOverlayVisible {
            hideOverlay()
        } else {
            showOverlay()
        }
    }

    // MARK: - Window Controls Overlay
    private func showWindowControls(for window: WindowInfo, at location: CGPoint) {
        // Create a popover with window controls
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 200)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: WindowControlsWrapper(window: window))

        // Create a temporary view for positioning the popover
        let anchorView = NSView(frame: NSRect(x: location.x, y: location.y, width: 1, height: 1))
        if let screen = NSScreen.main {
            // Convert location to screen coordinates (flipped Y)
            let screenRect = NSRect(x: location.x, y: screen.frame.height - location.y, width: 1, height: 1)
            anchorView.setFrameOrigin(screenRect.origin)
            // Add to screen's content view or use a window
            if let window = NSApp.windows.first(where: { $0.screen == screen }) {
                window.contentView?.addSubview(anchorView)
                popover.show(relativeTo: anchorView.bounds, of: anchorView, preferredEdge: .minY)
            }
        }
    }

    // MARK: - Feedback
    private func showTouchFeedback(at location: CGPoint) {
        // Visual feedback - could be a ripple effect
        if settings.showTouchVisualizer {
            // TODO: Add touch ripple animation
        }
    }

    private func provideHapticFeedback(for gesture: TouchGestureType) {
        // Use NSHapticFeedback if available
        let feedbackType: NSHapticFeedbackManager.FeedbackPattern

        switch gesture {
        case .tap, .doubleTap:
            feedbackType = .generic
        case .longPress:
            feedbackType = .alignment
        case .swipe:
            feedbackType = .levelChange
        default:
            feedbackType = .generic
        }

        NSHapticFeedbackManager.defaultPerformer.perform(feedbackType, performanceTime: .default)
    }

    // MARK: - Keyboard Shortcuts
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

    // MARK: - Cleanup
    func cleanup() {
        overlayWindow?.close()
        virtualTrackpadWindow?.close()
        virtualKeyboardWindow?.close()
        removeKeyboardMouseMonitor()
    }
}

// MARK: - Touch Gesture Recognizer
class TouchGestureRecognizer {
    private let callback: (TouchGestureType) -> Void
    private var touchStartTime: Date?
    private var touchStartLocation: CGPoint?
    private var lastTouchLocation: CGPoint?
    private var touchCount: Int = 0
    private var isGestureInProgress: Bool = false

    init(callback: @escaping (TouchGestureType) -> Void) {
        self.callback = callback
    }

    func processEvent(_ event: NSEvent) {
        switch event.type {
        case .beginGesture:
            isGestureInProgress = true
            touchStartTime = Date()
            touchStartLocation = event.locationInWindow
            touchCount = 1 // macOS doesn't provide touchCount directly

        case .gesture:
            if let startTime = touchStartTime,
               let startLocation = touchStartLocation {
                let duration = Date().timeIntervalSince(startTime)
                let translation = CGPoint(
                    x: event.locationInWindow.x - startLocation.x,
                    y: event.locationInWindow.y - startLocation.y
                )

                if duration > 0.5 && abs(translation.x) < 10 && abs(translation.y) < 10 {
                    callback(.longPress(location: startLocation, duration: duration))
                }
            }

        case .magnify:
            callback(.pinch(scale: 1.0 + event.magnification, velocity: event.magnification))

        case .swipe:
            let direction: SwipeDirection
            if abs(event.deltaX) > abs(event.deltaY) {
                direction = event.deltaX > 0 ? .right : .left
            } else {
                direction = event.deltaY > 0 ? .down : .up
            }
            callback(.swipe(direction: direction))

        case .rotate:
            callback(.rotate(rotation: CGFloat(event.rotation), velocity: CGFloat(event.rotation)))

        case .endGesture:
            isGestureInProgress = false
            touchStartTime = nil
            touchStartLocation = nil

        default:
            break
        }
    }
}

// MARK: - Overlay Windows
class TouchOverlayWindow: NSWindow {
    init() {
        super.init(
            contentRect: NSScreen.main?.frame ?? .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.level = .floating
        self.isOpaque = false
        self.backgroundColor = .clear
        self.ignoresMouseEvents = true
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        self.contentView = NSHostingView(rootView: TouchOverlayView())
    }
}

class VirtualTrackpadWindow: NSWindow {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
            styleMask: [.borderless, .nonactivatingPanel, .resizable],
            backing: .buffered,
            defer: false
        )

        self.level = .floating
        self.isOpaque = false
        self.backgroundColor = .clear
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        self.contentView = NSHostingView(rootView: VirtualTrackpadWrapper())
        self.titlebarAppearsTransparent = true
        self.hasShadow = true
        self.hidesOnDeactivate = false
        self.isReleasedWhenClosed = false

        }

    override var canBecomeKey: Bool { return false }
    override var canBecomeMain: Bool { return false }
    override var acceptsFirstResponder: Bool { return false }
}

struct VirtualTrackpadWrapper: View {
    var body: some View {
        VirtualTrackpadView()
            .environmentObject(SettingsService.shared)
    }
}

class VirtualKeyboardWindow: NSWindow {
    let settings: TouchyOSSettings
    var targetAppBundleId: String?

    init(settings: TouchyOSSettings, targetAppBundleId: String? = nil) {
        self.settings = settings
        self.targetAppBundleId = targetAppBundleId
        // Larger default size, will be scaled by keyboardSize setting in the view
        let defaultWidth: CGFloat = 1000
        let defaultHeight: CGFloat = 350
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: defaultWidth, height: defaultHeight),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.level = .floating
        self.isOpaque = false
        self.backgroundColor = .clear
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        self.contentView = NSHostingView(rootView: VirtualKeyboardWrapper(settings: settings, targetAppBundleId: targetAppBundleId))
        self.titlebarAppearsTransparent = true
        self.hasShadow = true
        self.hidesOnDeactivate = false
        self.isReleasedWhenClosed = false
    }

    // Prevent window from becoming key even when clicked
    override var canBecomeKey: Bool { return false }
    override var canBecomeMain: Bool { return false }
    override var acceptsFirstResponder: Bool { return false }
}

struct VirtualKeyboardWrapper: View {
    let settings: TouchyOSSettings
    let targetAppBundleId: String?
    var body: some View {
        VirtualKeyboardView(settings: settings, targetAppBundleId: targetAppBundleId)
            .environmentObject(SettingsService.shared)
    }
}

struct WindowControlsWrapper: View {
    let window: WindowInfo
    var body: some View {
        WindowControlsView(window: window)
            .environmentObject(SettingsService.shared)
    }
}