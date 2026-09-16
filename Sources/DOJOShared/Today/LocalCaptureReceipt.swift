import CryptoKit
import Foundation

/// Evidence that the Mac Today composer completed one local loop.
///
/// This is an object-scoped receipt. It proves local persistence of the
/// completed content on this surface; it does not promote the object into
/// FIELD authority or imply a chamber/runtime decision.
public struct LocalCaptureReceipt: Codable, Equatable, Hashable, Sendable, Identifiable {
    public let receiptID: String
    public var id: String { receiptID }
    public let objectID: String
    public let surface: String
    public let operation: String
    public let result: String
    public let issuedAt: Date
    public let contentSHA256: String
    public let objectPath: String
    public let receiptPath: String

    public init(
        receiptID: String = UUID().uuidString,
        objectID: String,
        surface: String,
        operation: String,
        result: String,
        issuedAt: Date = Date(),
        contentSHA256: String,
        objectPath: String,
        receiptPath: String
    ) {
        self.receiptID = receiptID
        self.objectID = objectID
        self.surface = surface
        self.operation = operation
        self.result = result
        self.issuedAt = issuedAt
        self.contentSHA256 = contentSHA256
        self.objectPath = objectPath
        self.receiptPath = receiptPath
    }

    public enum Operation {
        public static let capture = "local_capture"
        public static let hostedAnswer = "hosted_answer"
        public static let portalResponse = "portal_response"
    }

    public enum Outcome {
        public static let captured = "CAPTURED"
        public static let completed = "COMPLETED"
    }

    /// Stable digest over the captured object fields. The receipt itself is
    /// deliberately excluded so the evidence does not hash itself.
    public static func contentDigest(
        objectID: String,
        kind: String,
        home: String,
        title: String,
        body: String,
        subtitle: String,
        createdAt: Date,
        sourcePrompt: String?
    ) -> String {
        let formatter = ISO8601DateFormatter()
        return FieldDigest.sha256(
            components: [
                objectID,
                kind,
                home,
                title,
                body,
                subtitle,
                formatter.string(from: createdAt),
                sourcePrompt ?? ""
            ]
        )
    }
}

public enum FieldDigest {
    public static func sha256(components: [String]) -> String {
        let raw = components.joined(separator: "|")
        let digest = SHA256.hash(data: Data(raw.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
