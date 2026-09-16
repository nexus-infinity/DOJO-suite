# External Seal Experience Contract V0

**Status:** `DESIGN_REFINEMENT` · contracts + state machine + tests seated · **live physical seal HOLD**
**Object:** `DOJO.ExternalSealExperience`
**Handoff:** `docs/EXTERNAL_SEAL_EXPERIENCE_REFINEMENT_HANDOFF_V0.md`
**Predecessor:** Observer-Aligned Assistance ontology Weave — **preserved unchanged**

**Current successor refinement:** `docs/EXTERNAL_SEAL_FOCUS_LEASE_AND_RETURN_HANDOFF_V0.md` — the seal may request a bounded Focus Lease, while deterministic attention arbitration and continuity restoration remain separate constructs. Runtime remains HOLD.

---

## Confirmed refinement (viewed)

1. External Seal Experience is a **separate construct** from the originating OAW Weave.
2. Originator emits immutable **Seal Candidate**; cannot self-seal.
3. Seven-stage participatory commissioning ritual.
4. Calibration sound/movement must **verify**, not decorate.
5. Opening ≠ reading ≠ understanding ≠ affirming ≠ verifying ≠ sealed.
6. **ConfigurationEpoch** is physical–digital baseline; material change forces recommission.
7. Device admission ≠ external seal.
8. No new chamber/registry/truth surface — reuse KC, P11, Proof, Chronicle, Inspector as linked depth only.

---

## Seated implementation (this Weave)

| Artifact | Path |
|----------|------|
| Swift contracts + state machine | `Sources/DOJOShared/Contracts/ExternalSealExperienceContracts.swift` |
| Deterministic tests | `Tests/DOJOSharedTests/ExternalSealExperienceTests.swift` |
| Static seal specimen | `docs/fixtures/external_seal_experience_static_specimen_v0.json` |
| Offline calibration fixture | `docs/fixtures/external_seal_participatory_calibration_offline_fixture_v0.json` |
| This contract | `docs/EXTERNAL_SEAL_EXPERIENCE_CONTRACT_V0.md` |

Predecessor ontology, mapping, OAA Swift stubs, validator, and ontology seat receipt: **not modified**.

---

## Seal status of this Weave

```text
intentionally_unsealed
```

**Reason:** Contracts, machine, fixtures, and tests are design-time. Independent External Seal Experience (human participatory commissioning of a live physical–digital correspondence) has **not** been performed. No SEALED ConfigurationEpoch is claimed.

**Return point:** Run External Seal Experience outside this Weave against a submitted Seal Candidate (e.g. Voice & capture specimen).
**Resume condition:** Observer completes seven stages with independent judgement and required anchors.

---

## One-line lock

**The Weave produces the candidate; a separate participatory Seal Experience commissions physical–digital correspondence; the resulting epoch cannot silently survive material change.**
