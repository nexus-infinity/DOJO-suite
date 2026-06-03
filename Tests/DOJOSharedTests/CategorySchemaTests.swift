import Foundation
import XCTest
@testable import DOJOShared

final class CategorySchemaTests: XCTestCase {

    private let fixedDate = Date(timeIntervalSince1970: 1_774_712_800) // 2026-03-29T12:00:00Z

    func testCategoryAxisDefaultsCompileIntoLockedHomes() {
        let expected: [CategoryAxis: RoutingPin] = [
            .witness: RoutingPin(
                canonicalHome: .obiWan,
                validationHome: .tata,
                compileHome: .atlas,
                manifestHome: .dojo,
                runtimeBridge: .arkadas,
                archiveHome: .akron
            ),
            .environment: RoutingPin(
                canonicalHome: .obiWan,
                validationHome: .tata,
                compileHome: .atlas,
                manifestHome: .dojo,
                runtimeBridge: .halToArkadas,
                archiveHome: .akron
            ),
            .soma: RoutingPin(
                canonicalHome: .obiWan,
                validationHome: .tata,
                compileHome: .atlas,
                manifestHome: .dojo,
                runtimeBridge: .halToArkadas,
                archiveHome: .akron
            ),
            .logic: RoutingPin(
                canonicalHome: .tata,
                validationHome: .tata,
                compileHome: .atlas,
                manifestHome: .dojo,
                runtimeBridge: .arkadas,
                archiveHome: .akron
            )
        ]

        for axis in CategoryAxis.allCases {
            XCTAssertEqual(axis.defaultRoutingPin, expected[axis], "Unexpected routing pin for \(axis)")
        }
    }

    func testRegistryTypesSerializeRoundTrip() throws {
        let metadata = RegistryMetadata(effectiveAtUTC: fixedDate)
        let envelope = MurmurEnvelope(
            id: UUID(uuidString: "12345678-1234-1234-1234-1234567890AB")!,
            axis: .environment,
            originDevice: .appleWatch,
            observedAt: fixedDate,
            payloadRef: "ambient://living-room/temperature",
            confidence: 0.73,
            localState: .degraded,
            saveIntent: .explicitSave
        )

        struct Fixture: Codable, Equatable {
            let axis: CategoryAxis
            let routingPin: RoutingPin
            let envelope: MurmurEnvelope
            let metadata: RegistryMetadata
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let fixture = Fixture(
            axis: .environment,
            routingPin: CategoryAxis.environment.defaultRoutingPin,
            envelope: envelope,
            metadata: metadata
        )

        let data = try encoder.encode(fixture)
        let decoded = try decoder.decode(Fixture.self, from: data)

        XCTAssertEqual(decoded, fixture)
        XCTAssertEqual(decoded.metadata.version, "1.0.0")
        XCTAssertEqual(decoded.metadata.translationAuthority, "King's Chamber")
    }

    func testEnvironmentAndSomaPurgeWithoutExplicitSave() {
        for axis in [CategoryAxis.environment, .soma] {
            let envelope = MurmurEnvelope(
                axis: axis,
                originDevice: .appleHome,
                observedAt: fixedDate,
                payloadRef: "sensor://retained-locally",
                confidence: 0.41,
                localState: .degraded,
                saveIntent: .queuedOnly
            )

            XCTAssertTrue(envelope.requiresExplicitSaveForPromotion)
            XCTAssertTrue(envelope.staysLocalUntilExplicitSave)
            XCTAssertFalse(envelope.shouldHashPayloadOnPromotion)
            XCTAssertFalse(envelope.shouldCreateWitnessSeat)
            XCTAssertFalse(envelope.shouldQueueTataRatification)
            XCTAssertFalse(envelope.shouldArchivePayload)
            XCTAssertEqual(envelope.nextLocalStateAfterQueueWindow, .purged)
        }
    }

    func testExplicitSavePromotesEnvironmentAndSomaToRatification() {
        for axis in [CategoryAxis.environment, .soma] {
            let envelope = MurmurEnvelope(
                axis: axis,
                originDevice: .iphone,
                observedAt: fixedDate,
                payloadRef: "sensor://saved",
                confidence: 0.84,
                localState: .degraded,
                saveIntent: .explicitSave
            )

            XCTAssertTrue(envelope.requiresExplicitSaveForPromotion)
            XCTAssertFalse(envelope.staysLocalUntilExplicitSave)
            XCTAssertTrue(envelope.shouldHashPayloadOnPromotion)
            XCTAssertTrue(envelope.shouldCreateWitnessSeat)
            XCTAssertTrue(envelope.shouldQueueTataRatification)
            XCTAssertTrue(envelope.shouldArchivePayload)
            XCTAssertEqual(envelope.nextLocalStateAfterQueueWindow, .ratificationQueued)
        }
    }

    func testWitnessAndLogicDoNotRequireExplicitSave() {
        for axis in [CategoryAxis.witness, .logic] {
            let envelope = MurmurEnvelope(
                axis: axis,
                originDevice: .mac,
                observedAt: fixedDate,
                payloadRef: "field://direct-seat",
                confidence: 0.92,
                localState: .queued,
                saveIntent: .queuedOnly
            )

            XCTAssertFalse(envelope.requiresExplicitSaveForPromotion)
            XCTAssertFalse(envelope.staysLocalUntilExplicitSave)
            XCTAssertEqual(envelope.nextLocalStateAfterQueueWindow, .ratificationQueued)
        }
    }

    func testPulsePrimitiveMigrationRejectsLegacyWave() {
        XCTAssertEqual(PulsePrimitive.canonical, "≈")
        XCTAssertEqual(PulsePrimitive.retiredLegacy, "∿")
        XCTAssertTrue(PulsePrimitive.accepts("≈"))
        XCTAssertFalse(PulsePrimitive.accepts("∿"))
    }

    func testBreachBrickRoundTripPreservesCompanionSchemas() throws {
        let breachBrick = InvestigationExtension.BreachBrick(
            brickID: "BB-001",
            actID: "ACT-042",
            actor: "Adam Rich",
            duty: "fiduciary",
            confidence: 0.85,
            probeList: ["bank records", "device logs"],
            siblingBricks: ["BB-002", "BB-003"],
            witnessCompanion: .init(
                evidenceRef: "E-001",
                sensitivity: "HIGH",
                excerpt: "observed transfer",
                sourceAnchor: "/evidence/bank/statement.pdf"
            ),
            ratificationCompanion: .init(
                validationPin: "Fact=Verified Doc=Verified Time=Partial",
                timeWindow: "2024-05-01/2024-05-31",
                fact: "Payment gap detected",
                unresolvedGeometry: "Missing counterparty timestamp"
            ),
            manifestationCompanion: .init(
                requestMissingEvidence: true,
                filing: true,
                additionalActions: ["hold propagation"]
            )
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(breachBrick)
        let decoded = try decoder.decode(InvestigationExtension.BreachBrick.self, from: data)

        XCTAssertEqual(decoded, breachBrick)
        XCTAssertEqual(decoded.witnessCompanion.evidenceRef, "E-001")
        XCTAssertEqual(decoded.ratificationCompanion.tataAnchor, "TATA Anchor")
        XCTAssertEqual(decoded.manifestationCompanion.dojoAllowedActions, "DOJO Allowed Actions")
    }

    func testCategorySchemaSourceRemainsFoundationOnly() throws {
        let source = try String(contentsOf: categorySchemaSourceURL(), encoding: .utf8)

        XCTAssertTrue(source.contains("import Foundation"))
        XCTAssertFalse(source.contains("import SwiftUI"))
        XCTAssertFalse(source.contains("import UIKit"))
        XCTAssertFalse(source.contains("import AppKit"))
        XCTAssertFalse(source.contains("import WatchKit"))
    }

    private func categorySchemaSourceURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/DOJOShared/Models/CategorySchema.swift")
    }
}
