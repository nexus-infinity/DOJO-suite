import Foundation

/// Plain product rules derived from attention research.
/// These are implementation gates — not main-screen doctrine, not ontology UI,
/// and not a cognitive-benefit claim.
public enum TodayAttentionProductConstraints {
    /// Stillness is default. Repeated decorative motion is never lawful.
    public static let stillnessByDefault = true

    /// Motion is allowed only for these functional conditions (or explicit time-critical central).
    public enum LawfulMotionReason: String, Sendable {
        case send
        case loading
        case result
        case error
        case explicitTimeCritical
        /// Single transition when opening/closing a panel at a task boundary (not decoration).
        case boundaryPanelTransition
    }

    /// Right utility may open only for these boundary reasons.
    public enum RightPanelOpenReason: String, Sendable {
        case objectSelected
        case resultGenerated
        case explicitReviewOrDetails
        case userManualToggle
    }

    public static func isDecorativeMotionAllowed() -> Bool { false }

    public static func isMotionLawful(_ reason: LawfulMotionReason) -> Bool {
        switch reason {
        case .send, .loading, .result, .error, .explicitTimeCritical, .boundaryPanelTransition:
            return true
        }
    }

    public static func isRightPanelOpenLawful(_ reason: RightPanelOpenReason) -> Bool {
        switch reason {
        case .objectSelected, .resultGenerated, .explicitReviewOrDetails, .userManualToggle:
            return true
        }
    }
}

/// Recovery cue stored on a generated work object (plain product fields).
/// Shown in Details — not a full Focused Presence system.
public struct ObjectRecoveryCue: Equatable, Codable, Sendable, Hashable {
    public var objectLabel: String
    public var sourcePrompt: String
    public var providerModel: String
    public var createdAt: Date
    public var lastStablePoint: String
    public var nextAvailableAction: String
    /// `"none"` when unknown/unchanged; never invents remote change without evidence.
    public var changedWhileAway: String

    public init(
        objectLabel: String,
        sourcePrompt: String,
        providerModel: String,
        createdAt: Date = Date(),
        lastStablePoint: String,
        nextAvailableAction: String,
        changedWhileAway: String = "none"
    ) {
        self.objectLabel = objectLabel
        self.sourcePrompt = sourcePrompt
        self.providerModel = providerModel
        self.createdAt = createdAt
        self.lastStablePoint = lastStablePoint
        self.nextAvailableAction = nextAvailableAction
        self.changedWhileAway = changedWhileAway.isEmpty ? "none" : changedWhileAway
    }

    public var isMinimallyComplete: Bool {
        !objectLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastStablePoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !nextAvailableAction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Factory for a hosted Answer object at create/result boundary.
    public static func forAnswer(
        title: String,
        sourcePrompt: String,
        providerDisplayName: String,
        modelID: String,
        createdAt: Date = Date()
    ) -> ObjectRecoveryCue {
        ObjectRecoveryCue(
            objectLabel: title,
            sourcePrompt: sourcePrompt,
            providerModel: "\(providerDisplayName) · \(modelID)",
            createdAt: createdAt,
            lastStablePoint: "answer_received",
            nextAvailableAction: "Review · Save · Continue · Export",
            changedWhileAway: "none"
        )
    }
}
