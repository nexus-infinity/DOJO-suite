import SwiftUI
import DOJOShared
import DOJOUI

enum ChamberStatus { case alive, degraded, offline, unknown }

@MainActor
class ChamberHealthMonitor: ObservableObject {
    @Published var status: [Chamber: ChamberStatus] = [:]
    @Published var bearScore: Double = 0

    private var timer: Timer?

    init() {
        Task { await poll() }
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            Task { await self?.poll() }
        }
    }

    private func poll() async {
        guard let url = URL(string: "http://localhost:7410/health") else { return }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            await markDOJODirect()
            return
        }
        if let chambers = json["chambers"] as? [String: [String: Any]] {
            for chamber in Chamber.allCases {
                let key = chamber.name.lowercased().replacingOccurrences(of: "-", with: "")
                    .replacingOccurrences(of: " ", with: "")
                if let info = chambers[chamber.name.lowercased()] ?? chambers[key] {
                    let s = info["normalizedStatus"] as? String ?? ""
                    status[chamber] = s == "alive" ? .alive : s == "degraded" ? .degraded : .offline
                }
            }
        }
        if let bear = json["bear"] as? [String: Any], let score = bear["score"] as? Double {
            bearScore = score
        }
    }

    private func markDOJODirect() async {
        guard let url = URL(string: "http://localhost:7410") else { return }
        if let (_, resp) = try? await URLSession.shared.data(from: url),
           let http = resp as? HTTPURLResponse, http.statusCode == 200 {
            status[.dojo] = .alive
        }
    }
}
