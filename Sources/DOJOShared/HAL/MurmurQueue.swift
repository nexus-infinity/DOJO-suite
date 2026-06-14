import Foundation

/// Offline-capable store-and-forward queue for murmur packets.
/// In-memory in v0 — drops oldest when full. Drains on every enqueue.
/// File-backed spill buffer is a v1 concern.
public actor MurmurQueue {

    private let transport: MurmurTransport
    private var pending: [QueuedMurmurPacket] = []
    private var isDraining = false
    private let capacity: Int

    public init(transport: MurmurTransport, capacity: Int = 500) {
        self.transport = transport
        self.capacity = capacity
    }

    public func enqueue(_ packet: QueuedMurmurPacket) {
        if pending.count >= capacity { pending.removeFirst() }
        pending.append(packet)
        Task { await drain() }
    }

    /// Manual flush — call before app backgrounds or on rejoin.
    public func flush() async {
        await drain()
    }

    public var pendingCount: Int { pending.count }

    // MARK: - Private

    private func drain() async {
        guard !isDraining, !pending.isEmpty else { return }
        isDraining = true
        defer { isDraining = false }

        var failed: [QueuedMurmurPacket] = []
        for packet in pending {
            do {
                switch packet {
                case .audioChunk(let p):   try await transport.ingestAudio(p)
                case .qualityFrame(let p): try await transport.submitQuality(p)
                case .heartbeat(let p):    try await transport.sendHeartbeat(p)
                }
            } catch {
                failed.append(packet)
            }
        }
        pending = failed
    }
}
