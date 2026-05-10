import Foundation

/// The iPhone — Mobile cognitive node. The relay bridge.
/// Layer 2 when on its own; relay bridge between Watch and Mac over BLE.
public final class iPhoneMurmor: DOJOMurmor {

    public let identity: MurmorIdentity

    public var profile: HALProfile {
        HALProfile(
            sense:   .full,      // Mic, camera, LiDAR (supported models)
            process: .full,      // Neural Engine, full model inference
            store:   .moderate,  // Flash — hours of buffer
            relay:   .full,      // Wi-Fi, BLE, cellular, Thread
            act:     .full       // Screen, speakers, haptic
        )
    }

    public var localBuffer = EventBuffer(capacity: 5_000)
    public var lastKnownFieldState: FieldStateSnapshot = .defaultSnapshot

    public init(name: String = "iPhone") {
        self.identity = MurmorIdentity(
            name: name,
            deviceClass: .iPhone,
            profile: HALProfile(sense: .full, process: .full, store: .moderate, relay: .full, act: .full),
            state: .offline
        )
    }

    public func observeLocal() -> SenseEvent? {
        return nil
    }

    public func operateAutonomously() {
        // Bridge role when disconnected — continues relaying
        // between Watch and Mac over BLE on last known state
    }

    public func rejoinField(via relay: any DOJORelay) async throws -> SyncResult {
        let snapshot = localBuffer
        let result = try await relay.syncBuffer(snapshot)
        localBuffer = EventBuffer(capacity: 5_000)
        return result
    }
}
