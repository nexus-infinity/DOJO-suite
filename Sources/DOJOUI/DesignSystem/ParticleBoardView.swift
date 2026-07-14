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
                    if let address = editingCell {
                        editorPanel(for: address)
                    }
                    if let forecast = controller.pendingForecast {
                        forecastPanel(forecast)
                    }
                }
                .padding(16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FieldPalette.void.ignoresSafeArea())
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
                    ForEach(ClaimClass.allCases) { claimClass in
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

// MARK: - ClaimClass Identifiable bridge (local — avoids retroactive conformance)
extension ClaimClass: @retroactive Identifiable {
    public var id: String { rawValue }
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
