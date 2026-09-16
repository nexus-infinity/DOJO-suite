import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

@main
struct RouteLedgerClaimProbe {
    static func main() async {
        guard CommandLine.arguments.count == 6,
              let scheduledEpoch = TimeInterval(CommandLine.arguments[3]),
              let consumedEpoch = TimeInterval(CommandLine.arguments[4]) else {
            exit(64)
        }

        let ledgerURL = URL(fileURLWithPath: CommandLine.arguments[1])
        let receiptID = CommandLine.arguments[2]
        let resultURL = URL(fileURLWithPath: CommandLine.arguments[5])

        let delay = scheduledEpoch - Date().timeIntervalSince1970
        if delay > 0 {
            try? await Task.sleep(
                nanoseconds: UInt64(delay * 1_000_000_000)
            )
        }

        let ledger = FileRouteAdmissionReplayLedger(fileURL: ledgerURL)
        let claimed = await ledger.claim(
            receiptID: receiptID,
            consumedAt: Date(timeIntervalSince1970: consumedEpoch)
        )
        let snapshot = await ledger.snapshot()
        let evidence: [String: Any] = [
            "pid": ProcessInfo.processInfo.processIdentifier,
            "receipt_id": receiptID,
            "claimed": claimed,
            "admission_result": claimed
                ? "receiptAdmittedSpecializedRoute"
                : "HOLD.ReplayRejected",
            "routing_disposition": claimed
                ? "receiptAdmittedSpecializedRoute"
                : "canonicalDOJOFallback",
            "ledger_entry_count": snapshot?.entries.count ?? -1,
            "observed_at": ISO8601DateFormatter().string(from: Date())
        ]

        do {
            let data = try JSONSerialization.data(
                withJSONObject: evidence,
                options: [.prettyPrinted, .sortedKeys]
            )
            try data.write(to: resultURL, options: .atomic)
            exit(claimed ? 0 : 2)
        } catch {
            exit(74)
        }
    }
}
