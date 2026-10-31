import SwiftUI

// MARK: - Popover Content Wrapper
struct PopoverContentView: View {
    var body: some View {
        MenuBarView()
            .environmentObject(SettingsService.shared)
    }
}

// MARK: - Menu Bar View
struct MenuBarView: View {
    @EnvironmentObject var settingsService: SettingsService
    @StateObject var windowManager = WindowManager.shared
    @StateObject var overlayManager = TouchOverlayManager.shared
    @State private var showSettings = false
    @State private var showAbout = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Quick Actions
            quickActionsView

            Divider()

            // Window List
            windowListView

            Divider()

            // Footer
            footerView
        }
        .frame(width: 320)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "hand.tap.fill")
                .font(.title2)
                .foregroundColor(Color.accentColor(from: settingsService.accentColor))

            VStack(alignment: .leading, spacing: 2) {
                Text("TouchyOS")
                    .font(.headline)
                Text("Touch-Friendly macOS")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Status indicator
            Circle()
                .fill(settingsService.isEnabled ? Color.green : Color.red)
                .frame(width: 8, height: 8)
        }
        .padding()
    }

    private var quickActionsView: some View {
        VStack(spacing: 8) {
            // Toggle switches
            HStack {
                Toggle("Touch Mode", isOn: $settingsService.isEnabled)
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }
            .padding(.horizontal)

            // Action buttons
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MenuBarButton(
                    icon: "keyboard",
                    title: "Keyboard",
                    color: .blue
                ) {
                    overlayManager.showVirtualKeyboard()
                }

                MenuBarButton(
                    icon: "trackpad",
                    title: "Trackpad",
                    color: .green
                ) {
                    overlayManager.showVirtualTrackpad()
                }

                MenuBarButton(
                    icon: "square.grid.2x2",
                    title: "Snap",
                    color: .orange
                ) {
                    if let window = windowManager.frontmostWindow {
                        windowManager.performAction(.snap(windowId: window.id, to: .leftHalf))
                    }
                }

                MenuBarButton(
                    icon: "rectangle.3.offgrid",
                    title: "Mission Control",
                    color: .purple
                ) {
                    windowManager.performAction(.showMissionControl)
                }
            }
            .padding(.horizontal)

            // Visualizer toggle
            HStack {
                Toggle("Touch Visualizer", isOn: $settingsService.showTouchVisualizer)
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    private var windowListView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Open Windows")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Spacer()

                Button("Refresh") {
                    windowManager.refreshWindows()
                }
                .font(.caption)
                .controlSize(.mini)
            }
            .padding(.horizontal)

            if windowManager.windows.isEmpty {
                Text("No windows found")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(windowManager.windows.prefix(10)) { window in
                            WindowRowView(window: window)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .frame(maxHeight: 200)
            }
        }
    }

    private var footerView: some View {
        HStack {
            Button("Settings...") {
                showSettings = true
            }
            .controlSize(.small)

            Spacer()

            Button("About") {
                showAbout = true
            }
            .controlSize(.small)

            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .controlSize(.small)
        }
        .padding()
        .sheet(isPresented: $showSettings) {
            SettingsSheetContent()
        }
        .alert("About TouchyOS", isPresented: $showAbout) {
            Button("OK") { }
        } message: {
            Text("TouchyOS v1.0\nTouch-friendly macOS experience for touchscreen MacBooks\n\nInspired by iPadOS")
        }
    }
}

// MARK: - Settings Sheet Content
struct SettingsSheetContent: View {
    var body: some View {
        SettingsView()
            .environmentObject(SettingsService.shared)
            .frame(width: 500, height: 600)
    }
}

// MARK: - Menu Bar Button
struct MenuBarButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Window Row View
struct WindowRowView: View {
    let window: WindowInfo
    @StateObject var windowManager = WindowManager.shared
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            // App icon
            if let icon = window.appIcon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .cornerRadius(4)
            } else {
                Image(systemName: "app.fill")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
            }

            // Window info
            VStack(alignment: .leading, spacing: 2) {
                Text(window.ownerName)
                    .font(.subheadline)
                    .lineLimit(1)

                if !window.windowTitle.isEmpty {
                    Text(window.windowTitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Actions
            if isHovered {
                HStack(spacing: 4) {
                    TouchActionButton(icon: "arrow.up.left.and.arrow.down.right") {
                        windowManager.performAction(.snap(windowId: window.id, to: .leftHalf))
                    }

                    TouchActionButton(icon: "arrow.up.right.and.arrow.down.left") {
                        windowManager.performAction(.snap(windowId: window.id, to: .rightHalf))
                    }

                    TouchActionButton(icon: "xmark") {
                        windowManager.performAction(.close(windowId: window.id))
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isHovered ? Color(NSColor.selectedControlColor) : Color.clear)
        .cornerRadius(8)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            windowManager.performAction(.bringToFront(windowId: window.id))
        }
    }
}

// MARK: - Touch Action Button
struct TouchActionButton: View {
    let icon: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 32, height: 32)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Window Controls View
struct WindowControlsView: View {
    let window: WindowInfo
    @StateObject var windowManager = WindowManager.shared
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            // Window info
            HStack {
                if let icon = window.appIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .cornerRadius(6)
                }

                VStack(alignment: .leading) {
                    Text(window.ownerName)
                        .font(.headline)
                    Text(window.windowTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }

            Divider()

            // Control buttons
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                TouchControlButton(
                    icon: "arrow.up.left.and.arrow.down.right",
                    title: "Left Half",
                    color: .blue
                ) {
                    windowManager.performAction(.snap(windowId: window.id, to: .leftHalf))
                    dismiss()
                }

                TouchControlButton(
                    icon: "arrow.up.right.and.arrow.down.left",
                    title: "Right Half",
                    color: .blue
                ) {
                    windowManager.performAction(.snap(windowId: window.id, to: .rightHalf))
                    dismiss()
                }

                TouchControlButton(
                    icon: "square.resize",
                    title: "Full Screen",
                    color: .green
                ) {
                    windowManager.performAction(.toggleFullscreen(windowId: window.id))
                    dismiss()
                }

                TouchControlButton(
                    icon: "square.dashed",
                    title: "Center",
                    color: .orange
                ) {
                    windowManager.performAction(.snap(windowId: window.id, to: .center))
                    dismiss()
                }

                TouchControlButton(
                    icon: "minus.rectangle",
                    title: "Minimize",
                    color: .yellow
                ) {
                    windowManager.performAction(.minimize(windowId: window.id))
                    dismiss()
                }

                TouchControlButton(
                    icon: "xmark.circle",
                    title: "Close",
                    color: .red
                ) {
                    windowManager.performAction(.close(windowId: window.id))
                    dismiss()
                }
            }

            Spacer()
        }
        .padding(20)
    }
}

// MARK: - Touch Control Button
struct TouchControlButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}