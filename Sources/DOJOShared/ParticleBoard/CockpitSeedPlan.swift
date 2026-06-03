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
            action: "DOJO validation 1/6 on HF (2026-04-23). Harmony/chat-template mismatch. gemma3 is bridge-only — naima persona not seated.")
        case (0, 2): return .route(
            intent: "Recommendation",
            action: "Pin transformers>=4.52.0, fix chat-template. New HF job ~$22-25 (budget gate). Validate 6/6 before seating naima.")

        // Row 1 — Current task
        case (1, 0): return .route(
            intent: "Observed",
            action: "DOJO /chat live at port 7410 via gemma3. SpineTests 4/4 passing. Gap B closed. ParticleBoard seeded (G3 complete).")
        case (1, 1): return .route(
            intent: "Interpretation",
            action: "G1–G3 sealed. G4 next: board persists across restart. G6: hardware gate (BT + TTS duck/resume on device).")
        case (1, 2): return .empty  // user sets next action

        // Row 2 — Left open for operator input
        default:     return .empty
        }
    }
}
