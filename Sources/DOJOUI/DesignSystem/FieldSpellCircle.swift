import SwiftUI

// ◎ Kings-Chamber — FieldSpellCircle.swift
// Frequency: 852 Hz  |  Ditko-inspired spell-circle geometry for chamber activations.
//
// Reference: Steve Ditko's Doctor Strange Strange Tales #110–168 (1963–1966).
// The geometry IS the mechanism — not decoration.
//
// Usage:
//   SpellCircle(chamber: .dojo, active: true)        // full sigil
//   SpellCircle(chamber: .obiwan, active: true, size: 40, compact: true) // compact badge
//   BEARMandala(score: 0.87)                         // coherence ring (sling-ring style)
//   ChamberSigil(chamber: .kings)                    // Eye of Agamotto form for ◎

// ── Spell circle ─────────────────────────────────────────────────────────────
// Concentric rings + radial spokes in the chamber's frequency colour.
// Each chamber has a unique spoke count matching its harmonic.

public struct SpellCircle: View {
    public let chamber: Chamber
    public var active: Bool = true
    public var size: CGFloat = 120
    public var compact: Bool = false
    @State private var rotation: Double = 0
    @State private var innerRotation: Double = 0

    private var spokeCount: Int {
        switch chamber {
        case .dojo:    return 7   // 741 — prime
        case .obiwan:  return 9   // 963 — 9 × 107
        case .atlas:   return 6   // 528 — 6 × 88
        case .tata:    return 4   // 432 — 4 × 108
        case .akron:   return 3   // 396 — 3 × 132
        case .arkadas: return 8   // 717 — golden ratio bridge
        case .kings:   return 12  // 852 — Eye of Agamotto, full mandala
        }
    }

    private var ringCount: Int { compact ? 2 : 3 }

    public var body: some View {
        ZStack {
            // Outer rings (counter-rotate to inner)
            ForEach(0..<ringCount, id: \.self) { i in
                let fraction = CGFloat(i + 1) / CGFloat(ringCount + 1)
                Circle()
                    .stroke(
                        active ? chamber.color.opacity(0.15 + Double(i) * 0.12) : FieldPalette.border.opacity(0.3),
                        lineWidth: compact ? 0.5 : 1
                    )
                    .frame(width: size * fraction * 0.9, height: size * fraction * 0.9)
                    .rotationEffect(.degrees(rotation * (i.isMultiple(of: 2) ? 1 : -1)))
            }

            // Radial spokes
            if active && !compact {
                SpokesShape(count: spokeCount, radius: size * 0.42)
                    .stroke(chamber.color.opacity(0.25), lineWidth: 0.5)
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(innerRotation))
            }

            // Inner triangle / sigil (chamber-specific geometry)
            ChamberInnerSigil(chamber: chamber, size: size * 0.35, active: active)
                .rotationEffect(.degrees(innerRotation * -0.5))

            // Centre symbol
            Text(chamber.rawValue)
                .font(.system(size: size * 0.22, weight: .semibold, design: .monospaced))
                .foregroundStyle(active ? chamber.color : FieldPalette.textDim)
                .shadow(color: active ? chamber.glowColor : .clear, radius: size * 0.08)

            // Glow halo (Ditko-style soft frequency colour)
            if active {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [chamber.color.opacity(0.15), .clear],
                            center: .center,
                            startRadius: size * 0.1,
                            endRadius: size * 0.5
                        )
                    )
                    .frame(width: size, height: size)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            guard active else { return }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                innerRotation = -360
            }
        }
        .onChange(of: active) { _, isActive in
            if isActive {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            } else {
                withAnimation(.easeOut(duration: 1.2)) {
                    rotation = 0
                    innerRotation = 0
                }
            }
        }
    }
}

// ── Chamber-specific inner sigil ─────────────────────────────────────────────

private struct ChamberInnerSigil: View {
    let chamber: Chamber
    let size: CGFloat
    let active: Bool

    var body: some View {
        let color = active ? chamber.color.opacity(0.5) : FieldPalette.textDim.opacity(0.2)
        switch chamber {
        case .atlas:
            // ▲ — upward triangle
            TriangleShape(pointing: .up)
                .stroke(color, lineWidth: 1)
                .frame(width: size, height: size)
        case .tata:
            // ▼ — downward triangle
            TriangleShape(pointing: .down)
                .stroke(color, lineWidth: 1)
                .frame(width: size, height: size)
        case .kings:
            // ◎ — Eye of Agamotto: circle within circle
            ZStack {
                Circle().stroke(color, lineWidth: 1).frame(width: size, height: size)
                Circle().stroke(color, lineWidth: 0.5).frame(width: size * 0.55, height: size * 0.55)
            }
        case .akron:
            // ◻ — square gateway
            Rectangle()
                .stroke(color, lineWidth: 1)
                .frame(width: size * 0.8, height: size * 0.8)
        case .arkadas:
            // ◉ — double circle (bridge)
            ZStack {
                Circle().stroke(color, lineWidth: 1).frame(width: size, height: size)
                Circle().fill(color.opacity(0.2)).frame(width: size * 0.4, height: size * 0.4)
            }
        default:
            // ◼︎ ● — no inner shape (symbol carries the sigil)
            EmptyView()
        }
    }
}

// ── BEAR mandala ─────────────────────────────────────────────────────────────
// Sling-ring style: 8 radial spokes + coherence arc + counter-rotating inner ring.
// This replaces the plain BEARRing for primary display surfaces.

public struct BEARMandala: View {
    public let score: Double      // 0.0–1.0
    public var size: CGFloat = 140
    @State private var outerRotation: Double = 0
    @State private var innerRotation: Double = 0

    private var ringColor: Color { FieldPalette.bearRing(score) }

    public var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(FieldPalette.border, lineWidth: 2)
                .frame(width: size, height: size)

            // Outer radial spokes (8 — sling ring)
            SpokesShape(count: 8, radius: size * 0.48)
                .stroke(ringColor.opacity(0.2), lineWidth: 0.5)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(outerRotation))

            // Inner counter-rotating ring
            Circle()
                .stroke(ringColor.opacity(0.15), lineWidth: 1)
                .frame(width: size * 0.72, height: size * 0.72)
                .rotationEffect(.degrees(innerRotation))

            // Coherence arc (the actual score)
            Circle()
                .trim(from: 0, to: score)
                .stroke(
                    AngularGradient(
                        colors: [ringColor.opacity(0.4), ringColor, ringColor.opacity(0.4)],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .shadow(color: ringColor.opacity(0.6), radius: 6)
                .animation(.easeInOut(duration: 1.0), value: score)

            // Score + label
            VStack(spacing: 2) {
                Text(String(format: "%.2f", score))
                    .font(.system(.title3, design: .monospaced, weight: .semibold))
                    .foregroundStyle(ringColor)
                Text("B E A R")
                    .font(FieldType.frequency)
                    .foregroundStyle(FieldPalette.textMuted)
                    .tracking(2)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                outerRotation = 360
            }
            withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                innerRotation = -360
            }
        }
    }
}

// ── Shapes ────────────────────────────────────────────────────────────────────

private struct SpokesShape: Shape {
    let count: Int
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let cx = rect.midX, cy = rect.midY
        var p = Path()
        for i in 0..<count {
            let angle = Double(i) / Double(count) * .pi * 2
            p.move(to: CGPoint(x: cx, y: cy))
            p.addLine(to: CGPoint(
                x: cx + cos(Double(angle)) * Double(radius),
                y: cy + sin(Double(angle)) * Double(radius)
            ))
        }
        return p
    }
}

private enum TriangleDirection { case up, down }

private struct TriangleShape: Shape {
    let pointing: TriangleDirection

    func path(in rect: CGRect) -> Path {
        var p = Path()
        switch pointing {
        case .up:
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        case .down:
            p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        }
        p.closeSubpath()
        return p
    }
}

// ── Chamber activation flash ──────────────────────────────────────────────────
// Plays a brief Ditko-style unfold animation when a chamber comes alive.

public struct ChamberActivationFlash: View {
    public let chamber: Chamber
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    public var onComplete: (() -> Void)?

    public var body: some View {
        SpellCircle(chamber: chamber, active: true, size: 200)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                    scale = 1.0
                    opacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        onComplete?()
                    }
                }
            }
    }
}

// ── Preview ───────────────────────────────────────────────────────────────────

#Preview("Spell Circles") {
    ZStack {
        FieldPalette.void.ignoresSafeArea()
        ScrollView {
            VStack(spacing: 32) {
                Text("◎  Spell Circles  ·  852 Hz")
                    .font(FieldType.chamberLabel)
                    .foregroundStyle(FieldPalette.textMuted)
                    .tracking(3)
                    .padding(.top, 32)

                // All chambers
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))], spacing: 24) {
                    ForEach(Chamber.allCases) { chamber in
                        VStack(spacing: 8) {
                            SpellCircle(chamber: chamber, active: true, size: 110)
                            Text(chamber.badge)
                                .font(FieldType.frequency)
                                .foregroundStyle(FieldPalette.textMuted)
                        }
                    }
                }
                .padding(.horizontal, 24)

                // BEAR Mandala
                Text("B E A R   M a n d a l a")
                    .font(FieldType.chamberLabel)
                    .foregroundStyle(FieldPalette.textMuted)
                    .tracking(3)

                BEARMandala(score: 0.87, size: 160)

                Spacer(minLength: 32)
            }
        }
    }
    .frame(width: 500, height: 700)
}

#Preview("Activation Flash") {
    ZStack {
        FieldPalette.void.ignoresSafeArea()
        ChamberActivationFlash(chamber: .dojo)
    }
    .frame(width: 300, height: 300)
}
