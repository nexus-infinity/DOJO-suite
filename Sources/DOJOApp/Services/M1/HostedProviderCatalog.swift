import Foundation

/// M1 hosted multimodel catalog — UI + routing only.
/// Local models are listed as disabled placeholders (not integrated).

enum HostedProviderID: String, CaseIterable, Identifiable, Codable, Hashable {
    case anthropic
    case openai
    case google
    case xai
    case local

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .anthropic: return "Anthropic"
        case .openai: return "OpenAI"
        case .google: return "Google"
        case .xai: return "xAI / Grok"
        case .local: return "Local"
        }
    }

    /// Whether M1 can attempt live hosted calls for this provider.
    var isHostedLive: Bool {
        switch self {
        case .anthropic, .openai, .google, .xai: return true
        case .local: return false
        }
    }

    var statusLabel: String {
        isHostedLive ? "Hosted API" : "Placeholder — not enabled"
    }

    var defaultModelID: String {
        models.first?.id ?? ""
    }

    var models: [HostedModelDescriptor] {
        switch self {
        case .anthropic:
            return [
                .init(id: "claude-sonnet-4-20250514", displayName: "Claude Sonnet 4"),
                .init(id: "claude-3-5-haiku-20241022", displayName: "Claude 3.5 Haiku")
            ]
        case .openai:
            return [
                .init(id: "gpt-4o-mini", displayName: "GPT-4o mini"),
                .init(id: "gpt-4o", displayName: "GPT-4o")
            ]
        case .google:
            return [
                .init(id: "gemini-3.1-flash-lite", displayName: "Gemini 3.1 Flash Lite"),
                .init(id: "gemini-flash-lite-latest", displayName: "Gemini Flash Lite Latest")
            ]
        case .xai:
            return [
                .init(id: "grok-3-mini", displayName: "Grok 3 mini"),
                .init(id: "grok-3", displayName: "Grok 3")
            ]
        case .local:
            return [
                .init(id: "local-disabled", displayName: "Local (disabled)", isEnabled: false)
            ]
        }
    }
}

struct HostedModelDescriptor: Identifiable, Hashable, Codable {
    let id: String
    let displayName: String
    var isEnabled: Bool = true
}

enum HostedProviderCatalog {
    static var liveProviders: [HostedProviderID] {
        HostedProviderID.allCases.filter(\.isHostedLive)
    }

    static func model(provider: HostedProviderID, modelID: String) -> HostedModelDescriptor? {
        provider.models.first { $0.id == modelID }
    }

    static func resolvedModelID(provider: HostedProviderID, preferred: String?) -> String {
        if let preferred,
           let match = provider.models.first(where: { $0.id == preferred && $0.isEnabled }) {
            return match.id
        }
        return provider.defaultModelID
    }
}
