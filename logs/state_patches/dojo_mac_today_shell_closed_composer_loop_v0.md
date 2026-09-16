# DOJO Mac Today shell — closed composer loop v0

**Object:** Mac DOJO application shell
**Sitting:** Slice 1 — one primary window, one closed composer loop, no CarPlay
**Status:** `IMPLEMENTED.LOCAL` · `NOT_PROMOTED`
**Surface:** Cursor
**Repo:** `/Users/field/DOJO-suite` · branch `main`
**Issued:** 2026-08-29T16:26:52Z

## What this is

The Mac application is now **DOJO Today**. Launch presents that one primary window. Capture, hosted Ask, and DOJO portal success paths persist a generated object and issue a **local** receipt.

This is application-shell evidence. It is not Chronicle promotion, chamber authority, spinning-top PASS, or CarPlay.

## Witnessed changes

| Pin | Actual |
|---|---|
| Primary scene | `WindowGroup("DOJO Today")` → `DOJOTodaySurfaceView` |
| Labs | Singleton `Window` scenes, opened from **Labs** menu only |
| Closed loop | composer intent → object → `GeneratedObjectStore.complete` → local receipt JSONL |
| Operations | `local_capture` · `hosted_answer` · `portal_response` |
| Receipt home | `~/Library/Application Support/org.field.dojo/local_capture_receipts.jsonl` |
| CarPlay | unchanged held contract; no target, entitlement, template, or runtime |

## Verification

- Editor preflight PASS: `/Users/field/logs/state_patches/EDITOR_PREFLIGHT_20260829T162149Z.receipt.json`
- KC registration recorded (projection regen HOLD, as intended): `/Users/field/◎Kings-Chamber/chronicle/KC_REENTRY_20260829T162344Z_DOJO-MAC-TODAY-SHELL-CLOSED-COMPOSER-LOOP-V0.receipt.json`
- `swift build --target DOJOApp` PASS
- `swift test --filter LocalCaptureReceiptTests` 3/3 PASS
- GUI click-through: not run this sitting

## Still HOLD

- CarPlay channel remains `CHANNEL-HELD`
- Engineering lens remains unseated
- Local receipts ≠ Chronicle / KC promotion
- Portal and hosted routes still require their live backends; failures stay visible with no silent fallback
- Capture is the offline loop that always can complete

## Next lawful move

Launch DOJO Today, Keep a Capture note, open Proof, confirm a local receipt ID. Later sittings may add CarPlay as a constrained phenotype of the same grammar.

## Action obligation

`ACT` — human launch-and-Keep witness, or continue to the next bounded surface after that receipt is seen.
