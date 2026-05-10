import SwiftUI
import DOJOShared
import DOJOUI

enum ChamberStatus { case alive, degraded, offline, unknown }

@MainActor
class ChamberHealthMonitor: ObservableObject {
    @Published var status: [Chamber: ChamberStatus] = [:]
    @Published var bearScore: Double = 0

    private let spinningTop = SpinningTopClient()
    private var monitoringTask: Task<Void, Never>?

    init() {
        startMonitoring()
    }

    func startMonitoring() {
        guard monitoringTask == nil else { return }
        monitoringTask = Task { [weak self] in
            await self?.poll()
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(15))
                await self?.poll()
            }
        }
    }

    func stopMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil
    }

    private func poll() async {
        do {
            let state = try await spinningTop.getState()
            bearScore = state.coherence

            for chamber in Chamber.allCases {
                // Match by symbol first (canonical), fall back to name
                let node = state.nodes.first { $0.symbol == chamber.rawValue }
                    ?? state.nodes.first { $0.name.lowercased() == chamber.name.lowercased() }
                if let node {
                    status[chamber] = chamberStatus(from: node)
                }
            }

            // If DOJO has no node entry but server is operational, mark it alive
            if status[.dojo] == nil && state.operational {
                status[.dojo] = .alive
            }
        } catch {
            status[.dojo] = .offline
        }
    }

    private func chamberStatus(from node: SpinningTopClient.StateResponse.Node) -> ChamberStatus {
        guard node.state else { return .offline }
        switch node.health {
        case "alive", "healthy": return .alive
        case "degraded":         return .degraded
        case "unhealthy":        return .offline
        default:                 return .unknown
        }
    }
}
