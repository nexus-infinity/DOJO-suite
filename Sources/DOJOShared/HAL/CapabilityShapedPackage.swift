import Foundation

/// Immutable job DNA shared by every device expression.
///
/// Capability negotiation may change expression, never identity, meaning,
/// authority, provenance, or the route by which the result returns.
public struct CapabilityShapedPackage: Codable, Equatable, Sendable {
    public let packageID: UUID
    public let payloadSHA256: String
    public let semanticIntent: String
    public let authorityScope: String
    public let provenance: String
    public let returnRoute: String

    public init(
        packageID: UUID,
        payloadSHA256: String,
        semanticIntent: String,
        authorityScope: String,
        provenance: String,
        returnRoute: String
    ) {
        self.packageID = packageID
        self.payloadSHA256 = payloadSHA256
        self.semanticIntent = semanticIntent
        self.authorityScope = authorityScope
        self.provenance = provenance
        self.returnRoute = returnRoute
    }
}

public enum CapabilityLayerAvailability: String, Codable, Equatable, Sendable {
    case available
    case unavailable
}

/// An explicit, non-collapsed view of all three HAL layers.
public struct CapabilityLayerExpression: Codable, Equatable, Sendable {
    public let layer: Int
    public let availability: CapabilityLayerAvailability
}

public struct DeviceCapabilityExpression: Codable, Equatable, Sendable {
    public let package: CapabilityShapedPackage
    public let profile: HALProfile
    public let layers: [CapabilityLayerExpression]

    public init(package: CapabilityShapedPackage, profile: HALProfile) {
        self.package = package
        self.profile = profile
        self.layers = (1...3).map { layer in
            CapabilityLayerExpression(
                layer: layer,
                availability: profile.satisfiedLayers.contains(layer) ? .available : .unavailable
            )
        }
    }
}

public enum CapabilityCoherenceResult: String, Codable, Equatable, Sendable {
    case coherentDifferentPhenotypes = "COHERENT_DIFFERENT_PHENOTYPES"
    case holdIdentityDrift = "HOLD.IDENTITY_DRIFT"
    case holdSemanticDrift = "HOLD.SEMANTIC_DRIFT"
    case holdAuthorityExpansion = "HOLD.AUTHORITY_EXPANSION"
    case holdReturnLineageBroken = "HOLD.RETURN_LINEAGE_BROKEN"
    case holdNoPhenotypeDifference = "HOLD.NO_PHENOTYPE_DIFFERENCE"
}

public enum CapabilityCoherenceEvaluator {
    public static func compare(
        _ first: DeviceCapabilityExpression,
        _ second: DeviceCapabilityExpression
    ) -> CapabilityCoherenceResult {
        guard first.package.packageID == second.package.packageID,
              first.package.payloadSHA256 == second.package.payloadSHA256,
              first.package.provenance == second.package.provenance else {
            return .holdIdentityDrift
        }
        guard first.package.semanticIntent == second.package.semanticIntent else {
            return .holdSemanticDrift
        }
        guard first.package.authorityScope == second.package.authorityScope else {
            return .holdAuthorityExpansion
        }
        guard first.package.returnRoute == second.package.returnRoute else {
            return .holdReturnLineageBroken
        }
        guard first.layers != second.layers else {
            return .holdNoPhenotypeDifference
        }
        return .coherentDifferentPhenotypes
    }
}
