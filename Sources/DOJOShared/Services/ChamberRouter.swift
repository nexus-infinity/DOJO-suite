import Foundation

// MARK: - ChamberRouter

/// Routes GeometricCharacter messages through authority-bearing endpoints.
///
/// Availability observations such as health checks and DOJO `/state` are not
/// routing authority. Until a preferred chamber supplies a correlated,
/// deterministic routing receipt, the canonical DOJO client remains the
/// fail-closed fallback.
@MainActor
public final class ChamberRouter {
    private struct AdmittedRoute {
        let client: SpinningTopClient
        let expiresAt: Date
    }

    // MARK: - Character → Chamber preference

    private static let preferredChamber: [GeometricCharacter: String] = [
        .arkadas: "arkadas",
        .obiWan:  "obiwan",
        .aiMind:  "dojo"
    ]

    private static let staleAfter: TimeInterval = 300   // 5 minutes

    // MARK: - State

    private let dojo: SpinningTopClient
    private let admissionVerifier: any ChamberRouteAdmissionVerifying
    private let replayLedger: any RouteAdmissionReplayLedger
    private let now: () -> Date
    /// Only clients admitted by a correlated deterministic routing receipt may
    /// enter this table. No observational topology source populates it.
    private var liveClients: [String: AdmittedRoute] = [:]
    private var isRefreshing = false
    public private(set) var lastTopologyRefresh: Date?

    // MARK: - Init

    public init(
        dojoBaseURL: String = "http://127.0.0.1:7410",
        admissionVerifier: any ChamberRouteAdmissionVerifying = KingsChamberRouteAdmissionVerifier(),
        replayLedger: any RouteAdmissionReplayLedger = FileRouteAdmissionReplayLedger(),
        now: @escaping () -> Date = { Date() }
    ) {
        self.dojo = SpinningTopClient(baseURL: dojoBaseURL)
        self.admissionVerifier = admissionVerifier
        self.replayLedger = replayLedger
        self.now = now
    }

    // MARK: - Discovery

    /// Invalidates any previously projected topology.
    ///
    /// Health and `/state` observations may inform presentation elsewhere, but
    /// cannot populate an authority-bearing routing table.
    public func refreshTopology() async {
        liveClients.removeAll()
        lastTopologyRefresh = Date()
    }

    // MARK: - Routing

    /// Returns a SpinningTopClient for the character's preferred chamber if live,
    /// otherwise the DOJO client (always the fallback).
    public func client(for character: GeometricCharacter) -> SpinningTopClient {
        refreshIfStale()
        let key = Self.preferredChamber[character] ?? "dojo"
        return admittedClient(for: key) ?? dojo
    }

    /// Admit exactly one specialised route after both local deterministic
    /// checks and lawful receipt verification pass.
    @discardableResult
    public func admitSpecializedRoute(
        for character: GeometricCharacter,
        receipt: ChamberRouteAdmissionReceipt,
        correlationID: UUID
    ) async -> Bool {
        let key = Self.preferredChamber[character] ?? "dojo"
        let currentTime = now()
        guard key != "dojo",
              receipt.chamberKey == key,
              receipt.correlationID == correlationID,
              receipt.issuedAt <= currentTime,
              currentTime < receipt.expiresAt,
              let endpoint = URL(string: receipt.endpoint),
              let scheme = endpoint.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              endpoint.host != nil,
              await admissionVerifier.permits(
                  receipt,
                  chamberKey: key,
                  correlationID: correlationID
              ),
              await replayLedger.claim(
                  receiptID: receipt.receiptID,
                  consumedAt: currentTime
              ) else {
            liveClients.removeValue(forKey: key)
            return false
        }

        liveClients[key] = AdmittedRoute(
            client: SpinningTopClient(baseURL: receipt.endpoint),
            expiresAt: receipt.expiresAt
        )
        lastTopologyRefresh = currentTime
        return true
    }

    public func routingDisposition(for character: GeometricCharacter) -> ChamberRoutingDisposition {
        let key = Self.preferredChamber[character] ?? "dojo"
        return admittedClient(for: key) == nil
            ? .canonicalDOJOFallback
            : .receiptAdmittedSpecializedRoute
    }

    // MARK: - Request Feedback

    /// Failure may demote an admitted route, but can never create one.
    public func recordFailure(for character: GeometricCharacter) {
        let key = Self.preferredChamber[character] ?? "dojo"
        liveClients.removeValue(forKey: key)
    }

    /// Success is an operational observation, not routing authority.
    public func recordSuccess(for character: GeometricCharacter) {
        // Deliberately no promotion. Only admitSpecializedRoute can populate
        // an authority-bearing route.
    }

    /// True only when the preferred chamber has an authority-admitted endpoint.
    public func isPreferredChamberLive(for character: GeometricCharacter) -> Bool {
        let key = Self.preferredChamber[character] ?? "dojo"
        return admittedClient(for: key) != nil
    }

    // MARK: - Private

    private func admittedClient(for key: String) -> SpinningTopClient? {
        guard let route = liveClients[key] else { return nil }
        guard now() < route.expiresAt else {
            liveClients.removeValue(forKey: key)
            return nil
        }
        return route.client
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

}
