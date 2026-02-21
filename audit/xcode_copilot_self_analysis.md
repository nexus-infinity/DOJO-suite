# Xcode Copilot Self-Analysis

Anchor: `/Users/field/DOJO-suite/Package.swift`
Branch/PR: (proposed branch: `audit/self-analysis-package-change`)

## What change are you proposing?
Propose a minimal, safe Package manifest change: add a dedicated UI library target `DOJOUI` (and product) and make the primary app executable target (`DOJOApp`) depend on it. This moves preview/SwiftUI view code into a non-executable framework so Xcode Canvas/Preview works reliably without requiring `ENABLE_DEBUG_DYLIB = YES`, and it improves modular separation between UI and shared logic.

Rationale:
- Xcode preview engine requires UI/preview code to live in a library/framework target or the executable to use a debug dylib layout. Moving UI into `DOJOUI` is the package-friendly solution and avoids fragile build flag hacks.
- Encapsulates UI (ContentView, previews) away from the executable, making reuse across `DOJOMac`, `DOJOMobile`, and test harnesses easier.

---

## Assumptions (max 3)
1. `Sources/DOJOUI/` exists or can be created and will contain `ContentView.swift` and its PreviewProvider(s).
2. `DOJOApp` currently references UI symbols (e.g., `ContentView`) that can be satisfied by depending on `DOJOUI` after the change.
3. The project uses SwiftPM as the canonical package manifest and Xcode resolves SPM targets into schemes (standard behaviour for Xcode 14+).

## Unknowns
- Exact source file names and symbol locations: whether `ContentView` currently lives in `Sources/DOJOMacApp/` (and needs to be moved) or is already in `Sources/DOJOUI/`.
- Whether any other executable targets (e.g., `ArkadašApp`, `OB1LinkApp`) also reference the same UI files and would need to depend on `DOJOUI`.
- Any additional SPM product constraints or older CI wiring that assumes the current target layout.

---

## Next move (one small edit)
Edit `Package.swift` to:

1. Add a new library product entry:

```swift
.library(name: "DOJOUI", targets: ["DOJOUI"]),
```

2. Add a new target for `DOJOUI` (placed near `DOJOShared`):

```swift
.target(
  name: "DOJOUI",
  dependencies: ["DOJOShared"],
  path: "Sources/DOJOUI"
),
```

3. Update `DOJOApp` executable target to depend on `DOJOUI` as well as `DOJOShared`:

```swift
.executableTarget(
  name: "DOJOApp",
  dependencies: ["DOJOShared", "DOJOUI"],
  path: "Sources/DOJOApp"
),
```

This is a focused, single-file manifest change; it does not move source files — moving `ContentView.swift` into `Sources/DOJOUI/` is a next step if needed.

---

## Success check (build + test)
- Local verification commands (copy/paste):

```bash
cd /Users/field/DOJO-suite
swift build --configuration debug
swift test
```

- Xcode Canvas/Preview checks (manual):
  - Open `Package.swift` in Xcode, choose the `DOJOUI` scheme, set run destination to a simulator (for iOS preview) or `My Mac` (for macOS), open `Sources/DOJOUI/ContentView.swift`, and Resume the Canvas. Previews should compile without `ENABLE_DEBUG_DYLIB` errors.

- Acceptance criteria:
  1. `swift build` completes without errors.
  2. `swift test` (if tests exist) passes or reports only unrelated failures.
  3. Xcode Canvas builds UI previews when `DOJOUI` target scheme and simulator are selected.

---

## Failure check (what would break)
- If `ContentView` and preview symbols remain in `Sources/DOJOMacApp/` and are not moved (or not duplicated), `DOJOApp` may still compile but `DOJOUI` will be empty or missing symbols, causing build/link errors. Fix: move or duplicate the UI source into `Sources/DOJOUI/` and re-run.
- If other executables reference UI types but are not updated to depend on `DOJOUI`, their builds may fail with "No such module DOJOUI" or unresolved symbols. Fix: add `DOJOUI` to their `dependencies` array in `Package.swift`.
- CI or downstream scripts that expect the old target layout may fail; mitigate by updating CI scripts or adding compatibility notes in `audit/README.md`.

---

## Rollback plan
- If the edit causes unexpected breakage, revert the single commit that modifies `Package.swift` (git reset --hard or git revert commit), or restore from the patch prepared in `~/audit/`.

---

## Look-back: Chronicle Law 1–3 + SYMBOL_CONTRACT_LOCK
Ensure this change follows the repository's canonical rules:

- Chronicle Law 1: "Preserve geometric naming and symbol chamber locations" — new `DOJOUI` must live under the DOJO chamber namespace (use the sacred symbol in directory headers and file comments when appropriate). Add the frequency header to new or moved files (e.g., DOJOUI files should include a comment block: "Sacred Node: ◼︎DOJO — Frequency: 741Hz").

- Chronicle Law 2: "Location = Meaning = Frequency" — place UI sources under `Sources/DOJOUI/` and ensure directory names include the chamber symbol where required by repo canon (if your project's convention requires `◼︎DOJO/` prefix, apply the naming pattern consistently). I recommend adding a short `_header` comment to the top of moved files referencing the symbol and frequency.

- Chronicle Law 3: "No destructive migration without audit" — do not delete or rewrite sources. Perform non-destructive moves (copy + commit) and keep originals in `audit/quarantine` until validated.

Refer to `/Users/field/docs/SYMBOL_CONTRACT_LOCK.md` and ensure the new `DOJOUI` target's name and path conform to the symbol contract (if the contract requires sacred symbol characters in folder names, adapt the path to match the canon). If the contract forbids certain characters in Package.swift targets, prefer ASCII `DOJOUI` for the SPM target name and use symbolic directory names for human-facing resources.

---

## Proposed commit message
```
feat(package): add DOJOUI library target to host UI & previews; make DOJOApp depend on DOJOUI

- Adds `DOJOUI` library product and target
- Updates `DOJOApp` to depend on `DOJOUI`
- Enables robust Xcode Canvas previews without ENABLE_DEBUG_DYLIB
```

---

## Next steps I can perform now (pick one)
1. Make the small `Package.swift` edit and run `swift build` and `swift test` (I can apply the edit and verify locally here). 
2. Create `Sources/DOJOUI/` and move `ContentView.swift` into it, update file headers with sacred geometry comments, and re-run build & preview checks.
3. Prepare a patch and leave it for your review (non-destructive), so you can apply and push.

Tell me which one to do (1 / 2 / 3). If you want me to proceed, I will perform the small edit, run the build/test, and report results + any follow-up fixes.
