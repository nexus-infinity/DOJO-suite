import Foundation

/// Foundation-only geographic coordinate for shared FIELD contracts.
/// MapKit and Core Location conversions stay in app targets.
public struct SpatialCoordinate: Codable, Equatable, Hashable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init?(latitude: Double, longitude: Double) {
        guard SpatialCoordinate.isValid(latitude: latitude, longitude: longitude) else {
            return nil
        }
        self.latitude = latitude
        self.longitude = longitude
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        guard SpatialCoordinate.isValid(latitude: latitude, longitude: longitude) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "SpatialCoordinate latitude or longitude is outside lawful geographic bounds."
                )
            )
        }
        self.latitude = latitude
        self.longitude = longitude
    }

    public static func isValid(latitude: Double, longitude: Double) -> Bool {
        latitude.isFinite &&
            longitude.isFinite &&
            (-90...90).contains(latitude) &&
            (-180...180).contains(longitude)
    }
}

/// Shared spatial anchor for a FIELD projection. It may carry a coordinate,
/// but a missing or held coordinate must stay explicit as Unknown/HOLD.
public struct SpatialAnchor: Codable, Equatable, Hashable, Sendable {
    public let anchorID: String
    public let coordinate: SpatialCoordinate?
    public let displayName: String
    public let horizontalAccuracyMeters: Double?
    public let observedAt: Date?
    public let recordedAt: Date?
    public let evidenceAnchor: EvidenceAnchor
    public let unknownDimensions: [UnknownDimension]
    public let holdReasons: [ProjectionHoldReason]

    public init(
        anchorID: String,
        coordinate: SpatialCoordinate?,
        displayName: String = "Unknown place",
        horizontalAccuracyMeters: Double? = nil,
        observedAt: Date? = nil,
        recordedAt: Date? = nil,
        evidenceAnchor: EvidenceAnchor = .unknownSource,
        unknownDimensions: [UnknownDimension] = [],
        holdReasons: [ProjectionHoldReason] = []
    ) {
        self.anchorID = anchorID
        self.coordinate = coordinate
        self.displayName = displayName
        self.horizontalAccuracyMeters = horizontalAccuracyMeters.map { max(0, $0) }
        self.observedAt = observedAt
        self.recordedAt = recordedAt
        self.evidenceAnchor = evidenceAnchor
        self.unknownDimensions = coordinate == nil && !unknownDimensions.contains(.geometricReturn)
            ? unknownDimensions + [.geometricReturn]
            : unknownDimensions
        self.holdReasons = coordinate == nil && !holdReasons.contains(.evidence)
            ? holdReasons + [.evidence]
            : holdReasons
    }

    public static let unknown = SpatialAnchor(
        anchorID: "Unknown.SpatialAnchor",
        coordinate: nil,
        displayName: "Unknown place",
        evidenceAnchor: .unknownSource,
        unknownDimensions: [.geometricReturn, .source],
        holdReasons: [.evidence]
    )

    public var mayRenderAsMapAnnotation: Bool {
        coordinate != nil &&
            !unknownDimensions.contains(.geometricReturn) &&
            !holdReasons.contains(.evidence)
    }
}

/// A shared, MapKit-free annotation candidate that binds spatial position to
/// inverse projection grounding. App targets convert this into native MapKit.
public struct SpatialEvidenceProjection: Codable, Equatable, Sendable {
    public let spatialAnchor: SpatialAnchor
    public let projectionGrounding: ProjectionGrounding

    public init(
        spatialAnchor: SpatialAnchor,
        projectionGrounding: ProjectionGrounding
    ) {
        self.spatialAnchor = spatialAnchor
        self.projectionGrounding = projectionGrounding
    }

    public var mayRenderAsOrdinaryMapAnnotation: Bool {
        spatialAnchor.mayRenderAsMapAnnotation &&
            projectionGrounding.authorityStatus.decision == .pass &&
            !projectionGrounding.hasUnknownSource &&
            !projectionGrounding.hasAuthorityHold
    }

    public var requiresHoldPresentation: Bool {
        spatialAnchor.holdReasons.contains(.evidence) ||
            projectionGrounding.hasAuthorityHold ||
            projectionGrounding.holdReasons.contains(.evidence)
    }
}

public enum SpatialEvidenceProjectionFactory {
    public static func fromLocalCaptureReceipt(
        _ receipt: LocalCaptureReceipt?,
        spatialAnchor: SpatialAnchor?,
        projectionIdentity: ProjectionIdentity,
        interactionContext: InteractionContext = .unknown,
        authorityStatus: ProjectionAuthorityStatus = .unknown,
        projectionTime: Date? = nil
    ) -> SpatialEvidenceProjection {
        let anchor = spatialAnchor ?? .unknown
        let grounding = ProjectionGroundingFactory.fromLocalCaptureReceipt(
            receipt,
            projectionIdentity: projectionIdentity,
            interactionContext: interactionContext,
            authorityStatus: authorityStatus,
            projectionTime: projectionTime
        )

        return SpatialEvidenceProjection(
            spatialAnchor: anchor,
            projectionGrounding: applySpatialState(from: anchor, to: grounding)
        )
    }

    private static func applySpatialState(
        from anchor: SpatialAnchor,
        to grounding: ProjectionGrounding
    ) -> ProjectionGrounding {
        let unknowns = merged(
            grounding.unknownDimensions,
            anchor.unknownDimensions
        )
        let holds = merged(
            grounding.holdReasons,
            anchor.holdReasons
        )

        return ProjectionGrounding(
            projectionIdentity: grounding.projectionIdentity,
            representedObject: grounding.representedObject,
            interactionContext: grounding.interactionContext,
            evidenceAnchors: grounding.evidenceAnchors,
            temporalValidity: grounding.temporalValidity,
            authorityStatus: grounding.authorityStatus,
            correctionRoute: grounding.correctionRoute,
            unknownDimensions: unknowns,
            holdReasons: holds,
            inverseScopeNote: grounding.inverseScopeNote
        )
    }

    private static func merged<T: Equatable>(_ lhs: [T], _ rhs: [T]) -> [T] {
        rhs.reduce(lhs) { partial, value in
            partial.contains(value) ? partial : partial + [value]
        }
    }
}
