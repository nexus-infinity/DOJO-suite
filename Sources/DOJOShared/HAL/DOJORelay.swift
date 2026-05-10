import Foundation

// MARK: - Relay Protocol

/// Any transport layer (BLE, Thread, Wi-Fi, local IPC) conforms to this.
/// The murmor doesn't care HOW it connects — only that it CAN.
public protocol DOJORelay {
    /// Discover nearby murmors.
    func discoverPeers() async -> [MurmorIdentity]

    /// Publish a SenseEvent to the field.
    func publish(_ event: SenseEvent) async throws

    /// Subscribe to field state updates.
    func subscribeToFieldState() -> AsyncStream<FieldStateSnapshot>

    /// Receive an ActCommand from a cognitive node.
    func subscribeToCommands() -> AsyncStream<ActCommand>

    /// Sync local buffer with the field (Rule 3: rejoin).
    func syncBuffer(_ buffer: EventBuffer) async throws -> SyncResult
}

// MARK: - Sync Result

public struct SyncResult: Codable {
    public let eventsUploaded: Int
    public let stateUpdatesReceived: Int
    public let newFieldState: FieldStateSnapshot
    public let syncTimestamp: Date

    public init(
        eventsUploaded: Int,
        stateUpdatesReceived: Int,
        newFieldState: FieldStateSnapshot,
        syncTimestamp: Date = Date()
    ) {
        self.eventsUploaded = eventsUploaded
        self.stateUpdatesReceived = stateUpdatesReceived
        self.newFieldState = newFieldState
        self.syncTimestamp = syncTimestamp
    }
}

// MARK: - Event Buffer

/// The local rolling buffer (Rule 1: sense locally).
/// Bounded — never grows unbounded. Oldest events are evicted.
public struct EventBuffer: Codable {
    public let maxCapacity: Int
    public private(set) var events: [SenseEvent]

    public init(capacity: Int = 1000, events: [SenseEvent] = []) {
        self.maxCapacity = capacity
        self.events = events
    }

    public mutating func append(_ event: SenseEvent) {
        if events.count >= maxCapacity {
            events.removeFirst()  // Evict oldest — bounded entropy
        }
        events.append(event)
    }

    /// Returns all events and clears the buffer.
    public mutating func drain() -> [SenseEvent] {
        let drained = events
        events = []
        return drained
    }
}
