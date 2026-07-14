import Foundation
#if canImport(FieldKit)
import FieldKit
#endif
#if canImport(DOJOShared)
import DOJOShared
#endif

@MainActor
final class PacketQueue: ObservableObject {
    @Published private(set) var packets: [Packet] = []

    private static let proofPacketID = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!
    private static let proofText = "Portal Integrity Loop proof packet"
    private static let proofMediaRefs = ["local-seal:portal-integrity-loop-proof"]

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
        await ensureProofPacket()
        drainQueue()
    }

    func enqueue(textNotes: String, mediaRefs: [String] = [], voiceRef: String? = nil) async {
        let previousHash = packets.first?.integrityHash
        let hash = PacketFileStore.integrityHash(text: textNotes, mediaRefs: mediaRefs)
        let packet = Packet(
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

    /// MFC-01: enqueue from sealed voice object. Evidence = media path + audio hash; voiceRef is UI pointer only.
    /// Does not set AKRON_CONFIRMED; akron_receipt_id on sealed object must remain null until real receipt.
    func enqueueSealedVoice(_ sealed: SealedVoiceObject) async {
        let summary = """
        MFC-01 sealed voice object
        voice_object_id=\(sealed.voice_object_id)
        sealed_object_ref=\(sealed.sealed_object_ref)
        audio_hash=\(sealed.audio_hash)
        hash_algorithm=\(sealed.hash_algorithm)
        lifecycle_state=\(sealed.lifecycle_state.rawValue)
        authority_state=\(sealed.authority_state.rawValue)
        copy_policy=\(sealed.copy_policy.rawValue)
        export_policy=\(sealed.export_policy.rawValue)
        akron_receipt_id=\(sealed.akron_receipt_id ?? "null")
        duration=\(sealed.duration)
        """
        await enqueue(
            textNotes: summary,
            mediaRefs: [sealed.local_file_path, "sha256:\(sealed.audio_hash)"],
            voiceRef: sealed.sealed_object_ref
        )
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

    func resetFailed() {
        for i in packets.indices where packets[i].state == .failed {
            packets[i].state = .queued
            packets[i].retryCount = 0
        }
        Task { [weak self] in
            guard let self else { return }
            for packet in packets where packet.state == .queued {
                try? await store.save(packet)
            }
        }
        drainQueue()
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

    private func ensureProofPacket() async {
        guard !packets.contains(where: { $0.id == Self.proofPacketID }) else { return }

        let hash = PacketFileStore.integrityHash(
            text: Self.proofText,
            mediaRefs: Self.proofMediaRefs
        )
        let packet = Packet(
            id: Self.proofPacketID,
            deviceID: deviceID(),
            operatorID: "portal-integrity-loop",
            integrityHash: hash,
            previousPacketHash: packets.first?.integrityHash,
            textNotes: Self.proofText,
            mediaRefs: Self.proofMediaRefs,
            state: .queued
        )

        do {
            try await store.save(packet)
            packets.insert(packet, at: 0)
        } catch {
            packets.insert(packet, at: 0)
        }
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
