import SwiftUI
import AppKit

@main
struct TouchyOSApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var windowManager: WindowManager?
    var touchOverlayManager: TouchOverlayManager?
    var settingsWindow: NSWindow?
    var statusMenu: NSMenu?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure all setup runs on MainActor
        Task { @MainActor in
            // Set up menu bar item
            setupStatusItem()

            // Initialize managers
            windowManager = WindowManager.shared
            touchOverlayManager = TouchOverlayManager.shared

            // Request accessibility permissions
            requestAccessibilityPermissions()

            // Start monitoring for touch events
            startTouchMonitoring()
        }
    }

    @MainActor
    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "hand.tap.fill", accessibilityDescription: "TouchyOS")
            button.image?.isTemplate = true
            button.target = self
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Create popover with main menu
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 480)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: PopoverContentView())

        // Create contextual menu for right-click
        setupContextualMenu()
    }

    @MainActor
    func setupContextualMenu() {
        statusMenu = NSMenu()
        statusMenu?.autoenablesItems = false

        // Toggle Touch Mode
        let toggleItem = NSMenuItem(title: "Enable Touch Mode", action: #selector(toggleTouchMode(_:)), keyEquivalent: "")
        toggleItem.target = self
        toggleItem.state = SettingsService.shared.isEnabled ? .on : .off
        statusMenu?.addItem(toggleItem)

        statusMenu?.addItem(NSMenuItem.separator())

        // Quick actions
        let keyboardItem = NSMenuItem(title: "Show Virtual Keyboard", action: #selector(showVirtualKeyboard(_:)), keyEquivalent: "")
        keyboardItem.target = self
        statusMenu?.addItem(keyboardItem)

        let trackpadItem = NSMenuItem(title: "Show Virtual Trackpad", action: #selector(showVirtualTrackpad(_:)), keyEquivalent: "")
        trackpadItem.target = self
        statusMenu?.addItem(trackpadItem)

        statusMenu?.addItem(NSMenuItem.separator())

        // Window actions
        let snapLeftItem = NSMenuItem(title: "Snap Window Left", action: #selector(snapWindowLeft(_:)), keyEquivalent: "")
        snapLeftItem.target = self
        statusMenu?.addItem(snapLeftItem)

        let snapRightItem = NSMenuItem(title: "Snap Window Right", action: #selector(snapWindowRight(_:)), keyEquivalent: "")
        snapRightItem.target = self
        statusMenu?.addItem(snapRightItem)

        let missionControlItem = NSMenuItem(title: "Mission Control", action: #selector(showMissionControl(_:)), keyEquivalent: "")
        missionControlItem.target = self
        statusMenu?.addItem(missionControlItem)

        let appSwitcherItem = NSMenuItem(title: "App Switcher", action: #selector(showAppSwitcher(_:)), keyEquivalent: "")
        appSwitcherItem.target = self
        statusMenu?.addItem(appSwitcherItem)

        statusMenu?.addItem(NSMenuItem.separator())

        // Settings and About
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings(_:)), keyEquivalent: ",")
        settingsItem.target = self
        statusMenu?.addItem(settingsItem)

        let aboutItem = NSMenuItem(title: "About TouchyOS", action: #selector(showAbout(_:)), keyEquivalent: "")
        aboutItem.target = self
        statusMenu?.addItem(aboutItem)

        statusMenu?.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(title: "Quit TouchyOS", action: #selector(quitApp(_:)), keyEquivalent: "q")
        quitItem.target = self
        statusMenu?.addItem(quitItem)

        // Don't set menu on statusItem - we'll show it manually for right-click
        // statusItem?.menu = statusMenu
    }

    @objc @MainActor func statusItemClicked(_ sender: NSStatusBarButton) {
        guard let popover = popover else { return }

        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            // Right-click: show contextual menu at mouse position
            if let menu = statusMenu {
                updateMenuStates()
                // Show menu using the button as the view
                if let button = statusItem?.button {
                    let mouseLocation = NSEvent.mouseLocation
                    let locationInButton = button.convert(mouseLocation, from: nil)
                    menu.popUp(positioning: nil, at: locationInButton, in: button)
                }
            }
        } else {
            // Left-click: toggle popover
            if popover.isShown {
                popover.performClose(sender)
            } else {
                if let button = statusItem?.button {
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                }
            }
        }
    }

    nonisolated func updateMenuStates() {
        Task { @MainActor in
            guard let menu = statusMenu else { return }
            for item in menu.items {
                switch item.action {
                case #selector(toggleTouchMode(_:)):
                    item.state = SettingsService.shared.isEnabled ? .on : .off
                    item.title = SettingsService.shared.isEnabled ? "Disable Touch Mode" : "Enable Touch Mode"
                default:
                    break
                }
            }
        }
    }

    // MARK: - Menu Actions
    @objc func toggleTouchMode(_ sender: NSMenuItem) {
        Task { @MainActor in
            SettingsService.shared.isEnabled.toggle()
            updateMenuStates()
        }
    }

    @objc func showVirtualKeyboard(_ sender: NSMenuItem) {
        Task { @MainActor in
            TouchOverlayManager.shared.showVirtualKeyboard()
        }
    }

    @objc func showVirtualTrackpad(_ sender: NSMenuItem) {
        Task { @MainActor in
            TouchOverlayManager.shared.showVirtualTrackpad()
        }
    }

    @objc func snapWindowLeft(_ sender: NSMenuItem) {
        Task { @MainActor in
            if let window = windowManager?.frontmostWindow {
                windowManager?.performAction(.snap(windowId: window.id, to: .leftHalf))
            }
        }
    }

    @objc func snapWindowRight(_ sender: NSMenuItem) {
        Task { @MainActor in
            if let window = windowManager?.frontmostWindow {
                windowManager?.performAction(.snap(windowId: window.id, to: .rightHalf))
            }
        }
    }

    @objc func showMissionControl(_ sender: NSMenuItem) {
        Task { @MainActor in
            windowManager?.performAction(.showMissionControl)
        }
    }

    @objc func showAppSwitcher(_ sender: NSMenuItem) {
        Task { @MainActor in
            windowManager?.performAction(.showAppSwitcher)
        }
    }

    @objc func openSettings(_ sender: NSMenuItem) {
        Task { @MainActor in
            openSettingsWindow()
        }
    }

    @objc func showAbout(_ sender: NSMenuItem) {
        Task { @MainActor in
            let alert = NSAlert()
            alert.messageText = "TouchyOS"
            alert.informativeText = "TouchyOS v1.0\nTouch-friendly macOS experience for touchscreen MacBooks\n\nInspired by iPadOS"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    @objc func quitApp(_ sender: NSMenuItem) {
        Task { @MainActor in
            NSApplication.shared.terminate(nil)
        }
    }

    @MainActor
    func openSettingsWindow() {
        if settingsWindow == nil {
            struct SettingsWindowContent: View {
                @StateObject private var settingsService = SettingsService.shared
                var body: some View {
                    SettingsView()
                        .environmentObject(settingsService)
                }
            }

            let settingsView = SettingsWindowContent()
            let hostingController = NSHostingController(rootView: settingsView)
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            settingsWindow?.center()
            settingsWindow?.title = "TouchyOS Settings"
            settingsWindow?.contentViewController = hostingController
            settingsWindow?.isReleasedWhenClosed = false
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)

        if !trusted {
            // Show alert to guide user to System Settings
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAccessibilityAlert()
            }
        }
    }

    func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "TouchyOS needs accessibility access to manage windows and provide touch-friendly controls.\n\nPlease grant permission in System Settings > Privacy & Security > Accessibility. If TouchyOS doesn't appear in the list, click the '+' button and select TouchyOS from Applications."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Later")

        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }

    func startTouchMonitoring() {
        // Monitor for touch events globally
        NSEvent.addGlobalMonitorForEvents(matching: [.gesture, .magnify, .swipe, .rotate, .beginGesture, .endGesture]) { event in
            Task { @MainActor in
                self.touchOverlayManager?.handleTouchEvent(event)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        touchOverlayManager?.cleanup()
    }
}