import Foundation
#if canImport(DOJOShared)
import DOJOShared
#endif

public struct Packet: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let createdAt: Date
    public let deviceID: String
    public let operatorID: String
    public let integrityHash: String
    public let previousPacketHash: String?
    public let textNotes: String
    public let mediaRefs: [String]
    public let voiceRef: String?
    public let geoHash: String?
    public var state: PacketState
    public var retryCount: Int
    public var receipt: PacketReceipt?
    public var resonance: ResonanceSignature?
    public var workLayerStatus: WorkLayerStatus?
    public var semanticHoldReasons: [SemanticHoldReason]

    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        deviceID: String,
        operatorID: String,
        integrityHash: String,
        previousPacketHash: String? = nil,
        textNotes: String = "",
        mediaRefs: [String] = [],
        voiceRef: String? = nil,
        geoHash: String? = nil,
        state: PacketState = .draft,
        retryCount: Int = 0,
        receipt: PacketReceipt? = nil,
        resonance: ResonanceSignature? = nil,
        workLayerStatus: WorkLayerStatus? = nil,
        semanticHoldReasons: [SemanticHoldReason] = []
    ) {
        self.id = id
        self.createdAt = createdAt
        self.deviceID = deviceID
        self.operatorID = operatorID
        self.integrityHash = integrityHash
        self.previousPacketHash = previousPacketHash
        self.textNotes = textNotes
        self.mediaRefs = mediaRefs
        self.voiceRef = voiceRef
        self.geoHash = geoHash
        self.state = state
        self.retryCount = retryCount
        self.receipt = receipt
        self.resonance = resonance
        self.workLayerStatus = workLayerStatus
        self.semanticHoldReasons = semanticHoldReasons
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case deviceID
        case operatorID
        case integrityHash
        case previousPacketHash
        case textNotes
        case mediaRefs
        case voiceRef
        case geoHash
        case state
        case retryCount
        case receipt
        case resonance
        case workLayerStatus
        case semanticHoldReasons
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        deviceID = try container.decode(String.self, forKey: .deviceID)
        operatorID = try container.decode(String.self, forKey: .operatorID)
        integrityHash = try container.decode(String.self, forKey: .integrityHash)
        previousPacketHash = try container.decodeIfPresent(String.self, forKey: .previousPacketHash)
        textNotes = try container.decode(String.self, forKey: .textNotes)
        mediaRefs = try container.decode([String].self, forKey: .mediaRefs)
        voiceRef = try container.decodeIfPresent(String.self, forKey: .voiceRef)
        geoHash = try container.decodeIfPresent(String.self, forKey: .geoHash)
        state = try container.decode(PacketState.self, forKey: .state)
        retryCount = try container.decode(Int.self, forKey: .retryCount)
        receipt = try container.decodeIfPresent(PacketReceipt.self, forKey: .receipt)
        resonance = try container.decodeIfPresent(ResonanceSignature.self, forKey: .resonance)
        workLayerStatus = try container.decodeIfPresent(WorkLayerStatus.self, forKey: .workLayerStatus)
        semanticHoldReasons = try container.decodeIfPresent([SemanticHoldReason].self, forKey: .semanticHoldReasons) ?? []
    }
}
