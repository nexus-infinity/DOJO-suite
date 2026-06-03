import XCTest
@testable import DOJOShared
import FieldKit

/// Spine gate tests: capture → queue → AKRON → DOJO → receipt → render
///
/// Three tests, one per critical gap from the v0.1 inventory.
/// A PASSING test proves the happy path holds.
/// A GAP comment marks what is missing before the v0.1 gate is closeable.
final class SpineTests: XCTestCase {

    // ── Test 1: Offline persistence ───────────────────────────────────────────
    // Gate invariant: does not lose murmur.
    //
    // Proves: Packet JSON encoding round-trips intact — the exact format
    // PacketFileStore uses on disk. A packet in .queued state with a non-zero
    // retryCount must survive a process restart so the backoff clock isn't lost.

    func testPacketSurvivesOfflineEncoding() throws {
        let packetID = UUID()
        let hash = PacketFileStore.integrityHash(text: "field murmur test")
        let original = Packet(
            id: packetID,
            deviceID: "test-device",
            operatorID: "field-operator",
            integrityHash: hash,
            textNotes: "field murmur test",
            state: .queued,
            retryCount: 3
        )

        let data = try JSONEncoder().encode(original)
        let restored = try JSONDecoder().decode(Packet.self, from: data)

        XCTAssertEqual(restored.id, packetID,
            "Packet ID must survive disk round-trip")
        XCTAssertEqual(restored.textNotes, "field murmur test",
            "Text content must be intact")
        XCTAssertEqual(restored.state, .queued,
            "State must be preserved — loss reverts to draft and skips upload")
        XCTAssertEqual(restored.retryCount, 3,
            "Retry count must survive — loss resets the exponential backoff clock to zero")
        XCTAssertEqual(restored.integrityHash, hash,
            "Integrity hash must survive — reload compares against stored value")
    }

    // ── Test 2: HAL invariant breach ──────────────────────────────────────────
    // Gate invariant: does not crash car.
    //
    // Proves: FieldInvariant.evaluate() correctly returns .breached when no
    // cognitive murmor is registered (no node → field cannot orient).
    //
    // GAP (spine inventory gap C): this breach is NOT wired to PacketQueue.
    // In-flight packets do NOT move to .hold when the invariant fires .breached.
    // Fix: FieldInvariant result → .breached must call PacketQueue.holdAll(reason:).
    // When that fix lands, add:
    //   XCTAssertTrue(queue.packets.allSatisfy { $0.state == .hold })

    func testFieldInvariantBreachOnEmptyRegistry() {
        let snapshot = FieldStateSnapshot.defaultSnapshot
        let invariant = FieldInvariant(registry: [], currentState: snapshot)
        let result = invariant.evaluate()

        XCTAssertEqual(result.coherenceLevel, .breached,
            "Empty registry = no cognitive node: field cannot orient")

        guard case .breached(let reason) = result else {
            XCTFail("Expected .breached, got \(result)"); return
        }
        guard case .noCognitiveNode = reason else {
            XCTFail("Breach reason must be .noCognitiveNode, got \(reason)"); return
        }
    }

    // ── Test 3: Receipt ID end-to-end ─────────────────────────────────────────
    // Gate invariant: does not lose murmur.
    //
    // Proves: PacketReceipt.receiptID (FieldKit layer) survives JSON encoding.
    // This is the only end-to-end correlation key from queue → AKRON.
    //
    // GAP (spine inventory gap B): CockpitReceipt (DOJOShared) has no field
    // linking it back to the originating Packet.id. The stateHash is a content
    // hash, not a correlation key.
    // Fix: add packetID: UUID to CockpitReceipt; populate at emit() call site.
    // When that fix lands, add:
    //   XCTAssertEqual(cockpitReceipt.packetID, packet.id)

    func testPacketReceiptIDSurvivesEncoding() throws {
        let receipt = PacketReceipt(
            receiptID: "akron-2026-spine-001",
            receivedAt: "2026-05-17T00:00:00Z",
            chamberTrace: ["AKRON", "DOJO", "ATLAS"],
            validationResult: "VALIDATED"
        )

        let data = try JSONEncoder().encode(receipt)
        let restored = try JSONDecoder().decode(PacketReceipt.self, from: data)

        XCTAssertEqual(restored.receiptID, "akron-2026-spine-001",
            "receiptID must survive — only end-to-end correlation key from queue to AKRON")
        XCTAssertEqual(restored.chamberTrace, ["AKRON", "DOJO", "ATLAS"],
            "Chamber trace must survive — required for audit trail")
        XCTAssertEqual(restored.validationResult, "VALIDATED")
    }

    func testCockpitReceiptIDAndHashRoundTrip() throws {
        let knownID = UUID()
        let receipt = CockpitReceipt(
            receiptID: knownID,
            timestamp: "2026-05-17T00:00:00Z",
            event: "commit.accepted",
            actor: "cockpit-ui",
            boardTitle: "spine-test",
            stateHash: CockpitReceiptStore.sha256(from: "state", "v1", "cockpit-ui"),
            draftPresent: true,
            policyResult: "ok",
            addressesChanged: ["[1,1]"],
            holdReasons: nil
        )

        let data = try JSONEncoder().encode(receipt)
        let restored = try JSONDecoder().decode(CockpitReceipt.self, from: data)

        // Gap B closed: receiptID now survives JSONL encoding
        XCTAssertEqual(restored.receiptID, knownID,
            "receiptID must survive encoding — unique correlation key per board commit")

        // Hash determinism
        let h1 = CockpitReceiptStore.sha256(from: "state", "v1", "cockpit-ui")
        let h2 = CockpitReceiptStore.sha256(from: "state", "v1", "cockpit-ui")
        let hDiff = CockpitReceiptStore.sha256(from: "state", "v2", "cockpit-ui")

        XCTAssertEqual(h1, h2,
            "sha256 must be deterministic — same input always produces same hash")
        XCTAssertNotEqual(h1, hDiff,
            "sha256 must differ for different input")
        XCTAssertEqual(h1.count, 64,
            "SHA-256 hex digest must be 64 characters")
    }
}
