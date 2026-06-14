import Foundation

public struct AKRONClient: Sendable {
    private let baseURL: URL

    public init(host: String = "100.79.35.36", port: Int = 3960) {
        baseURL = URL(string: "http://\(host):\(port)")!
    }

    public func upload(_ packet: Packet) async throws -> PacketReceipt {
        var request = URLRequest(url: baseURL.appendingPathComponent("/packets"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(packet)
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw AKRONError.uploadFailed
        }
        return try JSONDecoder().decode(PacketReceipt.self, from: data)
    }
}

public enum AKRONError: Error, Sendable {
    case uploadFailed
    case invalidResponse
}
