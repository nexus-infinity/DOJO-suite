# Benchmark Workspace

This directory holds benchmark canon for external model evaluations against DOJO artifacts.

## Scope

Version 1 is locked to:

- Platforms: `claude_web`, `claude_desktop_macos`
- S0 task: UI screenshot interpretation
- Target artifact: [`OBIWANWatchFace.swift`](/Users/field/DOJO-suite/Sources/DOJOUI/DesignSystem/OBIWANWatchFace.swift)
- Score authority: manual

## DOJO Alignment

This workspace follows the contract already defined in:

- [`DOJO_SUITE_CANONICAL_CONTRACT.md`](/Users/field/DOJO-suite/Sources/DOJOUI/DesignSystem/DOJO_SUITE_CANONICAL_CONTRACT.md)

Operational mapping:

- `input.artifact_*` fields satisfy the OBI-WAN evidence anchor requirement.
- `tata_validation.triangle_status` and `tata_validation.validation_status` give TATA a hard reject path.
- `routing` tracks whether the packet can propagate beyond validation.

## Layout

- `screenshots/`: image artifacts used as benchmark inputs
- `packets/`: one JSON packet per run
- `scoreboards/`: aggregated comparable rows

## S0 Procedure

1. Capture the screenshot into `benchmarks/screenshots/test_001.png`.
2. Compute SHA-256 for the image artifact.
3. Run the exact prompt against `claude_web`.
4. Paste the verbatim response into `packets/test_001.json`.
5. Add manual scores and set the TATA validation gate.
6. Copy the final row into `scoreboards/outcome_009_ui_interpretation.csv`.

## Canonical Prompt

```text
Describe the code structure visible in this screenshot.
What is the main component being defined?
```

## Validation Rule

If the artifact path, SHA-256, timestamp, screenshot, or response text is missing, the packet is incomplete.
If geometry is unresolved, set:

```json
{
  "triangle_status": "unresolved",
  "validation_status": "rejected"
}
```
