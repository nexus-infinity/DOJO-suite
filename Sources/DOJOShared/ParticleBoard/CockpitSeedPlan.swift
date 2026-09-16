import Foundation

// CockpitVeneer3×3 — first-launch plan content (Cockpit G3 seed, naming-corrected).
//
// Lawful object: CockpitVeneer3×3 / Veneer3×3 control surface
//   (cockpit / admin / control / plan panel only)
//
// Naming lock (OAW_COCKPIT_VENEER_NAME_CORRECTION_20260805T112036Z):
//   "Particle Board" is reserved for Geometrical Particle Board only.
//   This surface must NOT be called ParticleBoard.Veneer3×3, Particle Board Veneer,
//   or any ParticleBoard.* prefix for the 3×3 admin/control surface.
//
// Not: Geometrical Particle Board, VisualMatter, living board, GPB progress, G6 hardware.
//
// Grid grammar (AikidoOpticsCodec):
//   Row 0 = intent · Row 1 = structure · Row 2 = policy
//   Col 0 = draft · Col 1 = validate · Col 2 = publish
//   Claim class is in route(intent:): Observed | Interpretation | Recommendation
//
// PolicyEngine: cell [2,2] MUST remain empty at seed so Accept stays locked
// until the operator explicitly authorises an execution action.
//
// Note: Swift types/paths may still say ParticleBoard* (structural rename staged).
// Lawful display and claim language uses CockpitVeneer3×3 only.

public enum CockpitSeedPlan {

    /// Seed version — bump when first-launch content or lawful naming changes.
    public static let seedVersion = "G3.20260805.naming"

    /// Lawful lane name (not Geometrical Particle Board).
    public static let lawfulLaneName = "CockpitVeneer3x3"

    public static let plan = DocumentPlan(
        title: "CockpitVeneer3×3 — Plan (G3)",
        sections: [
            DocumentSection(
                heading: "Intent — what is true on this surface",
                axis: .witness
            ),
            DocumentSection(
                heading: "Structure — G-sequence and lane fences",
                axis: .logic
            ),
            DocumentSection(
                heading: "Policy — allowed / forbidden / Accept gate",
                axis: .environment
            )
        ],
        placeholders: [
            "{operator-next-action}",
            "{accept-gate-authorisation}"
        ],
        policyPins: [
            PolicyPin(
                allowedAction: "Edit plan cells on CockpitVeneer3×3",
                constraint: "Does not promote Geometrical Particle Board, VisualMatter, or living board"
            ),
            PolicyPin(
                allowedAction: "Hold Accept until [2,2] authorised",
                constraint: "PolicyEngine POLICY_GATE_LOCKED while [2,2] empty"
            ),
            PolicyPin(
                allowedAction: "Hold G4 until naming correction acknowledged (now applied in seed language)",
                constraint: "G4 persistence remains separate; do not start G4 from this pass"
            )
        ]
    )

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

    /// Count of non-empty seeded cells (G3 target: 8; [2,2] empty).
    public static var seededNonEmptyCount: Int {
        makeSeedState().cells.filter {
            if case .empty = $0.payload { return false }
            return true
        }.count
    }

    private static func seedPayload(row: Int, col: Int) -> BoardPayload {
        switch (row, col) {

        // ── Row 0 · Intent (what is true on this surface) ─────────────────
        case (0, 0):
            return .route(
                intent: "Observed",
                action: """
                Surface: CockpitVeneer3×3 (Veneer3×3 control surface — cockpit plan panel). \
                Seed: \(seedVersion). \
                Lane: DOJO-suite cockpit. \
                First launch loads this plan when no cockpit snapshot exists. \
                Particle Board name is reserved for Geometrical Particle Board only.
                """
            )
        case (0, 1):
            return .route(
                intent: "Interpretation",
                action: """
                This is a 3×3 O/I/R cockpit control veneer for operator readability. \
                It is not Geometrical Particle Board, not VisualMatter, not smoke-to-photograph, \
                and not a living high-density particle field. G3 seed is cockpit-control only.
                """
            )
        case (0, 2):
            return .route(
                intent: "Recommendation",
                action: """
                Use cells for Observed / Interpretation / Recommendation only. \
                Do not call this ParticleBoard or Particle Board. \
                Do not claim GPB, VisualMatter, living board, G6, Sentry, training, or spin from this veneer.
                """
            )

        // ── Row 1 · Structure (G-sequence and dependencies) ───────────────
        case (1, 0):
            return .route(
                intent: "Observed",
                action: """
                Sequence: G1 ✅ · G2 ✅ · G3 cockpit seed ✅ (naming-corrected) · \
                G4 persist HOLD until after naming ack · freeze route drift · \
                G6 acoustic/hardware (human gate). \
                Geometrical Particle Board VisualMatter: HOLD.NotImplemented.
                """
            )
        case (1, 1):
            return .route(
                intent: "Interpretation",
                action: """
                G3 success = meaningful plan cells on first launch for CockpitVeneer3×3 only. \
                G3 is not GPB progress. G4 success = same board survives restart. \
                G6 is separate and user-device-only.
                """
            )
        case (1, 2):
            return .route(
                intent: "Recommendation",
                action: """
                After naming correction is acknowledged: G4 remains HOLD until explicitly opened. \
                Do not expand into Commons/Gemini sheets, HF training, spin, or GPB VisualMatter from this lane.
                """
            )

        // ── Row 2 · Policy (authorisation layer) ──────────────────────────
        case (2, 0):
            return .route(
                intent: "Observed",
                action: """
                PolicyEngine: Accept blocked while [2,2] is empty (POLICY_GATE_LOCKED). \
                Allowed: plan edit, HOLD, receipt emit on CockpitVeneer3×3. \
                Forbidden: ParticleBoard name for this surface; GPB/VisualMatter claims; G6/Sentry/training/spin from veneer.
                """
            )
        case (2, 1):
            return .route(
                intent: "Interpretation",
                action: """
                Empty [2,2] is intentional — execution gate stays human-authorised. \
                Filling [2,2] means the operator accepts a specific next action, not auto-promotion \
                and not Geometrical Particle Board progress.
                """
            )
        case (2, 2):
            // Keep empty — Accept gate locked until operator sets an action.
            return .empty

        default:
            return .empty
        }
    }
}
