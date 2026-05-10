import Foundation

// Deterministic starter state for Cockpit v0.
// Three cells seeded with O/I/R prompts; [2,2] left empty so PolicyEngine
// continues to block Accept until the user explicitly authorises that gate.
public enum CockpitSeedPlan {

    public static let plan = DocumentPlan(title: "Cockpit v0")

    public static func makeSeedState() -> ParticleBoardState {
        var cells: [BoardCell] = []
        for r in 0...2 {
            for c in 0...2 {
                guard let addr = GridAddress(row: r, col: c) else { continue }
                cells.append(BoardCell(address: addr, payload: seedPayload(row: r, col: c)))
            }
        }
        return ParticleBoardState(cells: cells)
    }

    private static func seedPayload(row: Int, col: Int) -> BoardPayload {
        switch (row, col) {
        // Row 0 — System state (what is actually true right now)
        case (0, 0): return .route(
            intent: "Observed",
            action: "6 chambers live: AKRON 3960 · OBI-WAN 9630 · TATA 4320 · ATLAS 5280 · ARKADAS 7170 · DOJO 7410. All 5 spoke models wired to Ollama.")
        case (0, 1): return .route(
            intent: "Interpretation",
            action: "The training pipeline is complete to its current ceiling. 3/6 DOJO gates pass stably. Structural — not a data problem.")
        case (0, 2): return .route(
            intent: "Recommendation",
            action: "Freeze training. Build one deterministic test per chamber. Wire the app to the live /chat endpoints.")

        // Row 1 — Current task
        case (1, 0): return .route(
            intent: "Observed",
            action: "DOJO /chat at port 7410 returns real responses via gemma3 bridge. MinimalChatView exists but is not the primary surface.")
        case (1, 1): return .route(
            intent: "Interpretation",
            action: "The app has a working backend and a working UI surface. The gap is wiring — not capability.")
        case (1, 2): return .empty  // user sets next action

        // Row 2 — Left open for operator input
        default:     return .empty
        }
    }
}
