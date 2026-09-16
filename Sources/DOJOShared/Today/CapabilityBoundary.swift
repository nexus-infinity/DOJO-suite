import Foundation

/// Non-secret projection of a provider capability check.
///
/// This is a support seam only: it describes custody and observed readiness;
/// it does not create processing state, authority, or a new provider registry.
public struct CapabilityBoundaryResult: Codable, Equatable, Identifiable {
    public enum Stage: String, Codable, Equatable, Sendable {
        case notConfigured = "not_configured"
        case configured
        case responding
        case modelCompatible = "model_compatible"
        case failed
        case hold
    }

    public enum Decision: String, Codable, Equatable, Sendable {
        case pass = "PASS"
        case fail = "FAIL"
        case unknown = "UNKNOWN"
        case hold = "HOLD"
    }

    public let id: String
    public let providerID: String
    public let custodyReference: String
    public let stage: Stage
    public let decision: Decision
    public let composerExposureAllowed: Bool
    public let nextEvidence: String?

    public init(
        providerID: String,
        custodyReference: String,
        stage: Stage,
        decision: Decision,
        composerExposureAllowed: Bool = false,
        nextEvidence: String? = nil
    ) {
        self.id = "\(providerID):\(custodyReference)"
        self.providerID = providerID
        self.custodyReference = custodyReference
        self.stage = stage
        self.decision = decision
        self.composerExposureAllowed = composerExposureAllowed
        self.nextEvidence = nextEvidence
    }
}

public enum CapabilityBoundaryPolicy {
    /// A key's presence is never sufficient to expose a capability.
    public static func provider(
        providerID: String,
        hasKey: Bool,
        wasTested: Bool,
        testSucceeded: Bool
    ) -> CapabilityBoundaryResult {
        let custody = "keychain://org.field.dojo.m1.api-keys/\(providerID)"
        guard hasKey else {
            return CapabilityBoundaryResult(
                providerID: providerID,
                custodyReference: "keychain://org.field.dojo.m1.api-keys/\(providerID)",
                stage: .notConfigured,
                decision: .hold,
                nextEvidence: "Add a key through the existing Keychain-backed Settings route."
            )
        }
        guard wasTested else {
            return CapabilityBoundaryResult(
                providerID: providerID,
                custodyReference: custody,
                stage: .configured,
                decision: .unknown,
                nextEvidence: "Run the bounded read-only provider smoke test."
            )
        }
        if testSucceeded {
            return CapabilityBoundaryResult(
                providerID: providerID,
                custodyReference: custody,
                stage: .modelCompatible,
                decision: .pass,
                nextEvidence: nil
            )
        }
        return CapabilityBoundaryResult(
            providerID: providerID,
            custodyReference: custody,
            stage: .failed,
            decision: .fail,
            nextEvidence: "Inspect the redacted provider receipt; do not copy or rotate the key here."
        )
    }
}

public enum HarmonicKernelLaw: String, Codable, CaseIterable, Equatable, Sendable {
    case conservation = "CONSERVATION"
    case symmetry = "SYMMETRY"
    case resonance = "RESONANCE"
}

public struct HarmonicKernelPreflightResult: Codable, Equatable, Sendable {
    public let decision: CapabilityBoundaryResult.Decision
    public let blockedLaw: HarmonicKernelLaw?
    public let reason: String
    public let holds: [String]

    public init(
        decision: CapabilityBoundaryResult.Decision,
        blockedLaw: HarmonicKernelLaw?,
        reason: String,
        holds: [String]
    ) {
        self.decision = decision
        self.blockedLaw = blockedLaw
        self.reason = reason
        self.holds = holds
    }

    public var mayProceed: Bool {
        decision == .pass
    }
}

public enum HarmonicKernelPreflightPolicy {
    /// Admission guard for external advisory requests before they may become a
    /// visible Today object. This does not trust or validate model output; it
    /// only proves the request path is local, bounded, reversible, and not
    /// safety-critical.
    public static func hostedAdvisoryRequest(
        prompt: String,
        hasStagedFiles: Bool,
        providerBoundary: CapabilityBoundaryResult,
        observerContext: FieldObserverContext?,
        permissionProfile: FieldPermissionProfile?
    ) -> HarmonicKernelPreflightResult {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return hold(.conservation, "HOLD.EmptyPrompt", "Conservation blocked an empty hosted request.")
        }
        guard !hasStagedFiles else {
            return hold(.conservation, "HOLD.FileAnalysisNotWired", "Conservation blocked staged files from hosted advisory Ask.")
        }
        guard providerBoundary.decision != .hold, providerBoundary.decision != .fail else {
            return hold(.conservation, "HOLD.ProviderBoundaryNotPassable", providerBoundary.nextEvidence ?? "Provider boundary is not passable.")
        }
        guard let observerContext else {
            return hold(.conservation, "HOLD.ObserverContextUnavailable", "Observer context is required before hosted advisory Ask.")
        }
        guard let permissionProfile else {
            return hold(.symmetry, "HOLD.PermissionProfileUnavailable", "Permission profile is required before hosted advisory Ask.")
        }
        guard permissionProfile.decision(for: .visual) == .pass,
              permissionProfile.decision(for: .evidential) == .pass
        else {
            return hold(.symmetry, "HOLD.PermissionProfileDoesNotAllowContextProjection", "Permission does not allow visual evidential projection.")
        }
        guard !permissionProfile.canMutateSource,
              !permissionProfile.canControlApplication,
              !permissionProfile.canSendOrPublish,
              !permissionProfile.consentInferred
        else {
            return hold(.symmetry, "HOLD.PermissionProfileOverreach", "Symmetry blocked source mutation, application control, send/publish, or inferred consent.")
        }
        guard !observerContext.activity.safetyCritical,
              observerContext.attention.level != .low,
              observerContext.attention.level != .unavailable,
              observerContext.attention.level != .unknown
        else {
            return hold(.resonance, "HOLD.StressModeRequiresExit", "Resonance blocked hosted advisory Ask under stress or safety-critical attention.")
        }

        return HarmonicKernelPreflightResult(
            decision: .pass,
            blockedLaw: nil,
            reason: "PASS.HarmonicKernel.HostedAdvisoryRequest",
            holds: []
        )
    }

    private static func hold(
        _ law: HarmonicKernelLaw,
        _ hold: String,
        _ reason: String
    ) -> HarmonicKernelPreflightResult {
        HarmonicKernelPreflightResult(
            decision: .hold,
            blockedLaw: law,
            reason: reason,
            holds: [hold]
        )
    }
}
