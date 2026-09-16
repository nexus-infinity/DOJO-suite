import Foundation

/// A bounded request to admit one specialised endpoint into ChamberRouter.
///
/// The receipt is evidence presented to a verifier; its mere presence never
/// grants routing authority.
public struct ChamberRouteAdmissionReceipt: Codable, Equatable, Sendable {
    public let receiptID: String
    public let chamberKey: String
    public let endpoint: String
    public let correlationID: UUID
    public let issuedAt: Date
    public let expiresAt: Date

    public init(
        receiptID: String,
        chamberKey: String,
        endpoint: String,
        correlationID: UUID,
        issuedAt: Date,
        expiresAt: Date
    ) {
        self.receiptID = receiptID
        self.chamberKey = chamberKey
        self.endpoint = endpoint
        self.correlationID = correlationID
        self.issuedAt = issuedAt
        self.expiresAt = expiresAt
    }

    /// Exact King’s Chamber tool scope for this route tuple. Any change to
    /// chamber, endpoint, correlation, issue time, or expiry changes the scope
    /// that the live verifier must find in the arbitration receipt.
    public var authorityScope: String {
        [
            "chamber_route_admission_v0",
            chamberKey,
            correlationID.uuidString.lowercased(),
            String(Int(issuedAt.timeIntervalSince1970)),
            String(Int(expiresAt.timeIntervalSince1970)),
            endpoint
        ].joined(separator: ":")
    }
}

/// The lawful authority lane verifies receipt authenticity. ChamberRouter also
/// enforces chamber scope, correlation, time bounds, and endpoint shape.
public protocol ChamberRouteAdmissionVerifying: Sendable {
    func permits(
        _ receipt: ChamberRouteAdmissionReceipt,
        chamberKey: String,
        correlationID: UUID
    ) async -> Bool
}

/// Production remains fail-closed until a canonical King’s Chamber verifier
/// is separately bound and proven.
public struct DenyAllChamberRouteAdmissionVerifier: ChamberRouteAdmissionVerifying {
    public init() {}

    public func permits(
        _ receipt: ChamberRouteAdmissionReceipt,
        chamberKey: String,
        correlationID: UUID
    ) async -> Bool {
        false
    }
}

/// Production binding to the existing read-only King’s Chamber
/// ARBITRATION_RECEIPT_V1 verifier. It issues no authority and fails closed.
public struct KingsChamberRouteAdmissionVerifier: ChamberRouteAdmissionVerifying {
    private let baseURL: URL
    private let session: URLSession

    public init(
        baseURL: String = "http://127.0.0.1:8520",
        session: URLSession? = nil
    ) {
        self.baseURL = URL(string: baseURL)!
        self.session = session ?? URLSession(configuration: .ephemeral)
    }

    public func permits(
        _ receipt: ChamberRouteAdmissionReceipt,
        chamberKey: String,
        correlationID: UUID
    ) async -> Bool {
        guard receipt.chamberKey == chamberKey,
              receipt.correlationID == correlationID else {
            return false
        }

        var request = URLRequest(url: baseURL.appendingPathComponent("authority/verify"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "receipt_id": receipt.receiptID,
            "tool_name": receipt.authorityScope,
            "correlation_id": correlationID.uuidString.lowercased()
        ])

        guard let (data, response) = try? await session.data(for: request),
              let http = response as? HTTPURLResponse,
              http.statusCode == 200,
              let body = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              body["permitted"] as? Bool == true,
              body["receipt_id"] as? String == receipt.receiptID,
              body["tool_name"] as? String == receipt.authorityScope,
              body["required_anchor"] as? String == "tool:\(receipt.authorityScope)" else {
            return false
        }
        return true
    }
}

public enum ChamberRoutingDisposition: String, Codable, Equatable, Sendable {
    case canonicalDOJOFallback
    case receiptAdmittedSpecializedRoute
}
