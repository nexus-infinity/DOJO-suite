import Foundation

// MARK: - ChamberRouter

/// Discovers live chamber endpoints and routes
/// GeometricCharacter messages to the right SpinningTopClient.
///
/// Node lifecycle:  alive → suspect (failures accumulating) → quarantined → removed
///                                                          ↑                    ↓
///                              1 success restores immediately          reprobe on quarantine
///
/// Routing is symbol-first and service-boundary aware. Canonical character
/// endpoints are probed directly; DOJO /state can add or refresh live nodes.
/// If a character's preferred chamber isn't live, falls back to DOJO.
@MainActor
public final class ChamberRouter {

    // MARK: - Character → Chamber preference

    private static let preferredChamber: [GeometricCharacter: String] = [
        .arkadas: "arkadas",
        .obiWan:  "obiwan",
        .aiMind:  "dojo"
    ]

    private static let canonicalPorts: [String: Int] = [
        "arkadas": 7170,
        "obiwan": 9630,
        "dojo": 7410
    ]

    private static let symbolKeys: [String: String] = [
        "◼︎": "dojo",
        "◼": "dojo",
        "●": "obiwan",
        "▲": "atlas",
        "▼": "tata",
        "◻": "akron",
        "♦︎": "akron",
        "◉": "arkadas",
        "🎭": "arkadas",
        "◎": "kingschamber",
        "⊗": "kingschamber"
    ]

    private static let pruneThreshold = 3
    private static let staleAfter: TimeInterval = 300   // 5 minutes

    // MARK: - State

    private let dojo: SpinningTopClient                          // unconditional fallback
    private var liveClients: [String: SpinningTopClient] = [:]  // routable
    private var quarantined: [String: SpinningTopClient] = [:]  // suspect — not routed, reprobe pending
    private var failureCounts: [String: Int] = [:]
    private var isRefreshing = false                            // dedup guard for refreshIfStale
    public private(set) var lastTopologyRefresh: Date?

    // MARK: - Init

    public init(dojoBaseURL: String = "http://localhost:7410") {
        self.dojo = SpinningTopClient(baseURL: dojoBaseURL)
    }

    // MARK: - Discovery

    /// Probe canonical endpoints, then query DOJO /state to rebuild the live table.
    /// Nodes that reappear are restored from quarantine automatically.
    public func refreshTopology() async {
        var clients: [String: SpinningTopClient] = [:]

        for (key, port) in Self.canonicalPorts {
            let client = quarantined[key]
                ?? liveClients[key]
                ?? SpinningTopClient(baseURL: "http://localhost:\(port)")
            if ((try? await client.healthCheck()) ?? false) {
                clients[key] = quarantined.removeValue(forKey: key) ?? client
                failureCounts[key] = 0
            }
        }

        if let state = try? await dojo.getState() {
            for node in state.nodes where node.state {
                guard let port = node.mcp_port else { continue }
                let key = key(for: node)
                let client = quarantined.removeValue(forKey: key)    // restore if quarantined
                    ?? clients[key]                                  // keep direct probe session
                    ?? liveClients[key]                              // keep existing session
                    ?? SpinningTopClient(baseURL: "http://localhost:\(port)")
                clients[key] = client
                failureCounts[key] = 0
            }
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
    /// Re-validates quarantine state post-suspension: refreshTopology may have
    /// already resolved the key while healthCheck() was awaited.
    private func reprobe(key: String) async {
        guard let client = quarantined[key] else { return }
        let alive = (try? await client.healthCheck()) ?? false
        // Post-suspension check: if refreshTopology already moved this key out of
        // quarantine, honour that decision and do not write over it.
        guard quarantined[key] != nil else {
            print("◆ ChamberRouter: '\(key)' reprobe superseded — topology already resolved")
            return
        }
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
        // isRefreshing guard prevents N concurrent topology refreshes when client(for:)
        // is called rapidly while topology is stale.
        guard isStale, !isRefreshing else { return }
        isRefreshing = true
        Task {
            defer { isRefreshing = false }
            await refreshTopology()
        }
    }

    private func key(for node: SpinningTopClient.StateResponse.Node) -> String {
        Self.symbolKeys[node.symbol] ?? normalized(node.name)
    }

    private func normalized(_ name: String) -> String {
        name.lowercased()
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
    }
}
