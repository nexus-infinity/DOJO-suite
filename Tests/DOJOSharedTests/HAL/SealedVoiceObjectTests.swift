import XCTest
@testable import DOJOShared

/// MFC-01 offline seal proof — no mic, no AKRON, no ParticleBoard.
final class SealedVoiceObjectTests: XCTestCase {

    private var tempRoot: URL!

    override func setUp() {
        super.setUp()
        tempRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("mfc01-test-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: tempRoot, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempRoot)
        super.tearDown()
    }

    func testSealWritesDurableAudioAndHash() throws {
        let store = SealedVoiceObjectStore(root: tempRoot)
        // 0.1s of silence at 16kHz mono PCM16
        var pcm = Data(count: 16_000 * 2 / 10)
        // Non-trivial bytes so hash is unique
        for i in 0..<min(100, pcm.count) { pcm[i] = UInt8(i & 0xff) }

        let sealed = try store.seal(pcm16le: pcm, deviceSessionID: "test-device-session")

        XCTAssertFalse(sealed.voice_object_id.isEmpty)
        XCTAssertTrue(sealed.sealed_object_ref.hasPrefix("sealed://voice/"))
        XCTAssertEqual(sealed.hash_algorithm, "SHA-256")
        XCTAssertEqual(sealed.audio_hash.count, 64)
        XCTAssertEqual(sealed.lifecycle_state, .queued)
        XCTAssertEqual(sealed.authority_state, .localOnlyPendingAKRON)
        XCTAssertEqual(sealed.copy_policy, .originalNotCopied)
        XCTAssertEqual(sealed.export_policy, .explicitExportOnly)
        XCTAssertNil(sealed.akron_receipt_id)
        XCTAssertTrue(FileManager.default.fileExists(atPath: sealed.local_file_path))
        XCTAssertTrue(try store.verifyIntegrity(sealed))

        let loaded = try store.load(voiceObjectID: sealed.voice_object_id)
        XCTAssertEqual(loaded?.audio_hash, sealed.audio_hash)
        XCTAssertEqual(loaded?.lifecycle_state, .queued)
    }

    func testEmptyAudioFails() {
        let store = SealedVoiceObjectStore(root: tempRoot)
        XCTAssertThrowsError(try store.seal(pcm16le: Data(), deviceSessionID: "x")) { err in
            XCTAssertEqual(err as? SealedVoiceError, .emptyAudio)
        }
    }

    // MARK: - AKRON receipt boundary

    func testAssignAKRONReceiptConfirmsObject() throws {
        let store = SealedVoiceObjectStore(root: tempRoot)
        var pcm = Data(count: 3_200); pcm[0] = 0x42
        let sealed = try store.seal(pcm16le: pcm, deviceSessionID: "akron-test")

        XCTAssertEqual(sealed.lifecycle_state, .queued)
        XCTAssertNil(sealed.akron_receipt_id)

        let receiptID = "akron-receipt-\(UUID().uuidString)"
        let confirmed = try store.assignAKRONReceipt(voiceObjectID: sealed.voice_object_id, receiptID: receiptID)

        XCTAssertEqual(confirmed.lifecycle_state, .akronConfirmed)
        XCTAssertEqual(confirmed.akron_receipt_id, receiptID)
        // Evidence spine must be unchanged
        XCTAssertEqual(confirmed.audio_hash, sealed.audio_hash)
        XCTAssertEqual(confirmed.local_file_path, sealed.local_file_path)
        XCTAssertEqual(confirmed.byte_count, sealed.byte_count)
    }

    func testAssignAKRONReceiptPersistsToDisk() throws {
        let store = SealedVoiceObjectStore(root: tempRoot)
        var pcm = Data(count: 3_200); pcm[0] = 0x99
        let sealed = try store.seal(pcm16le: pcm, deviceSessionID: "persist-test")
        let receiptID = "akron-receipt-persist"

        _ = try store.assignAKRONReceipt(voiceObjectID: sealed.voice_object_id, receiptID: receiptID)

        let loaded = try store.load(voiceObjectID: sealed.voice_object_id)
        XCTAssertEqual(loaded?.lifecycle_state, .akronConfirmed)
        XCTAssertEqual(loaded?.akron_receipt_id, receiptID)
    }

    func testQueuedStateFailsClosedWithoutReceipt() throws {
        let store = SealedVoiceObjectStore(root: tempRoot)
        var pcm = Data(count: 3_200); pcm[0] = 0x11
        let sealed = try store.seal(pcm16le: pcm, deviceSessionID: "fail-closed-test")

        // QUEUED with no receipt must never read as AKRON_CONFIRMED
        XCTAssertEqual(sealed.lifecycle_state, .queued)
        XCTAssertNil(sealed.akron_receipt_id)
        XCTAssertNotEqual(sealed.lifecycle_state, .akronConfirmed)
    }

    func testEmptyReceiptIDFails() throws {
        let store = SealedVoiceObjectStore(root: tempRoot)
        var pcm = Data(count: 3_200); pcm[0] = 0x22
        let sealed = try store.seal(pcm16le: pcm, deviceSessionID: "empty-receipt-test")

        XCTAssertThrowsError(
            try store.assignAKRONReceipt(voiceObjectID: sealed.voice_object_id, receiptID: "")
        ) { err in
            XCTAssertEqual(err as? SealedVoiceError, .invalidReceiptID)
        }
    }

    func testMissingObjectFails() {
        let store = SealedVoiceObjectStore(root: tempRoot)
        XCTAssertThrowsError(
            try store.assignAKRONReceipt(voiceObjectID: UUID().uuidString, receiptID: "some-receipt")
        ) { err in
            XCTAssertEqual(err as? SealedVoiceError, .objectNotFound)
        }
    }

    func testReceiptAssignmentIsIdempotent() throws {
        let store = SealedVoiceObjectStore(root: tempRoot)
        var pcm = Data(count: 3_200); pcm[0] = 0x55
        let sealed = try store.seal(pcm16le: pcm, deviceSessionID: "idempotent-test")
        let receiptID = "receipt-idempotent"

        let first = try store.assignAKRONReceipt(voiceObjectID: sealed.voice_object_id, receiptID: receiptID)
        let second = try store.assignAKRONReceipt(voiceObjectID: sealed.voice_object_id, receiptID: receiptID)

        XCTAssertEqual(first.lifecycle_state, .akronConfirmed)
        XCTAssertEqual(first.akron_receipt_id, second.akron_receipt_id)
        XCTAssertEqual(first.audio_hash, second.audio_hash)
    }

    func testHashStableForSameBytes() throws {
        let store = SealedVoiceObjectStore(root: tempRoot)
        let pcm = Data([0x01, 0x02, 0x03, 0x04] + Array(repeating: 0, count: 3_196))
        let a = try store.seal(pcm16le: pcm, deviceSessionID: "d1")
        let b = try store.seal(pcm16le: pcm, deviceSessionID: "d1")
        XCTAssertEqual(a.audio_hash, b.audio_hash)
        XCTAssertNotEqual(a.voice_object_id, b.voice_object_id)
    }
}
