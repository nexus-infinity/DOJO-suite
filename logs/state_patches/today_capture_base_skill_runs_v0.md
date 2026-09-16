# Today Capture — CSIA base-skill runs

**Object:** Score the ordinary Today Capture loop (TRY on the held slope).
**Issued:** 2026-08-31T01:55:42Z
**Repo:** `/Users/field/DOJO-suite` · `main`
**KC:** `/Users/field/◎Kings-Chamber/chronicle/KC_REENTRY_20260831T015326Z_DOJO-TODAY-CAPTURE-BASE-SKILL-RUN-V0.receipt.json` · PASS
**Lens:** `cricket` (this ball) · CSIA amplifier (base before the next hill)

```text
Recipe intention:   Get runs on the board on the current Today Capture slope.
Intended attribute: Capture evidence path is scored (same journal Keep uses).
Not this dish:      MapKit · CarPlay · hosted Ask · fake live-store Keep
```

## Scorecard

| Ball | When | Result | Evidence |
|---|---|---|---|
| Prior 1 | 2026-08-29T16:24:38Z | CAPTURED | Live `~/Library/Application Support/org.field.dojo/local_capture_receipts.jsonl` |
| Prior 2 | 2026-08-29T16:54:58Z | CAPTURED | Same journal (operator Keep, this sitting did not mutate it) |
| This sitting | 2026-08-31T01:55:42Z | 2/2 journal runs PASS | `LocalCaptureReceiptJournalTests.testCaptureLoopScoresOneRunOnTheBoard` |
| Digest / roundtrip | same | 3/3 PASS | `LocalCaptureReceiptTests` |
| DOJOApp | same | build complete | `swift build --target DOJOApp` |

Keep now writes through `LocalCaptureReceiptJournal` (`Sources/DOJOShared/Today/LocalCaptureReceiptJournal.swift`).

## Not claimed

GUI click-through this sitting. Hosted Ask. Portal. MapKit. CarPlay.

## Do′

Lived next ball: open **DOJO Today** → Capture → Keep → Proof, and read the new line in the same jsonl.

## Action obligation

`ACT` — evidence loop scored.
`ASK` — operator bowls the lived Keep if they want the inverse-field run.
`HOLD WITH RECHECK` — later hills still unsealed.
