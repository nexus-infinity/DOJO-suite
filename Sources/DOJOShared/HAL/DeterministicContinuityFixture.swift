import Foundation

/// One surface that may carry an immutable package for the present object.
///
/// Qualification is deterministic: the surface must be present, typed,
/// oriented to the observer, and able to express every required HAL layer.
public struct ContinuitySurfaceCandidate: Equatable, Sendable {
    public let surfaceID: String
    public let expression: DeviceCapabilityExpression
    public let availableNow: Bool
    public let objectOriented: Bool
    public let gstAlignedToObserver: Bool
    public let selectionPriority: Int

    public init(
        surfaceID: String,
        expression: DeviceCapabilityExpression,
        availableNow: Bool,
        objectOriented: Bool,
        gstAlignedToObserver: Bool,
        selectionPriority: Int
    ) {
        self.surfaceID = surfaceID
        self.expression = expression
        self.availableNow = availableNow
        self.objectOriented = objectOriented
        self.gstAlignedToObserver = gstAlignedToObserver
        self.selectionPriority = selectionPriority
    }

    public func isQualified(requiredLayers: Set<Int>) -> Bool {
        let availableLayers = Set(
            expression.layers
                .filter { $0.availability == .available }
                .map(\.layer)
        )
        return availableNow
            && objectOriented
            && gstAlignedToObserver
            && requiredLayers.isSubset(of: availableLayers)
    }
}

/// Exact return proof for one continuity handoff.
///
/// The receipt repeats the immutable package pins deliberately. A receipt for
/// a similar package, expanded authority, or another return route cannot close
/// the pending handoff.
public struct ContinuityHandoffReceipt: Equatable, Sendable {
    public let receiptID: String
    public let packageID: UUID
    public let payloadSHA256: String
    public let semanticIntent: String
    public let authorityScope: String
    public let provenance: String
    public let returnRoute: String
    public let sourceSurfaceID: String
    public let receivingSurfaceID: String
    public let focusedObjectID: String
    public let receivingSurfaceConfirmed: Bool

    public init(
        receiptID: String,
        package: CapabilityShapedPackage,
        sourceSurfaceID: String,
        receivingSurfaceID: String,
        focusedObjectID: String,
        receivingSurfaceConfirmed: Bool
    ) {
        self.receiptID = receiptID
        self.packageID = package.packageID
        self.payloadSHA256 = package.payloadSHA256
        self.semanticIntent = package.semanticIntent
        self.authorityScope = package.authorityScope
        self.provenance = package.provenance
        self.returnRoute = package.returnRoute
        self.sourceSurfaceID = sourceSurfaceID
        self.receivingSurfaceID = receivingSurfaceID
        self.focusedObjectID = focusedObjectID
        self.receivingSurfaceConfirmed = receivingSurfaceConfirmed
    }
}

public enum ContinuityTraceEvent: Equatable, Sendable {
    case sourceCapabilityLossExposed(surfaceID: String)
    case arkadasSelectedQualifiedSurface(surfaceID: String)
    case receivingSurfaceConfirmed(surfaceID: String)
    case receiptReturned(receiptID: String)
    case dojoReacquiredFocusedObject(objectID: String, surfaceID: String)
    case priorSurfaceReleased(surfaceID: String)
}

public enum ContinuityFixtureError: Error, Equatable {
    case sourceIsNotActive
    case sourceStillQualified
    case noQualifiedContinuitySurface
    case noPendingHandoff
    case receivingSurfaceNotConfirmed
    case receiptIdentityMismatch
    case receiptAuthorityMismatch
    case receiptReturnLineageMismatch
    case receiptSurfaceMismatch
    case focusedObjectMismatch
}

/// Pure deterministic fixture for HAL loss → Arkadaş reselection → receipt →
/// DOJO focus reacquisition → source release.
///
/// It performs no transport and grants no authority. The previous surface
/// remains active throughout a pending handoff. There is intentionally no
/// public operation that releases it early.
public struct DeterministicContinuityFixture: Sendable {
    public let package: CapabilityShapedPackage
    public let requiredLayers: Set<Int>
    public let attention: TodayAttentionContract

    public private(set) var activeSurfaceID: String
    public private(set) var pendingReceivingSurfaceID: String?
    public private(set) var releasedSurfaceIDs: Set<String> = []
    public private(set) var returnedReceipt: ContinuityHandoffReceipt?
    public private(set) var trace: [ContinuityTraceEvent] = []

    private var pendingSourceSurfaceID: String?

    public init(
        package: CapabilityShapedPackage,
        requiredLayers: Set<Int>,
        activeSurface: ContinuitySurfaceCandidate,
        attention: TodayAttentionContract
    ) throws {
        guard activeSurface.expression.package == package,
              activeSurface.isQualified(requiredLayers: requiredLayers) else {
            throw ContinuityFixtureError.noQualifiedContinuitySurface
        }
        guard attention.objectID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw ContinuityFixtureError.focusedObjectMismatch
        }

        self.package = package
        self.requiredLayers = requiredLayers
        self.attention = attention
        self.activeSurfaceID = activeSurface.surfaceID
    }

    /// Exposes loss and selects exactly one already-qualified receiving surface.
    /// Highest priority wins; surface ID is the stable tie-breaker.
    /// The source remains active until `confirmHandoff` completes.
    @discardableResult
    public mutating func exposeLossAndPrepareHandoff(
        sourceAfterLoss: ContinuitySurfaceCandidate,
        candidates: [ContinuitySurfaceCandidate]
    ) throws -> String {
        guard sourceAfterLoss.surfaceID == activeSurfaceID else {
            throw ContinuityFixtureError.sourceIsNotActive
        }
        guard sourceAfterLoss.isQualified(requiredLayers: requiredLayers) == false else {
            throw ContinuityFixtureError.sourceStillQualified
        }

        trace.append(.sourceCapabilityLossExposed(surfaceID: sourceAfterLoss.surfaceID))

        let receivingSurface = candidates
            .filter { candidate in
                candidate.surfaceID != sourceAfterLoss.surfaceID
                    && candidate.expression.package == package
                    && candidate.isQualified(requiredLayers: requiredLayers)
            }
            .sorted {
                if $0.selectionPriority != $1.selectionPriority {
                    return $0.selectionPriority > $1.selectionPriority
                }
                return $0.surfaceID < $1.surfaceID
            }
            .first

        guard let receivingSurface else {
            throw ContinuityFixtureError.noQualifiedContinuitySurface
        }

        pendingSourceSurfaceID = sourceAfterLoss.surfaceID
        pendingReceivingSurfaceID = receivingSurface.surfaceID
        trace.append(.arkadasSelectedQualifiedSurface(surfaceID: receivingSurface.surfaceID))
        return receivingSurface.surfaceID
    }

    /// Closes the handoff only when the receiving surface confirms and the
    /// returned receipt binds the exact package, surfaces, focused object,
    /// authority ceiling, provenance, and return route.
    public mutating func confirmHandoff(with receipt: ContinuityHandoffReceipt) throws {
        guard let sourceSurfaceID = pendingSourceSurfaceID,
              let receivingSurfaceID = pendingReceivingSurfaceID else {
            throw ContinuityFixtureError.noPendingHandoff
        }
        guard receipt.receivingSurfaceConfirmed else {
            throw ContinuityFixtureError.receivingSurfaceNotConfirmed
        }
        guard receipt.packageID == package.packageID,
              receipt.payloadSHA256 == package.payloadSHA256,
              receipt.semanticIntent == package.semanticIntent,
              receipt.provenance == package.provenance else {
            throw ContinuityFixtureError.receiptIdentityMismatch
        }
        guard receipt.authorityScope == package.authorityScope else {
            throw ContinuityFixtureError.receiptAuthorityMismatch
        }
        guard receipt.returnRoute == package.returnRoute else {
            throw ContinuityFixtureError.receiptReturnLineageMismatch
        }
        guard receipt.sourceSurfaceID == sourceSurfaceID,
              receipt.receivingSurfaceID == receivingSurfaceID else {
            throw ContinuityFixtureError.receiptSurfaceMismatch
        }
        guard receipt.focusedObjectID == attention.objectID else {
            throw ContinuityFixtureError.focusedObjectMismatch
        }

        trace.append(.receivingSurfaceConfirmed(surfaceID: receivingSurfaceID))
        trace.append(.receiptReturned(receiptID: receipt.receiptID))
        trace.append(
            .dojoReacquiredFocusedObject(
                objectID: attention.objectID,
                surfaceID: receivingSurfaceID
            )
        )

        activeSurfaceID = receivingSurfaceID
        returnedReceipt = receipt
        releasedSurfaceIDs.insert(sourceSurfaceID)
        trace.append(.priorSurfaceReleased(surfaceID: sourceSurfaceID))
        pendingSourceSurfaceID = nil
        pendingReceivingSurfaceID = nil
    }
}
