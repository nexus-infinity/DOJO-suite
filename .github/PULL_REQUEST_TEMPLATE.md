## Summary
Provide a short description of the change (1-2 sentences).

## Related Issue
Link any issue or task (e.g., #123) or write `None`.

## Changes
- Bullet list of the main changes made

## How to test
1. Pull this branch
2. Open the Xcode workspace
3. Select scheme: `DOJOSuite-All` (or `DOJOiOSApp`) and run Build
4. Run unit tests: Product → Test

## Checklist
- [ ] Builds locally (Xcode)
- [ ] All unit tests pass
- [ ] Linted (swiftformat / swiftlint) or note why skipped
- [ ] Shared schemes committed (`*.xcodeproj/xcshareddata/xcschemes`)
- [ ] No sensitive info committed

## Reviewer notes
Add anything a reviewer should watch for (performance, API changes, UX). 

--
If CI is failing, check the Xcode Cloud run logs (App Store Connect → Xcode Cloud → Activity). If signing fails, ensure the project has a `DEVELOPMENT_TEAM` set and schemes are shared.