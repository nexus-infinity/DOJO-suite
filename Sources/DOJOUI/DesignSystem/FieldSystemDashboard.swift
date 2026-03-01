import SwiftUI

// ◎ Kings-Chamber — FieldSystemDashboard.swift
// Frequency: 852 Hz  |  The temple display. Not an app — the system itself.
//
// What lives on the Mac Studio screen while FIELD DOJO runs.
// Shows all chambers, their pulse, BEAR coherence, current S-stage.
// Philosophy: calm surface, intelligence underneath.

// ── Chamber status model ─────────────────────────────────────────────────────

public struct ChamberStatus: Identifiable {
    public let chamber: Chamber
    public var alive: Bool
    public var coherence: Double     // 0.0–1.0 from /health
    public var lastBeat: Date?
    public var currentStage: String? // "S7", "S3", etc.

    public var id: String { chamber.id }

    public init(chamber: Chamber, alive: Bool = false, coherence: Double = 0, lastBeat: Date? = nil, currentStage: String? = nil) {
        self.chamber = chamber
        self.alive = alive
        self.coherence = coherence
        self.lastBeat = lastBeat
        self.currentStage = currentStage
    }

    // Seconds since last heartbeat — nil if never seen
    public var beatAge: Double? {
        guard let d = lastBeat else { return nil }
        return Date().timeIntervalSince(d)
    }

    public var pulseOpacity: Double {
        guard alive else { return 0.15 }
        guard let age = beatAge else { return 0.6 }
        return max(0.3, min(1.0, 1.0 - (age / 60.0) * 0.5))
    }
}

// ── Pyramid layout positions ─────────────────────────────────────────────────
// Mirrors the actual pyramid geometry: apex at top, base anchors below.

private let pyramidLayout: [(chamber: Chamber, unit: CGPoint)] = [
    (.kings,   CGPoint(x: 0.5,   y: 0.04)),  // ◎ apex — Kings Chamber
    (.dojo,    CGPoint(x: 0.5,   y: 0.22)),  // ◼︎ sub-apex — DOJO
    (.obiwan,  CGPoint(x: 0.12,  y: 0.56)),  // ● front-left vertex
    (.atlas,   CGPoint(x: 0.88,  y: 0.56)),  // ▲ front-right vertex
    (.tata,    CGPoint(x: 0.5,   y: 0.72)),  // ▼ front-center
    (.akron,   CGPoint(x: 0.5,   y: 0.92)),  // ◻ base gateway
    (.arkadas, CGPoint(x: 0.5,   y: 0.40)),  // ◉ King's Bridge — inside geometry
]

// ── Main dashboard ───────────────────────────────────────────────────────────

public struct FieldSystemDashboard: View {
    public let statuses: [ChamberStatus]
    public let bearScore: Double
    public let activeStage: String?     // "S7", "S3", etc.
    public let systemUptime: TimeInterval?

    public init(
        statuses: [ChamberStatus] = Chamber.allCases.map { ChamberStatus(chamber: $0) },
        bearScore: Double = 0,
        activeStage: String? = nil,
        systemUptime: TimeInterval? = nil
    ) {
        self.statuses = statuses
        self.bearScore = bearScore
        self.activeStage = activeStage
        self.systemUptime = systemUptime
    }

    private func status(for chamber: Chamber) -> ChamberStatus {
        statuses.first(where: { $0.chamber == chamber }) ?? ChamberStatus(chamber: chamber)
    }

    public var body: some View {
        ZStack {
            FieldPalette.void.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ──────────────────────────────────────────────
                header
                    .padding(.top, 24)
                    .padding(.horizontal, 32)

                // ── Pyramid field ────────────────────────────────────────
                GeometryReader { geo in
                    ZStack {
                        // Connecting lines (wireframe)
                        PyramidWireframe(size: geo.size)
                            .stroke(FieldPalette.border, lineWidth: 0.5)
                            .opacity(0.4)

                        // Chamber nodes
                        ForEach(pyramidLayout, id: \.chamber.id) { item in
                            let s = status(for: item.chamber)
                            ChamberNode(status: s)
                                .position(
                                    x: item.unit.x * geo.size.width,
                                    y: item.unit.y * geo.size.height
                                )
                        }

                        // BEAR mandala — sling-ring style, centered in the geometry
                        BEARMandala(score: bearScore, size: 80)
                            .position(
                                x: geo.size.width * 0.5,
                                y: geo.size.height * 0.56
                            )
                    }
                }
                .frame(maxWidth: 560, maxHeight: 480)
                .padding(.vertical, 16)

                // ── Footer status row ────────────────────────────────────
                footer
                    .padding(.bottom, 24)
                    .padding(.horizontal, 32)
            }
        }
        .frame(minWidth: 560, idealWidth: 640, minHeight: 600, idealHeight: 680)
    }

    // ── Header ───────────────────────────────────────────────────────────────

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("◎  F I E L D   D O J O")
                    .font(.system(.title3, design: .monospaced, weight: .semibold))
                    .foregroundStyle(FieldPalette.textPrimary)
                    .tracking(4)
                Text("852 Hz  ·  Kings Chamber  ·  The Temple")
                    .font(FieldType.frequency)
                    .foregroundStyle(FieldPalette.textMuted)
                    .tracking(1)
            }
            Spacer()
            if let uptime = systemUptime {
                uptimeBadge(uptime)
            }
        }
    }

    // ── Footer ───────────────────────────────────────────────────────────────

    private var footer: some View {
        HStack(spacing: 20) {
            ForEach(statuses.filter { $0.chamber != .kings }) { s in
                HStack(spacing: 4) {
                    Text(s.chamber.rawValue)
                        .font(FieldType.badge)
                        .foregroundStyle(s.alive ? s.chamber.color : FieldPalette.textDim)
                    Text(":\(s.chamber.port)")
                        .font(FieldType.frequency)
                        .foregroundStyle(s.alive ? FieldPalette.textMuted : FieldPalette.textDim)
                    Circle()
                        .frame(width: 4, height: 4)
                        .foregroundStyle(s.alive ? s.chamber.color : FieldPalette.textDim)
                        .shadow(color: s.alive ? s.chamber.glowColor : .clear, radius: 3)
                }
            }
            Spacer()
            if let stage = activeStage {
                Text(stage)
                    .font(FieldType.badge)
                    .foregroundStyle(Chamber.kings.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Chamber.kings.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Chamber.kings.color.opacity(0.3), lineWidth: 1))
            }
        }
    }

    private func uptimeBadge(_ seconds: TimeInterval) -> some View {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        return Text(String(format: "UP  %02d:%02d", h, m))
            .font(FieldType.frequency)
            .foregroundStyle(FieldPalette.textMuted)
            .tracking(2)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(FieldPalette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

// ── Chamber node (placed on pyramid) ─────────────────────────────────────────

private struct ChamberNode: View {
    let status: ChamberStatus

    var body: some View {
        VStack(spacing: 4) {
            // Spell circle — Ditko sigil at the node
            SpellCircle(chamber: status.chamber, active: status.alive, size: 54, compact: true)

            Text(status.chamber.name)
                .font(FieldType.frequency)
                .foregroundStyle(status.alive ? FieldPalette.textPrimary : FieldPalette.textDim)
                .tracking(1)

            HStack(spacing: 3) {
                Text("\(status.chamber.frequency)")
                    .font(FieldType.frequency)
                    .foregroundStyle(FieldPalette.textMuted)
                if let stage = status.currentStage {
                    Text("·")
                        .foregroundStyle(FieldPalette.textDim)
                    Text(stage)
                        .font(FieldType.frequency)
                        .foregroundStyle(status.chamber.color.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(FieldPalette.surface.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(status.alive ? status.chamber.color.opacity(0.25) : FieldPalette.border, lineWidth: 1)
        )
    }
}

// ── Wireframe connecting lines ────────────────────────────────────────────────

private struct PyramidWireframe: Shape {
    let size: CGSize

    func path(in rect: CGRect) -> Path {
        // Map unit coords → actual points
        func pt(_ ux: Double, _ uy: Double) -> CGPoint {
            CGPoint(x: ux * size.width, y: uy * size.height)
        }
        let apex   = pt(0.5,  0.04)
        let dojo   = pt(0.5,  0.22)
        let obi    = pt(0.12, 0.56)
        let atlas  = pt(0.88, 0.56)
        let tata   = pt(0.5,  0.72)
        let akron  = pt(0.5,  0.92)

        var p = Path()
        // Spine
        p.move(to: apex); p.addLine(to: akron)
        // Base quad
        p.move(to: obi);  p.addLine(to: tata)
        p.move(to: tata); p.addLine(to: atlas)
        p.move(to: atlas);p.addLine(to: obi)
        // Apex to base corners
        p.move(to: dojo); p.addLine(to: obi)
        p.move(to: dojo); p.addLine(to: atlas)
        p.move(to: dojo); p.addLine(to: tata)
        return p
    }
}

// ── Preview ───────────────────────────────────────────────────────────────────

#Preview {
    FieldSystemDashboard(
        statuses: [
            ChamberStatus(chamber: .dojo,    alive: true,  coherence: 1.0, lastBeat: Date(), currentStage: "S7"),
            ChamberStatus(chamber: .obiwan,  alive: true,  coherence: 0.95, lastBeat: Date()),
            ChamberStatus(chamber: .atlas,   alive: true,  coherence: 1.0,  lastBeat: Date()),
            ChamberStatus(chamber: .tata,    alive: false, coherence: 0.0),
            ChamberStatus(chamber: .akron,   alive: true,  coherence: 0.8,  lastBeat: Date()),
            ChamberStatus(chamber: .arkadas, alive: true,  coherence: 0.9,  lastBeat: Date(), currentStage: "S5"),
            ChamberStatus(chamber: .kings,   alive: true,  coherence: 1.0,  lastBeat: Date()),
        ],
        bearScore: 0.87,
        activeStage: "S7",
        systemUptime: 7230
    )
    .frame(width: 640, height: 680)
}
