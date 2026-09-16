import XCTest
@testable import DOJOShared

private struct ExactAIResultAuthorityVerifier: CockpitAuthorityVerifying {
    let receiptID: String
    let toolName: String
    let correlationID: UUID

    func permits(
        _ proof: CockpitAuthorityProof,
        toolName: String,
        correlationID: UUID
    ) async -> Bool {
        proof.receiptID == receiptID
            && proof.toolName == self.toolName
            && toolName == self.toolName
            && correlationID == self.correlationID
    }
}

final class AIServicePresentationAsStructuredResultBoundaryTests: XCTestCase {
    private let device = DeviceCapabilities(
        platform: .macOS,
        modelIdentifier: "fixture",
        supportsNeuralEngine: true,
        availableMemoryGB: 32,
        recommendedQuantization: .q8_0
    )

    private func result(
        output: String = "Presentation-shaped model output",
        confidence: Double? = nil,
        schemaID: String = AIModelResult.presentationSchemaID
    ) -> AIModelResult {
        AIModelResult(
            output: output,
            confidence: confidence,
            modelUsed: "fixture-model",
            deviceInfo: device,
            classification: .displayOnly,
            schemaID: schemaID
        )
    }

    func testPresentationAndAdvisoryResultsCarryNoAuthorityOrDefaultConfidence() {
        let presentation = result()
        let service = AIService(
            authorityVerifier: DenyAllCockpitAuthorityVerifier()
        )
        let advisory = service.runModel(input: TextInput(data: "hello"))

        XCTAssertFalse(presentation.isAuthorityBearing)
        XCTAssertNil(presentation.confidence)
        XCTAssertEqual(presentation.classification, .displayOnly)
        XCTAssertFalse(advisory.isAuthorityBearing)
        XCTAssertNil(advisory.confidence)
        XCTAssertEqual(advisory.classification, .advisory)
    }

    func testAbsentForgedUncorrelatedAndPresentationOnlyProofsAreDenied() async {
        let correlationID = UUID(
            uuidString: "9ac2c165-c1b3-41ab-8f02-3e1331f78bf3"
        )!
        let presentation = result()
        let scope = AIService.authorityScope(
            for: presentation,
            correlationID: correlationID
        )
        let service = AIService(
            authorityVerifier: ExactAIResultAuthorityVerifier(
                receiptID: "valid-ai-result.receipt.json",
                toolName: scope,
                correlationID: correlationID
            )
        )

        let absent = await service.admitAuthorityBearingResult(
            presentation,
            correlationID: correlationID,
            authorityProof: nil
        )
        let forged = await service.admitAuthorityBearingResult(
            presentation,
            correlationID: correlationID,
            authorityProof: CockpitAuthorityProof(
                receiptID: "forged.receipt.json",
                toolName: scope
            )
        )
        let presentationOnly = await service.admitAuthorityBearingResult(
            presentation,
            correlationID: correlationID,
            authorityProof: CockpitAuthorityProof(
                receiptID: "presentation-only",
                toolName: "presentation-only"
            )
        )
        let uncorrelated = await service.admitAuthorityBearingResult(
            presentation,
            correlationID: UUID(),
            authorityProof: CockpitAuthorityProof(
                receiptID: "valid-ai-result.receipt.json",
                toolName: scope
            )
        )

        XCTAssertNil(absent)
        XCTAssertNil(forged)
        XCTAssertNil(presentationOnly)
        XCTAssertNil(uncorrelated)
    }

    func testHardCodedConfidenceAndLegacyStructuredResultsAreDenied() async {
        let correlationID = UUID(
            uuidString: "66c70efd-e3af-47e9-aead-2a3beb4ee851"
        )!
        let hardCoded = result(confidence: 1.0)
        let legacy = result(schemaID: "LEGACY_AI_MODEL_RESULT")
        let hardCodedScope = AIService.authorityScope(
            for: hardCoded,
            correlationID: correlationID
        )
        let legacyScope = AIService.authorityScope(
            for: legacy,
            correlationID: correlationID
        )

        let hardCodedService = AIService(
            authorityVerifier: ExactAIResultAuthorityVerifier(
                receiptID: "hard-coded.receipt.json",
                toolName: hardCodedScope,
                correlationID: correlationID
            )
        )
        let legacyService = AIService(
            authorityVerifier: ExactAIResultAuthorityVerifier(
                receiptID: "legacy.receipt.json",
                toolName: legacyScope,
                correlationID: correlationID
            )
        )

        let hardCodedAdmission =
            await hardCodedService.admitAuthorityBearingResult(
                hardCoded,
                correlationID: correlationID,
                authorityProof: CockpitAuthorityProof(
                    receiptID: "hard-coded.receipt.json",
                    toolName: hardCodedScope
                )
            )
        let legacyAdmission =
            await legacyService.admitAuthorityBearingResult(
                legacy,
                correlationID: correlationID,
                authorityProof: CockpitAuthorityProof(
                    receiptID: "legacy.receipt.json",
                    toolName: legacyScope
                )
            )

        XCTAssertNil(hardCodedAdmission)
        XCTAssertNil(legacyAdmission)
    }

    func testExactCorrelatedDeterministicProofCreatesSeparateAuthorizedType() async {
        let correlationID = UUID(
            uuidString: "4dbeaf22-bf7d-4890-854c-6c99cf9c8d5c"
        )!
        let advisory = result(
            output: "Bound advisory result",
            confidence: 0.72
        )
        let scope = AIService.authorityScope(
            for: advisory,
            correlationID: correlationID
        )
        let receiptID = "correlated-ai-result.receipt.json"
        let service = AIService(
            authorityVerifier: ExactAIResultAuthorityVerifier(
                receiptID: receiptID,
                toolName: scope,
                correlationID: correlationID
            )
        )

        let admitted = await service.admitAuthorityBearingResult(
            advisory,
            correlationID: correlationID,
            authorityProof: CockpitAuthorityProof(
                receiptID: receiptID,
                toolName: scope
            )
        )

        XCTAssertNotNil(admitted)
        XCTAssertEqual(admitted?.correlationID, correlationID)
        XCTAssertEqual(admitted?.authorityReceiptID, receiptID)
        XCTAssertEqual(admitted?.output, advisory.output)
        XCTAssertFalse(admitted?.sourceResultDigest.isEmpty ?? true)
    }
}
