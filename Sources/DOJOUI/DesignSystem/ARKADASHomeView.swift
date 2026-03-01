import SwiftUI

// ◎ Kings-Chamber — ARKADASHomeView.swift
// Frequency: 717 Hz  |  ARKADAŞ bridge — the iPhone home screen.
//
// ARKADAŞ is the high priest: translator between user consciousness (DOJO Suite)
// and FIELD geometry (Mac Studio). The iPhone IS the bridge surface.
//
// Three Link pathways coordinate through ARKADAŞ:
//   OB1Link  → Observation (sensors → FIELD)
//   DojoLink → Intent (user → DOJO inference → FIELD manifestation)
//   SomaLink → Physical form (body/presence → FIELD structure)
//
// Visual: Doctor Strange sling ring portal — ◉ at centre, 6 chambers orbit
// around it as ARKADAŞ opens the link. Gold sparks trace the pathways.
// Portrait 9:16. Pyramid wireframe at 10% opacity behind everything.

// ── Link state ────────────────────────────────────────────────────────────────

public enum LinkState: String {
    case active     = "active"
    case buffering  = "buffering"
    case offline    = "offline"

    var color: Color {
        switch self {
        case .active:    return FieldPalette.bearRing(1.0)
        case .buffering: return FieldPalette.bearRing(0.75)
        case .offline:   return FieldPalette.bearRing(0.0)
        }
    }

    var label: String {
        switch self {
        case .active:    return "bridge active"
        case .buffering: return "buffering"
        case .offline:   return "offline"
        }
    }
}

// ── Product app entry ─────────────────────────────────────────────────────────

public struct ProductEntry: Identifiable {
    public let id: String
    public let symbol: String
    public let name: String
    public let subtitle: String
    public let chamber: Chamber
    public var hasUnread: Bool = false
}

public let fieldProductApps: [ProductEntry] = [
    ProductEntry(id: "niama",   symbol: "⬡",  name: "Niama",             subtitle: "DOJO Consciousness",   chamber: .dojo),
    ProductEntry(id: "response",symbol: "◈",  name: "Response Advantage",subtitle: "Healing · Accountability", chamber: .tata),
    ProductEntry(id: "berjak",  symbol: "◬",  name: "Berjak FRE",        subtitle: "Trading · Enterprise",  chamber: .atlas),
    ProductEntry(id: "kit-car", symbol: "🚗", name: "Kit Car",           subtitle: "Vehicle Node · HAL",    chamber: .akron),
]

// ── Main iPhone home view ─────────────────────────────────────────────────────

public struct ARKADASHomeView: View {
    public var dojoLink: LinkState = .active
    public var ob1Link: LinkState = .active
    public var somaLink: LinkState = .buffering
    public var bearScore: Double = 0.87
    public var chamberStatuses: [ChamberStatus] = Chamber.allCases.map { ChamberStatus(chamber: $0, alive: true) }
    public var onAppTap: ((ProductEntry) -> Void)? = nil

    @State private var orbitAngle: Double = 0
    @State private var portalScale: CGFloat = 0.85
    @State private var portalOpacity: Double = 0

    // 6 chambers orbiting ARKADAŞ (clockwise by frequency, ascending)
    private let orbitChambers: [(chamber: Chamber, orbitRadius: CGFloat, speed: Double, phase: Double)] = [
        (.akron,   0.38, 1.0,  0),     // 396 Hz — outermost, slow
        (.tata,    0.34, 1.15, 60),    // 432 Hz
        (.atlas,   0.30, 1.3,  120),   // 528 Hz
        (.dojo,    0.26, 1.5,  180),   // 741 Hz
        (.kings,   0.22, 1.7,  240),   // 852 Hz
        (.obiwan,  0.18, 2.0,  300),   // 963 Hz — innermost, fastest
    ]

    public var body: some View {
        ZStack {
            FieldPalette.void.ignoresSafeArea()

            // Pyramid wireframe backdrop (10% opacity)
            GeometryReader { geo in
                PyramidBackdrop(size: geo.size)
                    .stroke(FieldPalette.border.opacity(0.08), lineWidth: 0.5)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ───────────────────────────────────────────────
                header.padding(.top, 16).padding(.horizontal, 24)

                Spacer(minLength: 24)

                // ── Orbital field ────────────────────────────────────────
                GeometryReader { geo in
                    let centre = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

                    ZStack {
                        // Orbit path rings (dashed)
                        ForEach(orbitChambers, id: \.chamber.id) { item in
                            Circle()
                                .stroke(item.chamber.color.opacity(0.06), style: StrokeStyle(lineWidth: 0.5, dash: [3, 6]))
                                .frame(
                                    width: geo.size.width * item.orbitRadius * 2,
                                    height: geo.size.width * item.orbitRadius * 2
                                )
                        }

                        // Orbiting chamber sigils
                        ForEach(orbitChambers, id: \.chamber.id) { item in
                            let status = chamberStatuses.first(where: { $0.chamber == item.chamber })
                            let alive = status?.alive ?? false
                            let angle = (orbitAngle * item.speed + item.phase) * .pi / 180
                            let r = geo.size.width * item.orbitRadius

                            SpellCircle(chamber: item.chamber, active: alive, size: 36, compact: true)
                                .position(
                                    x: centre.x + cos(angle) * r,
                                    y: centre.y + sin(angle) * r
                                )
                        }

                        // ◉ ARKADAŞ — portal centre
                        VStack(spacing: 4) {
                            SpellCircle(chamber: .arkadas, active: dojoLink == .active, size: 90)
                                .scaleEffect(portalScale)
                                .opacity(portalOpacity)
                                .shadow(color: Chamber.arkadas.glowColor, radius: 20)

                            // Link pathway status
                            HStack(spacing: 12) {
                                linkPill("OB1", ob1Link)
                                linkPill("DOJO", dojoLink)
                                linkPill("SOMA", somaLink)
                            }
                            .padding(.top, 4)
                        }
                        .position(centre)
                    }
                }
                .frame(height: 340)

                Spacer(minLength: 20)

                // ── BEAR score row ───────────────────────────────────────
                bearRow
                    .padding(.horizontal, 24)

                Spacer(minLength: 20)

                // ── Product app entries ──────────────────────────────────
                appGrid
                    .padding(.horizontal, 16)

                Spacer(minLength: 24)
            }
        }
        .onAppear {
            // Portal unfold
            withAnimation(.spring(duration: 0.8, bounce: 0.25)) {
                portalScale = 1.0
                portalOpacity = 1.0
            }
            // Orbit rotation
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                orbitAngle = 360
            }
        }
    }

    // ── Header ───────────────────────────────────────────────────────────────

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("◉  A R K A D A Ş")
                    .font(.system(.headline, design: .monospaced, weight: .semibold))
                    .foregroundStyle(Chamber.arkadas.color)
                    .tracking(3)
                Text("717 Hz  ·  The Bridge")
                    .font(FieldType.frequency)
                    .foregroundStyle(FieldPalette.textMuted)
                    .tracking(1)
            }
            Spacer()
            // FIELD DOJO connection
            HStack(spacing: 4) {
                Circle().frame(width: 6, height: 6)
                    .foregroundStyle(dojoLink.color)
                    .shadow(color: dojoLink.color.opacity(0.8), radius: 3)
                Text("FIELD")
                    .font(FieldType.frequency)
                    .foregroundStyle(FieldPalette.textMuted)
                    .tracking(1)
            }
        }
    }

    // ── Link pill ─────────────────────────────────────────────────────────────

    private func linkPill(_ label: String, _ link: LinkState) -> some View {
        HStack(spacing: 3) {
            Circle().frame(width: 4, height: 4)
                .foregroundStyle(link.color)
            Text(label)
                .font(FieldType.frequency)
                .foregroundStyle(link == .active ? FieldPalette.textPrimary : FieldPalette.textMuted)
                .tracking(1)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(FieldPalette.surface)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(link.color.opacity(0.2), lineWidth: 1))
    }

    // ── BEAR row ─────────────────────────────────────────────────────────────

    private var bearRow: some View {
        HStack {
            Text("BEAR  \(String(format: "%.2f", bearScore))")
                .font(FieldType.badge)
                .foregroundStyle(FieldPalette.bearRing(bearScore))
                .tracking(1)
            Spacer()
            // Mini coherence bar
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(FieldPalette.border).frame(height: 3)
                    Capsule()
                        .fill(FieldPalette.bearRing(bearScore))
                        .frame(width: g.size.width * bearScore, height: 3)
                        .shadow(color: FieldPalette.bearRing(bearScore).opacity(0.6), radius: 2)
                        .animation(.easeInOut(duration: 0.8), value: bearScore)
                }
            }
            .frame(height: 3)
            .frame(maxWidth: 140)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(FieldPalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(FieldPalette.border, lineWidth: 1))
    }

    // ── Product app grid ─────────────────────────────────────────────────────

    private var appGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(fieldProductApps) { app in
                AppCard(entry: app, onTap: { onAppTap?(app) })
            }
        }
    }
}

// ── App card ──────────────────────────────────────────────────────────────────

private struct AppCard: View {
    let entry: ProductEntry
    var onTap: (() -> Void)?
    @State private var pressed = false

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 10) {
                // Chamber sigil (compact)
                SpellCircle(chamber: entry.chamber, active: true, size: 36, compact: true)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(entry.symbol)
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundStyle(entry.chamber.color)
                        Text(entry.name)
                            .font(FieldType.badge)
                            .foregroundStyle(FieldPalette.textPrimary)
                    }
                    Text(entry.subtitle)
                        .font(FieldType.frequency)
                        .foregroundStyle(FieldPalette.textMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
                if entry.hasUnread {
                    Circle().frame(width: 6, height: 6)
                        .foregroundStyle(entry.chamber.color)
                        .shadow(color: entry.chamber.glowColor, radius: 3)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(FieldPalette.surface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(entry.chamber.color.opacity(pressed ? 0.4 : 0.15), lineWidth: 1)
            )
            .scaleEffect(pressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: pressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in pressed = true }
            .onEnded   { _ in pressed = false })
    }
}

// ── Pyramid backdrop (full screen, portrait) ──────────────────────────────────

private struct PyramidBackdrop: Shape {
    let size: CGSize

    func path(in rect: CGRect) -> Path {
        func pt(_ ux: Double, _ uy: Double) -> CGPoint {
            CGPoint(x: ux * size.width, y: uy * size.height)
        }
        let apex  = pt(0.5, 0.05)
        let left  = pt(0.05, 0.75)
        let right = pt(0.95, 0.75)
        let base  = pt(0.5,  0.92)

        var p = Path()
        p.move(to: apex);  p.addLine(to: left)
        p.move(to: apex);  p.addLine(to: right)
        p.move(to: apex);  p.addLine(to: base)
        p.move(to: left);  p.addLine(to: right)
        p.move(to: left);  p.addLine(to: base)
        p.move(to: right); p.addLine(to: base)
        return p
    }
}

// ── Preview ───────────────────────────────────────────────────────────────────

#Preview("iPhone Home — Active") {
    ARKADASHomeView(
        dojoLink: .active,
        ob1Link: .active,
        somaLink: .buffering,
        bearScore: 0.87,
        chamberStatuses: Chamber.allCases.map { ChamberStatus(chamber: $0, alive: $0 != .tata) }
    )
    .frame(width: 390, height: 844)
}

#Preview("iPhone Home — Offline") {
    ARKADASHomeView(
        dojoLink: .offline,
        ob1Link: .buffering,
        somaLink: .offline,
        bearScore: 0.35,
        chamberStatuses: Chamber.allCases.map { ChamberStatus(chamber: $0, alive: false) }
    )
    .frame(width: 390, height: 844)
}
