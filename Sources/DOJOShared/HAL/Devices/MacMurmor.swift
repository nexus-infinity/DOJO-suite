import Foundation

/// The Mac — Full DOJO. The standing brain.
/// Layer 2 cognitive node — almost never autonomous, it IS the hub.
public final class MacMurmor: DOJOMurmor {

    public let identity: MurmorIdentity

    public var profile: HALProfile {
        HALProfile(
            sense:   .full,      // Mic, camera, screen OCR
            process: .full,      // Neural Engine, full model inference
            store:   .full,      // SSD, Core Data, relationship memory
            relay:   .full,      // Wi-Fi, BLE, Thread (if border router)
            act:     .full       // Screen, speakers, system commands
        )
    }

    public var localBuffer = EventBuffer(capacity: 10_000)
    public var lastKnownFieldState: FieldStateSnapshot = .defaultSnapshot

    // Fixed UUID — ensures registry[id] = mac is always an overwrite, never an accumulation.
    // Without this, each registerMacMurmor() call creates a fresh UUID and adds a second Mac entry.
    static let canonicalID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    public init(name: String = "Mac") {
        self.identity = MurmorIdentity(
            id: Self.canonicalID,
            name: name,
            deviceClass: .mac,
            profile: HALProfile(sense: .full, process: .full, store: .full, relay: .full, act: .full),
            state: .offline
        )
    }

    public func observeLocal() -> SenseEvent? {
        // VADMicBridge feeds voiceActivity events
        // Screen capture feeds screenContent events
        // Only publishes when something CHANGES — event-driven, not polled
        return nil
    }

    public func operateAutonomously() {
        // If Wi-Fi drops, continues O₁→O₂→O₃ using cached models
        // and local relationship memory. Never goes dark.
    }

    public func rejoinField(via relay: any DOJORelay) async throws -> SyncResult {
        let snapshot = localBuffer
        let result = try await relay.syncBuffer(snapshot)
        localBuffer = EventBuffer(capacity: 10_000)
        return result
    }
}
