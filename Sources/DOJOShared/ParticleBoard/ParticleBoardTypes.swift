import Foundation

// MARK: - 1. Grid Address (Failable / Throwing)

public struct GridAddress: Hashable, Codable, Sendable {
    public let row: Int
    public let col: Int

    public enum ValidationError: Error {
        case outOfBounds(row: Int, col: Int)
    }

    /// Failable — use when decoding external data (registry, snapshots)
    public init?(row: Int, col: Int) {
        guard (0...2).contains(row), (0...2).contains(col) else { return nil }
        self.row = row
        self.col = col
    }

    /// Throwing — use when you want to convert into HoldReason downstream
    public static func validated(row: Int, col: Int) throws -> GridAddress {
        guard (0...2).contains(row), (0...2).contains(col) else {
            throw ValidationError.outOfBounds(row: row, col: col)
        }
        return GridAddress(row: row, col: col)!
    }
}

// MARK: - 2. ParticleBoardState (Deterministic Array)

public enum BoardPayload: Codable, Equatable, Sendable {
    case empty
    case route(intent: String, action: String)
    case unknown(raw: String)
}

public struct ChannelState: Codable, Equatable, Sendable {
    public var color: String?
    public var motion: String?
    public var intensity: Double?

    public init(color: String? = nil, motion: String? = nil, intensity: Double? = nil) {
        self.color = color; self.motion = motion; self.intensity = intensity
    }
}

public struct BoardCell: Codable, Equatable, Sendable {
    public let address: GridAddress
    public let payload: BoardPayload
    public var channels: ChannelState?

    public init(address: GridAddress, payload: BoardPayload, channels: ChannelState? = nil) {
        self.address = address
        self.payload = payload
        self.channels = channels
    }
}

// MARK: - Deterministic Particle Grammar v0

/// Particles are the deterministic visual codec for ParticleBoard state.
/// Keep this grammar within human visual differentiation: shape + fill + state colour.
public enum ParticleShape: String, Codable, Equatable, Sendable, CaseIterable {
    case circle
    case triangle
    case square
    case diamond
}

/// Outline means potential, ambient, or not crystallised.
/// Solid means active, crystallised, or selected.
public enum ParticleFillState: String, Codable, Equatable, Sendable, CaseIterable {
    case outline
    case solid
}

/// Colour is a state signal, not decoration.
/// Do not encode meaning below clear human perceptual clarity.
public enum ParticleStateColor: String, Codable, Equatable, Sendable, CaseIterable {
    case ambient
    case active
    case hold
    case selected

    public var hex: String {
        switch self {
        case .ambient:  return "#6B7280"
        case .active:   return "#7C3AED"
        case .hold:     return "#F43F5E"
        case .selected: return "#22C55E"
        }
    }
}

/// Stable render token for future ParticleBoard UI.
/// Position is the board address; phase and motion reuse existing board channels.
public struct ParticleVisualToken: Codable, Equatable, Sendable, Identifiable {
    public var id: String { "\(position.row)x\(position.col)" }

    public let shape: ParticleShape
    public let fill: ParticleFillState
    public let color: ParticleStateColor
    public let position: GridAddress
    public let phase: Phase
    public let motion: String?

    public init(
        shape: ParticleShape,
        fill: ParticleFillState,
        color: ParticleStateColor,
        position: GridAddress,
        phase: Phase,
        motion: String? = nil
    ) {
        self.shape = shape
        self.fill = fill
        self.color = color
        self.position = position
        self.phase = phase
        self.motion = motion
    }
}

/// Tiny v0 adapter for a board-cell preview of the sourced particle grammar.
/// Star is intentionally absent until a source path exists.
public struct ParticleGrammarV0: Codable, Equatable, Sendable, Identifiable {
    public var id: String { "\(shape.rawValue)-\(fill.rawValue)" }

    public let shape: ParticleShape
    public let fill: ParticleFillState
    public let color: GeometricColor
    public let label: String

    public init(shape: ParticleShape, fill: ParticleFillState, color: GeometricColor, label: String) {
        self.shape = shape
        self.fill = fill
        self.color = color
        self.label = label
    }

    public static let previewTokens: [ParticleGrammarV0] = [
        ParticleGrammarV0(shape: .circle, fill: .outline, color: .violet, label: "circle · 963 Hz"),
        ParticleGrammarV0(shape: .circle, fill: .solid, color: .violet, label: "circle · solid"),
        ParticleGrammarV0(shape: .triangle, fill: .outline, color: .green, label: "triangle · 528 Hz"),
        ParticleGrammarV0(shape: .triangle, fill: .solid, color: .green, label: "triangle · solid"),
        ParticleGrammarV0(shape: .square, fill: .outline, color: .blue, label: "square · 741 Hz"),
        ParticleGrammarV0(shape: .square, fill: .solid, color: .blue, label: "square · solid"),
        ParticleGrammarV0(shape: .diamond, fill: .outline, color: .red, label: "diamond · 396 Hz"),
        ParticleGrammarV0(shape: .diamond, fill: .solid, color: .red, label: "diamond · solid")
    ]
}

public struct ParticleBoardState: Codable, Equatable, Sendable {
    public let cells: [BoardCell]

    public init(cells: [BoardCell]) {
        self.cells = cells
    }

    public func cell(at address: GridAddress) -> BoardCell? {
        cells.first { $0.address == address }
    }
}


// MARK: - 3. Forecast + ValidationResult + HoldReason (All Codable)

public struct HoldReason: Codable, Equatable, Sendable {
    public let address: GridAddress
    public let code: String
    public let detail: String

    public init(address: GridAddress, code: String, detail: String) {
        self.address = address
        self.code = code
        self.detail = detail
    }
}

public enum ValidationResult: Codable, Equatable, Sendable {
    case ok
    case hold(reasons: [HoldReason])
}

public struct DocumentDraft: Codable, Equatable, Sendable {
    public let markdown: String
    public let metadata: [String: String]

    public init(markdown: String, metadata: [String: String] = [:]) {
        self.markdown = markdown
        self.metadata = metadata
    }
}

public struct ImageDraft: Codable, Equatable, Sendable {
    public let sceneGraph: [String: String]
    public let metadata: [String: String]

    public init(sceneGraph: [String: String] = [:], metadata: [String: String] = [:]) {
        self.sceneGraph = sceneGraph
        self.metadata = metadata
    }
}

public struct Forecast: Codable, Equatable, Sendable {
    public let proposedState: ParticleBoardState
    public let documentPreview: DocumentDraft?
    public let imagePreview: ImageDraft?
    public let diff: String
    public let riskScore: Double

    public init(proposedState: ParticleBoardState, documentPreview: DocumentDraft? = nil, imagePreview: ImageDraft? = nil, diff: String = "", riskScore: Double = 0.0) {
        self.proposedState = proposedState
        self.documentPreview = documentPreview
        self.imagePreview = imagePreview
        self.diff = diff
        self.riskScore = riskScore
    }
}

// MARK: - Legacy Bridging Extensions

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

extension BoardCell {
    public var row: Int { address.row }
    public var col: Int { address.col }
    public var id: String { "\(address.row)x\(address.col)" }
    public var glyph: String {
        switch payload {
        case .empty: return "·"
        case .route: return "⬡"
        case .unknown: return "?"
        }
    }

    public func particleVisualToken(isSelected: Bool = false, hasHold: Bool = false) -> ParticleVisualToken {
        let baseShape: ParticleShape
        let baseFill: ParticleFillState
        let baseColor: ParticleStateColor

        switch payload {
        case .empty:
            baseShape = .circle
            baseFill = .outline
            baseColor = .ambient
        case .route:
            baseShape = .triangle
            baseFill = .solid
            baseColor = .active
        case .unknown:
            baseShape = .square
            baseFill = .outline
            baseColor = .hold
        }

        return ParticleVisualToken(
            shape: baseShape,
            fill: isSelected ? .solid : baseFill,
            color: hasHold ? .hold : (isSelected ? .selected : baseColor),
            position: address,
            phase: Phase.from(col: col),
            motion: channels?.motion
        )
    }
}
