# Benchmark Workspace

Evaluates **Claude desktop (macOS)** as an operator surface for **DOJOApp**.

## Scope

- **Surface under test**: `claude_desktop_macos`
- **Target app**: DOJOApp (macOS, 720×600, `Sources/DOJOApp/`)
- **Task categories**:
  - `S1` — chamber state read: which chambers are alive vs dead in the ChamberRail?
  - `S2` — BEAR score read: what is the numeric score shown in the AppBEARRing?
  - `S3` — action recommendation: given the visible state, what is the correct next action?
- **Score authority**: manual

## DOJO Alignment

Follows the contract in [`DOJO_SUITE_CANONICAL_CONTRACT.md`](/Users/field/DOJO-suite/Sources/DOJOUI/DesignSystem/DOJO_SUITE_CANONICAL_CONTRACT.md).

- `input.artifact_*` fields satisfy the OBI-WAN evidence anchor requirement.
- `tata_validation.triangle_status` / `validation_status` give TATA a hard reject path.
- `routing` tracks propagation readiness.

## Layout

- `screenshots/` — DOJOApp window captures used as benchmark inputs
- `packets/` — one JSON packet per run
- `scoreboards/` — aggregated comparable rows

## S1/S2/S3 Procedure

1. Launch DOJOApp and capture a full-window screenshot into `benchmarks/screenshots/test_001.png`.
2. Compute SHA-256 for the image artifact.
3. Open Claude desktop (macOS) and submit the screenshot with the canonical prompts below.
4. Paste verbatim responses into the packet for each task slot.
5. Score each dimension 1–5 and set the TATA validation gate.
6. Copy the final row into `scoreboards/outcome_009_ui_interpretation.csv`.

## Canonical Prompts

**S1 — Chamber state**
```text
Look at this DOJOApp screenshot. The left rail shows chamber signals (◎ ⬛ ◻ ◈ etc.).
Which chambers appear active (glowing) and which appear inactive (dim)?
List them.
```

**S2 — BEAR score**
```text
There is a circular ring at the bottom of the left rail labelled BEAR with a numeric score inside.
What is the exact number shown?
```

**S3 — Action recommendation**
```text
Given the chamber states and BEAR score visible in this screenshot,
what is the most important action the operator should take next?
```

## Scoring Rubric (1–5)

| Score | Meaning |
|-------|---------|
| 5 | Exact, no errors |
| 4 | Correct with minor omission |
| 3 | Partially correct |
| 2 | Mostly wrong but on-topic |
| 1 | Hallucination or off-topic |

## Validation Rule

Packet is incomplete if artifact path, SHA-256, timestamp, or any response slot is missing.
If geometry is unresolved, set:

```json
{
  "triangle_status": "unresolved",
  "validation_status": "rejected"
}
```
