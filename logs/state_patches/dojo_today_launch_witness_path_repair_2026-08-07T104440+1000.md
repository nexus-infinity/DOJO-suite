# DOJO Today Launch Witness Path Repair

Timestamp: 2026-08-07T10:44:40+1000

## Objective

Repair the macOS app launch witness path so `DOJO Today` can be opened and screenshotted from a live operator window.

## Files Inspected

- `Sources/DOJOApp/Info.plist`
- `Sources/DOJOApp/DOJOApp.swift`
- `project.yml`
- Built bundle at `~/Library/Developer/Xcode/DerivedData/.../Build/Products/Debug/DOJOApp.app`

## Files Changed

- `Sources/DOJOApp/Info.plist`
- `Sources/DOJOApp/DOJOApp.swift`
- `project.yml`
- `DOJO-suite.xcodeproj/project.pbxproj` via `xcodegen generate`

## Repairs Applied

### Info.plist

- Aligned `CFBundleIdentifier` with target signing identity:

```text
org.field.dojo
```

- Restored explicit executable metadata:

```text
CFBundleExecutable = $(EXECUTABLE_NAME)
CFBundleInfoDictionaryVersion = 6.0
```

- Added:

```text
LSApplicationCategoryType = public.app-category.productivity
```

### DOJOApp Target Settings

- Set:

```text
GENERATE_INFOPLIST_FILE = NO
ENABLE_DEBUG_DYLIB = NO
```

This makes the Debug product use a conventional `Contents/MacOS/DOJOApp` executable instead of an Xcode debug-stub executable plus `DOJOApp.debug.dylib`.

### Startup Lifecycle

- Removed the custom `NSApplicationDelegateAdaptor` startup activation path.
- SwiftUI now owns initial app/window lifecycle directly.

## Build

Command:

```bash
xcodegen generate
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
/var/folders/yl/b6mp9yw52sq_0mtrxrl2b3vr0000gs/T/ActionArtifacts/00AFD84C-76EF-4FDD-8403-B71F818C84E8/BuildProject/BuildProject-Log-20260807-104344.txt
```

## Bundle Verification

Built Info.plist contains:

```text
CFBundleExecutable = DOJOApp
CFBundleIdentifier = org.field.dojo
```

Executable verification:

```text
Contents/MacOS/DOJOApp: Mach-O 64-bit executable arm64
```

The executable now links directly to app frameworks; no `DOJOApp.debug.dylib` launcher remains.

## Launch Witness Attempt

Attempted:

```bash
open /private/tmp/DOJOAppWitness.app
```

Result:

```text
HOLD.LiveDOJOTodayOperatorWindowWitness
```

Observed error:

```text
kLSNoExecutableErr
```

Forced direct execution:

```bash
/private/tmp/DOJOAppWitness.app/Contents/MacOS/DOJOApp
```

Result:

```text
EXC_CRASH / SIGABRT / code 134
```

## Decision

```text
PARTIAL.LaunchBundleMetadataRepaired
HOLD.LiveDOJOTodayOperatorWindowWitness
```

## Holds Preserved

- HOLD.LiveDOJOTodayOperatorWindowWitness
- HOLD.ProductMaturity
- HOLD.RendererIdentity
- HOLD.VisualEquivalenceToKodexXcodeVersion
- HOLD.ReleaseDissolveVisualReceipt

## Next Lawful Move

Open `DOJOApp` from Xcode's Run action or another unsandboxed operator launcher, then capture the `DOJO Today` window if AppKit registration succeeds there. If it still aborts in the unsandboxed GUI session, inspect the Apple crash report for the first project frame above `_NSInitializeAppContext`.
