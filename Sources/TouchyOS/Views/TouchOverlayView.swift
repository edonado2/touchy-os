import SwiftUI

// MARK: - Touch Overlay View
struct TouchOverlayView: View {
    @StateObject var overlayManager = TouchOverlayManager.shared
    @StateObject var windowManager = WindowManager.shared
    @EnvironmentObject var settingsService: SettingsService

    var body: some View {
        ZStack {
            // Touch zones visualization
            if settingsService.showTouchVisualizer {
                ForEach(overlayManager.config.zones) { zone in
                    TouchZoneView(zone: zone)
                }
            }

            // Active gesture visualization
            if let gesture = overlayManager.activeGesture {
                GestureVisualizationView(gesture: gesture)
            }

            // Touch ripple effect
            if let lastTouch = overlayManager.config.lastTouchLocation as CGPoint? {
                TouchRippleView(location: lastTouch)
            }
        }
        .onAppear {
            // Update zones for frontmost window
            if let window = windowManager.frontmostWindow {
                overlayManager.updateTouchZones(for: window)
            }
        }
        .onChange(of: windowManager.frontmostWindow) { _, newWindow in
            if let window = newWindow {
                overlayManager.updateTouchZones(for: window)
            }
        }
    }
}

// MARK: - Touch Zone View
struct TouchZoneView: View {
    let zone: TouchZone
    @EnvironmentObject var settingsService: SettingsService
    @State private var isHovered = false

    var body: some View {
        Rectangle()
            .fill(zoneColor)
            .frame(width: zone.frame.width, height: zone.frame.height)
            .position(x: zone.frame.midX, y: zone.frame.midY)
            .overlay(
                RoundedRectangle(cornerRadius: settingsService.settings.cornerRadius)
                    .stroke(Color.primary.opacity(0.3), lineWidth: 1)
            )
            .overlay(
                zoneIcon
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary.opacity(0.6))
            )
            .opacity(zone.isActive ? 1.0 : settingsService.settings.overlayOpacity * 0.5)
            .animation(.easeInOut(duration: 0.15), value: zone.isActive)
            .onHover { hovering in
                isHovered = hovering
            }
    }

    private var zoneColor: Color {
        if zone.isActive {
            return Color.accentColor.opacity(0.3)
        }
        return Color.accentColor.opacity(0.1)
    }

    @ViewBuilder
    private var zoneIcon: some View {
        switch zone.action {
        case .close: Image(systemName: "xmark")
        case .minimize: Image(systemName: "minus")
        case .maximize: Image(systemName: "plus")
        case .snap(_, let position):
            Image(systemName: position.icon)
        case .move: Image(systemName: "hand.draw")
        case .resize: Image(systemName: "arrow.up.left.and.arrow.down.right")
        default: Image(systemName: "touchid")
        }
    }
}

// MARK: - Gesture Visualization View
struct GestureVisualizationView: View {
    let gesture: TouchGestureType
    @State private var animationProgress: CGFloat = 0

    var body: some View {
        Group {
            switch gesture {
            case .tap(let location), .doubleTap(let location):
                TapVisualization(location: location, progress: animationProgress)

            case .longPress(let location, _):
                LongPressVisualization(location: location, progress: animationProgress)

            case .pan(let translation, _):
                PanVisualization(translation: translation, progress: animationProgress)

            case .pinch(let scale, _):
                PinchVisualization(scale: scale, progress: animationProgress)

            case .swipe(let direction):
                SwipeVisualization(direction: direction, progress: animationProgress)

            case .edgeSwipe(let edge, let translation):
                EdgeSwipeVisualization(edge: edge, translation: translation, progress: animationProgress)

            default:
                EmptyView()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animationProgress = 1
            }
        }
    }
}

// MARK: - Tap Visualization
struct TapVisualization: View {
    let location: CGPoint
    let progress: CGFloat

    var body: some View {
        Circle()
            .stroke(Color.accentColor, lineWidth: 3 * (1 - progress))
            .frame(width: 50 * progress, height: 50 * progress)
            .position(location)
            .opacity(1 - progress)
    }
}

// MARK: - Long Press Visualization
struct LongPressVisualization: View {
    let location: CGPoint
    let progress: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.2 * progress))
                .frame(width: 80, height: 80)
                .position(location)

            Circle()
                .stroke(Color.accentColor, lineWidth: 2)
                .frame(width: 60 * progress, height: 60 * progress)
                .position(location)
        }
    }
}

// MARK: - Pan Visualization
struct PanVisualization: View {
    let translation: CGPoint
    let progress: CGFloat

    var body: some View {
        let startPoint = CGPoint(x: 0, y: 0)
        let endPoint = CGPoint(x: translation.x, y: translation.y)

        Path { path in
            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
        .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [10, 5]))
        .opacity(1 - progress)
    }
}

// MARK: - Pinch Visualization
struct PinchVisualization: View {
    let scale: CGFloat
    let progress: CGFloat

    var body: some View {
        let center = CGPoint(x: 0, y: 0)
        let radius = 60 * scale

        Circle()
            .stroke(Color.accentColor, lineWidth: 2)
            .frame(width: radius * progress * 2, height: radius * progress * 2)
            .position(center)
    }
}

// MARK: - Swipe Visualization
struct SwipeVisualization: View {
    let direction: SwipeDirection
    let progress: CGFloat

    var body: some View {
        let arrowOffset: CGFloat = 100 * progress
        let arrowLength: CGFloat = 80

        Path { path in
            let start: CGPoint
            let end: CGPoint

            switch direction {
            case .up:
                start = CGPoint(x: 0, y: arrowOffset)
                end = CGPoint(x: 0, y: arrowOffset - arrowLength)
            case .down:
                start = CGPoint(x: 0, y: -arrowOffset)
                end = CGPoint(x: 0, y: -arrowOffset + arrowLength)
            case .left:
                start = CGPoint(x: arrowOffset, y: 0)
                end = CGPoint(x: arrowOffset - arrowLength, y: 0)
            case .right:
                start = CGPoint(x: -arrowOffset, y: 0)
                end = CGPoint(x: -arrowOffset + arrowLength, y: 0)
            }

            path.move(to: start)
            path.addLine(to: end)

            // Arrow head
            let headLength: CGFloat = 20
            let headAngle: CGFloat = .pi / 6

            let dx = end.x - start.x
            let dy = end.y - start.y
            let angle = atan2(dy, dx)

            path.move(to: end)
            path.addLine(to: CGPoint(
                x: end.x - headLength * cos(angle - headAngle),
                y: end.y - headLength * sin(angle - headAngle)
            ))
            path.move(to: end)
            path.addLine(to: CGPoint(
                x: end.x - headLength * cos(angle + headAngle),
                y: end.y - headLength * sin(angle + headAngle)
            ))
        }
        .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
        .opacity(1 - progress)
    }
}

// MARK: - Edge Swipe Visualization
struct EdgeSwipeVisualization: View {
    let edge: Edge
    let translation: CGFloat
    let progress: CGFloat

    var body: some View {
        let screenBounds = NSScreen.main?.frame ?? .zero
        let barWidth: CGFloat = 60
        // let maxTranslation: CGFloat = 200 // reserved for future use

        Rectangle()
            .fill(Color.accentColor.opacity(0.3 * progress))
            .frame(
                width: edge == .left || edge == .right ? barWidth : screenBounds.width,
                height: edge == .top || edge == .bottom ? barWidth : screenBounds.height
            )
            .position(edgePosition(screenBounds: screenBounds, barWidth: barWidth))
            .overlay(
                edgeIndicator
            )
    }

    private func edgePosition(screenBounds: CGRect, barWidth: CGFloat) -> CGPoint {
        switch edge {
        case .top:
            return CGPoint(x: screenBounds.midX, y: barWidth / 2)
        case .bottom:
            return CGPoint(x: screenBounds.midX, y: screenBounds.height - barWidth / 2)
        case .left:
            return CGPoint(x: barWidth / 2, y: screenBounds.midY)
        case .right:
            return CGPoint(x: screenBounds.width - barWidth / 2, y: screenBounds.midY)
        }
    }

    @ViewBuilder
    private var edgeIndicator: some View {
        switch edge {
        case .top:
            Image(systemName: "chevron.down")
                .font(.title)
                .foregroundColor(.accentColor)
        case .bottom:
            Image(systemName: "chevron.up")
                .font(.title)
                .foregroundColor(.accentColor)
        case .left:
            Image(systemName: "chevron.right")
                .font(.title)
                .foregroundColor(.accentColor)
        case .right:
            Image(systemName: "chevron.left")
                .font(.title)
                .foregroundColor(.accentColor)
        }
    }
}

// MARK: - Touch Ripple View
struct TouchRippleView: View {
    let location: CGPoint
    @State private var ripples: [Ripple] = []
    @EnvironmentObject var settingsService: SettingsService

    struct Ripple: Identifiable {
        let id = UUID()
        let location: CGPoint
        var radius: CGFloat = 0
        var opacity: Double = 1
    }

    var body: some View {
        ZStack {
            ForEach(ripples) { ripple in
                Circle()
                    .stroke(Color.accentColor, lineWidth: 2)
                    .frame(width: ripple.radius * 2, height: ripple.radius * 2)
                    .position(ripple.location)
                    .opacity(ripple.opacity)
            }
        }
        .onAppear {
            addRipple(at: location)
        }
    }

    private func addRipple(at location: CGPoint) {
        let ripple = Ripple(location: location)
        ripples.append(ripple)

        withAnimation(.easeOut(duration: 0.8)) {
            if let index = ripples.firstIndex(where: { $0.id == ripple.id }) {
                ripples[index].radius = 60
                ripples[index].opacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            ripples.removeAll { $0.id == ripple.id }
        }
    }
}