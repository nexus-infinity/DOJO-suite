import SwiftUI
import DOJOUI
import AppKit
import DOJOShared
import MapKit
import UniformTypeIdentifiers

// MARK: - DOJO Today — workspace shell
// Wireframe: top · left places · centre work · right utility dock · composer
// Not a dashboard-card surface. FIELD complexity stays underneath.
// M1 hosted loop retained if keys present; no memory / local models / governance primary UI.
// Attention research → practical constraints only (see DOJO_TODAY_ATTENTION_PRODUCT_CONSTRAINTS_V0):
// A stillness default · B boundary-aware right panel · C recovery metadata on answer objects.

@available(macOS 14.0, *)
struct DOJOTodaySurfaceView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // Navigation
    @State private var selectedPlace: TodayPlace = .today
    @State private var selectedObjectID: UUID?

    // Layout
    @State private var leftRailCollapsed = false
    // Context begins at the horizon. It earns full width when an object is opened.
    @State private var rightRailCollapsed = true
    @State private var objectContextExpanded = false
    /// Compact capacity keeps context at the destination until the operator
    /// explicitly asks for it. This preserves the selected object while
    /// releasing centre space; it does not alter object or processing state.
    @State private var compactToolsRequested = false
    @State private var rightUtility: RightUtilityMode = .details
    // The composer is useful infrastructure, but it should not consume the
    // whole lower edge when the operator wants a larger work canvas.
    @State private var bottomComposerCollapsed = false

    // Composer
    @State private var composerText = ""
    /// Session-scoped local file intake. This seam never sends file bytes to a
    /// model; it only enables a local Capture receipt for selected metadata.
    @State private var attachedFiles: [URL] = []
    @State private var isDropTargeted = false
    @State private var selectedMode: ComposerMode = .capture
    @State private var selectedProvider: HostedProviderID = M1Preferences.defaultProvider
    @State private var selectedModelID: String = M1Preferences.defaultModelID

    // Sheets / progressive disclosure layers
    @State private var showingProofDrawer = false
    @State private var showingSettings = false
    @State private var showingDeveloper = false
    @State private var showingTestBench = false
    @State private var showingSystemInspector = false
    @State private var showingStatusPopover = false
    @State private var objectDetailsTarget: GeneratedObjectShell?
    @State private var selectedSpatialProofID: String?

    // Work objects (session + disk)
    @State private var generatedObjects: [GeneratedObjectShell] = []
    @State private var placeSearchText = ""
    @State private var isRequesting = false
    @State private var statusMessage = ""
    @State private var lastError: String?

    // Status popover toggles (not permanent top-bar chrome)
    @State private var boundaryTestMode = false
    /// Developer-only specimen switch. It is scoped to Boundary test so an
    /// accessibility comparison never becomes hidden production state.
    @State private var accessibilitySpecimen = false
    @State private var receiptsPolicyOn = true
    /// Settings sheet preferred section (e.g. jump to API keys from API key needed).
    @State private var settingsInitialSection: SettingsSection = .models

    var body: some View {
        GeometryReader { proxy in
            let capacity = TodaySurfaceCapacity(width: proxy.size.width)

            ZStack {
                DOJOTodayFieldAtmosphere()

                HStack(alignment: .top, spacing: 0) {
                // Places is its own zone. The main toolbar and composer begin
                // after this boundary, matching the focused workspace pattern.
                leftPlacesPanel(compact: false)
                Divider().overlay(dojoDividerColor.opacity(0.72))

                VStack(spacing: 0) {
                    topBar(capacity: capacity)

                    if let err = lastError {
                        thinBanner(err, isError: true) { lastError = nil }
                    } else if !statusMessage.isEmpty {
                        thinBanner(statusMessage, isError: false) { statusMessage = "" }
                    }

                    Divider().overlay(dojoDividerColor)

                    GeometryReader { _ in
                        HStack(alignment: .top, spacing: 0) {
                            centreWorkPanel(capacity: capacity)
                            if !isRightDockAtHorizon(for: capacity) {
                                Divider().overlay(dojoDividerColor.opacity(0.72))
                            }
                            rightUtilityDock(capacity: capacity)
                        }
                    }

                    Divider().overlay(dojoDividerColor)
                    if bottomComposerCollapsed {
                        collapsedComposerBar
                    } else {
                        bottomComposer(capacity: capacity)
                    }
                }
            }

                if boundaryTestMode {
                    surfaceMeasurementOverlay(capacity: capacity, dimensions: proxy.size)
                }
            }
        }
        .frame(minWidth: 780, minHeight: 620)
        .background(dojoObsidian)
        // Iterations reopen in the working frame. A user may still enter
        // full screen deliberately; this guard only clears restored full
        // screen state once when the surface is first attached to a window.
        .background(DOJOWindowPresentationGuard())
        .onAppear {
            if isPreviewRuntime {
                seedSampleObjects()
            } else {
                reloadFromDisk()
                openLatestWorkIfNothingSelected()
            }
            selectedProvider = M1Preferences.defaultProvider
            selectedModelID = HostedProviderCatalog.resolvedModelID(
                provider: selectedProvider,
                preferred: M1Preferences.defaultModelID
            )
        }
        .sheet(isPresented: $showingProofDrawer) {
            ProofDrawerView(object: selectedObject ?? generatedObjects.first)
        }
        .sheet(isPresented: $showingSettings) {
            TodaySettingsView(
                selectedProvider: $selectedProvider,
                selectedModelID: $selectedModelID,
                initialSection: settingsInitialSection,
                openSystemInspector: {
                    showingSettings = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        showingSystemInspector = true
                    }
                },
                openDeveloper: {
                    showingSettings = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        showingDeveloper = true
                    }
                }
            )
        }
        .sheet(isPresented: $showingSystemInspector) {
            SystemInspectorView(
                selectedObjectTitle: selectedObject?.title,
                selectedProviderName: selectedProvider.displayName,
                hasProviderKey: providerHasSavedKey(selectedProvider),
                receiptsOn: receiptsPolicyOn,
                memoryEnabled: false,
                isRequesting: isRequesting
            )
        }
        .sheet(isPresented: $showingDeveloper) {
            DeveloperSpaceView {
                showingDeveloper = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    showingTestBench = true
                }
            }
        }
        .sheet(isPresented: $showingTestBench) { DeterministicTestBenchView() }
        .sheet(item: $objectDetailsTarget) { object in
            ObjectDetailsSheet(
                object: object,
                openProof: { showingProofDrawer = true },
                openInspector: {
                    objectDetailsTarget = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showingSystemInspector = true
                    }
                }
            )
        }
    }

    /// Today typography keeps the existing visual hierarchy while honoring
    /// macOS accessibility sizes. This is presentation-only; it never changes
    /// object identity, processing, routing, persistence, or authority.
    private func todayFont(
        size: CGFloat,
        weight: Font.Weight = .regular,
        design: Font.Design = .default
    ) -> Font {
        let scale: CGFloat
        // Ordinary use inherits the user's macOS setting. The developer-only
        // specimen provides a deterministic accessibility comparison without
        // forcing production users back to the default size.
        let effectiveDynamicTypeSize: DynamicTypeSize =
            boundaryTestMode && accessibilitySpecimen ? .accessibility3 : dynamicTypeSize
        switch effectiveDynamicTypeSize {
        case .accessibility1: scale = 1.12
        case .accessibility2: scale = 1.20
        case .accessibility3: scale = 1.30
        case .accessibility4: scale = 1.40
        case .accessibility5: scale = 1.50
        default: scale = 1.0
        }
        return .system(size: size * scale, weight: weight, design: design)
    }

    // MARK: - Top bar (thin)

    private func topBar(capacity: TodaySurfaceCapacity) -> some View {
        let toolsAtHorizon = isRightDockAtHorizon(for: capacity)
        return HStack(spacing: 12) {
            Text("DOJO")
                .font(todayFont(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(canonicalRoleColor(.dojo))

            Text(Chamber.dojo.rawValue)
                .font(todayFont(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(canonicalRoleColor(.dojo))

            Text("·")
                .foregroundStyle(dojoTextTertiary)

            VStack(alignment: .leading, spacing: 2) {
                Text(currentWorkspaceLabel)
                    .font(todayFont(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#EAFBFF"))
                    .lineLimit(1)

                Text(surfaceContextHeaderLine(capacity: capacity))
                    .font(todayFont(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(dojoTextTertiary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .help(FieldSurfaceCoordinationCatalog.surfaceContextHeaderLine(observerID: "local-operator"))
            }

            Spacer(minLength: 8)

            if leftRailCollapsed {
                layoutChip("Places", systemImage: "sidebar.left") {
                    leftRailCollapsed = false
                }
            }
            if toolsAtHorizon {
                if capacity == .compact {
                    compactLayoutChip("Tools", systemImage: "sidebar.right") {
                        compactToolsRequested = true
                        openRightPanel(reason: .userManualToggle)
                    }
                } else {
                    layoutChip("Tools", systemImage: "sidebar.right") {
                        compactToolsRequested = true
                        openRightPanel(reason: .userManualToggle)
                    }
                }
            }

            if capacity == .compact {
                compactLayoutChip("Connections", systemImage: "point.3.connected.trianglepath.dotted") {
                    showingStatusPopover = true
                }
            } else {
                layoutChip("Connections", systemImage: "point.3.connected.trianglepath.dotted") {
                    showingStatusPopover = true
                }
            }

            // Lawful loading motion only (send in flight) — not decoration.
            if isRequesting {
                ProgressView().controlSize(.small).scaleEffect(0.75)
            }

            // Compact status — opens popover (Local / Receipts / Boundary test live here)
            Button { showingStatusPopover.toggle() } label: {
                Group {
                    if capacity == .compact {
                        Circle()
                            .fill(compactStatusColor)
                            .frame(width: 9, height: 9)
                            .frame(width: 28, height: 28)
                    } else {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(compactStatusColor)
                                .frame(width: 7, height: 7)
                            Text(compactStatusLabel)
                                .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color(hex: "#C9E4EA"))
                            Image(systemName: "chevron.down")
                                .font(todayFont(size: 9, weight: .bold))
                                .foregroundStyle(dojoTextTertiary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                    }
                }
                .background(dojoControl)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .help("Status: \(compactStatusLabel)")
            .accessibilityLabel(compactStatusLabel)
            .popover(isPresented: $showingStatusPopover, arrowEdge: .bottom) {
                statusPopoverContent(capacity: capacity)
            }

            // Layout: toggle right dock (explicit user request only)
            Button {
                if toolsAtHorizon {
                    compactToolsRequested = true
                    openRightPanel(reason: .userManualToggle)
                } else {
                    collapseRightPanelToHorizon()
                }
            } label: {
                Image(systemName: rightRailCollapsed ? "rectangle.split.2x1" : "rectangle.split.3x1")
                    .font(todayFont(size: 13, weight: .semibold))
                    .foregroundStyle(dojoTextSecondary)
                    .frame(width: 28, height: 28)
                    .background(dojoControl)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .help(rightRailCollapsed ? "Show utility dock" : "Hide utility dock")

            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    bottomComposerCollapsed.toggle()
                }
            } label: {
                Image(systemName: bottomComposerCollapsed ? "chevron.up" : "chevron.down")
                    .font(todayFont(size: 12, weight: .bold))
                    .foregroundStyle(dojoTextSecondary)
                    .frame(width: 28, height: 28)
                    .background(dojoControl)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .help(bottomComposerCollapsed ? "Show composer" : "Hide composer")

            Button { showingSettings = true } label: {
                Image(systemName: "gearshape")
                    .font(todayFont(size: 13, weight: .semibold))
                    .foregroundStyle(dojoTextSecondary)
                    .frame(width: 28, height: 28)
                    .background(dojoControl)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .help("Settings")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(dojoChrome.opacity(0.96))
    }

    private func surfaceContextHeaderLine(capacity: TodaySurfaceCapacity) -> String {
        FieldSurfaceCoordinationCatalog.surfaceContextHeaderLine(
            observerID: "local-operator",
            compact: capacity == .compact
        )
    }

    /// Experience-layer identity only. This names the surface's relationship
    /// to the spinning top without claiming a live round-trip or authority.
    private var mirrorPortalChip: some View {
        HStack(spacing: 5) {
            // A mirror identity is not a sync claim. Use a neutral portal symbol
            // so the experience does not imply live transport when none is active.
            Image(systemName: "rectangle.on.rectangle")
                .font(todayFont(size: 10, weight: .semibold))
            Text("Mirror portal")
                .font(todayFont(size: 10, weight: .semibold, design: .rounded))
            Text("· DOJO spinning top")
                .font(todayFont(size: 10, weight: .medium, design: .rounded))
        }
        .foregroundStyle(Color(hex: "#9ADCE7"))
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color(hex: "#0B3038").opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .help("DOJO Suite is a presentation mirror into the DOJO spinning top; this surface is not source-of-truth authority. SOMA is a separate sovereign peer phenotype.")
    }

    private var compactMirrorPortalChip: some View {
        Image(systemName: "rectangle.on.rectangle")
            .font(todayFont(size: 11, weight: .semibold))
            .foregroundStyle(Color(hex: "#9ADCE7"))
            .frame(width: 28, height: 24)
            .background(Color(hex: "#0B3038").opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 7))
                .help("Mirror portal · DOJO spinning top. Presentation mirror only; not source-of-truth authority. SOMA remains a separate sovereign peer phenotype and is not represented as DOJO state here.")
            .accessibilityLabel("Mirror portal · DOJO spinning top")
    }

    private var canonicalGeometryBar: some View {
        HStack(spacing: 12) {
            canonicalVertex(.obiwan, active: selectedPlace == .today)
            geometryConnector
            canonicalVertex(.tata, active: selectedPlace == .captures || lastError != nil)
            geometryConnector
            canonicalVertex(.atlas, active: selectedPlace == .projects || rightUtility == .review)
            geometryConnector
            canonicalVertex(.dojo, active: selectedObject != nil || selectedMode == .ask || selectedMode == .dojoPortal)

            Spacer(minLength: 8)

            HStack(spacing: 6) {
                Text("Prime-fractal / chakra")
                    .font(todayFont(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(dojoTextTertiary)
                Text("HOLD")
                    .font(todayFont(size: 8, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(hex: "#FBBF24"))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: "#FBBF24").opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .help("Recursive chakra embodiment is explicitly held until visual and runtime embodiment are complete.")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(dojoObsidian.opacity(0.96))
    }

    private func canonicalVertex(_ chamber: Chamber, active: Bool) -> some View {
        let roleColor = canonicalRoleColor(chamber)
        return HStack(spacing: 5) {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(chamber.rawValue) \(canonicalChamberName(chamber))")
                    .font(todayFont(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(active ? dojoTextPrimary : dojoTextTertiary)
                Text("\(canonicalRoleLabel(chamber)) · \(chamber.frequency) Hz")
                    .font(todayFont(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(active ? roleColor.opacity(0.86) : dojoTextTertiary)
            }
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(active ? roleColor.opacity(0.10) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .help("\(canonicalChamberName(chamber)): \(canonicalRoleLabel(chamber))")
    }

    private var geometryConnector: some View {
        Rectangle()
            .fill(dojoDividerColor.opacity(0.72))
            .frame(width: 18, height: 1)
    }

    private var currentWorkspaceLabel: String {
        if let obj = selectedObject {
            return "\(selectedPlace.title) · \(obj.title)"
        }
        return selectedPlace.title
    }

    private var isPreviewRuntime: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    private func providerHasSavedKey(_ provider: HostedProviderID) -> Bool {
        guard !isPreviewRuntime else { return false }
        return APIKeychainStore.hasKey(provider: provider)
    }

    private var currentInteractionContext: InteractionContext {
        InteractionContext(
            inputMode: currentInputMode,
            preferredOutputMode: nil,
            resolvedOutputMode: .visual,
            biometricState: .unknown,
            environmentState: .unknown,
            activeDevice: .mac
        )
    }

    private var currentInputMode: InputMode {
        switch selectedMode {
        case .review:
            return .gesture
        case .dojoPortal, .ask, .capture:
            return .text
        }
    }

    private var spatialEvidenceFixture: SpatialEvidenceProjection {
        let receipt = LocalCaptureReceipt(
            receiptID: "fixture-local-capture-mapkit-1",
            objectID: "fixture-field-object-mapkit-1",
            surface: "DOJO Today · macOS",
            operation: LocalCaptureReceipt.Operation.capture,
            result: LocalCaptureReceipt.Outcome.captured,
            issuedAt: Date(timeIntervalSince1970: 1_788_300_000),
            contentSHA256: String(repeating: "c", count: 64),
            objectPath: "/tmp/dojo-fixture/generated_objects.json",
            receiptPath: "/tmp/dojo-fixture/local_capture_receipts.jsonl"
        )
        let evidence = EvidenceAnchor(
            anchorID: receipt.receiptID,
            kind: .localCaptureReceipt,
            sourceID: receipt.receiptID,
            state: .sealed,
            claim: "Fixture spatial anchor attached to existing local capture receipt contract"
        )
        let anchor = SpatialAnchor(
            anchorID: "fixture-spatial-anchor-mapkit-1",
            coordinate: SpatialCoordinate(latitude: -37.8136, longitude: 144.9631),
            displayName: "FIXTURE / DEVELOPMENT PROOF — NOT LIVE LOCATION",
            horizontalAccuracyMeters: 18,
            observedAt: Date(timeIntervalSince1970: 1_788_299_940),
            recordedAt: receipt.issuedAt,
            evidenceAnchor: evidence
        )

        return SpatialEvidenceProjectionFactory.fromLocalCaptureReceipt(
            receipt,
            spatialAnchor: anchor,
            projectionIdentity: ProjectionIdentity(
                projectionID: "fixture-mapkit-annotation-1",
                surface: .mac,
                representationKind: .mapAnnotation
            ),
            interactionContext: currentInteractionContext,
            authorityStatus: ProjectionAuthorityStatus(
                decision: .pass,
                boundaryReference: "FIXTURE.Authority.Pass",
                nextEvidence: nil
            ),
            projectionTime: Date(timeIntervalSince1970: 1_788_300_060)
        )
    }

    private var compactStatusLabel: String {
        if lastError != nil { return "Blocked" }
        if isRequesting { return "Working" }
        if selectedMode == .ask && !providerHasSavedKey(selectedProvider) && selectedProvider.isHostedLive {
            return "API key needed"
        }
        return "Ready"
    }

    private var compactStatusColor: Color {
        if lastError != nil { return Color(hex: "#F87171") }
        if isRequesting { return Color(hex: "#FBBF24") }
        if selectedMode == .ask && !providerHasSavedKey(selectedProvider) && selectedProvider.isHostedLive {
            return Color(hex: "#FBBF24")
        }
        return Color(hex: "#86EFAC")
    }

    private func statusPopoverContent(capacity: TodaySurfaceCapacity) -> some View {
        let interactionContext = currentInteractionContext

        return VStack(alignment: .leading, spacing: 12) {
            Text("Status")
                .font(todayFont(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "#EAFBFF"))

            // App
            Text("App")
                .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#89A8B1"))
            statusCheck(true, "Local mode")
            statusCheck(receiptsPolicyOn, "Receipts enabled")
            statusCheck(false, "Memory not enabled")
            if selectedMode == .ask {
                let hasKey = providerHasSavedKey(selectedProvider)
                statusCheck(
                    hasKey,
                    hasKey
                        ? "Model API key ready (\(selectedProvider.displayName))"
                        : "Model API key not connected"
                )
            } else {
                statusCheck(true, "DOJO portal route selected")
            }

            Divider().overlay(dojoDividerColor)

            Text("Interaction context")
                .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#89A8B1"))
            labeledRow("Input", interactionContext.inputMode.diagnosticLabel)
            labeledRow("Output", interactionContext.resolvedOutputMode.diagnosticLabel)
            labeledRow("Biometric", interactionContext.biometricState.diagnosticLabel)
            labeledRow("Environment", interactionContext.environmentState.diagnosticLabel)
            labeledRow("Device", interactionContext.activeDevice.diagnosticLabel)
            Text("Local diagnostic contract only · no live sync or runtime promotion")
                .font(todayFont(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#6B8A93"))
                .fixedSize(horizontal: false, vertical: true)

            if selectedMode == .ask && !providerHasSavedKey(selectedProvider) && selectedProvider.isHostedLive {
                Button {
                    showingStatusPopover = false
                    openSettings(section: .apiKeys)
                } label: {
                    Text("Open API keys…")
                        .font(todayFont(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "#031416"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#FBBF24"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            Toggle("Receipts on", isOn: $receiptsPolicyOn)
                .toggleStyle(.switch)
                .font(todayFont(size: 12, weight: .medium, design: .rounded))

            Divider().overlay(dojoDividerColor)

            // Connections (summary only — not Inspector)
            Text("Connections")
                .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#89A8B1"))
            Text("External MCP setup pending")
                .font(todayFont(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#A9BBC2"))
            Text("DOJO portal: local spinning-top route · hosted providers: separate advisory route")
                .font(todayFont(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#6B8A93"))

            Text("FIELD phenotypes")
                .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#89A8B1"))
            Text("DOJO Suite · mirror portal into the DOJO spinning top")
                .font(todayFont(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#A9BBC2"))
            Text("SOMA · sovereign peer phenotype · separate lawful home")
                .font(todayFont(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#A9BBC2"))
            Text("Shared pulse genotype does not merge identity, authority, route, or home.")
                .font(todayFont(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#6B8A93"))

            Divider().overlay(dojoDividerColor)

            // Holds (plain language)
            Text("Current holds")
                .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#89A8B1"))
            Text("· External MCP adapters remain separate from the DOJO portal route")
                .font(todayFont(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#A9BBC2"))
            Text("· Memory not enabled")
                .font(todayFont(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#A9BBC2"))

            if let lastError {
                Text(lastError)
                    .font(todayFont(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#FCA5A5"))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider().overlay(dojoDividerColor)

            HStack(spacing: 8) {
                Button {
                    showingStatusPopover = false
                    showingSystemInspector = true
                } label: {
                    Text("Open System Inspector")
                        .font(todayFont(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "#031416"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Color(hex: "#6CEBFF"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                Button {
                    showingStatusPopover = false
                    showingProofDrawer = true
                } label: {
                    Text("Open Proof")
                        .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#7DD3FC"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(dojoControl)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            Toggle("Boundary test (layout)", isOn: $boundaryTestMode)
                .toggleStyle(.switch)
                .font(todayFont(size: 11, weight: .medium, design: .rounded))

            if boundaryTestMode {
                HStack(spacing: 8) {
                    miniAction("Collapse left") {
                        withAnimation { leftRailCollapsed = true }
                    }
                    miniAction("Seed work") { seedSampleObjects() }
                    miniAction(accessibilitySpecimen ? "A11y off" : "A11y on") {
                        accessibilitySpecimen.toggle()
                    }
                }
            }
        }
        .padding(14)
        .frame(width: capacity == .compact ? 280 : 320)
        .background(dojoPanel)
        .foregroundStyle(Color(hex: "#D8EDF2"))
    }

    private func statusCheck(_ ok: Bool, _ text: String) -> some View {
        HStack(spacing: 8) {
            Text(ok ? "✓" : "—")
                .font(todayFont(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(ok ? Color(hex: "#86EFAC") : dojoTextTertiary)
            Text(text)
                .font(todayFont(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(dojoTextPrimary)
        }
    }

    private func labeledRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(todayFont(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(dojoTextTertiary)
            Spacer()
            Text(value)
                .font(todayFont(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(dojoTextPrimary)
                .lineLimit(1)
        }
    }

    private func layoutChip(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#7DD3FC"))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(dojoControl)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }

    private func compactLayoutChip(
        _ title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(todayFont(size: 12, weight: .semibold))
                .foregroundStyle(Color(hex: "#7DD3FC"))
                .frame(width: 28, height: 28)
                .background(dojoControl)
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
        .help(title)
        .accessibilityLabel(title)
    }

    private func primaryStateAction(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(todayFont(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "#031416"))
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(Color(hex: "#6CEBFF"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func secondaryStateAction(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(todayFont(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#7DD3FC"))
                .padding(.horizontal, 11)
                .frame(height: 34)
                .background(dojoControl)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func miniAction(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(todayFont(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#EAFBFF"))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color(hex: "#2A1840"))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }

    private func thinBanner(_ text: String, isError: Bool, dismiss: @escaping () -> Void) -> some View {
        HStack {
            Text(text)
                .font(todayFont(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(isError ? Color(hex: "#FCA5A5") : Color(hex: "#A9BBC2"))
                .lineLimit(2)
            Spacer()
            Button("Dismiss", action: dismiss)
                .font(todayFont(size: 11, weight: .semibold))
                .buttonStyle(.plain)
                .foregroundStyle(isError ? Color(hex: "#FCA5A5") : Color(hex: "#7DD3FC"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background((isError ? Color(hex: "#3B1219") : dojoPanelRaised).opacity(0.95))
    }

    private func objectStatusStrip(
        _ object: GeneratedObjectShell,
        capacity: TodaySurfaceCapacity
    ) -> some View {
        HStack(spacing: 10) {
            Label(object.isSavedLocally ? "Saved on this Mac" : "Not saved yet", systemImage: object.isSavedLocally ? "checkmark.circle.fill" : "circle.dashed")
                .foregroundStyle(object.isSavedLocally ? Color(hex: "#86EFAC") : Color(hex: "#FBBF24"))
            if object.localReceipt != nil {
                Label("Proof ready", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(Color(hex: "#6CEBFF"))
            }
            if capacity != .compact {
                Text(object.providerDisplayName)
                    .foregroundStyle(Color(hex: "#C9E4EA"))
            }
            if capacity == .expansive, let modelID = object.modelID {
                Text(modelID)
                    .foregroundStyle(Color(hex: "#89A8B1"))
            }
            Spacer(minLength: 0)
            Text(object.nextAvailableAction)
                .foregroundStyle(Color(hex: "#7DD3FC"))
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .font(todayFont(size: 11, weight: .semibold, design: .rounded))
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(dojoPanel.opacity(0.90))
    }

    private func objectContextPanel(
        _ object: GeneratedObjectShell,
        capacity: TodaySurfaceCapacity
    ) -> some View {
        let evidenceLabel = reentryEvidenceLabel(for: object)
        let authorityLabel = reentryAuthorityLabel(for: object)
        let projectionLabel = reentryProjectionLabel(for: object)
        let holdPins = objectContextHoldPins(for: object)
        let surfaceNode = FieldSurfaceCoordinationCatalog.surfaceNode(for: "dojo_today_mac")
        let signalEdge = FieldSurfaceCoordinationCatalog.signalEdge(for: "dojo_today_object_context_open")
        let observerContext = FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator")
        let permissionProfile = observerContext.flatMap { FieldSurfaceCoordinationCatalog.permissionProfile(for: $0.permissionProfileID) }

        return DisclosureGroup(isExpanded: $objectContextExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: capacity == .compact ? 180 : 220), spacing: 10)],
                    alignment: .leading,
                    spacing: 10
                ) {
                    objectContextRow("Source", reentrySourceLabel(for: object), symbol: "arrow.down.doc")
                    objectContextRow("Home", reentryHomeLabel(for: object), symbol: "house")
                    objectContextRow("Evidence", evidenceLabel, symbol: reentryEvidenceSymbol(for: evidenceLabel))
                    objectContextRow("Authority", authorityLabel, symbol: "lock.shield")
                    objectContextRow("Projection", projectionLabel, symbol: "rectangle.3.group")
                    objectContextRow("Surface node", surfaceNode?.displayName ?? "Unknown surface", symbol: "macwindow")
                    objectContextRow("Signal lane", signalEdge?.lane.rawValue ?? "UNKNOWN", symbol: "point.3.connected.trianglepath.dotted")
                    objectContextRow("Permission", signalEdge?.permissionProfile ?? "Unknown", symbol: "person.crop.circle.badge.checkmark")
                    objectContextRow("Observer", observerContext?.id ?? "Unknown observer", symbol: "person.crop.circle")
                    objectContextRow("Activity", observerContext?.activity.kind.rawValue ?? "UNKNOWN", symbol: "figure.seated.side")
                    objectContextRow("Attention", observerContext.map { "\($0.attention.level.rawValue) / \($0.attention.mode.rawValue)" } ?? "UNKNOWN", symbol: "eye")
                    objectContextRow("Permission ceiling", permissionProfile?.authorityCeiling ?? "Unknown", symbol: "shield.lefthalf.filled")
                    objectContextRow("Created", object.createdAt.formatted(date: .abbreviated, time: .shortened), symbol: "clock")
                    if let receipt = object.localReceipt {
                        objectContextRow("Receipt issued", receipt.issuedAt.formatted(date: .abbreviated, time: .shortened), symbol: "checkmark.seal")
                        objectContextRow("Receipt path", receipt.receiptPath, symbol: "folder")
                    }
                    if let packet = object.processingPacket {
                        objectContextRow("Packet source", packet.source, symbol: "shippingbox")
                        objectContextRow("Packet observed", packet.observedAt?.formatted(date: .abbreviated, time: .shortened) ?? "Unknown", symbol: "eye")
                    }
                    objectContextRow("Last stable", object.lastStablePoint, symbol: "point.3.connected.trianglepath.dotted")
                    objectContextRow("Next lawful move", object.nextAvailableAction, symbol: "arrowshape.turn.up.right")
                }

                HStack(alignment: .top, spacing: 8) {
                    Text("HOLD")
                        .font(todayFont(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(hex: "#FBBF24"))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#FBBF24").opacity(0.10))
                        .clipShape(Capsule())
                    Text(holdPins.joined(separator: " · "))
                        .font(todayFont(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(dojoTextTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.top, 10)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.stack.badge.person.crop")
                    .font(todayFont(size: 11, weight: .semibold))
                    .foregroundStyle(Color(hex: "#7DD3FC"))
                    .accessibilityHidden(true)
                Text("Object Context")
                    .font(todayFont(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(dojoTextPrimary)
                objectContextPill(evidenceLabel)
                objectContextPill(authorityLabel)
                Spacer(minLength: 8)
                Text(objectContextExpanded ? "Expanded" : "Folded")
                    .font(todayFont(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(dojoTextTertiary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(dojoChrome.opacity(0.88))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Object context. \(reentrySourceLabel(for: object)). \(reentryHomeLabel(for: object)). \(evidenceLabel). \(authorityLabel). \(projectionLabel). Next move: \(object.nextAvailableAction).")
    }

    private func objectContextRow(_ title: String, _ value: String, symbol: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: symbol)
                .font(todayFont(size: 10, weight: .semibold))
                .foregroundStyle(dojoTextTertiary)
                .frame(width: 14, height: 14)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(todayFont(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(dojoTextTertiary)
                    .lineLimit(1)
                Text(value)
                    .font(todayFont(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(dojoTextSecondary)
                    .lineLimit(3)
                    .textSelection(.enabled)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func objectContextPill(_ value: String) -> some View {
        Text(value)
            .font(todayFont(size: 8, weight: .bold, design: .rounded))
            .foregroundStyle(dojoTextTertiary)
            .lineLimit(1)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(dojoControl.opacity(0.65))
            .clipShape(Capsule())
    }

    private func objectContextHoldPins(for object: GeneratedObjectShell) -> [String] {
        var pins: [String] = []
        if object.localReceipt == nil {
            pins.append("HOLD.LocalReceiptNotIssued")
        }
        if object.processingPacket?.resolution == .hold, let reason = object.processingPacket?.holdReason {
            pins.append(reason)
        }
        if object.processingPacket == nil {
            pins.append("HOLD.TodayProcessingPacketUnavailable")
        }
        if object.providerID != nil {
            pins.append("HOLD.ProviderResultAdvisoryOnly")
        }
        return pins.isEmpty ? ["none for this local object"] : pins
    }

    private func roleChamber(for kind: GeneratedObjectKind) -> Chamber {
        switch kind {
        case .answer, .document, .codeDiff:
            return .dojo
        case .table:
            return .atlas
        case .image, .media:
            return .obiwan
        }
    }

    // MARK: - Left panel — places only

    @ViewBuilder
    private func leftPlacesPanel(compact: Bool = false) -> some View {
        if leftRailCollapsed || compact {
            VStack(spacing: 6) {
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) { leftRailCollapsed = false }
                } label: {
                    Image(systemName: "sidebar.left")
                        .font(todayFont(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hex: "#7DD3FC"))
                        .frame(width: 44, height: 36)
                }
                .buttonStyle(.plain)
                .help("Expand places")

                ForEach(TodayPlace.firstScreenPlaces) { place in
                    let roleColor = canonicalRoleColor(place.chamber)
                    Button { selectPlace(place) } label: {
                            Text(place.chamber.rawValue)
                                .font(todayFont(size: 13, weight: .bold, design: .monospaced))
                                .foregroundStyle(selectedPlace == place ? roleColor : Color(hex: "#D9F8FF"))
                                .frame(width: 44, height: 34)
                                .background(selectedPlace == place ? roleColor.opacity(0.14) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .help(place.title)
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 10)
            .frame(width: 52)
            .background(dojoChrome.opacity(0.97))
        } else {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Channels")
                        .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#89A8B1"))
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) { leftRailCollapsed = true }
                    } label: {
                        Image(systemName: "sidebar.left")
                            .font(todayFont(size: 11, weight: .semibold))
                            .foregroundStyle(Color(hex: "#89A8B1"))
                    }
                    .buttonStyle(.plain)
                    .help("Collapse places")
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)

                ForEach(TodayPlace.firstScreenPlaces) { place in
                    let roleColor = canonicalRoleColor(place.chamber)
                    Button {
                        selectPlace(place)
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Text(place.chamber.rawValue)
                                .font(todayFont(size: 13, weight: .bold, design: .monospaced))
                                .frame(width: 18)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(place.title)
                                    .font(todayFont(size: 13, weight: .semibold, design: .rounded))
                                    .lineLimit(1)
                                Text(place.channelSummary)
                                    .font(todayFont(size: 9, weight: .medium, design: .rounded))
                                    .foregroundStyle(selectedPlace == place ? roleColor.opacity(0.78) : Color(hex: "#6B8A93"))
                                    .lineLimit(1)
                            }
                            Spacer(minLength: 0)
                            Circle()
                                .fill(place.surfaceStateColor)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                        }
                        .foregroundStyle(selectedPlace == place ? roleColor : Color(hex: "#D9F8FF"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(selectedPlace == place ? roleColor.opacity(0.14) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 8)
                }

                Divider()
                    .overlay(dojoDividerColor.opacity(0.72))
                    .padding(.vertical, 8)

                channelSurfaceFrame

                Spacer(minLength: 12)

                Button {
                    beginNewCapture()
                } label: {
                    Label("New capture", systemImage: "plus")
                        .font(todayFont(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#7DD3FC"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .help("Capture mode — local object on Send; no API required")

                Button { showingProofDrawer = true } label: {
                    Label("Proof", systemImage: "checkmark.seal")
                        .font(todayFont(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#6B8A93"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.bottom, 12)
                }
                .buttonStyle(.plain)
                .help("Open proof drawer for the selected object")
            }
            .frame(width: 216, alignment: .topLeading)
            .background(dojoChrome.opacity(0.97))
        }
    }

    private var channelSurfaceFrame: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Surface frame")
                .font(todayFont(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(dojoTextTertiary)
                .padding(.horizontal, 12)

            channelSurfaceRow(
                title: "DOJO Today",
                detail: "native working surface",
                state: "VISIBLE",
                color: Color(hex: "#86EFAC"),
                symbol: "macwindow"
            )
            channelSurfaceRow(
                title: "Notion diary",
                detail: "indexed development memory",
                state: "MIRROR",
                color: Color(hex: "#FBBF24"),
                symbol: "rectangle.stack"
            )
            channelSurfaceRow(
                title: "Local FIELD",
                detail: "receipts and files stay home",
                state: "LOCAL",
                color: Color(hex: "#7DD3FC"),
                symbol: "externaldrive"
            )
            channelSurfaceRow(
                title: "Codex / Xcode",
                detail: "implementation surface",
                state: "SEPARATE",
                color: Color(hex: "#A78BFA"),
                symbol: "hammer"
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Surface frame. DOJO Today visible. Notion diary mirror only. Local FIELD keeps receipts. Codex and Xcode remain separate implementation surfaces.")
    }

    private func channelSurfaceRow(
        title: String,
        detail: String,
        state: String,
        color: Color,
        symbol: String
    ) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: symbol)
                .font(todayFont(size: 10, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 16, height: 16)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 5) {
                    Text(title)
                        .font(todayFont(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#D9F8FF"))
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text(state)
                        .font(todayFont(size: 7, weight: .bold, design: .monospaced))
                        .foregroundStyle(color)
                        .lineLimit(1)
                }
                Text(detail)
                    .font(todayFont(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(dojoTextTertiary)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(dojoControl.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 8)
    }

    // MARK: - Centre — the work itself

    private func centreWorkPanel(capacity: TodaySurfaceCapacity) -> some View {
        VStack(spacing: 0) {
            dailyReentryStrip(capacity: capacity)

            Divider().overlay(dojoDividerColor.opacity(0.72))

            ZStack {
                Group {
                    if selectedPlace == .projects && selectedObject == nil {
                        DOJOInvestigationDeskView(
                            askAbout: beginInvestigationQuestion,
                            captureNote: beginNewCapture,
                            openInspector: { showingSystemInspector = true }
                        )
                    } else if let object = selectedObject {
                        selectedWorkView(object, capacity: capacity)
                    } else {
                        emptyWorkView(capacity: capacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(dojoObsidian.opacity(0.38))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(dojoObsidian.opacity(0.38))
    }

    private func dailyReentryStrip(capacity: TodaySurfaceCapacity) -> some View {
        let object = selectedObject ?? generatedObjects.first
        let evidenceLabel = reentryEvidenceLabel(for: object)
        let evidenceColor = reentryEvidenceColor(for: object)
        let sourceLabel = reentrySourceLabel(for: object)
        let homeLabel = reentryHomeLabel(for: object)
        let authorityLabel = reentryAuthorityLabel(for: object)
        let projectionLabel = reentryProjectionLabel(for: object)
        let nextMove = reentryNextMove(for: object)

        return ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: 12) {
                reentryObjectBlock(object: object, sourceLabel: sourceLabel, homeLabel: homeLabel)
                Divider().frame(height: 38).overlay(dojoDividerColor)
                reentryStatusBlock(
                    evidenceLabel: evidenceLabel,
                    evidenceColor: evidenceColor,
                    authorityLabel: authorityLabel,
                    projectionLabel: projectionLabel,
                    nextMove: nextMove
                )
                Spacer(minLength: 8)
                reentryActionRow(object: object)
            }

            VStack(alignment: .leading, spacing: 10) {
                reentryObjectBlock(object: object, sourceLabel: sourceLabel, homeLabel: homeLabel)
                HStack(alignment: .center, spacing: 10) {
                    reentryStatusBlock(
                        evidenceLabel: evidenceLabel,
                        evidenceColor: evidenceColor,
                        authorityLabel: authorityLabel,
                        projectionLabel: projectionLabel,
                        nextMove: nextMove
                    )
                    Spacer(minLength: 8)
                    reentryActionRow(object: object)
                }
            }
        }
        .padding(.horizontal, capacity == .compact ? 12 : 16)
        .padding(.vertical, 12)
        .background(dojoChrome.opacity(0.94))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Today re-entry. \(object?.title ?? "No current object"). \(sourceLabel). \(homeLabel). \(evidenceLabel). \(authorityLabel). \(projectionLabel). Next move: \(nextMove).")
    }

    private func reentryObjectBlock(
        object: GeneratedObjectShell?,
        sourceLabel: String,
        homeLabel: String
    ) -> some View {
        let chamber = object.map { roleChamber(for: $0.kind) } ?? selectedPlace.chamber
        return HStack(alignment: .center, spacing: 10) {
            Text(chamber.rawValue)
                .font(todayFont(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(canonicalRoleColor(chamber))
                .frame(width: 30, height: 30)
                .background(canonicalRoleColor(chamber).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(object?.title ?? "No current object")
                    .font(todayFont(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#EAFBFF"))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    reentryMicroAttribute(sourceLabel)
                    reentryMicroAttribute(homeLabel)
                }
            }
        }
        .frame(minWidth: 220, alignment: .leading)
    }

    private func reentryStatusBlock(
        evidenceLabel: String,
        evidenceColor: Color,
        authorityLabel: String,
        projectionLabel: String,
        nextMove: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 6) {
                Image(systemName: reentryEvidenceSymbol(for: evidenceLabel))
                    .font(todayFont(size: 10, weight: .semibold))
                    .foregroundStyle(evidenceColor)
                    .accessibilityHidden(true)
                Text(evidenceLabel)
                    .font(todayFont(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(evidenceColor)
                    .lineLimit(1)
            }

            HStack(spacing: 6) {
                reentryMicroAttribute(authorityLabel)
                reentryMicroAttribute(projectionLabel)
            }

            Text("Next: \(nextMove)")
                .font(todayFont(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(dojoTextSecondary)
                .lineLimit(1)
        }
        .frame(minWidth: 210, alignment: .leading)
    }

    private func reentryMicroAttribute(_ value: String) -> some View {
        Text(value)
            .font(todayFont(size: 9, weight: .semibold, design: .rounded))
            .foregroundStyle(dojoTextTertiary)
            .lineLimit(1)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(dojoControl.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func reentryActionRow(object: GeneratedObjectShell?) -> some View {
        HStack(spacing: 8) {
            Button {
                if let object {
                    continueFrom(object)
                } else {
                    beginNewCapture()
                }
            } label: {
                Label(object == nil ? "Capture" : "Continue", systemImage: object == nil ? "square.and.pencil" : "arrowshape.turn.up.right")
                    .font(todayFont(size: 12, weight: .bold, design: .rounded))
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "#6CEBFF"))
            .foregroundStyle(dojoObsidian)
            .help(object == nil ? "Start a local capture" : "Continue from the current object")

            Button {
                showingProofDrawer = true
            } label: {
                Label("Proof", systemImage: "checkmark.seal")
                    .font(todayFont(size: 12, weight: .semibold, design: .rounded))
            }
            .buttonStyle(.bordered)
            .disabled(object == nil)
            .help(object == nil ? "No object has proof yet" : "Show evidence for the current object")
        }
        .controlSize(.small)
    }

    private func reentrySourceLabel(for object: GeneratedObjectShell?) -> String {
        guard let object else { return "Source · local composer" }
        if let providerID = object.providerID, !providerID.isEmpty {
            return "Source · \(object.providerDisplayName)"
        }
        if object.localReceipt != nil {
            return "Source · local receipt"
        }
        if object.sourcePrompt?.isEmpty == false {
            return "Source · local prompt"
        }
        if object.isSavedLocally {
            return "Source · local object store"
        }
        return "Source · unrecorded"
    }

    private func reentryHomeLabel(for object: GeneratedObjectShell?) -> String {
        guard let object else { return "Home · \(selectedPlace.title)" }
        return "Home · \(object.home.rawValue.capitalized)"
    }

    private func reentryEvidenceLabel(for object: GeneratedObjectShell?) -> String {
        guard let object else { return "HOLD · no current object" }
        if let receipt = object.localReceipt {
            return "Evidence · receipt \(receipt.receiptID.prefix(8))"
        }
        if let packet = object.processingPacket {
            return "Evidence · \(packet.evidenceState.rawValue)"
        }
        if object.isSavedLocally {
            return "Evidence · saved object"
        }
        return "HOLD · evidence unrecorded"
    }

    private func reentryEvidenceColor(for object: GeneratedObjectShell?) -> Color {
        guard let object else { return Color(hex: "#FBBF24") }
        if object.localReceipt != nil || object.isSavedLocally {
            return Color(hex: "#86EFAC")
        }
        if object.processingPacket?.evidenceState == .witnessed || object.processingPacket?.evidenceState == .sealed {
            return Color(hex: "#86EFAC")
        }
        return Color(hex: "#FBBF24")
    }

    private func reentryAuthorityLabel(for object: GeneratedObjectShell?) -> String {
        guard let object else { return "Authority · local capture only" }
        if object.localReceipt != nil {
            return "Authority · local receipt"
        }
        if object.providerID != nil {
            return "Authority · advisory"
        }
        return "Authority · local surface"
    }

    private func reentryProjectionLabel(for object: GeneratedObjectShell?) -> String {
        guard let object else { return "Projection · capture lane" }
        if object.processingPacket?.mayProjectResolvedState == true {
            return "Projection · resolved"
        }
        if object.localReceipt != nil || object.isSavedLocally {
            return "Projection · inspectable"
        }
        return "Projection · held"
    }

    private func reentryEvidenceSymbol(for evidenceLabel: String) -> String {
        if evidenceLabel.contains("HOLD") {
            return "pause.circle"
        }
        if evidenceLabel.contains("Unknown") || evidenceLabel.contains("unknown") || evidenceLabel.contains("unrecorded") {
            return "questionmark.circle"
        }
        return "checkmark.seal"
    }

    private func reentryNextMove(for object: GeneratedObjectShell?) -> String {
        guard let object else { return "Capture a local note" }
        return object.nextAvailableAction
    }

    private func emptyWorkView(capacity: TodaySurfaceCapacity) -> some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                Spacer(minLength: 24)

            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: selectedPlace.symbol)
                        .font(todayFont(size: 13, weight: .semibold))
                        .foregroundStyle(canonicalRoleColor(selectedPlace.chamber))
                        .frame(width: 28, height: 28)
                        .background(canonicalRoleColor(selectedPlace.chamber).opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedPlace.title)
                            .font(todayFont(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(dojoTextPrimary)
                        Text(selectedPlace.surfaceRole)
                            .font(todayFont(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(dojoTextTertiary)
                    }
                    Spacer()
                    Text(emptyStateBadgeText)
                        .font(todayFont(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(emptyStateBadgeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(emptyStateBadgeColor.opacity(0.10))
                        .clipShape(Capsule())
                }

                Divider().overlay(dojoDividerColor.opacity(0.72))

                VStack(alignment: .leading, spacing: 12) {
                    Text(emptyStateHeading)
                        .font(todayFont(size: 34, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#EAFBFF"))

                    Text(selectedPlace.canvasSubtitle)
                        .font(todayFont(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#C9E4EA"))

                    HStack(spacing: 8) {
                        Text(selectedPlace.surfaceState)
                            .font(todayFont(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(selectedPlace.surfaceStateColor)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(selectedPlace.surfaceStateColor.opacity(0.10))
                            .clipShape(Capsule())
                        Text(selectedPlace.channelSummary)
                            .font(todayFont(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(dojoTextTertiary)
                    }

                    Text(emptyStateGuidance)
                        .font(todayFont(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(dojoTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 560, alignment: .leading)
                }

                HStack(spacing: 10) {
                    primaryStateAction(emptyPrimaryActionTitle, systemImage: emptyPrimaryActionIcon) {
                        runEmptyPrimaryAction()
                    }
                    secondaryStateAction("Capture note", systemImage: "square.and.pencil") {
                        beginNewCapture()
                    }
                    if lastError != nil {
                        secondaryStateAction("API keys", systemImage: "key") {
                            openSettings(section: .apiKeys)
                        }
                    }
                }

                SpatialEvidenceMapSection(
                    projection: spatialEvidenceFixture,
                    selectedProjectionID: $selectedSpatialProofID,
                    todayFont: { size, weight, design in
                        todayFont(size: size, weight: weight, design: design)
                    }
                )

                if !objectsForCurrentPlace.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Recent work")
                                .font(todayFont(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(dojoTextSecondary)
                            Spacer()
                            Text("Open to continue")
                                .font(todayFont(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(dojoTextTertiary)
                        }
                        if objectsForCurrentPlace.count > 4 {
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(todayFont(size: 11, weight: .semibold))
                                    .foregroundStyle(dojoTextTertiary)
                                TextField("Search \(selectedPlace.title.lowercased())…", text: $placeSearchText)
                                    .textFieldStyle(.plain)
                                    .font(todayFont(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(dojoTextPrimary)
                                if !placeSearchText.isEmpty {
                                    Button {
                                        placeSearchText = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(todayFont(size: 12, weight: .semibold))
                                            .foregroundStyle(dojoTextTertiary)
                                    }
                                    .buttonStyle(.plain)
                                    .help("Clear search")
                                }
                            }
                            .padding(.horizontal, 10)
                            .frame(height: 32)
                            .background(dojoControl.opacity(0.82))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        if visibleObjectsForCurrentPlace.isEmpty {
                            Text("No work matches this search.")
                                .font(todayFont(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(dojoTextTertiary)
                                .padding(.vertical, 6)
                        }

                        ForEach(visibleObjectsForCurrentPlace.prefix(8)) { object in
                            let chamber = roleChamber(for: object.kind)
                            Button {
                                selectedObjectID = object.id
                                openRightPanel(reason: .objectSelected, mode: .details)
                            } label: {
                                HStack(spacing: 10) {
                                    Text(chamber.rawValue)
                                        .font(todayFont(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundStyle(canonicalRoleColor(chamber))
                                        .frame(width: 26, height: 26)
                                        .background(canonicalRoleColor(chamber).opacity(0.10))
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(object.title)
                                            .font(todayFont(size: 12, weight: .semibold, design: .rounded))
                                            .foregroundStyle(Color(hex: "#EAFBFF"))
                                            .lineLimit(1)
                                        Text(object.subtitle)
                                            .font(todayFont(size: 10, weight: .medium, design: .rounded))
                                            .foregroundStyle(dojoTextTertiary)
                                            .lineLimit(1)
                                    }
                                    Spacer(minLength: 8)
                                    Image(systemName: "chevron.right")
                                        .font(todayFont(size: 10, weight: .bold))
                                        .foregroundStyle(dojoTextTertiary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(dojoPanel.opacity(0.88))
                                .clipShape(RoundedRectangle(cornerRadius: 9))
                            }
                            .buttonStyle(.plain)
                        }

                        if visibleObjectsForCurrentPlace.count > 8 {
                            Text("Showing 8 of \(visibleObjectsForCurrentPlace.count) matches. Refine the search to find more.")
                                .font(todayFont(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(dojoTextTertiary)
                                .padding(.top, 2)
                        }
                    }
                    .padding(.top, 4)
                }

                Text("Local work remains here. Receipts and deeper system state are available when requested.")
                    .font(todayFont(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(dojoTextTertiary)
            }
            .padding(28)
            .frame(maxWidth: 820, alignment: .leading)
            // Expansive and working surfaces stay open like the supplied
            // production references; compact capacity earns a quiet grouping
            // so the object boundary remains legible in reduced space.
            .background(
                capacity == .compact
                    ? AnyShapeStyle(dojoPanelRaised.opacity(0.92))
                    : AnyShapeStyle(Color.clear)
            )
            .overlay {
                if capacity == .compact {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(dojoDividerColor.opacity(0.92), lineWidth: 1)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: capacity == .compact ? 16 : 0))

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .scrollIndicators(.automatic)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func selectedWorkView(_ object: GeneratedObjectShell, capacity: TodaySurfaceCapacity) -> some View {
        let chamber = roleChamber(for: object.kind)
        return VStack(alignment: .leading, spacing: 0) {
            // Object chrome (minimal — not a dashboard)
            HStack(spacing: 10) {
                Text(object.title)
                    .font(todayFont(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#F2FDFF"))
                    .lineLimit(1)
                Text(object.kind.badge)
                    .font(todayFont(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(canonicalRoleColor(chamber))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(canonicalRoleColor(chamber).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Spacer()
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 6) {
                        objectActionButton("Continue", systemImage: "arrowshape.turn.up.right") {
                            continueFrom(object)
                        }
                        objectActionButton("Save", systemImage: "tray.and.arrow.down") {
                            saveObject(object)
                        }
                        objectActionButton("Export", systemImage: "square.and.arrow.up") {
                            exportObject(object)
                        }
                        objectActionButton("Details", systemImage: "info.circle") {
                            objectDetailsTarget = object
                        }
                    }
                    HStack(spacing: 8) {
                        objectActionButton("Continue", systemImage: "arrowshape.turn.up.right") {
                            continueFrom(object)
                        }
                        objectActionButton("Save", systemImage: "tray.and.arrow.down") {
                            saveObject(object)
                        }
                        objectActionButton("Export", systemImage: "square.and.arrow.up") {
                            exportObject(object)
                        }
                        objectActionButton("Details", systemImage: "info.circle") {
                            objectDetailsTarget = object
                        }
                    }
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .help("Object actions")

                Button {
                    selectedObjectID = nil
                    collapseRightPanelToHorizon()
                } label: {
                    Text("Close")
                        .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#89A8B1"))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(dojoChrome.opacity(0.92))

            Divider().overlay(dojoDividerColor.opacity(0.72))

            objectStatusStrip(object, capacity: capacity)

            objectContextPanel(object, capacity: capacity)

            ScrollView {
                Text(object.body)
                    .font(.system(
                        size: 14,
                        weight: .medium,
                        design: object.kind == .codeDiff ? .monospaced : .rounded
                    ))
                    .foregroundStyle(Color(hex: "#E8F4F7"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .padding(24)
            }
        }
    }

    // MARK: - Right utility dock

    @ViewBuilder
    private func rightUtilityDock(capacity: TodaySurfaceCapacity) -> some View {
        if isRightDockAtHorizon(for: capacity) {
            VStack(spacing: 8) {
                Button {
                    compactToolsRequested = true
                    openRightPanel(reason: .userManualToggle)
                } label: {
                    Image(systemName: "sidebar.right")
                        .font(todayFont(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hex: "#7DD3FC"))
                        .frame(width: 44, height: 36)
                }
                .buttonStyle(.plain)
                .help("Show tools")

                ForEach(RightUtilityMode.allCases) { mode in
                    Button {
                        // Explicit review/details (or other tool) request — boundary open.
                        let reason: TodayAttentionProductConstraints.RightPanelOpenReason =
                            (mode == .details || mode == .review) ? .explicitReviewOrDetails : .userManualToggle
                        openRightPanel(reason: reason, mode: mode)
                    } label: {
                        Image(systemName: mode.symbol)
                            .font(todayFont(size: 12, weight: .semibold))
                            .foregroundStyle(rightUtility == mode ? dojoObsidian : dojoTextSecondary)
                            .frame(width: 44, height: 32)
                            .background(rightUtility == mode ? Color(hex: "#6CEBFF") : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .help(mode.title)
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 10)
            .frame(width: 52)
            .background(dojoChrome.opacity(0.97))
        } else {
            VStack(spacing: 0) {
                // Mode tabs — one utility at a time (already open; no re-unfold)
                HStack(spacing: 0) {
                    ForEach(RightUtilityMode.allCases) { mode in
                        Button {
                            rightUtility = mode
                        } label: {
                            VStack(spacing: 3) {
                                Image(systemName: mode.symbol)
                                    .font(todayFont(size: 11, weight: .semibold))
                                Text(mode.shortTitle)
                                    .font(todayFont(size: 9, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(rightUtility == mode ? Color(hex: "#6CEBFF") : Color(hex: "#6B8A93"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(rightUtility == mode ? dojoControl : Color.clear)
                        }
                        .buttonStyle(.plain)
                        .help(mode.title)
                    }

                    Button {
                        collapseRightPanelToHorizon()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(todayFont(size: 10, weight: .bold))
                            .foregroundStyle(Color(hex: "#6B8A93"))
                            .frame(width: 28, height: 36)
                    }
                    .buttonStyle(.plain)
                    .help("Collapse tools")
                }
                .background(dojoChrome)

                Divider().overlay(dojoDividerColor.opacity(0.72))

                // Active utility body
                ScrollView {
                    utilityBody
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
            .frame(width: capacity.rightDockWidth)
            .background(dojoChrome.opacity(0.97))
        }
    }

    @ViewBuilder
    private var utilityBody: some View {
        switch rightUtility {
        case .details:
            detailsUtility
        case .review:
            reviewUtility
        case .files:
            filesUtility
        }
    }

    /// Contextual inspector — selection-scoped only (not system dump).
    private var detailsUtility: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(todayFont(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#EAFBFF"))
            Text("What is this object?")
                .font(todayFont(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#6B8A93"))

            if let object = selectedObject {
                detailRow("Title", object.title)
                detailRow("Type", object.kind.badge)
                detailRow("Home", object.home.rawValue.capitalized)
                detailRow("Created", object.createdAt.formatted(date: .abbreviated, time: .shortened))
                detailRow("Provider", object.providerDisplayName)
                detailRow("Model", object.modelID ?? "—")
                detailRow("Saved", object.isSavedLocally ? "Yes" : "No")
                if let receipt = object.localReceipt {
                    detailRow("Local receipt", receipt.receiptID)
                    detailRow("Receipt operation", receipt.operation)
                } else {
                    detailRow("Local receipt", "Not issued")
                }

                Text("Recovery")
                    .font(todayFont(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#A9BBC2"))
                    .padding(.top, 6)
                detailRow("Object", object.recoveryCue.objectLabel)
                detailRow("Last stable", object.lastStablePoint)
                detailRow("Next action", object.nextAvailableAction)
                detailRow("While away", object.changedWhileAway)
                if let prompt = object.sourcePrompt, !prompt.isEmpty {
                    Text("Source prompt")
                        .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#89A8B1"))
                        .padding(.top, 4)
                    Text(prompt)
                        .font(todayFont(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#C9E4EA"))
                        .lineLimit(5)
                }
                Text("Short provenance: local session · \(object.isSavedLocally ? "persisted" : "unsaved")")
                    .font(todayFont(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#6B8A93"))

                utilityButton("Proof…") { showingProofDrawer = true }
                utilityButton("Copy metadata") {
                    let md = object.asMarkdown()
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(md, forType: .string)
                    statusMessage = "Metadata copied"
                }
                utilityButton("Open System Inspector") { showingSystemInspector = true }
                utilityButton("Full details sheet…") { objectDetailsTarget = object }
            } else {
                Text("No object selected.")
                    .font(todayFont(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#89A8B1"))
                Text("Open work in the centre to inspect it here.")
                    .font(todayFont(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#6B8A93"))
            }
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#6B8A93"))
                .frame(width: 72, alignment: .leading)
            Text(value)
                .font(todayFont(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#EAFBFF"))
                .lineLimit(3)
            Spacer(minLength: 0)
        }
    }

    /// Review = work-adjacent inspect/actions, not system-wide inspector.
    private var reviewUtility: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Review")
                .font(todayFont(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#EAFBFF"))

            if let object = selectedObject {
                VStack(alignment: .leading, spacing: 8) {
                    Text(object.kind.badge)
                        .font(todayFont(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "#7DD3FC"))
                    Text(object.title)
                        .font(todayFont(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#F2FDFF"))
                    if let model = object.modelID {
                        Text("\(object.providerDisplayName) · \(model)")
                            .font(todayFont(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(hex: "#89A8B1"))
                    }
                    if object.isSavedLocally {
                        Text("Saved locally")
                            .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(hex: "#86EFAC"))
                    }
                    if let prompt = object.sourcePrompt, !prompt.isEmpty {
                        Text("Source prompt")
                            .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(hex: "#6B8A93"))
                            .padding(.top, 4)
                        Text(prompt)
                            .font(todayFont(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(hex: "#C9E4EA"))
                            .lineLimit(5)
                    }

                    HStack(spacing: 8) {
                        utilityButton("Continue") { continueFrom(object) }
                        utilityButton("Save") { saveObject(object) }
                        utilityButton("Export") { exportObject(object) }
                    }
                    utilityButton("Details") { objectDetailsTarget = object }
                    utilityButton("Proof…") { showingProofDrawer = true }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(dojoPanel)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Text("Select work in the centre or Recent list to inspect it here.")
                    .font(todayFont(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#89A8B1"))
                    .fixedSize(horizontal: false, vertical: true)

                if !objectsForCurrentPlace.isEmpty {
                    Text("Open an item")
                        .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#6B8A93"))
                        .padding(.top, 4)
                    ForEach(objectsForCurrentPlace.prefix(5)) { object in
                        Button {
                            selectedObjectID = object.id
                            openRightPanel(reason: .objectSelected, mode: .review)
                        } label: {
                            Text(object.title)
                                .font(todayFont(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(hex: "#7DD3FC"))
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var filesUtility: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Files")
                    .font(todayFont(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#EAFBFF"))
                wiringBadge("PARTIAL")
            }
            Text("Paths only — no project browser yet.")
                .font(todayFont(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#89A8B1"))

            fileRow("Application Support store", GeneratedObjectStore.storeURL.path)
            fileRow("Export folder", GeneratedObjectStore.exportDirectory.path)
        }
    }

    private func wiringBadge(_ status: String) -> some View {
        Text(status)
            .font(todayFont(size: 9, weight: .bold, design: .rounded))
            .foregroundStyle(Color(hex: "#FBBF24"))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color(hex: "#FBBF24").opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private func fileRow(_ title: String, _ path: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#89A8B1"))
            Text(path)
                .font(todayFont(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(Color(hex: "#6B8A93"))
                .lineLimit(3)
                .textSelection(.enabled)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(dojoPanel)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func utilityButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(todayFont(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#7DD3FC"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(dojoControl)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Composer (persistent)

    private var collapsedComposerBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "text.bubble")
                .font(todayFont(size: 12, weight: .semibold))
                .foregroundStyle(Color(hex: "#7DD3FC"))
            VStack(alignment: .leading, spacing: 1) {
                Text("Composer hidden")
                    .font(todayFont(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(dojoTextPrimary)
                Text("Your work remains visible. Reopen it when you want to ask, capture, or continue.")
                    .font(todayFont(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(dojoTextTertiary)
                    .lineLimit(1)
            }
            Spacer(minLength: 12)
            Button("Show composer") {
                withAnimation(.easeInOut(duration: 0.18)) {
                    bottomComposerCollapsed = false
                }
            }
            .font(todayFont(size: 11, weight: .semibold, design: .rounded))
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(dojoChrome.opacity(0.98))
    }

    private func bottomComposer(capacity: TodaySurfaceCapacity) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Button {
                chooseAttachments()
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "paperclip")
                        .font(todayFont(size: 13, weight: .semibold))
                        .foregroundStyle(Color(hex: "#7DD3FC"))
                        .frame(width: 30, height: 30)
                        .background(dojoControl.opacity(0.86))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    if !attachedFiles.isEmpty {
                        Text("\(attachedFiles.count)")
                            .font(todayFont(size: 8, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(hex: "#031416"))
                            .padding(3)
                            .background(Color(hex: "#FBBF24"))
                            .clipShape(Circle())
                            .offset(x: 5, y: -5)
                    }
                }
            }
            .buttonStyle(.plain)
            .help("Choose local files. Capture stores metadata and issues a local receipt; model analysis remains held.")
            .accessibilityLabel(attachedFiles.isEmpty ? "Attach local files" : "Attach local files, \(attachedFiles.count) selected")

            if !attachedFiles.isEmpty {
                Menu {
                    ForEach(attachedFiles, id: \.self) { url in
                        Button {
                            removeAttachment(url)
                        } label: {
                            Label("Remove \(url.lastPathComponent)", systemImage: "xmark")
                        }
                    }
                } label: {
                    Text("\(attachedFiles.count) local file\(attachedFiles.count == 1 ? "" : "s")")
                        .font(todayFont(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#FBBF24"))
                        .lineLimit(1)
                }
                .menuStyle(.borderlessButton)
                .help("Selected files are metadata-only until a local Capture is kept")
            }

            composerHeldControl(
                systemImage: "mic",
                help: "Voice capture is not wired yet. This input path remains HOLD."
            )

            TextField(composerPlaceholder, text: $composerText, axis: .vertical)
                .textFieldStyle(.plain)
                .font(todayFont(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#EAFBFF"))
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(dojoPanelRaised.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(dojoDividerColor, lineWidth: 1)
                )
                .disabled(isRequesting)
                .onSubmit { Task { await submitComposer() } }

            Picker("", selection: $selectedMode) {
                ForEach(ComposerMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .labelsHidden()
            .frame(width: 88)
            .controlSize(.small)
            .tint(Color(hex: "#C9E4EA"))
            .background(dojoControl)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .help("DOJO = spinning-top portal · Ask = hosted advisory · Capture = local object · Review = open Review dock")
            .onChange(of: selectedMode) { _, mode in
                if mode == .review {
                    openRightPanel(reason: .explicitReviewOrDetails, mode: .review)
                }
            }

            if selectedMode == .ask && capacity != .compact {
                Picker("", selection: $selectedProvider) {
                    ForEach(HostedProviderCatalog.liveProviders) { p in
                        Text(p.displayName).tag(p)
                    }
                }
                .labelsHidden()
                .frame(width: 110)
                .controlSize(.small)
                .tint(Color(hex: "#C9E4EA"))
                .background(dojoControl)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .onChange(of: selectedProvider) { _, p in
                    selectedModelID = HostedProviderCatalog.resolvedModelID(provider: p, preferred: selectedModelID)
                    M1Preferences.setDefault(provider: p, modelID: selectedModelID)
                }

                Picker("", selection: $selectedModelID) {
                    ForEach(selectedProvider.models.filter(\.isEnabled)) { m in
                        Text(m.displayName).tag(m.id)
                    }
                }
                .labelsHidden()
                .frame(width: 130)
                .controlSize(.small)
                .tint(Color(hex: "#C9E4EA"))
                .background(dojoControl)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .onChange(of: selectedModelID) { _, m in
                    M1Preferences.setDefault(provider: selectedProvider, modelID: m)
                }
            } else if selectedMode == .ask {
                compactHostedModelMenu
            }

            Button {
                Task { await submitComposer() }
            } label: {
                Text(isRequesting ? "…" : composerActionTitle)
                    .font(todayFont(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#031416"))
                    .padding(.horizontal, 16)
                    .frame(height: 38)
                    .background(isRequesting ? Color(hex: "#4A6B74") : Color(hex: "#5CAEFF"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .disabled(isRequesting || !composerCanSubmit)
            .help(composerActionHelp)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(dojoChrome.opacity(0.98))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isDropTargeted ? Color(hex: "#6CEBFF") : .clear,
                    style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .allowsHitTesting(false)
        }
        .onDrop(of: [UTType.fileURL], isTargeted: $isDropTargeted) { providers in
            handleFileDrop(providers)
        }
    }

    private var compactHostedModelMenu: some View {
        Menu {
            Section("Provider") {
                ForEach(HostedProviderCatalog.liveProviders) { provider in
                    Button {
                        selectedProvider = provider
                        selectedModelID = HostedProviderCatalog.resolvedModelID(
                            provider: provider,
                            preferred: selectedModelID
                        )
                        M1Preferences.setDefault(provider: provider, modelID: selectedModelID)
                    } label: {
                        HStack {
                            Text(provider.displayName)
                            if provider == selectedProvider {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            Section("Model") {
                ForEach(selectedProvider.models.filter(\ .isEnabled)) { model in
                    Button {
                        selectedModelID = model.id
                        M1Preferences.setDefault(provider: selectedProvider, modelID: model.id)
                    } label: {
                        HStack {
                            Text(model.displayName)
                            if model.id == selectedModelID {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            VStack(alignment: .leading, spacing: 1) {
                Text(selectedProvider.displayName)
                    .font(todayFont(size: 10, weight: .semibold, design: .rounded))
                Text(selectedModelDisplayName)
                    .font(todayFont(size: 9, weight: .medium, design: .rounded))
                    .lineLimit(1)
            }
            .foregroundStyle(Color(hex: "#C9E4EA"))
            .frame(width: 132, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(dojoControl)
            .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .menuStyle(.borderlessButton)
        .help("Hosted provider and model. Current: \(selectedProvider.displayName) · \(selectedModelDisplayName)")
    }

    private var selectedModelDisplayName: String {
        selectedProvider.models.first(where: { $0.id == selectedModelID })?.displayName ?? selectedModelID
    }

    private func objectActionButton(
        _ title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
        }
        .help(title)
    }

    private func surfaceMeasurementOverlay(
        capacity: TodaySurfaceCapacity,
        dimensions: CGSize
    ) -> some View {
        let leftWidth = leftRailCollapsed ? 52 : 188
        let rightWidth = isRightDockAtHorizon(for: capacity) ? 52 : capacity.rightDockWidth
        let centreWidth = max(0, dimensions.width - CGFloat(leftWidth) - rightWidth)

        return VStack(alignment: .leading, spacing: 4) {
            Text("Surface specimen · \(capacity.title)\(boundaryTestMode && accessibilitySpecimen ? " · Accessibility enlargement" : "")")
                .font(todayFont(size: 11, weight: .bold, design: .monospaced))
            Text("\(Int(dimensions.width.rounded())) × \(Int(dimensions.height.rounded())) · left \(leftWidth) · centre \(Int(centreWidth.rounded())) · right \(Int(rightWidth.rounded()) )")
                .font(todayFont(size: 10, weight: .medium, design: .monospaced))
            Text("Centre dominant · composer \(bottomComposerCollapsed ? "folded" : "open") · \(capacity.composerPosture)")
                .font(todayFont(size: 10, weight: .medium, design: .rounded))
            Text("Developer measurement only · no processing or authority state")
                .font(todayFont(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#A9BBC2"))
        }
        .foregroundStyle(Color(hex: "#EAFBFF"))
        .padding(10)
        .background(Color(hex: "#121A2B").opacity(0.94))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#6CEBFF").opacity(0.7), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .allowsHitTesting(false)
    }

    /// Production-surface affordances for input paths that remain explicitly
    /// held. The icon is visible for topology, but cannot imply a working
    /// Dictation or voice-to-voice action.
    private func composerHeldControl(systemImage: String, help: String) -> some View {
        Image(systemName: systemImage)
            .font(todayFont(size: 13, weight: .semibold))
            .foregroundStyle(dojoTextTertiary)
            .frame(width: 30, height: 30)
            .background(dojoControl.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .help(help)
            .accessibilityLabel(help)
    }

    /// The native Mac file chooser is the first half of the attachment seam.
    /// It deliberately stops at local metadata intake; no model or chamber
    /// receives the selected URLs from this view.
    @MainActor
    private func chooseAttachments() {
        let panel = NSOpenPanel()
        panel.title = "Attach to DOJO Today"
        panel.message = "Choose files for a local Capture. File analysis remains held."
        panel.prompt = "Attach"
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.data, .image, .pdf, .text, .audio, .movie]

        guard panel.runModal() == .OK else { return }
        stageAttachments(panel.urls)
    }

    /// Native drag-and-drop joins the same existing attachment seam as the
    /// file chooser. It only stages local URLs; Capture remains the sole route
    /// that materialises metadata and issues a receipt.
    private func handleFileDrop(_ providers: [NSItemProvider]) -> Bool {
        let fileType = UTType.fileURL.identifier
        let fileProviders = providers.filter {
            $0.hasItemConformingToTypeIdentifier(fileType)
        }
        guard !fileProviders.isEmpty else { return false }

        for provider in fileProviders {
            provider.loadItem(forTypeIdentifier: fileType, options: nil) { item, _ in
                guard let url = Self.fileURL(from: item) else { return }
                DispatchQueue.main.async {
                    stageAttachments([url])
                }
            }
        }
        return true
    }

    private static func fileURL(from item: NSSecureCoding?) -> URL? {
        if let url = item as? URL { return url }
        if let url = item as? NSURL { return url as URL }
        if let data = item as? Data {
            return URL(dataRepresentation: data, relativeTo: nil)
        }
        if let path = item as? String {
            return URL(fileURLWithPath: path)
        }
        return nil
    }

    @MainActor
    private func stageAttachments(_ urls: [URL]) {
        for url in urls where !attachedFiles.contains(url) {
            _ = url.startAccessingSecurityScopedResource()
            attachedFiles.append(url)
        }
        if !attachedFiles.isEmpty {
            lastError = nil
            statusMessage = "\(attachedFiles.count) local file\(attachedFiles.count == 1 ? "" : "s") staged. Capture to issue a local receipt; model analysis remains HOLD."
        }
    }

    private func removeAttachment(_ url: URL) {
        guard let index = attachedFiles.firstIndex(of: url) else { return }
        attachedFiles[index].stopAccessingSecurityScopedResource()
        attachedFiles.remove(at: index)
        statusMessage = attachedFiles.isEmpty
            ? "Local file intake cleared."
            : "\(attachedFiles.count) local file\(attachedFiles.count == 1 ? "" : "s") remains staged."
    }

    private func clearAttachments() {
        attachedFiles.forEach { $0.stopAccessingSecurityScopedResource() }
        attachedFiles.removeAll()
    }

    private var attachmentMetadataBody: String {
        attachedFiles.map { url in
            let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentTypeKey])
            let size = values?.fileSize.map { ByteCountFormatter.string(fromByteCount: Int64($0), countStyle: .file) } ?? "size unknown"
            let type = values?.contentType?.preferredMIMEType ?? "type unknown"
            return "- \(url.lastPathComponent) · \(type) · \(size) · bytes not analysed"
        }.joined(separator: "\n")
    }

    private var composerPlaceholder: String {
        switch selectedMode {
        case .dojoPortal: return "Ask DOJO…"
        case .ask: return "Ask a hosted model…"
        case .capture: return "Type a note, then Keep"
        case .review: return "Add a note, or open Review…"
        }
    }

    private var composerCanSubmit: Bool {
        if selectedMode == .review { return true }
        if !composerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return true }
        return selectedMode == .capture && !attachedFiles.isEmpty
    }

    private var composerActionTitle: String {
        switch selectedMode {
        case .dojoPortal: return "Send"
        case .ask: return "Send"
        case .capture: return "Keep"
        case .review: return "Review"
        }
    }

    private var composerActionHelp: String {
        switch selectedMode {
        case .dojoPortal: return "Send through the DOJO Suite mirror portal to the DOJO spinning top"
        case .ask: return "Send to hosted model"
        case .capture: return "Save this note on your Mac"
        case .review: return "Open Review tools without sending to a hosted model"
        }
    }

    private var emptyStateGuidance: String {
        if lastError != nil {
            return "The last action needs attention. Keep working locally with Capture, or open API keys if you want hosted answers."
        }
        switch selectedPlace {
        case .projects:
            return "Use the investigation desk to choose a live thread, then ask about it, capture evidence, or inspect boundaries."
        case .threads:
            return "Threads hold conversations as local work objects. Start a bounded turn below, then open the result to continue or review it."
        case .captures:
            return "Capture keeps a local object without calling a model. Save or export once it matters."
        case .media:
            return "Media is a review surface. Local file metadata can be captured; file and image analysis remains held."
        case .documents:
            return "Documents is the drafting surface. Start from the DOJO portal or open an existing document; the surface does not claim a document has been created until an object exists."
        default:
            return "Type a note below and press Keep. It is saved on this Mac. Open Proof to see the stamp."
        }
    }

    private var emptyPrimaryActionTitle: String {
        if lastError != nil { return "Resolve status" }
        switch selectedPlace {
        case .projects: return "Ask from investigation"
        case .captures: return "New capture"
        case .threads: return selectedMode == .ask && providerHasSavedKey(selectedProvider) ? "Ask model" : "Start thread"
        case .media: return "Open captures"
        case .documents: return "Start with DOJO"
        default:
            return "New capture"
        }
    }

    private var emptyPrimaryActionIcon: String {
        if lastError != nil { return "exclamationmark.triangle" }
        switch selectedPlace {
        case .projects: return "doc.text.magnifyingglass"
        case .captures: return "square.and.pencil"
        case .threads: return selectedMode == .ask && providerHasSavedKey(selectedProvider) ? "paperplane" : "text.bubble"
        case .media: return "tray.and.arrow.down"
        case .documents: return "arrow.triangle.2.circlepath"
        default:
            return "square.and.pencil"
        }
    }

    private var emptyStateHeading: String {
        selectedPlace == .today ? greetingLine : selectedPlace.surfaceHeading
    }

    private var emptyStateBadgeText: String {
        if lastError != nil { return "NEEDS ATTENTION" }
        return selectedPlace.surfaceState
    }

    private var emptyStateBadgeColor: Color {
        if lastError != nil { return Color(hex: "#FBBF24") }
        return selectedPlace.surfaceStateColor
    }

    // MARK: - Attention product gates (A/B — not decorative doctrine)

    /// Boundary-aware right panel open. No unfold without a lawful reason.
    private func openRightPanel(
        reason: TodayAttentionProductConstraints.RightPanelOpenReason,
        mode: RightUtilityMode? = nil
    ) {
        guard TodayAttentionProductConstraints.isRightPanelOpenLawful(reason) else { return }
        if let mode { rightUtility = mode }
        // Single boundary transition only — not repeated decorative motion.
        guard TodayAttentionProductConstraints.isMotionLawful(.boundaryPanelTransition) else {
            rightRailCollapsed = false
            return
        }
        withAnimation(.easeInOut(duration: 0.18)) {
            rightRailCollapsed = false
        }
    }

    /// Return contextual tools to horizon (release/recover).
    private func collapseRightPanelToHorizon() {
        withAnimation(.easeInOut(duration: 0.18)) {
            rightRailCollapsed = true
            compactToolsRequested = false
        }
    }

    private func isRightDockAtHorizon(for capacity: TodaySurfaceCapacity) -> Bool {
        rightRailCollapsed || (capacity == .compact && !compactToolsRequested)
    }

    // MARK: - State helpers

    private var selectedObject: GeneratedObjectShell? {
        generatedObjects.first { $0.id == selectedObjectID }
    }

    private var greetingLine: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning."
        case 12..<17: return "Good afternoon."
        case 17..<22: return "Good evening."
        default: return "Welcome back."
        }
    }

    // MARK: - M1 / object actions (retained; not primary UI chrome)

    private func openSettings(section: SettingsSection = .models) {
        settingsInitialSection = section
        showingSettings = true
    }

    private func beginNewCapture() {
        selectedPlace = .captures
        selectedObjectID = nil
        placeSearchText = ""
        composerText = ""
        selectedMode = .capture
        lastError = nil
        statusMessage = "Capture mode — type a note and Keep (local, no API)."
        collapseRightPanelToHorizon()
    }

    private func beginInvestigationQuestion(_ subject: String) {
        selectedPlace = .projects
        selectedObjectID = nil
        placeSearchText = ""
        selectedMode = .ask
        composerText = "Investigate: \(subject)\n\nWhat is known, what is only represented, what is blocked, and what is the next evidence?"
        openRightPanel(reason: .explicitReviewOrDetails, mode: .review)
        statusMessage = providerHasSavedKey(selectedProvider)
            ? "Investigation prompt prepared — edit and Send."
            : "Investigation prompt prepared — add an API key or switch to Capture."
    }

    private func runEmptyPrimaryAction() {
        if lastError != nil {
            openSettings(section: .apiKeys)
            return
        }
        switch selectedPlace {
        case .projects:
            beginInvestigationQuestion("selected investigation lane")
        case .captures:
            beginNewCapture()
        case .media:
            selectPlace(.captures)
            statusMessage = "Media analysis is held. Captures is the local entry point for metadata-only file intake."
        case .threads:
            if selectedMode == .capture { selectedMode = .dojoPortal }
            statusMessage = selectedMode == .ask
                ? "Thread composer ready — type a bounded turn and Send."
                : "Thread composer ready — type a bounded turn for the DOJO portal."
        case .documents:
            selectedMode = .dojoPortal
            statusMessage = "Document drafting route ready — type a bounded request in the composer."
        default:
            beginNewCapture()
        }
    }

    /// Objects relevant to a place (honest filter; not full libraries).
    private func objects(for place: TodayPlace) -> [GeneratedObjectShell] {
        switch place {
        case .today:
            return generatedObjects
        default:
            return generatedObjects.filter { $0.home == place.objectHome }
        }
    }

    private var objectsForCurrentPlace: [GeneratedObjectShell] {
        objects(for: selectedPlace)
    }

    private var visibleObjectsForCurrentPlace: [GeneratedObjectShell] {
        let query = placeSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return objectsForCurrentPlace }
        return objectsForCurrentPlace.filter { object in
            [object.title, object.subtitle, object.body]
                .joined(separator: "\n")
                .localizedCaseInsensitiveContains(query)
        }
    }

    /// Keep navigation and object scope aligned without introducing a second store.
    /// A selected object may remain visible only when the destination place owns its
    /// current representation; otherwise the stale centre and contextual dock close.
    private func selectPlace(_ place: TodayPlace) {
        selectedPlace = place
        placeSearchText = ""
        guard let selectedObjectID else { return }
        guard objects(for: place).contains(where: { $0.id == selectedObjectID }) else {
            self.selectedObjectID = nil
            collapseRightPanelToHorizon()
            statusMessage = "Moved to \(place.title)."
            return
        }
    }

    @MainActor
    private func submitComposer() async {
        switch selectedMode {
        case .capture:
            createLocalCapture()
        case .review:
            openRightPanel(reason: .explicitReviewOrDetails, mode: .review)
            if composerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                statusMessage = "Review open — select an object or type a follow-up."
            } else {
                statusMessage = "Review mode does not send to a hosted model. Switch to Ask to send, or Capture to keep this note locally."
            }
        case .dojoPortal:
            await submitDojoPortalIntent()
        case .ask:
            await submitHostedIntent()
        }
    }

    /// The primary Today route is the existing DOJO spinning-top portal.
    /// Failures remain visible; there is no local or hosted fallback here.
    @MainActor
    private func submitDojoPortalIntent() async {
        guard attachedFiles.isEmpty else {
            lastError = "Local files are staged, but DOJO file analysis remains HOLD. Switch to Capture to receipt the metadata."
            return
        }
        let trimmed = composerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        lastError = nil
        statusMessage = ""
        isRequesting = true
        defer { isRequesting = false }

        do {
            let response = try await SpinningTopClient().sendMessage(trimmed)
            guard response.inferenceAvailable else {
                let detail = response.response
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .prefix(180)
                lastError = detail.isEmpty
                    ? "DOJO portal reached · inference HOLD · \(response.model_used)"
                    : "DOJO portal reached · inference HOLD · \(response.model_used): \(detail)"
                return
            }
            var answer = GeneratedObjectShell(
                kind: .answer,
                home: .threads,
                title: "DOJO · \(trimmed.prefix(48))",
                body: response.response,
                subtitle: "DOJO spinning top · \(response.chamber ?? "DOJO")",
                providerID: "DOJO spinning top",
                modelID: response.model_used,
                sourcePrompt: trimmed,
                lastStablePoint: "portal_response_received",
                nextAvailableAction: "Review · Save · Export · Continue",
                changedWhileAway: "none"
            )
            answer.processingPacket = TodayProcessingPacket.portalResponseHold(
                objectID: answer.id.uuidString
            )
            presentCompleted(
                answer,
                operation: LocalCaptureReceipt.Operation.portalResponse,
                result: LocalCaptureReceipt.Outcome.completed,
                place: .threads,
                successStatus: "DOJO portal response ready · \(response.model_used)"
            )
        } catch {
            lastError = "DOJO portal unavailable: \(error.localizedDescription)"
        }
    }

    private func createLocalCapture() {
        let trimmed = composerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || !attachedFiles.isEmpty else { return }
        lastError = nil
        let short = trimmed.isEmpty ? "local files" : String(trimmed.prefix(48))
        let body: String
        if attachedFiles.isEmpty {
            body = trimmed
        } else if trimmed.isEmpty {
            body = "Local file intake (metadata only)\n\n\(attachmentMetadataBody)"
        } else {
            body = "\(trimmed)\n\nLocal file intake (metadata only)\n\n\(attachmentMetadataBody)"
        }
        let object = GeneratedObjectShell(
            kind: .document,
            home: .captures,
            title: "Capture · \(short)",
            body: body,
            subtitle: attachedFiles.isEmpty ? "Local capture" : "Local capture · metadata only",
            sourcePrompt: trimmed,
            lastStablePoint: "capture_kept",
            nextAvailableAction: "Review · Save · Export · Continue",
            changedWhileAway: "none"
        )
        presentCompleted(
            object,
            operation: LocalCaptureReceipt.Operation.capture,
            result: LocalCaptureReceipt.Outcome.captured,
            place: .captures,
            successStatus: "Capture kept locally"
        )
        clearAttachments()
    }

    @MainActor
    private func submitHostedIntent() async {
        guard attachedFiles.isEmpty else {
            lastError = "Local files are staged, but hosted file analysis remains HOLD. Switch to Capture to receipt the metadata."
            return
        }
        let trimmed = composerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        lastError = nil
        statusMessage = ""

        guard selectedProvider.isHostedLive else {
            lastError = "Choose a hosted provider in the composer."
            return
        }
        guard providerHasSavedKey(selectedProvider) else {
            lastError = "No API key for \(selectedProvider.displayName). Open Settings → API keys."
            openSettings(section: .apiKeys)
            return
        }
        let observerContext = FieldSurfaceCoordinationCatalog.observerContext(for: "local-operator")
        let permissionProfile = observerContext.flatMap {
            FieldSurfaceCoordinationCatalog.permissionProfile(for: $0.permissionProfileID)
        }
        let providerBoundary = CapabilityBoundaryPolicy.provider(
            providerID: selectedProvider.rawValue,
            hasKey: true,
            wasTested: true,
            testSucceeded: true
        )
        let preflight = HarmonicKernelPreflightPolicy.hostedAdvisoryRequest(
            prompt: trimmed,
            hasStagedFiles: !attachedFiles.isEmpty,
            providerBoundary: providerBoundary,
            observerContext: observerContext,
            permissionProfile: permissionProfile
        )
        guard preflight.mayProceed else {
            let law = preflight.blockedLaw?.rawValue ?? "UNKNOWN"
            let holds = preflight.holds.isEmpty ? "HOLD.HarmonicKernel" : preflight.holds.joined(separator: " · ")
            lastError = "\(law) \(holds): \(preflight.reason)"
            return
        }

        isRequesting = true
        defer { isRequesting = false }

        let contextBody: String? = {
            guard let obj = selectedObject else { return nil }
            var parts: [String] = []
            if let p = obj.sourcePrompt, !p.isEmpty { parts.append("Prior prompt: \(p)") }
            parts.append(obj.body)
            return parts.joined(separator: "\n\n")
        }()

        do {
            let response = try await HostedChatClient.complete(
                HostedChatRequest(
                    provider: selectedProvider,
                    modelID: selectedModelID,
                    userMessage: trimmed,
                    contextBody: contextBody
                )
            )
            let answer = GeneratedObjectShell.answer(
                body: response.text,
                provider: response.provider,
                modelID: response.modelID,
                sourcePrompt: trimmed
            )
            presentCompleted(
                answer,
                operation: LocalCaptureReceipt.Operation.hostedAnswer,
                result: LocalCaptureReceipt.Outcome.completed,
                place: .threads,
                successStatus: "Answer ready · HTTP \(response.httpStatus)"
            )
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// Input → local object → persistence → receipt. Failures stay visible.
    private func presentCompleted(
        _ object: GeneratedObjectShell,
        operation: String,
        result: String,
        place: TodayPlace,
        successStatus: String
    ) {
        do {
            let completed = try GeneratedObjectStore.complete(
                object,
                operation: operation,
                result: result
            )
            generatedObjects.insert(completed.object, at: 0)
            selectedObjectID = completed.object.id
            selectedPlace = place
            openRightPanel(reason: .resultGenerated, mode: .details)
            composerText = ""
            lastError = nil
            statusMessage = "\(successStatus) · receipt \(completed.receipt.receiptID.prefix(8))"
        } catch {
            generatedObjects.insert(object, at: 0)
            selectedObjectID = object.id
            selectedPlace = place
            openRightPanel(reason: .resultGenerated, mode: .details)
            composerText = ""
            lastError = "Work is on the canvas, but the local receipt failed: \(error.localizedDescription)"
        }
    }

    private func continueFrom(_ object: GeneratedObjectShell) {
        selectedObjectID = object.id
        if let idx = generatedObjects.firstIndex(where: { $0.id == object.id }) {
            generatedObjects[idx].lastStablePoint = "continue_prepared"
            generatedObjects[idx].nextAvailableAction = "Edit composer · Send"
            generatedObjects[idx].changedWhileAway = "none"
        }
        openRightPanel(reason: .objectSelected, mode: .review)
        if composerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            composerText = "Continue from the selected work."
        }
        statusMessage = "Context set — edit the composer and Send."
    }

    private func saveObject(_ object: GeneratedObjectShell) {
        do {
            var toSave = object
            toSave.lastStablePoint = "saved_locally"
            toSave.nextAvailableAction = "Export · Continue · Close"
            toSave.changedWhileAway = "none"
            let saved = try GeneratedObjectStore.save(toSave)
            if let idx = generatedObjects.firstIndex(where: { $0.id == object.id }) {
                generatedObjects[idx] = saved
            }
            statusMessage = "Saved"
            lastError = nil
        } catch {
            lastError = "Save failed: \(error.localizedDescription)"
        }
    }

    private func exportObject(_ object: GeneratedObjectShell) {
        do {
            var updated = object
            updated.lastStablePoint = "exported"
            updated.nextAvailableAction = "Continue · Close"
            updated.changedWhileAway = "none"
            _ = try GeneratedObjectStore.export(updated, mode: .clipboard)
            let path = try GeneratedObjectStore.export(updated, mode: .markdownFile)
            if let idx = generatedObjects.firstIndex(where: { $0.id == object.id }) {
                generatedObjects[idx] = updated
                if updated.isSavedLocally {
                    _ = try? GeneratedObjectStore.save(updated)
                }
            }
            statusMessage = "Exported · \(path)"
            lastError = nil
        } catch {
            lastError = "Export failed: \(error.localizedDescription)"
        }
    }

    private func reloadFromDisk() {
        let disk = GeneratedObjectStore.loadAll()
        var map: [UUID: GeneratedObjectShell] = [:]
        for o in disk { map[o.id] = o }
        for o in generatedObjects { map[o.id] = o }
        generatedObjects = map.values.sorted { $0.createdAt > $1.createdAt }
    }

    /// Opening the app should show the last real note, not an empty wireframe.
    private func openLatestWorkIfNothingSelected() {
        guard selectedObjectID == nil, let newest = generatedObjects.first else { return }
        selectedObjectID = newest.id
        selectedMode = .capture
        if newest.home == .captures {
            selectedPlace = .captures
        }
    }

    private func seedSampleObjects() {
        generatedObjects = [
            GeneratedObjectShell(
                kind: .answer,
                home: .threads,
                title: "Sample answer",
                body: "Offline sample body for shell review. Not a live API response.",
                subtitle: "Seeded",
                sourcePrompt: "seed"
            ),
            GeneratedObjectShell(
                kind: .document,
                home: .documents,
                title: "Notes.md",
                body: "# Notes\n\nDocument body in centre when opened.",
                subtitle: "Document"
            )
        ]
        selectedObjectID = generatedObjects.first?.id
        if selectedObjectID != nil {
            openRightPanel(reason: .objectSelected, mode: .details)
        }
    }
}

/// Keeps the ordinary DOJO portal from inheriting a previous full-screen
/// window state on every rebuild/relaunch. This is an experience-layer seam:
/// it does not alter surface capacity, processing, object state, or authority.
@available(macOS 14.0, *)
private struct DOJOWindowPresentationGuard: NSViewRepresentable {
    final class Coordinator {
        var didApply = false
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        NSView(frame: .zero)
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard !context.coordinator.didApply else { return }

        let apply = {
            guard !context.coordinator.didApply,
                  let window = nsView.window else { return }

            context.coordinator.didApply = true
            if window.styleMask.contains(.fullScreen) {
                window.toggleFullScreen(nil)
            }
        }

        if nsView.window == nil {
            DispatchQueue.main.async(execute: apply)
        } else {
            apply()
        }
    }
}

// MARK: - Right utility modes (workspace-adjacent only)

private enum RightUtilityMode: String, CaseIterable, Identifiable {
    case details
    case review
    case files

    var id: String { rawValue }

    var title: String {
        switch self {
        case .details: return "Details"
        case .review: return "Review"
        case .files: return "Files"
        }
    }

    var shortTitle: String {
        switch self {
        case .details: return "Details"
        case .review: return "Review"
        case .files: return "Files"
        }
    }

    var symbol: String {
        switch self {
        case .details: return "info.circle"
        case .review: return "doc.text.magnifyingglass"
        case .files: return "folder"
        }
    }
}

// MARK: - Places / composer mode

private enum TodayPlace: String, CaseIterable, Identifiable {
    case today, threads, captures, media, documents, projects
    var id: String { rawValue }

    var objectHome: GeneratedObjectHome {
        switch self {
        case .today: return .today
        case .threads: return .threads
        case .captures: return .captures
        case .media: return .media
        case .documents: return .documents
        case .projects: return .investigations
        }
    }
    static var firstScreenPlaces: [TodayPlace] {
        [.today, .threads, .captures, .media, .documents, .projects]
    }
    var title: String {
        switch self {
        case .today: return "Today"
        case .threads: return "Threads"
        case .captures: return "Captures"
        case .media: return "Media"
        case .documents: return "Documents"
        case .projects: return "Investigations"
        }
    }
    var symbol: String {
        switch self {
        case .today: return "sun.max"
        case .threads: return "bubble.left.and.bubble.right"
        case .captures: return "tray.and.arrow.down"
        case .media: return "photo.on.rectangle"
        case .documents: return "doc.text"
        case .projects: return "folder"
        }
    }
    var chamber: Chamber {
        switch self {
        case .today: return .obiwan
        case .threads: return .kings
        case .captures: return .tata
        case .media: return .obiwan
        case .documents: return .dojo
        case .projects: return .atlas
        }
    }
    var canvasSubtitle: String {
        switch self {
        case .today: return "What would you like to work on?"
        case .threads: return "Open a thread to continue the conversation."
        case .captures: return "Captures you kept."
        case .media: return "Images and media."
        case .documents: return "Documents and drafts."
        case .projects: return "Investigations, manifestations, and longer work."
        }
    }

    var surfaceHeading: String {
        switch self {
        case .today: return "Today"
        case .threads: return "Continue the thread."
        case .captures: return "Keep what matters."
        case .media: return "Review your media."
        case .documents: return "Shape a document."
        case .projects: return "Follow the evidence."
        }
    }

    var surfaceRole: String {
        switch self {
        case .today: return "Working surface"
        case .threads: return "Conversation surface"
        case .captures: return "Local capture surface"
        case .media: return "Media review surface"
        case .documents: return "Drafting surface"
        case .projects: return "Investigation surface"
        }
    }

    var channelSummary: String {
        switch self {
        case .today: return "Ask · Capture · Continue"
        case .threads: return "Conversation objects · Local continuity"
        case .captures: return "Local note · Receipt"
        case .media: return "Review · Analysis held"
        case .documents: return "Draft · Review · Export"
        case .projects: return "Evidence · Boundaries · Next move"
        }
    }

    var surfaceState: String {
        switch self {
        case .media: return "INTAKE HELD"
        default: return "READY"
        }
    }

    var surfaceStateColor: Color {
        switch self {
        case .media: return Color(hex: "#FBBF24")
        default: return Color(hex: "#86EFAC")
        }
    }
}

private enum ComposerMode: String, CaseIterable, Identifiable {
    case dojoPortal = "dojo_portal"
    case ask, capture, review
    var id: String { rawValue }
    var title: String {
        switch self {
        case .dojoPortal: return "DOJO"
        case .ask: return "Ask"
        case .capture: return "Capture"
        case .review: return "Review"
        }
    }
}

/// Presentation-only capacity classification for the Today shell.
///
/// These are candidate breakpoints for the FIELD Matrix surface specimens,
/// not claims about device classes or user attention. Processing, routing,
/// persistence, and authority do not depend on this value.
private enum TodaySurfaceCapacity: Equatable {
    case expansive
    case working
    case compact

    init(width: CGFloat) {
        if width >= 1240 {
            self = .expansive
        } else if width >= 980 {
            self = .working
        } else {
            self = .compact
        }
    }

    var title: String {
        switch self {
        case .expansive: return "Expansive"
        case .working: return "Working"
        case .compact: return "Compact"
        }
    }

    var rightDockWidth: CGFloat {
        switch self {
        case .expansive: return 300
        case .working: return 272
        case .compact: return 248
        }
    }

    var composerPosture: String {
        switch self {
        case .expansive: return "full provider/model controls"
        case .working: return "full provider/model controls"
        case .compact: return "provider/model behind one menu"
        }
    }
}

// MARK: - Details / Proof / Settings (unchanged role; secondary)

@available(macOS 14.0, *)
private struct ObjectDetailsSheet: View {
    let object: GeneratedObjectShell
    var openProof: () -> Void
    var openInspector: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Details")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#EAFBFF"))
                Spacer()
                dismissX { dismiss() }
            }
            Text("This object only — not the whole system.")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#89A8B1"))
            LabeledContent("Type", value: object.kind.badge)
            LabeledContent("Provider", value: object.providerDisplayName)
            LabeledContent("Model", value: object.modelID ?? "—")
            LabeledContent("Saved", value: object.isSavedLocally ? "Yes" : "No")
            LabeledContent("Created", value: object.createdAt.formatted(date: .abbreviated, time: .shortened))
            if let packet = object.processingPacket {
                Text("Processing")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#A9BBC2"))
                    .padding(.top, 4)
                LabeledContent("Resolution", value: packet.resolution.rawValue)
                LabeledContent("Evidence", value: packet.evidenceState.rawValue)
                if let holdReason = packet.holdReason {
                    Text(holdReason)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#FBBF24"))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Text("Recovery")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#A9BBC2"))
                .padding(.top, 4)
            LabeledContent("Object", value: object.recoveryCue.objectLabel)
            LabeledContent("Last stable point", value: object.lastStablePoint)
            LabeledContent("Next action", value: object.nextAvailableAction)
            LabeledContent("Changed while away", value: object.changedWhileAway)
            if let prompt = object.sourcePrompt, !prompt.isEmpty {
                Text("Source prompt")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#89A8B1"))
                Text(prompt)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#C9E4EA"))
                    .lineLimit(6)
            }
            Button {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: openProof)
            } label: {
                Label("Proof…", systemImage: "checkmark.seal")
                    .foregroundStyle(Color(hex: "#7DD3FC"))
            }
            .buttonStyle(.plain)
            Button {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: openInspector)
            } label: {
                Label("Open System Inspector", systemImage: "wrench.and.screwdriver")
                    .foregroundStyle(Color(hex: "#C4B5FD"))
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .padding(24)
        .frame(width: 440, height: 520)
        .background(dojoPanel)
        .foregroundStyle(Color(hex: "#D8EDF2"))
    }
}

@available(macOS 14.0, *)
private struct ProofDrawerView: View {
    var object: GeneratedObjectShell?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Proof")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#EAFBFF"))
                    Text("The stamp for this note — saved on this Mac.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#A9BBC2"))
                }
                Spacer()
                dismissX { dismiss() }
            }

            if let object {
                proofRow("Object", object.title)
                proofRow("Type", object.kind.badge)
                proofRow("Created", object.createdAt.formatted(date: .abbreviated, time: .shortened))
                proofRow("Model / tool", object.modelID ?? "—")
                proofRow("Provider", object.providerDisplayName)
                if let receipt = object.localReceipt {
                    proofRow("Receipt ID", receipt.receiptID)
                    proofRow("Operation", receipt.operation)
                    proofRow("Receipt path", receipt.receiptPath)
                    proofRow("Object path", receipt.objectPath)
                    proofRow("Hash", receipt.contentSHA256)
                    proofRow("Result", receipt.result)
                    proofRow("Witness", receipt.surface)
                    proofRow("Issued", receipt.issuedAt.formatted(date: .abbreviated, time: .shortened))
                    proofRow("Authority", "Local surface evidence only · not Chronicle")
                } else {
                    proofRow("Receipt path", object.isSavedLocally ? GeneratedObjectStore.storeURL.path : "Not saved yet")
                    proofRow("Hash", "Not issued for this object")
                    proofRow("Witness", "Object session state")
                }
                proofRow("Object HOLDs", "None recorded")
            } else {
                Text("No note is open. Type one below, press Keep, then open Proof.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#A9BBC2"))
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(dojoPanelRaised)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Text("This is the stamp for this note, not a FIELD system report.")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#6B8A93"))
            Spacer()
        }
        .padding(24)
        .frame(width: 500, height: 520)
        .background(dojoPanel)
        .foregroundStyle(Color(hex: "#D8EDF2"))
    }

    private func proofRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#6B8A93"))
                .frame(width: 100, alignment: .leading)
            Text(value)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#EAFBFF"))
                .textSelection(.enabled)
            Spacer(minLength: 0)
        }
    }
}

@available(macOS 14.0, *)
private struct TodaySettingsView: View {
    @Binding var selectedProvider: HostedProviderID
    @Binding var selectedModelID: String
    var initialSection: SettingsSection = .models
    var openSystemInspector: () -> Void
    var openDeveloper: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var section: SettingsSection = .models
    @State private var searchText = ""
    @State private var draftKeys: [HostedProviderID: String] = [:]
    @State private var revealKey: [HostedProviderID: Bool] = [:]
    /// Per-provider live test results (Obsidian-style: enter key → test → know it works).
    @State private var liveStatus: [HostedProviderID: APIKeyLiveStatus] = [:]
    @State private var testingProvider: HostedProviderID?
    /// Providers the operator chose to surface (try-for-a-while) without dumping the full catalog.
    @State private var expandedProviders: Set<HostedProviderID> = []
    #if os(macOS)
    @StateObject private var voiceCapture = VoiceCaptureSettingsModel()
    #endif

    private var filtered: [SettingsSection] {
        let q = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return SettingsSection.allCases }
        return SettingsSection.allCases.filter { $0.title.lowercased().contains(q) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#EAFBFF"))
                Spacer()
                TextField("Search", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                dismissX { dismiss() }
            }
            .padding(16)
            .background(dojoChrome)

            HStack(alignment: .top, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(filtered) { item in
                            Button { section = item } label: {
                                Text(item.title)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundStyle(section == item ? Color(hex: "#031416") : Color(hex: "#D9F8FF"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 9)
                                    .background(section == item ? Color(hex: "#6CEBFF") : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)
                }
                .frame(width: 200)
                .background(dojoChrome)

                ScrollView {
                    settingsDetail
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .background(dojoPanel)
            }
        }
        .frame(width: 780, height: 540)
        .onAppear {
            section = initialSection
            for p in HostedProviderCatalog.liveProviders {
                draftKeys[p] = ""
                revealKey[p] = false
            }
            // Surface only providers that already matter: keys saved + current default.
            var seed = Set(HostedProviderCatalog.liveProviders.filter {
                APIKeychainStore.hasKey(provider: $0)
            })
            if selectedProvider.isHostedLive {
                seed.insert(selectedProvider)
            }
            expandedProviders = seed
        }
        .foregroundStyle(Color(hex: "#D8EDF2"))
    }

    @ViewBuilder
    private var settingsDetail: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(section.title)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#EAFBFF"))

            switch section {
            case .models:
                Picker("Default provider", selection: $selectedProvider) {
                    ForEach(HostedProviderCatalog.liveProviders) { p in
                        Text(p.displayName).tag(p)
                    }
                }
                .onChange(of: selectedProvider) { _, p in
                    selectedModelID = HostedProviderCatalog.resolvedModelID(provider: p, preferred: selectedModelID)
                    M1Preferences.setDefault(provider: p, modelID: selectedModelID)
                }
                Picker("Default model", selection: $selectedModelID) {
                    ForEach(selectedProvider.models.filter(\.isEnabled)) { m in
                        Text(m.displayName).tag(m.id)
                    }
                }
                .onChange(of: selectedModelID) { _, m in
                    M1Preferences.setDefault(provider: selectedProvider, modelID: m)
                }
            case .voice:
                #if os(macOS)
                voiceCaptureSection
                #else
                Text("Voice & capture Settings ship first on Mac. iPhone/iPad use system routes + stacked shell.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#A9BBC2"))
                #endif
            case .apiKeys:
                apiKeysSection
            case .memory:
                Text("Unavailable / hold")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#FBBF24"))
                Text("Not enabled yet. No memory store is active.")
                    .foregroundStyle(Color(hex: "#A9BBC2"))
            case .developer:
                Text("Settings configure the app. System Inspector explains current behaviour. Diagnostics are raw machinery.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#A9BBC2"))
                Button(action: openSystemInspector) {
                    Label("Open System Inspector…", systemImage: "rectangle.and.text.magnifyingglass")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "#6CEBFF"))
                Button(action: openDeveloper) {
                    Label("Open Developer Space…", systemImage: "wrench.and.screwdriver")
                }
                .buttonStyle(.bordered)
            default:
                Text("Not available in this pass")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#FBBF24"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(hex: "#FBBF24").opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text(section.blurb)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#A9BBC2"))
                Text("This section is listed for orientation only. No action is exposed here.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#6B8A93"))
            }
        }
    }

    // MARK: - Voice & capture (Mac)

    #if os(macOS)
    private var voiceCaptureSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Microphone → packet → (optional) text. Apple owns device pairing; DOJO only prefers and tests.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#89A8B1"))
                .fixedSize(horizontal: false, vertical: true)

            // Permission
            settingsCard("Microphone permission") {
                HStack {
                    Text(voiceCapture.micPermission.rawValue)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(
                            voiceCapture.micPermission.isUsable
                                ? Color(hex: "#86EFAC")
                                : Color(hex: "#FBBF24")
                        )
                    Spacer()
                    if voiceCapture.micPermission == .unknown {
                        Button("Request access") { voiceCapture.requestPermission() }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(hex: "#6CEBFF"))
                    }
                    if voiceCapture.micPermission == .denied || voiceCapture.micPermission == .restricted {
                        Button("Open System Settings…") { voiceCapture.openSystemPrivacySettings() }
                            .buttonStyle(.bordered)
                    }
                    Button("Refresh") { voiceCapture.refreshPermission() }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
            }

            // Input
            settingsCard("Preferred microphone") {
                Picker("Input", selection: Binding(
                    get: { voiceCapture.preferredInputID },
                    set: { voiceCapture.selectInput($0) }
                )) {
                    Text("System default").tag("system")
                    ForEach(voiceCapture.inputDevices) { device in
                        Text(deviceLabel(device)).tag(device.id)
                    }
                }
                .labelsHidden()
                HStack {
                    Button("Refresh devices") { voiceCapture.refreshDevices() }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    Button("System Sound…") { voiceCapture.openSystemSoundSettings() }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
            }

            // Output
            settingsCard("Preferred speakers / output") {
                Picker("Output", selection: Binding(
                    get: { voiceCapture.preferredOutputID },
                    set: { voiceCapture.selectOutput($0) }
                )) {
                    Text("System default").tag("system")
                    ForEach(voiceCapture.outputDevices) { device in
                        Text(device.name).tag(device.id)
                    }
                }
                .labelsHidden()
            }

            // Test
            settingsCard("Test capture") {
                HStack {
                    Button {
                        voiceCapture.runTestCapture()
                    } label: {
                        if voiceCapture.isTesting {
                            HStack(spacing: 8) {
                                ProgressView().controlSize(.small)
                                Text("Listening…")
                            }
                        } else {
                            Text("Test capture")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: "#6CEBFF"))
                    .disabled(voiceCapture.isTesting || !voiceCapture.micPermission.isUsable)

                    if voiceCapture.isTesting || voiceCapture.testLevelDb > -90 {
                        Text(String(format: "%.0f dB", voiceCapture.testLevelDb))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(hex: "#7DD3FC"))
                    }
                }
                if !voiceCapture.testMessage.isEmpty {
                    Text(voiceCapture.testMessage)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#C9E4EA"))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text("Test checks capture level only — not speech-to-text. STT is a separate translator layer.")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#6B8A93"))
            }

            // Handshake: enhanced hearing / multi-mic only if connected
            if voiceCapture.shouldShowEnhancedHearingSection {
                settingsCard("Enhanced hearing / multi-mic (connected)") {
                    Text("Shown only because a connected device reports multi-mic or hearing-related capability.")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#89A8B1"))
                    ForEach(voiceCapture.connectedEnhancedHearingDevices) { device in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(device.name)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                            Text(device.capabilityLabels.joined(separator: " · "))
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(hex: "#7DD3FC"))
                        }
                        .padding(.vertical, 4)
                    }
                    Text("Use Preferred microphone to select this device. No extra modes when nothing capable is connected.")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#6B8A93"))
                }
            }

            settingsCard("Pipeline (simple)") {
                Text("Mic → Murmur / SealedVoice packet → dock (Hermen) across surfaces → translator (Apple / hosted / Whisper when optimal) → text object.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#A9BBC2"))
                    .fixedSize(horizontal: false, vertical: true)
                Text("Layers stay separate. Zero-loss = packet + hash; AKRON only on explicit promote.")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#6B8A93"))
            }
        }
        .onAppear {
            voiceCapture.refreshPermission()
            voiceCapture.refreshDevices()
        }
    }

    private func deviceLabel(_ device: SelectableAudioDevice) -> String {
        let caps = device.capabilityLabels
        if caps.isEmpty { return device.name }
        return "\(device.name) · \(caps.joined(separator: ", "))"
    }

    private func settingsCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#C9E4EA"))
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(dojoPanelRaised)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    #endif

    /// Progressive API keys: only show providers in play; expand to try another; contract when removed.
    /// Pattern: findable Settings · no wall of empty key fields · try briefly without permanent clutter.
    private var apiKeysSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Keys stay in Settings (not a back room), but only providers you’re using appear here. Try another when you want — remove it when you’re done.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#89A8B1"))
                .fixedSize(horizontal: false, vertical: true)

            Text("Capability boundary: Keychain presence is not readiness. A provider remains unpromoted until a real read-only smoke check succeeds.")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#7DD3FC"))
                .fixedSize(horizontal: false, vertical: true)

            Text("Paste a key → Save & Test (real network check; never faked).")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#6B8A93"))

            pepProviderPhenotypeSpecimenStrip

            if visibleKeyProviders.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No providers open yet.")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#EAFBFF"))
                    Text("Add one to try. Empty key rows for every organisation stay out of the way until you ask.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#89A8B1"))
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(dojoPanelRaised)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                ForEach(visibleKeyProviders) { provider in
                    providerKeyCard(provider)
                }
            }

            // Expand: try another org without showing all unconnected cards by default
            if !hiddenKeyProviders.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Try another provider")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#89A8B1"))

                    HStack(spacing: 8) {
                        ForEach(hiddenKeyProviders) { provider in
                            Button {
                                expandedProviders.insert(provider)
                            } label: {
                                Label(provider.displayName, systemImage: "plus")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color(hex: "#7DD3FC"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(dojoControl)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text("\(hiddenKeyProviders.count) more available — not shown until you open them.")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#6B8A93"))
                }
            }

            // Compact footprint of the full catalog (not interactive key forms)
            DisclosureGroup("All providers (catalog only)") {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(HostedProviderCatalog.liveProviders) { p in
                        HStack {
                            Text(p.displayName)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                            Spacer()
                            Text(catalogFootprintLabel(p))
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color(hex: "#6B8A93"))
                            if !visibleKeyProviders.contains(p) {
                                Button("Open") {
                                    expandedProviders.insert(p)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                        }
                    }
                    Text("Local models remain disabled elsewhere — not listed as live API keys.")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#6B8A93"))
                        .padding(.top, 4)
                }
                .padding(.top, 8)
            }
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(Color(hex: "#A9BBC2"))
        }
    }

    /// In play = has key · current default · or explicitly expanded to try.
    private var visibleKeyProviders: [HostedProviderID] {
        HostedProviderCatalog.liveProviders.filter { p in
            APIKeychainStore.hasKey(provider: p)
                || p == selectedProvider
                || expandedProviders.contains(p)
        }
    }

    private var hiddenKeyProviders: [HostedProviderID] {
        HostedProviderCatalog.liveProviders.filter { !visibleKeyProviders.contains($0) }
    }

    private func catalogFootprintLabel(_ p: HostedProviderID) -> String {
        if APIKeychainStore.hasKey(provider: p) {
            if case .working = liveStatus[p] { return "Working" }
            return "Key saved"
        }
        if expandedProviders.contains(p) || p == selectedProvider {
            return "Open"
        }
        return "Not open"
    }

    private func providerKeyCard(_ provider: HostedProviderID) -> some View {
        let hasKey = APIKeychainStore.hasKey(provider: provider)
        let status = liveStatus[provider] ?? (hasKey ? .keySavedNotTested : .empty)
        let isThisTesting = testingProvider == provider
        let capability = capabilityBoundaryResult(provider)
        let phenotype = providerPEPPhenotype(
            provider: provider,
            status: status,
            capability: capability,
            isTesting: isThisTesting,
            hasKey: hasKey
        )
        let phenotypeStyle = PEPPhenotypeStyleResolver.style(for: phenotype)
        let capabilityStage = capability.stage.rawValue.replacingOccurrences(of: "_", with: " ")
        let capabilityLabel = "Capability boundary · \(capabilityStage) · \(capability.decision.rawValue) · composer closed"
        let capabilityColor = phenotypeStyle.boundaryColor

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(provider.displayName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Spacer()
                pepPhenotypeBadge(phenotypeStyle)
                liveStatusBadge(status, isTesting: isThisTesting)
            }

            // Key field
            HStack(spacing: 8) {
                Group {
                    if revealKey[provider] == true {
                        TextField("Paste API key…", text: bindingKey(provider))
                            .textFieldStyle(.roundedBorder)
                    } else {
                        SecureField("Paste API key…", text: bindingKey(provider))
                            .textFieldStyle(.roundedBorder)
                    }
                }
                Toggle(isOn: revealBinding(provider)) {
                    Text("Show")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                }
                .toggleStyle(.checkbox)
            }

            // Actions — Save & Test is primary (live verification)
            HStack(spacing: 8) {
                Button {
                    Task { await saveAndTest(provider) }
                } label: {
                    if isThisTesting {
                        HStack(spacing: 6) {
                            ProgressView().controlSize(.small)
                            Text("Testing…")
                        }
                    } else {
                        Text("Save & Test")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "#6CEBFF"))
                .disabled(isThisTesting || (draftKeys[provider] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Button {
                    Task { await runLiveTest(provider) }
                } label: {
                    Text(isThisTesting ? "…" : "Test again")
                }
                .buttonStyle(.bordered)
                .disabled(isThisTesting || !hasKey)

                Button {
                    removeKey(provider)
                } label: {
                    Text("Remove key")
                }
                .buttonStyle(.bordered)
                .disabled(isThisTesting || !hasKey)

                // Contract: stop trying this provider → collapse the card (unless it's the default).
                if expandedProviders.contains(provider) || hasKey {
                    Button {
                        collapseProvider(provider)
                    } label: {
                        Text("Hide")
                    }
                    .buttonStyle(.bordered)
                    .disabled(isThisTesting)
                    .help("Collapse this row. Key stays in Keychain if saved; remove key separately.")
                }
            }

            // Live result line (like Obsidian plugin verification feedback)
            if case .working(let detail) = status {
                Text("Working · \(detail)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#86EFAC"))
                    .textSelection(.enabled)
            } else if case .failed(let detail) = status {
                Text("Failed · \(detail)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#FCA5A5"))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            } else if case .keySavedNotTested = status {
                Text("Key is saved. Press Test again (or re-enter and Save & Test) to verify live.")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#FBBF24"))
            } else if case .savedTesting = status {
                Text("Saved to Keychain — running live check…")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#7DD3FC"))
            }

            Text(capabilityLabel)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(capabilityColor)
                .textSelection(.enabled)

            pepPhenotypeLine(phenotype, style: phenotypeStyle)
        }
        .padding(14)
        .background(dojoPanelRaised)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var pepProviderPhenotypeSpecimenStrip: some View {
        settingsCard("PEP phenotype specimen") {
            Text("FIXTURE / DEVELOPMENT PROOF — provider expression only; no delivery, consent, routing or runtime authority.")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#89A8B1"))
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 8) {
                ForEach(pepProviderPhenotypeFixtures, id: \.identity.phenotypeID) { resolution in
                    let style = PEPPhenotypeStyleResolver.style(for: resolution)
                    VStack(alignment: .leading, spacing: 6) {
                        pepPhenotypeBadge(style)
                        Text(style.authoritySummary)
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundStyle(dojoTextTertiary)
                        Text(style.stateBadge.label == "Eligible" ? "renderable style" : "no action enabled")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(style.accentColor)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(dojoControl.opacity(0.76))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style.boundaryColor.opacity(0.48), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("PEP fixture \(style.accessibilityLabel)")
                }
            }
        }
    }

    private var pepProviderPhenotypeFixtures: [PEPPhenotypeResolution] {
        [
            providerPEPFixture(state: .eligible, decision: .pass, label: "Eligible fixture"),
            providerPEPFixture(state: .held, decision: .hold, label: "Held fixture", holds: [.authority]),
            providerPEPFixture(state: .unknown, decision: .unknown, label: "Unknown fixture", unknowns: [.source]),
            providerPEPFixture(state: .forbidden, decision: .fail, label: "Forbidden fixture")
        ]
    }

    private func pepPhenotypeBadge(_ style: PEPResolvedPhenotypeStyle) -> some View {
        PEPPhenotypeBadgeView(style: style)
    }

    private func pepPhenotypeLine(
        _ resolution: PEPPhenotypeResolution,
        style: PEPResolvedPhenotypeStyle
    ) -> some View {
        let unknownLabel = resolution.unknownDimensions.isEmpty
            ? "Unknown none"
            : "Unknown \(resolution.unknownDimensions.map(\.rawValue).joined(separator: ", "))"
        let holdLabel = resolution.holdReasons.isEmpty
            ? "HOLD none"
            : "HOLD \(resolution.holdReasons.map(\.rawValue).joined(separator: ", "))"

        return HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: style.stateBadge.symbolName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(style.accentColor)
            Text("\(style.authoritySummary) · \(unknownLabel) · \(holdLabel)")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#89A8B1"))
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(style.accessibilityLabel)
    }

    private func providerPEPPhenotype(
        provider: HostedProviderID,
        status: APIKeyLiveStatus,
        capability: CapabilityBoundaryResult,
        isTesting: Bool,
        hasKey: Bool
    ) -> PEPPhenotypeResolution {
        let authorityStatus = pepAuthorityStatus(for: capability)
        let state = pepState(status: status, capability: capability, isTesting: isTesting)
        let unknowns = pepUnknownDimensions(status: status, capability: capability, hasKey: hasKey)
        let holds = pepHoldReasons(capability: capability, hasKey: hasKey)
        let evidence = hasKey
            ? EvidenceAnchor(
                anchorID: "provider-keychain:\(provider.rawValue)",
                kind: .humanReport,
                sourceID: capability.custodyReference,
                state: capability.decision == .pass ? .witnessed : .partial,
                claim: "Provider key custody is represented without exposing the secret."
            )
            : .unknownSource
        let correctionRoute = CorrectionRoute(
            routeID: "settings-api-key:\(provider.rawValue)",
            destination: "Settings/API keys/\(provider.displayName)",
            preservesHistory: true
        )
        let grounding = ProjectionGrounding(
            projectionIdentity: ProjectionIdentity(
                projectionID: "provider-key-card:\(provider.rawValue)",
                surface: .mac,
                representationKind: .card
            ),
            representedObject: FieldObjectIdentity(
                objectID: "provider:\(provider.rawValue)",
                ontologyKind: .generatedObject,
                displayLabel: provider.displayName,
                sourceObjectID: provider.rawValue
            ),
            interactionContext: InteractionContext(
                inputMode: .text,
                preferredOutputMode: .visual,
                resolvedOutputMode: .visual,
                biometricState: .unknown,
                environmentState: .unknown,
                activeDevice: .mac
            ),
            evidenceAnchors: [evidence],
            temporalValidity: TemporalValidity(
                projectionTime: nil,
                freshness: state == .eligible ? .current : .partial
            ),
            authorityStatus: authorityStatus,
            correctionRoute: correctionRoute,
            unknownDimensions: unknowns,
            holdReasons: holds
        )
        let attribute = PEPAttribute(
            attributeID: "provider-key-attribute:\(provider.rawValue)",
            semanticRole: "Provider capability boundary",
            colorRole: colorRole(for: state),
            geometryRole: .boundary,
            motionRole: .none,
            communicationMode: .visual,
            evidenceAnchor: evidence,
            authorityStatus: authorityStatus,
            unknownDimensions: unknowns,
            holdReasons: holds,
            correctionRoute: correctionRoute
        )
        let boundary = PEPExpressionBoundary(
            authorityStatus: authorityStatus,
            allowedExpressionModes: [.visual, .textual],
            forbiddenExpressionModes: [.auditory, .haptic, .spatial, .multimodal],
            allowsInteractionAffordance: state == .eligible,
            correctionRoute: correctionRoute,
            unknownDimensions: unknowns,
            holdReasons: holds
        )
        let surfaceExpression = PEPSurfaceExpression(
            surfaceClass: .desktop,
            semanticEmphasis: "Provider key capability state",
            attributes: [attribute],
            density: .compact,
            priority: state == .held ? .hold : .normal,
            legibilityRequirements: ["state label", "SF Symbol", "boundary stroke"],
            availableCommunicationModes: [.visual, .textual],
            interactionAffordance: state == .eligible ? .actionRepresentable : .inspectable,
            isSelectedSurface: true
        )

        return PEPPhenotypeResolution(
            state: state,
            identity: PEPPhenotypeIdentity(
                phenotypeID: "pep-provider:\(provider.rawValue):\(state.rawValue)",
                genotypeObject: grounding.representedObject,
                projectionIdentity: grounding.projectionIdentity,
                sourceExpression: surfaceExpression.semanticEmphasis
            ),
            projectionGrounding: grounding,
            selectedSurfaceClass: .desktop,
            surfaceExpression: surfaceExpression,
            expressionBoundary: boundary,
            resolvedAttributes: [attribute],
            unknownDimensions: unknowns,
            holdReasons: holds,
            correctionRoute: correctionRoute
        )
    }

    private func providerPEPFixture(
        state: PEPPhenotypeResolutionState,
        decision: ProjectionAuthorityStatus.Decision,
        label: String,
        unknowns: [UnknownDimension] = [],
        holds: [ProjectionHoldReason] = []
    ) -> PEPPhenotypeResolution {
        let provider = selectedProvider
        let capability = CapabilityBoundaryResult(
            providerID: provider.rawValue,
            custodyReference: "fixture://pep-provider/\(provider.rawValue)",
            stage: decision == .pass ? .modelCompatible : decision == .fail ? .failed : .hold,
            decision: CapabilityBoundaryResult.Decision(rawValue: decision.rawValue) ?? .unknown,
            composerExposureAllowed: false,
            nextEvidence: label
        )
        return providerPEPPhenotype(
            provider: provider,
            status: decision == .pass ? .working(label) : decision == .fail ? .failed(label) : .keySavedNotTested,
            capability: capability,
            isTesting: false,
            hasKey: decision != .hold || state == .held
        )
    }

    private func pepAuthorityStatus(for capability: CapabilityBoundaryResult) -> ProjectionAuthorityStatus {
        ProjectionAuthorityStatus(
            decision: ProjectionAuthorityStatus.Decision(rawValue: capability.decision.rawValue) ?? .unknown,
            boundaryReference: capability.custodyReference,
            nextEvidence: capability.nextEvidence
        )
    }

    private func pepState(
        status: APIKeyLiveStatus,
        capability: CapabilityBoundaryResult,
        isTesting: Bool
    ) -> PEPPhenotypeResolutionState {
        if isTesting || capability.decision == .unknown {
            return .unknown
        }
        switch capability.decision {
        case .pass:
            if case .working = status { return .eligible }
            return .unknown
        case .hold:
            return .held
        case .fail:
            return .forbidden
        case .unknown:
            return .unknown
        }
    }

    private func pepUnknownDimensions(
        status: APIKeyLiveStatus,
        capability: CapabilityBoundaryResult,
        hasKey: Bool
    ) -> [UnknownDimension] {
        var unknowns: [UnknownDimension] = []
        if !hasKey || capability.decision == .unknown {
            unknowns.append(.source)
        }
        if capability.decision == .unknown {
            unknowns.append(.authority)
        }
        if case .savedTesting = status {
            unknowns.append(.temporalValidity)
        }
        return unknowns
    }

    private func pepHoldReasons(
        capability: CapabilityBoundaryResult,
        hasKey: Bool
    ) -> [ProjectionHoldReason] {
        var holds: [ProjectionHoldReason] = []
        if capability.decision == .hold {
            holds.append(.authority)
        }
        if !hasKey {
            holds.append(.evidence)
        }
        return holds
    }

    private func colorRole(for state: PEPPhenotypeResolutionState) -> PEPColorRole {
        switch state {
        case .eligible:
            return .evidence
        case .held:
            return .hold
        case .unknown:
            return .unknown
        case .forbidden:
            return .caution
        }
    }

    private func liveStatusBadge(_ status: APIKeyLiveStatus, isTesting: Bool) -> some View {
        let label: String
        let color: Color
        if isTesting {
            label = "Testing…"
            color = Color(hex: "#7DD3FC")
        } else {
            switch status {
            case .empty:
                label = "No key"
                color = Color(hex: "#6B8A93")
            case .keySavedNotTested, .savedTesting:
                label = "Saved · untested"
                color = Color(hex: "#FBBF24")
            case .working:
                label = "Working"
                color = Color(hex: "#86EFAC")
            case .failed:
                label = "Failed"
                color = Color(hex: "#F87171")
            }
        }
        return Text(label)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func bindingKey(_ p: HostedProviderID) -> Binding<String> {
        Binding(get: { draftKeys[p] ?? "" }, set: { draftKeys[p] = $0 })
    }
    private func revealBinding(_ p: HostedProviderID) -> Binding<Bool> {
        Binding(get: { revealKey[p] ?? false }, set: { revealKey[p] = $0 })
    }

    private func capabilityBoundaryResult(_ provider: HostedProviderID) -> CapabilityBoundaryResult {
        let status = liveStatus[provider]
        let tested: Bool
        let succeeded: Bool
        switch status {
        case .working:
            tested = true
            succeeded = true
        case .failed:
            tested = true
            succeeded = false
        default:
            tested = false
            succeeded = false
        }
        return CapabilityBoundaryPolicy.provider(
            providerID: provider.rawValue,
            hasKey: APIKeychainStore.hasKey(provider: provider),
            wasTested: tested,
            testSucceeded: succeeded
        )
    }

    private func removeKey(_ provider: HostedProviderID) {
        do {
            try APIKeychainStore.delete(provider: provider)
            draftKeys[provider] = ""
            liveStatus[provider] = .empty
            // After remove, collapse trial rows so Settings doesn't keep an empty chart.
            if provider != selectedProvider {
                expandedProviders.remove(provider)
            }
        } catch {
            liveStatus[provider] = .failed(error.localizedDescription)
        }
    }

    private func collapseProvider(_ provider: HostedProviderID) {
        draftKeys[provider] = ""
        expandedProviders.remove(provider)
        // Keep default provider visible even if collapsed request — re-insert for UX honesty.
        if provider == selectedProvider {
            expandedProviders.insert(provider)
        }
    }

    @MainActor
    private func saveAndTest(_ provider: HostedProviderID) async {
        let raw = (draftKeys[provider] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else {
            liveStatus[provider] = .failed("Paste an API key first.")
            return
        }
        do {
            try APIKeychainStore.save(provider: provider, key: raw)
            draftKeys[provider] = ""
            liveStatus[provider] = .savedTesting
            await runLiveTest(provider)
        } catch {
            liveStatus[provider] = .failed("Save failed: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func runLiveTest(_ provider: HostedProviderID) async {
        guard APIKeychainStore.hasKey(provider: provider) else {
            liveStatus[provider] = .failed("No key in Keychain for \(provider.displayName).")
            return
        }
        testingProvider = provider
        liveStatus[provider] = .savedTesting
        defer { testingProvider = nil }

        // Prefer the model currently selected if this is the active provider.
        let model: String? = provider == selectedProvider ? selectedModelID : nil
        let result = await HostedChatClient.testConnection(provider: provider, modelID: model)
        switch result {
        case .success(let msg):
            liveStatus[provider] = .working(msg)
        case .failure(let err):
            liveStatus[provider] = .failed(err.localizedDescription)
        }
    }
}

/// Live verification state for one provider key (Settings → API keys).
private enum APIKeyLiveStatus: Equatable {
    case empty
    case keySavedNotTested
    case savedTesting
    case working(String)
    case failed(String)
}

private enum SettingsSection: String, CaseIterable, Identifiable {
    case account, models, apiKeys, agents, skills, connectors, mcp
    case voice, files, memory, receipts, privacy, appearance
    case shortcuts, notifications, storage, developer
    var id: String { rawValue }
    var title: String {
        switch self {
        case .account: return "Account / profile"
        case .models: return "Models & providers"
        case .apiKeys: return "API keys"
        case .agents: return "Agents"
        case .skills: return "Skills"
        case .connectors: return "Connectors"
        case .mcp: return "MCP servers"
        case .voice: return "Voice & capture"
        case .files: return "Files & media"
        case .memory: return "Memory"
        case .receipts: return "Receipts & history"
        case .privacy: return "Privacy & local/cloud"
        case .appearance: return "Appearance"
        case .shortcuts: return "Keyboard shortcuts"
        case .notifications: return "Notifications"
        case .storage: return "Storage"
        case .developer: return "Developer / Advanced"
        }
    }
    var blurb: String { "Configure \(title) when available." }
}

@available(macOS 14.0, *)
private struct DeveloperSpaceView: View {
    @Environment(\.dismiss) private var dismiss
    private let openTestBench: () -> Void

    init(openTestBench: @escaping () -> Void = {}) {
        self.openTestBench = openTestBench
    }

    /// Cheap wiring checklist — Developer/Advanced only (see Surface Action Wiring Matrix).
    private let wiringChecklist: [(String, String)] = [
        ("Top bar · Settings gear", "WIRED"),
        ("Top bar · API key needed → API keys", "WIRED"),
        ("Left · Places select / collapse", "PARTIAL"),
        ("Left · New capture", "WIRED"),
        ("Left · Proof", "WIRED"),
        ("Centre · Open/close object", "WIRED"),
        ("Right · Details / Review", "WIRED"),
        ("Right · Files paths", "PARTIAL"),
        ("Right · non-live Browser / Terminal / Side chat", "REMOVED"),
        ("Composer · Send hosted", "WIRED"),
        ("Composer · Capture Keep", "WIRED"),
        ("Composer · Mic / Attach", "REMOVED"),
        ("Object · Save / Export / Continue", "WIRED"),
        ("Settings · Models / API keys", "WIRED"),
        ("Credential boundary · non-secret readiness", "WIRED"),
        ("Settings · other sections", "HOLD"),
        ("Developer · Test Bench entry", "WIRED"),
        ("Test Bench · hosted proposal", "WIRED"),
        ("Test Bench · deterministic fail-closed gate", "WIRED"),
        ("Test Bench · authority receipt promotion", "HOLD"),
        ("Memory", "HOLD"),
        ("MCP execution", "HOLD"),
        ("Local models", "HOLD")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Developer Space")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#EAFBFF"))
                Spacer()
                dismissX { dismiss() }
            }
            Text("Generated object store")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#89A8B1"))
            Text(GeneratedObjectStore.storeURL.path)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Color(hex: "#89A8B1"))
                .textSelection(.enabled)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Deterministic Test Bench")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#EAFBFF"))
                    Text("External proposal → deterministic gate → receipt-aware decision")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(Color(hex: "#89A8B1"))
                }
                Spacer()
                Button("Open bench", action: openTestBench)
                    .buttonStyle(.borderedProminent)
                    .tint(Chamber.atlas.color)
            }
            .padding(12)
            .background(Color(hex: "#16252B"))
            .clipShape(RoundedRectangle(cornerRadius: 9))

            Text("Surface wiring checklist")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#89A8B1"))
                .padding(.top, 4)
            Text("Source: docs/DOJO_TODAY_SURFACE_ACTION_WIRING_MATRIX_V0.md")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#6B8A93"))

            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(wiringChecklist, id: \.0) { row in
                        HStack {
                            Text(row.0)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(hex: "#D8EDF2"))
                            Spacer()
                            Text(row.1)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(checklistColor(row.1))
                        }
                    }
                }
            }
        }
        .padding(24)
        .frame(width: 520, height: 440)
        .background(dojoPanel)
    }

    private func checklistColor(_ status: String) -> Color {
        switch status {
        case "WIRED": return Color(hex: "#86EFAC")
        case "PARTIAL": return Color(hex: "#7DD3FC")
        case "REMOVED": return Color(hex: "#6B8A93")
        case "HOLD", "BROKEN": return Color(hex: "#F87171")
        default: return Color(hex: "#A9BBC2")
        }
    }
}

@available(macOS 14.0, *)
private struct DeterministicTestBenchView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var requestText = "Review this object and propose the next useful step."
    @State private var selectedProvider: HostedProviderID = M1Preferences.defaultProvider
    @State private var selectedModelID: String = M1Preferences.defaultModelID
    @State private var proposalText = ""
    @State private var correlationID = UUID()
    @State private var isProposing = false
    @State private var isChecking = false
    @State private var proposalStage: BenchStageState = .idle
    @State private var routeStage: BenchStageState = .idle
    @State private var authorityStage: BenchStageState = .idle
    @State private var receiptLabel = "No receipt issued"

    private var hasProviderKey: Bool {
        selectedProvider.isHostedLive && APIKeychainStore.hasKey(provider: selectedProvider)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(dojoDividerColor)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    purposeStrip
                    requestCard
                    pipeline
                    if !proposalText.isEmpty {
                        proposalCard
                    }
                    receiptCard
                }
                .padding(24)
            }
        }
        .frame(minWidth: 980, minHeight: 720)
        .background(dojoObsidian)
        .onChange(of: selectedProvider) { _, provider in
            selectedModelID = HostedProviderCatalog.resolvedModelID(
                provider: provider,
                preferred: nil
            )
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("DETERMINISTIC TEST BENCH")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(dojoTextPrimary)
                Text("A controlled proving surface for the application shell")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(dojoTextTertiary)
            }
            Spacer()
            Text("DEVELOPER / ADVANCED")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Chamber.atlas.color)
            dismissX { dismiss() }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(dojoChrome)
    }

    private var purposeStrip: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(Chamber.atlas.color)
                .frame(width: 34, height: 34)
                .background(Chamber.atlas.color.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 5) {
                Text("The model may propose. The deterministic layer decides.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(dojoTextPrimary)
                Text("A hosted response is presentation/advisory input. It does not become authority by being visible, confident, or well-formed. The gate below is intentionally able to return HOLD.")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(dojoTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(dojoPanel)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Chamber.atlas.color.opacity(0.5), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var requestCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            benchSectionTitle("01 · INPUT", "Controlled request", "The request is the object under test. No hidden context is added.")

            TextEditor(text: $requestText)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(dojoTextPrimary)
                .scrollContentBackground(.hidden)
                .padding(8)
                .frame(minHeight: 92)
                .background(dojoControl)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            HStack(spacing: 10) {
                Picker("Provider", selection: $selectedProvider) {
                    ForEach(HostedProviderCatalog.liveProviders) { provider in
                        Text(provider.displayName).tag(provider)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 180, alignment: .leading)

                Picker("Model", selection: $selectedModelID) {
                    ForEach(selectedProvider.models.filter(\.isEnabled)) { model in
                        Text(model.displayName).tag(model.id)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 210, alignment: .leading)

                Spacer()

                Label(
                    hasProviderKey ? "API key available" : "API key required",
                    systemImage: hasProviderKey ? "key.fill" : "key"
                )
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(hasProviderKey ? Color.green : Color.orange)
            }

            HStack(spacing: 10) {
                Button {
                    Task { await runProposal() }
                } label: {
                    Label(isProposing ? "Requesting…" : "Run external proposal", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(Chamber.dojo.color)
                .disabled(isProposing || isChecking || requestText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !hasProviderKey)

                Button("Reset run") {
                    resetRun()
                }
                .buttonStyle(.bordered)
                .disabled(isProposing || isChecking)

                Spacer()
                Text("Live HTTPS call · explicit user action")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(dojoTextTertiary)
            }
        }
        .padding(16)
        .background(dojoPanel)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var pipeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            benchSectionTitle("02 · PIPELINE", "Visible handoff", "Each stage owns a different claim. Transitions are part of the test.")

            HStack(alignment: .top, spacing: 10) {
                stageCard(index: "A", title: "External proposal", detail: "Hosted model", state: proposalStage)
                Image(systemName: "arrow.right")
                    .foregroundStyle(dojoTextTertiary)
                    .padding(.top, 30)
                stageCard(index: "B", title: "Deterministic route", detail: "DOJO fallback / admitted route", state: routeStage)
                Image(systemName: "arrow.right")
                    .foregroundStyle(dojoTextTertiary)
                    .padding(.top, 30)
                stageCard(index: "C", title: "Authority decision", detail: "Receipt-gated", state: authorityStage)
            }

            if !proposalText.isEmpty {
                HStack {
                    Spacer()
                    Button {
                        Task { await runDeterministicCheck() }
                    } label: {
                        Label(isChecking ? "Checking…" : "Run deterministic check", systemImage: "checkmark.shield")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Chamber.atlas.color)
                    .disabled(isProposing || isChecking)
                }
            }
        }
        .padding(16)
        .background(dojoPanel)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var proposalCard: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                benchSectionTitle("03 · PROPOSAL", "Presentation result", "Visible, inspectable, not authority-bearing.")
                Spacer()
                Text(selectedProvider.displayName + " · " + selectedModelID)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Chamber.dojo.color)
            }
            Text(proposalText)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(dojoTextPrimary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(dojoControl)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(16)
        .background(dojoPanel)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var receiptCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: authorityStage.isHold ? "pause.circle" : "doc.text.magnifyingglass")
                .foregroundStyle(authorityStage.isHold ? Color.orange : Chamber.tata.color)
            VStack(alignment: .leading, spacing: 5) {
                Text("RECEIPT / PROOF")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(dojoTextTertiary)
                Text(receiptLabel)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(dojoTextPrimary)
                Text("Correlation: \(correlationID.uuidString.lowercased())")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(dojoTextTertiary)
                    .textSelection(.enabled)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(dojoPanelRaised)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func benchSectionTitle(_ eyebrow: String, _ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(eyebrow)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(1.1)
                .foregroundStyle(Chamber.atlas.color)
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(dojoTextPrimary)
            Text(subtitle)
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(dojoTextTertiary)
        }
    }

    private func stageCard(index: String, title: String, detail: String, state: BenchStageState) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 7) {
                Text(index)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(dojoTextPrimary)
                    .frame(width: 22, height: 22)
                    .background(state.color)
                    .clipShape(Circle())
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(dojoTextPrimary)
            }
            Text(detail)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(dojoTextTertiary)
            Text(state.label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(state.color)
                .lineLimit(2)
        }
        .padding(11)
        .frame(maxWidth: .infinity, minHeight: 108, alignment: .topLeading)
        .background(dojoControl)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(state.color.opacity(0.55), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @MainActor
    private func runProposal() async {
        guard !isProposing else { return }
        let trimmedRequest = requestText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedRequest.isEmpty, hasProviderKey else { return }

        isProposing = true
        correlationID = UUID()
        proposalText = ""
        receiptLabel = "No receipt issued"
        proposalStage = .running
        routeStage = .idle
        authorityStage = .idle

        defer { isProposing = false }
        do {
            let response = try await HostedChatClient.complete(
                HostedChatRequest(
                    provider: selectedProvider,
                    modelID: selectedModelID,
                    userMessage: trimmedRequest,
                    contextBody: "Return a concise proposal only. This is advisory input for a separate deterministic gate. Do not claim authority, execution, or a receipt."
                )
            )
            proposalText = response.text
            proposalStage = .complete("RECEIVED · HTTP \(response.httpStatus)")
            routeStage = .ready("Awaiting deterministic check")
            authorityStage = .hold("Not evaluated")
        } catch {
            proposalStage = .failed(error.localizedDescription)
            routeStage = .idle
            authorityStage = .hold("Proposal unavailable")
        }
    }

    @MainActor
    private func runDeterministicCheck() async {
        guard !proposalText.isEmpty, !isChecking else { return }
        isChecking = true
        routeStage = .running
        authorityStage = .running
        receiptLabel = "Checking exact correlation; no receipt supplied"

        defer { isChecking = false }

        let router = ChamberRouter()
        await router.refreshTopology()
        let disposition = router.routingDisposition(for: .aiMind)
        routeStage = .complete(disposition == .canonicalDOJOFallback ? "CANONICAL DOJO FALLBACK" : "RECEIPT-ADMITTED ROUTE")

        // This is deliberately a presentation result with no authority proof.
        // AIService must therefore fail closed, which is the first deterministic
        // behavior the bench needs to make observable.
        let result = AIModelResult(
            output: proposalText,
            modelUsed: "\(selectedProvider.rawValue):\(selectedModelID)",
            deviceInfo: DeviceCapabilities.detect(),
            classification: .advisory
        )
        let admitted = await AIService().admitAuthorityBearingResult(
            result,
            correlationID: correlationID,
            authorityProof: nil
        )

        if admitted == nil {
            authorityStage = .hold("HOLD · correlated receipt required")
            receiptLabel = "HOLD · proposal was not promoted; no authority receipt was supplied"
        } else {
            authorityStage = .complete("PROMOTED · receipt verified")
            receiptLabel = "Authority receipt verified for this correlation"
        }
    }

    private func resetRun() {
        proposalText = ""
        correlationID = UUID()
        proposalStage = .idle
        routeStage = .idle
        authorityStage = .idle
        receiptLabel = "No receipt issued"
    }
}

private enum BenchStageState: Equatable {
    case idle
    case running
    case ready(String)
    case complete(String)
    case hold(String)
    case failed(String)

    var label: String {
        switch self {
        case .idle: return "READY · not run"
        case .running: return "RUNNING · observe transition"
        case .ready(let value), .complete(let value), .hold(let value), .failed(let value): return value
        }
    }

    var isHold: Bool {
        if case .hold = self { return true }
        return false
    }

    var color: Color {
        switch self {
        case .idle: return dojoTextTertiary
        case .running: return Chamber.atlas.color
        case .ready: return Color.orange
        case .complete: return Color.green
        case .hold, .failed: return Color.orange
        }
    }
}

@available(macOS 14.0, *)
private func dismissX(action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Image(systemName: "xmark")
            .font(.system(size: 12, weight: .bold))
            .frame(width: 28, height: 28)
            .foregroundStyle(Color(hex: "#EAFBFF"))
            .background(Color(hex: "#10252B"))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .buttonStyle(.plain)
}

// MARK: - Canonical chamber role layer

private let dojoObsidian = Color(hex: "#090A0D")
private let dojoChrome = Color(hex: "#0D0E12")
private let dojoPanel = Color(hex: "#111318")
private let dojoPanelRaised = Color(hex: "#161922")
private let dojoControl = Color(hex: "#181B23")
private let dojoDividerColor = Color(hex: "#292D36").opacity(0.82)
private let dojoTextPrimary = Color(hex: "#F4F6F8")
private let dojoTextSecondary = Color(hex: "#B7BEC8")
private let dojoTextTertiary = Color(hex: "#7E8794")

private func canonicalRoleColor(_ chamber: Chamber) -> Color {
    switch chamber {
    case .obiwan:
        return Color(hex: "#8B5CF6")
    case .tata:
        return Color(hex: "#14B8A6")
    case .atlas:
        return Color(hex: "#38BDF8")
    case .dojo:
        return Color(hex: "#2563EB")
    case .akron:
        return Color(hex: "#DC2626")
    case .arkadas:
        return Color(hex: "#EAB308")
    case .kings:
        return Color(hex: "#4F46E5")
    }
}

private func canonicalChamberName(_ chamber: Chamber) -> String {
    switch chamber {
    case .obiwan:
        return "OBI-WAN"
    case .tata:
        return "TATA"
    case .atlas:
        return "ATLAS"
    case .dojo:
        return "DOJO"
    case .akron:
        return "AKRON"
    case .arkadas:
        return "ARKADAS"
    case .kings:
        return "KINGS"
    }
}

private func canonicalRoleLabel(_ chamber: Chamber) -> String {
    switch chamber {
    case .obiwan:
        return "Witness"
    case .tata:
        return "Temporal"
    case .atlas:
        return "Align"
    case .dojo:
        return "Manifest"
    case .akron:
        return "Archive"
    case .arkadas:
        return "Relay"
    case .kings:
        return "Observe"
    }
}

// MARK: - Atmosphere (background only)

private struct DOJOTodayFieldAtmosphere: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "#07080A"),
                Color(hex: "#0A0B0F"),
                Color(hex: "#111219")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct CanonicalPyramidGuide: View {
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let apex = CGPoint(x: size.width * 0.5, y: size.height * 0.13)
            let leftBase = CGPoint(x: size.width * 0.19, y: size.height * 0.83)
            let rightBase = CGPoint(x: size.width * 0.81, y: size.height * 0.83)
            let dojoPoint = CGPoint(x: size.width * 0.5, y: size.height * 0.36)
            let arkadasPoint = CGPoint(x: size.width * 0.5, y: size.height * 0.56)

            Canvas { context, _ in
                var pyramid = Path()
                pyramid.move(to: apex)
                pyramid.addLine(to: leftBase)
                pyramid.addLine(to: rightBase)
                pyramid.closeSubpath()
                context.stroke(pyramid, with: .color(canonicalRoleColor(.dojo).opacity(0.10)), lineWidth: 1)

                var spine = Path()
                spine.move(to: apex)
                spine.addLine(to: CGPoint(x: size.width * 0.5, y: size.height * 0.88))
                context.stroke(spine, with: .color(canonicalRoleColor(.kings).opacity(0.10)), lineWidth: 1)

                var base = Path()
                base.move(to: leftBase)
                base.addLine(to: rightBase)
                context.stroke(base, with: .color(canonicalRoleColor(.tata).opacity(0.12)), lineWidth: 1)
            }

            guideGlyph(.obiwan, at: apex)
            guideGlyph(.tata, at: leftBase)
            guideGlyph(.atlas, at: rightBase)
            guideGlyph(.dojo, at: dojoPoint)
            guideGlyph(.kings, at: arkadasPoint)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func guideGlyph(_ chamber: Chamber, at point: CGPoint) -> some View {
        Text(chamber.rawValue)
            .font(.system(size: 13, weight: .bold, design: .monospaced))
            .foregroundStyle(canonicalRoleColor(chamber).opacity(0.20))
            .position(point)
    }
}

/// A shallow perceptual basin for present work. It carries no state or authority and never
/// animates; it only gives the central reading/action path more coherence than its foothills.
private struct TodayCognitiveRidgeway: View {
    let isActive: Bool

    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: isActive ? "#181D27" : "#151922").opacity(0.44),
                            Color(hex: "#0C0E13").opacity(0.18),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 24,
                        endRadius: max(proxy.size.width, proxy.size.height) * 0.62
                    )
                )
                .padding(.horizontal, max(18, proxy.size.width * 0.055))
                .padding(.vertical, max(18, proxy.size.height * 0.045))
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

@available(macOS 14.0, *)
private struct DojoRenderTuplePresentation: Identifiable {
    let id: String
    let geometry: String
    let role: String
    let evidence: String
    let authority: String
    let next: String
    let primeState: String
}

@available(macOS 14.0, *)
private struct DOJOInvestigationDeskView: View {
    var askAbout: (String) -> Void
    var captureNote: () -> Void
    var openInspector: () -> Void

    @State private var selectedID = DOJOInvestigationCard.seed.first?.id

    private var selectedCard: DOJOInvestigationCard {
        DOJOInvestigationCard.seed.first { $0.id == selectedID } ?? DOJOInvestigationCard.seed[0]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text(Chamber.dojo.rawValue)
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundStyle(canonicalRoleColor(.dojo))
                            Text("Investigations")
                                .font(.system(size: 30, weight: .semibold, design: .rounded))
                                .foregroundStyle(dojoTextPrimary)
                        }
                        Text("A working map for this FIELD. DOJO points, composes, and records next evidence; native systems keep their own authority.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(dojoTextSecondary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: 680, alignment: .leading)
                    }
                    Spacer(minLength: 12)
                    statusPill("Snapshot", color: Color(hex: "#FBBF24"))
                }

                authorityBand
                chakraHoldBand
                dojoRenderProjectionBand

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 260), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(DOJOInvestigationCard.seed) { card in
                        Button {
                            selectedID = card.id
                        } label: {
                            investigationCard(card, selected: card.id == selectedID)
                        }
                        .buttonStyle(.plain)
                    }
                }

                selectedPanel(selectedCard)
            }
            .padding(24)
            .padding(.bottom, 112)
        }
    }

    private var authorityBand: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(Chamber.tata.rawValue)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(canonicalRoleColor(.tata))
            VStack(alignment: .leading, spacing: 4) {
                Text("Authority Boundary")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(dojoTextPrimary)
                Text("Representation, provenance, current status, and next evidence stay separate. No card claims live control over Notion, Google, GitHub, Vercel, finance, legal, or trading systems.")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(dojoTextSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(dojoPanelRaised.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var chakraHoldBand: some View {
        HStack(alignment: .center, spacing: 10) {
            Text("⬡")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(dojoTextTertiary)
            Text("Prime-fractal recursive chakra genotype")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(dojoTextSecondary)
            Spacer(minLength: 8)
            statusPill("HOLD · not embodied", color: Color(hex: "#FBBF24"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(dojoPanel.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var dojoRenderProjectionBand: some View {
        let receipt = LocalDojoTodayRenderBridge.consumeVerifiedFeed()
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("Render projection")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(dojoTextTertiary)
                statusPill("READ ONLY", color: Color(hex: "#89A8B1"))
                statusPill("VERIFIED FEED", color: Color(hex: "#89A8B1"))
                statusPill("dojo", color: Color(hex: "#2563EB"))
                statusPill("NO LIVE NOTION MCP", color: Color(hex: "#FBBF24"))
                Spacer(minLength: 8)
            }
            HStack(alignment: .top, spacing: 12) {
                ForEach(receipt.projection.tuples.map { tuple in
                    DojoRenderTuplePresentation(
                        id: tuple.id,
                        geometry: tuple.geometry.rawValue,
                        role: tuple.role.rawValue,
                        evidence: tuple.evidence.rawValue,
                        authority: tuple.authority.rawValue,
                        next: tuple.next,
                        primeState: tuple.primeState.rawValue
                    )
                }) { tuple in
                    dojoRenderTupleCard(tuple)
                }
            }
            Text(LocalDojoTodayRenderBridge.relationshipEvidenceBoundary)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(dojoTextTertiary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            Text(receipt.receiptLine)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(dojoTextTertiary)
                .lineLimit(1)
        }
    }

    private func dojoRenderTupleCard(_ tuple: DojoRenderTuplePresentation) -> some View {
        let chamberColor = canonicalRoleColor(.dojo)
        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Text(Chamber.dojo.rawValue)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundStyle(chamberColor)
                VStack(alignment: .leading, spacing: 3) {
                    Text(tuple.geometry)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(dojoTextPrimary)
                    Text("\(tuple.role) · \(tuple.authority)")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(dojoTextTertiary)
                }
                Spacer(minLength: 4)
                statusPill(tuple.evidence, color: evidencePillColor(tuple.evidence))
            }
            Text(tuple.next)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(dojoTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
            statusPill(tuple.primeState, color: Color(hex: "#FBBF24"))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(dojoPanel)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(chamberColor.opacity(0.35), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func evidencePillColor(_ evidence: String) -> Color {
        switch evidence {
        case "HOLD": return Color(hex: "#FBBF24")
        case "SEALED": return Color(hex: "#89A8B1")
        case "PROMOTE": return Color(hex: "#93C5FD")
        default: return Color(hex: "#FBBF24")
        }
    }

    private func investigationCard(_ card: DOJOInvestigationCard, selected: Bool) -> some View {
        let roleColor = canonicalRoleColor(card.chamber)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 9) {
                Text(card.chamber.rawValue)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundStyle(roleColor)
                    .frame(width: 20)
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(dojoTextPrimary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                    Text(card.nativeAuthority)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(dojoTextTertiary)
                        .lineLimit(2)
                    Text("\(canonicalChamberName(card.chamber)) · \(card.chamber.frequency) Hz")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(roleColor.opacity(0.88))
                }
                Spacer(minLength: 4)
                statusPill(card.status, color: card.statusColor)
            }
            Divider().overlay(dojoDividerColor.opacity(0.72))
            smallLine("Representation", card.representation)
            smallLine("Next evidence", card.nextEvidence)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 166, alignment: .topLeading)
        .background(selected ? dojoPanelRaised : dojoPanel)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(selected ? roleColor : roleColor.opacity(0.35), lineWidth: selected ? 1.5 : 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func selectedPanel(_ card: DOJOInvestigationCard) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Selected Work")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(dojoTextPrimary)
                Spacer()
                statusPill("DOJO pointer", color: Color(hex: "#6CEBFF"))
            }
            Text(card.detail)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(dojoTextSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
            HStack(alignment: .top, spacing: 14) {
                detailColumn("Ceiling", card.ceiling)
                detailColumn("Obligation", card.action)
                detailColumn("Next", card.nextEvidence)
            }
            HStack(spacing: 9) {
                deskAction("Ask", systemImage: "paperplane") { askAbout(card.title) }
                deskAction("Capture", systemImage: "square.and.pencil") { captureNote() }
                deskAction("Inspector", systemImage: "rectangle.and.text.magnifyingglass") { openInspector() }
            }
        }
        .padding(16)
        .background(dojoPanelRaised.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func detailColumn(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(dojoTextTertiary)
            Text(value)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(dojoTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func smallLine(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title.uppercased())
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(dojoTextTertiary)
            Text(value)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(dojoTextSecondary)
                .lineLimit(2)
        }
    }

    private func statusPill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 8, weight: .bold, design: .monospaced))
            .foregroundStyle(color)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 5))
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
}

private struct DOJOInvestigationCard: Identifiable {
    let id: String
    let title: String
    let chamber: Chamber
    let status: String
    let statusColor: Color
    let nativeAuthority: String
    let representation: String
    let nextEvidence: String
    let ceiling: String
    let action: String
    let detail: String

    static let seed: [DOJOInvestigationCard] = [
        .init(id: "backbone-2007", title: "2007 Strategic Backbone", chamber: .tata, status: "Historical", statusColor: Color(hex: "#86EFAC"), nativeAuthority: "Legacy source still requires exact witness", representation: "Blueprint / Gemini / local lineage", nextEvidence: "Verify original source anchor", ceiling: "Historical anchor only", action: "Preserve", detail: "Useful orientation material, but not current runtime authority until a fresh source witness exists."),
        .init(id: "call-file", title: "23-point Call File / CRM genotype", chamber: .atlas, status: "Hold", statusColor: Color(hex: "#FBBF24"), nativeAuthority: "FRE ontology and original CRM exports", representation: "Notion CRM card / Gemini analysis / local schema", nextEvidence: "Witness schema and runtime parity", ceiling: "Evaluation only", action: "Hold with recheck", detail: "The representations are useful for comparison. No surface currently proves a live governed CRM genotype."),
        .init(id: "finance", title: "Finance / Matters records", chamber: .tata, status: "No authority", statusColor: Color(hex: "#F87171"), nativeAuthority: "Native financial and legal systems", representation: "Evidence matrices and local records", nextEvidence: "Name native records and connector boundary", ceiling: "No financial or legal action", action: "Preserve", detail: "DOJO can show evidence lanes. It cannot adjudicate, submit, pay, cancel, or change records."),
        .init(id: "github", title: "GitHub / local implementation", chamber: .atlas, status: "Unknown", statusColor: Color(hex: "#FBBF24"), nativeAuthority: "Local repo and remote GitHub history", representation: "Worktree, source files, commit history", nextEvidence: "Read-only ref and diff comparison", ceiling: "Implementation evidence only", action: "Recheck", detail: "Local code can be inspected here. Remote alignment remains unknown until a fresh read-only comparison succeeds."),
        .init(id: "vercel", title: "Vercel / v0 surfaces", chamber: .dojo, status: "Preserve", statusColor: Color(hex: "#FBBF24"), nativeAuthority: "Vercel account and project surfaces", representation: "Dashboard, deployment views, receipts", nextEvidence: "Re-witness exact project row", ceiling: "Deployment witness only", action: "Preserve", detail: "Deployment, DNS, billing, refunds, and account changes remain outside this desk.")
    ]
}

@available(macOS 14.0, *)
private struct SpatialEvidenceMapSection: View {
    let projection: SpatialEvidenceProjection
    @Binding var selectedProjectionID: String?
    let todayFont: (CGFloat, Font.Weight, Font.Design) -> Font

    private var annotation: SpatialEvidenceAnnotationModel? {
        SpatialEvidenceAnnotationModel(projection: projection)
    }

    private var isSelected: Bool {
        selectedProjectionID == projection.projectionGrounding.projectionIdentity.projectionID
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Spatial evidence")
                        .font(todayFont(13, .bold, .rounded))
                        .foregroundStyle(dojoTextPrimary)
                    Text("FIXTURE / DEVELOPMENT PROOF — NOT LIVE LOCATION")
                        .font(todayFont(9, .bold, .monospaced))
                        .foregroundStyle(Color(hex: "#FBBF24"))
                        .accessibilityLabel("Fixture development proof. Not live location.")
                }
                Spacer()
                Text(projection.projectionGrounding.authorityStatus.decision.rawValue)
                    .font(todayFont(8, .bold, .monospaced))
                    .foregroundStyle(authorityColor)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(authorityColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }

            HStack(alignment: .top, spacing: 12) {
                mapPane
                    .frame(minWidth: 280, idealWidth: 360, maxWidth: .infinity)
                inverseInspector
                    .frame(minWidth: 260, idealWidth: 320, maxWidth: 360, alignment: .topLeading)
            }

            textualEquivalent
        }
        .padding(14)
        .background(dojoPanel.opacity(0.90))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#6CEBFF").opacity(0.25), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Spatial evidence fixture. Native MapKit map with inverse grounding inspector. Not live location.")
        .onAppear {
            if selectedProjectionID == nil, annotation != nil {
                selectedProjectionID = projection.projectionGrounding.projectionIdentity.projectionID
            }
        }
    }

    @ViewBuilder
    private var mapPane: some View {
        if let annotation {
            Map(
                initialPosition: .region(
                    MKCoordinateRegion(
                        center: annotation.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)
                    )
                ),
                interactionModes: [.pan, .zoom]
            ) {
                Annotation(annotation.title, coordinate: annotation.coordinate) {
                    Button {
                        selectedProjectionID = annotation.id
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: isSelected ? "mappin.circle.fill" : "mappin.circle")
                                .font(todayFont(24, .semibold, .rounded))
                                .foregroundStyle(isSelected ? Color(hex: "#6CEBFF") : Color(hex: "#FBBF24"))
                            Text("Fixture")
                                .font(todayFont(8, .bold, .monospaced))
                                .foregroundStyle(Color(hex: "#031416"))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color(hex: "#EAFBFF"))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .padding(6)
                        .background(dojoPanelRaised.opacity(0.92))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Select fixture spatial evidence annotation")
                    .accessibilityHint("Shows inverse grounding for the fixture capture receipt.")
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(height: 220)
            .overlay(alignment: .bottomLeading) {
                Text("MapKit rendering only · no user-location dot")
                    .font(todayFont(9, .semibold, .rounded))
                    .foregroundStyle(Color(hex: "#C9E4EA"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(dojoPanelRaised.opacity(0.86))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(8)
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("Map projection withheld")
                    .font(todayFont(12, .bold, .rounded))
                    .foregroundStyle(Color(hex: "#FBBF24"))
                Text("Spatial coordinate or projection authority is Unknown/HOLD, so no authoritative annotation is fabricated.")
                    .font(todayFont(11, .medium, .rounded))
                    .foregroundStyle(dojoTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 220, alignment: .center)
            .padding(14)
            .background(dojoPanelRaised.opacity(0.74))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var inverseInspector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isSelected ? "Inverse trace · selected" : "Inverse trace")
                .font(todayFont(12, .bold, .rounded))
                .foregroundStyle(dojoTextPrimary)

            inverseRow("Object", projection.projectionGrounding.representedObject.objectID)
            inverseRow("Projection", projection.projectionGrounding.projectionIdentity.projectionID)
            inverseRow("Ontology", projection.projectionGrounding.representedObject.ontologyKind.rawValue)
            inverseRow("Evidence", evidenceSummary)
            inverseRow("Observation", formattedDate(projection.spatialAnchor.observedAt))
            inverseRow("Recording", formattedDate(projection.projectionGrounding.temporalValidity.recordingTime))
            inverseRow("Projection time", formattedDate(projection.projectionGrounding.temporalValidity.projectionTime))
            inverseRow("Temporal state", projection.projectionGrounding.temporalValidity.freshness.rawValue)
            inverseRow("Authority", projection.projectionGrounding.authorityStatus.decision.rawValue)
            inverseRow("Unknown", list(projection.projectionGrounding.unknownDimensions.map(\.rawValue)))
            inverseRow("HOLD", list(projection.projectionGrounding.holdReasons.map(\.rawValue)))
            inverseRow("Correction", projection.projectionGrounding.correctionRoute.destination)
            inverseRow("Status", "Fixture only · no live sync")
        }
        .padding(12)
        .background(dojoPanelRaised.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .contain)
    }

    private var textualEquivalent: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Text equivalent")
                .font(todayFont(10, .bold, .rounded))
                .foregroundStyle(dojoTextTertiary)
            Text("Fixture annotation \(projection.projectionGrounding.projectionIdentity.projectionID) represents \(projection.projectionGrounding.representedObject.objectID), grounded by \(evidenceSummary), recorded \(formattedDate(projection.projectionGrounding.temporalValidity.recordingTime)), authority \(projection.projectionGrounding.authorityStatus.decision.rawValue), correction route \(projection.projectionGrounding.correctionRoute.destination).")
                .font(todayFont(11, .medium, .rounded))
                .foregroundStyle(dojoTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .background(dojoControl.opacity(0.70))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var authorityColor: Color {
        switch projection.projectionGrounding.authorityStatus.decision {
        case .pass: return Color(hex: "#86EFAC")
        case .hold, .unknown: return Color(hex: "#FBBF24")
        case .fail: return Color(hex: "#F87171")
        }
    }

    private var evidenceSummary: String {
        guard let evidence = projection.projectionGrounding.evidenceAnchors.first else {
            return "Unknown.Source"
        }
        return "\(evidence.kind.rawValue) · \(evidence.state.rawValue) · \(evidence.sourceID ?? "Unknown.Source")"
    }

    private func inverseRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(title)
                .font(todayFont(9, .semibold, .rounded))
                .foregroundStyle(dojoTextTertiary)
                .frame(width: 82, alignment: .leading)
            Text(value)
                .font(todayFont(9, .medium, .rounded))
                .foregroundStyle(dojoTextPrimary)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "Unknown" }
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    private func list(_ values: [String]) -> String {
        values.isEmpty ? "None" : values.joined(separator: ", ")
    }
}

@available(macOS 14.0, *)
private struct SpatialEvidenceAnnotationModel: Identifiable, Equatable {
    let id: String
    let title: String
    let coordinate: CLLocationCoordinate2D
    let grounding: ProjectionGrounding

    init?(projection: SpatialEvidenceProjection) {
        guard projection.mayRenderAsOrdinaryMapAnnotation,
              let coordinate = projection.spatialAnchor.coordinate else {
            return nil
        }
        self.id = projection.projectionGrounding.projectionIdentity.projectionID
        self.title = projection.spatialAnchor.displayName
        self.coordinate = coordinate.mapCoordinate
        self.grounding = projection.projectionGrounding
    }

    static func == (lhs: SpatialEvidenceAnnotationModel, rhs: SpatialEvidenceAnnotationModel) -> Bool {
        lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.coordinate.latitude == rhs.coordinate.latitude &&
            lhs.coordinate.longitude == rhs.coordinate.longitude &&
            lhs.grounding == rhs.grounding
    }
}

@available(macOS 14.0, *)
private extension SpatialCoordinate {
    var mapCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

private extension InputMode {
    var diagnosticLabel: String {
        switch self {
        case .voice: return "Voice"
        case .text: return "Text"
        case .visual: return "Visual"
        case .gesture: return "Gesture"
        case .biometric: return "Biometric"
        case .unknown: return "Unknown"
        }
    }
}

private extension OutputMode {
    var diagnosticLabel: String {
        switch self {
        case .voice: return "Voice"
        case .text: return "Text"
        case .visual: return "Visual"
        case .haptic: return "Haptic"
        case .silent: return "Silent"
        case .unknown: return "Unknown"
        }
    }
}

private extension BiometricState {
    var diagnosticLabel: String {
        switch self {
        case .unknown: return "Unknown"
        case .steady: return "Steady"
        case .discovery: return "Discovery"
        case .deepWork: return "Deep work"
        case .stress: return "Stress"
        }
    }
}

private extension EnvironmentState {
    var diagnosticLabel: String {
        var parts: [String] = []
        if let noiseLevel {
            parts.append("noise \(Int((noiseLevel * 100).rounded()))%")
        } else {
            parts.append("noise unknown")
        }
        parts.append(isPublic ? "public" : "private")
        if isMotionActive {
            parts.append("motion")
        }
        return parts.joined(separator: " · ")
    }
}

private extension DeviceSurface {
    var diagnosticLabel: String {
        switch self {
        case .mac: return "Mac"
        case .iPhone: return "iPhone"
        case .iPad: return "iPad"
        case .watch: return "Watch"
        case .web: return "Web"
        case .unknown: return "Unknown"
        }
    }
}

#Preview("DOJO Today workspace shell") {
    if #available(macOS 14.0, *) {
        DOJOTodaySurfaceView()
            .frame(width: 1280, height: 860)
    }
}
