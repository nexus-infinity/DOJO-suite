import Foundation

/// Network path observed by the caller. A reachable service is not thereby
/// authorised for every path; the observer context must match the route.
public enum FieldNetworkContext: String, Codable, CaseIterable, Equatable, Sendable {
    case hostLoopback = "host_loopback"
    case sandboxLoopback = "sandbox_loopback"
    case tailnet = "tailnet"
    case external = "external"
    case stdio = "stdio"
    case unknown = "unknown"
}

/// Scope of the requested target, kept separate from the address string.
public enum FieldTargetScope: String, Codable, CaseIterable, Equatable, Sendable {
    case localHost = "local_host"
    case tailnetPeer = "tailnet_peer"
    case publicInternet = "public_internet"
    case unknown = "unknown"
}

/// Where the service is bound. This is a witness input, not an inference from
/// the hostname or IP address.
public enum FieldServiceBindContext: String, Codable, CaseIterable, Equatable, Sendable {
    case hostLoopback = "host_loopback"
    case sandboxLoopback = "sandbox_loopback"
    case tailnet = "tailnet"
    case external = "external"
    case unknown = "unknown"
}

/// Authority responsible for the address/resolution layer being selected.
public enum FieldDNSAuthority: String, Codable, CaseIterable, Equatable, Sendable {
    case tailscaleControlPlane = "tailscale_control_plane"
    case hostResolver = "host_resolver"
    case publicDNS = "public_dns"
    case fieldRouteRegistry = "field_route_registry"
    case unknown = "unknown"
}

/// Address form observed for the target. MagicDNS is intentionally not public
/// DNS, even though both are represented by names.
public enum FieldAddressKind: String, Codable, CaseIterable, Equatable, Sendable {
    case loopback = "loopback"
    case tailnetIPv4 = "tailnet_ipv4"
    case tailnetIPv6 = "tailnet_ipv6"
    case magicDNS = "magic_dns"
    case publicDNS = "public_dns"
    case stdio = "stdio"
    case unknown = "unknown"
}

public enum FieldRouteKind: String, Codable, CaseIterable, Equatable, Sendable {
    case hostLoopback = "host_loopback"
    case tailnet = "tailnet"
    case external = "external"
    case hold = "hold"
}

/// Result of pure route classification. It contains no transport client and
/// cannot mutate a resolver, Tailscale, ACL, route, or public DNS record.
public struct FieldRouteDecision: Codable, Equatable, Sendable {
    public let route: FieldRouteKind
    public let reason: String

    public init(route: FieldRouteKind, reason: String) {
        self.route = route
        self.reason = reason
    }

    public var isHeld: Bool { route == .hold }
}

/// Deterministic DNS/network management attribute for cross-surface route
/// selection. The attribute describes witnessed context; it is not a DNS
/// manager and does not grant mutation authority.
public struct TailscaleDNSManagementAttribute: Codable, Equatable, Sendable {
    public static let schema = "FIELD_TAILSCALE_DNS_MANAGEMENT_V0"

    public let observerContext: FieldNetworkContext
    public let targetScope: FieldTargetScope
    public let serviceBindContext: FieldServiceBindContext
    public let dnsAuthority: FieldDNSAuthority
    public let addressKind: FieldAddressKind
    public let targetAddress: String
    public let witnessID: String?
    public let witnessedAt: Date?
    public let authorityCeiling: String

    public init(
        observerContext: FieldNetworkContext,
        targetScope: FieldTargetScope,
        serviceBindContext: FieldServiceBindContext,
        dnsAuthority: FieldDNSAuthority,
        addressKind: FieldAddressKind,
        targetAddress: String,
        witnessID: String? = nil,
        witnessedAt: Date? = nil,
        authorityCeiling: String = "OBSERVATION_ONLY"
    ) {
        self.observerContext = observerContext
        self.targetScope = targetScope
        self.serviceBindContext = serviceBindContext
        self.dnsAuthority = dnsAuthority
        self.addressKind = addressKind
        self.targetAddress = targetAddress
        self.witnessID = witnessID
        self.witnessedAt = witnessedAt
        self.authorityCeiling = authorityCeiling
    }

    /// Classify the minimum lawful route. Missing witness or mismatched
    /// context always returns HOLD rather than trying a different address.
    public func selectRoute() -> FieldRouteDecision {
        guard !targetAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return hold("target address is missing")
        }
        guard witnessID != nil, witnessedAt != nil else {
            return hold("observer witness is missing")
        }

        switch targetScope {
        case .localHost:
            guard observerContext == .hostLoopback,
                  serviceBindContext == .hostLoopback,
                  dnsAuthority == .hostResolver,
                  addressKind == .loopback else {
                return hold("local-host target does not have a coherent loopback witness")
            }
            return FieldRouteDecision(
                route: .hostLoopback,
                reason: "same-host service is witnessed on host loopback"
            )

        case .tailnetPeer:
            guard observerContext == .tailnet,
                  serviceBindContext == .tailnet,
                  dnsAuthority == .tailscaleControlPlane,
                  [.tailnetIPv4, .tailnetIPv6, .magicDNS].contains(addressKind) else {
                return hold("tailnet target does not have a coherent Tailscale witness")
            }
            return FieldRouteDecision(
                route: .tailnet,
                reason: "remote target is witnessed through the Tailscale control-plane address layer"
            )

        case .publicInternet:
            guard observerContext == .external,
                  serviceBindContext == .external,
                  dnsAuthority == .publicDNS,
                  addressKind == .publicDNS else {
                return hold("public target does not have a coherent public-DNS witness")
            }
            return FieldRouteDecision(
                route: .external,
                reason: "public target is witnessed through the public DNS authority layer"
            )

        case .unknown:
            return hold("target scope is unknown")
        }
    }

    private func hold(_ reason: String) -> FieldRouteDecision {
        FieldRouteDecision(route: .hold, reason: reason)
    }
}
