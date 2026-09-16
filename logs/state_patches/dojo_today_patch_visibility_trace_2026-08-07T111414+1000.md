# DOJO Today Patch Visibility Trace

Timestamp: 2026-08-07T11:14:14+1000

## Objective

Trace why the patched `DOJOTodaySurfaceView` was not visible in the live app.

## Observed

The live visual witness still showed the pre-patch layer:

- Boundary Capacity rail visible on first screen
- Receipts rail visible on first screen
- no large text/drop input visible
- no `System` depth control visible

## Scheme / Target

Active build settings confirm:

```text
TARGET_NAME = DOJOApp
PRODUCT_NAME = DOJOApp
PRODUCT_BUNDLE_IDENTIFIER = org.field.dojo
FULL_PRODUCT_NAME = DOJOApp.app
BUILT_PRODUCTS_DIR = /Users/field/Library/Developer/Xcode/DerivedData/DOJO-suite-chpxgmwqpwprgncvzevbccprkabz/Build/Products/Debug
ENABLE_DEBUG_DYLIB = NO
GENERATE_INFOPLIST_FILE = NO
```

## Root View / Window Route

Source route confirms:

```text
WindowGroup("DOJO Today") {
    DOJOTodaySurfaceView()
}
```

`DOJO Today` is the first `WindowGroup` in `Sources/DOJOApp/DOJOApp.swift`.

## Built Bundle Contains Patch

The built executable contains post-patch strings:

```text
Speak, type, or drop something here...
Nothing moves until you choose.
Details available
Drop to review
SystemDepthView
```

This means the build product includes the patched source.

## Running App Processes

Two `DOJOApp` processes were observed running from:

```text
/Users/field/Library/Developer/Xcode/DerivedData/DOJO-suite-chpxgmwqpwprgncvzevbccprkabz/Build/Products/Debug/DOJOApp.app/Contents/MacOS/DOJOApp
```

Observed PIDs:

```text
6515
83230
```

Interpretation:

```text
The live witness likely showed a stale in-memory DOJOApp process, not a freshly relaunched patched binary.
```

## Multiple App Bundle Copies

Copies found:

```text
/Users/field/DOJO-suite/build/Debug/DOJOApp.app
/Users/field/Library/Developer/Xcode/DerivedData/DOJO-suite-chpxgmwqpwprgncvzevbccprkabz/Index.noindex/Build/Products/Debug/DOJOApp.app
/Users/field/Library/Developer/Xcode/DerivedData/DOJO-suite-chpxgmwqpwprgncvzevbccprkabz/Build/Products/Debug/DOJOApp.app
/private/tmp/dojo-suite-visual-review-derived/Build/Products/Debug/DOJOApp.app
/private/tmp/dojo-today-derived/Build/Products/Debug/DOJOApp.app
```

## Attempted Fix

Attempted to terminate stale `DOJOApp` PIDs:

```bash
kill 6515 83230
```

Result:

```text
operation not permitted
```

Attempted Apple Events quit by bundle id:

```bash
osascript -e 'tell application id "org.field.dojo" to quit'
```

Result:

```text
application id not resolved / blocked from this shell
```

## Decision

```text
HOLD.PatchNotVisibleInLiveApp
HOLD.LiveSurfaceStillShowsOldLayer
```

## Next Lawful Move

Quit all visible `DOJOApp` / `DOJO Today` windows from the macOS UI or Xcode Stop button, then run the `DOJOApp` scheme again from Xcode. The fresh window must show the patched input-first surface before PASS.
