import Foundation
import DOJOShared

enum GeneratedObjectKind: String, CaseIterable, Codable, Hashable {
    case answer
    case document
    case image
    case table
    case media
    case codeDiff

    var badge: String {
        switch self {
        case .answer: return "Answer"
        case .document: return "Document"
        case .image: return "Image"
        case .table: return "Table"
        case .media: return "Media"
        case .codeDiff: return "Code / Diff"
        }
    }

    var symbol: String {
        switch self {
        case .answer: return "text.bubble"
        case .document: return "doc.richtext"
        case .image: return "photo"
        case .table: return "tablecells"
        case .media: return "waveform"
        case .codeDiff: return "chevron.left.forwardslash.chevron.right"
        }
    }
}

/// The existing object store's lawful home. This is representation metadata,
/// not a second registry or an instruction about how the object is evaluated.
enum GeneratedObjectHome: String, CaseIterable, Codable, Hashable {
    case today
    case threads
    case captures
    case media
    case documents
    case investigations
}

/// First-class canvas object (M1 Answer + shell types).
struct GeneratedObjectShell: Identifiable, Equatable, Codable, Hashable {
    let id: UUID
    let kind: GeneratedObjectKind
    var home: GeneratedObjectHome
    var title: String
    var body: String
    var subtitle: String
    var isDeveloperOnly: Bool
    var createdAt: Date
    /// Hosted provider raw value when kind == .answer
    var providerID: String?
    var modelID: String?
    var sourcePrompt: String?
    /// Receipt issued when the Mac Today composer completes a local loop.
    /// Local only — not a Chronicle, chamber, or authority receipt.
    var localReceipt: LocalCaptureReceipt?
    /// Processing remains a separate, optional packet seam. The object shell
    /// carries it without interpreting or promoting its state.
    var processingPacket: TodayProcessingPacket?
    var isSavedLocally: Bool
    /// Attention product constraint C — plain recovery fields (not ontology UI).
    var lastStablePoint: String
    var nextAvailableAction: String
    var changedWhileAway: String

    init(
        id: UUID = UUID(),
        kind: GeneratedObjectKind,
        home: GeneratedObjectHome = .today,
        title: String,
        body: String,
        subtitle: String,
        isDeveloperOnly: Bool = false,
        createdAt: Date = Date(),
        providerID: String? = nil,
        modelID: String? = nil,
        sourcePrompt: String? = nil,
        localReceipt: LocalCaptureReceipt? = nil,
        processingPacket: TodayProcessingPacket? = nil,
        isSavedLocally: Bool = false,
        lastStablePoint: String = "created",
        nextAvailableAction: String = "Open · Review",
        changedWhileAway: String = "none"
    ) {
        self.id = id
        self.kind = kind
        self.home = home
        self.title = title
        self.body = body
        self.subtitle = subtitle
        self.isDeveloperOnly = isDeveloperOnly
        self.createdAt = createdAt
        self.providerID = providerID
        self.modelID = modelID
        self.sourcePrompt = sourcePrompt
        self.localReceipt = localReceipt
        self.processingPacket = processingPacket
        self.isSavedLocally = isSavedLocally
        self.lastStablePoint = lastStablePoint
        self.nextAvailableAction = nextAvailableAction
        self.changedWhileAway = changedWhileAway.isEmpty ? "none" : changedWhileAway
    }

    enum CodingKeys: String, CodingKey {
        case id, kind, home, title, body, subtitle, isDeveloperOnly, createdAt
        case providerID, modelID, sourcePrompt, localReceipt, processingPacket, isSavedLocally
        case lastStablePoint, nextAvailableAction, changedWhileAway
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        kind = try c.decode(GeneratedObjectKind.self, forKey: .kind)
        let decodedHome = try c.decodeIfPresent(GeneratedObjectHome.self, forKey: .home)
        let fallbackHome: GeneratedObjectHome
        switch kind {
        case .image, .media:
            fallbackHome = .media
        case .document, .codeDiff:
            fallbackHome = .documents
        case .answer, .table:
            fallbackHome = .today
        }
        home = decodedHome ?? fallbackHome
        title = try c.decode(String.self, forKey: .title)
        body = try c.decode(String.self, forKey: .body)
        subtitle = try c.decode(String.self, forKey: .subtitle)
        isDeveloperOnly = try c.decodeIfPresent(Bool.self, forKey: .isDeveloperOnly) ?? false
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        providerID = try c.decodeIfPresent(String.self, forKey: .providerID)
        modelID = try c.decodeIfPresent(String.self, forKey: .modelID)
        sourcePrompt = try c.decodeIfPresent(String.self, forKey: .sourcePrompt)
        localReceipt = try c.decodeIfPresent(LocalCaptureReceipt.self, forKey: .localReceipt)
        processingPacket = try c.decodeIfPresent(TodayProcessingPacket.self, forKey: .processingPacket)
        isSavedLocally = try c.decodeIfPresent(Bool.self, forKey: .isSavedLocally) ?? false
        lastStablePoint = try c.decodeIfPresent(String.self, forKey: .lastStablePoint) ?? "created"
        nextAvailableAction = try c.decodeIfPresent(String.self, forKey: .nextAvailableAction) ?? "Open · Review"
        let away = try c.decodeIfPresent(String.self, forKey: .changedWhileAway) ?? "none"
        changedWhileAway = away.isEmpty ? "none" : away
    }

    /// Plain recovery cue for Details (attention product constraint C).
    var recoveryCue: ObjectRecoveryCue {
        ObjectRecoveryCue(
            objectLabel: title,
            sourcePrompt: sourcePrompt ?? "",
            providerModel: {
                if let modelID {
                    return "\(providerDisplayName) · \(modelID)"
                }
                return providerDisplayName
            }(),
            createdAt: createdAt,
            lastStablePoint: lastStablePoint,
            nextAvailableAction: nextAvailableAction,
            changedWhileAway: changedWhileAway
        )
    }

    var providerDisplayName: String {
        if let providerID, let p = HostedProviderID(rawValue: providerID) {
            return p.displayName
        }
        return providerID ?? "—"
    }

    static func answer(
        body: String,
        provider: HostedProviderID,
        modelID: String,
        sourcePrompt: String
    ) -> GeneratedObjectShell {
        let short = sourcePrompt
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(48)
        let title = short.isEmpty ? "Answer" : "Answer · \(short)"
        let cue = ObjectRecoveryCue.forAnswer(
            title: String(title),
            sourcePrompt: sourcePrompt,
            providerDisplayName: provider.displayName,
            modelID: modelID
        )
        return GeneratedObjectShell(
            kind: .answer,
            home: .threads,
            title: String(title),
            body: body,
            subtitle: "\(provider.displayName) · \(modelID)",
            providerID: provider.rawValue,
            modelID: modelID,
            sourcePrompt: sourcePrompt,
            lastStablePoint: cue.lastStablePoint,
            nextAvailableAction: cue.nextAvailableAction,
            changedWhileAway: cue.changedWhileAway
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(kind, forKey: .kind)
        try c.encode(home, forKey: .home)
        try c.encode(title, forKey: .title)
        try c.encode(body, forKey: .body)
        try c.encode(subtitle, forKey: .subtitle)
        try c.encode(isDeveloperOnly, forKey: .isDeveloperOnly)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encodeIfPresent(providerID, forKey: .providerID)
        try c.encodeIfPresent(modelID, forKey: .modelID)
        try c.encodeIfPresent(sourcePrompt, forKey: .sourcePrompt)
        try c.encodeIfPresent(localReceipt, forKey: .localReceipt)
        try c.encodeIfPresent(processingPacket, forKey: .processingPacket)
        try c.encode(isSavedLocally, forKey: .isSavedLocally)
        try c.encode(lastStablePoint, forKey: .lastStablePoint)
        try c.encode(nextAvailableAction, forKey: .nextAvailableAction)
        try c.encode(changedWhileAway, forKey: .changedWhileAway)
    }

    func asMarkdown() -> String {
        var lines: [String] = []
        lines.append("# \(title)")
        lines.append("")
        lines.append("- Type: \(kind.badge)")
        lines.append("- Home: \(home.rawValue)")
        if let providerID {
            lines.append("- Provider: \(providerDisplayName) (`\(providerID)`)")
        }
        if let modelID {
            lines.append("- Model: \(modelID)")
        }
        lines.append("- Created: \(createdAt.ISO8601Format())")
        lines.append("- Last stable point: \(lastStablePoint)")
        lines.append("- Next action: \(nextAvailableAction)")
        lines.append("- Changed while away: \(changedWhileAway)")
        if let localReceipt {
            lines.append("- Local receipt: \(localReceipt.receiptID)")
            lines.append("- Content SHA-256: \(localReceipt.contentSHA256)")
            lines.append("- Receipt path: \(localReceipt.receiptPath)")
        }
        if let sourcePrompt, !sourcePrompt.isEmpty {
            lines.append("")
            lines.append("## Source prompt")
            lines.append("")
            lines.append(sourcePrompt)
        }
        lines.append("")
        lines.append("## Body")
        lines.append("")
        lines.append(body)
        lines.append("")
        return lines.joined(separator: "\n")
    }
}
