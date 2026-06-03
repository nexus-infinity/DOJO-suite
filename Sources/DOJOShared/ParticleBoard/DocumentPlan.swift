import Foundation

// MARK: - DocumentPlan  (canonical model, v0)
// This is what the AikidoOpticsCodec encodes FROM.
// Content lives here (title strings, headings). Structure is the bijection surface.

public struct DocumentPlan: Codable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    /// Up to 3 sections in v0 — maps 1:1 to the structure row (1,0)…(1,2).
    public let sections: [DocumentSection]
    /// Named placeholder slots (e.g. "{witness-excerpt}").
    public let placeholders: [String]
    /// v0 max 3 — maps to policy row (2,0)…(2,2).
    public let policyPins: [PolicyPin]

    public init(
        id: UUID = UUID(),
        title: String,
        sections: [DocumentSection] = [],
        placeholders: [String] = [],
        policyPins: [PolicyPin] = []
    ) {
        self.id = id
        self.title = title
        self.sections = sections
        self.placeholders = placeholders
        self.policyPins = policyPins
    }
}

public struct DocumentSection: Codable, Equatable, Sendable {
    public let id: UUID
    public let heading: String
    public let axis: CategoryAxis

    public init(id: UUID = UUID(), heading: String, axis: CategoryAxis) {
        self.id = id; self.heading = heading; self.axis = axis
    }
}

public struct PolicyPin: Codable, Equatable, Sendable {
    public let id: UUID
    public let allowedAction: String
    public let constraint: String?

    public init(id: UUID = UUID(), allowedAction: String, constraint: String? = nil) {
        self.id = id; self.allowedAction = allowedAction; self.constraint = constraint
    }
}

// MARK: - Draft Outputs

/// Deterministic Notion Markdown output — always reproducible from the same board state.

public struct DraftMetadata: Equatable, Sendable {
    public let sectionCount: Int
    public let hasPolicyPins: Bool
    public let primaryAxis: CategoryAxis?
    public let validationHome: PersistenceHome
    public let publishHome: PersistenceHome

    public init(
        sectionCount: Int,
        hasPolicyPins: Bool,
        primaryAxis: CategoryAxis?,
        validationHome: PersistenceHome,
        publishHome: PersistenceHome
    ) {
        self.sectionCount = sectionCount
        self.hasPolicyPins = hasPolicyPins
        self.primaryAxis = primaryAxis
        self.validationHome = validationHome
        self.publishHome = publishHome
    }
}

/// Primitive scene graph for image path — v0 stub, no synthesis.
