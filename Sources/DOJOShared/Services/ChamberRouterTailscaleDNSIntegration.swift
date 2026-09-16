import Foundation

/// Network-aware admission seam for ChamberRouter.
///
/// Classification is necessary but never sufficient: the attribute must first
/// produce a non-HOLD route, its exact target must match the authority receipt,
/// and the existing King’s Chamber admission path must still accept the route.
/// Public-DNS routes are intentionally not promoted into a chamber route by
/// this seam.
public extension ChamberRouter {
    @discardableResult
    func admitSpecializedRoute(
        for character: GeometricCharacter,
        receipt: ChamberRouteAdmissionReceipt,
        correlationID: UUID,
        networkAttribute: TailscaleDNSManagementAttribute
    ) async -> Bool {
        let decision = networkAttribute.selectRoute()
        guard decision.route == .hostLoopback || decision.route == .tailnet,
              networkAttribute.targetAddress == receipt.endpoint else {
            recordFailure(for: character)
            return false
        }

        return await admitSpecializedRoute(
            for: character,
            receipt: receipt,
            correlationID: correlationID
        )
    }
}
