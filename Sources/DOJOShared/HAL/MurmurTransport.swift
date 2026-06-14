import Foundation

/// HTTP transport to sovereign hub (OBI-WAN ingest, ARKADAŠ quality, TATA receipt).
/// Tailnet-perimeter auth in v0; X-Signature header wired but unsigned.
public final class MurmurTransport: Sendable {

    private let obiwanURL: URL   // 9630 — witness / audio ingest
    private let arkadasURL: URL  // 7170 — coordination / quality frames
    private let deviceID: String
    private let session: URLSession

    public init(
        host: String = "100.79.35.36",
        obiwanPort: Int = 9630,
        arkadasPort: Int = 7170,
        deviceID: String
    ) {
        self.obiwanURL = URL(string: "http://\(host):\(obiwanPort)")!
        self.arkadasURL = URL(string: "http://\(host):\(arkadasPort)")!
        self.deviceID = deviceID
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config)
    }

    // MARK: - Response types

    public struct IngestResponse: Codable, Sendable {
        public let ok: Bool
        public let packetID: String
        public let obiwanRef: String

        private enum CodingKeys: String, CodingKey {
            case ok
            case packetID = "packet_id"
            case obiwanRef = "obiwan_ref"
        }
    }

    public struct QualityResponse: Codable, Sendable {
        public let ok: Bool
        public let leader: Leader

        public struct Leader: Codable, Sendable {
            public let sourceID: String
            public let streamID: String

            private enum CodingKeys: String, CodingKey {
                case sourceID = "source_id"
                case streamID = "stream_id"
            }
        }

        private enum CodingKeys: String, CodingKey {
            case ok, leader
        }
    }

    // MARK: - Endpoints

    @discardableResult
    public func ingestAudio(_ packet: MurmurPacket<AudioChunkPayload>) async throws -> IngestResponse {
        try await post(to: obiwanURL.appendingPathComponent("v0/obiwan/ingest"), body: packet)
    }

    @discardableResult
    public func submitQuality(_ packet: MurmurPacket<QualityFramePayload>) async throws -> QualityResponse {
        try await post(to: arkadasURL.appendingPathComponent("v0/arkadas/quality"), body: packet)
    }

    @discardableResult
    public func sendHeartbeat(_ packet: MurmurPacket<HeartbeatPayload>) async throws -> IngestResponse {
        try await post(to: obiwanURL.appendingPathComponent("v0/obiwan/ingest"), body: packet)
    }

    // MARK: - Private

    private func post<Body: Encodable, Response: Decodable>(
        to url: URL,
        body: Body
    ) async throws -> Response {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(deviceID, forHTTPHeaderField: "X-Device-Id")
        req.setValue(UUID().uuidString, forHTTPHeaderField: "X-Packet-Id")
        req.setValue(ISO8601DateFormatter().string(from: Date()), forHTTPHeaderField: "X-Ts")
        req.setValue("", forHTTPHeaderField: "X-Signature")  // unsigned in v0; enforce in v1
        req.httpBody = try JSONEncoder().encode(body)
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw MurmurTransportError.badStatus
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }

    public enum MurmurTransportError: Error {
        case badStatus
    }
}
