# DOJO Suite pipeline convergence — 2026-09-17

**Decision:** `PROMOTE.BOUNDED_IMPLEMENTATION` with explicit external-runtime `HOLD`s.

This record closes the accumulated local development surface into one reviewable repository state. A passing build or unit test is evidence for the bounded implementation only; it is not evidence for unavailable devices, external services, human visual judgement, sovereign authority, or production maturity.

## Geometric summary

| Plane | Current state | Evidence | Boundary |
|---|---|---|---|
| Source and project graph | `IMPLEMENTED` | All eight shared Xcode schemes build successfully | Checked-in XcodeGen source graph |
| Shared contracts and policies | `IMPLEMENTED` | Compiled by Xcode; covered by the active test plan | Runtime adoption remains contract-specific |
| DOJO Today native surface | `IMPLEMENTED · PARTIAL RUNTIME WITNESS` | Builds with the macOS application; existing state-patch receipts retained | Comparative visual parity, voice, streaming, external seal, and successful portal inference remain `HOLD` where named in their contracts |
| Arkadaş, HAL, transport, persistence, and route admission | `IMPLEMENTED` with bounded live seams | Deterministic tests pass; live dependencies fail closed | King’s Chamber and bounded live fixtures are optional external witnesses |
| Geometrical Particle Board and projection surfaces | `IMPLEMENTED · SPECIMEN` | Source, tests, and visual evidence contracts are present | Product maturity and external visual equivalence remain `HOLD` |
| Web surface | `IMPLEMENTED` | TypeScript type-check passes | Deployment and live connector claims remain outside this receipt |
| Observer-aligned assistance ontology | `VALIDATED · DESIGN SPECIMEN` | Validator passes 32 physical JSONL records | `HOLD.NOT_IMPLEMENTED_OR_VERIFIED` for runtime sensing/assistance, consent UX, efficacy, and authority |
| External and physical channels | `HOLD` unless separately witnessed | Existing CarPlay, landscape, Bluetooth, readiness, external-seal, and MCP contracts preserve named proof gates | No absent entitlement, device, service, or observer receipt is inferred |

## Verification receipt

- Xcode builds: `PASS` for DOJOApp, ArkadasApp, DOJOiOSApp, DojoLinkApp, OB1LinkApp, DOJOShared, DOJOUI, and DOJOPersistence.
- Xcode active test plan: `415 total · 401 passed · 0 failed · 14 skipped`.
- Web TypeScript and production build: `PASS`.
- Observer-aligned ontology validation: `PASS · 32 records`.
- SwiftPM CLI in the managed assistant environment: `HOLD.ToolingSandbox`; SwiftPM could not initialize its nested sandbox. Xcode compiled the same source graph and ran the active test plan successfully.

## Intentional test HOLDs

The skipped set is explicit rather than silently green:

- Eight legacy compatibility test names remain skipped because their removed stub types no longer exist.
- Two Cockpit live replays require `FIELD_LIVE_COCKPIT_REPLAY=1` and the bounded external service.
- One inert-authority live fixture requires `FIELD_LIVE_INERT_AUTHORITY=1`.
- Three route-admission integration witnesses require a currently valid King’s Chamber receipt/verifier; unavailable authority is represented as `HOLD`, never as a failed local implementation or invented admission.

## Pipeline corrections in this convergence

- The release build script now builds the complete current Swift package and no longer suppresses executable failures or names the retired `ArkadašApp` product.
- The test script runs Swift tests, ontology validation, and the web type-check when web dependencies are provisioned.
- The TypeScript authority-boundary fixture uses a portable module import.
- Live route-admission tests now distinguish unavailable external authority from deterministic local failure.
- Generated Xcode runtime directories and profiling residue are ignored and removed from the development surface.

## Preserved HOLD boundary

Anything already marked `HOLD`, `Unknown`, `PARTIAL`, proposal, specimen, or unverified in the checked-in contracts remains in that state unless a specific receipt in this repository promotes it. This convergence does not collapse design documents into runtime claims and does not treat screenshots, local availability, or model output as sovereign authority.

## Next bounded work

1. Provision King’s Chamber and issue fresh correlated route-admission receipts, then rerun the three live integration witnesses.
2. Run the opt-in Cockpit and inert-authority fixtures in their controlled environments.
3. Run `Scripts/test_all.sh` in a normal terminal environment where SwiftPM sandboxing is available.
4. Promote individual visual, device, connector, and external-observer HOLDs only with their named receipts.
