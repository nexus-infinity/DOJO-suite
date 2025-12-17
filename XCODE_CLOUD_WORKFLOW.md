# Xcode Cloud Quick Workflow (one-click friendly)

This doc explains the easiest Xcode Cloud workflow for non-traditional developers. It assumes your repo is `nexus-infinity/DOJO-suite` and shared schemes exist (we detected `DOJOSuite-All` and `DOJOiOSApp`).

Goals: minimal friction, reliable builds, and clear actions for PR contributors.

Quick summary
1. Push PR to `main` branch — Xcode Cloud will run the `CI / PR Build` workflow.
2. Workflow builds the specified shared scheme, runs unit tests, and reports results in App Store Connect.
3. If tests pass and reviewers approve, merge to `main`.

Recommended Xcode Cloud Workflow settings
- Trigger: Pull Request + Push to `main`
- Xcode version: Latest stable (or specific version matching local dev if required)
- Scheme: `DOJOSuite-All` (preferred) or `DOJOiOSApp`
- Signing: Automatic (Xcode Cloud manages signing)
- Actions: Build, Test, (optional) Archive & Distribute to TestFlight

How to connect the repo to Xcode Cloud (one-time setup)
1. App Store Connect → My Apps → select/create your App
2. App → Xcode Cloud → Get Started → Connect GitHub → authorize nexus-infinity
3. Select repo `nexus-infinity/DOJO-suite` and branch `main`
4. Create workflow with the settings above and save

What contributors must do in a PR
1. Ensure shared schemes are present (the repo already contains them)
2. Keep commits small and write a short PR description
3. The PR template contains a minimal test checklist (Build locally, Run tests, Lint)

Troubleshooting (most common issues)
- "No shared schemes found": ensure `*.xcodeproj/xcshareddata/xcschemes/*.xcscheme` files exist and are committed.
- "Signing error": ensure `DEVELOPMENT_TEAM` is present or choose Automatic signing in Xcode Cloud settings.
- "Dependency resolution" errors: ensure all Swift packages or local dependencies are resolvable by Xcode Cloud (consider vendoring or adding packages to `Package.swift`).

Helpful links
- Xcode Cloud docs: https://developer.apple.com/documentation/xcode-cloud
- Viewing Xcode Cloud logs: App Store Connect → Xcode Cloud → Activity → select run → Logs

If you want, I can 1) create a `ci/share-schemes` branch and push the shared scheme files (already present), 2) confirm signing team entries in `project.pbxproj`, and 3) open a PR to add this workflow doc and PR template. Say which of these you'd like me to do next.