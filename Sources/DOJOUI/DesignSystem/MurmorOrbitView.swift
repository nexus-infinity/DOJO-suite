import SwiftUI
import DOJOShared

// MARK: - MurmorOrbitView

/// Hardware topology visualiser — shows registered murmors orbiting the Observer.
///
/// Active murmors (high activityLevel) orbit close in; idle/offline murmors drift out.
/// Uses `RelevanceGravity.normalizedLayout(for:)` for spatial positioning.
public struct MurmorOrbitView: View {

    public let murmors: [MurmorIdentity]
    public var showLabels: Bool = true

    public init(murmors: [MurmorIdentity], showLabels: Bool = true) {
        self.murmors = murmors
        self.showLabels = showLabels
    }

    public var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let layout = RelevanceGravity.normalizedLayout(for: murmors)

            ZStack {
                // Orbit rings — passive reference at active/idle radii
                orbitRing(radius: RelevanceGravity.activeRadius / RelevanceGravity.idleRadius * size * 0.5,
                          center: center, opacity: 0.12)
                orbitRing(radius: size * 0.5 - 2,
                          center: center, opacity: 0.06)

                // Connection lines from center to each murmor
                ForEach(layout, id: \.identity.id) { item in
                    let pt = point(from: item.point, size: size, center: center)
                    Path { p in
                        p.move(to: center)
                        p.addLine(to: pt)
                    }
                    .stroke(
                        color(for: item.identity.deviceClass)
                            .opacity(item.identity.activityLevel * 0.3),
                        lineWidth: 0.5
                    )
                }

                // Observer center node
                Circle()
                    .fill(FieldPalette.surfaceRaised)
                    .frame(width: 36, height: 36)
                    .overlay(Circle().stroke(FieldPalette.border, lineWidth: 1))
                    .overlay(
                        Text("◎")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundStyle(FieldPalette.textPrimary)
                    )
                    .position(center)

                // Murmor nodes
                ForEach(layout, id: \.identity.id) { item in
                    MurmorNode(
                        identity: item.identity,
                        showLabel: showLabels,
                        nodeColor: color(for: item.identity.deviceClass)
                    )
                    .position(point(from: item.point, size: size, center: center))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Helpers

    private func point(from normalized: CGPoint, size: CGFloat, center: CGPoint) -> CGPoint {
        CGPoint(
            x: center.x + (normalized.x - 0.5) * size,
            y: center.y + (normalized.y - 0.5) * size
        )
    }

    private func orbitRing(radius: CGFloat, center: CGPoint, opacity: Double) -> some View {
        Circle()
            .stroke(FieldPalette.border.opacity(opacity), lineWidth: 1)
            .frame(width: radius * 2, height: radius * 2)
            .position(center)
    }

    private func color(for deviceClass: DeviceClass) -> Color {
        switch deviceClass {
        case .mac:          return Color(hex: "#7C3AED")   // violet
        case .iPhone:       return Color(hex: "#06B6D4")   // cyan
        case .watch:        return Color(hex: "#EAB308")   // gold
        case .homePod:      return Color(hex: "#F43F5E")   // rose
        case .appleTV:      return Color(hex: "#78716C")   // earth
        case .roomSensor:   return Color(hex: "#22C55E")   // green
        case .doorContact:  return Color(hex: "#F59E0B")   // amber
        case .smartSpeaker: return Color(hex: "#E2E8F0")   // silver
        case .lightStrip:   return Color(hex: "#A78BFA")   // lavender
        case .irBlaster:    return Color(hex: "#64748B")   // slate
        case .edgeCompute:  return Color(hex: "#0EA5E9")   // sky
        case .smartGlasses: return Color(hex: "#34D399")   // emerald
        case .biometricBand:return Color(hex: "#FB7185")   // pink
        case .custom:       return FieldPalette.textMuted
        }
    }
}

// MARK: - MurmorNode

private struct MurmorNode: View {
    let identity: MurmorIdentity
    let showLabel: Bool
    let nodeColor: Color

    private var activity: Double { identity.activityLevel }
    private var nodeSize: CGFloat { 8 + CGFloat(activity) * 10 }

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                // Glow halo for active nodes
                if activity > 0.3 {
                    Circle()
                        .fill(nodeColor.opacity(activity * 0.2))
                        .frame(width: nodeSize + 10, height: nodeSize + 10)
                }

                Circle()
                    .fill(nodeColor.opacity(0.15 + activity * 0.6))
                    .frame(width: nodeSize, height: nodeSize)
                    .overlay(
                        Circle()
                            .stroke(nodeColor.opacity(0.4 + activity * 0.6), lineWidth: 1)
                    )

                Text(symbol(for: identity.deviceClass))
                    .font(.system(size: nodeSize * 0.55))
            }

            if showLabel {
                Text(identity.name)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundStyle(FieldPalette.textMuted.opacity(0.5 + activity * 0.5))
                    .lineLimit(1)
                    .frame(maxWidth: 56)
            }
        }
    }

    private func symbol(for deviceClass: DeviceClass) -> String {
        switch deviceClass {
        case .mac:           return "􀌂"
        case .iPhone:        return "􀟜"
        case .watch:         return "􀟸"
        case .homePod:       return "􀟫"
        case .appleTV:       return "􀡄"
        case .roomSensor:    return "􀝦"
        case .doorContact:   return "􀎚"
        case .smartSpeaker:  return "􀝦"
        case .lightStrip:    return "􀇯"
        case .irBlaster:     return "􀋦"
        case .edgeCompute:   return "􀈑"
        case .smartGlasses:  return "􀒡"
        case .biometricBand: return "􀐿"
        case .custom:        return "◆"
        }
    }
}

// MARK: - Preview

#Preview("Orbit — mixed activity") {
    let murmors: [MurmorIdentity] = [
        {
            var m = MurmorIdentity(name: "JB's Mac", deviceClass: .mac,
                                   profile: .init(sense: .full, process: .full, store: .full, relay: .full, act: .full))
            m.state = .active
            m.lastSyncTimestamp = Date()
            return m
        }(),
        {
            var m = MurmorIdentity(name: "JB's Watch", deviceClass: .watch,
                                   profile: .init(sense: .full, process: .minimal, store: .minimal, relay: .moderate, act: .moderate))
            m.state = .autonomous
            m.lastSyncTimestamp = Date().addingTimeInterval(-120)
            return m
        }(),
        {
            var m = MurmorIdentity(name: "Kitchen Sensor", deviceClass: .roomSensor,
                                   profile: .init(sense: .moderate, process: .minimal, store: .minimal, relay: .moderate, act: .minimal))
            m.state = .buffering
            return m
        }(),
        {
            var m = MurmorIdentity(name: "iPhone 16", deviceClass: .iPhone,
                                   profile: .init(sense: .full, process: .full, store: .moderate, relay: .full, act: .full))
            m.state = .sleeping
            return m
        }(),
        {
            var m = MurmorIdentity(name: "Front Door", deviceClass: .doorContact,
                                   profile: .init(sense: .minimal, process: .none, store: .none, relay: .minimal, act: .none))
            m.state = .offline
            return m
        }()
    ]

    ZStack {
        FieldPalette.void.ignoresSafeArea()
        MurmorOrbitView(murmors: murmors)
            .padding(24)
    }
}
