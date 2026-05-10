import Foundation

// MARK: - ChamberRouter

/// Discovers live chamber endpoints from DOJO /state and routes
/// GeometricCharacter messages to the right SpinningTopClient.
///
/// Node lifecycle:  alive → suspect (failures accumulating) → quarantined → removed
///                                                          ↑                    ↓
///                              1 success restores immediately          reprobe on quarantine
///
/// Routing is data-driven — no hardcoded ports. If a character's preferred
/// chamber isn't live, falls back to the DOJO orchestrator.
@MainActor
public final class ChamberRouter {

    // MARK: - Character → Chamber preference

    private static let preferredChamber: [GeometricCharacter: String] = [
        .arkadas: "arkadas",
        .obiWan:  "obiwan",
        .aiMind:  "dojo"
    ]

    private static let pruneThreshold = 3
    private static let staleAfter: TimeInterval = 300   // 5 minutes

    // MARK: - State

    private let dojo: SpinningTopClient                          // unconditional fallback
    private var liveClients: [String: SpinningTopClient] = [:]  // routable
    private var quarantined: [String: SpinningTopClient] = [:]  // suspect — not routed, reprobe pending
    private var failureCounts: [String: Int] = [:]
    public private(set) var lastTopologyRefresh: Date?

    // MARK: - Init

    public init(dojoBaseURL: String = "http://localhost:7410") {
        self.dojo = SpinningTopClient(baseURL: dojoBaseURL)
    }

    // MARK: - Discovery

    /// Query DOJO /state and rebuild the live endpoint table.
    /// Nodes that reappear are restored from quarantine automatically.
    public func refreshTopology() async {
        guard let state = try? await dojo.getState() else { return }

        var clients: [String: SpinningTopClient] = [:]
        for node in state.nodes where node.state {
            guard let port = node.mcp_port else { continue }
            let key = normalized(node.name)
            let client = quarantined.removeValue(forKey: key)        // restore if quarantined
                ?? liveClients[key]                                  // keep existing session
                ?? SpinningTopClient(baseURL: "http://localhost:\(port)")
            clients[key] = client
            failureCounts[key] = 0
        }
        liveClients = clients
        lastTopologyRefresh = Date()
    }

    // MARK: - Routing

    /// Returns a SpinningTopClient for the character's preferred chamber if live,
    /// otherwise the DOJO client (always the fallback).
    public func client(for character: GeometricCharacter) -> SpinningTopClient {
        refreshIfStale()
        let key = Self.preferredChamber[character] ?? "dojo"
        return liveClients[key] ?? dojo
    }

    // MARK: - Health Feedback

    /// Record a request failure. After `pruneThreshold` consecutive failures
    /// the chamber is quarantined and a targeted reprobe is launched.
    public func recordFailure(for character: GeometricCharacter) {
        let key = Self.preferredChamber[character] ?? "dojo"
        guard liveClients[key] != nil else { return }

        let count = (failureCounts[key] ?? 0) + 1
        failureCounts[key] = count

        guard count >= Self.pruneThreshold else { return }

        if let client = liveClients.removeValue(forKey: key) {
            quarantined[key] = client
            failureCounts.removeValue(forKey: key)
            print("◆ ChamberRouter: '\(key)' quarantined after \(count) failures — reprobing")
            Task { await reprobe(key: key) }
        }
    }

    /// Record a successful request. Resets the failure counter and immediately
    /// restores the chamber if it was quarantined (trust re-accrual on first success).
    public func recordSuccess(for character: GeometricCharacter) {
        let key = Self.preferredChamber[character] ?? "dojo"
        failureCounts[key] = 0
        if let client = quarantined.removeValue(forKey: key) {
            liveClients[key] = client
            print("◆ ChamberRouter: '\(key)' restored from quarantine on success")
        }
    }

    /// True if the character's preferred chamber has a live (non-quarantined) endpoint.
    public func isPreferredChamberLive(for character: GeometricCharacter) -> Bool {
        let key = Self.preferredChamber[character] ?? "dojo"
        return liveClients[key] != nil
    }

    // MARK: - Private

    /// Targeted health check against the quarantined node only.
    /// Restores on pass, permanently removes on fail.
    private func reprobe(key: String) async {
        guard let client = quarantined[key] else { return }
        let alive = (try? await client.healthCheck()) ?? false
        if alive {
            quarantined.removeValue(forKey: key)
            liveClients[key] = client
            print("◆ ChamberRouter: '\(key)' restored after successful reprobe")
        } else {
            quarantined.removeValue(forKey: key)
            print("◆ ChamberRouter: '\(key)' permanently removed after failed reprobe")
        }
    }

    private func refreshIfStale() {
        let isStale = lastTopologyRefresh.map { Date().timeIntervalSince($0) > Self.staleAfter } ?? true
        if isStale { Task { await refreshTopology() } }
    }

    private func normalized(_ name: String) -> String {
        name.lowercased()
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
    }
}
