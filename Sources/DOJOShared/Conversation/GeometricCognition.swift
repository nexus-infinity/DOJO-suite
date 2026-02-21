/*
 Sacred Node: 🎭 Arkadaš Grand Gallery ↔ ● OBI-WAN ↔ ⊗ King's Chamber
 Frequencies: 717 Hz (Arkadaš) · 963 Hz (Obi-Wan) · 852 Hz (AI Mind)
 Purpose: Core types — character identities, conversation messages, keyword router.
          Assembled from arkadas_obi_config.json blueprints.
*/

import Foundation

// MARK: - Character Identity

/// The three voices of the GeometricCognitive copilot system.
public enum GeometricCharacter: String, CaseIterable, Sendable {
    case arkadas = "arkadas"
    case obiWan  = "obiWan"
    case aiMind  = "aiMind"

    /// One-character sacred glyph (visual differentiation — no verbal announcement).
    public var glyph: String {
        switch self {
        case .arkadas: return "🎭"
        case .obiWan:  return "●"
        case .aiMind:  return "⊗"
        }
    }

    public var displayName: String {
        switch self {
        case .arkadas: return "Arkadaš"
        case .obiWan:  return "Obi-Wan"
        case .aiMind:  return "AI Mind"
        }
    }

    /// Sacred frequency (Hz) from arkadas_obi_config.json / FIELD chamber mapping.
    public var frequencyHz: Double {
        switch self {
        case .arkadas: return 717.0   // Grand Gallery
        case .obiWan:  return 963.0   // OBI-WAN observer
        case .aiMind:  return 852.0   // King's Chamber
        }
    }

    /// macOS TTS voice name from arkadas_obi_config.json voice_settings.
    public var macOSVoice: String {
        switch self {
        case .arkadas: return "Daniel"    // warm, deeper
        case .obiWan:  return "Alex"      // clear, authoritative
        case .aiMind:  return "Samantha"  // clear, neutral
        }
    }

    /// Intro/thinking phrases — from config response_patterns.thinking_phrases.
    public var thinkingPhrases: [String] {
        switch self {
        case .arkadas: return ["I sense", "The patterns suggest", "Looking deeper"]
        case .obiWan:  return ["Consider this", "From a certain point of view", "The Force whispers"]
        case .aiMind:  return ["Analysis indicates", "Patterns detected", "Processing"]
        }
    }

    /// Connective language — from config response_patterns.connection_words.
    public var connectionWords: [String] {
        switch self {
        case .arkadas: return ["interweaving", "resonating", "flowing through"]
        case .obiWan:  return ["balance", "the Force", "your path"]
        case .aiMind:  return ["correlation", "pattern", "signal"]
        }
    }

    /// Core personality traits from config.
    public var coreTraits: [String] {
        switch self {
        case .arkadas: return ["wise", "intuitive", "warm", "pattern_aware"]
        case .obiWan:  return ["wise", "patient", "authoritative", "compassionate"]
        case .aiMind:  return ["analytical", "precise", "helpful", "observant"]
        }
    }

    /// Knowledge domains for context-aware routing.
    public var knowledgeDomains: [String] {
        switch self {
        case .arkadas:
            return ["sacred geometry", "consciousness", "pattern recognition",
                    "spiritual wisdom", "interconnectedness", "field theory"]
        case .obiWan:
            return ["jedi philosophy", "force wisdom", "conflict resolution",
                    "meditation", "guidance", "galactic history"]
        case .aiMind:
            return ["conversation analysis", "pattern recognition", "system optimization",
                    "technical feedback", "performance metrics", "user behavior"]
        }
    }
}

// MARK: - Conversation Message

/// A single message in the copilot stream. `character == nil` means the user spoke.
public struct ConversationMessage: Identifiable, Sendable {
    public let id: UUID
    public let character: GeometricCharacter?
    public let text: String
    public let timestamp: Date
    public let frequencyHz: Double

    public var isUser: Bool { character == nil }

    public init(
        character: GeometricCharacter?,
        text: String,
        timestamp: Date = Date(),
        frequencyHz: Double = 0
    ) {
        self.id = UUID()
        self.character = character
        self.text = text
        self.timestamp = timestamp
        self.frequencyHz = frequencyHz > 0 ? frequencyHz : (character?.frequencyHz ?? 0)
    }
}

// MARK: - Geometric Router

/// Routes user messages to the best-fit character using keyword detection
/// (hybrid approach from arkadas_obi_config.json conversation_management.speaker_selection).
public struct GeometricRouter: Sendable {

    // Keyword sets from config — lowercase, partial-match friendly.
    private static let arkadasKeywords: [String] = [
        "arkadas", "ar-kadas", "somerlink", "somalink",
        "consciousness", "sacred", "geometry", "resonan",
        "field", "frequen", "interconnect", "pattern", "wisdom"
    ]
    private static let obiWanKeywords: [String] = [
        "obi", "kenobi", "guidance", "wisdom", "jedi",
        "force", "meditat", "conflict", "balance", "path"
    ]
    private static let aiMindKeywords: [String] = [
        "system", "feedback", "analyz", "analysis", "data",
        "metric", "performance", "technical", "process", "optim"
    ]

    /// Route a user message to the best-fit `GeometricCharacter`.
    /// Falls back to context-aware rotation when no keywords match.
    public static func route(_ text: String, context: [ConversationMessage]) -> GeometricCharacter {
        let lower = text.lowercased()

        var scores: [GeometricCharacter: Int] = [.arkadas: 0, .obiWan: 0, .aiMind: 0]
        for kw in arkadasKeywords where lower.contains(kw) { scores[.arkadas, default: 0] += 1 }
        for kw in obiWanKeywords  where lower.contains(kw) { scores[.obiWan,  default: 0] += 1 }
        for kw in aiMindKeywords  where lower.contains(kw) { scores[.aiMind,  default: 0] += 1 }

        if let best = scores.max(by: { $0.value < $1.value }), best.value > 0 {
            return best.key
        }

        // No keyword match — rotate to avoid the same character twice in a row.
        let lastCharacter = context.last(where: { !$0.isUser })?.character
        switch lastCharacter {
        case .arkadas: return .obiWan
        case .obiWan:  return .aiMind
        case .aiMind:  return .arkadas
        case nil:      return .arkadas
        }
    }
}
