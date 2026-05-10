import Foundation

// MARK: - Field Integrity Invariant

/// The single check that answers: "Is the DOJO field currently valid or drifting?"
///
/// Runs on any cognitive murmor (Layer 2 node).
/// Authority made executable — it doesn't describe what the field should be,
/// it fails when the field isn't.
///
/// Uses HALProfile.satisfiedLayers for multi-role device support:
/// a single Mac satisfies layers 1, 2, and 3 simultaneously.
public struct FieldInvariant {

    let registry: [MurmorIdentity]
    let currentState: FieldStateSnapshot

    // ─── CHECK 1: Authority — cognitive node must be active ──────────────────
    // If this fails, nothing else matters. The field cannot orient.

    var hasActiveCognitiveNode: Bool {
        registry.contains { murmor in
            murmor.state == .active &&
            murmor.profile.satisfiedLayers.contains(2)
        }
    }

    // ─── CHECK 2: Coverage ───────────────────────────────────────────────────

    var hasSensingCoverage: Bool {
        registry.contains { murmor in
            (murmor.state == .active || murmor.state == .autonomous) &&
            murmor.profile.satisfiedLayers.contains(1)
        }
    }

    var hasOutputPath: Bool {
        registry.contains { murmor in
            (murmor.state == .active || murmor.state == .autonomous) &&
            murmor.profile.satisfiedLayers.contains(3)
        }
    }

    // ─── CHECK 3: Temporal Coherence ─────────────────────────────────────────

    var maxSyncAge: TimeInterval {
        let now = Date()
        return registry
            .filter { $0.state == .active }
            .map { now.timeIntervalSince($0.lastSyncTimestamp) }
            .max() ?? .infinity
    }

    var isSyncCoherent: Bool {
        maxSyncAge < 300  // 5 minutes
    }

    // ─── THE INVARIANT ───────────────────────────────────────────────────────

    public func evaluate() -> FieldInvariantResult {
        // Breach: no cognitive node — field cannot orient, nothing else matters.
        guard hasActiveCognitiveNode else {
            return .breached(reason: .noCognitiveNode)
        }

        let sensing = hasSensingCoverage
        let output  = hasOutputPath

        // Coherent: all coverage present — verify temporal coherence.
        if sensing && output {
            guard isSyncCoherent else {
                return .drifting(reason: .syncStale(age: maxSyncAge))
            }
            return .valid
        }

        // Degraded: can process and act, but no dedicated sensing layer.
        // Cognitive node's own sensors (e.g., Mac mic) may partially cover this.
        if output && !sensing {
            return .degraded(reason: .noSensingCoverage)
        }

        // Drifting: can sense but cannot deliver output.
        return .drifting(reason: .noOutputPath)
    }
}

// MARK: - Results

public enum FieldInvariantResult {
    case valid
    case degraded(reason: DegradedReason)
    case drifting(reason: DriftReason)
    case breached(reason: BreachReason)

    public var coherenceLevel: CoherenceLevel {
        switch self {
        case .valid:    return .coherent
        case .degraded: return .degraded
        case .drifting: return .drifting
        case .breached: return .breached
        }
    }
}

public enum DegradedReason {
    case noSensingCoverage  // Cognitive + output present, but no dedicated sensor layer
}

public enum DriftReason {
    case noOutputPath           // Can sense but cannot deliver
    case syncStale(age: TimeInterval)
}

public enum BreachReason {
    case noCognitiveNode        // Cannot orient — field is structurally blind
}

// MARK: - Coherence State Tracker (Hysteresis)

/// Prevents ActCommand spam by requiring N consecutive evaluations at the same
/// CoherenceLevel before confirming a state transition.
///
/// Usage:
///   if let confirmed = tracker.update(with: result.coherenceLevel) {
///       dispatch(confirmed)   // only fires on stable transitions
///   }
public struct CoherenceStateTracker {

    public private(set) var lastStable: CoherenceLevel
    private var candidate: CoherenceLevel?
    private var candidateCount: Int = 0
    private let requiredConsecutive: Int

    public init(initial: CoherenceLevel = .coherent, requiredConsecutive: Int = 2) {
        self.lastStable = initial
        self.requiredConsecutive = requiredConsecutive
    }

    /// Feed a new evaluation result.
    /// Returns the confirmed new level only when a transition is stable.
    /// Returns nil if no confirmed transition occurred.
    public mutating func update(with new: CoherenceLevel) -> CoherenceLevel? {
        if new == lastStable {
            // Back to stable — reset any pending candidate
            candidate = nil
            candidateCount = 0
            return nil
        }

        if candidate == new {
            candidateCount += 1
        } else {
            // Different candidate — restart count
            candidate = new
            candidateCount = 1
        }

        guard candidateCount >= requiredConsecutive else { return nil }

        // Transition confirmed
        lastStable = new
        candidate = nil
        candidateCount = 0
        return new
    }
}
