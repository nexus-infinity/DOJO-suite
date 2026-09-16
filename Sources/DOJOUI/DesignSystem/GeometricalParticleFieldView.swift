import SwiftUI
import DOJOShared

// MARK: - Geometrical Particle Field View (Specimen 1)
// Participatory Embodied Performance — living geometric visual field.
// Lawful lane: Geometrical Particle Board.
// Forbidden: ParticleBoardView, CockpitOIRTextGrid, Misrouted UI Build naming.

/// First GPB specimen surface: ParticleEngine-driven smoke → triangle recognition breath.
public struct GeometricalParticleFieldView: View {
    @State private var driver = GPBSpecimenDriver(particleCount: 120, fieldSize: 20, cycleDuration: 12)

    public init() {}

    public var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { timeline in
            let _ = tick(from: timeline.date)
            ZStack {
                FieldPalette.void.ignoresSafeArea()
                fieldCanvas
                VStack {
                    HStack {
                        statusPanel
                            .padding(16)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        laneLock
                            .padding(16)
                        Spacer()
                    }
                }
            }
        }
    }

    private func tick(from date: Date) -> Bool {
        let t = Float(date.timeIntervalSinceReferenceDate)
        let cycle = (t / driver.cycleDuration).truncatingRemainder(dividingBy: 1.0)
        driver.simulate(atCycle: cycle, dt: 1.0 / 30.0)
        return true
    }

    // MARK: - Canvas

    private var fieldCanvas: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            context.fill(Path(rect), with: .color(FieldPalette.void))

            let scale = min(size.width, size.height) / CGFloat(driver.fieldSize)
            let origin = CGPoint(x: size.width / 2, y: size.height / 2)

            func project(_ p: SIMD3<Float>) -> CGPoint {
                CGPoint(
                    x: origin.x + CGFloat(p.x) * scale,
                    y: origin.y - CGFloat(p.y) * scale
                )
            }

            let centre3 = (driver.glyphVertices[0] + driver.glyphVertices[1] + driver.glyphVertices[2]) / 3
            let centre = project(centre3)
            let glowR = min(size.width, size.height) * 0.28
            let glowRect = CGRect(x: centre.x - glowR, y: centre.y - glowR, width: glowR * 2, height: glowR * 2)
            let phaseBoost = (driver.phase == .stillness || driver.phase == .coalesce) ? 0.12 : 0.04
            context.fill(
                Path(ellipseIn: glowRect),
                with: .radialGradient(
                    Gradient(colors: [
                        Chamber.dojo.color.opacity(0.06 + phaseBoost),
                        Chamber.atlas.color.opacity(0.04),
                        FieldPalette.void.opacity(0)
                    ]),
                    center: centre,
                    startRadius: 0,
                    endRadius: glowR
                )
            )

            let recognition = driver.recognition.score
            for particle in driver.engine.particles {
                let pt = project(particle.position)
                let r: CGFloat = 2.2 + CGFloat(recognition) * 1.8
                let alpha = 0.25 + Double(recognition) * 0.55
                let color: Color = recognition > 0.5 ? Chamber.dojo.color : Chamber.arkadas.color
                let dot = CGRect(x: pt.x - r, y: pt.y - r, width: r * 2, height: r * 2)
                context.fill(Path(ellipseIn: dot), with: .color(color.opacity(alpha)))
            }

            if driver.recognition.score > 0.35 {
                var path = Path()
                let pts = driver.glyphVertices.map(project)
                path.move(to: pts[0])
                path.addLine(to: pts[1])
                path.addLine(to: pts[2])
                path.closeSubpath()
                let opacity = 0.15 + Double(driver.recognition.score) * 0.75
                context.stroke(
                    path,
                    with: .color(Chamber.dojo.color.opacity(opacity)),
                    lineWidth: 1.5 + CGFloat(driver.recognition.score) * 1.5
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Panels

    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GEOMETRICAL PARTICLE BOARD")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Chamber.dojo.color)

            Text("Participatory Embodied Performance · Specimen 1")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(FieldPalette.textMuted)

            Text("Phase: \(driver.phase.rawValue.uppercased())")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(FieldPalette.textPrimary)

            Text(String(format: "Recognition: %.2f  ·  meanΔ: %.2f", driver.recognition.score, driver.recognition.meanDistance))
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(driver.recognition.isRecognisable ? Chamber.atlas.color : FieldPalette.textDim)

            Text(driver.recognition.isRecognisable ? "STRUCTURE RECOGNISABLE" : "FIELD DIFFUSE")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(driver.recognition.isRecognisable ? Color(hex: "#22C55E") : FieldPalette.textMuted)
        }
        .padding(12)
        .background(FieldPalette.surface.opacity(0.92))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(FieldPalette.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(maxWidth: 360, alignment: .leading)
    }

    private var laneLock: some View {
        Text("Lane lock: not Misrouted UI Build · not CockpitOIRTextGrid · not ParticleBoardView")
            .font(.system(size: 9, design: .monospaced))
            .foregroundStyle(FieldPalette.textDim)
            .padding(8)
            .background(FieldPalette.surfaceRaised.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#if DEBUG
#Preview("GPB Specimen 1") {
    GeometricalParticleFieldView()
        .frame(width: 720, height: 480)
}
#endif
