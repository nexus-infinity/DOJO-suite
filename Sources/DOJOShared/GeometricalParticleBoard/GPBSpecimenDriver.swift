import Foundation
import simd

// MARK: - Geometrical Particle Board — Specimen 1
// Lawful object: Participatory Embodied Performance (living geometric visual field)
// NOT DeadEnd.MisroutedUIBuild / CockpitOIRTextGrid / ParticleBoardView

/// Breath phases of the first GPB specimen: smoke → pressure → coalesce → stillness → dissolve.
public enum GPBPhase: String, Codable, Sendable, CaseIterable, Equatable {
    case smoke
    case pressure
    case coalesce
    case stillness
    case dissolve

    /// Map a unit cycle progress `[0, 1)` onto the specimen breath.
    public static func from(cycle: Float) -> GPBPhase {
        let c = cycle.truncatingRemainder(dividingBy: 1.0)
        switch c {
        case 0.00..<0.18: return .smoke
        case 0.18..<0.38: return .pressure
        case 0.38..<0.58: return .coalesce
        case 0.58..<0.78: return .stillness
        default:          return .dissolve
        }
    }
}

/// Recognition of a target geometric form from particle positions (0 = diffuse, 1 = crystallised).
public struct GPBRecognition: Sendable, Equatable {
    public let score: Float
    public let meanDistance: Float
    public let phase: GPBPhase

    public var isRecognisable: Bool { score >= 0.55 && (phase == .coalesce || phase == .stillness) }

    public init(score: Float, meanDistance: Float, phase: GPBPhase) {
        self.score = min(1, max(0, score))
        self.meanDistance = meanDistance
        self.phase = phase
    }
}

/// Deterministic driver for Specimen 1 — ParticleEngine + triangle glyph attractors.
public final class GPBSpecimenDriver: @unchecked Sendable {
    public let engine: ParticleEngine
    public private(set) var phase: GPBPhase = .smoke
    public private(set) var recognition: GPBRecognition
    public private(set) var cycle: Float = 0

    /// Equilateral triangle vertices in field space (z = 0 plane).
    public let glyphVertices: [SIMD3<Float>]
    public let fieldSize: Float
    public let cycleDuration: Float

    public init(
        particleCount: Int = 96,
        fieldSize: Float = 20.0,
        cycleDuration: Float = 12.0,
        seedLayout: Bool = true
    ) {
        self.fieldSize = fieldSize
        self.cycleDuration = cycleDuration
        self.engine = ParticleEngine(count: particleCount, fieldSize: fieldSize)
        self.glyphVertices = Self.makeTriangleVertices(fieldSize: fieldSize)
        self.recognition = GPBRecognition(score: 0, meanDistance: fieldSize, phase: .smoke)
        if seedLayout {
            reseatDiffuseSmoke()
        }
        engine.setDamping(0.96)
        engine.setMaxSpeed(8.0)
    }

    /// Advance the specimen by `dt` seconds. Cycle wraps for continuous breath.
    public func tick(dt: Float) {
        cycle = (cycle + dt / cycleDuration).truncatingRemainder(dividingBy: 1.0)
        if cycle < 0 { cycle += 1 }
        simulate(atCycle: cycle, dt: dt)
    }

    /// Scrub to a unit cycle and run one physics step (for TimelineView / tests).
    public func simulate(atCycle target: Float, dt: Float) {
        cycle = target.truncatingRemainder(dividingBy: 1.0)
        if cycle < 0 { cycle += 1 }
        phase = GPBPhase.from(cycle: cycle)
        applyPhaseForces()
        engine.step(dt: dt)
        recognition = measureRecognition()
    }

    /// Force a unit cycle position without stepping physics (inspection only).
    public func seek(cycle: Float) {
        self.cycle = cycle.truncatingRemainder(dividingBy: 1.0)
        if self.cycle < 0 { self.cycle += 1 }
        phase = GPBPhase.from(cycle: self.cycle)
        applyPhaseForces()
        recognition = measureRecognition()
    }

    /// Reset to diffuse smoke at cycle 0.
    public func reset() {
        cycle = 0
        phase = .smoke
        reseatDiffuseSmoke()
        recognition = measureRecognition()
    }

    // MARK: - Forces

    private func applyPhaseForces() {
        let strength: Float
        let turbulence: Float
        switch phase {
        case .smoke:
            strength = 0.4
            turbulence = 2.2
        case .pressure:
            strength = 6.0
            turbulence = 0.8
        case .coalesce:
            strength = 14.0
            turbulence = 0.15
        case .stillness:
            strength = 18.0
            turbulence = 0.02
        case .dissolve:
            strength = 0.2
            turbulence = 3.5
        }

        for vertex in glyphVertices {
            engine.applyAttractor(position: vertex, strength: strength, falloff: 1.6)
        }
        // Centre of triangle soft attractor
        let centre = (glyphVertices[0] + glyphVertices[1] + glyphVertices[2]) / 3
        engine.applyAttractor(position: centre, strength: strength * 0.35, falloff: 1.8)

        if turbulence > 0.05 {
            engine.applyTurbulence(strength: turbulence)
        }
        if phase == .dissolve {
            engine.applyVortex(center: centre, strength: 4.0, axis: SIMD3<Float>(0, 0, 1))
        }
    }

    // MARK: - Recognition

    public func measureRecognition() -> GPBRecognition {
        let particles = engine.particles
        guard !particles.isEmpty else {
            return GPBRecognition(score: 0, meanDistance: fieldSize, phase: phase)
        }

        var total: Float = 0
        for p in particles {
            var best = Float.greatestFiniteMagnitude
            for v in glyphVertices {
                best = min(best, simdLength(p.position - v))
            }
            // Also reward proximity to edges (midpoints)
            for i in 0..<3 {
                let a = glyphVertices[i]
                let b = glyphVertices[(i + 1) % 3]
                let mid = (a + b) * 0.5
                best = min(best, simdLength(p.position - mid))
            }
            total += best
        }
        let mean = total / Float(particles.count)
        // Typical diffuse mean ~ fieldSize/3; crystallised mean << 2
        let crystallised: Float = 1.8
        let diffuse: Float = fieldSize * 0.35
        let raw = 1.0 - ((mean - crystallised) / max(0.001, diffuse - crystallised))
        var score = min(1, max(0, raw))

        // Phase gate: only coalesce/stillness may claim recognisable structure
        if phase == .smoke || phase == .dissolve {
            score *= 0.35
        } else if phase == .pressure {
            score *= 0.7
        }

        return GPBRecognition(score: score, meanDistance: mean, phase: phase)
    }

    // MARK: - Layout

    private func reseatDiffuseSmoke() {
        let half = fieldSize / 2
        for i in 0..<engine.particles.count {
            let t = Float(i) / Float(max(1, engine.particles.count - 1))
            let angle = t * Float.pi * 2 * 3.0
            let radius = half * (0.35 + 0.55 * (Float(i % 7) / 7.0))
            engine.particles[i].position = SIMD3<Float>(
                cos(angle) * radius,
                sin(angle) * radius * 0.85,
                0
            )
            engine.particles[i].velocity = .zero
            engine.particles[i].acceleration = .zero
            engine.particles[i].shape = .circle
            engine.particles[i].color = .violet
        }
    }

    private static func makeTriangleVertices(fieldSize: Float) -> [SIMD3<Float>] {
        let r = fieldSize * 0.22
        // Equilateral triangle, point up
        return [
            SIMD3<Float>(0, r, 0),
            SIMD3<Float>(-r * 0.866, -r * 0.5, 0),
            SIMD3<Float>(r * 0.866, -r * 0.5, 0)
        ]
    }
}
