import CryptoKit
import Foundation

// MARK: - External Seal Experience contracts V0
// Source handoff: docs/EXTERNAL_SEAL_EXPERIENCE_REFINEMENT_HANDOFF_V0.md
// Predecessor: Observer-Aligned Assistance ontology (unchanged, separate construct)
// Status: DESIGN_REFINEMENT · HOLD.NOT_IMPLEMENTED_OR_VERIFIED for live physical seal
// Invariant: Originating Weave cannot self-seal.

// MARK: Judgement

public enum ESESealJudgementOutcome: String, Codable, Sendable, Equatable {
    case valid = "VALID"
    case invalid = "INVALID"
    case delta = "DELTA"
    case cannotVerify = "CANNOT_VERIFY"
}

public enum ESEHumanJudgementChoice: String, Codable, Sendable, Equatable {
    case matches = "MATCHES"
    case differs = "DIFFERS"
    case cannotVerify = "I_CANNOT_VERIFY_THIS"

    public var mappedOutcome: ESESealJudgementOutcome {
        switch self {
        case .matches: return .valid
        case .differs: return .delta
        case .cannotVerify: return .cannotVerify
        }
    }
}

public enum ESEReturnState: String, Codable, Sendable, Equatable {
    case sealed = "SEALED"
    case notSealed = "NOT_SEALED"
}

// MARK: Seal Candidate (immutable after submission)

public struct ESESealCandidate: Codable, Sendable, Equatable, Identifiable {
    public var id: String { candidateId }
    public let candidateId: String
    public let predecessorRunId: String
    public let subjectObjectIds: [String]
    public let declaredOutcome: String
    public let expectedManifestation: String
    public let acceptanceCriteria: [String]
    public let forbiddenChanges: [String]
    public let evidenceAnchorPointers: [String]
    public let knownUnknowns: [String]
    public let knownHolds: [String]
    public let originatingSurface: String
    public let originatingWeaver: String
    public let submittedAt: String
    /// Hash of canonical candidate body; recomputation must match after submission.
    public let candidateHash: String

    public init(
        candidateId: String = UUID().uuidString,
        predecessorRunId: String,
        subjectObjectIds: [String],
        declaredOutcome: String,
        expectedManifestation: String,
        acceptanceCriteria: [String],
        forbiddenChanges: [String],
        evidenceAnchorPointers: [String],
        knownUnknowns: [String],
        knownHolds: [String],
        originatingSurface: String,
        originatingWeaver: String,
        submittedAt: String = ISO8601DateFormatter().string(from: Date()),
        candidateHash: String? = nil
    ) {
        self.candidateId = candidateId
        self.predecessorRunId = predecessorRunId
        self.subjectObjectIds = subjectObjectIds
        self.declaredOutcome = declaredOutcome
        self.expectedManifestation = expectedManifestation
        self.acceptanceCriteria = acceptanceCriteria
        self.forbiddenChanges = forbiddenChanges
        self.evidenceAnchorPointers = evidenceAnchorPointers
        self.knownUnknowns = knownUnknowns
        self.knownHolds = knownHolds
        self.originatingSurface = originatingSurface
        self.originatingWeaver = originatingWeaver
        self.submittedAt = submittedAt
        if let candidateHash {
            self.candidateHash = candidateHash
        } else {
            self.candidateHash = ESESealCandidate.computeHash(
                candidateId: candidateId,
                predecessorRunId: predecessorRunId,
                subjectObjectIds: subjectObjectIds,
                declaredOutcome: declaredOutcome,
                expectedManifestation: expectedManifestation,
                acceptanceCriteria: acceptanceCriteria,
                forbiddenChanges: forbiddenChanges,
                evidenceAnchorPointers: evidenceAnchorPointers,
                knownUnknowns: knownUnknowns,
                knownHolds: knownHolds,
                originatingSurface: originatingSurface,
                originatingWeaver: originatingWeaver,
                submittedAt: submittedAt
            )
        }
    }

    /// Recompute hash from fields (excluding stored hash) for immutability checks.
    public func recomputeHash() -> String {
        ESESealCandidate.computeHash(
            candidateId: candidateId,
            predecessorRunId: predecessorRunId,
            subjectObjectIds: subjectObjectIds,
            declaredOutcome: declaredOutcome,
            expectedManifestation: expectedManifestation,
            acceptanceCriteria: acceptanceCriteria,
            forbiddenChanges: forbiddenChanges,
            evidenceAnchorPointers: evidenceAnchorPointers,
            knownUnknowns: knownUnknowns,
            knownHolds: knownHolds,
            originatingSurface: originatingSurface,
            originatingWeaver: originatingWeaver,
            submittedAt: submittedAt
        )
    }

    public var hashIntact: Bool {
        recomputeHash() == candidateHash
    }

    private static func computeHash(
        candidateId: String,
        predecessorRunId: String,
        subjectObjectIds: [String],
        declaredOutcome: String,
        expectedManifestation: String,
        acceptanceCriteria: [String],
        forbiddenChanges: [String],
        evidenceAnchorPointers: [String],
        knownUnknowns: [String],
        knownHolds: [String],
        originatingSurface: String,
        originatingWeaver: String,
        submittedAt: String
    ) -> String {
        let payload = [
            candidateId,
            predecessorRunId,
            subjectObjectIds.joined(separator: ","),
            declaredOutcome,
            expectedManifestation,
            acceptanceCriteria.joined(separator: "|"),
            forbiddenChanges.joined(separator: "|"),
            evidenceAnchorPointers.joined(separator: "|"),
            knownUnknowns.joined(separator: "|"),
            knownHolds.joined(separator: "|"),
            originatingSurface,
            originatingWeaver,
            submittedAt
        ].joined(separator: "\n")
        let digest = SHA256.hash(data: Data(payload.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: Participatory calibration

public struct ESEParticipatoryCalibrationPlan: Codable, Sendable, Equatable, Identifiable {
    public var id: String { planId }
    public let planId: String
    public let candidateId: String
    /// Must reference an acceptance criterion index or text — not decorative.
    public let tiedAcceptanceCriterion: String
    public let observerActionDescription: String
    public let sensoryModalities: [String]
    public let contributesToMeasurement: Bool
    public let reversible: Bool
    public let accessible: Bool

    public init(
        planId: String,
        candidateId: String,
        tiedAcceptanceCriterion: String,
        observerActionDescription: String,
        sensoryModalities: [String],
        contributesToMeasurement: Bool,
        reversible: Bool,
        accessible: Bool
    ) {
        self.planId = planId
        self.candidateId = candidateId
        self.tiedAcceptanceCriterion = tiedAcceptanceCriterion
        self.observerActionDescription = observerActionDescription
        self.sensoryModalities = sensoryModalities
        self.contributesToMeasurement = contributesToMeasurement
        self.reversible = reversible
        self.accessible = accessible
    }

    public var isLawfulCalibration: Bool {
        contributesToMeasurement && reversible && accessible && !tiedAcceptanceCriterion.isEmpty
    }
}

public struct ESEActualManifestation: Codable, Sendable, Equatable, Identifiable {
    public var id: String { manifestationId }
    public let manifestationId: String
    public let candidateId: String
    public let presentedAt: String
    public let description: String
    public let measuredAttributes: [String: String]
    public let presentedWithoutManualHunt: Bool
}

public struct ESESealJudgement: Codable, Sendable, Equatable, Identifiable {
    public var id: String { judgementId }
    public let judgementId: String
    public let candidateId: String
    public let humanChoice: ESEHumanJudgementChoice
    public let outcome: ESESealJudgementOutcome
    public let notes: String
    public let recordedAt: String
    public let requiredAnchorsPresent: Bool

    public init(
        judgementId: String = UUID().uuidString,
        candidateId: String,
        humanChoice: ESEHumanJudgementChoice,
        notes: String = "",
        recordedAt: String = ISO8601DateFormatter().string(from: Date()),
        requiredAnchorsPresent: Bool,
        forceInvalidOnDiffer: Bool = false
    ) {
        self.judgementId = judgementId
        self.candidateId = candidateId
        self.humanChoice = humanChoice
        self.notes = notes
        self.recordedAt = recordedAt
        self.requiredAnchorsPresent = requiredAnchorsPresent
        if humanChoice == .differs && forceInvalidOnDiffer {
            self.outcome = .invalid
        } else if humanChoice == .matches && !requiredAnchorsPresent {
            // MATCHES without anchors cannot become sealed VALID for return
            self.outcome = .cannotVerify
        } else {
            self.outcome = humanChoice.mappedOutcome
        }
    }
}

public struct ESEVerificationReceipt: Codable, Sendable, Equatable, Identifiable {
    public var id: String { receiptId }
    public let receiptId: String
    public let candidateId: String
    public let judgementId: String
    public let declaredSummary: String
    public let actualSummary: String
    public let independentComparison: Bool
    public let originatorCouldNotModify: Bool
    public let receiptPathOrUnknown: String
}

public struct ESEConfigurationEpoch: Codable, Sendable, Equatable, Identifiable {
    public var id: String { epochId }
    public let epochId: String
    public let candidateId: String
    public let physicalIdentity: String
    public let digitalIdentity: String
    public let hardwareFirmwareState: String
    public let channelMap: [String: String]
    public let executionHost: String
    public let humanInputSurface: String
    public let activeEnvironmentalAttentionSurface: String
    public let permissionState: String
    public let authorityCeilings: [String]
    public let calibrationResults: [String: String]
    public let observerJudgement: ESESealJudgementOutcome
    public let evidenceAnchors: [String]
    public let receiptPointer: String
    public let sealedAt: String
    public let predecessorEpochIdOrUnknown: String
    public let active: Bool

    public init(
        epochId: String,
        candidateId: String,
        physicalIdentity: String,
        digitalIdentity: String,
        hardwareFirmwareState: String,
        channelMap: [String: String],
        executionHost: String,
        humanInputSurface: String,
        activeEnvironmentalAttentionSurface: String,
        permissionState: String,
        authorityCeilings: [String],
        calibrationResults: [String: String],
        observerJudgement: ESESealJudgementOutcome,
        evidenceAnchors: [String],
        receiptPointer: String,
        sealedAt: String,
        predecessorEpochIdOrUnknown: String,
        active: Bool
    ) {
        self.epochId = epochId
        self.candidateId = candidateId
        self.physicalIdentity = physicalIdentity
        self.digitalIdentity = digitalIdentity
        self.hardwareFirmwareState = hardwareFirmwareState
        self.channelMap = channelMap
        self.executionHost = executionHost
        self.humanInputSurface = humanInputSurface
        self.activeEnvironmentalAttentionSurface = activeEnvironmentalAttentionSurface
        self.permissionState = permissionState
        self.authorityCeilings = authorityCeilings
        self.calibrationResults = calibrationResults
        self.observerJudgement = observerJudgement
        self.evidenceAnchors = evidenceAnchors
        self.receiptPointer = receiptPointer
        self.sealedAt = sealedAt
        self.predecessorEpochIdOrUnknown = predecessorEpochIdOrUnknown
        self.active = active
    }
}

public struct ESEMaterialChangeDelta: Codable, Sendable, Equatable, Identifiable {
    public var id: String { deltaId }
    public let deltaId: String
    public let epochId: String
    public let changeClass: String
    public let description: String
    public let detectedAt: String
    /// Always true for material changes under this contract.
    public let invalidatesSealInheritance: Bool

    public init(
        deltaId: String,
        epochId: String,
        changeClass: String,
        description: String,
        detectedAt: String,
        invalidatesSealInheritance: Bool = true
    ) {
        self.deltaId = deltaId
        self.epochId = epochId
        self.changeClass = changeClass
        self.description = description
        self.detectedAt = detectedAt
        self.invalidatesSealInheritance = invalidatesSealInheritance
    }
}

public struct ESERecommissionRequest: Codable, Sendable, Equatable, Identifiable {
    public var id: String { requestId }
    public let requestId: String
    public let predecessorEpochId: String
    public let materialChangeDeltaId: String
    public let reducedAuthorityCeiling: String
    public let affectedAttributes: [String]
    public let returnPoint: String
    public let resumeCondition: String

    public init(
        requestId: String,
        predecessorEpochId: String,
        materialChangeDeltaId: String,
        reducedAuthorityCeiling: String,
        affectedAttributes: [String],
        returnPoint: String,
        resumeCondition: String
    ) {
        self.requestId = requestId
        self.predecessorEpochId = predecessorEpochId
        self.materialChangeDeltaId = materialChangeDeltaId
        self.reducedAuthorityCeiling = reducedAuthorityCeiling
        self.affectedAttributes = affectedAttributes
        self.returnPoint = returnPoint
        self.resumeCondition = resumeCondition
    }
}

// MARK: State machine

public enum ESEState: String, Codable, Sendable, Equatable, CaseIterable {
    case candidateReceived
    case identified
    case declaredPresented
    case calibrationInProgress
    case actualManifested
    case comparisonReady
    case judgementRecorded
    case sealed
    case delta
    case intentionallyUnsealed
}

public enum ESEEvent: String, Codable, Sendable, Equatable {
    case identify
    case presentDeclared
    case beginCalibration
    case completeCalibration
    case presentActual
    case readyForComparison
    case recordJudgementMatches
    case recordJudgementDiffers
    case recordJudgementCannotVerify
    case missingAnchor
    case materialChange
    case emergencyFailSafe
}

/// Deterministic External Seal Experience state machine.
/// Originator cannot force seal; no jump from candidateReceived to sealed.
public struct ESEStateMachine: Sendable, Equatable {
    public private(set) var state: ESEState
    public private(set) var lastReturnMessage: String
    public let candidateId: String
    public private(set) var anchorsPresent: Bool
    public private(set) var calibrationTiedToCriterion: Bool

    public init(
        candidateId: String,
        anchorsPresent: Bool = true,
        calibrationTiedToCriterion: Bool = true
    ) {
        self.candidateId = candidateId
        self.state = .candidateReceived
        self.lastReturnMessage = "Ready for independent verification"
        self.anchorsPresent = anchorsPresent
        self.calibrationTiedToCriterion = calibrationTiedToCriterion
    }

    /// Originating weaver cannot seal. Always false.
    public static func originatorCanSelfSeal() -> Bool { false }

    public mutating func apply(_ event: ESEEvent) -> Bool {
        let next = transition(from: state, event: event)
        guard let next else { return false }
        state = next
        updateReturnMessage(for: event)
        return true
    }

    public func transition(from: ESEState, event: ESEEvent) -> ESEState? {
        // Hard ban: never jump candidateReceived → sealed
        if from == .candidateReceived && (event == .recordJudgementMatches || event == .recordJudgementDiffers) {
            return nil
        }

        switch (from, event) {
        case (.candidateReceived, .identify):
            return .identified
        case (.identified, .presentDeclared):
            return .declaredPresented
        case (.declaredPresented, .beginCalibration):
            return calibrationTiedToCriterion ? .calibrationInProgress : nil
        case (.calibrationInProgress, .completeCalibration):
            return .actualManifested
        // Allow skip of calibration only if plan marks not required — not via sealed jump
        case (.declaredPresented, .presentActual):
            return .actualManifested
        case (.actualManifested, .readyForComparison), (.actualManifested, .presentActual):
            return .comparisonReady
        case (.comparisonReady, .recordJudgementMatches):
            // Judgement recorded then seal only with anchors (no originator self-seal path)
            return anchorsPresent ? .sealed : .intentionallyUnsealed
        case (.comparisonReady, .recordJudgementDiffers):
            return .delta
        case (.comparisonReady, .recordJudgementCannotVerify):
            return .intentionallyUnsealed
        case (.comparisonReady, .missingAnchor), (.sealed, .missingAnchor):
            return .intentionallyUnsealed
        case (.sealed, .materialChange), (.delta, .materialChange):
            return .delta
        case (_, .emergencyFailSafe):
            // Reduces authority / unseals without reseal claim
            return .intentionallyUnsealed
        default:
            return nil
        }
    }

    private mutating func updateReturnMessage(for event: ESEEvent) {
        switch state {
        case .sealed:
            lastReturnMessage = "SEALED"
        case .delta:
            lastReturnMessage = "NOT SEALED\nMissing: correspondence or material change\nReturn point: External Seal Experience comparison\nResume condition: recommission affected attributes"
        case .intentionallyUnsealed:
            if event == .emergencyFailSafe {
                lastReturnMessage = "NOT SEALED\nMissing: post-failsafe re-verification\nReturn point: External Seal Experience arrival\nResume condition: observer re-enters seal experience"
            } else if event == .missingAnchor || !anchorsPresent {
                lastReturnMessage = "NOT SEALED\nMissing: required evidence anchors\nReturn point: provide anchors then External Seal Experience\nResume condition: anchors present"
            } else {
                lastReturnMessage = "NOT SEALED\nMissing: independent verification\nReturn point: External Seal Experience\nResume condition: observer can verify"
            }
        case .candidateReceived:
            lastReturnMessage = "Ready for independent verification"
        default:
            lastReturnMessage = "In progress: \(state.rawValue)"
        }
    }

    /// Seal return only after judgement with anchors — never from originator flag.
    public static func returnState(
        machineState: ESEState,
        judgement: ESESealJudgementOutcome?,
        anchorsPresent: Bool
    ) -> ESEReturnState {
        if machineState == .sealed && judgement == .valid && anchorsPresent {
            return .sealed
        }
        return .notSealed
    }
}

// MARK: Epoch / recommission helpers

public enum ESEConfigurationEpochRules {
    /// Material change never silently inherits predecessor seal.
    public static func materialChangeInvalidatesInheritance() -> Bool { true }

    public static func applyMaterialChange(
        activeEpoch: ESEConfigurationEpoch,
        change: ESEMaterialChangeDelta
    ) -> (epoch: ESEConfigurationEpoch, request: ESERecommissionRequest) {
        // Predecessor preserved (inactive); seal inheritance invalidated.
        let frozen = ESEConfigurationEpoch(
            epochId: activeEpoch.epochId,
            candidateId: activeEpoch.candidateId,
            physicalIdentity: activeEpoch.physicalIdentity,
            digitalIdentity: activeEpoch.digitalIdentity,
            hardwareFirmwareState: activeEpoch.hardwareFirmwareState,
            channelMap: activeEpoch.channelMap,
            executionHost: activeEpoch.executionHost,
            humanInputSurface: activeEpoch.humanInputSurface,
            activeEnvironmentalAttentionSurface: activeEpoch.activeEnvironmentalAttentionSurface,
            permissionState: activeEpoch.permissionState,
            authorityCeilings: activeEpoch.authorityCeilings,
            calibrationResults: activeEpoch.calibrationResults,
            observerJudgement: activeEpoch.observerJudgement,
            evidenceAnchors: activeEpoch.evidenceAnchors,
            receiptPointer: activeEpoch.receiptPointer,
            sealedAt: activeEpoch.sealedAt,
            predecessorEpochIdOrUnknown: activeEpoch.predecessorEpochIdOrUnknown,
            active: false
        )
        _ = change
        let request = ESERecommissionRequest(
            requestId: UUID().uuidString,
            predecessorEpochId: frozen.epochId,
            materialChangeDeltaId: change.deltaId,
            reducedAuthorityCeiling: "last_safe_witnessed_ceiling",
            affectedAttributes: [change.changeClass],
            returnPoint: "External Seal Experience · Arrival",
            resumeCondition: "affected attributes recommissioned and externally judged"
        )
        return (frozen, request)
    }

    public static func linkSuccessor(
        predecessor: ESEConfigurationEpoch,
        newEpochId: String,
        candidateId: String,
        sealedAt: String
    ) -> ESEConfigurationEpoch {
        ESEConfigurationEpoch(
            epochId: newEpochId,
            candidateId: candidateId,
            physicalIdentity: predecessor.physicalIdentity,
            digitalIdentity: predecessor.digitalIdentity,
            hardwareFirmwareState: predecessor.hardwareFirmwareState,
            channelMap: predecessor.channelMap,
            executionHost: predecessor.executionHost,
            humanInputSurface: predecessor.humanInputSurface,
            activeEnvironmentalAttentionSurface: predecessor.activeEnvironmentalAttentionSurface,
            permissionState: predecessor.permissionState,
            authorityCeilings: predecessor.authorityCeilings,
            calibrationResults: predecessor.calibrationResults,
            observerJudgement: .valid,
            evidenceAnchors: predecessor.evidenceAnchors,
            receiptPointer: predecessor.receiptPointer,
            sealedAt: sealedAt,
            predecessorEpochIdOrUnknown: predecessor.epochId,
            active: true
        )
    }
}

// MARK: Ritual stage labels (seven-stage)

public enum ESECommissioningStage: Int, Codable, Sendable, CaseIterable {
    case arrival = 1
    case identification = 2
    case declaredState = 3
    case participatoryCalibration = 4
    case actualManifestation = 5
    case guidedComparison = 6
    case returnState = 7

    public var title: String {
        switch self {
        case .arrival: return "Arrival"
        case .identification: return "Identification"
        case .declaredState: return "Declared state"
        case .participatoryCalibration: return "Participatory calibration"
        case .actualManifestation: return "Actual manifestation"
        case .guidedComparison: return "Guided comparison and judgement"
        case .returnState: return "Return"
        }
    }
}

// MARK: Sensory non-collapse

public enum ESESensoryLayer: String, Codable, Sendable, CaseIterable {
    case audioInput
    case calibrationStimulus
    case assistanceOutput
    case observerAcknowledgement
}

public enum ESEMeta {
    public static let objectId = "DOJO.ExternalSealExperience"
    public static let handoffPath = "docs/EXTERNAL_SEAL_EXPERIENCE_REFINEMENT_HANDOFF_V0.md"
    public static let status = "DESIGN_REFINEMENT"
    public static let runtimeStatus = "HOLD.NOT_IMPLEMENTED_OR_VERIFIED"
    public static let predecessorOntology = "docs/OBSERVER_ALIGNED_ASSISTANCE_ONTOLOGY_V0.jsonl"
}
