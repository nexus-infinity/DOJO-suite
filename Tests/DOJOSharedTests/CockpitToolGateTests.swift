import Foundation
import XCTest
@testable import DOJOShared

private final class CockpitURLProtocol: URLProtocol {
    static var requestCount = 0
    static var responder: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.requestCount += 1
        do {
            let (response, data) = try Self.responder!(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

private struct ExactAuthorityVerifier: CockpitAuthorityVerifying {
    let receiptID: String
    let toolName: String

    func permits(
        _ proof: CockpitAuthorityProof,
        toolName: String,
        correlationID: UUID
    ) async -> Bool {
        proof.receiptID == receiptID && proof.toolName == self.toolName && toolName == self.toolName
    }
}

final class CockpitToolGateTests: XCTestCase {
    override func setUp() {
        super.setUp()
        CockpitURLProtocol.requestCount = 0
        CockpitURLProtocol.responder = nil
    }

    private func session() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [CockpitURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    func testConsequentialCallWithoutAuthorityIsDeniedBeforeDispatch() async {
        let client = SpinningTopClient(baseURL: "http://cockpit.test", session: session())

        do {
            _ = try await client.callTool(
                name: "atlas_load_model",
                effect: .consequential
            )
            XCTFail("Expected permission denial")
        } catch SpinningTopClient.SpinningTopError.permissionDenied {
            XCTAssertEqual(CockpitURLProtocol.requestCount, 0)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testForgedAuthorityIsDeniedBeforeDispatch() async {
        let verifier = ExactAuthorityVerifier(receiptID: "real-receipt", toolName: "atlas_load_model")
        let client = SpinningTopClient(
            baseURL: "http://cockpit.test",
            session: session(),
            authorityVerifier: verifier
        )

        do {
            _ = try await client.callTool(
                name: "atlas_load_model",
                effect: .consequential,
                authorityProof: CockpitAuthorityProof(
                    receiptID: "forged-receipt",
                    toolName: "atlas_load_model"
                )
            )
            XCTFail("Expected permission denial")
        } catch SpinningTopClient.SpinningTopError.permissionDenied {
            XCTAssertEqual(CockpitURLProtocol.requestCount, 0)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testReadOnlyCallConsumesMatchingCorrelation() async throws {
        let correlationID = UUID()
        CockpitURLProtocol.responder = { request in
            XCTAssertEqual(
                request.value(forHTTPHeaderField: "X-FIELD-Correlation-ID"),
                correlationID.uuidString
            )
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = try JSONSerialization.data(withJSONObject: [
                "correlation_id": correlationID.uuidString,
                "status": "stable"
            ])
            return (response, data)
        }
        let client = SpinningTopClient(baseURL: "http://cockpit.test", session: session())

        let receipt = try await client.callTool(
            name: "obiwan_status",
            effect: .readOnly,
            correlationID: correlationID
        )

        XCTAssertEqual(receipt.correlationID, correlationID)
        XCTAssertEqual(receipt.toolName, "obiwan_status")
        XCTAssertEqual(CockpitURLProtocol.requestCount, 1)
    }

    func testMismatchedCorrelationIsWithheld() async {
        CockpitURLProtocol.responder = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = try JSONSerialization.data(withJSONObject: [
                "correlation_id": UUID().uuidString,
                "status": "stable"
            ])
            return (response, data)
        }
        let client = SpinningTopClient(baseURL: "http://cockpit.test", session: session())

        do {
            _ = try await client.callTool(name: "obiwan_status", effect: .readOnly)
            XCTFail("Expected correlation mismatch")
        } catch SpinningTopClient.SpinningTopError.correlationMismatch {
            XCTAssertEqual(CockpitURLProtocol.requestCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
