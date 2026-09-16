# External Seal Experience — Successor Integration Handoff V0

**Object:** `DOJO.ExternalSealExperience`
**Artifact role:** Successor integration handoff
**Created:** 2026-08-07 (Australia/Melbourne)
**Status:** `DESIGN_REFINEMENT` · `HOLD.NOT_IMPLEMENTED_OR_VERIFIED`

## Predecessor anchors

This handoff folds forward from the completed design Weave reported in:

- `docs/OBSERVER_ALIGNED_ASSISTANCE_ONTOLOGY_V0.jsonl`
- `docs/OBSERVER_ALIGNED_ASSISTANCE_ATTRIBUTE_MAPPING_V0.md`
- `Sources/DOJOShared/Contracts/ObserverAlignedAssistanceOntology.swift`
- `scripts/validate_observer_aligned_assistance_ontology.py`
- `logs/state_patches/observer_aligned_assistance_ontology_seat_20260807T061558Z.json`

The predecessor ontology remains unchanged and retains:

- 32 parseable JSONL records;
- `HOLD.NOT_IMPLEMENTED_OR_VERIFIED` runtime status;
- `HYPOTHESIS.NOT_RUNTIME_EVIDENCE` for the fridge specimen; and
- separate camera scene, microphone intention input, and assistance output channels.

This handoff does not overwrite or retroactively expand the predecessor receipt.

---

## Refinement point

The External Orbiting Observer Seal must be embodied as a **separate construct**, not rendered as the final internal step of the workflow that designed or produced the object.

```text
Originating field
Observer → Architect → Weaver
              ↓
       immutable Seal Candidate
              ↓ boundary crossing
External Seal Experience
encounter → calibrate → manifest → compare → judge → return
```

The originating process may request a seal. It may not award, simulate, or modify its own seal result.

---

## Product purpose

Turn verification from manual forensic labour into a deliberate, observer-facing commissioning experience that:

1. identifies the exact physical and digital object;
2. makes hidden state perceptible;
3. invites one meaningful observer action;
4. independently compares declared and actual behaviour;
5. preserves disagreement and inability to verify;
6. establishes a durable physical–digital configuration epoch; and
7. requires recommissioning when a material attribute changes.

The design reference is Sonos-style participatory calibration: sound, movement, physical state, and guided pacing make the person a meaningful participant in commissioning. The ritual must collect or reveal evidence; decorative theatre cannot manufacture truth.

---

## Non-collapsed objects

| Object | Function |
|---|---|
| `OAWRun` | Produces an artifact, action, or handoff |
| `SealCandidate` | Immutable statement of declared outcome, expected manifestation, anchors, and known unknowns |
| `ExternalSealExperience` | Separately entered human-facing verification construct |
| `ParticipatoryCalibration` | Meaningful observer action that helps reveal correspondence |
| `ActualManifestation` | What is physically or digitally presented and measured |
| `SealJudgement` | Observer-grounded result: `VALID`, `INVALID`, `DELTA`, or `CANNOT_VERIFY` |
| `VerificationReceipt` | Evidence that declared and actual states were independently compared |
| `ArtifactReceipt` | Durable predecessor-linked record written after judgement |
| `ConfigurationEpoch` | Protected physical–digital baseline established by commissioning |
| `RecommissionRequest` | Bounded reopening caused by a material change or detected drift |

The following statements are invariants:

```text
opened ≠ read
read ≠ comprehended
comprehended ≠ affirmed
affirmed ≠ independently verified
verified ≠ sealed without required anchors
ritual ≠ evidence unless participation contributes to measurement or comparison
```

---

## External boundary contract

The External Seal Experience must have:

- a separate entry point from the originating workflow;
- an immutable input candidate;
- read-only access to the originating result;
- its own state machine and UI state;
- its own observer interaction;
- its own receipt output;
- no ability to modify the object to make it pass;
- no default assumption that originator evidence is sufficient; and
- an exact re-entry path when verification cannot complete.

It does not create a new FIELD chamber, registry, arbiter, or truth surface. It is a separate product construct over existing P11, King’s Chamber arbitration, lawful artifact homes, and Chronicle receipt paths.

---

## Seal Candidate contract

Minimum candidate fields:

```text
candidate_id
predecessor_run_id
subject_object_ids
declared_outcome
expected_manifestation
acceptance_criteria
forbidden_changes
evidence_anchor_pointers
known_unknowns
known_holds
originating_surface
originating_weaver
submitted_at
candidate_hash
```

After submission, mutation produces a new candidate linked to its predecessor. It does not alter the submitted candidate.

---

## Seven-stage commissioning ritual

### 1. Arrival

Announce that an object is ready to be checked. Do not announce completion.

```text
Ready for independent verification
```

### 2. Identification

Show the exact object, expected location, intended function, forbidden changes, and failure condition.

### 3. Declared state

Render the claim in ordinary language, with technical depth reachable on demand.

### 4. Participatory calibration

Invite one meaningful observer action that contributes to verification. Examples:

- hear and locate a channel-identification tone;
- perform one recognisable control interaction;
- move through the relevant physical area when environmental calibration is required;
- identify the expected physical object;
- compare reference and actual cue routes.

The action must be accessible, bounded, reversible, and relevant to the acceptance criterion.

### 5. Actual manifestation

Bring the thing being verified forward. The observer must not manually hunt through unrelated code, windows, logs, or receipts to find it.

### 6. Guided comparison and judgement

Present declared and actual states together. The human-facing choices are:

```text
MATCHES
DIFFERS
I CANNOT VERIFY THIS
```

Map them as follows:

```text
MATCHES              → VALID candidate, subject to required anchors
DIFFERS              → DELTA, or INVALID when an acceptance condition is contradicted
I CANNOT VERIFY THIS → CANNOT_VERIFY / intentionally_unsealed
```

### 7. Return

Emit one restrained completion state:

```text
SEALED
```

or:

```text
NOT SEALED
Missing: ...
Return point: ...
Resume condition: ...
```

---

## Sound and sensory calibration law

Sound may provide theatre, but it must also perform a verification function. An admitted calibration sound may:

- identify the selected output device;
- confirm left/right or spatial routing;
- establish safe perceptible volume;
- expose latency;
- demonstrate privacy or leakage boundaries;
- provide a reference cue for comparison; or
- confirm that the observer can perceive the assistance channel.

The system must preserve:

```text
audio input ≠ calibration stimulus ≠ assistance output ≠ observer acknowledgement
```

Participation may strengthen procedural trust and psychological ownership. It does not transfer authority or convert a mismatch into a pass.

---

## Configuration Epoch

A successful commissioning seal establishes a `ConfigurationEpoch` containing or pointing to:

```text
physical identity
digital identity
hardware and firmware state
channel map
execution host
human input surface
active environmental attention surface
permission state
authority ceilings
calibration results
observer judgement
evidence anchors
receipt pointer
sealed_at
predecessor_epoch_id_or_unknown
```

This epoch becomes the protected baseline against which later drift is measured.

---

## Material-change and recommissioning law

No material change beneath a commissioned physical–digital correspondence may silently inherit the predecessor seal.

Material changes include:

- hardware or firmware change;
- execution-host change;
- new vendor AI or model route;
- camera, microphone, speaker, haptic, or transport route change;
- permission expansion;
- retention or cloud-processing change;
- authority-ceiling expansion;
- materially different room or attention surface where calibration is context-dependent; or
- altered acceptance criteria.

Required transition:

```text
SEALED EPOCH
→ material change proposed or detected
→ CHANGE_PENDING / DELTA.ConfigurationChanged
→ predecessor preserved
→ authority reduced to the last safe witnessed ceiling
→ affected attributes recommissioned
→ new external judgement
→ successor epoch linked to predecessor
```

Emergency mute, disconnect, revocation, rollback, or fail-safe remains permitted. Such an action may protect the observer, but the affected commissioned state becomes unsealed until reverified.

---

## Relationship to device admission

`DeviceSurfaceAdmissionRoutine` and `ExternalSealExperience` remain separate:

```text
Device admission
→ decomposes device and bundled AI into channel-level evidence and decisions
→ produces a Seal Candidate when a bounded configuration is ready

External Seal Experience
→ independently commissions the claimed physical–digital correspondence
→ cannot edit the admission result
→ produces judgement, delta, receipt, and configuration epoch
```

A channel-level HOLD does not skip Observer, Architect, or Weaver work. It changes the produced handoff and required-next-evidence. The seal independently determines whether the declared HOLD and actual condition correspond.

---

## DOJO Suite integration targets

### Contract layer

Add predecessor-linked types under `Sources/DOJOShared/Contracts`:

```text
SealCandidate
ParticipatoryCalibrationPlan
ActualManifestation
SealJudgement
VerificationReceipt
ConfigurationEpoch
MaterialChangeDelta
RecommissionRequest
```

Do not extend the existing observer-assistance types by making them self-seal.

### Surface layer

Add a separately entered `External Seal Experience` surface. It must not be a card buried inside System Inspector, Proof, Settings, or the originating work object.

Supporting depth may link to:

- Proof for source anchors;
- System Inspector for system state;
- Review for declared-versus-actual comparison; and
- Chronicle for durable receipt pointers.

Those linked surfaces do not become the seal experience itself.

### Deterministic state machine

```text
candidateReceived
identified
declaredPresented
calibrationInProgress
actualManifested
comparisonReady
judgementRecorded
sealed | delta | intentionallyUnsealed
```

No transition may jump from `candidateReceived` directly to `sealed`.

### Validation

Add deterministic tests for:

1. originator cannot self-seal;
2. candidate is immutable after submission;
3. opening does not count as comprehension or verification;
4. calibration action is tied to an acceptance criterion;
5. mismatch produces DELTA or INVALID, never silent repair;
6. missing anchor produces intentionally unsealed with exact return point;
7. material change invalidates inheritance of the active seal;
8. predecessor epoch remains intact;
9. successor epoch links to predecessor; and
10. emergency fail-safe reduces authority without claiming reseal.

---

## Updated implementation boundary

| Layer | Current status |
|---|---|
| Observer-aligned ontology | `PRESERVE` · seated design specification |
| Attribute mapping and Swift stubs | `PRESERVE` · design-time implementation |
| Device capability handshake | `PARTIAL` · audio-specific paths witnessed |
| General device admission orchestrator | `HOLD.NOT_IMPLEMENTED` |
| External Seal Experience contract | `DESIGN_REFINEMENT` · this handoff |
| Participatory calibration runtime | `HOLD.NOT_IMPLEMENTED_OR_VERIFIED` |
| Configuration Epoch enforcement | `HOLD.NOT_IMPLEMENTED_OR_VERIFIED` |
| Material-change recommissioning | `HOLD.NOT_IMPLEMENTED_OR_VERIFIED` |
| Live physical–digital seal | `HOLD.NO_CONTROLLED_WITNESS` |

---

## Acceptance boundary for the next Weave

The next Weave is complete only when it produces:

1. the separate typed contracts above;
2. a deterministic, non-self-sealing state machine;
3. one static Seal Experience specimen;
4. one offline participatory-calibration fixture;
5. material-change/recommissioning tests;
6. an implementation receipt; and
7. an External Orbiting Observer Seal performed outside that Weave, or an exact `intentionally_unsealed` return record.

No camera, live audio, medical claim, vendor-AI integration, or irreversible configuration change is authorised by this handoff.

---

## Integration instruction

```text
Continue from the seated Observer-Aligned Assistance Ontology Weave.

Preserve the predecessor ontology, mapping, Swift stubs, validator, receipt, and runtime HOLD.

Integrate this successor refinement without collapse:
- External Seal Experience is a separate construct outside the originating OAW/device-admission workflow.
- The originator emits an immutable Seal Candidate and cannot self-seal.
- The observer enters a seven-stage participatory commissioning ritual.
- Calibration sound/movement must contribute to verification, not decorative persuasion.
- A valid seal establishes a predecessor-linked ConfigurationEpoch.
- Material change produces DELTA.ConfigurationChanged and requires bounded recommissioning.
- Opening, reading, comprehension, affirmation, verification, receipt, and seal remain distinct.
- Existing King’s Chamber, P11, Chronicle, Proof, Review, and System Inspector homes are reused; create no substitute registry, chamber, or truth surface.

Return: declared files changed, tests run, actual outcomes, deltas, receipt path, and a separately performed external seal or intentionally-unsealed recheck path.
```

## One-line lock

**The Weave produces the candidate; a separate participatory Seal Experience commissions physical–digital correspondence; the resulting epoch cannot silently survive material change.**
