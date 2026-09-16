import SwiftUI
import DOJOShared
import simd

// MARK: - DOJO Geometric Smoke Recognition View
// Candidate convergence component.
// Combines Smoke Accent atmosphere with GPB Specimen 1 recognition proof.
// Not ParticleBoardView. Not product maturity. Not renderer identity.

public struct DOJOGeometricSmokeRecognitionView: View {
    private let debugMode: Bool
    @State private var driver = GPBSpecimenDriver(particleCount: 120, fieldSize: 20, cycleDuration: 12)

    private let smokeColumns = 28
    private let smokeRows = 16

    public init(debugMode: Bool = false) {
        self.debugMode = debugMode
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let cycle = cyclePosition(for: timeline.date)
            let _ = simulate(cycle: cycle)

            ZStack {
                FieldPalette.void.ignoresSafeArea()

                Canvas { context, size in
                    let rect = CGRect(origin: .zero, size: size)
                    context.fill(Path(rect), with: .color(FieldPalette.void))

                    let geometry = GeometryProjection(size: size, fieldSize: driver.fieldSize)
                    let glyphPoints = driver.glyphVertices.map { geometry.project($0) }
                    let centre = glyphCentre(glyphPoints)
                    let pressure = pressureProgress(for: cycle)
                    let condensation = condensationProgress(for: cycle)
                    let stillness = stillnessProgress(for: cycle)
                    let dissolve = dissolveProgress(for: cycle)

                    drawAtmosphere(
                        context: &context,
                        rect: rect,
                        centre: centre,
                        pressure: pressure,
                        stillness: stillness,
                        dissolve: dissolve
                    )
                    drawSmokeLayer(
                        context: &context,
                        size: size,
                        centre: centre,
                        glyphPoints: glyphPoints,
                        time: time,
                        pressure: pressure,
                        condensation: condensation,
                        stillness: stillness,
                        dissolve: dissolve
                    )
                    drawRecognitionParticles(
                        context: &context,
                        geometry: geometry,
                        recognition: Double(driver.recognition.score),
                        dissolve: dissolve
                    )
                    drawTriangle(
                        context: &context,
                        points: glyphPoints,
                        recognition: Double(driver.recognition.score),
                        condensation: condensation,
                        stillness: stillness,
                        dissolve: dissolve
                    )
                }

                if debugMode {
                    debugPanel
                        .padding(16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }

                laneLock
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
    }

    private func cyclePosition(for date: Date) -> Float {
        let t = Float(date.timeIntervalSinceReferenceDate)
        return (t / driver.cycleDuration).truncatingRemainder(dividingBy: 1.0)
    }

    private func simulate(cycle: Float) -> Bool {
        driver.simulate(atCycle: cycle, dt: 1.0 / 30.0)
        return true
    }

    private var debugPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DOJO GEOMETRIC SMOKE RECOGNITION")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Chamber.dojo.color)

            Text("Candidate convergence · proof inside feel")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(FieldPalette.textMuted)

            Text("Phase: \(driver.phase.rawValue.uppercased())")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(FieldPalette.textPrimary)

            Text(String(format: "Recognition: %.2f  ·  meanDelta: %.2f", driver.recognition.score, driver.recognition.meanDistance))
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
        .frame(maxWidth: 380, alignment: .leading)
    }

    private var laneLock: some View {
        Text("Candidate rail: not ProductMaturity · not RendererIdentity · not VisualEquivalence · not ParticleBoardView")
            .font(.system(size: 9, design: .monospaced))
            .foregroundStyle(FieldPalette.textDim)
            .padding(8)
            .background(FieldPalette.surfaceRaised.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func drawAtmosphere(
        context: inout GraphicsContext,
        rect: CGRect,
        centre: CGPoint,
        pressure: Double,
        stillness: Double,
        dissolve: Double
    ) {
        let radius = min(rect.width, rect.height) * 0.32
        let glowRect = CGRect(x: centre.x - radius, y: centre.y - radius, width: radius * 2, height: radius * 2)
        context.fill(
            Path(ellipseIn: glowRect),
            with: .radialGradient(
                Gradient(colors: [
                    Chamber.dojo.color.opacity(0.08 + 0.14 * pressure + 0.10 * stillness),
                    Chamber.atlas.color.opacity(0.05 + 0.08 * stillness),
                    FieldPalette.void.opacity(0)
                ]),
                center: centre,
                startRadius: 0,
                endRadius: radius
            )
        )

        if pressure > 0.02 || dissolve > 0.02 {
            for ring in 1...3 {
                let ringRadius = rect.width * (0.075 + Double(ring) * 0.045) * (1.0 + 0.22 * dissolve - 0.12 * pressure)
                let ringRect = CGRect(
                    x: centre.x - ringRadius,
                    y: centre.y - ringRadius,
                    width: ringRadius * 2,
                    height: ringRadius * 2
                )
                context.stroke(
                    Path(ellipseIn: ringRect),
                    with: .color(Chamber.dojo.color.opacity(0.018 + 0.026 * (pressure + dissolve) / Double(ring))),
                    lineWidth: 1
                )
            }
        }
    }

    private func drawSmokeLayer(
        context: inout GraphicsContext,
        size: CGSize,
        centre: CGPoint,
        glyphPoints: [CGPoint],
        time: TimeInterval,
        pressure: Double,
        condensation: Double,
        stillness: Double,
        dissolve: Double
    ) {
        context.drawLayer { layer in
            layer.addFilter(.blur(radius: 16 + 8 * dissolve))
            for row in 0..<smokeRows {
                for col in 0..<smokeColumns {
                    let base = smokePoint(row: row, col: col, in: size, time: time)
                    let fieldDensity = radialInfluence(point: base, center: centre, radius: min(size.width, size.height) * 0.48)
                    let glyphDensity = glyphFieldStrength(at: base, glyphPoints: glyphPoints)
                    let edgeAngle = glyphEdgeDirection(at: base, glyphPoints: glyphPoints)

                    let pulled = CGPoint(
                        x: base.x + (centre.x - base.x) * pressure * fieldDensity * 0.12,
                        y: base.y + (centre.y - base.y) * pressure * fieldDensity * 0.12
                    )
                    let released = CGPoint(
                        x: pulled.x + (base.x - centre.x) * dissolve * 0.10,
                        y: pulled.y + (base.y - centre.y) * dissolve * 0.10
                    )

                    let noise = smokeNoise(at: base, time: time)
                    let alignment = max(0, glyphDensity * (pressure + condensation + stillness - dissolve * 0.65))
                    let alpha = 0.02
                        + 0.08 * noise
                        + 0.08 * fieldDensity
                        + 0.20 * pressure * glyphDensity
                        + 0.18 * stillness * glyphDensity
                        + 0.08 * dissolve
                    let width = 30
                        + 28 * noise
                        + 28 * pressure * fieldDensity
                        + 36 * glyphDensity * condensation
                    let height = 18
                        + 12 * noise
                        + 16 * fieldDensity
                        + 18 * glyphDensity * pressure

                    let path = orientedSmokePath(
                        center: released,
                        width: width,
                        height: height,
                        angle: edgeAngle,
                        alignment: alignment
                    )
                    let tint = glyphDensity > 0.24
                        ? Color(hex: "#C4B5FD").opacity(alpha * (0.9 + 0.22 * glyphDensity))
                        : Chamber.dojo.color.opacity(alpha)
                    layer.fill(path, with: .color(tint))
                }
            }
        }
    }

    private func drawRecognitionParticles(
        context: inout GraphicsContext,
        geometry: GeometryProjection,
        recognition: Double,
        dissolve: Double
    ) {
        for particle in driver.engine.particles {
            let point = geometry.project(particle.position)
            let radius = 1.9 + recognition * 1.7 + dissolve * 0.5
            let alpha = max(0.12, 0.20 + recognition * 0.54 - dissolve * 0.16)
            let color = recognition > 0.5 ? Chamber.dojo.color : Chamber.arkadas.color
            let dot = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
            context.fill(Path(ellipseIn: dot), with: .color(color.opacity(alpha)))
        }
    }

    private func drawTriangle(
        context: inout GraphicsContext,
        points: [CGPoint],
        recognition: Double,
        condensation: Double,
        stillness: Double,
        dissolve: Double
    ) {
        guard points.count == 3 else { return }
        let opacity = max(0, min(1, 0.10 + recognition * 0.72 + stillness * 0.20 - dissolve * 0.78))
        guard opacity > 0.02 else { return }

        var path = Path()
        path.move(to: points[0])
        path.addLine(to: points[1])
        path.addLine(to: points[2])
        path.closeSubpath()

        context.stroke(
            path,
            with: .color(Chamber.dojo.color.opacity(opacity)),
            lineWidth: 1.4 + CGFloat(recognition + condensation) * 1.4
        )
    }

    private func pressureProgress(for cycle: Float) -> Double {
        switch cycle {
        case 0.18..<0.38:
            return easeInOut(Double((cycle - 0.18) / 0.20))
        case 0.38..<0.78:
            return 1
        case 0.78..<0.92:
            return 1 - easeInOut(Double((cycle - 0.78) / 0.14))
        default:
            return 0
        }
    }

    private func condensationProgress(for cycle: Float) -> Double {
        switch cycle {
        case 0.38..<0.58:
            return easeInOut(Double((cycle - 0.38) / 0.20))
        case 0.58..<0.78:
            return 1
        case 0.78..<0.92:
            return 1 - easeInOut(Double((cycle - 0.78) / 0.14))
        default:
            return 0
        }
    }

    private func stillnessProgress(for cycle: Float) -> Double {
        switch cycle {
        case 0.58..<0.78:
            return 1
        case 0.52..<0.58:
            return easeInOut(Double((cycle - 0.52) / 0.06))
        case 0.78..<0.86:
            return 1 - easeInOut(Double((cycle - 0.78) / 0.08))
        default:
            return 0
        }
    }

    private func dissolveProgress(for cycle: Float) -> Double {
        switch cycle {
        case 0.78..<1.0:
            return easeInOut(Double((cycle - 0.78) / 0.22))
        default:
            return 0
        }
    }

    private func smokePoint(row: Int, col: Int, in size: CGSize, time: TimeInterval) -> CGPoint {
        let xUnit = (Double(col) + 0.5) / Double(smokeColumns)
        let yUnit = (Double(row) + 0.5) / Double(smokeRows)
        let driftX = sin(time * 0.11 + Double(row) * 0.54) * 16 + cos(time * 0.08 + Double(col) * 0.37) * 9
        let driftY = cos(time * 0.10 + Double(col) * 0.49) * 14 + sin(time * 0.07 + Double(row) * 0.43) * 7
        return CGPoint(x: size.width * xUnit + driftX, y: size.height * yUnit + driftY)
    }

    private func smokeNoise(at point: CGPoint, time: TimeInterval) -> Double {
        let a = sin(Double(point.x) * 0.013 + time * 0.25)
        let b = cos(Double(point.y) * 0.015 - time * 0.20)
        let c = sin(Double(point.x + point.y) * 0.009 + time * 0.15)
        return ((a + b + c) / 3 + 1) * 0.5
    }

    private func glyphCentre(_ points: [CGPoint]) -> CGPoint {
        guard !points.isEmpty else { return .zero }
        let total = points.reduce(CGPoint.zero) { partial, point in
            CGPoint(x: partial.x + point.x, y: partial.y + point.y)
        }
        return CGPoint(x: total.x / CGFloat(points.count), y: total.y / CGFloat(points.count))
    }

    private func radialInfluence(point: CGPoint, center: CGPoint, radius: CGFloat) -> Double {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        let normalized = max(0, min(1, 1 - distance / radius))
        return Double(normalized * normalized)
    }

    private func glyphFieldStrength(at point: CGPoint, glyphPoints: [CGPoint]) -> Double {
        guard glyphPoints.count == 3 else { return 0 }
        let distances = [
            distanceToSegment(point: point, a: glyphPoints[0], b: glyphPoints[1]),
            distanceToSegment(point: point, a: glyphPoints[1], b: glyphPoints[2]),
            distanceToSegment(point: point, a: glyphPoints[2], b: glyphPoints[0])
        ]
        let nearest = distances.min() ?? .greatestFiniteMagnitude
        return max(0, min(1, 1 - Double(nearest / 60)))
    }

    private func glyphEdgeDirection(at point: CGPoint, glyphPoints: [CGPoint]) -> Double {
        guard glyphPoints.count == 3 else { return 0 }
        let edges = [
            (glyphPoints[0], glyphPoints[1]),
            (glyphPoints[1], glyphPoints[2]),
            (glyphPoints[2], glyphPoints[0])
        ]
        let nearest = edges.min { lhs, rhs in
            distanceToSegment(point: point, a: lhs.0, b: lhs.1) < distanceToSegment(point: point, a: rhs.0, b: rhs.1)
        } ?? edges[0]
        return atan2(nearest.1.y - nearest.0.y, nearest.1.x - nearest.0.x)
    }

    private func distanceToSegment(point: CGPoint, a: CGPoint, b: CGPoint) -> CGFloat {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let lengthSquared = dx * dx + dy * dy
        guard lengthSquared > 0 else { return hypot(point.x - a.x, point.y - a.y) }
        let t = max(0, min(1, ((point.x - a.x) * dx + (point.y - a.y) * dy) / lengthSquared))
        let projection = CGPoint(x: a.x + t * dx, y: a.y + t * dy)
        return hypot(point.x - projection.x, point.y - projection.y)
    }

    private func orientedSmokePath(center: CGPoint, width: Double, height: Double, angle: Double, alignment: Double) -> Path {
        let alignedWidth = width * (1 + 0.35 * alignment)
        let alignedHeight = max(8, height * (1 - 0.42 * alignment))
        let rect = CGRect(
            x: center.x - alignedWidth / 2,
            y: center.y - alignedHeight / 2,
            width: alignedWidth,
            height: alignedHeight
        )
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: center.x, y: center.y)
        transform = transform.rotated(by: angle)
        transform = transform.translatedBy(x: -center.x, y: -center.y)
        return Path(ellipseIn: rect).applying(transform)
    }

    private func easeInOut(_ value: Double) -> Double {
        let t = max(0, min(1, value))
        return t * t * (3 - 2 * t)
    }
}

private struct GeometryProjection {
    let size: CGSize
    let fieldSize: Float

    func project(_ point: SIMD3<Float>) -> CGPoint {
        let scale = min(size.width, size.height) / CGFloat(fieldSize)
        let origin = CGPoint(x: size.width / 2, y: size.height / 2)
        return CGPoint(
            x: origin.x + CGFloat(point.x) * scale,
            y: origin.y - CGFloat(point.y) * scale
        )
    }
}

#if DEBUG
#Preview("DOJO Geometric Smoke Recognition · Normal") {
    DOJOGeometricSmokeRecognitionView()
        .frame(width: 860, height: 560)
}

#Preview("DOJO Geometric Smoke Recognition · Debug") {
    DOJOGeometricSmokeRecognitionView(debugMode: true)
        .frame(width: 860, height: 560)
}
#endif
