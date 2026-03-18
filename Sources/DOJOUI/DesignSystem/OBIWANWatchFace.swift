import DOJOShared
import SwiftUI
import HealthKit

// ◎ Kings-Chamber — OBIWANWatchFace.swift
// Frequency: 963 Hz  |  OBI-WAN ambient observer — the Watch surface.
//
// Philosophy: The right presence when required. Facilitates the experience
// of life through seamless integrated technology.
// - Always with you. Swims with you.
// - Offline-first: displays last known state if Mac Studio unreachable.
// - One glance = three things: coherence, last biometric, connection state.
// - NOT a dashboard — one breath of information.
//
// Doctor Strange reference: minimal Ditko spell circle on pure void.
// 9 spokes (963 = 9×107). 3 concentric rings. The eye watches.

// ── Watch face (full screen) ─────────────────────────────────────────────────

public struct OBIWANWatchFace: View {
    @ObservedObject public var state: OBIWANState
    public var heartRate: Double?          // BPM from HealthKit
    public var hrv: Double?                // HRV SDNN ms
    public var oawPhase: Int = 9           // 3, 6, or 9 — current Tesla phase

    public init(state: OBIWANState = .shared, heartRate: Double? = nil, hrv: Double? = nil, oawPhase: Int = 9) {
        self.state = state
        self.heartRate = heartRate
        self.hrv = hrv
        self.oawPhase = oawPhase
    }

    private var coherence: Double { state.alignment }
    private var connected: ConnectionState {
        coherence >= 0.9 ? .online : (coherence >= 0.4 ? .buffering : .offline)
    }

    public var body: some View {
        ZStack {
            FieldPalette.void.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 6)

                // ── Centre sigil ─────────────────────────────────────────
                ZStack {
                    // OAW phase arc — outer ring shows 3, 6, or 9 phase
                    OAWPhaseArc(phase: oawPhase, size: 130)

                    // OBI-WAN spell circle
                    SpellCircle(chamber: .obiwan, active: state.isObserving, size: 100, compact: false)

                    // Coherence overlay ring
                    Circle()
                        .trim(from: 0, to: coherence)
                        .stroke(
                            FieldPalette.bearRing(coherence),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 122, height: 122)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: FieldPalette.bearRing(coherence).opacity(0.6), radius: 4)
                        .animation(.easeInOut(duration: 0.8), value: coherence)
                }

                Spacer(minLength: 8)

                // ── Primary metric ───────────────────────────────────────
                primaryMetric

                Spacer(minLength: 6)

                // ── Footer ───────────────────────────────────────────────
                footer
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, 8)
        }
    }

    // ── Primary metric (heart rate or HRV) ───────────────────────────────────

    private var primaryMetric: some View {
        Group {
            if let bpm = heartRate {
                VStack(spacing: 1) {
                    Text(String(format: "%.0f", bpm))
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                        .foregroundStyle(FieldPalette.textPrimary)
                    Text("BPM")
                        .font(FieldType.frequency)
                        .foregroundStyle(FieldPalette.textMuted)
                        .tracking(2)
                }
            } else if let sdnn = hrv {
                VStack(spacing: 1) {
                    Text(String(format: "%.0f", sdnn))
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                        .foregroundStyle(FieldPalette.textPrimary)
                    Text("HRV ms")
                        .font(FieldType.frequency)
                        .foregroundStyle(FieldPalette.textMuted)
                        .tracking(2)
                }
            } else {
                VStack(spacing: 1) {
                    Text("●")
                        .font(.system(.title3, design: .monospaced))
                        .foregroundStyle(Chamber.obiwan.color.opacity(0.6))
                    Text("watching")
                        .font(FieldType.frequency)
                        .foregroundStyle(FieldPalette.textDim)
                        .tracking(2)
                }
            }
        }
    }

    // ── Footer ────────────────────────────────────────────────────────────────

    private var footer: some View {
        HStack {
            Text("963 Hz")
                .font(FieldType.frequency)
                .foregroundStyle(FieldPalette.textMuted)
                .tracking(1)
            Spacer()
            ConnectionDot(state: connected)
        }
    }
}

// ── OAW phase arc ─────────────────────────────────────────────────────────────
// Tesla 3-6-9: the outer ring shows which harmonic phase OBI-WAN is in.
// Phase 3 = intake/observe, Phase 6 = process, Phase 9 = synthesise.

private struct OAWPhaseArc: View {
    let phase: Int    // 3, 6, or 9
    let size: CGFloat

    private var phaseColor: Color {
        switch phase {
        case 3:  return Chamber.akron.color.opacity(0.5)   // earth — intake
        case 6:  return Chamber.atlas.color.opacity(0.5)   // crystal — process
        default: return Chamber.obiwan.color.opacity(0.5)  // ether — synthesise
        }
    }

    private var phaseArc: Double {
        switch phase {
        case 3:  return 3.0 / 9.0
        case 6:  return 6.0 / 9.0
        default: return 1.0
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(FieldPalette.border.opacity(0.3), lineWidth: 1)
                .frame(width: size, height: size)

            Circle()
                .trim(from: 0, to: phaseArc)
                .stroke(phaseColor, style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [2, 4]))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // Phase label
            Text("OAW·\(phase)")
                .font(FieldType.frequency)
                .foregroundStyle(phaseColor)
                .tracking(1)
                .offset(y: size * 0.44)
        }
    }
}

// ── Connection state dot ──────────────────────────────────────────────────────

public enum ConnectionState {
    case online, buffering, offline

    var color: Color {
        switch self {
        case .online:    return FieldPalette.bearRing(1.0)   // green
        case .buffering: return FieldPalette.bearRing(0.8)   // amber
        case .offline:   return FieldPalette.bearRing(0.0)   // red
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

// ── Complication (tiny — corner / bezel) ─────────────────────────────────────
// When DOJO Suite isn't foregrounded — just the ● and BEAR coherence.

public struct OBIWANComplication: View {
    @ObservedObject public var state: OBIWANState = .shared

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

// ── Preview ───────────────────────────────────────────────────────────────────

#Preview("Watch Face — Online") {
    OBIWANWatchFace(
        state: {
            let s = OBIWANState.shared
            s.alignment = 0.94
            s.isObserving = true
            return s
        }(),
        heartRate: 62,
        oawPhase: 9
    )
    .frame(width: 180, height: 220)
}

#Preview("Watch Face — Offline") {
    OBIWANWatchFace(
        state: {
            let s = OBIWANState.shared
            s.alignment = 0.35
            s.isObserving = false
            return s
        }(),
        heartRate: nil,
        oawPhase: 3
    )
    .frame(width: 180, height: 220)
}

#Preview("Complication") {
    ZStack {
        FieldPalette.void
        OBIWANComplication()
    }
    .frame(width: 80, height: 80)
}
