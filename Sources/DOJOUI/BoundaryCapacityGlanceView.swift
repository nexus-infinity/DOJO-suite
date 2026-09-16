import SwiftUI
#if canImport(DOJOShared)
import DOJOShared
#endif

/// Read-only Boundary Capacity / Can Drive Now glance.
/// Reporting stubs only — does not probe Home, mutate authority, or seal AKRON.
public struct BoundaryCapacityGlanceView: View {
    public let snapshot: BoundaryCapacitySnapshot
    public let modeLabel: String
    /// Operator-facing next step only — not an authority mutation.
    public let nextLawfulMove: String?

    public init(
        snapshot: BoundaryCapacitySnapshot,
        modeLabel: String = "read-only stubs",
        nextLawfulMove: String? = nil
    ) {
        self.snapshot = snapshot
        self.modeLabel = modeLabel
        self.nextLawfulMove = nextLawfulMove
    }

    /// Simulator / cockpit default: all drive-critical pins unknown.
    public static func reportingStubGlance(
        queueDepth: Int = 0,
        modeLabel: String = "cockpit glance · reporting stubs",
        nextLawfulMove: String? = "HOLD: recheck when Home / Handoff / Ceiling are witnessed — no live probe this surface"
    ) -> BoundaryCapacityGlanceView {
        let home = HomeReachabilitySnapshot.contractStub
        let handoff = HandoffWitnessSnapshot.contractStub
        let ceiling = AuthorityCeilingSnapshot.reportingStub
        let snap = BoundaryCapacitySnapshot(
            homeReachable: home.homeReachable,
            queueDepth: queueDepth,
            lastReceiptID: nil,
            murmurPendingCount: nil,
            selectedInputSurface: SurfaceSelectionSnapshot.localIOSDefault.selectedInputSurface,
            selectedOutputSurface: SurfaceSelectionSnapshot.localIOSDefault.selectedOutputSurface,
            handoffAvailable: handoff.handoffAvailable,
            handoffReliability: handoff.handoffReliability,
            authorityCeiling: ceiling.authorityCeiling,
            holdReasons: [
                "HOLD.HomeProbeUnknown",
                "HOLD.HandoffWitnessUnknown",
                "HOLD.AuthorityCeilingUnknown",
                "HOLD.CanDriveNowUnknown"
            ],
            canDriveNow: .unknown
        )
        return BoundaryCapacityGlanceView(
            snapshot: snap,
            modeLabel: modeLabel,
            nextLawfulMove: nextLawfulMove
        )
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Boundary Capacity / Can Drive Now")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#E2E8F0"))
                Spacer()
                Text(modeLabel)
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: "#9CA3AF"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            HStack(spacing: 8) {
                statusChip(
                    "CAN DRIVE: \(snapshot.canDriveNow.rawValue.uppercased())",
                    statusColor(for: snapshot.canDriveNow)
                )
                statusChip(
                    "MUTATION: \(snapshot.authorityMutation.rawValue.uppercased())",
                    Color(hex: "#A78BFA")
                )
                statusChip("READ-ONLY", unknownColor)
            }

            VStack(alignment: .leading, spacing: 5) {
                capacityRow("canDriveNow", snapshot.canDriveNow.rawValue, statusColor(for: snapshot.canDriveNow))
                capacityRow("homeReachable", snapshot.homeReachable.rawValue, reachabilityColor(snapshot.homeReachable))
                capacityRow("queueDepth", "\(snapshot.queueDepth)", Color(hex: "#E2E8F0"))
                capacityRow(
                    "lastReceiptID",
                    snapshot.lastReceiptID ?? "unknown",
                    snapshot.lastReceiptID == nil ? unknownColor : Color(hex: "#A78BFA")
                )
                capacityRow(
                    "authorityCeiling",
                    snapshot.authorityCeiling?.rawValue ?? "unknown",
                    snapshot.authorityCeiling == nil ? unknownColor : Color(hex: "#F59E0B")
                )
            }

            if !snapshot.holdReasons.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("HOLD REASONS")
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color(hex: "#F43F5E"))
                    ForEach(snapshot.holdReasons, id: \.self) { reason in
                        Text(reason)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(Color(hex: "#FCA5A5"))
                            .lineLimit(2)
                    }
                }
            }

            if let next = nextLawfulMove, !next.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NEXT LAWFUL MOVE")
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color(hex: "#38BDF8"))
                    Text(next)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(Color(hex: "#BAE6FD"))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(12)
        .background(Color(hex: "#111113"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#27272A"), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Boundary capacity, read only. Can drive \(snapshot.canDriveNow.rawValue).")
    }

    private var unknownColor: Color { Color(hex: "#9CA3AF") }

    private func statusChip(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.system(size: 8, weight: .semibold, design: .monospaced))
            .foregroundStyle(color)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(color.opacity(0.13))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.35), lineWidth: 1))
            .lineLimit(1)
            .minimumScaleFactor(0.65)
    }

    private func capacityRow(_ label: String, _ value: String, _ valueColor: Color) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color(hex: "#6B7280"))
                .frame(width: 132, alignment: .leading)
            Text(value)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(valueColor)
                .lineLimit(2)
        }
    }

    private func reachabilityColor(_ value: BoundaryReachability) -> Color {
        switch value {
        case .yes: return Color(hex: "#22C55E")
        case .no: return Color(hex: "#F43F5E")
        case .unknown: return unknownColor
        }
    }

    private func statusColor(for value: BoundaryDriveReadiness) -> Color {
        switch value {
        case .yes: return Color(hex: "#22C55E")
        case .no: return Color(hex: "#F43F5E")
        case .degraded: return Color(hex: "#F59E0B")
        case .unknown: return unknownColor
        }
    }
}
