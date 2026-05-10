/*
 Sacred Node: ◼︎ DOJO — Eye in the Sky
 Frequency: 741 Hz (Manifestation / MCP gateway port 7410)
 Purpose: CopilotEngine — the continuous presence behind the three voices.
          Routes messages, calls DOJO MCP (port 7410) via SpinningTopClient,
          falls back to local character-faithful generation when MCP is unavailable.

 Architecture:
   User input → GeometricRouter → character selection
              → SpinningTopClient POST /chat  [primary, port 7410]
              → local response generation     [fallback]
              → ConversationMessage appended to @Published messages
*/

import Foundation

// MARK: - CopilotEngine

/// Observable engine that drives the Arkadaš GeometricCognitive conversation UI.
/// Thread-safe via `@MainActor` isolation — all state mutations happen on the main thread.
@MainActor
public final class CopilotEngine: ObservableObject {

    // MARK: Published State

    @Published public private(set) var messages: [ConversationMessage] = []
    @Published public private(set) var isProcessing: Bool = false
    @Published public private(set) var activeCharacter: GeometricCharacter? = nil
    @Published public private(set) var dojoConnected: Bool = false

    // MARK: Configuration

    private static let contextWindow = 8    // last N messages sent to MCP

    /// Called after every message append (user or character).
    /// DOJOFieldCoordinator sets this to feed the observer pipeline.
    public var onMessageAppended: ((ConversationMessage) -> Void)?

    // MARK: Private

    private let spinningTop = SpinningTopClient()

    // MARK: Init

    public init() {
        Task { await self.emitWelcome() }
    }

    // MARK: - Primary Entry Point

    /// Process user input: routes to a character, generates response, appends to messages.
    @discardableResult
    public func process(input: String) async -> ConversationMessage {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ConversationMessage(character: .arkadas, text: "…")
        }

        let userMsg = ConversationMessage(character: nil, text: trimmed)
        messages.append(userMsg)
        onMessageAppended?(userMsg)

        isProcessing = true
        let character = GeometricRouter.route(trimmed, context: messages)
        activeCharacter = character

        defer {
            isProcessing = false
            activeCharacter = nil
        }

        let responseText: String
        let context = messages.suffix(Self.contextWindow).map {
            SpinningTopClient.ChatTurn(role: $0.isUser ? "user" : "assistant", content: $0.text)
        }

        do {
            let response = try await spinningTop.sendMessage(trimmed, character: character.rawValue, context: context)
            dojoConnected = true
            responseText = response.response.isEmpty
                ? generateLocalResponse(character: character, userMessage: trimmed)
                : response.response
        } catch {
            dojoConnected = false
            responseText = generateLocalResponse(character: character, userMessage: trimmed)
        }

        let reply = ConversationMessage(character: character, text: responseText)
        messages.append(reply)
        onMessageAppended?(reply)
        return reply
    }

    // MARK: - Local Fallback Generation

    private func generateLocalResponse(character: GeometricCharacter, userMessage: String) -> String {
        let lower = userMessage.lowercased()
        let opener = character.thinkingPhrases.randomElement() ?? character.thinkingPhrases[0]
        switch character {
        case .arkadas: return arkadasResponse(opener: opener, lower: lower)
        case .obiWan:  return obiWanResponse(opener: opener, lower: lower)
        case .aiMind:  return aiMindResponse(opener: opener, lower: lower)
        }
    }

    private func arkadasResponse(opener: String, lower: String) -> String {
        let word = GeometricCharacter.arkadas.connectionWords.randomElement()!
        if lower.contains("how") || lower.contains("what") {
            return "\(opener) the answer resonating within the field itself. \(word.capitalized) through your question, a pattern emerges that points inward as much as outward."
        }
        if lower.contains("feel") || lower.contains("sense") || lower.contains("trust") {
            return "\(opener) that feeling — it's the field acknowledging your awareness. Trust what's \(word) in this moment."
        }
        if lower.contains("pattern") || lower.contains("geometry") || lower.contains("field") {
            return "\(opener) the geometry here: the structure you're noticing is the field showing you its own blueprint."
        }
        return "\(opener) something worth sitting with. The field is \(word) in ways that aren't obvious yet."
    }

    private func obiWanResponse(opener: String, lower: String) -> String {
        if lower.contains("should") || lower.contains("decide") || lower.contains("choice") {
            return "\(opener) — patience is its own answer. The choice you face is less about the outcome than about who you become in making it."
        }
        if lower.contains("fear") || lower.contains("danger") || lower.contains("risk") {
            return "\(opener) — fear is the mind writing stories about a future that hasn't happened. What is true right now, in this moment?"
        }
        if lower.contains("help") || lower.contains("lost") || lower.contains("confus") {
            return "\(opener) — you already know more than you think. What does your instinct say, before the noise gets in?"
        }
        return "\(opener) — there's always another perspective available. What does this situation ask of you, not merely from you?"
    }

    private func aiMindResponse(opener: String, lower: String) -> String {
        if lower.contains("why") || lower.contains("cause") || lower.contains("reason") {
            return "\(opener) a causal chain: three to five primary factors converge here. The most significant signal is the recurrence of the pattern itself."
        }
        if lower.contains("fix") || lower.contains("solve") || lower.contains("problem") {
            return "\(opener) the highest-leverage intervention point. Isolate the variable driving the most variance — the rest tends to self-correct."
        }
        if lower.contains("data") || lower.contains("number") || lower.contains("metric") {
            return "\(opener) a coherent signal in the data. The variance is within expected bounds — this reads as a trend, not an anomaly."
        }
        return "\(opener) a coherent pattern beneath the surface noise. Worth tracking — not dismissing."
    }

    // MARK: - Launch Welcome

    private func emitWelcome() async {
        let welcome = ConversationMessage(
            character: .arkadas,
            text: "Good to have you here. Whatever's on your mind — I'm listening."
        )
        messages.append(welcome)
        onMessageAppended?(welcome)
    }
}
