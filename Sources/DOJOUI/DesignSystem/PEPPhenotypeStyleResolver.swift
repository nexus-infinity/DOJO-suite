import SwiftUI
import DOJOShared

/// Existing DOJO visual token names used by the PEP style resolver. The token
/// name is testable; the Color is the native SwiftUI expression for app use.
public enum PEPVisualToken: String, CaseIterable, Equatable, Hashable, Sendable {
    case primaryAction = "existing.cyan.primaryAction"
    case pass = "existing.green.pass"
    case hold = "existing.amber.hold"
    case forbidden = "existing.red.forbidden"
    case unknown = "existing.blueGrey.unknown"
    case evidence = "existing.sky.evidence"
    case correction = "existing.teal.correction"
    case neutral = "existing.slate.neutral"

    public var color: Color {
        switch self {
        case .primaryAction:
            return Color(hex: "#6CEBFF")
        case .pass:
            return Color(hex: "#86EFAC")
        case .hold:
            return Color(hex: "#FBBF24")
        case .forbidden:
            return Color(hex: "#F87171")
        case .unknown:
            return Color(hex: "#6B8A93")
        case .evidence:
            return Color(hex: "#7DD3FC")
        case .correction:
            return Color(hex: "#14B8A6")
        case .neutral:
            return FieldPalette.textMuted
        }
    }
}

public enum PEPShapeToken: String, CaseIterable, Equatable, Hashable, Sendable {
    case filledBadge = "existing.badge.filled"
    case outlinedBoundary = "existing.boundary.outlined"
    case mutedPanel = "existing.panel.muted"
    case heldBoundary = "existing.boundary.held"
}

public enum PEPTextToken: String, CaseIterable, Equatable, Hashable, Sendable {
    case title = "existing.text.titleRounded"
    case body = "existing.text.bodyRounded"
    case caption = "existing.text.captionRounded"
    case code = "existing.text.captionMonospaced"

    public var font: Font {
        switch self {
        case .title:
            return .system(size: 14, weight: .semibold, design: .rounded)
        case .body:
            return .system(size: 12, weight: .medium, design: .rounded)
        case .caption:
            return .system(size: 10, weight: .semibold, design: .rounded)
        case .code:
            return .system(size: 10, weight: .semibold, design: .monospaced)
        }
    }
}

public enum PEPResolvedActionAffordance: String, Codable, Equatable, Hashable, Sendable {
    case none = "NONE"
    case inspectOnly = "INSPECT_ONLY"
    case correctionRepresentable = "CORRECTION_REPRESENTABLE"
    case actionRepresentable = "ACTION_REPRESENTABLE"
}

public struct PEPResolvedStateBadge: Equatable, Hashable, Sendable {
    public let label: String
    public let symbolName: String
    public let token: PEPVisualToken
    public let shapeToken: PEPShapeToken

    public init(
        label: String,
        symbolName: String,
        token: PEPVisualToken,
        shapeToken: PEPShapeToken = .filledBadge
    ) {
        self.label = label
        self.symbolName = symbolName
        self.token = token
        self.shapeToken = shapeToken
    }
}

public struct PEPResolvedPhenotypeStyle: Equatable, Sendable {
    public let state: PEPPhenotypeResolutionState
    public let stateBadge: PEPResolvedStateBadge
    public let textToken: PEPTextToken
    public let accentToken: PEPVisualToken
    public let boundaryToken: PEPVisualToken
    public let evidenceToken: PEPVisualToken
    public let shapeToken: PEPShapeToken
    public let actionAffordance: PEPResolvedActionAffordance
    public let reinforcesWithLabel: Bool
    public let reinforcesWithSymbol: Bool
    public let reinforcesWithBoundary: Bool
    public let accessibilityLabel: String
    public let lineageSummary: String
    public let authoritySummary: String

    public var accentColor: Color { accentToken.color }
    public var boundaryColor: Color { boundaryToken.color }
    public var evidenceColor: Color { evidenceToken.color }
    public var font: Font { textToken.font }

    public var actionAffordanceEnabled: Bool {
        actionAffordance == .actionRepresentable
    }
}

public struct PEPPhenotypeBadgeView: View {
    public let style: PEPResolvedPhenotypeStyle

    public init(style: PEPResolvedPhenotypeStyle) {
        self.style = style
    }

    public var body: some View {
        HStack(spacing: 5) {
            Image(systemName: style.stateBadge.symbolName)
                .font(.system(size: 10, weight: .semibold))
            Text(style.stateBadge.label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
        }
        .foregroundStyle(style.accentColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(style.accentColor.opacity(0.12))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(style.boundaryColor.opacity(0.44), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .accessibilityLabel("PEP phenotype \(style.accessibilityLabel)")
    }
}

/// Resolves shared PEP meaning into native SwiftUI style tokens. This resolver
/// is pure: it does not render, deliver, route, write receipts, inspect devices,
/// infer consent, or change authority.
public enum PEPPhenotypeStyleResolver {
    public static func style(for resolution: PEPPhenotypeResolution) -> PEPResolvedPhenotypeStyle {
        let badge = stateBadge(for: resolution)
        let actionAffordance = resolvedActionAffordance(for: resolution)
        let lineage = lineageSummary(for: resolution)
        let authority = authoritySummary(for: resolution)
        let accessibility = [
            badge.label,
            authority,
            lineage,
            unknownSummary(for: resolution),
            holdSummary(for: resolution)
        ]
        .filter { !$0.isEmpty }
        .joined(separator: ". ")

        return PEPResolvedPhenotypeStyle(
            state: resolution.state,
            stateBadge: badge,
            textToken: .caption,
            accentToken: accentToken(for: resolution),
            boundaryToken: boundaryToken(for: resolution),
            evidenceToken: evidenceToken(for: resolution),
            shapeToken: shapeToken(for: resolution),
            actionAffordance: actionAffordance,
            reinforcesWithLabel: true,
            reinforcesWithSymbol: true,
            reinforcesWithBoundary: true,
            accessibilityLabel: accessibility,
            lineageSummary: lineage,
            authoritySummary: authority
        )
    }

    public static func styles(for resolutions: [PEPPhenotypeResolution]) -> [PEPResolvedPhenotypeStyle] {
        resolutions.map(style(for:))
    }

    private static func stateBadge(for resolution: PEPPhenotypeResolution) -> PEPResolvedStateBadge {
        switch resolution.state {
        case .eligible:
            return PEPResolvedStateBadge(label: "Eligible", symbolName: "checkmark.seal", token: .pass)
        case .held:
            return PEPResolvedStateBadge(label: "HOLD", symbolName: "pause.circle", token: .hold, shapeToken: .heldBoundary)
        case .unknown:
            return PEPResolvedStateBadge(label: "Unknown", symbolName: "questionmark.circle", token: .unknown, shapeToken: .outlinedBoundary)
        case .forbidden:
            return PEPResolvedStateBadge(label: "Forbidden", symbolName: "xmark.octagon", token: .forbidden, shapeToken: .outlinedBoundary)
        }
    }

    private static func accentToken(for resolution: PEPPhenotypeResolution) -> PEPVisualToken {
        if resolution.holdReasons.contains(.authority) || resolution.state == .held {
            return .hold
        }
        if resolution.state == .forbidden {
            return .forbidden
        }
        if resolution.unknownDimensions.contains(.source) || resolution.state == .unknown {
            return .unknown
        }
        return .pass
    }

    private static func boundaryToken(for resolution: PEPPhenotypeResolution) -> PEPVisualToken {
        switch resolution.state {
        case .eligible:
            return .evidence
        case .held:
            return .hold
        case .unknown:
            return .unknown
        case .forbidden:
            return .forbidden
        }
    }

    private static func evidenceToken(for resolution: PEPPhenotypeResolution) -> PEPVisualToken {
        if resolution.projectionGrounding?.hasUnknownSource == true || resolution.unknownDimensions.contains(.source) {
            return .unknown
        }
        if resolution.holdReasons.contains(.evidence) {
            return .hold
        }
        return .evidence
    }

    private static func shapeToken(for resolution: PEPPhenotypeResolution) -> PEPShapeToken {
        switch resolution.state {
        case .eligible:
            return .outlinedBoundary
        case .held:
            return .heldBoundary
        case .unknown:
            return .mutedPanel
        case .forbidden:
            return .outlinedBoundary
        }
    }

    private static func resolvedActionAffordance(for resolution: PEPPhenotypeResolution) -> PEPResolvedActionAffordance {
        guard resolution.state == .eligible,
              resolution.expressionBoundary.authorityStatus.decision == .pass,
              resolution.holdReasons.isEmpty else {
            return .none
        }

        switch resolution.surfaceExpression.interactionAffordance {
        case .actionRepresentable:
            return resolution.expressionBoundary.allowsInteractionAffordance ? .actionRepresentable : .inspectOnly
        case .correctable:
            return .correctionRepresentable
        case .inspectable:
            return .inspectOnly
        case .none, .unknown:
            return .none
        }
    }

    private static func lineageSummary(for resolution: PEPPhenotypeResolution) -> String {
        guard let grounding = resolution.projectionGrounding else {
            return "Lineage Unknown"
        }
        return "Object \(grounding.representedObject.objectID) projected as \(grounding.projectionIdentity.projectionID)"
    }

    private static func authoritySummary(for resolution: PEPPhenotypeResolution) -> String {
        "Authority \(resolution.expressionBoundary.authorityStatus.decision.rawValue)"
    }

    private static func unknownSummary(for resolution: PEPPhenotypeResolution) -> String {
        guard !resolution.unknownDimensions.isEmpty else { return "Unknown none" }
        return "Unknown " + resolution.unknownDimensions.map(\.rawValue).joined(separator: ", ")
    }

    private static func holdSummary(for resolution: PEPPhenotypeResolution) -> String {
        guard !resolution.holdReasons.isEmpty else { return "HOLD none" }
        return "HOLD " + resolution.holdReasons.map(\.rawValue).joined(separator: ", ")
    }
}
