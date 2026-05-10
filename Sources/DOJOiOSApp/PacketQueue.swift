import Foundation
import FieldKit

@MainActor
final class PacketQueue: ObservableObject {
    @Published private(set) var packets: [Packet] = []

    private let store: any PacketRepository
    private let client: AKRONClient
    private var uploadTask: Task<Void, Never>?

    init(store: any PacketRepository = PacketFileStore(),
         client: AKRONClient = AKRONClient()) {
        self.store = store
        self.client = client
    }

    func load() async {
        packets = (try? await store.loadAll()) ?? []
        drainQueue()
    }

    func enqueue(textNotes: String, mediaRefs: [String] = [], voiceRef: String? = nil) async {
        let previousHash = packets.first?.integrityHash
        let hash = PacketFileStore.integrityHash(text: textNotes, mediaRefs: mediaRefs)
        var packet = Packet(
            deviceID: deviceID(),
            operatorID: "field-operator",
            integrityHash: hash,
            previousPacketHash: previousHash,
            textNotes: textNotes,
            mediaRefs: mediaRefs,
            voiceRef: voiceRef,
            state: .queued
        )
        try? await store.save(packet)
        packets.insert(packet, at: 0)
        drainQueue()
    }

    func drainQueue() {
        uploadTask?.cancel()
        uploadTask = Task { [weak self] in
            guard let self else { return }
            for i in packets.indices where packets[i].state.isUploadable {
                await upload(packetID: packets[i].id)
            }
        }
    }

    private func upload(packetID: UUID) async {
        guard let idx = packets.firstIndex(where: { $0.id == packetID }) else { return }
        guard !Task.isCancelled else { return }

        packets[idx].state = .uploading
        try? await store.save(packets[idx])

        do {
            let receipt = try await client.upload(packets[idx])
            let newState: PacketState = receipt.validationResult == "VALIDATED" ? .validated
                        : receipt.validationResult == "HOLD"      ? .hold
                        : .acknowledged
            packets[idx].state = newState
            packets[idx].receipt = receipt
        } catch {
            let retries = packets[idx].retryCount
            if retries < 5 {
                packets[idx].state = .retrying
                packets[idx].retryCount += 1
                try? await store.save(packets[idx])
                let delay = UInt64(min(pow(2.0, Double(retries)), 60)) * 1_000_000_000
                try? await Task.sleep(nanoseconds: delay)
                await upload(packetID: packetID)
                return
            } else {
                packets[idx].state = .failed
            }
        }
        try? await store.save(packets[idx])
    }

    // Stable per-device ID stored in UserDefaults — no UIKit dependency.
    private func deviceID() -> String {
        let key = "field.device.id"
        if let stored = UserDefaults.standard.string(forKey: key) { return stored }
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: key)
        return newID
    }
}
