import Foundation

// MARK: - ArtifactKind
// The kind of artifact encountered — shapes which services and boundary rules apply.

public enum ArtifactKind: String, Codable, Sendable, Equatable, CaseIterable {
    case notionPage         = "NOTION_PAGE"
    case googleDriveFile    = "GOOGLE_DRIVE_FILE"
    case localFile          = "LOCAL_FILE"
    case voiceRecording     = "VOICE_RECORDING"
    case emailMessage       = "EMAIL_MESSAGE"
    case codeFile           = "CODE_FILE"
    case calendarEvent      = "CALENDAR_EVENT"
    case databaseRecord     = "DATABASE_RECORD"
    case packet             = "PACKET"              // DOJOShared Packet in transit
    case sealedVoice        = "SEALED_VOICE"        // SealedVoiceObject with receipt
    case unknown            = "UNKNOWN"
}

// MARK: - SovereignTouchStatus
// The touch and canonization state of any artifact within FIELD authority.
//
// Distinct from AuthorityLevel (VesselContract), which tracks promotion of locally-generated output.
// SovereignTouchStatus classifies any artifact FIELD has encountered, regardless of origin:
// a Notion page, a Google Drive doc, a local file, a voice recording, an email.
//
// Decision tree:
//   Not in index              → UNTOUCHED or DISCOVERED
//   In index, no hash         → INDEXED or NAMED
//   Hashed, no receipt        → HASHED
//   Receipted, not promoted   → RECEIPTED or SOVEREIGN_TOUCHED
//   Promoted authority        → CANONICAL or CANONICAL_ALIAS
//   Not authority             → MIRROR_ONLY or DUPLICATE
//   Blocked from promotion    → HELD
//   State cannot be read      → UNKNOWN

public enum SovereignTouchStatus: String, Codable, Sendable, Equatable, CaseIterable {
    /// Known to exist but no FIELD process has touched it.
    case untouched          = "UNTOUCHED"
    /// Seen by scan or discovery; not yet entered into a registry.
    case discovered         = "DISCOVERED"
    /// Entered into a FIELD index or registry.
    case indexed            = "INDEXED"
    /// FIELD canonical naming applied or mapped.
    case named              = "NAMED"
    /// Content hash or stable identity established.
    case hashed             = "HASHED"
    /// A FIELD processing receipt exists.
    case receipted          = "RECEIPTED"
    /// Passed through the sovereign gate or approved touch process.
    case sovereignTouched   = "SOVEREIGN_TOUCHED"
    /// Alias pointing to the canonical object with matching hash.
    case canonicalAlias     = "CANONICAL_ALIAS"
    /// Promoted source of truth for its scope.
    case canonical          = "CANONICAL"
    /// Copy or reference only — not the authority for this scope.
    case mirrorOnly         = "MIRROR_ONLY"
    /// Known duplicate of a canonical object.
    case duplicate          = "DUPLICATE"
    /// Known but promotion blocked — pins missing or risk present.
    case held               = "HELD"
    /// Touch state cannot be determined.
    case unknown            = "UNKNOWN"
}

// MARK: - FieldArtifactBoundaryStatus
// The combined boundary record for one artifact:
// where it is, what kind it is, how FIELD has treated it, and what authority it currently holds.

public struct FieldArtifactBoundaryStatus: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let artifactKind: ArtifactKind
    public let artifactTitle: String?
    public let currentLocation: String?
    public let sourceSurface: SurfaceVector?
    public let canonicalHome: String?

    public let sovereignTouchStatus: SovereignTouchStatus
    public let authorityLevel: AuthorityLevel?

    public let contentHash: String?
    public let canonicalAlias: String?
    public let duplicateOf: String?

    public let lastReceiptID: String?
    public let holdReasons: [SemanticHoldReason]
    public let lastCheckedAt: Date

    public init(
        id: String = UUID().uuidString,
        artifactKind: ArtifactKind,
        artifactTitle: String? = nil,
        currentLocation: String? = nil,
        sourceSurface: SurfaceVector? = nil,
        canonicalHome: String? = nil,
        sovereignTouchStatus: SovereignTouchStatus,
        authorityLevel: AuthorityLevel? = nil,
        contentHash: String? = nil,
        canonicalAlias: String? = nil,
        duplicateOf: String? = nil,
        lastReceiptID: String? = nil,
        holdReasons: [SemanticHoldReason] = [],
        lastCheckedAt: Date = Date()
    ) {
        self.id = id
        self.artifactKind = artifactKind
        self.artifactTitle = artifactTitle
        self.currentLocation = currentLocation
        self.sourceSurface = sourceSurface
        self.canonicalHome = canonicalHome
        self.sovereignTouchStatus = sovereignTouchStatus
        self.authorityLevel = authorityLevel
        self.contentHash = contentHash
        self.canonicalAlias = canonicalAlias
        self.duplicateOf = duplicateOf
        self.lastReceiptID = lastReceiptID
        self.holdReasons = holdReasons
        self.lastCheckedAt = lastCheckedAt
    }
}
