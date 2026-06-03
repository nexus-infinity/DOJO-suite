import DOJOShared
import SwiftUI
import HealthKit

// ◎ Kings-Chamber — OBIWANWatchFace.swift
// Frequency: 963 Hz  |  OBI-WAN ambient observer — the Watch surface.
//
// Ditko reference: Strange Tales #110–168 (1963–1966).
// The geometry IS the mechanism — not decoration.
// 9 spokes (963 = 9×107). 5 concentric rings. Nonagram {9/4}. The eye watches.

public struct OBIWANWatchFace: View {
    @ObservedObject public var state: OBIWANState
    @Environment(\.scenePhase) private var scenePhase
    public var heartRate: Double?
    public var hrv: Double?
    public var oawPhase: Int = 9

    public init(state: OBIWANState, heartRate: Double? = nil, hrv: Double? = nil, oawPhase: Int = 9) {
        self.state = state
        self.heartRate = heartRate.flatMap { (30...220).contains($0) ? $0 : nil }
        self.hrv = hrv.flatMap { (0...300).contains($0) ? $0 : nil }
        if state.validatePhaseTransition(from: state.currentPhase, to: oawPhase) {
            self.oawPhase = oawPhase
            state.currentPhase = oawPhase
        } else {
            print("⚠️ Invalid phase transition: \(state.currentPhase) → \(oawPhase). Holding current phase.")
            self.oawPhase = state.currentPhase
        }
    }

    @MainActor
    public static func withShared(heartRate: Double? = nil, hrv: Double? = nil, oawPhase: Int = 9) -> OBIWANWatchFace {
        OBIWANWatchFace(state: .shared, heartRate: heartRate, hrv: hrv, oawPhase: oawPhase)
    }

    private var coherence: Double { state.alignment }
    private var connected: ConnectionState {
        guard state.networkReachable else { return .offline }
        return coherence >= 0.9 ? .online : (coherence >= 0.4 ? .buffering : .offline)
    }
    private var phaseColor: Color {
        switch oawPhase {
        case 3:  return Chamber.akron.color
        case 6:  return Chamber.atlas.color
        default: return Chamber.obiwan.color
        }
    }

    public var body: some View {
        ZStack {
            FieldPalette.void.ignoresSafeArea()

            DitkoGeometry(
                coherence: coherence,
                phase: oawPhase,
                connection: connected,
                active: state.isObserving && scenePhase == .active
            )

            eyeCenter

            VStack {
                Spacer()
                HStack {
                    Text("OAW·\(oawPhase)")
                        .font(FieldType.frequency)
                        .foregroundStyle(phaseColor.opacity(0.55))
                        .tracking(1)
                    Spacer()
                    ConnectionDot(state: connected)
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 6)
            }
        }
    }

    private var eyeCenter: some View {
        ZStack {
            Circle()
                .fill(FieldPalette.void.opacity(0.85))
                .frame(width: 42, height: 42)
            biometricText
        }
    }

    @ViewBuilder
    private var biometricText: some View {
        if let bpm = heartRate {
            VStack(spacing: 0) {
                Text(String(format: "%.0f", bpm))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(FieldPalette.textPrimary)
                Text("bpm")
                    .font(.system(size: 6, weight: .medium, design: .monospaced))
                    .foregroundStyle(FieldPalette.textMuted)
                    .tracking(1)
            }
        } else if let sdnn = hrv {
            VStack(spacing: 0) {
                Text(String(format: "%.0f", sdnn))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(FieldPalette.textPrimary)
                Text("hrv")
                    .font(.system(size: 6, weight: .medium, design: .monospaced))
                    .foregroundStyle(FieldPalette.textMuted)
                    .tracking(1)
            }
        } else {
            Text("◉")
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Chamber.obiwan.color.opacity(0.5))
        }
    }
}

// ── Ditko geometry engine ─────────────────────────────────────────────────────
// 5 rings + nonagram {9/4} + dual spoke lattice.
// Each layer counter-rotates its neighbour — the Ditko "impossible depth" field.

private struct DitkoGeometry: View {
    let coherence: Double
    let phase: Int
    let connection: ConnectionState
    let active: Bool

    @State private var r5rot: Double = 0   // outermost — slow clockwise
    @State private var r4rot: Double = 0   // phase ring — counter-clockwise
    @State private var spokeRot: Double = 0 // primary 9 spokes — clockwise
    @State private var nRot: Double = 0    // nonagram — counter-clockwise
    @State private var r2rot: Double = 0   // inner ring — counter-clockwise

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            ZStack {
                // R5 — outermost boundary, 9 connection-coloured ticks
                Circle()
                    .stroke(obi.opacity(0.10), lineWidth: 0.5)
                    .frame(width: d * 0.96, height: d * 0.96)
                WatchTicks(radius: d * 0.48, count: 9, len: d * 0.03, color: connection.color.opacity(0.65))
                    .frame(width: d, height: d)
                    .rotationEffect(.degrees(r5rot))

                // R4 — OAW phase arc, dashed, counter-rotating
                Circle()
                    .stroke(obi.opacity(0.08), lineWidth: 0.5)
                    .frame(width: d * 0.82, height: d * 0.82)
                Circle()
                    .trim(from: 0, to: phaseArc)
                    .stroke(phaseColor.opacity(0.50),
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [3, 7]))
                    .frame(width: d * 0.82, height: d * 0.82)
                    .rotationEffect(.degrees(-90 + r4rot))

                // R3 — coherence arc with angular-gradient glow
                Circle()
                    .stroke(FieldPalette.border.opacity(0.18), lineWidth: 1)
                    .frame(width: d * 0.68, height: d * 0.68)
                Circle()
                    .trim(from: 0, to: coherence)
                    .stroke(
                        AngularGradient(
                            colors: [coherenceColor.opacity(0.2), coherenceColor, coherenceColor.opacity(0.2)],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                    )
                    .frame(width: d * 0.68, height: d * 0.68)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: coherenceColor.opacity(0.8), radius: 5)
                    .animation(.easeInOut(duration: 1.0), value: coherence)

                // Primary spokes: 9 annular lines, centre gap to R3
                AnnularSpokes(count: 9, inner: d * 0.07, outer: d * 0.33, offset: 0, color: obi.opacity(0.22))
                    .frame(width: d, height: d)
                    .rotationEffect(.degrees(spokeRot))

                // Nonagram {9/4}: counter-rotates against primary spokes
                NonagramShape(radius: d * 0.29)
                    .stroke(obi.opacity(0.38), lineWidth: 0.8)
                    .frame(width: d, height: d)
                    .shadow(color: obi.opacity(0.5), radius: 4)
                    .rotationEffect(.degrees(nRot))

                // Secondary spokes: 9 offset 20°, creates lattice with primary
                AnnularSpokes(count: 9, inner: d * 0.05, outer: d * 0.24, offset: 20, color: obi.opacity(0.13))
                    .frame(width: d, height: d)
                    .rotationEffect(.degrees(-spokeRot * 0.7))

                // R2 — inner ring, counter-rotating
                Circle()
                    .stroke(obi.opacity(0.24), lineWidth: 1)
                    .frame(width: d * 0.47, height: d * 0.47)
                    .rotationEffect(.degrees(r2rot))

                // R1 — innermost ring, eye surround zone
                Circle()
                    .stroke(obi.opacity(0.42), lineWidth: 0.5)
                    .frame(width: d * 0.30, height: d * 0.30)

                // Radial energy field from centre
                if active {
                    RadialGradient(
                        colors: [obi.opacity(0.18), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: d * 0.32
                    )
                    .frame(width: d, height: d)
                    .allowsHitTesting(false)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear { if active { start() } }
        .onChange(of: active) { _, on in on ? start() : stop() }
    }

    private var obi: Color { Chamber.obiwan.color }
    private var phaseArc: Double {
        switch phase { case 3: return 1.0/3.0; case 6: return 2.0/3.0; default: return 1.0 }
    }
    private var phaseColor: Color {
        switch phase { case 3: return Chamber.akron.color; case 6: return Chamber.atlas.color; default: return obi }
    }
    private var coherenceColor: Color { FieldPalette.bearRing(coherence) }

    private func start() {
        withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) { r5rot = 360 }
        withAnimation(.linear(duration: 45).repeatForever(autoreverses: false)) { r4rot = -360 }
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) { spokeRot = 360 }
        withAnimation(.linear(duration: 28).repeatForever(autoreverses: false)) { nRot = -360 }
        withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) { r2rot = -360 }
    }
    private func stop() {
        withAnimation(.easeOut(duration: 1.5)) { r5rot = 0; r4rot = 0; spokeRot = 0; nRot = 0; r2rot = 0 }
    }
}

// ── Shapes ────────────────────────────────────────────────────────────────────

private struct NonagramShape: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let cx = rect.midX, cy = rect.midY
        let pts: [CGPoint] = (0..<9).map { i in
            let a = Double(i) / 9.0 * .pi * 2 - .pi / 2
            return CGPoint(x: cx + CGFloat(cos(a)) * radius, y: cy + CGFloat(sin(a)) * radius)
        }
        var p = Path()
        var idx = 0
        p.move(to: pts[0])
        // {9/4}: connect every 4th vertex — visits all 9 before closing
        for _ in 0..<9 { idx = (idx + 4) % 9; p.addLine(to: pts[idx]) }
        p.closeSubpath()
        return p
    }
}

// ── Canvas primitives ─────────────────────────────────────────────────────────

private struct AnnularSpokes: View {
    let count: Int
    let inner: CGFloat
    let outer: CGFloat
    let offset: Double  // degrees
    let color: Color

    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2, cy = size.height / 2
            for i in 0..<count {
                let a = Double(i) / Double(count) * .pi * 2 + offset * .pi / 180
                var path = Path()
                path.move(to: CGPoint(x: cx + CGFloat(cos(a)) * inner, y: cy + CGFloat(sin(a)) * inner))
                path.addLine(to: CGPoint(x: cx + CGFloat(cos(a)) * outer, y: cy + CGFloat(sin(a)) * outer))
                ctx.stroke(path, with: .color(color), lineWidth: 0.8)
            }
        }
    }
}

private struct WatchTicks: View {
    let radius: CGFloat
    let count: Int
    let len: CGFloat
    let color: Color

    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2, cy = size.height / 2
            for i in 0..<count {
                let a = Double(i) / Double(count) * .pi * 2
                var path = Path()
                path.move(to: CGPoint(x: cx + CGFloat(cos(a)) * (radius - len),
                                      y: cy + CGFloat(sin(a)) * (radius - len)))
                path.addLine(to: CGPoint(x: cx + CGFloat(cos(a)) * radius,
                                         y: cy + CGFloat(sin(a)) * radius))
                ctx.stroke(path, with: .color(color), lineWidth: 1.5)
            }
        }
    }
}

// ── Connection state ──────────────────────────────────────────────────────────

public enum ConnectionState {
    case online, buffering, offline

    var color: Color {
        switch self {
        case .online:    return FieldPalette.bearRing(1.0)
        case .buffering: return FieldPalette.bearRing(0.8)
        case .offline:   return FieldPalette.bearRing(0.0)
        }
    }

    var label: String {
        switch self {
        case .online:    return "live"
        case .buffering: return "buffer"
        case .offline:   return "solo"
        }
    }
}

private struct ConnectionDot: View {
    let state: ConnectionState
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 3) {
            Circle()
                .frame(width: 5, height: 5)
                .foregroundStyle(state.color)
                .shadow(color: state.color.opacity(0.8), radius: 3)
                .scaleEffect(state == .online && pulse ? 1.3 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)
                .onAppear { if state == .online { pulse = true } }
            Text(state.label)
                .font(FieldType.frequency)
                .foregroundStyle(FieldPalette.textMuted)
                .tracking(1)
        }
    }
}

// ── Complication (corner / bezel) ─────────────────────────────────────────────

public struct OBIWANComplication: View {
    @ObservedObject public var state: OBIWANState

    public init(state: OBIWANState) { self.state = state }

    public var body: some View {
        ZStack {
            FieldPalette.void
            VStack(spacing: 1) {
                SpellCircle(chamber: .obiwan, active: state.isObserving, size: 28, compact: true)
                Text(String(format: "%.0f%%", state.alignment * 100))
                    .font(.system(.caption2, design: .monospaced, weight: .medium))
                    .foregroundStyle(FieldPalette.bearRing(state.alignment))
            }
        }
        .frame(width: 40, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// ── Previews ──────────────────────────────────────────────────────────────────

#Preview("Watch Face — Online") {
    OBIWANWatchFace.withShared(heartRate: 62, oawPhase: 9)
        .onAppear {
            OBIWANState.shared.alignment = 0.94
            OBIWANState.shared.isObserving = true
        }
        .frame(width: 180, height: 220)
}

#Preview("Watch Face — Offline") {
    OBIWANWatchFace.withShared(heartRate: nil, oawPhase: 3)
        .onAppear {
            OBIWANState.shared.alignment = 0.35
            OBIWANState.shared.isObserving = false
        }
        .frame(width: 180, height: 220)
}

#Preview("Complication") {
    ZStack {
        FieldPalette.void
        OBIWANComplication(state: .shared)
    }
    .frame(width: 80, height: 80)
}
