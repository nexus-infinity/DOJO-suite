import XCTest
@testable import DOJOShared

final class CapabilityBoundaryTests: XCTestCase {
    func testKeyPresenceDoesNotPromoteCapability() {
        let result = CapabilityBoundaryPolicy.provider(
            providerID: "google",
            hasKey: true,
            wasTested: false,
            testSucceeded: false
        )

        XCTAssertEqual(result.stage, .configured)
        XCTAssertEqual(result.decision, .unknown)
        XCTAssertFalse(result.composerExposureAllowed)
        XCTAssertTrue(result.custodyReference.contains("keychain://"))
    }

    func testSuccessfulSmokeReachesModelCompatibleButKeepsComposerClosed() {
        let result = CapabilityBoundaryPolicy.provider(
            providerID: "openai",
            hasKey: true,
            wasTested: true,
            testSucceeded: true
        )

        XCTAssertEqual(result.stage, .modelCompatible)
        XCTAssertEqual(result.decision, .pass)
        XCTAssertFalse(result.composerExposureAllowed)
    }

    func testMissingKeyHoldsWithNextEvidence() {
        let result = CapabilityBoundaryPolicy.provider(
            providerID: "anthropic",
            hasKey: false,
            wasTested: false,
            testSucceeded: false
        )

        XCTAssertEqual(result.stage, .notConfigured)
        XCTAssertEqual(result.decision, .hold)
        XCTAssertNotNil(result.nextEvidence)
    }

    func testHostedAdvisoryPreflightPassesForBoundedDesktopContext() throws {
        let context = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator"))
        let profile = try XCTUnwrap(FieldSurfaceCoordinationCatalog.permissionProfile(for: context.permissionProfileID))
        let boundary = CapabilityBoundaryPolicy.provider(
            providerID: "openai",
            hasKey: true,
            wasTested: true,
            testSucceeded: true
        )

        let result = HarmonicKernelPreflightPolicy.hostedAdvisoryRequest(
            prompt: "What is the next local move?",
            hasStagedFiles: false,
            providerBoundary: boundary,
            observerContext: context,
            permissionProfile: profile
        )

        XCTAssertTrue(result.mayProceed)
        XCTAssertEqual(result.decision, .pass)
        XCTAssertNil(result.blockedLaw)
        XCTAssertTrue(result.holds.isEmpty)
    }

    func testHostedAdvisoryPreflightConservationBlocksStagedFiles() throws {
        let context = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator"))
        let profile = try XCTUnwrap(FieldSurfaceCoordinationCatalog.permissionProfile(for: context.permissionProfileID))
        let boundary = CapabilityBoundaryPolicy.provider(
            providerID: "openai",
            hasKey: true,
            wasTested: true,
            testSucceeded: true
        )

        let result = HarmonicKernelPreflightPolicy.hostedAdvisoryRequest(
            prompt: "Analyse this file",
            hasStagedFiles: true,
            providerBoundary: boundary,
            observerContext: context,
            permissionProfile: profile
        )

        XCTAssertFalse(result.mayProceed)
        XCTAssertEqual(result.decision, .hold)
        XCTAssertEqual(result.blockedLaw, .conservation)
        XCTAssertEqual(result.holds, ["HOLD.FileAnalysisNotWired"])
    }

    func testHostedAdvisoryPreflightConservationRequiresObserverContext() throws {
        let profile = try XCTUnwrap(FieldSurfaceCoordinationCatalog.permissionProfile(for: "READ_ONLY_CONTEXT_PROJECTION"))
        let boundary = CapabilityBoundaryPolicy.provider(
            providerID: "openai",
            hasKey: true,
            wasTested: true,
            testSucceeded: true
        )

        let result = HarmonicKernelPreflightPolicy.hostedAdvisoryRequest(
            prompt: "Continue",
            hasStagedFiles: false,
            providerBoundary: boundary,
            observerContext: nil,
            permissionProfile: profile
        )

        XCTAssertFalse(result.mayProceed)
        XCTAssertEqual(result.blockedLaw, .conservation)
        XCTAssertEqual(result.holds, ["HOLD.ObserverContextUnavailable"])
    }

    func testHostedAdvisoryPreflightSymmetryBlocksAuthorityOverreach() throws {
        let context = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator"))
        let boundary = CapabilityBoundaryPolicy.provider(
            providerID: "openai",
            hasKey: true,
            wasTested: true,
            testSucceeded: true
        )
        let overreachingProfile = FieldPermissionProfile(
            id: "OVERREACH",
            displayName: "Overreach",
            allowedChannels: [.visual, .evidential],
            allowedActions: ["send"],
            authorityCeiling: "UNBOUNDED",
            canMutateSource: true,
            canControlApplication: true,
            canSendOrPublish: true,
            consentInferred: true
        )

        let result = HarmonicKernelPreflightPolicy.hostedAdvisoryRequest(
            prompt: "Send this",
            hasStagedFiles: false,
            providerBoundary: boundary,
            observerContext: context,
            permissionProfile: overreachingProfile
        )

        XCTAssertFalse(result.mayProceed)
        XCTAssertEqual(result.blockedLaw, .symmetry)
        XCTAssertEqual(result.holds, ["HOLD.PermissionProfileOverreach"])
    }

    func testHostedAdvisoryPreflightResonanceBlocksStressMode() throws {
        let existing = try XCTUnwrap(FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator"))
        let profile = try XCTUnwrap(FieldSurfaceCoordinationCatalog.permissionProfile(for: existing.permissionProfileID))
        let boundary = CapabilityBoundaryPolicy.provider(
            providerID: "openai",
            hasKey: true,
            wasTested: true,
            testSucceeded: true
        )
        let stressedContext = FieldObserverContext(
            observerID: existing.id,
            version: existing.version,
            asOfTime: existing.asOfTime,
            timeZone: existing.timeZone,
            permissionProfileID: existing.permissionProfileID,
            continuityContractID: existing.continuityContractID,
            primaryDeviceID: existing.primaryDeviceID,
            availableSurfaceIDs: existing.availableSurfaceIDs,
            activeChannels: existing.activeChannels,
            activity: FieldObserverActivityState(kind: .driving, safetyCritical: true),
            attention: FieldObserverAttentionState(level: .low, mode: .audioPrimary),
            location: FieldObserverLocationState(semantic: .inVehicle, primarySurfaceID: "vehicle_safety_simulator"),
            activeObjects: existing.activeObjects,
            continuityPromises: existing.continuityPromises,
            evidenceRef: existing.evidenceRef,
            integrityStatus: existing.integrityStatus
        )

        let result = HarmonicKernelPreflightPolicy.hostedAdvisoryRequest(
            prompt: "Continue",
            hasStagedFiles: false,
            providerBoundary: boundary,
            observerContext: stressedContext,
            permissionProfile: profile
        )

        XCTAssertFalse(result.mayProceed)
        XCTAssertEqual(result.blockedLaw, .resonance)
        XCTAssertEqual(result.holds, ["HOLD.StressModeRequiresExit"])
    }
}
