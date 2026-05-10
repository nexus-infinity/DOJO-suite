import Foundation

// MARK: - The Core Protocol

/// Any device that conforms to this protocol IS a murmor.
/// It can join the DOJO field, contribute to reliability,
/// and operate autonomously when disconnected.
public protocol DOJOMurmor: AnyObject {

    // ─── IDENTITY ────────────────────────────────────────

    /// Who am I?
    var identity: MurmorIdentity { get }

    /// What can I do? (The five HAL questions, answered)
    var profile: HALProfile { get }

    // ─── RULE 1: SENSE LOCALLY, REPORT GLOBALLY ─────────

    /// The local event buffer. Murmors collect SenseEvents
    /// internally and only publish to the field when something
    /// CHANGES. No polling. Event-driven only.
    var localBuffer: EventBuffer { get set }

    /// Called by the murmor's own sensor loop.
    /// Returns nil if nothing changed (no event published).
    /// Returns a SenseEvent if a threshold was crossed.
    func observeLocal() -> SenseEvent?

    // ─── RULE 2: ACT ON LAST KNOWN STATE ────────────────

    /// The last coherent field state this murmor received.
    /// If the network drops, the murmor continues operating
    /// from this snapshot. Never goes dark.
    var lastKnownFieldState: FieldStateSnapshot { get set }

    /// What does this murmor DO when it's on its own?
    /// This is the autonomous behavior — not idle, but
    /// operating on cached truth.
    func operateAutonomously()

    // ─── RULE 3: REJOIN WITHOUT CEREMONY ────────────────

    /// Called when connectivity is restored.
    /// Sends local buffer upstream, receives missed state updates.
    /// No manual pairing. No configuration. Just sync.
    func rejoinField(via relay: any DOJORelay) async throws -> SyncResult
}
