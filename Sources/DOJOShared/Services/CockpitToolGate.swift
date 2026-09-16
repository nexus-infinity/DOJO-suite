import Foundation

public enum CockpitToolEffect: String, Codable, Sendable {
    case readOnly
    case consequential
}

public struct CockpitAuthorityProof: Codable, Equatable, Sendable {
    public let receiptID: String
    public let toolName: String
    public let nonce: String
    public let verificationID: UUID

    public init(
        receiptID: String,
        toolName: String,
        nonce: String = "",
        verificationID: UUID = UUID()
    ) {
        self.receiptID = receiptID
        self.toolName = toolName
        self.nonce = nonce
        self.verificationID = verificationID
    }
}

/// A verifier is supplied by the lawful authority lane. The cockpit must not
/// infer authority from a model proposal or from the mere presence of a token.
public protocol CockpitAuthorityVerifying: Sendable {
    func permits(
        _ proof: CockpitAuthorityProof,
        toolName: String,
        correlationID: UUID
    ) async -> Bool
}

/// Production default: consequential work remains withheld until a canonical
/// verifier is explicitly wired into the adapter.
public struct DenyAllCockpitAuthorityVerifier: CockpitAuthorityVerifying {
    public init() {}

    public func permits(
        _ proof: CockpitAuthorityProof,
        toolName: String,
        correlationID: UUID
    ) async -> Bool {
        false
    }
}

/// Canonical production binding: King’s Chamber verifies a Chronicle-resident
/// ARBITRATION_RECEIPT_V1. The verifier issues no authority and fails closed.
public struct KingsChamberAuthorityVerifier: CockpitAuthorityVerifying {
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
        _ proof: CockpitAuthorityProof,
        toolName: String,
        correlationID: UUID
    ) async -> Bool {
        guard proof.toolName == toolName else { return false }
        var request = URLRequest(url: baseURL.appendingPathComponent("authority/verify"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "receipt_id": proof.receiptID,
            "tool_name": toolName,
            "nonce": proof.nonce,
            "correlation_id": correlationID.uuidString,
            "cockpit_verification_id": proof.verificationID.uuidString
        ])
        guard let (data, response) = try? await session.data(for: request),
              let http = response as? HTTPURLResponse,
              http.statusCode == 200,
              let body = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              body["permitted"] as? Bool == true else {
            return false
        }
        return true
    }
}

public struct CockpitToolCallReceipt: Codable, Equatable, Sendable {
    public let correlationID: UUID
    public let toolName: String
    public let effect: CockpitToolEffect
    public let httpStatus: Int
    public let responseBody: Data

    public init(
        correlationID: UUID,
        toolName: String,
        effect: CockpitToolEffect,
        httpStatus: Int,
        responseBody: Data
    ) {
        self.correlationID = correlationID
        self.toolName = toolName
        self.effect = effect
        self.httpStatus = httpStatus
        self.responseBody = responseBody
    }
}
