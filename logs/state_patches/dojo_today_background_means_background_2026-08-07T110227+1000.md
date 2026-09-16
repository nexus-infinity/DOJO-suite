# DOJO Today Background Means Background Patch

Timestamp: 2026-08-07T11:02:27+1000

## Objective

Restore the product law:

```text
FIELD governance must be available, not dominant.
```

## Observed

The first DOJO Today screen was still consuming operator attention with inside-FIELD material:

- Boundary Capacity first-screen rail card
- Receipts first-screen rail card
- receipt as a peer media object
- attention copy referencing internal machinery

This made governance visible as the main surface instead of background protection.

## Files Changed

- `Sources/DOJOApp/Views/DOJOTodaySurfaceView.swift`

## Patch

Moved behind the `System` depth sheet:

- full Boundary Capacity card
- receipt list
- build/launch repair receipt status
- read-only capacity details

Removed from first screen:

- full boundary capacity card
- full receipts card
- receipt media tile
- internal “machinery” wording

Kept on first screen:

- greeting
- one large capture/input area
- voice / text / drop affordance
- action buttons: capture, continue, review, attention
- recent thread placeholder
- one optional attention hint
- quiet trust indicators: Local, Receipts on, Held items available
- System button for requested depth

## Boundaries Preserved

- No dynamic spin
- No model training
- No portal runtime
- No Home probe
- No authority mutation
- No new architecture program
- Governance retained behind requested depth

## Build

Command:

```text
XcodeRefreshCodeIssuesInFile DOJO-suite/DOJOApp/Views/DOJOTodaySurfaceView.swift
```

Result:

```text
PASS
```

Command:

```text
Xcode BuildProject
```

Result:

```text
PASS
```

Build log:

```text
/var/folders/yl/b6mp9yw52sq_0mtrxrl2b3vr0000gs/T/ActionArtifacts/D0FCFA98-0C15-4280-854E-290A82F1969A/BuildProject/BuildProject-Log-20260807-110102.txt
```

## Screenshot

No fresh post-patch live screenshot was produced from this shell.

## Decision

```text
PARTIAL.BackgroundMeansBackgroundPatched
HOLD.PostPatchLiveVisualWitness
```

Code/build satisfies the first-screen law. Visual PASS remains held until the patched `DOJO Today` window is reopened and witnessed.

## Next Lawful Move

Reopen `DOJO Today` and visually confirm the first screen shows ordinary-use capture first, with governance only behind `System`.
