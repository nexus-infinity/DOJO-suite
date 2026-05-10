import Foundation

public struct PacketReceipt: Codable, Sendable, Equatable {
    public let receiptID: String
    public let receivedAt: String       // ISO 8601
    public let chamberTrace: [String]   // e.g. ["AKRON","DOJO","ATLAS"]
    public let validationResult: String // "ACKNOWLEDGED" | "VALIDATED" | "HOLD"
    public let holdReasons: [String]?

    public init(
        receiptID: String,
        receivedAt: String,
        chamberTrace: [String],
        validationResult: String,
        holdReasons: [String]? = nil
    ) {
        self.receiptID = receiptID
        self.receivedAt = receivedAt
        self.chamberTrace = chamberTrace
        self.validationResult = validationResult
        self.holdReasons = holdReasons
    }
}
