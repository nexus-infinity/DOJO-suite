import SwiftUI
import AppKit
import Foundation
import DOJOShared
import DOJOUI

#if os(macOS)

// MARK: - DOJO Graphics Theme

struct DOJOTheme {
    // Sacred Geometry Colors
    static let void = Color(hex: "#0A0A0C")           // Absolute void
    static let obsidian = Color(hex: "#111113")       // Deep obsidian
    static let slate = Color(hex: "#1E1E20")          // Slate surface
    static let stone = Color(hex: "#2D2D30")          // Stone border
    
    // Frequency Colors (741 Hz + 963 Hz)
    static let manifestation = Color(hex: "#7C3AED")  // 741 Hz - Purple (primary)
    static let observer = Color(hex: "#A78BFA")       // 963 Hz - Light purple
    static let consciousness = Color(hex: "#C4B5FD")  // Consciousness glow
    
    // Semantic Colors
    static let danger = Color(hex: "#EF4444")         // Red (clipping/error)
    static let caution = Color(hex: "#F59E0B")        // Amber (warning)
    static let optimal = Color(hex: "#10B981")        // Green (good signal)
    static let quiet = Color(hex: "#3B82F6")          // Blue (low signal)
    
    // Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "#D1D5DB")
    static let textTertiary = Color(hex: "#9CA3AF")
    static let textMuted = Color(hex: "#6B7280")
    static let textDim = Color(hex: "#4B5563")
    
    // Geometric Gradients
    static let pyramidGradient = LinearGradient(
        colors: [manifestation, observer],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let frequencyGradient = LinearGradient(
        colors: [manifestation, consciousness],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Main Audio Capture View

struct DOJOAudioCaptureView: View {
    @StateObject private var controller = MacOSMurmurController()
    @State private var selectedTab: Tab = .cockpitShell
    
    enum Tab {
        case cockpitShell
        case integrity
        case particleboard
        case capture
        case monitor
        case cockpit
        case receipts
    }
    
    var body: some View {
        ZStack {
            // Geometric background layer
            DOJOTheme.void
            
            VStack(spacing: 0) {
                deviceSelector
                Divider().background(DOJOTheme.stone)
                tabSelector
                Divider().background(DOJOTheme.stone)
                
                Group {
                    switch selectedTab {
                    case .cockpitShell:
                        CockpitShellAlphaView()
                    case .integrity:
                        PortalIntegrityLoopReviewView()
                    case .particleboard:
                        ParticleBoardFirstSliceView()
                    case .capture:
                        captureTab
                    case .monitor:
                        AudioMonitorView(controller: controller)
                    case .cockpit:
                        G6CockpitSurfaceView()
                    case .receipts:
                        GateReceiptView()
                    }
                }
            }
        }
        .frame(minWidth: 860, minHeight: 720)
    }
    
    private var deviceSelector: some View {
        HStack(spacing: 12) {
            // Frequency icon (741 Hz manifestation)
            Image(systemName: "waveform.badge.mic")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(DOJOTheme.pyramidGradient)
                .shadow(color: DOJOTheme.manifestation.opacity(0.3), radius: 4)
            
            Text("INPUT DEVICE")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(DOJOTheme.textMuted)
                .tracking(1.2)
            
            Menu {
                ForEach(controller.deviceManager.availableDevices) { device in
                    Button {
                        controller.deviceManager.selectedDevice = device
                    } label: {
                        HStack {
                            Text("\(device.type.icon) \(device.name)")
                            if controller.deviceManager.selectedDevice?.id == device.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(DOJOTheme.manifestation)
                            }
                        }
                    }
                }
                
                Divider()
                
                Button {
                    Task {
                        await controller.deviceManager.refreshDevices()
                    }
                } label: {
                    Label("Refresh Devices", systemImage: "arrow.clockwise.circle")
                }
            } label: {
                HStack(spacing: 8) {
                    if let device = controller.deviceManager.selectedDevice {
                        Text(device.type.icon)
                            .font(.system(size: 14))
                        Text(device.name)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(DOJOTheme.textPrimary)
                    } else {
                        Text("No device selected")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(DOJOTheme.textMuted)
                    }
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(DOJOTheme.textMuted)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(DOJOTheme.obsidian)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(controller.deviceManager.selectedDevice != nil ? DOJOTheme.manifestation.opacity(0.3) : DOJOTheme.stone, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .disabled(controller.isCapturing)
            
            Spacer()
            
            if controller.isCapturing {
                HStack(spacing: 8) {
                    // Pulsing sacred geometry indicator
                    Circle()
                        .fill(DOJOTheme.danger)
                        .frame(width: 8, height: 8)
                        .shadow(color: DOJOTheme.danger.opacity(0.6), radius: 6)
                    Text("RECORDING")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(DOJOTheme.danger)
                        .tracking(1.5)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(DOJOTheme.danger.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(DOJOTheme.danger.opacity(0.4), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            ZStack {
                DOJOTheme.slate
                // Subtle pyramid geometry pattern
                DOJOTheme.manifestation.opacity(0.02)
            }
        )
    }
    
    private var tabSelector: some View {
        HStack(spacing: 4) {
            DOJOTabButton(
                title: "Shell",
                icon: "point.3.connected_trianglepath.dotted",
                frequency: "α",
                isSelected: selectedTab == .cockpitShell
            ) {
                selectedTab = .cockpitShell
            }

            DOJOTabButton(
                title: "Portal",
                icon: "lock.shield",
                frequency: "edge",
                isSelected: selectedTab == .integrity
            ) {
                selectedTab = .integrity
            }

            DOJOTabButton(
                title: "Particle",
                icon: "sparkles",
                frequency: "slice-1",
                isSelected: selectedTab == .particleboard
            ) {
                selectedTab = .particleboard
            }

            DOJOTabButton(
                title: "Capture",
                icon: "waveform.circle.fill",
                frequency: "741 Hz",
                isSelected: selectedTab == .capture
            ) {
                selectedTab = .capture
            }
            
            DOJOTabButton(
                title: "Monitor",
                icon: "chart.xyaxis.line",
                frequency: "963 Hz",
                isSelected: selectedTab == .monitor
            ) {
                selectedTab = .monitor
            }

            DOJOTabButton(
                title: "Cockpit",
                icon: "square.grid.3x3.fill",
                frequency: "G3",
                isSelected: selectedTab == .cockpit
            ) {
                selectedTab = .cockpit
            }
            
            DOJOTabButton(
                title: "G6 Gate",
                icon: "checkmark.seal.fill",
                frequency: "Ξ",
                isSelected: selectedTab == .receipts
            ) {
                selectedTab = .receipts
            }
        }
        .padding(12)
        .background(DOJOTheme.obsidian)
    }

    private struct ParticleBoardFirstSliceView: View {
        var body: some View {
            CockpitParticleSmokeAccentView()
        }
    }
}

// MARK: - Cockpit Shell Alpha (composed operator surface)

@MainActor
final class PortalIntegrityLoopProofModel: ObservableObject {
    static let packetID = "11111111-2222-3333-4444-555555555555"
    static let shortSeal = "97a7f0da"
    static let fullSeal = "97a7f0da0adc70856abe294e46dfd72a34533bf8917ac1f82336ac85663d7c76"
    static let lifecycle = [
        "Captured",
        "Local sealed",
        "Queued",
        "Syncing",
        "Receipted",
        "Validated",
        "Manifested/Hold"
    ]

    @Published var currentState = "Queued"
    @Published var syncMessage = "Preserved locally. Queued for AKRON. Not yet sovereignly receipted."
    @Published var receiptID: String?
    @Published var isSyncing = false
    @Published var holdActive = false
    @Published var holdMessage: String?

    var stateColor: Color {
        switch currentState {
        case "Queued": return DOJOTheme.caution
        case "Syncing": return DOJOTheme.quiet
        case "Receipted": return DOJOTheme.optimal
        default: return DOJOTheme.textMuted
        }
    }

    func applyHold() {
        holdActive = true
        holdMessage = "Governor HOLD — packet remains queued locally. No AKRON receipt claimed."
        syncMessage = holdMessage ?? syncMessage
    }

    func applyCorrectAdvisory() {
        holdActive = false
        holdMessage = "Correction is Governor-only in Shell Alpha. No structural edits applied."
        syncMessage = holdMessage ?? syncMessage
    }

    func attemptAkronSync() async {
        isSyncing = true
        currentState = "Syncing"
        syncMessage = "Attempting to submit the proof packet to AKRON."
        receiptID = nil

        do {
            let receipt = try await Self.submitProofPacket()
            receiptID = receipt
            currentState = "Receipted"
            syncMessage = "AKRON receipt received. This prototype still does not claim FIELD validation."
        } catch {
            currentState = "Queued"
            syncMessage = "AKRON not reached — packet remains queued."
        }

        isSyncing = false
    }

    private static func submitProofPacket() async throws -> String {
        let url = URL(string: "http://100.79.35.36:3960/packets")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 8
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "id": packetID,
            "deviceID": "dojoapp-governor-review",
            "operatorID": "portal-integrity-loop",
            "integrityHash": fullSeal,
            "previousPacketHash": NSNull(),
            "textNotes": "Portal Integrity Loop proof packet",
            "mediaRefs": ["local-seal:portal-integrity-loop-proof"],
            "voiceRef": NSNull(),
            "state": "QUEUED",
            "retryCount": 0
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        if let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let receiptID = object["receiptID"] as? String { return receiptID }
            if let receiptID = object["receipt_id"] as? String { return receiptID }
        }

        throw URLError(.cannotParseResponse)
    }
}

struct CockpitShellAlphaView: View {
    @StateObject private var proof = PortalIntegrityLoopProofModel()
    @State private var showInspect = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                presenceHeader
                fourSurfacesStrip
                sealedEventObject
                layerHints
                operatorControls
                governorPrompt
            }
            .padding(24)
            .frame(minWidth: 760, maxWidth: .infinity, alignment: .leading)
        }
        .background(DOJOTheme.void)
        .scrollIndicators(.visible)
        .sheet(isPresented: $showInspect) {
            inspectSheet
        }
    }

    private var presenceHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(DOJOTheme.pyramidGradient)
                    .frame(width: 10, height: 10)
                    .shadow(color: DOJOTheme.manifestation.opacity(0.45), radius: 8)
                Text("DOJO Cockpit Shell α")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(DOJOTheme.textPrimary)
            }
            Text("Niama presence · 741 Hz")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(DOJOTheme.manifestation)
                .tracking(1.1)
            Text("I have preserved this locally. AKRON receipt is pending.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(DOJOTheme.textPrimary)
            Text("Not yet sovereignly receipted.")
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(DOJOTheme.textMuted)
        }
    }

    private var fourSurfacesStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("FOUR SURFACES · HONEST")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(DOJOTheme.textDim)
                .tracking(1.2)
            HStack(spacing: 8) {
                surfaceChip("Interface", "Cockpit visible", DOJOTheme.quiet)
                surfaceChip("State", "Packet queued", DOJOTheme.caution)
                surfaceChip("Route", "AKRON pending", DOJOTheme.caution)
                surfaceChip("Body", "Not instrumented", DOJOTheme.textMuted)
            }
            .frame(minHeight: 54)
        }
        .padding(14)
        .background(DOJOTheme.obsidian)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(DOJOTheme.stone, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func surfaceChip(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(DOJOTheme.textDim)
            Text(value)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(color)
                .lineLimit(2)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(DOJOTheme.slate.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var sealedEventObject: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SEALED EVENT OBJECT")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(DOJOTheme.textDim)
                .tracking(1.2)

            VStack(alignment: .leading, spacing: 14) {
                CockpitParticleSmokeAccentView(showGovernorPrompt: false)
                    .frame(minHeight: 260, maxHeight: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(DOJOTheme.stone, lineWidth: 1))

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Sealed event")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(DOJOTheme.textPrimary)
                        Spacer()
                        Text(proof.currentState.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(proof.stateColor)
                    }
                    Text("seal · \(PortalIntegrityLoopProofModel.shortSeal)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(DOJOTheme.consciousness)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text("Proof packet · smoke crystallizing to seal")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(DOJOTheme.textMuted)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DOJOTheme.obsidian.opacity(0.86))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(proof.stateColor.opacity(0.5), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(14)
        .background(DOJOTheme.obsidian)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(DOJOTheme.stone, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var layerHints: some View {
        HStack(spacing: 10) {
            layerPill("Niama", "presence")
            layerPill("Arkadaş", "717 · align")
            layerPill("AKRON", "receipt gate")
            layerPill("FIELD", "validation")
        }
        .padding(.top, 4)
    }

    private func layerPill(_ name: String, _ hint: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(DOJOTheme.textSecondary)
            Text(hint)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(DOJOTheme.textDim)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(DOJOTheme.slate.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var operatorControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OPERATOR")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(DOJOTheme.textDim)
                .tracking(1.2)

            Text(proof.syncMessage)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(DOJOTheme.textSecondary)

            if let receiptID = proof.receiptID {
                shellDetailRow("AKRON receipt", receiptID)
            }

            HStack(spacing: 10) {
                Button("Inspect") { showInspect = true }
                    .buttonStyle(.bordered)
                Button {
                    Task { await proof.attemptAkronSync() }
                } label: {
                    if proof.isSyncing {
                        ProgressView().controlSize(.small)
                    } else {
                        Text("Attempt AKRON Sync")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(DOJOTheme.manifestation)
                .disabled(proof.isSyncing)
                Button("Hold") { proof.applyHold() }
                    .buttonStyle(.bordered)
                Button("Correct") { proof.applyCorrectAdvisory() }
                    .buttonStyle(.bordered)
            }
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
        }
        .padding(16)
        .background(DOJOTheme.obsidian)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(DOJOTheme.stone, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var governorPrompt: some View {
        Text("Work-layer check: witness, receipt, route, and operator action should remain visible without overlap.")
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundStyle(DOJOTheme.textTertiary)
            .padding(.top, 4)
    }

    private var inspectSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    shellDetailRow("Packet ID", PortalIntegrityLoopProofModel.packetID)
                    shellDetailRow("Local seal", PortalIntegrityLoopProofModel.fullSeal)
                    lifecycleLadder
                }
                .padding(20)
            }
            .background(DOJOTheme.void)
            .navigationTitle("Inspect · Proof Packet")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { showInspect = false }
                }
            }
        }
        .frame(minWidth: 480, minHeight: 420)
    }

    private var lifecycleLadder: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lifecycle")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(DOJOTheme.textSecondary)
            HStack(spacing: 8) {
                ForEach(PortalIntegrityLoopProofModel.lifecycle, id: \.self) { step in
                    shellLifecycleStep(step)
                    if step != PortalIntegrityLoopProofModel.lifecycle.last {
                        Rectangle().fill(DOJOTheme.stone).frame(width: 12, height: 1)
                    }
                }
            }
        }
        .padding(16)
        .background(DOJOTheme.obsidian)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(DOJOTheme.stone, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func shellLifecycleStep(_ step: String) -> some View {
        let isCurrent = step == proof.currentState
        return VStack(spacing: 6) {
            Circle()
                .fill(isCurrent ? proof.stateColor : DOJOTheme.stone)
                .frame(width: 12, height: 12)
            Text(step)
                .font(.system(size: 9, weight: isCurrent ? .bold : .medium, design: .monospaced))
                .foregroundStyle(isCurrent ? DOJOTheme.textPrimary : DOJOTheme.textMuted)
                .multilineTextAlignment(.center)
                .frame(width: 68, height: 28)
        }
    }

    private func shellDetailRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(DOJOTheme.textDim)
            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(DOJOTheme.textSecondary)
                .textSelection(.enabled)
        }
    }
}

// MARK: - Particle smoke accent (shared slice)

struct CockpitParticleSmokeAccentView: View {
        var showGovernorPrompt: Bool = true

        private let cycleDuration: Double = 14.0
        private let smokeColumns: Int = 30
        private let smokeRows: Int = 18
        private let holdItems: [String] = [
            "Document/image condensation is HOLD",
            "AI image generation is Unknown/disabled",
            "Multimodal fusion is Unknown/not implemented",
            "Live FIELD telemetry wiring is Unknown/not implemented"
        ]

        var body: some View {
            TimelineView(.animation) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let cycle = (time.truncatingRemainder(dividingBy: cycleDuration)) / cycleDuration

                VStack(spacing: 0) {
                    particleCanvas(cycle: cycle, time: time)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(alignment: .topLeading) {
                            overlayPanel(cycle: cycle)
                                .padding(18)
                        }
                        .overlay(alignment: .bottomLeading) {
                            if showGovernorPrompt {
                                governorPrompt
                                    .padding(18)
                            }
                        }
                }
                .background(DOJOTheme.void)
            }
        }

        private func particleCanvas(cycle: Double, time: Double) -> some View {
            Canvas { context, size in
                let rect = CGRect(origin: .zero, size: size)
                context.fill(Path(rect), with: .color(DOJOTheme.void))

                let attractor = CGPoint(x: size.width * 0.5, y: size.height * 0.46)
                let glyphOpacity = glyphOpacity(for: cycle)
                let smokeOpacity = smokeOpacity(for: cycle)
                let stillness = stillnessProgress(for: cycle)
                let pressure = pressureProgress(for: cycle)
                let glyphPoints = triangleGlyphPoints(center: attractor, radius: min(size.width, size.height) * 0.12)

                drawAtmosphere(context: &context, rect: rect, attractor: attractor, cycle: cycle)
                drawAttractor(context: &context, at: attractor, cycle: cycle)

                context.drawLayer { layer in
                    layer.addFilter(.blur(radius: 18))
                    for row in 0..<smokeRows {
                        for col in 0..<smokeColumns {
                            let point = pressuredSmokePoint(
                                row: row,
                                col: col,
                                in: size,
                                time: time,
                                attractor: attractor,
                                pressure: pressure
                            )
                            let noise = smokeNoise(at: point, time: time)
                            let fieldDensity = radialInfluence(point: point, center: attractor, radius: min(size.width, size.height) * 0.42)
                            let glyphDensity = glyphFieldStrength(at: point, glyphPoints: glyphPoints)
                            let edgeAngle = glyphEdgeDirection(at: point, glyphPoints: glyphPoints)
                            let alpha = 0.015
                                + 0.08 * smokeOpacity
                                + 0.10 * noise
                                + 0.10 * fieldDensity
                                + 0.30 * pressure * glyphDensity
                                + 0.18 * stillness * glyphDensity
                            let width = 34
                                + 28 * noise
                                + 36 * pressure * fieldDensity
                                + 44 * glyphDensity * pressure
                            let height = 20
                                + 14 * noise
                                + 18 * fieldDensity
                                + 24 * glyphDensity * pressure
                            let smokeShape = orientedSmokePath(
                                center: point,
                                width: width,
                                height: height,
                                angle: edgeAngle,
                                alignment: glyphDensity * pressure
                            )
                            let tint = glyphDensity > 0.22
                                ? DOJOTheme.consciousness.opacity(alpha * (0.92 + 0.18 * glyphDensity))
                                : DOJOTheme.manifestation.opacity(alpha)
                            layer.fill(smokeShape, with: .color(tint))

                            if glyphDensity > 0.24 {
                                let glowShape = orientedSmokePath(
                                    center: point,
                                    width: width + 10,
                                    height: height + 8,
                                    angle: edgeAngle,
                                    alignment: glyphDensity * pressure
                                )
                                layer.fill(glowShape, with: .color(DOJOTheme.observer.opacity(0.04 + 0.10 * pressure * glyphDensity)))
                            }
                        }
                    }
                }

                if glyphOpacity > 0.02 {
                    context.drawLayer { layer in
                        layer.addFilter(.blur(radius: 6))
                        var glyph = Path()
                        glyph.move(to: glyphPoints[0])
                        glyph.addLines(glyphPoints)
                        glyph.closeSubpath()
                        layer.stroke(
                            glyph,
                            with: .color(DOJOTheme.consciousness.opacity(0.03 + 0.07 * glyphOpacity)),
                            lineWidth: 0.8 + 0.5 * glyphOpacity
                        )
                    }
                }
            }
        }

        private func overlayPanel(cycle: Double) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("PROTOTYPE / NOT CANON")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(DOJOTheme.caution)

                Text("PARTICLEBOARD — FAST PROTOTYPE LANE")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(DOJOTheme.consciousness)

                Text("Dark canvas · ambient smoke/static field · one attractor · glyph condensation from field density and pressure · dissolve to smoke")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DOJOTheme.textSecondary)

                Text("Phase: \(phaseLabel(for: cycle))")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(DOJOTheme.textTertiary)

                Text("Breath: ambient smoke -> pressure call -> condensation -> brief stillness -> dissolution")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(DOJOTheme.textMuted)

                Divider().overlay(DOJOTheme.stone)

                Text("HOLD / UNKNOWN")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(DOJOTheme.caution)

                ForEach(holdItems, id: \.self) { item in
                    Text("• \(item)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(DOJOTheme.textSecondary)
                }
            }
            .padding(14)
            .background(DOJOTheme.slate.opacity(0.92))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(DOJOTheme.stone, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: 430, alignment: .leading)
        }

        private var governorPrompt: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Governor approval / correction prompt")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(DOJOTheme.observer)

                Text("Does this smoke-to-crystalline visual direction match the ParticleBoard design intent?")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DOJOTheme.textPrimary)
            }
            .padding(14)
            .background(DOJOTheme.obsidian.opacity(0.94))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(DOJOTheme.manifestation.opacity(0.45), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: 460, alignment: .leading)
        }

        private func drawAtmosphere(context: inout GraphicsContext, rect: CGRect, attractor: CGPoint, cycle: Double) {
            let baseGlow = CGRect(
                x: attractor.x - rect.width * 0.22,
                y: attractor.y - rect.height * 0.22,
                width: rect.width * 0.44,
                height: rect.height * 0.44
            )
            context.fill(
                Path(ellipseIn: baseGlow),
                with: .radialGradient(
                    Gradient(colors: [
                        DOJOTheme.manifestation.opacity(0.08 + 0.14 * pressureProgress(for: cycle)),
                        DOJOTheme.observer.opacity(0.05 + 0.08 * stillnessProgress(for: cycle)),
                        DOJOTheme.void.opacity(0.0)
                    ]),
                    center: attractor,
                    startRadius: 0,
                    endRadius: rect.width * 0.26
                )
            )

            let pressure = pressureProgress(for: cycle)
            if pressure > 0.02 {
                for ring in 1...3 {
                    let radius = rect.width * (0.09 + Double(ring) * 0.05) * (1.0 - 0.16 * pressure)
                    let ringRect = CGRect(
                        x: attractor.x - radius,
                        y: attractor.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
                    context.stroke(
                        Path(ellipseIn: ringRect),
                        with: .color(DOJOTheme.manifestation.opacity(0.015 + 0.03 * pressure / Double(ring))),
                        lineWidth: 1
                    )
                }
            }
        }

        private func drawAttractor(context: inout GraphicsContext, at point: CGPoint, cycle: Double) {
            let pulse = 7.0 + 5.0 * (0.5 + 0.5 * sin(cycle * .pi * 2))
            let ring1 = CGRect(x: point.x - pulse, y: point.y - pulse, width: pulse * 2, height: pulse * 2)
            let ring2 = CGRect(x: point.x - pulse * 2.0, y: point.y - pulse * 2.0, width: pulse * 4.0, height: pulse * 4.0)
            let core = CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6)
            context.stroke(Path(ellipseIn: ring2), with: .color(DOJOTheme.observer.opacity(0.08 + 0.06 * condensationProgress(for: cycle))), lineWidth: 1)
            context.stroke(Path(ellipseIn: ring1), with: .color(DOJOTheme.observer.opacity(0.18 + 0.10 * condensationProgress(for: cycle))), lineWidth: 1.2)
            context.fill(Path(ellipseIn: core), with: .color(DOJOTheme.consciousness.opacity(0.92)))
        }

        private func pressureProgress(for cycle: Double) -> Double {
            switch cycle {
            case 0.12..<0.30:
                return easeInOut((cycle - 0.12) / 0.18)
            case 0.30..<0.78:
                return 1
            case 0.78..<0.92:
                return 1.0 - easeInOut((cycle - 0.78) / 0.14)
            default:
                return 0
            }
        }

        private func condensationProgress(for cycle: Double) -> Double {
            switch cycle {
            case 0.0..<0.22:
                return 0
            case 0.22..<0.52:
                return easeInOut((cycle - 0.22) / 0.30)
            default:
                return 1
            }
        }

        private func stillnessProgress(for cycle: Double) -> Double {
            switch cycle {
            case 0.52..<0.72:
                return 1
            case 0.46..<0.52:
                return easeInOut((cycle - 0.46) / 0.06)
            case 0.72..<0.80:
                return 1.0 - easeInOut((cycle - 0.72) / 0.08)
            default:
                return 0
            }
        }

        private func dissolveProgress(for cycle: Double) -> Double {
            switch cycle {
            case 0.80..<1.0:
                return easeInOut((cycle - 0.80) / 0.20)
            default:
                return 0
            }
        }

        private func glyphOpacity(for cycle: Double) -> Double {
            let condense = condensationProgress(for: cycle)
            let dissolve = dissolveProgress(for: cycle)
            return max(0, condense - dissolve * 0.95)
        }

        private func smokeOpacity(for cycle: Double) -> Double {
            1.0 - 0.55 * glyphOpacity(for: cycle)
        }

        private func phaseLabel(for cycle: Double) -> String {
            switch cycle {
            case 0.0..<0.12:
                return "ambient smoke"
            case 0.12..<0.30:
                return "field pressure"
            case 0.30..<0.52:
                return "condensing form"
            case 0.52..<0.80:
                return "stabilised image"
            default:
                return "dissolving"
            }
        }

        private func pressuredSmokePoint(row: Int, col: Int, in size: CGSize, time: Double, attractor: CGPoint, pressure: Double) -> CGPoint {
            let base = smokePoint(row: row, col: col, in: size, time: time)
            let falloff = radialInfluence(point: base, center: attractor, radius: min(size.width, size.height) * 0.58)
            return CGPoint(
                x: base.x + (attractor.x - base.x) * pressure * falloff * 0.16,
                y: base.y + (attractor.y - base.y) * pressure * falloff * 0.16
            )
        }

        private func smokePoint(row: Int, col: Int, in size: CGSize, time: Double) -> CGPoint {
            let xUnit = (Double(col) + 0.5) / Double(smokeColumns)
            let yUnit = (Double(row) + 0.5) / Double(smokeRows)
            let driftX = sin(time * 0.12 + Double(row) * 0.6) * 18 + cos(time * 0.08 + Double(col) * 0.4) * 10
            let driftY = cos(time * 0.10 + Double(col) * 0.55) * 16 + sin(time * 0.07 + Double(row) * 0.45) * 8
            return CGPoint(
                x: size.width * xUnit + driftX,
                y: size.height * yUnit + driftY
            )
        }

        private func smokeNoise(at point: CGPoint, time: Double) -> Double {
            let a = sin(Double(point.x) * 0.013 + time * 0.28)
            let b = cos(Double(point.y) * 0.015 - time * 0.21)
            let c = sin((Double(point.x + point.y)) * 0.009 + time * 0.16)
            return ((a + b + c) / 3.0 + 1.0) * 0.5
        }

        private func radialInfluence(point: CGPoint, center: CGPoint, radius: CGFloat) -> Double {
            let dx = point.x - center.x
            let dy = point.y - center.y
            let distance = sqrt(dx * dx + dy * dy)
            let normalized = max(0, min(1, 1 - distance / radius))
            return Double(normalized * normalized)
        }

        private func triangleGlyphPoints(center: CGPoint, radius: CGFloat) -> [CGPoint] {
            (0..<3).map { idx in
                let angle = -Double.pi / 2 + (Double(idx) * (2 * Double.pi / 3))
                return CGPoint(
                    x: center.x + CGFloat(cos(angle)) * radius,
                    y: center.y + CGFloat(sin(angle)) * radius
                )
            }
        }

        private func glyphEdgeDirection(at point: CGPoint, glyphPoints: [CGPoint]) -> Double {
            let edges = [
                (glyphPoints[0], glyphPoints[1]),
                (glyphPoints[1], glyphPoints[2]),
                (glyphPoints[2], glyphPoints[0])
            ]
            let nearest = edges.min { lhs, rhs in
                distanceToSegment(point: point, a: lhs.0, b: lhs.1) < distanceToSegment(point: point, a: rhs.0, b: rhs.1)
            } ?? edges[0]
            return atan2(nearest.1.y - nearest.0.y, nearest.1.x - nearest.0.x)
        }

        private func orientedSmokePath(center: CGPoint, width: Double, height: Double, angle: Double, alignment: Double) -> Path {
            let alignedWidth = width * (1.0 + 0.35 * alignment)
            let alignedHeight = max(8.0, height * (1.0 - 0.45 * alignment))
            let rect = CGRect(
                x: center.x - alignedWidth / 2,
                y: center.y - alignedHeight / 2,
                width: alignedWidth,
                height: alignedHeight
            )
            var transform = CGAffineTransform.identity
            transform = transform.translatedBy(x: center.x, y: center.y)
            transform = transform.rotated(by: angle)
            transform = transform.translatedBy(x: -center.x, y: -center.y)
            return Path(ellipseIn: rect).applying(transform)
        }

        private func glyphFieldStrength(at point: CGPoint, glyphPoints: [CGPoint]) -> Double {
            let edgeDistance = min(
                distanceToSegment(point: point, a: glyphPoints[0], b: glyphPoints[1]),
                min(
                    distanceToSegment(point: point, a: glyphPoints[1], b: glyphPoints[2]),
                    distanceToSegment(point: point, a: glyphPoints[2], b: glyphPoints[0])
                )
            )
            let inside = pointInTriangle(point, glyphPoints[0], glyphPoints[1], glyphPoints[2])
            let edgeBand = max(0, 1 - edgeDistance / 48.0)
            let interior = inside ? max(0, 1 - edgeDistance / 90.0) : 0
            return max(edgeBand * 0.7, interior)
        }

        private func pointInTriangle(_ p: CGPoint, _ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Bool {
            let area = triangleArea(a, b, c)
            let area1 = triangleArea(p, b, c)
            let area2 = triangleArea(a, p, c)
            let area3 = triangleArea(a, b, p)
            return abs(area - (area1 + area2 + area3)) < 0.5
        }

        private func triangleArea(_ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> CGFloat {
            abs((p1.x * (p2.y - p3.y) + p2.x * (p3.y - p1.y) + p3.x * (p1.y - p2.y)) / 2.0)
        }

        private func distanceToSegment(point: CGPoint, a: CGPoint, b: CGPoint) -> Double {
            let dx = b.x - a.x
            let dy = b.y - a.y
            if dx == 0 && dy == 0 {
                let px = point.x - a.x
                let py = point.y - a.y
                return Double(sqrt(px * px + py * py))
            }
            let t = max(0, min(1, ((point.x - a.x) * dx + (point.y - a.y) * dy) / (dx * dx + dy * dy)))
            let projection = CGPoint(x: a.x + t * dx, y: a.y + t * dy)
            let px = point.x - projection.x
            let py = point.y - projection.y
            return Double(sqrt(px * px + py * py))
        }

        private func easeInOut(_ value: Double) -> Double {
            value * value * (3 - 2 * value)
        }
}

extension DOJOAudioCaptureView {
    private struct G6CockpitSurfaceView: View {
        private enum BoardSource: String {
            case persisted = "Restored from persisted cockpit snapshot"
            case seeded = "Loaded from CockpitSeedPlan and saved as the initial cockpit snapshot"
        }

        @StateObject private var coordinator: DOJOFieldCoordinator
        @State private var boardController: ParticleBoardController

        private let boardStore: CockpitBoardStore
        private let receiptStore: CockpitReceiptStore
        private let boardSource: BoardSource
        init() {
            let engine = CopilotEngine()
            let coordinator = DOJOFieldCoordinator(engine: engine)
            coordinator.registerMacMurmor()
            let boardStore = CockpitBoardStore()
            let receiptStore = CockpitReceiptStore()
            let controller = ParticleBoardController(
                receiptStore: receiptStore,
                boardStore: boardStore
            )

            let seedPlan = CockpitSeedPlan.plan
            let boardSource: BoardSource
            if let restoredState = boardStore.load() {
                controller.loadSeeded(seedPlan, seedState: restoredState)
                boardSource = .persisted
            } else {
                let seedState = CockpitSeedPlan.makeSeedState()
                controller.loadSeeded(seedPlan, seedState: seedState)
                boardStore.save(seedState, title: seedPlan.title)
                boardSource = .seeded
            }

            self._coordinator = StateObject(wrappedValue: coordinator)
            self._boardController = State(initialValue: controller)
            self.boardStore = boardStore
            self.receiptStore = receiptStore
            self.boardSource = boardSource
        }

        var body: some View {
            VStack(spacing: 0) {
                metadataBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(DOJOTheme.slate)
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(DOJOTheme.stone).frame(height: 1)
                    }

                ParticleBoardView(controller: boardController, coordinator: coordinator)
            }
            .background(DOJOTheme.void)
            .onAppear {
                emitSurfaceReceipt()
            }
        }

        private var metadataBar: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text("COCKPIT SURFACE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(DOJOTheme.textMuted)
                    .tracking(1.2)

                Text(boardSource.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DOJOTheme.textPrimary)

                Text("snapshot: \(boardStore.fileURL.lastPathComponent) · receipts: \(receiptStore.fileURL.lastPathComponent)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(DOJOTheme.textDim)

                wp07WitnessPanel
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        private var wp07WitnessPanel: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text("WP-07 WITNESS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Chamber.tata.color)
                    .tracking(1.2)

                Text("Governor only needs to confirm whether the displayed actual value matches the expected value.")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DOJOTheme.textSecondary)

                witnessRow(label: "target", value: "[2,2]")
                witnessRow(label: "expected", value: wp07Witness?.expectedValue ?? "UNKNOWN")
                witnessRow(label: "actual", value: actualWP07Value)
                witnessRow(label: "pre-hash", value: wp07Witness?.preRestartHash ?? "UNKNOWN")
                witnessRow(label: "post-hash", value: currentStateHash)
                witnessRow(label: "result", value: wp07VisibleResult)
            }
            .padding(.top, 8)
        }

        private var wp07Witness: WP07WitnessState? {
            boardStore.loadWP07Witness()
        }

        private var actualWP07Value: String {
            guard let cell = boardController.committed?.cell(at: GridAddress(row: 2, col: 2)!) else {
                return "UNKNOWN"
            }
            switch cell.payload {
            case .route(_, let action):
                return action
            case .empty:
                return "EMPTY"
            case .unknown(let raw):
                return raw
            }
        }

        private var currentStateHash: String {
            stateHash(for: boardController.committed)
        }

        private var wp07VisibleResult: String {
            guard let witness = wp07Witness else { return "UNKNOWN" }
            guard !currentStateHash.isEmpty else { return "HOLD" }
            if actualWP07Value == witness.expectedValue && currentStateHash == witness.preRestartHash {
                return "PASS"
            }
            if actualWP07Value != witness.expectedValue {
                return "MISMATCH"
            }
            return "HOLD"
        }

        private func witnessRow(label: String, value: String) -> some View {
            HStack(alignment: .top, spacing: 8) {
                Text(label)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(DOJOTheme.textMuted)
                    .frame(width: 64, alignment: .leading)
                Text(value)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(DOJOTheme.textPrimary)
                    .textSelection(.enabled)
                Spacer(minLength: 0)
            }
        }

        private func emitSurfaceReceipt() {
            receiptStore.emit(
                CockpitReceipt(
                    timestamp: ISO8601DateFormatter().string(from: Date()),
                    event: "g6.cockpit.surface.visible",
                    actor: "g6-wp-06",
                    boardTitle: CockpitSeedPlan.plan.title,
                    stateHash: stateHash(for: boardController.committed),
                    draftPresent: boardController.committedDraft != nil,
                    policyResult: "ok",
                    addressesChanged: [],
                    holdReasons: nil
                )
            )
        }

        private func stateHash(for state: ParticleBoardState?) -> String {
            guard let state else { return "" }
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let data = (try? encoder.encode(state)) ?? Data()
            return CockpitReceiptStore.sha256(
                from: String(data: data, encoding: .utf8) ?? "",
                boardSource.rawValue
            )
        }
    }
    
    private var captureTab: some View {
        ZStack {
            // Background void
            DOJOTheme.void
            
            // Subtle geometric pattern overlay
            GeometricPattern()
                .opacity(0.03)
            
            VStack(spacing: 32) {
                Spacer()
                
                // Sacred geometry record button
                Button {
                    controller.toggle()
                } label: {
                    ZStack {
                        // Outer glow ring
                        Circle()
                            .stroke(
                                controller.isCapturing ? 
                                    DOJOTheme.danger.opacity(0.3) :
                                    DOJOTheme.manifestation.opacity(0.3),
                                lineWidth: 2
                            )
                            .frame(width: 140, height: 140)
                            .blur(radius: 8)
                        
                        // Main circle
                        Circle()
                            .fill(
                                controller.isCapturing ? 
                                    AnyShapeStyle(DOJOTheme.danger) :
                                    AnyShapeStyle(DOJOTheme.pyramidGradient)
                            )
                            .frame(width: 120, height: 120)
                            .shadow(
                                color: controller.isCapturing ? 
                                    DOJOTheme.danger.opacity(0.6) :
                                    DOJOTheme.manifestation.opacity(0.6),
                                radius: 20
                            )
                        
                        // Inner symbol
                        if controller.isCapturing {
                            // Geometric stop (square within circle - sacred proportion)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(DOJOTheme.textPrimary)
                                .frame(width: 40, height: 40)
                        } else {
                            // Pyramid capture symbol
                            ZStack {
                                Circle()
                                    .fill(DOJOTheme.textPrimary)
                                    .frame(width: 50, height: 50)
                                
                                // Frequency indicator
                                Text("◼︎")
                                    .font(.system(size: 20, weight: .ultraLight))
                                    .foregroundStyle(DOJOTheme.manifestation)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(controller.deviceManager.selectedDevice == nil)
                
                // Status text with frequency
                VStack(spacing: 12) {
                    Text(controller.isCapturing ? "◼︎ RECORDING" : "◼︎ READY")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundStyle(DOJOTheme.textPrimary)
                        .tracking(2)
                    
                    if let device = controller.deviceManager.selectedDevice {
                        HStack(spacing: 6) {
                            Text(device.type.icon)
                            Text(device.name)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(DOJOTheme.textTertiary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(DOJOTheme.obsidian)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(DOJOTheme.manifestation.opacity(0.2), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    } else {
                        Text("SELECT DEVICE ▲")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(DOJOTheme.textMuted)
                            .tracking(1)
                    }
                    
                    // Frequency indicator
                    if controller.isCapturing {
                        Text("741 Hz ◆ 963 Hz")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(DOJOTheme.observer)
                            .tracking(1.5)
                    }
                }
                
                // Real-time stats (pyramid layout)
                if controller.isCapturing {
                    HStack(spacing: 20) {
                        DOJOQuickStat(
                            icon: "waveform",
                            label: "LEVEL",
                            value: "\(Int(controller.currentRMSdB)) dB",
                            color: levelStatColor
                        )
                        
                        if let quality = controller.lastQuality {
                            DOJOQuickStat(
                                icon: "antenna.radiowaves.left.and.right",
                                label: "SNR",
                                value: quality.snrQuality.uppercased(),
                                color: DOJOTheme.manifestation
                            )
                            
                            DOJOQuickStat(
                                icon: "waveform.path.ecg",
                                label: "SPEECH",
                                value: "\(Int(quality.vadSpeechRatio * 100))%",
                                color: quality.vadSpeechRatio > 0.3 ? DOJOTheme.optimal : DOJOTheme.textMuted
                            )
                        }
                    }
                    .padding(.top, 24)
                }
                
                Spacer()
                
                // Instructions panel (geometric)
                if !controller.isCapturing {
                    geometricInstructions
                }
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var levelStatColor: Color {
        let db = controller.currentRMSdB
        if db > -6 { return DOJOTheme.danger }
        if db > -12 { return DOJOTheme.caution }
        if db > -24 { return DOJOTheme.optimal }
        return DOJOTheme.quiet
    }
    
    private var geometricInstructions: some View {
        VStack(alignment: .leading, spacing: 14) {
            DOJOInstructionRow(
                number: "1",
                text: "Select X6 Bluetooth headphones from device menu"
            )
            DOJOInstructionRow(
                number: "2",
                text: "Initiate capture via geometric record symbol"
            )
            DOJOInstructionRow(
                number: "3",
                text: "Monitor 741 Hz + 963 Hz frequency synthesis"
            )
            DOJOInstructionRow(
                number: "4",
                text: "Verify G6 gate receipt in geometric ledger"
            )
        }
        .padding(24)
        .background(
            ZStack {
                DOJOTheme.obsidian
                DOJOTheme.manifestation.opacity(0.03)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [DOJOTheme.manifestation.opacity(0.3), DOJOTheme.observer.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 32)
        .padding(.bottom, 16)
    }
}

// MARK: - Audio Monitor View

struct AudioMonitorView: View {
    @ObservedObject var controller: MacOSMurmurController
    @State private var blink = true
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "waveform")
                    .font(.title3)
                    .foregroundStyle(.purple)
                Text("Audio Monitor")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                Spacer()
                
                if controller.isCapturing {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                            .opacity(blink ? 1.0 : 0.3)
                        Text("LIVE")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(.red)
                    }
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
                            blink.toggle()
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            Divider().background(Color(hex: "#2D2D30"))
            
            levelMeter
            
            if let quality = controller.lastQuality {
                Divider().background(Color(hex: "#2D2D30"))
                qualityMetrics(quality)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#0A0A0C"))
    }
    
    private var levelMeter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("INPUT LEVEL")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(Color(hex: "#6B7280"))
            
            HStack(spacing: 12) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("0").font(.system(size: 9, design: .monospaced))
                    Spacer()
                    Text("-12").font(.system(size: 9, design: .monospaced))
                    Spacer()
                    Text("-24").font(.system(size: 9, design: .monospaced))
                    Spacer()
                    Text("-48").font(.system(size: 9, design: .monospaced))
                    Spacer()
                    Text("-96").font(.system(size: 9, design: .monospaced))
                }
                .foregroundStyle(Color(hex: "#6B7280"))
                .frame(height: 100)
                
                GeometryReader { geo in
                    ZStack(alignment: .bottom) {
                        LinearGradient(
                            colors: [
                                Color(hex: "#EF4444"),
                                Color(hex: "#F59E0B"),
                                Color(hex: "#10B981"),
                                Color(hex: "#3B82F6")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .opacity(0.2)
                        
                        LinearGradient(
                            colors: levelColors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: levelHeight(in: geo.size.height))
                        .animation(.easeOut(duration: 0.05), value: controller.currentRMSdB)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(hex: "#2D2D30"), lineWidth: 1)
                    )
                }
                .frame(width: 40, height: 100)
                
                VStack {
                    Text("\(Int(controller.currentRMSdB))")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundStyle(levelTextColor)
                    Text("dBFS")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color(hex: "#6B7280"))
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func qualityMetrics(_ quality: QualityMetrics) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("QUALITY METRICS")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color(hex: "#6B7280"))
                Spacer()
                Text("Last update: \(timeAgo(quality.timestamp))")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(Color(hex: "#4B5563"))
            }
            
            MetricRow(
                label: "SNR",
                value: "\(Int(quality.snrEst)) dB",
                badge: quality.snrQuality,
                badgeColor: quality.snrColor
            )
            
            MetricRow(
                label: "Speech",
                value: "\(Int(quality.vadSpeechRatio * 100))%",
                badge: quality.vadSpeechRatio > 0.3 ? "Active" : "Silent",
                badgeColor: quality.vadSpeechRatio > 0.3 ? "#10B981" : "#6B7280"
            )
            
            MetricRow(
                label: "Noise Floor",
                value: "\(Int(quality.noiseFloorDb)) dB",
                badge: nil,
                badgeColor: nil
            )
            
            if quality.clipRate > 0.01 {
                MetricRow(
                    label: "Clipping",
                    value: "\(Int(quality.clipRate * 100))%",
                    badge: "WARNING",
                    badgeColor: "#EF4444"
                )
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func levelHeight(in maxHeight: CGFloat) -> CGFloat {
        let db = controller.currentRMSdB
        let normalized = (db + 96) / 96
        return max(2, maxHeight * CGFloat(normalized))
    }
    
    private var levelColors: [Color] {
        let db = controller.currentRMSdB
        if db >= -6 {
            return [Color(hex: "#EF4444"), Color(hex: "#F59E0B")]
        }
        if db >= -12 {
            return [Color(hex: "#F59E0B"), Color(hex: "#10B981")]
        }
        return [Color(hex: "#10B981"), Color(hex: "#3B82F6")]
    }
    
    private var levelTextColor: Color {
        let db = controller.currentRMSdB
        return db > -6 ? Color(hex: "#EF4444") : .white
    }
    
    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "\(seconds)s ago" }
        let minutes = seconds / 60
        return "\(minutes)m ago"
    }
}

// MARK: - Gate Receipt View

struct GateReceiptView: View {
    @State private var receipts: [GeometryGateReceipt] = []
    @State private var selectedReceipt: GeometryGateReceipt?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title3)
                    .foregroundStyle(.purple)
                Text("G6 Hardware Gate")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(receipts.isEmpty ? Color(hex: "#6B7280") : Color(hex: "#10B981"))
                        .frame(width: 6, height: 6)
                    Text(receipts.isEmpty ? "No Sessions" : "\(receipts.count) Sessions")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color(hex: "#9CA3AF"))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: "#111113"))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                Button {
                    refreshReceipts()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider().background(Color(hex: "#2D2D30"))
            
            if receipts.isEmpty {
                emptyState
            } else {
                receiptList
            }
        }
        .background(Color(hex: "#0A0A0C"))
        .onAppear { refreshReceipts() }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "mic.slash")
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: "#4B5563"))
            Text("No Capture Sessions Yet")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(hex: "#9CA3AF"))
            Text("Start a capture session to log your first G6 gate receipt")
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: "#6B7280"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var receiptList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(receipts, id: \.sessionRef) { receipt in
                    ReceiptCard(
                        receipt: receipt,
                        isSelected: selectedReceipt?.sessionRef == receipt.sessionRef
                    )
                    .onTapGesture {
                        selectedReceipt = receipt
                    }
                }
            }
            .padding(12)
        }
    }
    
    private func refreshReceipts() {
        receipts = GeometryGateReceipt.fetchAll().reversed()
    }
}

struct PortalIntegrityLoopReviewView: View {
    @StateObject private var proof = PortalIntegrityLoopProofModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                packetSummary
                lifecycleLadder
                statePanel
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(DOJOTheme.void)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Portal Integrity Loop")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(DOJOTheme.textPrimary)
            Text("Review prototype: local evidence preservation before AKRON receipt.")
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(DOJOTheme.textMuted)
        }
    }

    private var packetSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Proof packet")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(DOJOTheme.textPrimary)
                Spacer()
                Text(proof.currentState.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(proof.stateColor)
            }

            detailRow("ID", PortalIntegrityLoopProofModel.packetID)
            detailRow("Short seal", PortalIntegrityLoopProofModel.shortSeal)
            detailRow("Full seal", PortalIntegrityLoopProofModel.fullSeal)
        }
        .padding(16)
        .background(DOJOTheme.obsidian)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(DOJOTheme.stone, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var lifecycleLadder: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lifecycle")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(DOJOTheme.textSecondary)

            HStack(spacing: 8) {
                ForEach(PortalIntegrityLoopProofModel.lifecycle, id: \.self) { step in
                    lifecycleStep(step)
                    if step != PortalIntegrityLoopProofModel.lifecycle.last {
                        Rectangle()
                            .fill(DOJOTheme.stone)
                            .frame(width: 16, height: 1)
                    }
                }
            }
        }
        .padding(16)
        .background(DOJOTheme.obsidian)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(DOJOTheme.stone, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var statePanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(proof.syncMessage)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(DOJOTheme.textSecondary)

            if let receiptID = proof.receiptID {
                detailRow("AKRON receipt", receiptID)
            }

            Button {
                Task { await proof.attemptAkronSync() }
            } label: {
                HStack(spacing: 8) {
                    if proof.isSyncing {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    Text(proof.isSyncing ? "Attempting AKRON Sync" : "Attempt AKRON Sync")
                }
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
            }
            .buttonStyle(.borderedProminent)
            .disabled(proof.isSyncing)
            .tint(DOJOTheme.manifestation)
        }
        .padding(16)
        .background(DOJOTheme.obsidian)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(proof.stateColor.opacity(0.8), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(DOJOTheme.textDim)
            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(DOJOTheme.textSecondary)
                .textSelection(.enabled)
        }
    }

    private func lifecycleStep(_ step: String) -> some View {
        let isCurrent = step == proof.currentState
        return VStack(spacing: 6) {
            Circle()
                .fill(isCurrent ? proof.stateColor : DOJOTheme.stone)
                .frame(width: 12, height: 12)
            Text(step)
                .font(.system(size: 9, weight: isCurrent ? .bold : .medium, design: .monospaced))
                .foregroundStyle(isCurrent ? DOJOTheme.textPrimary : DOJOTheme.textMuted)
                .multilineTextAlignment(.center)
                .frame(width: 72, height: 28)
        }
    }
}

// MARK: - DOJO Supporting Views

// Geometric pattern overlay
struct GeometricPattern: View {
    var body: some View {
        Canvas { context, size in
            let columns = 20
            let rows = 20
            let cellWidth = size.width / CGFloat(columns)
            let cellHeight = size.height / CGFloat(rows)
            
            for row in 0..<rows {
                for col in 0..<columns {
                    let x = CGFloat(col) * cellWidth
                    let y = CGFloat(row) * cellHeight
                    
                    if (row + col) % 2 == 0 {
                        let rect = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
                        context.fill(Path(rect), with: .color(.white))
                    }
                }
            }
        }
    }
}

struct DOJOTabButton: View {
    let title: String
    let icon: String
    let frequency: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isSelected ? AnyShapeStyle(DOJOTheme.pyramidGradient) : AnyShapeStyle(DOJOTheme.textMuted))
                
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(isSelected ? DOJOTheme.textPrimary : DOJOTheme.textMuted)
                    .tracking(0.5)
                
                Text(frequency)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(isSelected ? DOJOTheme.observer : DOJOTheme.textDim)
                    .opacity(0.6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                ZStack {
                    if isSelected {
                        DOJOTheme.slate
                        DOJOTheme.pyramidGradient.opacity(0.1)
                    } else {
                        Color.clear
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? DOJOTheme.manifestation.opacity(0.4) : Color.clear,
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct DOJOQuickStat: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(color)
                .shadow(color: color.opacity(0.3), radius: 4)
            
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(DOJOTheme.textMuted)
                .tracking(1)
            
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(DOJOTheme.textPrimary)
        }
        .frame(width: 100)
        .padding(.vertical, 14)
        .background(
            ZStack {
                DOJOTheme.obsidian
                color.opacity(0.05)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct DOJOInstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(DOJOTheme.pyramidGradient)
                    .frame(width: 28, height: 28)
                    .shadow(color: DOJOTheme.manifestation.opacity(0.3), radius: 4)
                
                Text(number)
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundStyle(DOJOTheme.textPrimary)
            }
            
            Text(text)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(DOJOTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    let badge: String?
    let badgeColor: String?
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Color(hex: "#9CA3AF"))
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white)
            
            if let badge = badge, let color = badgeColor {
                Text(badge)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: color))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
        .background(Color(hex: "#111113"))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct ReceiptCard: View {
    let receipt: GeometryGateReceipt
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color(hex: "#10B981"))
                
                Text(receipt.capability.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(hex: "#10B981"))
                
                Spacer()
                
                Text(formatTimestamp(receipt.timestamp))
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(Color(hex: "#6B7280"))
            }
            
            HStack(spacing: 6) {
                Image(systemName: "waveform")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: "#9CA3AF"))
                Text(receipt.deviceName)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color(hex: "#D1D5DB"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("SESSION REF")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color(hex: "#6B7280"))
                
                HStack {
                    Text(receipt.sha256Hint)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color(hex: "#A78BFA"))
                    
                    Text("•••")
                        .font(.system(size: 10))
                        .foregroundStyle(Color(hex: "#4B5563"))
                    
                    Spacer()
                    
                    Button {
                        copyToClipboard(receipt.sessionRef)
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(hex: "#9CA3AF"))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(hex: "#111113"))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            HStack {
                Image(systemName: "lock.shield")
                    .font(.system(size: 9))
                Text("Ready for AKRON v1 signature")
                    .font(.system(size: 9, design: .monospaced))
                Spacer()
            }
            .foregroundStyle(Color(hex: "#6B7280"))
        }
        .padding(12)
        .background(isSelected ? Color(hex: "#1E1E20") : Color(hex: "#111113"))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color(hex: "#7C3AED") : Color(hex: "#2D2D30"), lineWidth: isSelected ? 2 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#endif
