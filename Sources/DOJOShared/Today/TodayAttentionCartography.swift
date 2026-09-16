import Foundation

/// A bounded representation contract for projecting a deep work state onto a flat surface.
///
/// This is not the Geometrical Particle Board and does not route agents. It preserves the
/// minimum state a Today surface needs to orient, engage, sustain, release, and recover work
/// without treating geometry, colour, motion, or gaze as authority.
public struct TodayAttentionContract: Equatable, Sendable {
    public enum Phase: String, CaseIterable, Sendable {
        case orient
        case engage
        case sustain
        case release
        case recover
    }

    public enum Topology: String, CaseIterable, Sendable {
        case horizon
        case peripheral
        case boundary
        case contextual
        case central
    }

    public enum Motion: String, CaseIterable, Sendable {
        case still
        case singleTransition
        case repeatedTimeCritical
    }

    /// The three semantic depths that must survive projection onto the visible surface.
    /// The names follow the existing dimensional-projection naming lock.
    public struct DepthColumn: Equatable, Sendable {
        public let executive: String
        public let strategic: String
        public let foundation: String

        public init(executive: String, strategic: String, foundation: String) {
            self.executive = executive
            self.strategic = strategic
            self.foundation = foundation
        }

        public var isComplete: Bool {
            !executive.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !strategic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !foundation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    public let objectID: String
    public let phase: Phase
    public let topology: Topology
    public let motion: Motion
    public let depth: DepthColumn
    public let authorityCeiling: String
    public let recoveryPointer: String

    public init(
        objectID: String,
        phase: Phase,
        topology: Topology,
        motion: Motion = .still,
        depth: DepthColumn,
        authorityCeiling: String,
        recoveryPointer: String
    ) {
        self.objectID = objectID
        self.phase = phase
        self.topology = topology
        self.motion = motion
        self.depth = depth
        self.authorityCeiling = authorityCeiling
        self.recoveryPointer = recoveryPointer
    }

    public var isProjectionComplete: Bool {
        !objectID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        depth.isComplete &&
        !authorityCeiling.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !recoveryPointer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Repeated motion is reserved for an explicitly time-critical central condition.
    public var hasLawfulMotionPosture: Bool {
        motion != .repeatedTimeCritical || topology == .central
    }
}
