import SwiftUI
import DOJOShared

// MARK: - DOJO Cockpit v0
// 3×3 ParticleBoard grid bound to ParticleBoardController.
// Governance: RealityAnchor -> O/I/R -> Triangle -> HOLD/GO -> Seat.

@MainActor
public struct ParticleBoardView: View {
    @State private var controller: ParticleBoardController
    @ObservedObject private var coordinator: DOJOFieldCoordinator

    @State private var editingCell: GridAddress? = nil
    @State private var editContent: String = ""
    @State private var editClaimClass: ClaimClass = .observed
    @State private var editTriangleResolved = true
    @State private var holdErrors: [GridAddress: String] = [:]
    @FocusState private var editorFocused: Bool
    private let wp07Target = GridAddress(row: 2, col: 2)!

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    public init(controller: ParticleBoardController, coordinator: DOJOFieldCoordinator) {
        self._controller = State(initialValue: controller)
        self.coordinator = coordinator
    }

    public var body: some View {
        VStack(spacing: 0) {
            halStatusBar
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(FieldPalette.surface)
                .overlay(alignment: .bottom) {
                    Rectangle().fill(FieldPalette.border).frame(height: 1)
                }

            ScrollView {
                VStack(spacing: 20) {
                    gridSection
                    aikidoOpticsProjectSection
                    if let address = editingCell {
                        editorPanel(for: address)
                    }
                    if let forecast = controller.pendingForecast {
                        forecastPanel(forecast)
                    }
                    carPlayDOJOSection
                    landscapePlaceSection
                }
                .padding(16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FieldPalette.void.ignoresSafeArea())
    }

    private var aikidoOpticsProjectSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AIKIDO OPTICS PROJECT")
                .font(.caption.monospaced().bold())
                .foregroundStyle(FieldPalette.textMuted)

            AikidoOpticsProjectCard(
                projection: AikidoOpticsProjectRegistration.current.particleBoardCard
            )
        }
    }

    // MARK: - HAL Status Bar

    private var halStatusBar: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(verdictColor)
                .frame(width: 6, height: 6)
                .shadow(color: verdictColor.opacity(0.8), radius: 4)
            Text(coordinator.keeperVerdict.summary)
                .foregroundStyle(verdictColor)
            Spacer()
            Text("\(coordinator.audioMode.rawValue) · \(coordinator.activeProfile.rawValue)")
                .foregroundStyle(FieldPalette.textDim)
        }
        .font(.caption.monospaced())
    }

    private var verdictColor: Color {
        switch coordinator.keeperVerdict.state {
        case .aligned:  return Chamber.atlas.color
        case .degraded: return Chamber.tata.color
        case .hold:     return Color(hex: "#F43F5E")
        }
    }

    // MARK: - Grid

    private var gridSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("◼︎ PARTICLE BOARD")
                .font(.caption.monospaced().bold())
                .foregroundStyle(FieldPalette.textMuted)

            if let state = controller.committedState {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(0..<9, id: \.self) { idx in
                        let r = idx / 3, c = idx % 3
                        if let address = GridAddress(row: r, col: c),
                           let cell = state.cell(at: address) {
                            cellView(cell)
                        }
                    }
                }
            } else {
                Text("No state loaded — load a DocumentPlan to begin.")
                    .font(.caption.monospaced())
                    .foregroundStyle(FieldPalette.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(32)
            }
        }
    }

    // MARK: - Cell View

    private func cellView(_ cell: BoardCell) -> some View {
        let hasHold = holdErrors[cell.address] != nil
        let isWP07Target = cell.address == wp07Target
        let isEditing = editingCell == cell.address
        return Button {
            beginEditing(cell)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("[\(cell.row),\(cell.col)]")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(FieldPalette.textDim)
                    if isWP07Target {
                        Text("WP07 TARGET")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundStyle(Chamber.tata.color)
                    }
                    Spacer()
                    Text(CellKind.from(row: cell.row).rawValue)
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundStyle(FieldPalette.textDim)
                }
                switch cell.payload {
                case .route(let intent, let action):
                    Text(intent.uppercased())
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .foregroundStyle(payloadColor(cell.payload))
                    Text(action)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(FieldPalette.textPrimary)
                        .lineLimit(4)
                        .truncationMode(.tail)
                case .empty:
                    Spacer(minLength: 0)
                    HStack {
                        Spacer()
                        Text("·")
                            .font(.title3)
                            .foregroundStyle(payloadColor(cell.payload))
                        Spacer()
                    }
                    Spacer(minLength: 0)
                case .unknown(let raw):
                    Text("?")
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .foregroundStyle(payloadColor(cell.payload))
                    Text(raw)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(payloadColor(cell.payload))
                        .lineLimit(3)
                }
                HStack {
                    Text(Phase.from(col: cell.col).rawValue)
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundStyle(FieldPalette.textDim)
                    Spacer()
                }
                if let msg = holdErrors[cell.address] {
                    Text(msg)
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundStyle(Color(hex: "#F43F5E"))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(8)
            .background(cellBackground(cell))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        hasHold ? Color(hex: "#F43F5E") : (isEditing ? Chamber.dojo.color : (isWP07Target ? Chamber.tata.color : cellBorderColor(cell.payload))),
                        lineWidth: hasHold ? 2 : (isEditing || isWP07Target ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func cellBackground(_ cell: BoardCell) -> Color {
        if let hex = cell.channels?.color { return Color(hex: hex).opacity(0.12) }
        switch cell.payload {
        case .empty:   return FieldPalette.surfaceRaised
        case .route:   return Chamber.dojo.color.opacity(0.08)
        case .unknown: return Color(hex: "#F43F5E").opacity(0.05)
        }
    }

    private func payloadColor(_ payload: BoardPayload) -> Color {
        switch payload {
        case .empty:   return FieldPalette.textDim
        case .route:   return Chamber.dojo.color
        case .unknown: return Color(hex: "#F43F5E")
        }
    }

    private func cellBorderColor(_ payload: BoardPayload) -> Color {
        switch payload {
        case .empty:   return FieldPalette.border
        case .route:   return Chamber.dojo.color.opacity(0.4)
        case .unknown: return Color(hex: "#F43F5E").opacity(0.4)
        }
    }

    // MARK: - Forecast Panel

    private func editorPanel(for address: GridAddress) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("EDIT CELL [\(address.row),\(address.col)]")
                    .font(.caption.monospaced().bold())
                    .foregroundStyle(Chamber.tata.color)
                Spacer()
                if address == wp07Target {
                    Text("Governor-visible witness editor")
                        .font(.caption2.monospaced())
                        .foregroundStyle(FieldPalette.textDim)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("O / I / R CLASS")
                    .font(.caption.monospaced())
                    .foregroundStyle(FieldPalette.textMuted)
                Picker("Claim Class", selection: $editClaimClass) {
                    ForEach(ClaimClass.allCases, id: \.self) { claimClass in
                        Text(claimClass.rawValue).tag(claimClass)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("CONTENT")
                    .font(.caption.monospaced())
                    .foregroundStyle(FieldPalette.textMuted)
                TextField("Enter cell content", text: $editContent)
                    .textFieldStyle(.roundedBorder)
                    .font(.body.monospaced())
                    .focused($editorFocused)
            }

            Toggle("Triangle Resolved", isOn: $editTriangleResolved)
                .font(.body.monospaced())
                .foregroundStyle(FieldPalette.textPrimary)
                .tint(Chamber.atlas.color)

            HStack(spacing: 12) {
                Button("Cancel") {
                    cancelEditing()
                }
                .buttonStyle(FieldButtonStyle(tint: FieldPalette.border))

                Button("Propose Edit") {
                    commitInlineEdit(for: address)
                }
                .buttonStyle(FieldButtonStyle())
                .disabled(editContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(14)
        .background(FieldPalette.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8).stroke(FieldPalette.border, lineWidth: 1)
        )
    }

    private var particleGrammarSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Particle Grammar v0 — visual codec")
                .font(.caption.monospaced().bold())
                .foregroundStyle(FieldPalette.textMuted)

            ParticleGrammarDemoView(tokens: ParticleGrammarV0.previewTokens)
        }
    }

    private var nigeriaRehearsalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FIELD Engagement v0 — Nigeria Rehearsal")
                .font(.caption.monospaced().bold())
                .foregroundStyle(FieldPalette.textMuted)

            NigeriaRehearsalCard()
        }
    }

    private var storyWheelSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FIELD STORY WHEEL")
                .font(.caption.monospaced().bold())
                .foregroundStyle(FieldPalette.textMuted)

            StoryWheelSignalCard()
        }
    }

    private var audioPEPSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AUDIO SURFACE PEP TEST")
                .font(.caption.monospaced().bold())
                .foregroundStyle(FieldPalette.textMuted)

            AudioSurfacePEPCard()
        }
    }

    private var llmEcosystemSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LLM ECOSYSTEM CHANNEL")
                .font(.caption.monospaced().bold())
                .foregroundStyle(FieldPalette.textMuted)

            LLMEcosystemChannelCard()
        }
    }

    private var llmAudioLinkSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LLM ECOSYSTEM AUDIO LINK")
                .font(.caption.monospaced().bold())
                .foregroundStyle(FieldPalette.textMuted)

            LLMEcosystemAudioLinkCard()
        }
    }

    private var photoImageSurfaceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PHOTO / IMAGE SURFACE CHANNEL")
                .font(.caption.monospaced().bold())
                .foregroundStyle(FieldPalette.textMuted)

            PhotoImageSurfaceChannelCard()
        }
    }

    private var geometricCherryPickSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GEOMETRIC CHERRY PICK")
                .font(.caption.monospaced().bold())
                .foregroundStyle(FieldPalette.textMuted)

            GeometricCherryPickCard()
        }
    }

    private var carPlayDOJOSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CARPLAY DOJO CHANNEL")
                .font(.caption.monospaced().bold())
                .foregroundStyle(FieldPalette.textMuted)

            CarPlayDOJOChannelCard()
        }
    }

    private var landscapePlaceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LANDSCAPE / PLACE CHANNEL")
                .font(.caption.monospaced().bold())
                .foregroundStyle(FieldPalette.textMuted)

            LandscapePlaceChannelCard()
        }
    }

    private var appleTVSurfacePULSESection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("APPLE TV SURFACE PULSE CHANNEL")
                .font(.caption.monospaced().bold())
                .foregroundStyle(FieldPalette.textMuted)

            AppleTVSurfacePULSEChannelCard()
        }
    }

    private func forecastPanel(_ forecast: Forecast) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("PENDING FORECAST")
                    .font(.caption.monospaced().bold())
                    .foregroundStyle(FieldPalette.textMuted)
                Spacer()
                Text(String(format: "risk: %.2f", forecast.riskScore))
                    .font(.caption2.monospaced())
                    .foregroundStyle(FieldPalette.textDim)
            }
            if !forecast.diff.isEmpty {
                Text(forecast.diff)
                    .font(.caption2.monospaced())
                    .foregroundStyle(FieldPalette.textDim)
            }
            HStack(spacing: 12) {
                Button("Accept") {
                    do {
                        try controller.acceptForecast()
                        holdErrors = [:]
                        editingCell = nil
                    } catch ParticleBoardError.acceptBlockedByPolicy(let reasons) {
                        holdErrors = [:]
                        for reason in reasons {
                            holdErrors[reason.address] = reason.detail
                        }
                    } catch {
                        print("◆ Unexpected accept error: \(error)")
                    }
                }
                .buttonStyle(FieldButtonStyle())

                Button("Reject") {
                    controller.rejectForecast()
                    holdErrors = [:]
                }
                .buttonStyle(FieldButtonStyle(tint: Color(hex: "#F43F5E")))
            }
        }
        .padding(14)
        .background(FieldPalette.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8).stroke(FieldPalette.border, lineWidth: 1)
        )
    }

    private func beginEditing(_ cell: BoardCell) {
        editingCell = cell.address
        holdErrors[cell.address] = nil
        switch cell.payload {
        case .route(let intent, let action):
            editContent = action
            editClaimClass = ClaimClass(rawValue: intent) ?? .observed
        case .empty:
            editContent = ""
            editClaimClass = .observed
        case .unknown(let raw):
            editContent = raw
            editClaimClass = .observed
        }
        editTriangleResolved = true
        DispatchQueue.main.async {
            editorFocused = true
        }
    }

    private func cancelEditing() {
        editingCell = nil
        editContent = ""
        editClaimClass = .observed
        editTriangleResolved = true
        editorFocused = false
    }

    private func commitInlineEdit(for address: GridAddress) {
        let trimmed = editContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let anchor = RealityAnchor(
            hashSHA256: CockpitReceiptStore.sha256(
                from: trimmed,
                editClaimClass.rawValue,
                editTriangleResolved ? "resolved" : "unresolved"
            ),
            storageLocation: "cell[\(address.row),\(address.col)]"
        )
        let triangle: TriangleStatus = editTriangleResolved
            ? .resolved
            : .unresolved(missingSides: [.document], acknowledgedGap: true)
        let artifact = FieldArtifact(
            anchor: anchor,
            claimClass: editClaimClass,
            triangle: triangle,
            content: trimmed
        )
        let payload = BoardPayload.route(
            intent: artifact.claimClass.rawValue,
            action: artifact.content
        )
        controller.proposeEdit(row: address.row, col: address.col, payload: payload)
        editorFocused = false
    }

}

private struct AikidoOpticsProjectCard: View {
    let projection: AikidoOpticsProjectCardProjection

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(projection.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(FieldPalette.textPrimary)
                    Text(projection.relationshipLabel)
                        .font(.caption.monospaced())
                        .foregroundStyle(Chamber.dojo.color)
                }
                Spacer()
                Text("HOLD · registration only")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(hex: ParticleStateColor.hold.hex))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color(hex: ParticleStateColor.hold.hex).opacity(0.10))
                    .clipShape(Capsule())
            }

            relationshipRow(
                label: "PARENT",
                value: "\(projection.parentLabel)  →  \(projection.parentProjectID)"
            )

            scopeGroup(
                title: projection.scopeLabel,
                values: projection.ownedScope,
                tint: Chamber.dojo.color
            )

            scopeGroup(
                title: projection.nonOwnershipLabel,
                values: projection.nonOwnedScope,
                tint: Color(hex: ParticleStateColor.hold.hex)
            )

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                relationshipRow(label: "STATE", value: projection.statusLabel)
                Spacer(minLength: 8)
                relationshipRow(label: "CEILING", value: projection.authorityLabel)
            }
        }
        .padding(14)
        .background(FieldPalette.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Chamber.dojo.color.opacity(0.35), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Aikido Optics project card")
    }

    private func scopeGroup(title: String, values: [String], tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(tint)
            FlowLayout(spacing: 6) {
                ForEach(values, id: \.self) { value in
                    Text(value.replacingOccurrences(of: "_", with: " "))
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(FieldPalette.textMuted)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 5)
                        .background(tint.opacity(0.08))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(tint.opacity(0.24), lineWidth: 1))
                }
            }
        }
    }

    private func relationshipRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(FieldPalette.textDim)
            Text(value)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(FieldPalette.textMuted)
        }
    }
}

private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        layout(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, point) in result.points.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, points: [CGPoint]) {
        let availableWidth = proposal.width ?? .infinity
        var points: [CGPoint] = []
        var cursor = CGPoint.zero
        var rowHeight: CGFloat = 0
        var usedWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if cursor.x > 0, cursor.x + size.width > availableWidth {
                cursor.x = 0
                cursor.y += rowHeight + spacing
                rowHeight = 0
            }
            points.append(cursor)
            cursor.x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            usedWidth = max(usedWidth, cursor.x - spacing)
        }

        return (
            CGSize(width: min(availableWidth, usedWidth), height: cursor.y + rowHeight),
            points
        )
    }
}

// MARK: - Particle Grammar v0 Demo

private struct ParticleGrammarDemoView: View {
    let tokens: [ParticleGrammarV0]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(tokens) { token in
                    ParticleGrammarCell(token: token)
                }
            }

            Text("Star: HOLD — not sourced in v0")
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color(hex: ParticleStateColor.hold.hex))
        }
        .padding(10)
        .background(FieldPalette.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(FieldPalette.border, lineWidth: 1)
        )
    }
}

private struct ParticleGrammarCell: View {
    let token: ParticleGrammarV0

    var body: some View {
        VStack(spacing: 6) {
            particleShape
                .frame(width: 30, height: 30)
                .frame(maxWidth: .infinity)

            Text(token.fill.rawValue)
                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                .foregroundStyle(FieldPalette.textMuted)

            Text(token.label)
                .font(.system(size: 7, design: .monospaced))
                .foregroundStyle(FieldPalette.textDim)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(8)
        .frame(minHeight: 82)
        .background(FieldPalette.void.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    @ViewBuilder
    private var particleShape: some View {
        switch token.shape {
        case .circle:
            if token.fill == .solid {
                Circle().fill(color)
            } else {
                Circle().stroke(color, lineWidth: 2)
            }
        case .triangle:
            if token.fill == .solid {
                TriangleParticle().fill(color)
            } else {
                TriangleParticle().stroke(color, lineWidth: 2)
            }
        case .square:
            if token.fill == .solid {
                Rectangle().fill(color)
            } else {
                Rectangle().stroke(color, lineWidth: 2)
            }
        case .diamond:
            if token.fill == .solid {
                DiamondParticle().fill(color)
            } else {
                DiamondParticle().stroke(color, lineWidth: 2)
            }
        }
    }

    private var color: Color {
        Color(hex: token.color.rawValue)
    }
}

private struct TriangleParticle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct DiamondParticle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Nigeria "Do This Here" Rehearsal

private struct NigeriaRehearsalCard: View {
    private let phases = [
        "Read Field",
        "Establish Base",
        "Release Assumption",
        "Enter Clean Turn",
        "Regulate Load",
        "Finish Balanced",
        "Re-enter Stronger"
    ]
    private let currentPhase = "Establish Base"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Agriculture pilot")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(FieldPalette.textPrimary)
                    Text("Place/object: Nigeria pilot plot placeholder")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(FieldPalette.textMuted)
                }
                Spacer()
                Text("placeholder")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(FieldPalette.textDim)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(FieldPalette.void.opacity(0.6))
                    .clipShape(Capsule())
            }

            phaseRail

            HStack(spacing: 10) {
                DiamondParticle()
                    .fill(Chamber.arkadas.color.opacity(0.9))
                    .frame(width: 22, height: 22)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Do this here")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(FieldPalette.textPrimary)
                    Text("Test soil here before choosing the pilot crop.")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(FieldPalette.textMuted)
                        .lineLimit(2)
                }
            }
            .padding(10)
            .background(Chamber.arkadas.color.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Chamber.arkadas.color.opacity(0.35), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 4) {
                labelRow("current phase", currentPhase)
                labelRow("next action", "Confirm authority/site data before soil test / site action.")
                labelRow("HOLD", "HOLD — authority/site data missing")
                labelRow("note", "Preparation is not procrastination when it creates clean movement.")
            }
        }
        .padding(12)
        .background(FieldPalette.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: ParticleStateColor.hold.hex).opacity(0.35), lineWidth: 1)
        )
    }

    private var phaseRail: some View {
        HStack(spacing: 4) {
            ForEach(phases, id: \.self) { phase in
                VStack(spacing: 3) {
                    Capsule()
                        .fill(phase == currentPhase ? Chamber.arkadas.color : FieldPalette.border)
                        .frame(height: 4)
                    Text(phase)
                        .font(.system(size: 7, design: .monospaced))
                        .foregroundStyle(phase == currentPhase ? Chamber.arkadas.color : FieldPalette.textDim)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }
        }
    }

    private func labelRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                .foregroundStyle(FieldPalette.textDim)
                .frame(width: 92, alignment: .leading)
            Text(value)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(label == "HOLD" ? Color(hex: ParticleStateColor.hold.hex) : FieldPalette.textMuted)
                .lineLimit(2)
        }
    }
}

// MARK: - Recursive Story Wheel Signal

private struct StoryWheelSignalCard: View {
    private let phases = [
        "Ground",
        "Disturbance",
        "Orientation",
        "Crossing",
        "Trial",
        "Crystallisation",
        "Return",
        "Re-entry"
    ]
    private let currentPhase = "Orientation"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("FIELD Story Wheel v0")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(FieldPalette.textPrimary)
                Spacer()
                Text("local signal")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(FieldPalette.textDim)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(FieldPalette.void.opacity(0.6))
                    .clipShape(Capsule())
            }

            storySpiral

            VStack(alignment: .leading, spacing: 6) {
                narrativeLane("human lane", "fear -> beauty -> witness -> dream", Chamber.dojo.color)
                narrativeLane("system lane", "purpose -> field engagement -> boundary -> receipt", Chamber.arkadas.color)
            }

            HStack(spacing: 8) {
                DiamondParticle()
                    .fill(Chamber.arkadas.color.opacity(0.9))
                    .frame(width: 18, height: 18)
                Text("What is the next clean move?")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(FieldPalette.textPrimary)
            }
            .padding(10)
            .background(Chamber.arkadas.color.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Chamber.arkadas.color.opacity(0.35), lineWidth: 1)
            )

            Text("return becomes new ground")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(FieldPalette.textMuted)
        }
        .padding(12)
        .background(FieldPalette.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(FieldPalette.border, lineWidth: 1)
        )
    }

    private var storySpiral: some View {
        ZStack {
            ForEach(Array(phases.enumerated()), id: \.offset) { index, phase in
                let isCurrent = phase == currentPhase
                let angle = Double(index) / Double(phases.count) * .pi * 1.72 - .pi * 0.82
                let radius = 22.0 + Double(index) * 5.0
                let x = cos(angle) * radius
                let y = sin(angle) * radius

                VStack(spacing: 3) {
                    Circle()
                        .fill(isCurrent ? Chamber.arkadas.color : FieldPalette.border)
                        .frame(width: isCurrent ? 11 : 7, height: isCurrent ? 11 : 7)
                    Text(phase)
                        .font(.system(size: 7, weight: isCurrent ? .bold : .regular, design: .monospaced))
                        .foregroundStyle(isCurrent ? Chamber.arkadas.color : FieldPalette.textDim)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                }
                .frame(width: 78)
                .offset(x: x, y: y)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 154)
        .background(FieldPalette.void.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func narrativeLane(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                .foregroundStyle(color)
                .frame(width: 82, alignment: .leading)
            Text(value)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(FieldPalette.textMuted)
                .lineLimit(2)
        }
    }
}

// MARK: - Audio Surface PEP Test

private struct AudioSurfacePEPCard: View {
    private let rows = [
        ("device / surface", "Hybrid open-ear test surface"),
        ("surface class", "hybrid"),
        ("test context", "quiet room / home movement / car / farm / call / voice note / AI conversation / long wear"),
        ("organic read", "comfort / fatigue / awareness preserved"),
        ("digital read", "mic quality / transcript / latency / battery"),
        ("boundary read", "local-first / cloud / permissions / stop capture"),
        ("environment read", "wind / noise / shared space / awareness"),
        ("result", "HELD — promotion evidence missing")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Audio Surface PEP Test v0")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(FieldPalette.textPrimary)
                Spacer()
                Text("CHANNEL-HELD")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(FieldPalette.textDim)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(FieldPalette.void.opacity(0.6))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 5) {
                ForEach(rows, id: \.0) { label, value in
                    pepRow(label, value)
                }
            }

            Text("Audio surfaces promote by lived fit, not feature list.")
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(Chamber.arkadas.color)

            Text("This surface reserves the audio channel without claiming a working device, service, sensor, capture path, or authority.")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(FieldPalette.textMuted)

            Text("Promotion requires: evidence + consent + boundary + purpose + lived fit")
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color(hex: ParticleStateColor.hold.hex))
        }
        .padding(12)
        .background(FieldPalette.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: ParticleStateColor.hold.hex).opacity(0.35), lineWidth: 1)
        )
    }

    private func pepRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                .foregroundStyle(FieldPalette.textDim)
                .frame(width: 112, alignment: .leading)
            Text(value)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(label == "result" ? Color(hex: ParticleStateColor.hold.hex) : FieldPalette.textMuted)
                .lineLimit(3)
        }
    }
}

// MARK: - LLM Ecosystem Channel

private struct LLMEcosystemChannelCard: View {
    private let rows = [
        ("state", "CHANNEL-HELD"),
        ("status", "HELD — model authority not promoted"),
        ("rule", "Model != authority"),
        ("allowed roles", "ASR / transcription / local resident DOJO / external LLM guest / specialist model / chamber-aligned model"),
        ("promotion requires", "purpose + evidence + consent + boundary + lived fit + output labelling"),
        ("HOLD", "HOLD — model identity mistaken for truth")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("LLM Ecosystem Channel")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(FieldPalette.textPrimary)
                Spacer()
                Text("CHANNEL-HELD")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(FieldPalette.textDim)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(FieldPalette.void.opacity(0.6))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 5) {
                ForEach(rows, id: \.0) { label, value in
                    llmRow(label, value)
                }
            }

            Text("This surface reserves the LLM ecosystem channel without claiming a working model route, ASR path, API call, chamber authority, or decision engine.")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(FieldPalette.textMuted)
        }
        .padding(12)
        .background(FieldPalette.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: ParticleStateColor.hold.hex).opacity(0.35), lineWidth: 1)
        )
    }

    private func llmRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                .foregroundStyle(FieldPalette.textDim)
                .frame(width: 126, alignment: .leading)
            Text(value)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(label == "HOLD" ? Color(hex: ParticleStateColor.hold.hex) : FieldPalette.textMuted)
                .lineLimit(3)
        }
    }
}

// MARK: - LLM Ecosystem Audio Link

private struct LLMEcosystemAudioLinkCard: View {
    private let rows = [
        ("Audio PEP result ref", "AUDIO-PEP-LOCAL-001 / undated local rehearsal"),
        ("Organic present?", "Y — lived witness required before comfort scoring"),
        ("Digital path", "ASR? none / local DOJO? none"),
        ("Labels used", "PROBABLE.transcript / ORGANIC.witness"),
        ("Who may score comfort?", "Organic only"),
        ("Who may draft Result?", "Candidate model / human only"),
        ("Who decides Result?", "Arbiter / JB only"),
        ("Guest LLM used?", "N — if Y: guest, not owner"),
        ("AKRON touched?", "none / explicit promote only")
    ]

    private let holdTriggers = [
        "Model-as-authority",
        "Transcript-as-truth",
        "Comfort inference",
        "Guest-as-owner",
        "Default AKRON",
        "medical",
        "device=self"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("LLM Ecosystem Audio Link v0")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(FieldPalette.textPrimary)
                Spacer()
                Text("CHANNEL-HELD")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(FieldPalette.textDim)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(FieldPalette.void.opacity(0.6))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 5) {
                linkRow("state", "CHANNEL-HELD")
                linkRow("status", "HELD — no model route promoted")
                linkRow("contract", "docs/LLM_ECOSYSTEM_CONSIDERATION_MATRIX_V0.md")
                ForEach(rows, id: \.0) { label, value in
                    linkRow(label, value)
                }
            }

            Text("Candidates implement. Contracts govern. Witness decides. Guests advise.")
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(Chamber.arkadas.color)

            VStack(alignment: .leading, spacing: 5) {
                Text("HOLD TRIGGERS HIT")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: ParticleStateColor.hold.hex))
                ForEach(holdTriggers, id: \.self) { trigger in
                    HStack(spacing: 6) {
                        Circle()
                            .stroke(Color(hex: ParticleStateColor.hold.hex), lineWidth: 1)
                            .frame(width: 7, height: 7)
                        Text(trigger)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(FieldPalette.textMuted)
                    }
                }
            }

            Text("This card links audio participation to possible model roles without claiming ASR, local inference, external API routing, chamber authority, or automatic decision closure.")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(FieldPalette.textMuted)
        }
        .padding(12)
        .background(FieldPalette.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: ParticleStateColor.hold.hex).opacity(0.35), lineWidth: 1)
        )
    }

    private func linkRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                .foregroundStyle(FieldPalette.textDim)
                .frame(width: 132, alignment: .leading)
            Text(value)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(label == "status" ? Color(hex: ParticleStateColor.hold.hex) : FieldPalette.textMuted)
                .lineLimit(3)
        }
    }
}

// MARK: - Photo / Image Surface Channel

private struct PhotoImageSurfaceChannelCard: View {
    private let rows = [
        ("channel", "photo / image surface"),
        ("state", "CHANNEL-HELD"),
        ("status", "HELD — no image capture or generation promoted"),
        ("allowed future sources", "camera capture / selected image / generated image / scanned document/image / external visual reference"),
        ("promotion requires", "evidence + consent + boundary + purpose + source label + lived fit"),
        ("source label required", "CAPTURED / SELECTED / GENERATED / SCANNED / EXTERNAL / UNKNOWN"),
        ("HOLD", "HOLD — source/evidence missing"),
        ("rule", "Image surface != captured/generated image")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Photo / Image Surface Channel v0")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(FieldPalette.textPrimary)
                Spacer()
                Text("CHANNEL-HELD")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(FieldPalette.textDim)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(FieldPalette.void.opacity(0.6))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 5) {
                ForEach(rows, id: \.0) { label, value in
                    imageRow(label, value)
                }
            }

            Text("This surface reserves the photo/image channel without claiming a working camera path, image generation route, photo library access, vision model, or external service.")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(FieldPalette.textMuted)
        }
        .padding(12)
        .background(FieldPalette.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: ParticleStateColor.hold.hex).opacity(0.35), lineWidth: 1)
        )
    }

    private func imageRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                .foregroundStyle(FieldPalette.textDim)
                .frame(width: 136, alignment: .leading)
            Text(value)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle((label == "status" || label == "HOLD") ? Color(hex: ParticleStateColor.hold.hex) : FieldPalette.textMuted)
                .lineLimit(3)
        }
    }
}

// MARK: - Geometric Cherry Pick

private struct GeometricCherryPickCard: View {
    /// One named hole only: ● OBI-WAN observed-only candidate DNA.
    /// Morphosis pre-candidate / ARCHIVE — no load, no Ollama, no chamber PROMOTE.
    private let rows = [
        ("candidate", "★ EDGDAD12a / eddad3ba crown"),
        ("Morphosis stage", "pre-candidate · archaeology / ARCHIVE.only"),
        ("named hole", "● OBI-WAN — observed-only candidate DNA (one hole)"),
        ("state", "CANDIDATE.observed_dna"),
        ("verdict", "ARCHIVE.only + CANDIDATE.observed_dna · no chamber PROMOTE"),
        ("Axis A — Discovery", "jbear ▲ATLAS/⬢_models/★ → Akron hexagon dump (archaeology)"),
        ("Axis B — Placement", "this hole only; ATLAS-by-path HOLD.Wrong.Slot; ASR HOLD.Wrong.Slot"),
        ("Axis C — Residence", "DNA: ●OBI-WAN/◎models/edgdad12a · weights: Akron archive"),
        ("RESIDENCE.LOCKED", "NONE — do not bind Ollama/MLX until lock written"),
        ("runtime bind", "none (guest engines must not home)"),
        ("Q observed-only?", "UNKNOWN — suite not run; DNA claims only"),
        ("Q obs≠interp?", "UNKNOWN — no contract suite receipt"),
        ("Q House budget?", "PASS for DNA-only; FAIL if full 4.7G hot-load without plan"),
        ("P0 Morphosis", "no model shopping · no ollama pull as step zero"),
        ("P1 hole named", "● OBI-WAN observed-only"),
        ("P2 questions", "chamber contract bank + residence bank"),
        ("P3 DNA only", "config/Modelfile present; pytorch on Akron only"),
        ("P4 scores", "UNKNOWN contract · PASS archive integrity path observed"),
        ("P5 residence draft", "lock path not written — HOLD.RESIDENCE.UNLOCKED"),
        ("P6 verdict", "ARCHIVE.only for this hole · all other holes not opened"),
        ("P7 receipt", "ParticleBoard card + diary 2026-07-21 morning sequence")
    ]

    private let rules = [
        "path ≠ seat",
        "label / Hz / ★ ≠ PROMOTE",
        "discovery ≠ placement",
        "nearby scripts ≠ ASR",
        "Ollama home ≠ FIELD home",
        "RESIDENCE.LOCKED before runtime bind",
        "archive ≠ failure"
    ]

    private let holds = [
        "HOLD.RESIDENCE.UNLOCKED",
        "HOLD.RuntimeSplit",
        "HOLD.NoOllamaRestore",
        "HOLD.NoChamberPromote",
        "HOLD.Wrong.Slot.ATLAS",
        "HOLD.Wrong.Slot.ASR",
        "HOLD.SuiteNotRun.OBIWAN"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Geometric Cherry Pick Card v0 — EDGDAD12a")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(FieldPalette.textPrimary)
                Spacer()
                Text("ONE HOLE · HELD")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(FieldPalette.textDim)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(FieldPalette.void.opacity(0.6))
                    .clipShape(Capsule())
            }

            Text("Morphosis first · sovereign FIELD first · one named hole only")
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(Chamber.arkadas.color)

            VStack(alignment: .leading, spacing: 5) {
                ForEach(rows, id: \.0) { label, value in
                    cherryPickRow(label, value)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("NON-COLLAPSE RULES")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Chamber.arkadas.color)
                ForEach(rules, id: \.self) { rule in
                    Text(rule)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(FieldPalette.textMuted)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("HOLDS")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: ParticleStateColor.hold.hex))
                ForEach(holds, id: \.self) { hold in
                    HStack(spacing: 6) {
                        Circle()
                            .stroke(Color(hex: ParticleStateColor.hold.hex), lineWidth: 1)
                            .frame(width: 7, height: 7)
                        Text(hold)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(FieldPalette.textMuted)
                    }
                }
            }

            Text("docs/GEOMETRIC_CHERRY_PICK_PROTOCOL_V0.md · docs/FIELD_MODEL_RESIDENCE_WIREFRAME_V0.md")
                .font(.system(size: 8, design: .monospaced))
                .foregroundStyle(FieldPalette.textDim)
        }
        .padding(12)
        .background(FieldPalette.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: ParticleStateColor.hold.hex).opacity(0.35), lineWidth: 1)
        )
    }

    private func cherryPickRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                .foregroundStyle(FieldPalette.textDim)
                .frame(width: 138, alignment: .leading)
            Text(value)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(
                    (label == "state" || label == "verdict" || label == "RESIDENCE.LOCKED")
                        ? Color(hex: ParticleStateColor.hold.hex)
                        : FieldPalette.textMuted
                )
                .lineLimit(4)
        }
    }
}

// MARK: - CarPlay DOJO Channel

private struct CarPlayDOJOChannelCard: View {
    private let rows = [
        ("observer", "JB in vehicle context"),
        ("mode", "voice-primary / hands-free / low-distraction"),
        ("surface role", "driving-safe intake, acknowledgement, short-thread continuity, HOLD/queue cue"),
        ("allowed channel use", "short voice capture / brief audio response / safe acknowledgement / recent thread cue / queue/HOLD status / do this later handoff"),
        ("not claimed", "full DOJO cockpit / dense visual review / long-form editing / vehicle control / navigation/music/climate control / system-wide CarPlay entitlement / live CarPlay runtime / ASR implementation / external LLM routing / AKRON upload / SPIN implementation"),
        ("promotion requires", "Apple CarPlay capability / entitlement verified / template constraints verified / driving-safe UX contract / voice thread anchor / drop/recovery behavior / latency test / explicit approval gates / build receipt"),
        ("boundary", "CarPlay is a DOJO surface vector through the iPhone vessel. It is not FIELD, not AKRON, not SOMA, not vehicle control, and not the Mac Studio command center.")
    ]

    private let holds = [
        "HOLD.CarPlayEntitlementUnknown",
        "HOLD.TemplateConstraintsUnverified",
        "HOLD.DrivingMode.CognitiveLoad",
        "HOLD.DenseVisualReview",
        "HOLD.ThreadAnchorMissing",
        "HOLD.ExternalActionNeedsApproval",
        "HOLD.ASRTranscriptUnverified",
        "HOLD.BackendRouteUnknown",
        "HOLD.DefaultAKRON"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("CarPlay DOJO Channel v0")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(FieldPalette.textPrimary)
                Spacer()
                Text("CHANNEL-HELD")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(FieldPalette.textDim)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(FieldPalette.void.opacity(0.6))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 5) {
                carPlayRow("state", "CHANNEL-HELD")
                carPlayRow("status", "HELD — driving-safe contract not promoted")
                carPlayRow("contract", "docs/CARPLAY_DOJO_CHANNEL_CONTRACT_V0.md")
                carPlayRow("rule", "CarPlay surface != full DOJO cockpit")
                ForEach(rows, id: \.0) { label, value in
                    carPlayRow(label, value)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("HOLD TRIGGERS")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: ParticleStateColor.hold.hex))
                ForEach(holds, id: \.self) { hold in
                    HStack(spacing: 6) {
                        Circle()
                            .stroke(Color(hex: ParticleStateColor.hold.hex), lineWidth: 1)
                            .frame(width: 7, height: 7)
                        Text(hold)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(FieldPalette.textMuted)
                            .lineLimit(2)
                    }
                }
            }

            Text("This card opens the CarPlay DOJO channel as a held vehicle surface without claiming CarPlay runtime, entitlement, ASR, routing, vehicle control, or AKRON boundary crossing.")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(FieldPalette.textMuted)

            Text("Open the paddock. Count the stock. Do not move the mob yet.")
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(Chamber.arkadas.color)
        }
        .padding(12)
        .background(FieldPalette.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: ParticleStateColor.hold.hex).opacity(0.35), lineWidth: 1)
        )
    }

    private func carPlayRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                .foregroundStyle(FieldPalette.textDim)
                .frame(width: 138, alignment: .leading)
            Text(value)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle((label == "status" || label == "rule") ? Color(hex: ParticleStateColor.hold.hex) : FieldPalette.textMuted)
                .lineLimit(4)
        }
    }
}

// MARK: - Landscape / Place Channel

private struct LandscapePlaceChannelCard: View {
    private let pin = LandscapePlaceSnapshot.v0Held

    private var rows: [(String, String)] {
        [
            ("observer", "JB in the world — desk, walk, car, room"),
            ("mode", "reporting pin now · glanceable place cue later"),
            ("surface role", "where the human is; sibling of CarPlay, not CarPlay"),
            ("allowed now", "name the space · keep it visible · keep it separate"),
            ("not claimed", "MapKit / Core Location / turn-by-turn / Apple Maps clone / vehicle nav / ATLAS as a map app / Perplexity maps"),
            ("promotion requires", "new sitting · location primes · MapKit only if named · CarPlay-safe glance stays a CarPlay sitting"),
            ("boundary", pin.authorityCeiling)
        ]
    }

    private let holds = [
        "HOLD.LandscapeMappingUnseated",
        "HOLD.MapKitNotAuthorized",
        "HOLD.LocationPermissionUnknown",
        "HOLD.CollapseIntoCarPlay",
        "HOLD.CollapseIntoTodayMap"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Landscape / Place Channel v0")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(FieldPalette.textPrimary)
                Spacer()
                Text("CHANNEL-HELD")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(FieldPalette.textDim)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(FieldPalette.void.opacity(0.6))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 5) {
                placeRow("state", pin.state)
                placeRow("status", "HELD — terrain named; map tools not unlocked")
                placeRow("contract", pin.contractPath)
                placeRow("rule", "Place != CarPlay != Today first-screen map")
                ForEach(rows, id: \.0) { label, value in
                    placeRow(label, value)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("HOLD TRIGGERS")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: ParticleStateColor.hold.hex))
                ForEach(holds, id: \.self) { hold in
                    HStack(spacing: 6) {
                        Circle()
                            .stroke(Color(hex: ParticleStateColor.hold.hex), lineWidth: 1)
                            .frame(width: 7, height: 7)
                        Text(hold)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(FieldPalette.textMuted)
                            .lineLimit(2)
                    }
                }
            }

            Text("This card fills the landscape/place space as a held channel. It does not claim a map, a location fix, or CarPlay navigation.")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(FieldPalette.textMuted)

            Text("Name the terrain. Do not unlock the hill yet.")
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(Chamber.atlas.color)
        }
        .padding(12)
        .background(FieldPalette.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: ParticleStateColor.hold.hex).opacity(0.35), lineWidth: 1)
        )
    }

    private func placeRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                .foregroundStyle(FieldPalette.textDim)
                .frame(width: 138, alignment: .leading)
            Text(value)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle((label == "status" || label == "rule" || label == "state") ? Color(hex: ParticleStateColor.hold.hex) : FieldPalette.textMuted)
                .lineLimit(4)
        }
    }
}

// MARK: - Apple TV Surface PULSE Channel

private struct AppleTVSurfacePULSEChannelCard: View {
    /// Surface category ≠ surface identity. Role assigned by active matrix attributes.
    private let rows = [
        ("surface object", "Apple TV — room-scale display surface (not fixed identity)"),
        ("visible rule", "surface role = context + purpose + audience + boundary"),
        ("classification", "not pre-classified as personal, non-personal, household, public, PULSE, DOJO, OBI-WAN, SOMA, AKRON, automotive, or sovereign"),
        ("candidate role", "may become DOJO / Surface PULSE channel only when purpose + boundary assign that active role"),
        ("location", "OPEN (potential) — living / bedroom / office / shared / public / multi-home / n/a"),
        ("audience", "OPEN (potential) — solo / shared / guest / public / empty room / session-bound"),
        ("purpose", "OPEN (potential) — ambient / alignment / handoff visibility / review / entertainment / idle"),
        ("visibility", "OPEN (potential) — private / shared-limited / household / public / screen-off"),
        ("authority", "safety rail: display/cue-only; proposal/approval remain potential research only"),
        ("data source", "OPEN (potential) — DOJO / Surface PULSE expression / OBI-WAN summary / manual / none"),
        ("interaction", "OPEN lean: passive; remote/voice/handoff potential later if assigned"),
        ("sensitivity", "OPEN (potential) — open / internal / confidential / care-sensitive / mixed"),
        ("unknown means", "open potential under time-local HOLDs — not a blank to coerce"),
        ("explore first", "docs/SURFACE_ATTRIBUTE_POTENTIAL_EXPLORATION_V0.md"),
        ("layer split", "TV surface ≠ Surface PULSE expression ≠ PULSE infrastructure ≠ OBI-WAN library ≠ person"),
        ("allowed if promoted", "ambient status / Story Wheel glance / do-this-here cue / consent-gated handoff visibility — only under active attributes"),
        ("not claimed", "tvOS app / HomeKit / sensors / surveillance / medical automation / model routing / AKRON upload / SPIN / PULSE server / OBI-WAN storage move"),
        ("promotion requires", "attribute labels filled / consent when shared / boundary suite / no identity collapse / explicit approval / build receipt"),
        ("contract", "docs/SURFACE_PULSE_APPLE_TV_CHANNEL_CONTRACT_V0.md")
    ]

    private let holds = [
        "HOLD.SurfacePULSE.ContractNotPromoted",
        "HOLD.tvOS.NotImplemented",
        "HOLD.PreClassification.Assumed",
        "HOLD.Collapse.PULSEInfrastructure",
        "HOLD.Collapse.SurfaceAsIdentity",
        "HOLD.Attributes.Unknown",
        "HOLD.Cohabitation.ConsentUnknown",
        "HOLD.DefaultAKRON",
        "HOLD.DenseCockpitOnRoomDisplay"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Apple TV Surface PULSE Channel v0")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(FieldPalette.textPrimary)
                Spacer()
                Text("CHANNEL-HELD")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(FieldPalette.textDim)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(FieldPalette.void.opacity(0.6))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 5) {
                appleTVRow("state", "CHANNEL-HELD")
                appleTVRow("status", "HELD — room-surface contract not promoted")
                appleTVRow("rule", "Apple TV surface role = context + purpose + audience + boundary")
                appleTVRow("non-collapse", "Surface category ≠ surface identity · role assigned, not assumed")
                ForEach(rows, id: \.0) { label, value in
                    appleTVRow(label, value)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("HOLD TRIGGERS")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: ParticleStateColor.hold.hex))
                ForEach(holds, id: \.self) { hold in
                    HStack(spacing: 6) {
                        Circle()
                            .stroke(Color(hex: ParticleStateColor.hold.hex), lineWidth: 1)
                            .frame(width: 7, height: 7)
                        Text(hold)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(FieldPalette.textMuted)
                            .lineLimit(2)
                    }
                }
            }

            Text("Don’t brand the paddock before you know what mob is in it. Same gate, different mob, different day, different job.")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(FieldPalette.textMuted)

            Text("Open the paddock. Count the stock. Do not move the mob yet.")
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(Chamber.arkadas.color)
        }
        .padding(12)
        .background(FieldPalette.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: ParticleStateColor.hold.hex).opacity(0.35), lineWidth: 1)
        )
    }

    private func appleTVRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                .foregroundStyle(FieldPalette.textDim)
                .frame(width: 138, alignment: .leading)
            Text(value)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(
                    (label == "status" || label == "rule" || label == "state" || label == "non-collapse" || label == "visible rule")
                        ? Color(hex: ParticleStateColor.hold.hex)
                        : FieldPalette.textMuted
                )
                .lineLimit(5)
        }
    }
}

// MARK: - FieldButtonStyle

struct FieldButtonStyle: ButtonStyle {
    var tint: Color = Chamber.dojo.color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.monospaced())
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(tint.opacity(configuration.isPressed ? 0.2 : 0.1))
            .foregroundStyle(tint)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(tint.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}
