import Foundation

// MARK: - Aikido Optics Codec
//
// Bijective (within the v0 domain) encode/decode between DocumentPlan and ParticleBoardState.
//
// Fixed encoding map (invariants — never change without bumping the codec version):
//
//   (0,0) intent/draft    → primary axis: sections[0].axis ?? .witness
//   (0,1) intent/validate → routingHome(.atlas)   — ATLAS is always validation authority
//   (0,2) intent/publish  → routingHome(.dojo)    — DOJO is always manifestation authority
//   (1,0) struct/draft    → sections[0].axis or .empty
//   (1,1) struct/validate → sections[1].axis or .empty
//   (1,2) struct/publish  → sections[2].axis or .empty
//   (2,0) policy/draft    → policyPins[0] present? routingHome(.obiWan) : .empty
//   (2,1) policy/validate → policyPins[1] present? routingHome(.tata)   : .empty
//   (2,2) policy/publish  → policyPins[0] present? routingHome(.akron)  : .empty
//
// Shadow-casting contract: forecast() computes the diff without mutating canonical.
// Canonical write is ONLY permitted after the caller explicitly accepts the forecast.

public enum AikidoOpticsCodec {

    // MARK: - PBV-1  Encode

    public static func encode(_ plan: DocumentPlan, veneerEnabled: Bool = true) -> ParticleBoardState {
        let s = plan.sections
        let p = plan.policyPins
        let cells: [BoardCell] = [
            // Row 0 — intent
            BoardCell(row: 0, col: 0, payload: .axis(s.first?.axis ?? .witness)),
            BoardCell(row: 0, col: 1, payload: .routingHome(.atlas)),
            BoardCell(row: 0, col: 2, payload: .routingHome(.dojo)),
            // Row 1 — structure
            BoardCell(row: 1, col: 0, payload: s.count > 0 ? .axis(s[0].axis) : .empty),
            BoardCell(row: 1, col: 1, payload: s.count > 1 ? .axis(s[1].axis) : .empty),
            BoardCell(row: 1, col: 2, payload: s.count > 2 ? .axis(s[2].axis) : .empty),
            // Row 2 — policy
            BoardCell(row: 2, col: 0, payload: p.isEmpty       ? .empty : .routingHome(.obiWan)),
            BoardCell(row: 2, col: 1, payload: p.count > 1     ? .routingHome(.tata)   : .empty),
            BoardCell(row: 2, col: 2, payload: !p.isEmpty      ? .routingHome(.akron)  : .empty),
        ]
        return ParticleBoardState(cells: cells, veneerEnabled: veneerEnabled)
    }

    // MARK: - PBV-2  Decode → DocumentDraft

    public static func decodeToDocument(_ state: ParticleBoardState) -> Result<DocumentDraft, DecodeError> {
        guard state.isValid else {
            return .failure(.invalidBoard(reason: "Board must have exactly 9 unique cells"))
        }

        // Intent row — primary axis from (0,0), routing authorities from (0,1)/(0,2)
        let primaryAxis: CategoryAxis?
        if case .axis(let a) = state[0, 0]?.payload { primaryAxis = a } else { primaryAxis = nil }

        let validationHome: PersistenceHome
        if case .routingHome(let h) = state[0, 1]?.payload { validationHome = h } else { validationHome = .atlas }

        let publishHome: PersistenceHome
        if case .routingHome(let h) = state[0, 2]?.payload { publishHome = h } else { publishHome = .dojo }

        // Structure row — section axes from (1,0)…(1,2)
        let sectionAxes: [CategoryAxis] = (0..<3).compactMap { col -> CategoryAxis? in
            guard case .axis(let a) = state[1, col]?.payload else { return nil }
            return a
        }

        // Policy row — any non-empty cell means pins present
        let hasPolicyPins = (0..<3).contains { col in
            if case .empty = state[2, col]?.payload ?? .empty { return false }
            return true
        }

        let markdown = buildMarkdown(
            primaryAxis: primaryAxis,
            sectionAxes: sectionAxes,
            hasPolicyPins: hasPolicyPins,
            validationHome: validationHome,
            publishHome: publishHome
        )
        let metadata = DraftMetadata(
            sectionCount: sectionAxes.count,
            hasPolicyPins: hasPolicyPins,
            primaryAxis: primaryAxis,
            validationHome: validationHome,
            publishHome: publishHome
        )
        return .success(DocumentDraft(sourceID: state.boardID, markdown: markdown, metadata: metadata))
    }

    // MARK: - Image draft (v0 — scene graph, no synthesis)

    public static func decodeToImage(_ state: ParticleBoardState) -> Result<ImageDraft, DecodeError> {
        guard state.isValid else {
            return .failure(.invalidBoard(reason: "Board must have exactly 9 unique cells"))
        }
        let cellW: Double = 100, cellH: Double = 80
        var primitives: [ImageDraft.Primitive] = []
        for cell in state.cells.sorted(by: { $0.row == $1.row ? $0.col < $1.col : $0.row < $1.row }) {
            let x = Double(cell.col) * cellW
            let y = Double(cell.row) * cellH
            primitives.append(.rect(x: x, y: y, width: cellW - 4, height: cellH - 4, label: cell.cellKind.rawValue))
            primitives.append(.text(x: x + cellW / 2, y: y + cellH / 2, content: cell.glyph))
        }
        return .success(ImageDraft(sourceID: state.boardID, primitives: primitives))
    }

    // MARK: - Validate

    public enum ValidationResult: Equatable {
        case pass
        case hold(reasons: [String])
    }

    /// Policy gate: enforces ATLAS/DOJO invariants and board structure.
    /// Returns .hold with all violation reasons (fail-open list, fail-closed action).
    public static func validate(_ state: ParticleBoardState) -> ValidationResult {
        var reasons: [String] = []

        if !state.isValid {
            reasons.append("Board must have exactly 9 unique (row, col) cells")
        }

        // Intent row routing invariants — these are non-negotiable in v0
        if let cell01 = state[0, 1] {
            if case .routingHome(let h) = cell01.payload, h != .atlas {
                reasons.append("Cell (0,1) must route to ATLAS — validation authority invariant violated (got \(h.rawValue))")
            }
        }
        if let cell02 = state[0, 2] {
            if case .routingHome(let h) = cell02.payload, h != .dojo {
                reasons.append("Cell (0,2) must route to DOJO — publication authority invariant violated (got \(h.rawValue))")
            }
        }

        return reasons.isEmpty ? .pass : .hold(reasons: reasons)
    }

    // MARK: - Shadow-casting Forecast

    public struct CellDiff: Sendable {
        public let address: String          // e.g. "1x2"
        public let before: CellPayload
        public let after: CellPayload
    }

    public struct Forecast: Sendable {
        public let proposed: ParticleBoardState
        public let diffs: [CellDiff]
        public let validation: ValidationResult
        public let draftPreview: DocumentDraft?
        public let risk: Risk

        public enum Risk: Sendable { case none, low, high, blocked }
    }

    /// Compute a diff + preview between current and proposed board.
    /// Does NOT mutate canonical — caller must explicitly accept before any write.
    /// If incomplete or invalid, returns .blocked with reasons in validation.
    public static func forecast(current: ParticleBoardState?, proposed: ParticleBoardState) -> Forecast {
        let diffs: [CellDiff]
        if let current {
            diffs = (0..<3).flatMap { row in
                (0..<3).compactMap { col -> CellDiff? in
                    let before = current[row, col]?.payload ?? .empty
                    let after  = proposed[row, col]?.payload ?? .empty
                    guard before != after else { return nil }
                    return CellDiff(address: "\(row)x\(col)", before: before, after: after)
                }
            }
        } else {
            diffs = []
        }

        let validation = validate(proposed)
        let draft = try? decodeToDocument(proposed).get()

        let risk: Forecast.Risk
        switch validation {
        case .hold:  risk = .blocked
        case .pass:  risk = diffs.isEmpty ? .none : (diffs.count <= 2 ? .low : .high)
        }

        return Forecast(proposed: proposed, diffs: diffs, validation: validation, draftPreview: draft, risk: risk)
    }

    // MARK: - Errors

    public enum DecodeError: Error, Equatable {
        case invalidBoard(reason: String)
        case incompletePayload(cell: String)
        case policyViolation(reason: String)
    }

    // MARK: - Markdown builder (deterministic — same inputs always produce same output)

    private static func buildMarkdown(
        primaryAxis: CategoryAxis?,
        sectionAxes: [CategoryAxis],
        hasPolicyPins: Bool,
        validationHome: PersistenceHome,
        publishHome: PersistenceHome
    ) -> String {
        var lines: [String] = []

        lines.append(primaryAxis.map { "# [\($0.displayName)]" } ?? "# [Document]")
        lines.append("")

        if sectionAxes.isEmpty {
            lines.append("## [Section]")
            lines.append("{placeholder}")
            lines.append("")
        } else {
            for axis in sectionAxes {
                lines.append("## \(axis.displayName)")
                lines.append("{placeholder}")
                lines.append("")
            }
        }

        if hasPolicyPins {
            lines.append("---")
            lines.append("**Policy:** {allowed-actions}")
            lines.append("")
        }

        lines.append("---")
        lines.append("*Validates via:* \(validationHome.rawValue)  |  *Publishes via:* \(publishHome.rawValue)")

        return lines.joined(separator: "\n")
    }
}
