import Observation
import Foundation
import DOJOShared

@Observable
@MainActor
public final class ParticleBoardController {
    public private(set) var committedState: ParticleBoardState?
    public private(set) var pendingForecast: Forecast?
    public private(set) var committedDraft: DocumentDraft?
    public private(set) var committedImageDraft: ImageDraft?

    public var onCommit: ((ParticleBoardState, DocumentDraft?) -> Void)?

    private var receiptStore: CockpitReceiptStore?
    private var boardTitle: String = ""

    public init(plan: DocumentPlan? = nil, receiptStore: CockpitReceiptStore? = nil) {
        self.receiptStore = receiptStore
        if let plan { load(plan) }
    }

    public func load(_ plan: DocumentPlan) {
        boardTitle = plan.title
        let state = AikidoOpticsCodec.encode(plan: plan)
        committedState = state
        committedDraft = AikidoOpticsCodec.decodeToDocument(state: state)
        committedImageDraft = AikidoOpticsCodec.decodeToImage(state: state)
        pendingForecast = nil
    }

    public func proposeEdit(row: Int, col: Int, payload: BoardPayload) {
        guard let current = committedState, let address = GridAddress(row: row, col: col) else { return }
        let edit = BoardEdit(address: address, payload: payload)
        pendingForecast = AikidoOpticsCodec.forecast(committed: current, proposedEdit: edit, policy: PolicyPins())
    }

    public func acceptForecast() throws {
        guard let pending = pendingForecast else {
            throw ParticleBoardError.noPendingForecast
        }

        let result = PolicyEngine.validate(pending.proposedState)

        switch result {
        case .ok:
            let prior = committedState?.cells ?? []
            let changed: [String] = zip(prior, pending.proposedState.cells)
                .compactMap { a, b in a.payload != b.payload ? "[\(b.row),\(b.col)]" : nil }
            let hash = stateHash(for: pending.proposedState)

            committedState = pending.proposedState
            committedDraft = AikidoOpticsCodec.decodeToDocument(state: pending.proposedState)
            committedImageDraft = AikidoOpticsCodec.decodeToImage(state: pending.proposedState)
            pendingForecast = nil

            onCommit?(committedState!, committedDraft)

            receiptStore?.emit(CockpitReceipt(
                timestamp: iso8601Now(),
                event: "commit.accepted",
                actor: "cockpit-ui",
                boardTitle: boardTitle,
                stateHash: hash,
                draftPresent: committedDraft != nil,
                policyResult: "ok",
                addressesChanged: changed,
                holdReasons: nil
            ))

        case .hold(let reasons):
            receiptStore?.emit(CockpitReceipt(
                timestamp: iso8601Now(),
                event: "commit.blocked",
                actor: "cockpit-ui",
                boardTitle: boardTitle,
                stateHash: "",
                draftPresent: false,
                policyResult: "hold",
                addressesChanged: [],
                holdReasons: reasons.map {
                    HoldReasonReceipt(
                        address: "[\($0.address.row),\($0.address.col)]",
                        code: $0.code,
                        detail: $0.detail
                    )
                }
            ))
            throw ParticleBoardError.acceptBlockedByPolicy(reasons: reasons)
        }
    }

    public func rejectForecast() {
        pendingForecast = nil
    }

    public func updateChannels(row: Int, col: Int, channels: ChannelState?) {
        guard let current = committedState, let address = GridAddress(row: row, col: col) else { return }
        var cells = current.cells
        if let idx = cells.firstIndex(where: { $0.address == address }) {
            cells[idx].channels = channels
        }
        committedState = ParticleBoardState(cells: cells)
    }

    // MARK: - Helpers

    private func stateHash(for state: ParticleBoardState) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = (try? encoder.encode(state)) ?? Data()
        return CockpitReceiptStore.sha256(from: String(data: data, encoding: .utf8) ?? "")
    }

    private func iso8601Now() -> String {
        ISO8601DateFormatter().string(from: Date())
    }
}

public enum ParticleBoardError: Error {
    case acceptBlockedByPolicy(reasons: [HoldReason])
    case noPendingForecast
    case securityBypassAttempt
}

extension ParticleBoardController {
    public var committed: ParticleBoardState? { committedState }
}
