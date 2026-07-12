import Foundation
#if canImport(DOJOShared)
import DOJOShared
#endif

public struct PacketReceipt: Codable, Sendable, Equatable {
    public let receiptID: String
    public let receivedAt: String       // ISO 8601
    public let chamberTrace: [String]   // e.g. ["AKRON","DOJO","ATLAS"]
    public let validationResult: String // "ACKNOWLEDGED" | "VALIDATED" | "HOLD"
    public let holdReasons: [String]?
    public let resonance: ResonanceSignature?
    public let workLayerStatus: WorkLayerStatus?
    public let semanticHoldReasons: [SemanticHoldReason]

    public init(
        receiptID: String,
        receivedAt: String,
        chamberTrace: [String],
        validationResult: String,
        holdReasons: [String]? = nil,
        resonance: ResonanceSignature? = nil,
        workLayerStatus: WorkLayerStatus? = nil,
        semanticHoldReasons: [SemanticHoldReason] = []
    ) {
        self.receiptID = receiptID
        self.receivedAt = receivedAt
        self.chamberTrace = chamberTrace
        self.validationResult = validationResult
        self.holdReasons = holdReasons
        self.resonance = resonance
        self.workLayerStatus = workLayerStatus
        self.semanticHoldReasons = semanticHoldReasons
    }

    private enum CodingKeys: String, CodingKey {
        case receiptID
        case receivedAt
        case chamberTrace
        case validationResult
        case holdReasons
        case resonance
        case workLayerStatus
        case semanticHoldReasons
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        receiptID = try container.decode(String.self, forKey: .receiptID)
        receivedAt = try container.decode(String.self, forKey: .receivedAt)
        chamberTrace = try container.decode([String].self, forKey: .chamberTrace)
        validationResult = try container.decode(String.self, forKey: .validationResult)
        holdReasons = try container.decodeIfPresent([String].self, forKey: .holdReasons)
        resonance = try container.decodeIfPresent(ResonanceSignature.self, forKey: .resonance)
        workLayerStatus = try container.decodeIfPresent(WorkLayerStatus.self, forKey: .workLayerStatus)
        semanticHoldReasons = try container.decodeIfPresent([SemanticHoldReason].self, forKey: .semanticHoldReasons) ?? []
    }
}
