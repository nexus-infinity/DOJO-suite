import Foundation
import SwiftUI

// MARK: - System Inspector (Under-the-Hood)
// Contract: docs/DOJO_TODAY_UNDER_THE_HOOD_INSPECTOR_CONTRACT_V0.md
// App-scoped · human-readable · mostly read-only · not the workspace
// Diagnostics tab = raw machinery placeholder (Developer/Advanced)

@available(macOS 14.0, *)
struct SystemInspectorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var section: InspectorSection = .pipeline
    private let mcpReadiness = MCPReadinessSnapshot.empty

    /// Optional selection context (does not make Inspector object-scoped overall)
    var selectedObjectTitle: String?
    var selectedProviderName: String
    var hasProviderKey: Bool
    var receiptsOn: Bool
    var memoryEnabled: Bool
    var isRequesting: Bool

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(Color(hex: "#1C4B56").opacity(0.5))
            HStack(alignment: .top, spacing: 0) {
                sectionList
                Divider().overlay(Color(hex: "#1C4B56").opacity(0.4))
                ScrollView {
                    sectionBody
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .background(Color(hex: "#061014"))
            }
        }
        .frame(width: 820, height: 560)
        .background(Color(hex: "#041618"))
        .foregroundStyle(Color(hex: "#D8EDF2"))
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("System Inspector")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#EAFBFF"))
                Text("How the system is composed and behaving — not the workspace.")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#89A8B1"))
            }
            Spacer()
            Text("Lift the hood")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#C4B5FD"))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: "#C4B5FD").opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .frame(width: 28, height: 28)
                    .foregroundStyle(Color(hex: "#EAFBFF"))
                    .background(Color(hex: "#10252B"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(hex: "#041618"))
    }

    private var sectionList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(InspectorSection.allCases) { item in
                    Button {
                        section = item
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: item.symbol)
                                .frame(width: 16)
                            Text(item.title)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .lineLimit(1)
                            Spacer(minLength: 0)
                        }
                        .foregroundStyle(section == item ? Color(hex: "#031416") : Color(hex: "#D9F8FF"))
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
        .background(Color(hex: "#03191D"))
    }

    @ViewBuilder
    private var sectionBody: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(section.title)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#EAFBFF"))
            Text(section.blurb)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#89A8B1"))
                .fixedSize(horizontal: false, vertical: true)

            switch section {
            case .pipeline:
                pipelineBody
            case .mcp:
                mcpBody
            case .models:
                modelsBody
            case .tools:
                card("Tool inventory") {
                    infoRow("Hosted model chat", "provider route", valueColor: Color(hex: "#6CEBFF"))
                    infoRow("External MCP tools", "\(mcpReadiness.composerExposedServers) composer exposed", valueColor: Color(hex: "#FBBF24"))
                    infoRow("Required gate", "read-only smoke receipt")
                    Text("Hosted model chat is not an MCP tool inventory. External tools stay hidden from the composer until they have a real read-only smoke receipt.")
                        .foregroundStyle(Color(hex: "#89A8B1"))
                }
            case .memory:
                card("Memory") {
                    Text(memoryEnabled ? "Enabled" : "Not enabled yet")
                        .foregroundStyle(memoryEnabled ? Color(hex: "#86EFAC") : Color(hex: "#FBBF24"))
                    Text("FIELD memory is out of ordinary workspace scope.")
                        .foregroundStyle(Color(hex: "#6B8A93"))
                }
            case .attributes:
                card("Attributes") {
                    infoRow("Selection", selectedObjectTitle ?? "none")
                    infoRow("Object kind", selectedObjectTitle == nil ? "none" : "generated object")
                    infoRow("Schema view", "summary only", valueColor: Color(hex: "#FBBF24"))
                    Text("Detailed attribute mapping remains out of the ordinary workspace. This panel only reports selection context.")
                        .foregroundStyle(Color(hex: "#89A8B1"))
                }
            case .receipts:
                card("Receipts") {
                    infoRow("Receipts policy", receiptsOn ? "on" : "off", valueColor: receiptsOn ? Color(hex: "#86EFAC") : Color(hex: "#FBBF24"))
                    infoRow("Generated object store", GeneratedObjectStore.storeURL.path)
                    infoRow("MCP smoke receipts", mcpReadiness.smokeReceiptDirectoryPath)
                    Text("Object-scoped Proof lives in the Proof drawer, not here.")
                        .foregroundStyle(Color(hex: "#89A8B1"))
                }
            case .jobs:
                card("Jobs") {
                    infoRow("Hosted model", isRequesting ? "request in flight" : "idle", valueColor: isRequesting ? Color(hex: "#6CEBFF") : Color(hex: "#86EFAC"))
                    infoRow("MCP smoke", "no queued job")
                    infoRow("Memory indexing", "not enabled", valueColor: Color(hex: "#FBBF24"))
                    Text("No background queue is being hidden from the workspace.")
                        .foregroundStyle(Color(hex: "#89A8B1"))
                }
            case .panels:
                card("Panels") {
                    infoRow("Workspace shell", "Places · Centre work · Utility dock · Composer")
                    infoRow("Right utilities", "Details · Review · Files")
                    infoRow("Removed from dock", "Browser · Terminal · Side chat", valueColor: Color(hex: "#FBBF24"))
                    Text("Non-live utilities are not shown as ordinary tabs.")
                        .foregroundStyle(Color(hex: "#89A8B1"))
                }
            case .holds:
                card("Holds (user-facing)") {
                    holdLine("Landscape / place", "HOLD · named space; not MapKit; not CarPlay nav")
                    holdLine("CarPlay channel", "HOLD · driving-safe contract; sibling of place")
                    holdLine("Mac OS integration", "PARTIAL · native Today window; connector depth thin")
                    holdLine("External MCP composer exposure", "Pending smoke readiness contract")
                    holdLine("Live Notion MCP", "HOLD · Today consumes a verified local snapshot only")
                    holdLine("Role-colour retinting", "HOLD · no retint in this pass")
                    holdLine("SOMA embodiment", "HOLD · prime-fractal remains not embodied")
                    holdLine("Trek restoration", "HOLD · walk-on source remains omitted")
                    holdLine("Memory", "Not enabled")
                    Text("FIELD HOLD.* labels live under Diagnostics when needed.")
                        .foregroundStyle(Color(hex: "#6B8A93"))
                        .padding(.top, 4)
                }
            case .diagnostics:
                diagnosticsBody
            }
        }
    }

    private var pipelineBody: some View {
        card("Current action pipeline") {
            pipelineStep("Composer input", true)
            pipelineStep("Provider / model route", true)
            pipelineStep("Tool eligibility (MCP gate)", false)
            pipelineStep("Permission check", true)
            pipelineStep("Generated object", true)
            pipelineStep("Save / export", true)
            pipelineStep("Receipt / Proof", true)
            Divider().overlay(Color(hex: "#1C4B56").opacity(0.4))
            Text("Current stage: \(isRequesting ? "Model request in flight" : "Waiting for user input")")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#6CEBFF"))
            if let selectedObjectTitle {
                Text("Centre selection: \(selectedObjectTitle)")
                    .foregroundStyle(Color(hex: "#89A8B1"))
            }
        }
    }

    private var mcpBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            card("External MCP registry") {
                infoRow("Schema", mcpReadiness.schema)
                infoRow("Registered servers", "\(mcpReadiness.registeredServers)")
                infoRow("Enabled servers", "\(mcpReadiness.enabledServers)")
                infoRow("Composer exposed", "\(mcpReadiness.composerExposedServers)", valueColor: Color(hex: "#FBBF24"))
                Text("No external MCP is exposed to the composer until a real read-only smoke receipt reaches Responding or Limited with read-only tools.")
                    .foregroundStyle(Color(hex: "#89A8B1"))
                HStack(spacing: 8) {
                    disabledInspectorButton("Add server")
                    disabledInspectorButton("Run smoke test")
                }
                .padding(.top, 2)
            }
            card("Connection stage ladder") {
                ForEach(MCPConnectionStage.allCases) { stage in
                    stageLegendRow(stage)
                }
            }
            card("Read-only smoke receipts") {
                infoRow("Receipt count", "\(mcpReadiness.smokeReceipts)")
                infoRow("Write policy", mcpReadiness.writePolicy)
                infoRow("Faked success", mcpReadiness.fakedSuccess ? "true" : "false", valueColor: Color(hex: "#86EFAC"))
                infoRow("Receipt path", mcpReadiness.smokeReceiptDirectoryPath)
            }
            card("FIELD chamber MCP (reference)") {
                Text("Chamber Free Radical servers are FIELD infrastructure, not this Inspector’s external attach list.")
                    .foregroundStyle(Color(hex: "#89A8B1"))
                Text("Layer 2 (reachable) / Layer 3 (responding) language applies when external servers are registered.")
                    .foregroundStyle(Color(hex: "#6B8A93"))
            }
        }
    }

    private var modelsBody: some View {
        card("Models & providers") {
            Text("Active UI provider: \(selectedProviderName)")
            Text(hasProviderKey ? "Key: saved in Keychain" : "Key: not saved")
                .foregroundStyle(hasProviderKey ? Color(hex: "#86EFAC") : Color(hex: "#FBBF24"))
            Text("Local models: not enabled")
                .foregroundStyle(Color(hex: "#6B8A93"))
            Text("Routing summary only — configure keys in Settings.")
                .foregroundStyle(Color(hex: "#6B8A93"))
        }
    }

    private var diagnosticsBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            card("Diagnostics (Developer)") {
                Text("Machine-level evidence. Not the ordinary workspace.")
                    .foregroundStyle(Color(hex: "#FBBF24"))
                Text("This tab is the progressive-disclosure end of the chain. Raw payloads stay off by default.")
                    .foregroundStyle(Color(hex: "#89A8B1"))
            }
            card("Placeholders (not live dumps)") {
                diagToggle("Show raw MCP tool schemas", enabled: false)
                diagToggle("Show request traces", enabled: false)
                diagToggle("Show local process paths", enabled: false)
                diagToggle("Show build diagnostics", enabled: false)
                diagToggle("Show FIELD internal labels", enabled: false)
            }
            card("Paths") {
                Text("Object store: \(GeneratedObjectStore.storeURL.path)")
                    .font(.system(size: 11, design: .monospaced))
                Text("MCP smoke receipts: \(mcpReadiness.smokeReceiptDirectoryPath)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color(hex: "#6B8A93"))
            }
        }
    }

    private func pipelineStep(_ title: String, _ available: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: available ? "checkmark.circle.fill" : "circle.dashed")
                .foregroundStyle(available ? Color(hex: "#86EFAC") : Color(hex: "#6B8A93"))
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
            Spacer()
            Text(available ? "seated" : "gated")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#6B8A93"))
        }
    }

    private func holdLine(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
            Text(detail)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#89A8B1"))
        }
        .padding(.vertical, 4)
    }

    private func diagToggle(_ title: String, enabled: Bool) -> some View {
        HStack {
            Image(systemName: enabled ? "checkmark.square" : "square")
                .foregroundStyle(Color(hex: "#6B8A93"))
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#A9BBC2"))
            Spacer()
            Text("off")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "#6B8A93"))
        }
    }

    private func infoRow(_ title: String, _ value: String, valueColor: Color = Color(hex: "#A9BBC2")) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#6B8A93"))
                .frame(width: 132, alignment: .leading)
            Text(value)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(valueColor)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    private func disabledInspectorButton(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(Color(hex: "#6B8A93"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: "#12242A").opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color(hex: "#29424A").opacity(0.8), lineWidth: 1)
            )
    }

    private func stageLegendRow(_ stage: MCPConnectionStage) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Text(stage.symbol)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(stage.color)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 2) {
                Text(stage.title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#D8EDF2"))
                Text(stage.evidence)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#89A8B1"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
    }

    private func card<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#C9E4EA"))
            content()
                .font(.system(size: 12, weight: .medium, design: .rounded))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#0A1B21"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct MCPReadinessSnapshot {
    let schema: String
    let registeredServers: Int
    let enabledServers: Int
    let composerExposedServers: Int
    let smokeReceipts: Int
    let writePolicy: String
    let fakedSuccess: Bool
    let smokeReceiptDirectoryPath: String

    static var empty: MCPReadinessSnapshot {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let smokeDirectory = appSupport
            .appendingPathComponent("org.field.dojo", isDirectory: true)
            .appendingPathComponent("mcp_smoke_receipts", isDirectory: true)

        return MCPReadinessSnapshot(
            schema: "DOJO.Today.MCPConnectionRegistry.V0",
            registeredServers: 0,
            enabledServers: 0,
            composerExposedServers: 0,
            smokeReceipts: 0,
            writePolicy: "read_only",
            fakedSuccess: false,
            smokeReceiptDirectoryPath: smokeDirectory.path
        )
    }
}

private enum MCPConnectionStage: String, CaseIterable, Identifiable {
    case notConnected
    case needsLogin
    case connected
    case reachable
    case responding
    case limited
    case failed
    case disabled

    var id: String { rawValue }

    var title: String {
        switch self {
        case .notConnected: return "Not connected"
        case .needsLogin: return "Needs login"
        case .connected: return "Connected"
        case .reachable: return "Reachable"
        case .responding: return "Responding"
        case .limited: return "Limited"
        case .failed: return "Failed"
        case .disabled: return "Disabled"
        }
    }

    var symbol: String {
        switch self {
        case .notConnected: return "○"
        case .needsLogin: return "◇"
        case .connected: return "●"
        case .reachable: return "◌"
        case .responding: return "◎"
        case .limited: return "◐"
        case .failed: return "!"
        case .disabled: return "×"
        }
    }

    var color: Color {
        switch self {
        case .responding, .limited: return Color(hex: "#86EFAC")
        case .failed, .needsLogin: return Color(hex: "#FBBF24")
        default: return Color(hex: "#6B8A93")
        }
    }

    var evidence: String {
        switch self {
        case .notConnected: return "No live session; config presence is not connection evidence."
        case .needsLogin: return "Authentication is required or expired."
        case .connected: return "Transport session exists, but tool response is not proven."
        case .reachable: return "Transport responds at health, ping, or process layer."
        case .responding: return "A parseable tool inventory returned from tools/list or equivalent."
        case .limited: return "Inventory exists, but quota, permissions, or partial tools restrict use."
        case .failed: return "A real attempt produced an error receipt."
        case .disabled: return "Operator or policy is off; no automatic reconnect."
        }
    }
}

private enum InspectorSection: String, CaseIterable, Identifiable {
    case pipeline, mcp, models, tools, memory, attributes, receipts, jobs, panels, holds, diagnostics

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pipeline: return "Pipeline"
        case .mcp: return "MCP Connections"
        case .models: return "Models & Providers"
        case .tools: return "Tools"
        case .memory: return "Memory"
        case .attributes: return "Attributes"
        case .receipts: return "Receipts"
        case .jobs: return "Jobs"
        case .panels: return "Panels"
        case .holds: return "Holds"
        case .diagnostics: return "Diagnostics"
        }
    }

    var symbol: String {
        switch self {
        case .pipeline: return "arrow.triangle.branch"
        case .mcp: return "server.rack"
        case .models: return "cpu"
        case .tools: return "wrench"
        case .memory: return "brain"
        case .attributes: return "list.bullet.rectangle"
        case .receipts: return "checkmark.seal"
        case .jobs: return "clock"
        case .panels: return "rectangle.split.3x1"
        case .holds: return "hand.raised"
        case .diagnostics: return "ladybug"
        }
    }

    var blurb: String {
        switch self {
        case .pipeline: return "Summarized action path from composer to object and receipt."
        case .mcp: return "External connection stages and policy — not a tool schema dump."
        case .models: return "Provider routing state. Configure keys in Settings."
        case .tools: return "Eligibility and exposure rules for tools."
        case .memory: return "Memory subsystem status."
        case .attributes: return "Attribute / schema overview for selection context."
        case .receipts: return "Where evidence lives; object Proof stays in the Proof drawer."
        case .jobs: return "Background work and queues."
        case .panels: return "Workspace panel composition."
        case .holds: return "Plain-language unresolved conditions."
        case .diagnostics: return "Raw machinery. Explicit Developer depth only."
        }
    }
}

#Preview("System Inspector") {
    if #available(macOS 14.0, *) {
        SystemInspectorView(
            selectedObjectTitle: "Sample answer",
            selectedProviderName: "OpenAI",
            hasProviderKey: false,
            receiptsOn: true,
            memoryEnabled: false,
            isRequesting: false
        )
    }
}
