import Foundation

/// The complete governed spinning-top spine.
///
/// This is a coverage contract, not proof that every stage is currently live.
/// Each stage remains distinct even when the same chamber appears at more than
/// one point in the cycle.
public enum FieldSpinStage: String, CaseIterable, Codable, Hashable, Sendable {
    case s0 = "S0"
    case s1 = "S1"
    case s2 = "S2"
    case s3 = "S3"
    case s4 = "S4"
    case s5 = "S5"
    case s6 = "S6"
    case s7 = "S7"
    case s8 = "S8"
    case s9 = "S9"
    case s10 = "S10"
    case s11 = "S11"

    public var owner: String {
        switch self {
        case .s0, .s1, .s2: return "◻ AKRON"
        case .s3, .s4: return "● OBI-WAN + ▼ TATA + ▲ ATLAS (Trident)"
        case .s5: return "◉ Arkadaş"
        case .s6: return "Queen's gate"
        case .s7: return "◼︎ DOJO"
        case .s8: return "▼ TATA Chronicle"
        case .s9: return "◉ Arkadaş wisdom"
        case .s10: return "FIELD mirrors"
        case .s11: return "◻ AKRON wisdom seed"
        }
    }

    public var requiredReturn: String {
        switch self {
        case .s0: return "source identity and intake boundary"
        case .s1: return "preserved object state"
        case .s2: return "witnessed handoff"
        case .s3: return "separated evidence lanes"
        case .s4: return "truth-state agreement or HOLD"
        case .s5: return "continuity and drift state"
        case .s6: return "admission decision"
        case .s7: return "bounded output with authority ceiling"
        case .s8: return "append-only receipt"
        case .s9: return "declared-versus-actual comparison"
        case .s10: return "source and mirror distinction"
        case .s11: return "new-ground receipt for the next cycle"
        }
    }
}

public struct FieldS0S11CoverageContract: Codable, Equatable, Sendable {
    public let stages: [FieldSpinStage]

    public init(stages: [FieldSpinStage] = FieldSpinStage.allCases) {
        self.stages = stages
    }

    public static let v0 = FieldS0S11CoverageContract()

    public var hasAllStagesInOrder: Bool {
        stages == FieldSpinStage.allCases
    }

    public var hasNoCollapsedStages: Bool {
        Set(stages).count == FieldSpinStage.allCases.count && stages.count == FieldSpinStage.allCases.count
    }
}
