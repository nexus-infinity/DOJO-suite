# External Seal Focus Lease and Return — Successor Handoff V0

**Attention/continuity stack pointer:** for DOJO Today work, use the pointer-only crosswalk in `docs/DIMENSIONAL_ATTENTION_LINEAGE_TO_PULSE_AND_ELIZA_HOMEFIELD_V0.md` § *Attention / continuity crosswalk* (Matrix → available∧OOO∧GST → zero_point → Focused Presence / focus vector / worker → Focus Lease → Capture/Channel Matrix → Today cartography). This handoff remains the Focus Lease home; do not re-derive the stack here.

**Object:** `DOJO.ExternalSealFocusLeaseAndReturn`
**Artifact role:** Successor integration handoff
**Created:** 2026-08-07 (Australia/Melbourne)
**Status:** `DESIGN_REFINEMENT` · `HOLD.NOT_IMPLEMENTED_OR_VERIFIED`

## Predecessor anchors

This refinement folds forward from, and does not overwrite:

- `docs/OBSERVER_ALIGNED_ASSISTANCE_ONTOLOGY_V0.jsonl`
- `docs/EXTERNAL_SEAL_EXPERIENCE_REFINEMENT_HANDOFF_V0.md`
- `docs/EXTERNAL_SEAL_EXPERIENCE_CONTRACT_V0.md`
- `Sources/DOJOShared/Contracts/ExternalSealExperienceContracts.swift`
- `Tests/DOJOSharedTests/ExternalSealExperienceTests.swift`
- `logs/state_patches/external_seal_experience_weave_receipt_20260807T063700Z.json`

The existing External Seal contracts and tests remain design-time evidence. This handoff does not claim a live focus controller, interruption gate, physical seal, or ConfigurationEpoch.

---

## Refined object

An External Seal Experience may request a bounded **Focus Lease** so the observer can complete one declared object without avoidable competition. The seal does not own global attention, pause arbitrary processes, or award itself authority.

```text
Seal Candidate
→ Focus Lease request
→ Attention Arbiter evaluates competing activity
→ Continuity Manager checkpoints lawful pause candidates
→ bounded single-object attention envelope
→ independent External Seal comparison and judgement
→ receipt
→ Continuity Manager restores suspended work and context
```

The experience should be allowed to consume the whole available surface when the user initiated a bounded, consequential commissioning or verification sequence. Full-screen presentation is a Level 3 attention claim, not decorative theatre and not proof by itself.

---

## Non-collapsed objects

| Object | Function | Authority boundary |
|---|---|---|
| `SealCandidate` | Immutable declared outcome awaiting external comparison | Cannot self-seal |
| `FocusLeaseRequest` | Requests bounded foreground attention for one object | Request only |
| `AttentionArbiter` | Classifies concurrent activity and returns one governed interruption decision | Reuses existing deterministic authority; not a new chamber |
| `InterruptionPolicy` | States whether an activity may be quieted, checkpointed, deferred, or must remain live | Registration does not prove current urgency |
| `ContinuityCheckpoint` | Preserves exact resumable state before suspension | Cannot imply task completion |
| `AttentionalCommissioningEnvelope` | Presents the bounded full-screen sequence | Surface claim only; geometry does not grant authority |
| `ExternalSealExperience` | Independently compares declared and actual outcomes | Read-only toward the originating result |
| `RestorationPlan` | Restores suspended objects in lawful order with continuity cues | Cannot silently discard or reorder work |
| `FocusLeaseReceipt` | Records what was foregrounded, protected, paused, restored, or left unresolved | Evidence record, not authority source |

The following remain distinct:

```text
priority label ≠ present non-interruptibility
pause ≠ cancel
checkpoint ≠ completion
quiet ≠ conceal
foreground attention ≠ exclusive authority
human affirmation ≠ machine verification
seal judgement ≠ originator claim
restoration ≠ starting over
```

---

## Deterministic interruption decision

Before the lease begins, every concurrent activity must resolve to exactly one disposition:

```text
PROTECT_LIVE       safety-critical, emergency, irreversible, or presently non-interruptible
ALLOW_THROUGH      bounded urgent cue permitted inside the envelope
CHECKPOINT_PAUSE   safely checkpointable and resumable
QUIET_DEFER        notification or optional work deferred without stopping underlying state
HOLD_UNKNOWN       insufficient evidence to pause, suppress, or classify
```

An activity marked `high priority` is not automatically protected or paused. The arbiter must evaluate current evidence, interruption policy, safety consequence, reversibility, expiry, and authority source.

If a competing executable truth remains unresolved, the lease does not silently choose. It returns `HOLD.FocusLeaseConflict` with the exact object, owner, required evidence, and recheck point.

---

## Focus Lease request packet

Minimum fields:

```text
lease_request_id
seal_candidate_id
foreground_object_id
purpose
requested_attention_level
requested_surface_scope
requested_channels
expected_duration_or_unknown
expiry
revocation_path
completion_criteria
concurrent_activity_snapshot
interruption_policy_pointers
known_unknowns
requested_at
```

The lease is invalid without an immediate exit or revocation path. Expiry returns the envelope to a safe unsealed state; it does not manufacture completion.

---

## Full-screen commissioning sequence

### Phase A — connect and configure

This phase may change system state under explicit authority.

1. **Identify** — exact physical device and digital identity.
2. **Connect** — transport, execution host, and current permission boundary.
3. **Discover channels** — separately enumerate sensing, input, output, storage, relay, and actuation.
4. **Declare authority** — show admitted capabilities, ceilings, unavailable channels, and vendor-AI boundaries.
5. **Test** — perform a reversible controlled probe.
6. **Participatory calibration** — ask the observer to perform one evidence-producing action.
7. **Experience the capability** — demonstrate the new bounded operating mode.

Then present a hard boundary:

```text
CONFIGURATION COMPLETE
The system will now begin an independent check.
```

### Phase B — external verification

This phase must be read-only toward the originating configuration result.

1. Show the immutable Seal Candidate.
2. Present expected and actual manifestation together.
3. Identify evidence coverage and any unsensed attribute.
4. Ask `MATCHES`, `DIFFERS`, or `I CANNOT VERIFY THIS`.
5. Emit `SEALED` or `NOT SEALED` with return point and resume condition.

The phases may share a calm full-screen envelope but must not share mutation authority.

---

## Safety and interruption law

The envelope must preserve:

- emergency calls, alarms, smoke or hazard signals, and registered safety processes;
- local physical mute, stop, escape, and revocation controls;
- one narrow escalation path for new urgent events;
- honest Level 3 or Level 4 presentation when interruption is warranted;
- accessible cues across admitted sight, hearing, or haptic channels; and
- a visible reason whenever attention is claimed or continuation is blocked.

Unverified inference, model preference, gaze estimate, emotion estimate, geometry, or decorative urgency may not independently protect, suppress, or interrupt another activity.

---

## Continuity and return law

Every paused object must carry:

```text
object_id
lawful_home
pre_pause_state
checkpoint_pointer
paused_at
pause_reason
dependencies
priority_and_source
expiry_or_recheck
resume_condition
resume_order
continuity_cue
restoration_result
```

After the seal exits, the Continuity Manager must:

1. preserve the seal outcome and receipt;
2. restore protected UI, task, model, terminal, audio, and notification states only as authorised;
3. resume objects in their recorded lawful order;
4. provide a restrained continuity cue such as `You were reviewing the microphone route`;
5. expose any item that could not be restored; and
6. never convert an interrupted or expired object into `complete`.

`Zero loss` therefore means preservation of object identity, state, provenance, authority, and return path. It does not mean every process continues running concurrently.

---

## Example — kitchen safety-sensitive object

```text
foreground object: pan on heat
attention mode: focused / safety-sensitive
PROTECT_LIVE: timer, smoke alarm, emergency call
ALLOW_THROUGH: one concise hazard cue
QUIET_DEFER: routine messages and unrelated model responses
CHECKPOINT_PAUSE: non-urgent document and conversation work
declared completion: heat off; food transferred; timer cleared
human judgement: MATCHES | DIFFERS | I CANNOT VERIFY THIS
machine evidence: only admitted appliance or sensor state
```

If machine evidence is unavailable, preserve separate states:

```text
human affirmation: witnessed
machine verification: unavailable
seal: intentionally_unsealed or partially evidenced
required recheck: direct observation or admitted sensor
```

---

## DOJO Suite integration targets

### Contract layer

Extend adjacent to, not inside, the existing External Seal types:

```text
ESEFocusLeaseRequest
ESEConcurrentActivitySnapshot
ESEInterruptionPolicy
ESEInterruptionDisposition
ESEContinuityCheckpoint
ESEAttentionalCommissioningEnvelope
ESERestorationPlan
ESEFocusLeaseReceipt
```

### Service layer

Introduce a deterministic coordinator that calls existing authority and continuity machinery. It must not become a new registry or truth surface.

### Surface layer

Provide:

- a bounded full-screen commissioning shell;
- persistent progress and escape controls;
- an honest protected-interruption lane;
- a visible Phase A / Phase B boundary;
- completion capability summary: available, unavailable, attention mode, seal time, proof pointer;
- `Try`, `View proof`, and `Done` exits; and
- a restrained restoration cue after return.

The shell is a phenotype. Screen size, aspect ratio, input method, accessibility settings, and surface role may change its placement without changing the underlying object relationships or authority pins.

### Deterministic validation

Add tests proving:

1. the seal requests but cannot award its own Focus Lease;
2. full-screen mode cannot begin without user initiation or lawful Level 3 evidence;
3. each concurrent activity receives one disposition;
4. safety-critical work remains live;
5. a `high priority` label alone cannot decide interruption;
6. unknown interruption policy fails closed;
7. pause creates a checkpoint and never marks completion;
8. urgent permitted cues can enter through the narrow gate;
9. Phase B cannot mutate Phase A configuration;
10. lease expiry produces a safe, unsealed return;
11. restoration retains object order, context, and provenance; and
12. failed restoration emits exact delta and recheck evidence.

---

## Next object — surface geometry refinement

The next design object is:

```text
DOJO.ObserverAlignedResponsiveSurfaceGeometry
```

It must study optimal graphic hierarchy, spacing, geometric placement, density, contrast, typography, motion, and progressive disclosure across screen and surface phenotypes without collapsing:

```text
semantic object
geometric representation
surface role
viewport and physical dimensions
human input surface
execution host
active environmental attention surface
attention mode
authority claim
accessibility state
```

The same genotype may manifest differently on a Mac display, laptop, tablet, glasses, CarPlay, or room display. Responsive rearrangement is allowed; semantic ownership, evidence status, attention claim, and authority are not inferred from placement.

Relevant comparison lenses include Claude's conversational spacing and progressive disclosure, ChatGPT's differentiated object rendering, and the denser tool-oriented grammars of Codex, Cursor, Visual Studio Code, and other editor surfaces. These are research references, not authority sources or instructions to clone a product.

---

## Acceptance boundary for the next Weave

The focus-lease Weave is complete only when it produces:

1. typed contracts for lease, interruption, checkpoint, restoration, and receipt;
2. a deterministic coordinator with no self-sealing path;
3. one static full-screen commissioning specimen;
4. one desktop-development fixture and one kitchen safety fixture;
5. interruption, expiry, and restoration tests;
6. an implementation receipt; and
7. a separate External Orbiting Observer Seal or an exact `intentionally_unsealed` return record.

No live process suspension, notification suppression, application closure, device change, camera, microphone, safety claim, or destructive action is authorised by this handoff.

## One-line lock

**The seal may request a bounded Focus Lease; deterministic attention authority protects or pauses each object; independent verification judges completion; continuity restores every suspended object without loss.**
