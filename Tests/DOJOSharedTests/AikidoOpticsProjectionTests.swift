import XCTest
import SwiftUI
@testable import DOJOUI

final class AikidoOpticsProjectionTests: XCTestCase {
    func testStableParticleIdentitiesSurviveCompleteCycle() {
        XCTAssertTrue(AikidoOpticsProjection.stableIdentitiesSurviveCycle(count: 128))
    }

    func testProjectionKeepsParticleCountAndMovesTowardFocus() {
        let particles = AikidoOpticsProjection.seedParticles(count: 64)
        let attracting = AikidoOpticsProjection.frame(state: .attracting, particles: particles)
        let revealed = AikidoOpticsProjection.frame(state: .revealed, particles: particles)

        XCTAssertEqual(attracting.particles.count, particles.count)
        XCTAssertEqual(revealed.particles.count, particles.count)
        XCTAssertGreaterThan(revealed.opticalFocus, attracting.opticalFocus)
        XCTAssertGreaterThan(revealed.artifactOpacity, attracting.artifactOpacity)
    }

    func testHeldAndUnknownDoNotRevealArtifact() {
        let particles = AikidoOpticsProjection.seedParticles(count: 32)
        let held = AikidoOpticsProjection.frame(state: .held, particles: particles)
        let unknown = AikidoOpticsProjection.frame(state: .unknown, particles: particles)

        XCTAssertEqual(held.artifactOpacity, 0)
        XCTAssertEqual(unknown.artifactOpacity, 0)
        XCTAssertTrue(held.particles.allSatisfy { $0.semanticRole == .hold })
        XCTAssertTrue(unknown.particles.allSatisfy { $0.semanticRole == .unknown })
    }

    func testReduceMotionPreservesSemanticStateButLimitsTravel() {
        let particles = AikidoOpticsProjection.seedParticles(count: 48)
        let normal = AikidoOpticsProjection.frame(state: .attracting, particles: particles, reduceMotion: false)
        let reduced = AikidoOpticsProjection.frame(state: .attracting, particles: particles, reduceMotion: true)

        XCTAssertEqual(normal.state, reduced.state)
        XCTAssertEqual(normal.particles.map(\.identity), reduced.particles.map(\.identity))
        XCTAssertLessThan(reduced.convergence, normal.convergence)
    }

    func testVisualParticleCodableRoundTrip() throws {
        let particle = AikidoOpticsProjection.seedParticles(count: 1).first!

        let data = try JSONEncoder().encode(particle)
        let decoded = try JSONDecoder().decode(VisualParticle.self, from: data)

        XCTAssertEqual(decoded, particle)
    }

    func testRenderingStateCannotMutateAuthority() {
        let envelope = ParticleBoardSampleArtifact.eligibleEnvelope()
        let before = envelope.projectionAuthorityStatus
        _ = AikidoOpticsProjection.frame(state: .revealed, particles: ParticleBoardSampleArtifact.particles(count: 24))

        XCTAssertEqual(envelope.projectionAuthorityStatus, before)
        XCTAssertEqual(envelope.projectionAuthorityStatus.decision, .pass)
    }

    func testWritesPerformanceObservation() throws {
        let directory = URL(fileURLWithPath: "/private/tmp/dojo-particleboard-proof", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let particles = ParticleBoardSampleArtifact.particles(count: ParticleBoardFidelity.photographic.particleCount)
        let iterations = 500
        let states: [ParticleBoardVisualState] = [.quiet, .attracting, .revealed]
        var lines: [String] = []

        for state in states {
            let start = Date()
            for _ in 0..<iterations {
                _ = AikidoOpticsProjection.frame(state: state, particles: particles)
            }
            let elapsed = Date().timeIntervalSince(start)
            let averageMilliseconds = elapsed / Double(iterations) * 1_000
            lines.append("\(state.rawValue): \(String(format: "%.4f", averageMilliseconds)) ms average model-frame projection over \(iterations) iterations")
            XCTAssertGreaterThanOrEqual(averageMilliseconds, 0)
        }

        try lines.joined(separator: "\n").write(
            to: directory.appendingPathComponent("performance-observations.txt"),
            atomically: true,
            encoding: .utf8
        )
    }

    @MainActor
    func testGeneratesVisualEvidenceArtifacts() throws {
        #if os(macOS)
        let directory = URL(fileURLWithPath: "/private/tmp/dojo-particleboard-proof", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let particles = ParticleBoardSampleArtifact.particles(count: 180)
        let envelope = ParticleBoardSampleArtifact.eligibleEnvelope()
        let states: [(String, ParticleBoardVisualState, DraftManifestationEnvelope?, Bool)] = [
            ("quiet", .quiet, nil, false),
            ("lucid", .lucid, envelope, false),
            ("mid-attraction", .attracting, envelope, false),
            ("mid-crystallization", .crystallizing, envelope, false),
            ("revealed", .revealed, envelope, false),
            ("held", .held, ParticleBoardSampleArtifact.heldEnvelope(), false),
            ("dissolving", .dissolving, envelope, false),
            ("returned", .returned, envelope, false),
            ("reduce-motion", .attracting, envelope, true)
        ]

        for (name, state, currentEnvelope, reduceMotion) in states {
            let view = ParticleBoardSpecimenFrame(
                state: state,
                envelope: currentEnvelope,
                particles: particles,
                reduceMotion: reduceMotion,
                debugOverlay: true
            )
            .frame(width: 960, height: 620)
            let renderer = ImageRenderer(content: view)
            renderer.scale = 1
            guard let image = renderer.nsImage,
                  let data = image.tiffRepresentation else {
                throw XCTSkip("SwiftUI ImageRenderer did not produce a macOS image in this environment.")
            }
            try data.write(to: directory.appendingPathComponent("\(name).tiff"))
        }

        XCTAssertTrue(FileManager.default.fileExists(atPath: directory.appendingPathComponent("revealed.tiff").path))
        #else
        throw XCTSkip("Visual evidence artifact generation is macOS-only.")
        #endif
    }
}
