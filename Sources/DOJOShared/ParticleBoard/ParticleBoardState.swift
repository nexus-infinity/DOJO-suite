import Foundation

// MARK: - PBV-0  ParticleBoardState schema
//
// Grid semantics (fixed — locked per dev contract):
//
//            draft       validate    publish
//  intent  │ (0,0)    │  (0,1)   │  (0,2)  │  row 0 — what does this want to be
//  struct  │ (1,0)    │  (1,1)   │  (1,2)  │  row 1 — sections / shape
//  policy  │ (2,0)    │  (2,1)   │  (2,2)  │  row 2 — policyPins / allowed actions
//
// Cell meaning = (row, col) + cellKind + phase (redundant but defensive).
// Cell glyph  = derived from payload — never the decoder key.

// MARK: - Address Semantics

public enum CellKind: String, Codable, Sendable {
    case intent    = "intent"
    case structure = "structure"
    case policy    = "policy"

    public static func from(row: Int) -> CellKind {
        switch row {
        case 0:  return .intent
        case 1:  return .structure
        default: return .policy
        }
    }
}

public enum Phase: String, Codable, Sendable {
    case draft    = "draft"
    case validate = "validate"
    case publish  = "publish"

    public static func from(col: Int) -> Phase {
        switch col {
        case 0:  return .draft
        case 1:  return .validate
        default: return .publish
        }
    }
}

// MARK: - Payload (tagged union — type is decoder key, glyph is view only)

public enum CellPayload: Codable, Equatable, Sendable {
    case axis(CategoryAxis)
    case routingHome(PersistenceHome)
    case empty

    // Explicit Codable — avoids silent synthesis breakage across version bumps.
    private enum PayloadType: String, Codable { case axis, routingHome, empty }
    private enum CodingKeys: String, CodingKey { case type, value }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(PayloadType.self, forKey: .type) {
        case .axis:        self = .axis(try c.decode(CategoryAxis.self, forKey: .value))
        case .routingHome: self = .routingHome(try c.decode(PersistenceHome.self, forKey: .value))
        case .empty:       self = .empty
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .axis(let a):
            try c.encode(PayloadType.axis, forKey: .type)
            try c.encode(a, forKey: .value)
        case .routingHome(let h):
            try c.encode(PayloadType.routingHome, forKey: .type)
            try c.encode(h, forKey: .value)
        case .empty:
            try c.encode(PayloadType.empty, forKey: .type)
        }
    }

    /// Derived glyph — non-authoritative, purely for display.
    public var glyph: String {
        switch self {
        case .axis(let a):        return a.rawValue
        case .routingHome(let h): return h.boardSymbol
        case .empty:              return "·"
        }
    }
}

// MARK: - Persistence home glyph extension

extension PersistenceHome {
    /// Board-display glyph — distinct from chamber rawValue strings.
    public var boardSymbol: String {
        switch self {
        case .obiWan: return "●"
        case .tata:   return "▼"
        case .atlas:  return "▲"
        case .dojo:   return "◼︎"
        case .akron:  return "◻"
        }
    }
}

// MARK: - Non-canonical channels (visual only, never written to canonical store)

public struct CellChannels: Codable, Equatable, Sendable {
    public var color: String?
    public var motion: String?
    public var intensity: Double?

    public init(color: String? = nil, motion: String? = nil, intensity: Double? = nil) {
        self.color = color; self.motion = motion; self.intensity = intensity
    }
}

// MARK: - BoardCell

public struct BoardCell: Codable, Equatable, Identifiable, Sendable {
    public let row: Int         // 0=intent | 1=structure | 2=policy
    public let col: Int         // 0=draft  | 1=validate  | 2=publish
    public let cellKind: CellKind  // derived from row — stored for safety
    public let phase: Phase        // derived from col — stored for safety
    public let payload: CellPayload
    public let glyph: String       // derived from payload — never authoritative
    public var channels: CellChannels?

    public var id: String { "\(row)x\(col)" }

    public init(row: Int, col: Int, payload: CellPayload, channels: CellChannels? = nil) {
        self.row = row
        self.col = col
        self.cellKind = CellKind.from(row: row)
        self.phase = Phase.from(col: col)
        self.payload = payload
        self.glyph = payload.glyph
        self.channels = channels
    }
}

// MARK: - ParticleBoardState

public struct ParticleBoardState: Codable, Equatable, Sendable {
    public let boardID: UUID
    /// Always 9 cells (3×3), ordered row-major: (0,0)…(2,2).
    public let cells: [BoardCell]
    public let veneerEnabled: Bool
    public let createdAt: Date

    public init(boardID: UUID = UUID(), cells: [BoardCell], veneerEnabled: Bool, createdAt: Date = Date()) {
        self.boardID = boardID
        self.cells = cells
        self.veneerEnabled = veneerEnabled
        self.createdAt = createdAt
    }

    /// Addressed subscript — O(n) over 9 cells, acceptable for v0.
    public subscript(row: Int, col: Int) -> BoardCell? {
        cells.first { $0.row == row && $0.col == col }
    }

    /// True iff exactly 9 cells with unique (row, col) addresses.
    public var isValid: Bool {
        cells.count == 9 &&
        Set(cells.map(\.id)).count == 9
    }
}
