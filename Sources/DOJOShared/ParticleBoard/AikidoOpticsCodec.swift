import Foundation

public struct BoardEdit {
    public let address: GridAddress
    public let payload: BoardPayload
    
    public init(address: GridAddress, payload: BoardPayload) {
        self.address = address
        self.payload = payload
    }
}

public struct PolicyPins {
    public let hasMailPrivacy: Bool
    public let hasCalendarPrivacy: Bool
    public let geometricIntegrityValid: Bool
    
    public init(hasMailPrivacy: Bool = true, hasCalendarPrivacy: Bool = true, geometricIntegrityValid: Bool = true) {
        self.hasMailPrivacy = hasMailPrivacy
        self.hasCalendarPrivacy = hasCalendarPrivacy
        self.geometricIntegrityValid = geometricIntegrityValid
    }
}

public enum PolicyEngine {
    public static func validate(_ state: ParticleBoardState) -> ValidationResult {
        var reasons: [HoldReason] = []
        
        if state.cells.count != 9 {
            if let addr = GridAddress(row: 0, col: 0) {
                reasons.append(HoldReason(address: addr, code: "MALFORMED_BOARD", detail: "Grid must contain exactly 9 cells."))
            }
        }
        
        if let policyGateAddress = GridAddress(row: 2, col: 2),
           let pCell = state.cell(at: policyGateAddress),
           pCell.payload == .empty {
            reasons.append(HoldReason(address: policyGateAddress, code: "POLICY_GATE_LOCKED", detail: "Cell [2,2] must be explicitly authorized to execute an Accept."))
        }
        
        return reasons.isEmpty ? .ok : .hold(reasons: reasons)
    }
    
    // Wire the Authority Check directly into the Policy Engine
    @MainActor
    public static func enforceAuthority() -> Bool {
        let level = AuthorityManager.shared.state.currentLevel
        if level == .level0_interfaces {
            print("◆ HOLD: Sovereign field execution blocked. Authority Level 0.")
            return false
        }
        return true
    }
}

public enum AikidoOpticsCodec {

    // MARK: - Composition Rules
    //
    // Row semantics (CellKind):
    //   0 = intent layer    — what the operator asserts is true
    //   1 = structure layer — how those assertions relate
    //   2 = policy layer    — what action is authorised ([2,2] is the execution gate)
    //
    // Column semantics (Phase):
    //   0 = draft     — in-progress, not yet validated
    //   1 = validate  — awaiting review
    //   2 = publish   — authorised for external action
    //
    // Claim class comes from BoardPayload.route(intent:), not position:
    //   "Observed"       → witnessed fact, no inference applied
    //   "Interpretation" → reasoning applied to observed facts
    //   "Recommendation" → proposed action derived from interpretation

    public static func encode(plan: DocumentPlan) -> ParticleBoardState {
        var cells: [BoardCell] = []
        for r in 0...2 {
            for c in 0...2 {
                if let addr = GridAddress(row: r, col: c) {
                    cells.append(BoardCell(address: addr, payload: .empty))
                }
            }
        }
        return ParticleBoardState(cells: cells)
    }

    public static func forecast(committed: ParticleBoardState, proposedEdit: BoardEdit, policy: PolicyPins) -> Forecast {
        var newCells = committed.cells
        if let idx = newCells.firstIndex(where: { $0.address == proposedEdit.address }) {
            newCells[idx] = BoardCell(address: proposedEdit.address, payload: proposedEdit.payload, channels: newCells[idx].channels)
        } else {
            newCells.append(BoardCell(address: proposedEdit.address, payload: proposedEdit.payload))
        }
        let proposedState = ParticleBoardState(cells: newCells)
        return Forecast(
            proposedState: proposedState,
            documentPreview: decodeToDocument(state: proposedState),
            imagePreview: decodeToImage(state: proposedState),
            diff: diff(committed: committed, proposed: proposedState),
            riskScore: 0.1
        )
    }

    /// Assembles board state into a structured O/I/R forensic document.
    /// Cells are grouped by claim class (intent field), ordered row-major within each group.
    /// Empty cells are excluded from the body; their count appears in metadata.
    public static func decodeToDocument(state: ParticleBoardState) -> DocumentDraft {
        var observed: [(row: Int, col: Int, text: String)] = []
        var interpretation: [(row: Int, col: Int, text: String)] = []
        var recommendation: [(row: Int, col: Int, text: String)] = []
        var metadata: [String: String] = [:]

        let sorted = state.cells.sorted { ($0.row * 3 + $0.col) < ($1.row * 3 + $1.col) }
        for cell in sorted {
            guard case .route(let intent, let action) = cell.payload else { continue }
            let entry = (row: cell.row, col: cell.col, text: action)
            switch intent.lowercased() {
            case "observed":       observed.append(entry)
            case "interpretation": interpretation.append(entry)
            case "recommendation": recommendation.append(entry)
            default:               metadata["[\(cell.row),\(cell.col)]"] = "\(intent): \(action)"
            }
        }

        var lines: [String] = []
        if !observed.isEmpty {
            lines.append("## ● Observed")
            for e in observed { lines.append("- `[\(e.row),\(e.col)]` \(e.text)") }
            lines.append("")
        }
        if !interpretation.isEmpty {
            lines.append("## ◈ Interpretation")
            for e in interpretation { lines.append("- `[\(e.row),\(e.col)]` \(e.text)") }
            lines.append("")
        }
        if !recommendation.isEmpty {
            lines.append("## ◉ Recommendation")
            for e in recommendation { lines.append("- `[\(e.row),\(e.col)]` \(e.text)") }
            lines.append("")
        }

        let emptyCount = state.cells.filter { $0.payload == .empty }.count
        if emptyCount > 0 { metadata["empty_cells"] = "\(emptyCount)" }

        return DocumentDraft(
            markdown: lines.isEmpty ? "— no content committed —" : lines.joined(separator: "\n"),
            metadata: metadata
        )
    }

    /// Builds a scene-graph of the grid for visual layout consumers.
    /// Keys: "cell_R_C". Metadata encodes the row/col semantic labels.
    public static func decodeToImage(state: ParticleBoardState) -> ImageDraft {
        var sceneGraph: [String: String] = [:]
        for cell in state.cells {
            let key = "cell_\(cell.row)_\(cell.col)"
            switch cell.payload {
            case .empty:                    sceneGraph[key] = "·"
            case .route(let intent, let a): sceneGraph[key] = "\(intent): \(a.prefix(60))"
            case .unknown(let raw):         sceneGraph[key] = "?: \(raw.prefix(60))"
            }
        }
        return ImageDraft(
            sceneGraph: sceneGraph,
            metadata: [
                "row_0": "intent",   "row_1": "structure", "row_2": "policy",
                "col_0": "draft",    "col_1": "validate",  "col_2": "publish"
            ]
        )
    }

    // MARK: - Private

    private static func diff(committed: ParticleBoardState, proposed: ParticleBoardState) -> String {
        let sort: (BoardCell, BoardCell) -> Bool = { ($0.row * 3 + $0.col) < ($1.row * 3 + $1.col) }
        let changes = zip(committed.cells.sorted(by: sort), proposed.cells.sorted(by: sort))
            .compactMap { old, new -> String? in
                guard old.payload != new.payload else { return nil }
                return "[\(new.row),\(new.col)] \(payloadLabel(old.payload)) → \(payloadLabel(new.payload))"
            }
        return changes.isEmpty ? "no change" : changes.joined(separator: "; ")
    }

    private static func payloadLabel(_ payload: BoardPayload) -> String {
        switch payload {
        case .empty:             return "·"
        case .route(let i, _):  return i
        case .unknown(let r):   return "?\(r.prefix(8))"
        }
    }
}
