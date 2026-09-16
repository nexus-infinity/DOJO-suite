import Foundation
import simd

public struct VisualParticle: Codable, Equatable, Sendable, Identifiable {
    public let identity: UInt32
    public var id: UInt32 { identity }
    public var position: SIMD2<Float>
    public var velocity: SIMD2<Float>
    public var target: SIMD2<Float>
    public var primitive: ParticlePrimitive
    public var semanticRole: ParticleSemanticRole
    public var colour: SIMD4<Float>
    public var opacity: Float
    public var depth: Float
    public var lockProgress: Float

    private enum CodingKeys: String, CodingKey {
        case identity
        case position
        case velocity
        case target
        case primitive
        case semanticRole
        case colour
        case opacity
        case depth
        case lockProgress
    }

    public init(
        identity: UInt32,
        position: SIMD2<Float>,
        velocity: SIMD2<Float> = .zero,
        target: SIMD2<Float> = .zero,
        primitive: ParticlePrimitive = .circle,
        semanticRole: ParticleSemanticRole = .quietTrace,
        colour: SIMD4<Float> = SIMD4<Float>(0.102, 0.478, 0.478, 0.1),
        opacity: Float = 0.1,
        depth: Float = 0,
        lockProgress: Float = 0
    ) {
        self.identity = identity
        self.position = position
        self.velocity = velocity
        self.target = target
        self.primitive = primitive
        self.semanticRole = semanticRole
        self.colour = colour
        self.opacity = opacity
        self.depth = depth
        self.lockProgress = lockProgress
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            identity: try container.decode(UInt32.self, forKey: .identity),
            position: try Self.decodeSIMD2(container, forKey: .position),
            velocity: try Self.decodeSIMD2(container, forKey: .velocity),
            target: try Self.decodeSIMD2(container, forKey: .target),
            primitive: try container.decode(ParticlePrimitive.self, forKey: .primitive),
            semanticRole: try container.decode(ParticleSemanticRole.self, forKey: .semanticRole),
            colour: try Self.decodeSIMD4(container, forKey: .colour),
            opacity: try container.decode(Float.self, forKey: .opacity),
            depth: try container.decode(Float.self, forKey: .depth),
            lockProgress: try container.decode(Float.self, forKey: .lockProgress)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identity, forKey: .identity)
        try container.encode([position.x, position.y], forKey: .position)
        try container.encode([velocity.x, velocity.y], forKey: .velocity)
        try container.encode([target.x, target.y], forKey: .target)
        try container.encode(primitive, forKey: .primitive)
        try container.encode(semanticRole, forKey: .semanticRole)
        try container.encode([colour.x, colour.y, colour.z, colour.w], forKey: .colour)
        try container.encode(opacity, forKey: .opacity)
        try container.encode(depth, forKey: .depth)
        try container.encode(lockProgress, forKey: .lockProgress)
    }

    private static func decodeSIMD2<K: CodingKey>(_ container: KeyedDecodingContainer<K>, forKey key: K) throws -> SIMD2<Float> {
        let values = try container.decode([Float].self, forKey: key)
        return SIMD2<Float>(values[safe: 0] ?? 0, values[safe: 1] ?? 0)
    }

    private static func decodeSIMD4<K: CodingKey>(_ container: KeyedDecodingContainer<K>, forKey key: K) throws -> SIMD4<Float> {
        let values = try container.decode([Float].self, forKey: key)
        return SIMD4<Float>(values[safe: 0] ?? 0, values[safe: 1] ?? 0, values[safe: 2] ?? 0, values[safe: 3] ?? 1)
    }
}

public struct AikidoOpticsFrame: Equatable, Sendable {
    public let state: ParticleBoardVisualState
    public let particles: [VisualParticle]
    public let opticalFocus: Float
    public let artifactOpacity: Float
    public let artifactBlur: Float
    public let convergence: Float

    public init(
        state: ParticleBoardVisualState,
        particles: [VisualParticle],
        opticalFocus: Float,
        artifactOpacity: Float,
        artifactBlur: Float,
        convergence: Float
    ) {
        self.state = state
        self.particles = particles
        self.opticalFocus = opticalFocus
        self.artifactOpacity = artifactOpacity
        self.artifactBlur = artifactBlur
        self.convergence = convergence
    }
}

public enum AikidoOpticsProjection {
    public static func seedParticles(count: Int, seed: UInt32 = 717) -> [VisualParticle] {
        (0..<max(1, count)).map { index in
            let unit = Float(index) / Float(max(1, count - 1))
            let radial = Float((index * 37) % 100) / 100.0
            let angle = unit * Float.pi * 2.0 * 5.0
            let x = cos(angle) * (0.14 + radial * 0.76)
            let y = sin(angle * 0.83) * (0.10 + radial * 0.58)
            return VisualParticle(
                identity: seed &+ UInt32(index),
                position: SIMD2<Float>(x, y),
                target: targetPoint(index: index, count: count),
                primitive: primitive(index: index),
                semanticRole: semanticRole(index: index, focus: 0),
                colour: colour(for: semanticRole(index: index, focus: 0)),
                opacity: 0.07 + Float(index % 5) * 0.01,
                depth: Float(index % 7) / 7.0,
                lockProgress: 0
            )
        }
    }

    public static func frame(
        state: ParticleBoardVisualState,
        particles: [VisualParticle],
        reduceMotion: Bool = false
    ) -> AikidoOpticsFrame {
        let focus = opticalFocus(for: state)
        let rawConvergence = convergence(for: state)
        let convergence = reduceMotion ? min(rawConvergence, 0.22) : rawConvergence
        let resolvedParticles = particles.map { particle in
            projectedParticle(particle, state: state, focus: focus, convergence: convergence, reduceMotion: reduceMotion)
        }
        return AikidoOpticsFrame(
            state: state,
            particles: resolvedParticles,
            opticalFocus: focus,
            artifactOpacity: artifactOpacity(for: state),
            artifactBlur: artifactBlur(for: state, reduceMotion: reduceMotion),
            convergence: convergence
        )
    }

    public static func stableIdentitiesSurviveCycle(count: Int) -> Bool {
        let seeded = seedParticles(count: count)
        let cycle: [ParticleBoardVisualState] = [.lucid, .attracting, .crystallizing, .revealed, .dissolving, .returned, .lucid]
        let ids = seeded.map(\.identity)
        return cycle.allSatisfy { frame(state: $0, particles: seeded).particles.map(\.identity) == ids }
    }

    private static func projectedParticle(
        _ particle: VisualParticle,
        state: ParticleBoardVisualState,
        focus: Float,
        convergence: Float,
        reduceMotion: Bool
    ) -> VisualParticle {
        var resolved = particle
        let target = targetPoint(index: Int(particle.identity % 1_000), count: max(1, Int(particle.identity % 420) + 1))
        resolved.target = target
        resolved.position = particle.position + (target - particle.position) * convergence
        resolved.velocity = (target - particle.position) * convergence
        resolved.lockProgress = focus
        resolved.semanticRole = semanticRole(index: Int(particle.identity), focus: focus)
        if state == .held {
            resolved.semanticRole = .hold
        } else if state == .unknown {
            resolved.semanticRole = .unknown
        }
        resolved.colour = colour(for: resolved.semanticRole)
        resolved.opacity = opacity(for: state, focus: focus, particle: particle)
        return resolved
    }

    private static func targetPoint(index: Int, count: Int) -> SIMD2<Float> {
        let columns = 28
        let row = index / columns
        let col = index % columns
        let x = -0.50 + Float(col) / Float(columns - 1)
        let y = -0.30 + Float(row % 18) / 17.0 * 0.60
        let edgeBias = (row % 6 == 0 || col % 7 == 0) ? Float(0.04) : 0
        return SIMD2<Float>(x, y + edgeBias)
    }

    private static func primitive(index: Int) -> ParticlePrimitive {
        ParticlePrimitive.allCases[index % ParticlePrimitive.allCases.count]
    }

    private static func semanticRole(index: Int, focus: Float) -> ParticleSemanticRole {
        if index % 41 == 0 { return .wisdomAccent }
        if focus > 0.74 { return .activeFocus }
        if focus > 0.28 { return .wireframe }
        return .quietTrace
    }

    private static func colour(for role: ParticleSemanticRole) -> SIMD4<Float> {
        switch role {
        case .quietTrace:
            return SIMD4<Float>(0.102, 0.478, 0.478, 0.10)
        case .wireframe:
            return SIMD4<Float>(0.420, 0.302, 0.608, 0.48)
        case .activeFocus:
            return SIMD4<Float>(0.000, 0.851, 0.851, 0.82)
        case .wisdomAccent:
            return SIMD4<Float>(1.000, 0.843, 0.000, 0.72)
        case .hold:
            return SIMD4<Float>(0.984, 0.749, 0.141, 0.56)
        case .unknown:
            return SIMD4<Float>(0.420, 0.541, 0.576, 0.45)
        }
    }

    private static func opticalFocus(for state: ParticleBoardVisualState) -> Float {
        switch state {
        case .quiet: return 0
        case .lucid: return 0.08
        case .receivingCandidate: return 0.18
        case .evaluatingPresentation: return 0.24
        case .attracting: return 0.48
        case .crystallizing: return 0.76
        case .revealed, .revising: return 1.0
        case .dissolving: return 0.42
        case .returned: return 0.06
        case .held: return 0.18
        case .unknown: return 0.12
        }
    }

    private static func convergence(for state: ParticleBoardVisualState) -> Float {
        switch state {
        case .quiet: return 0
        case .lucid: return 0.08
        case .receivingCandidate: return 0.16
        case .evaluatingPresentation: return 0.20
        case .attracting: return 0.48
        case .crystallizing: return 0.74
        case .revealed, .revising: return 0.92
        case .dissolving: return 0.36
        case .returned: return 0.04
        case .held: return 0.10
        case .unknown: return 0.06
        }
    }

    private static func artifactOpacity(for state: ParticleBoardVisualState) -> Float {
        switch state {
        case .crystallizing: return 0.48
        case .revealed, .revising: return 1.0
        case .dissolving: return 0.25
        default: return 0
        }
    }

    private static func artifactBlur(for state: ParticleBoardVisualState, reduceMotion: Bool) -> Float {
        if reduceMotion {
            return state == .revealed || state == .revising ? 0 : 6
        }
        switch state {
        case .crystallizing: return 5
        case .revealed, .revising: return 0
        case .dissolving: return 9
        default: return 12
        }
    }

    private static func opacity(for state: ParticleBoardVisualState, focus: Float, particle: VisualParticle) -> Float {
        switch state {
        case .quiet:
            return 0.06
        case .lucid, .returned:
            return 0.08 + particle.depth * 0.06
        case .held, .unknown:
            return 0.18
        case .dissolving:
            return 0.18 + particle.depth * 0.10
        default:
            return min(0.92, 0.20 + focus * 0.58 + particle.depth * 0.08)
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
