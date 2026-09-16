import SwiftUI
import DOJOShared
import DOJOUI

/// A human-facing manifestation surface for the investigation matrix.
///
/// This view is deliberately a projection: it makes the working shape visible
/// without becoming a source archive, provider control plane, or arbitration
/// authority. Live status must be re-witnessed at the named lawful home.
@available(macOS 14.0, *)
struct InvestigationDeskView: View {
    var askAbout: (String) -> Void = { _ in }
    var captureNote: () -> Void = {}
    var openInspector: () -> Void = {}

    @State private var selectedLane: DeskLane = .all
    @State private var selectedCardID: String?

    private let cards = InvestigationCard.seed

    private var visibleCards: [InvestigationCard] {
        guard selectedLane != .all else { return cards }
        return cards.filter { $0.lane == selectedLane }
    }

    private var selectedCard: InvestigationCard? {
        guard let selectedCardID else { return nil }
        return cards.first { $0.id == selectedCardID }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                authorityNotice
                knowledgeLanes
                surfaceTopology
                manifestationCapabilities
                lanePicker
                matrix

                if let selectedCard {
                    selectedCardPanel(selectedCard)
                }
            }
            .padding(28)
        }
        .background(Color(hex: "#021214").opacity(0.35))
        .onAppear {
            if selectedCardID == nil {
                selectedCardID = cards.first?.id
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Text("◼︎  INVESTIGATIONS")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .tracking(1.4)
                    .foregroundStyle(Chamber.dojo.color)

                Text("Manifestation Desk")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#EAFBFF"))

                Text("A single working surface for seeing the investigation shape without flattening the evidence.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#B7DEE5"))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 650, alignment: .leading)
            }

            Spacer(minLength: 20)

            VStack(alignment: .trailing, spacing: 6) {
                deskBadge("WORKING SURFACE", color: Chamber.dojo.color)
                Text("Snapshot · re-witness before action")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: "#89A8B1"))
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private var authorityNotice: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "eye.slash")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Chamber.atlas.color)

            VStack(alignment: .leading, spacing: 4) {
                Text("DOJO composes; it does not certify")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#EAFBFF"))
                Text("Each card keeps its native authority, representation, provenance, status, and next evidence. Notion, Gemini/Google Workspace, GitHub, and Vercel remain distinct surfaces.")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#A9BBC2"))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            deskBadge("PROMOTION CLOSED", color: Color(hex: "#A78BFA"))
        }
        .padding(14)
        .background(Color(hex: "#071D23"))
        .overlay {
            RoundedRectangle(cornerRadius: 9)
                .stroke(Color(hex: "#1C4B56"), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 9))
    }

    private var knowledgeLanes: some View {
        VStack(alignment: .leading, spacing: 9) {
            sectionLabel("KNOWLEDGE LANES")

            LazyVGrid(
                columns: [
                    GridItem(.flexible(minimum: 180), spacing: 10),
                    GridItem(.flexible(minimum: 180), spacing: 10),
                    GridItem(.flexible(minimum: 180), spacing: 10),
                    GridItem(.flexible(minimum: 180), spacing: 10)
                ],
                spacing: 10
            ) {
                ForEach(KnowledgeLane.allCases) { lane in
                    knowledgeLaneCard(lane)
                }
            }
        }
    }

    private func knowledgeLaneCard(_ lane: KnowledgeLane) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                Image(systemName: lane.icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(lane.color)
                Text(lane.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#EAFBFF"))
            }

            Text(lane.role)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#A9BBC2"))
                .lineLimit(3)

            Text(lane.status)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(0.7)
                .foregroundStyle(lane.color)
        }
        .padding(13)
        .frame(maxWidth: .infinity, minHeight: 105, alignment: .topLeading)
        .background(Color(hex: "#06191F"))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lane.color.opacity(0.42), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var surfaceTopology: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                sectionLabel("PHILHARMONIC SURFACE TOPOLOGY")
                Text("same genotype · distinct residence, state, and phenotype")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#89A8B1"))
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(minimum: 180), spacing: 10),
                    GridItem(.flexible(minimum: 180), spacing: 10),
                    GridItem(.flexible(minimum: 180), spacing: 10),
                    GridItem(.flexible(minimum: 180), spacing: 10)
                ],
                spacing: 10
            ) {
                ForEach(FieldSurfaceCoordinationCatalog.entries) { entry in
                    surfaceTopologyCard(entry)
                }
            }
        }
    }

    private func surfaceTopologyCard(_ entry: FieldSurfaceCoordinationEntry) -> some View {
        let stateColor = surfaceStateColor(entry.evidenceState)

        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: surfaceIcon(entry.role))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(stateColor)

                Text(entry.displayName)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#EAFBFF"))

                Spacer(minLength: 0)

                Text(entry.evidenceState.rawValue)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(0.5)
                    .foregroundStyle(stateColor)
            }

            Text(surfaceLabel(entry.plane.rawValue) + " · " + surfaceLabel(entry.role.rawValue))
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(stateColor)

            Text(entry.phenotype)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#A9BBC2"))
                .lineLimit(2)

            Text("Ceiling: \(entry.authorityCeiling)")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(Color(hex: "#89A8B1"))
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
        .background(Color(hex: "#06191F"))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(stateColor.opacity(0.38), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.displayName). \(surfaceLabel(entry.plane.rawValue)). \(surfaceLabel(entry.role.rawValue)). Evidence \(entry.evidenceState.rawValue). Authority ceiling \(entry.authorityCeiling).")
    }

    private var manifestationCapabilities: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                sectionLabel("MANIFESTATION ENVELOPES")
                Text("signal and receiver direction · live experience · held capability")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#89A8B1"))
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(minimum: 220), spacing: 10),
                    GridItem(.flexible(minimum: 220), spacing: 10),
                    GridItem(.flexible(minimum: 220), spacing: 10)
                ],
                spacing: 10
            ) {
                ForEach(FieldManifestationCapabilityCatalog.entries) { entry in
                    manifestationCapabilityCard(entry)
                }
            }
        }
    }

    private func manifestationCapabilityCard(_ entry: FieldManifestationCapabilityEntry) -> some View {
        let stateColor = surfaceStateColor(entry.evidenceState)
        let available = entry.availableFunctions.prefix(2).joined(separator: " · ")
        let held = entry.heldFunctions.prefix(2).joined(separator: " · ")

        return VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: manifestationIcon(entry.family))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(stateColor)

                Text(surfaceLabel(entry.surfaceID))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#EAFBFF"))

                Spacer(minLength: 0)

                Text(entry.liveExperience.rawValue)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(0.35)
                    .foregroundStyle(stateColor)
                    .multilineTextAlignment(.trailing)
            }

            Text(surfaceLabel(entry.family.rawValue) + " · " + surfaceLabel(entry.signalDirection.rawValue))
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(stateColor)

            Text("Observer: " + surfaceLabel(entry.observerRelationship.rawValue))
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#A9BBC2"))
                .lineLimit(2)

            Text("Available: " + (available.isEmpty ? "none witnessed" : available))
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#B7DEE5"))
                .lineLimit(2)

            Text("Held: " + (held.isEmpty ? "none stated" : held))
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#FBBF24"))
                .lineLimit(2)

            Text("Ceiling: \(entry.authorityCeiling)")
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundStyle(Color(hex: "#89A8B1"))
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 156, alignment: .topLeading)
        .background(Color(hex: "#06191F"))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(stateColor.opacity(0.32), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(surfaceLabel(entry.surfaceID)). Family \(surfaceLabel(entry.family.rawValue)). Signal direction \(surfaceLabel(entry.signalDirection.rawValue)). Live experience \(surfaceLabel(entry.liveExperience.rawValue)). Authority ceiling \(entry.authorityCeiling).")
    }

    private func manifestationIcon(_ family: FieldManifestationFamily) -> String {
        switch family {
        case .externalIntake: return "arrow.down.doc"
        case .externalMirror: return "arrow.left.arrow.right"
        case .internalRuntime: return "waveform.path.ecg"
        case .dojoSuite: return "square.grid.2x2"
        case .dojoToday: return "sun.max"
        case .deviceFeedback: return "waveform"
        }
    }

    private func surfaceLabel(_ rawValue: String) -> String {
        rawValue
            .replacingOccurrences(of: "_", with: " ")
            .lowercased()
            .capitalized
    }

    private func surfaceStateColor(_ state: FieldSurfaceEvidenceState) -> Color {
        switch state {
        case .witnessed: return Color(hex: "#86EFAC")
        case .partial: return Color(hex: "#FBBF24")
        case .unknown, .held: return Color(hex: "#F87171")
        }
    }

    private func surfaceIcon(_ role: FieldSurfaceRole) -> String {
        switch role {
        case .intentionCanon: return "note.text"
        case .coordination: return "rectangle.3.group"
        case .architectHandoff: return "arrow.triangle.branch"
        case .implementationLineage: return "chevron.left.forwardslash.chevron.right"
        case .sovereignMirror: return "folder"
        case .externalIntake: return "arrow.down.doc"
        case .internalObserver: return "eye"
        case .internalConductor: return "waveform.path.ecg"
        case .hostedPhenotype: return "cloud"
        case .visualPhenotype: return "paintpalette"
        case .deviceFeedback: return "waveform"
        }
    }

    private var lanePicker: some View {
        HStack(spacing: 7) {
            sectionLabel("MATRIX")
            Spacer()

            ForEach(DeskLane.allCases) { lane in
                Button {
                    withAnimation(.easeInOut(duration: 0.16)) {
                        selectedLane = lane
                    }
                } label: {
                    Text(lane.title)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(selectedLane == lane ? Color(hex: "#031416") : Color(hex: "#A9BBC2"))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(selectedLane == lane ? Color(hex: "#6CEBFF") : Color(hex: "#0A2A32"))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var matrix: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(minimum: 300), spacing: 12),
                GridItem(.flexible(minimum: 300), spacing: 12)
            ],
            spacing: 12
        ) {
            ForEach(visibleCards) { card in
                Button {
                    selectedCardID = card.id
                } label: {
                    matrixCard(card, selected: selectedCardID == card.id)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func matrixCard(_ card: InvestigationCard, selected: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 9) {
                Image(systemName: card.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(card.color)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 3) {
                    Text(card.title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#EAFBFF"))
                        .multilineTextAlignment(.leading)
                    Text(card.lane.title.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(0.7)
                        .foregroundStyle(card.color)
                }

                Spacer(minLength: 6)
                deskBadge(card.status, color: card.statusColor)
            }

            Divider().overlay(Color(hex: "#1C4B56"))
            cardRow("Native authority", card.nativeAuthority)
            cardRow("Representation", card.representation)
            cardRow("Next evidence", card.nextEvidence)
        }
        .padding(15)
        .frame(maxWidth: .infinity, minHeight: 214, alignment: .topLeading)
        .background(selected ? Color(hex: "#0A252D") : Color(hex: "#06191F"))
        .overlay {
            RoundedRectangle(cornerRadius: 9)
                .stroke(selected ? Color(hex: "#6CEBFF") : card.color.opacity(0.36), lineWidth: selected ? 1.5 : 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 9))
    }

    private func selectedCardPanel(_ card: InvestigationCard) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                sectionLabel("SELECTED OBJECT")
                Spacer()
                Text("DOJO VIEW · POINTER / INTERPRETATION")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(hex: "#6B8A93"))
            }

            Text(card.title)
                .font(.system(size: 19, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#EAFBFF"))

            Text(card.detail)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#B7DEE5"))
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 18) {
                detailColumn("Authority ceiling", card.ceiling)
                detailColumn("Current decision", card.status)
                detailColumn("Action obligation", card.action)
            }

            HStack(spacing: 9) {
                deskAction("Ask", systemImage: "paperplane") {
                    askAbout(card.title)
                }
                deskAction("Capture evidence", systemImage: "square.and.pencil") {
                    captureNote()
                }
                deskAction("Inspector", systemImage: "rectangle.and.text.magnifyingglass") {
                    openInspector()
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(hex: "#04181E"))
        .overlay {
            RoundedRectangle(cornerRadius: 9)
                .stroke(Color(hex: "#1C4B56"), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 9))
    }

    private func detailColumn(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .tracking(0.7)
                .foregroundStyle(Color(hex: "#6B8A93"))
            Text(value)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#D8EDF2"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func cardRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title.uppercased())
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .tracking(0.7)
                .foregroundStyle(Color(hex: "#6B8A93"))
            Text(value)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#C9E4EA"))
                .lineLimit(2)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .tracking(1.1)
            .foregroundStyle(Color(hex: "#89A8B1"))
    }

    private func deskAction(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#031416"))
                .padding(.horizontal, 10)
                .frame(height: 30)
                .background(Color(hex: "#6CEBFF"))
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
    }

    private func deskBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 8, weight: .bold, design: .monospaced))
            .tracking(0.6)
            .foregroundStyle(color)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

private enum DeskLane: String, CaseIterable, Identifiable {
    case all, investigations, representations

    var id: String { rawValue }
    var title: String {
        switch self {
        case .all: return "All"
        case .investigations: return "Investigations"
        case .representations: return "Representations"
        }
    }
}

private enum KnowledgeLane: String, CaseIterable, Identifiable {
    case notion, google, github, vercel

    var id: String { rawValue }
    var title: String {
        switch self {
        case .notion: return "Notion / Notorious"
        case .google: return "Gemini / Google"
        case .github: return "GitHub / local"
        case .vercel: return "Vercel / v0"
        }
    }
    var icon: String {
        switch self {
        case .notion: return "doc.richtext"
        case .google: return "text.book.closed"
        case .github: return "arrow.triangle.branch"
        case .vercel: return "cloud"
        }
    }
    var color: Color {
        switch self {
        case .notion: return Color(hex: "#F5D0A9")
        case .google: return Color(hex: "#93C5FD")
        case .github: return Color(hex: "#C4B5FD")
        case .vercel: return Color(hex: "#F0F9FF")
        }
    }
    var role: String {
        switch self {
        case .notion: return "Notorious benchmark, plans, decisions, pointers, and HOLDs"
        case .google: return "Historical evidence and working analysis"
        case .github: return "Implementation history and local code"
        case .vercel: return "Deployment / provider witness surface"
        }
    }
    var status: String {
        switch self {
        case .notion: return "BENCHMARK · REPRESENTATION"
        case .google: return "REPRESENTATION · DISTINCT"
        case .github: return "UNKNOWN / HOLD"
        case .vercel: return "PRESERVE / HOLD"
        }
    }
}

private struct InvestigationCard: Identifiable {
    let id: String
    let title: String
    let lane: DeskLane
    let icon: String
    let color: Color
    let status: String
    let statusColor: Color
    let nativeAuthority: String
    let representation: String
    let nextEvidence: String
    let ceiling: String
    let action: String
    let detail: String

    static let seed: [InvestigationCard] = [
        InvestigationCard(
            id: "backbone-2007",
            title: "2007 Strategic Backbone",
            lane: .investigations,
            icon: "clock.arrow.circlepath",
            color: Chamber.tata.color,
            status: "PROMOTE · HISTORICAL",
            statusColor: Color(hex: "#86EFAC"),
            nativeAuthority: "Berjak legacy source · exact source still to verify",
            representation: "Notion FRE Blueprint · Gemini historical proposals · GitHub ontology lineage",
            nextEvidence: "Verify the original source anchor",
            ceiling: "Historical anchor only; not executable authority",
            action: "PRESERVE",
            detail: "A useful historical spine for orientation, but it must not become the current runtime architecture without a fresh source witness."
        ),
        InvestigationCard(
            id: "call-file",
            title: "23-point Call File / CRM genotype",
            lane: .investigations,
            icon: "person.2.crop.square.stack",
            color: Chamber.atlas.color,
            status: "HOLD · SCHEMA / RUNTIME",
            statusColor: Color(hex: "#FBBF24"),
            nativeAuthority: "FRE ontology and original CRM exports",
            representation: "Notion CRM Card · Gemini event analysis / TPGM · ontology/ and lib/call-file/",
            nextEvidence: "Witness schema and runtime parity",
            ceiling: "Evaluation and alignment only",
            action: "HOLD WITH RECHECK",
            detail: "The representations are useful for comparison, but no one surface currently proves a live, governed CRM genotype."
        ),
        InvestigationCard(
            id: "trading",
            title: "Trading module",
            lane: .investigations,
            icon: "chart.xyaxis.line",
            color: Chamber.dojo.color,
            status: "HOLD · PARITY",
            statusColor: Color(hex: "#FBBF24"),
            nativeAuthority: "Live trading source and production connector",
            representation: "Blueprint and finance-drill references · local implementation remains planned",
            nextEvidence: "Production connector and exact runtime proof",
            ceiling: "No production claim",
            action: "HOLD WITH RECHECK",
            detail: "This is a manifestation candidate, not a live trading surface. Account, connector, and production actions remain outside this desk."
        ),
        InvestigationCard(
            id: "finance",
            title: "Finance / Matters records",
            lane: .investigations,
            icon: "building.columns",
            color: Chamber.tata.color,
            status: "HOLD · NO AUTHORITY",
            statusColor: Color(hex: "#F87171"),
            nativeAuthority: "Native financial and legal sources",
            representation: "Notion finance drill · Google Workspace evidence matrices · local RecordsModule",
            nextEvidence: "Named native records and connector boundary",
            ceiling: "No financial or legal authority",
            action: "PRESERVE",
            detail: "The desk can show where the records and evidence lanes are; it cannot adjudicate, submit, pay, cancel, or change them."
        ),
        InvestigationCard(
            id: "sailing",
            title: "Sailing chart",
            lane: .investigations,
            icon: "map",
            color: Chamber.obiwan.color,
            status: "HOLD · POINTER PROOF",
            statusColor: Color(hex: "#FBBF24"),
            nativeAuthority: "● OBI-WAN live chart",
            representation: "King's Chamber pointer and sailing registry · FRE stale assumptions",
            nextEvidence: "Prove the current pointer and chart home",
            ceiling: "Finding surface only; no SQLite movement",
            action: "HOLD WITH RECHECK",
            detail: "The visual relationship is useful, but a stale path or count must never be promoted through display."
        ),
        InvestigationCard(
            id: "workspace",
            title: "Google Workspace / Gemini lane",
            lane: .representations,
            icon: "folder.badge.gearshape",
            color: Color(hex: "#93C5FD"),
            status: "HOLD · CATALOGUE",
            statusColor: Color(hex: "#FBBF24"),
            nativeAuthority: "Google Workspace and Vault remain native",
            representation: "Gemini exports, telemetry cauldron, finance hinge folder, Drive evidence folders",
            nextEvidence: "Catalogue named folders and files before movement",
            ceiling: "Historical / analytical witness only",
            action: "PRESERVE",
            detail: "Gemini material can inform reconstruction and evidence lineage. It does not prove live ERP state or production parity."
        ),
        InvestigationCard(
            id: "notorious",
            title: "Notion / Notorious benchmark",
            lane: .representations,
            icon: "note.text",
            color: Color(hex: "#F5D0A9"),
            status: "BENCHMARK / DISTINCT",
            statusColor: Color(hex: "#93C5FD"),
            nativeAuthority: "Notion remains native to its planning and presentation home",
            representation: "Notorious Home / Drop Zone, Development Diary, named pages, and linked views",
            nextEvidence: "Retrieve named benchmark packets when the Notion lane is available",
            ceiling: "Benchmark and planning mirror; not execution authority",
            action: "PRESERVE",
            detail: "Notorious is a useful benchmark for retrieval, continuity, and planning. DOJO can exceed it as a visual manifestation surface without becoming Notion or absorbing Notion authority."
        ),
        InvestigationCard(
            id: "github",
            title: "GitHub / local implementation",
            lane: .representations,
            icon: "chevron.left.forwardslash.chevron.right",
            color: Color(hex: "#C4B5FD"),
            status: "UNKNOWN / HOLD",
            statusColor: Color(hex: "#F87171"),
            nativeAuthority: "Local implementation repository and remote GitHub history",
            representation: "Local branch, worktree, commit history, and source files",
            nextEvidence: "Read-only live refs, divergence, and uncommitted diff",
            ceiling: "Implementation evidence; not live alignment proof",
            action: "HOLD WITH RECHECK",
            detail: "The local code can be inspected here, but remote alignment remains Unknown until a fresh, read-only ref comparison succeeds."
        ),
        InvestigationCard(
            id: "vercel",
            title: "Vercel / v0 surfaces",
            lane: .representations,
            icon: "cloud",
            color: Color(hex: "#F0F9FF"),
            status: "PRESERVE / HOLD",
            statusColor: Color(hex: "#FBBF24"),
            nativeAuthority: "Vercel account, project, deployment, and billing surfaces",
            representation: "Provider dashboard, v0 project/deployment views, local receipts, and screenshots",
            nextEvidence: "Re-witness the exact provider/project row before any action",
            ceiling: "Deployment and provider witness only",
            action: "PRESERVE",
            detail: "This card gives Vercel a visible place in the investigation map while keeping deployment, DNS, billing, refunds, and account changes outside the desk."
        )
    ]
}
