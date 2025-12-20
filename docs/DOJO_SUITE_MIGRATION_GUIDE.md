# DOJO-suite Migration & Repo Scaffolding Guide

**Purpose:** A single, shareable guide that describes the new `DOJO-suite` repository to create, contains the exact Copilot prompt to generate the repo scaffold, per-file prompts, safe migration commands, and QA checks.

## Status (Scanner Run)

- I scanned `/Users/jbear/FIELD-DEV` for name variants (Dojo-sweet, Dojo-suit, dojo_suite, etc.)
- The script wrote `/Users/jbear/dojo_occurrences.json` and found 6 matches, all in generated `.build` files under `/Users/jbear/FIELD-DEV/DOJO-Suite/.build/` (build artifacts)
- No source files were flagged by the scanner as containing DOJO naming variants
- **Recommendation:** Run the quick grep later on candidate source dirs before mass renames

## Quick Checklist (Shareable)

- [ ] Create the new `DOJO-suite` GitHub repository (empty remote)
- [ ] Use the Main Copilot prompt (below) at the new repo root to scaffold the package files
- [ ] Copy or extract source code from the monorepo (copy mapping below)
- [ ] Run `swift build` && `swift test` and fix any minor issues
- [ ] Enable CI/branch protection and hooks

---

## Main Single-Shot Copilot Prompt

**Usage:** Paste into Xcode Copilot / Copilot Chat at the new repo root

```
Create a complete Swift package repository named `DOJO-suite` to act as the canonical home of the DOJO particle visualization and shared geometry engine. The repo must be a production-ready SwiftPM layout with iOS and macOS app targets and a shared library target, basic unit tests, lint/format tooling, CI, pre-commit hooks, README and MIT license. Requirements:

- Package: Swift tools version 5.9+; platforms iOS 15+ and macOS 12+.

- Products & Targets:
  - Library product `DOJOShared` (target `DOJOShared`) — contains all shared geometry, simd utilities, and the particle engine.
  - App target `DOJOiOSApp` (target `DOJOiOSApp`) — SwiftUI iOS app that depends on `DOJOShared` and includes `ParticleFieldView`.
  - App target `DOJOMacApp` (target `DOJOMacApp`) — SwiftUI macOS app that depends on `DOJOShared` and includes `ManifestationParticleView`.
  - Test target `DOJOSharedTests` that depends on `DOJOShared` and contains basic tests for particle behavior and geometry transforms.

- Files to produce at repo root: `Package.swift`, `README.md`, `LICENSE` (MIT), `.gitignore`, `.swiftlint.yml`, `.githooks/pre-commit`, `.github/workflows/ci.yml`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/branch_protection.md`.

- Generate starter source files:
  - `Sources/DOJOShared/GeometryTransforms.swift` (orthographic mapping, safe attractorForce) — use existing code if present.
  - `Sources/DOJOShared/ParticleEngine.swift` (GeometricParticle, ParticleEngine API: init(count:), step(dt:), applyAttractor(...)).
  - `Sources/DOJOiOSApp/ParticleFieldView.swift` (SwiftUI Canvas using ParticleEngine).
  - `Sources/DOJOMacApp/ManifestationParticleView.swift` (macOS counterpart).
  - `Tests/DOJOSharedTests/AttractorTests.swift` (unit tests verifying attractorForce and zero-distance handling).

- Lint & format: include swiftformat + swiftlint usage in CI and a pre-commit hook that runs checks.

- CI: GitHub Actions workflow that runs on push and PR to `main`, on macos-latest: checkout, install tooling (brew or mint fallback), `swift build`, `swift test`, `swiftformat --lint .`, `swiftlint lint --strict`.

- Copy guidance: When scaffolding, copy existing sources from the workspace into the new layout:
  - `/Users/jbear/FIELD-DEV/DOJO-SwiftPM/Sources/DojoSuite/* -> Sources/DOJOShared/`
  - `/Users/jbear/FIELD-DEV/DojoiOS/ParticleFieldView.swift -> Sources/DOJOiOSApp/ParticleFieldView.swift`
  - `/Users/jbear/FIELD-DEV/DojoMac/ManifestationParticleView.swift -> Sources/DOJOMacApp/ManifestationParticleView.swift`
  - If `FIELD-Modules/SacredGeometry` is required, add it as a local package dependency in `Package.swift` or vendor only needed files into `DOJOShared`.

- Add short README Quick Start and developer notes (how to enable .githooks and run lint/format).

- Keep the scaffolding small and immediately buildable (`swift build` and `swift test` should pass or be trivially fixable).
```

---

## Per-File Copilot Prompts

**Usage:** Paste individually if you want focused outputs

### `Package.swift` Prompt

```
Create a minimal `Package.swift` for package name `DOJO-suite` (swift-tools 5.9). Add product `DOJOShared` (library) and targets: `DOJOShared`, `DOJOiOSApp` (dependsOn DOJOShared), `DOJOMacApp` (dependsOn DOJOShared), and `DOJOSharedTests` (test). Set platforms iOS 15+ and macOS 12+. Keep dependencies local/minimal.
```

### `README.md` Prompt

```
Write a concise `README.md` with: project purpose, quick start commands (clone, swift build, swift test), note to run `git config core.hooksPath .githooks` to enable hooks, and link to LICENSE.
```

### `LICENSE` Prompt (MIT)

```
Create an `LICENSE` file with the MIT license. Put `Your Name or Organization` and year `2025` as placeholders.
```

### `.gitignore` Prompt

```
Create a `.gitignore` for Swift/Xcode: ignore `.build`, `.swiftpm`, DerivedData, `.DS_Store`, `*.xcworkspace`, `Pods/`, `Carthage/`, `.idea/`, `.vscode/`.
```

### `.swiftlint.yml` Prompt

```
Create `.swiftlint.yml` enabling recommended rules, set max_line_length: 120 and disable `trailing_whitespace`.
```

### `.githooks/pre-commit` Prompt

```
Create `.githooks/pre-commit` (POSIX shell) that runs `swiftformat --lint .` then `swiftlint lint --strict`; if either fails, exit non-zero and block commit. Include a short echo instruction to set `git config core.hooksPath .githooks`.
```

### `.github/workflows/ci.yml` Prompt

```
Create `ci.yml` (GitHub Actions) that runs on push and PR to main on `macos-latest`. Steps: actions/checkout@v4 -> install swiftformat & swiftlint (brew or Mint) -> swift build -> swift test -> swiftformat --lint . -> swiftlint lint --strict. Document homebrew vs mint usage in comments.
```

### `GeometryTransforms.swift` Prompt

```
Create `GeometryTransforms.swift` (public API) with Camera struct and GeometryTransforms methods `fieldToScreen`, `screenToField` and `attractorForce` using simd; ensure safe handling of zero distance.
```

### `ParticleEngine.swift` Prompt

```
Create `ParticleEngine.swift` exposing `GeometricParticle` and `ParticleEngine` with public API: `init(count:Int)`, `step(dt:Float)`, `applyAttractor(position: SIMD3<Float>, strength: Float, falloff:Float)`. Keep logic simple and testable.
```

### `ParticleFieldView.swift` (iOS) Prompt

```
Create `ParticleFieldView.swift` as a SwiftUI Canvas that obtains particle positions from `ParticleEngine` and draws circles. Provide a preview and an API for `particleCount`.
```

### `ManifestationParticleView.swift` (macOS) Prompt

```
Create a macOS-adapted view that mirrors the iOS particle view using the same `ParticleEngine`.
```

### `Tests/AttractorTests.swift` Prompt

```
Create a unit test asserting `attractorForce` returns a vector pointing at the attractor and that zero-distance returns a zero vector (or safe finite vector).
```

---

## Safe Migration & Rename Guidance (Summary)

- Scanner found only `.build` occurrences; do not mass-replace across `.build` or generated artifacts.
- If you want to normalize names in source files, run the scanner, review `/Users/jbear/dojo_occurrences.json`, and then:
  1. Create a branch: `git checkout -b normalize/dojo-naming`
  2. For filename renames: `git mv old/path NewPath` and `git commit`.
  3. For content-only replacements use the safe per-file script (below). Commit per-file to keep history clear.

### Safe Replace Helper (Already Saved Under Tools)

- `/Users/jbear/FIELD-DEV/tools/generate_dojo_report.py` (scanner)
- `/Users/jbear/FIELD-DEV/tools/safe_replace.sh` (creates per-file commits)

### Run the Safe Script (Example)

```bash
cd /Users/jbear/FIELD-DEV
git checkout -b normalize/dojo-naming
./tools/generate_dojo_report.py /Users/jbear/FIELD-DEV /Users/jbear/dojo_occurrences.json
./tools/safe_replace.sh /Users/jbear/dojo_occurrences.json
```

---

## Copy Mapping (What to Seed Into the New Repo)

- `/Users/jbear/FIELD-DEV/DOJO-SwiftPM/Sources/DojoSuite/*` → `Sources/DOJOShared/`
- `/Users/jbear/FIELD-DEV/DojoiOS/ParticleFieldView.swift` → `Sources/DOJOiOSApp/ParticleFieldView.swift`
- `/Users/jbear/FIELD-DEV/DojoMac/ManifestationParticleView.swift` → `Sources/DOJOMacApp/ManifestationParticleView.swift`
- If you need `SacredGeometry` utilities: add `FIELD-Modules/SacredGeometry` as a local package dependency or copy the needed files into `DOJOShared`.

### Copy Commands (Example)

```bash
# Run in new repo root
mkdir -p Sources/DOJOShared Sources/DOJOiOSApp Sources/DOJOMacApp Tests/DOJOSharedTests
cp -R /Users/jbear/FIELD-DEV/DOJO-SwiftPM/Sources/DojoSuite/* Sources/DOJOShared/ || true
cp /Users/jbear/FIELD-DEV/DojoiOS/ParticleFieldView.swift Sources/DOJOiOSApp/ || true
cp /Users/jbear/FIELD-DEV/DojoMac/ManifestationParticleView.swift Sources/DOJOMacApp/ || true
```

---

## Two Repo-Init Flows (Copy-Paste)

### A) Quick Init (No History)

```bash
mkdir -p ~/projects/DOJO-suite
cd ~/projects/DOJO-suite
git init
git remote add origin git@github.com:YOUR_ORG/DOJO-suite.git

# Create dirs and copy code (use copy commands above)
# Then commit and push
git add .
git commit -m "Initial DOJO-suite scaffold"
git branch -M main
git push -u origin main
```

### B) Extract With History (Subtree Split — Recommended to Preserve History)

```bash
cd /Users/jbear/FIELD-DEV
git subtree split -P DOJO-SwiftPM -b dojo-split-branch
mkdir -p /tmp/DOJO-suite
cd /tmp/DOJO-suite
git init
git remote add origin git@github.com:YOUR_ORG/DOJO-suite.git
git pull /Users/jbear/FIELD-DEV dojo-split-branch

# Adjust Package.swift and file locations if needed
git add .
git commit -m "Reorganize package to top-level"
git branch -M main
git push -u origin main
```

---

## CI Snippet

**Usage:** Paste into `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Homebrew packages
        run: |
          brew update
          brew install swiftlint swiftformat || true
      
      - name: Build
        run: swift build --configuration debug
      
      - name: Test
        run: swift test --parallel
      
      - name: SwiftFormat (check)
        run: swiftformat --lint . || true
      
      - name: SwiftLint
        run: swiftlint lint --strict
```

---

## Post-Init QA (What to Run Locally)

After cloning the new repo locally:

```bash
# Enable hooks locally
git config core.hooksPath .githooks

# Build the project
swift build

# Run tests
swift test

# Check formatting
swiftformat --lint .

# Run linter
swiftlint lint
```

---

## Notes & Next Steps

- The scanner found occurrences only in `.build` artifacts. Before renaming anything in source, re-run the grep on the candidate source directories:

```bash
grep -RIn --exclude-dir=.git --exclude-dir=.build -E "\b[Dd]ojo[-_ ]?(suite|sweet|suit)\b" \
  /Users/jbear/FIELD-DEV/DOJO-SwiftPM \
  /Users/jbear/FIELD-DEV/DojoiOS \
  /Users/jbear/FIELD-DEV/DojoMac | sed -n '1,200p'
```

- If you want the concrete file contents for the scaffold (Package.swift, README, LICENSE, .gitignore, .swiftlint.yml, .githooks/pre-commit, CI, sample source files and tests), reply: **"Generate files"** and I will create them in the new repo folder or paste contents for you to copy.

---

## Quick Reference

### Key Files to Generate

| File | Purpose |
|------|---------|
| `Package.swift` | SwiftPM package manifest |
| `README.md` | Project documentation |
| `LICENSE` | MIT license |
| `.gitignore` | Git ignore rules |
| `.swiftlint.yml` | SwiftLint configuration |
| `.githooks/pre-commit` | Pre-commit hook for linting |
| `.github/workflows/ci.yml` | GitHub Actions CI workflow |
| `Sources/DOJOShared/GeometryTransforms.swift` | Geometry utilities |
| `Sources/DOJOShared/ParticleEngine.swift` | Particle engine core |
| `Sources/DOJOiOSApp/ParticleFieldView.swift` | iOS particle view |
| `Sources/DOJOMacApp/ManifestationParticleView.swift` | macOS particle view |
| `Tests/DOJOSharedTests/AttractorTests.swift` | Unit tests |

### Required Tools

- Swift 5.9+
- SwiftLint (via Homebrew or Mint)
- SwiftFormat (via Homebrew or Mint)
- Xcode (for iOS/macOS development)

### Support Platforms

- iOS 15.0+
- macOS 12.0+

---

**End of Guide**
