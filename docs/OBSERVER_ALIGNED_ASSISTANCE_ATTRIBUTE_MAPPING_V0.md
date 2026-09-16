# Observer-Aligned Assistance — DOJO Suite Attribute Mapping V0

**Source ontology:** `docs/OBSERVER_ALIGNED_ASSISTANCE_ONTOLOGY_V0.jsonl` (32 records, Kodex handoff)
**Ontology status:** `HOLD.NOT_IMPLEMENTED_OR_VERIFIED`
**Specimen status:** `HYPOTHESIS.NOT_RUNTIME_EVIDENCE`
**This document:** design/contract attribute mapping only — **not** runtime promotion

**Action class:** `PRESERVE` ontology · **Weaver seat:** mapping + typed stubs · **Runtime:** HOLD

---

## Product law (from ontology)

```text
Observer ≠ device ≠ chamber ≠ model
Camera scene ≠ microphone intention ≠ audio assistance output
Geometry orients · never grants authority
Intention requires explicit evidence · not scene alone
Assistance fits attention ceiling
Consent is scoped · revocable · not blanket
Unknown and HOLD remain valid
No medical / cognitive efficacy claims
```

---

## 1. Six alignment axes → DOJO / FIELD homes

| Axis | Ontology question (short) | Maps into DOJO Suite / FIELD |
|------|---------------------------|------------------------------|
| **geometric** | Where are observer, object, sensors, hosts relative? | Surface presence pins · Aikido Optics · camera frame IDs · Voice device geometry (not authority) |
| **semantic** | What bounded meaning is supported? | ObservationEvent.semantic · Cue content · never auto-intention |
| **temporal** | When, order, expiry? | LIVE/DELAYED/STALE/UNTRUSTED · intention `valid_until` · cue expiry |
| **epistemic** | Witnessed vs inferred vs unknown? | Witnessed / Attributed / Hypothesis / Unknown · Kings-Chamber validity filter kinship |
| **authority** | What may sense / cue / act now? | AuthorityGate · OBSERVE_ONLY → CUE_PERMITTED · Explicit confirm · HOLD |
| **provenance** | What source backs each claim? | ReceiptPointer · Proof drawer · SealedVoice hash · smoke receipts |

---

## 2. Twelve classes → suite attribute map

| Class | Role | DOJO / FIELD attribute homes | Runtime today |
|-------|------|------------------------------|---------------|
| **Observer** | Organic person | Operator profile · consent profile · not Apple ID alone | Partial (account label) |
| **ObservationEvent** | Bounded witness event | Future observation store · Observer data paths | HOLD |
| **EnvironmentScene** | Outward scene (e.g. fridge) | Camera sensing channel · derived features only by default | HOLD (no live camera) |
| **HumanIntention** | Explicit / pinned / confirmed intent | Composer mode · Voice intention input · not STT alone | Partial (composer text) |
| **AttentionContext** | Attention ceiling / mode | Multi-surface layout law · CarPlay voice-primary · attention modes | Partial (surface matrix) |
| **SurfacePresence** | Input · execution · env attention pins | `AIKIDO_OPTICS_SURFACE_PRESENCE_RULE_V0` · Connector Mandela surfaces | Spec seated · runtime partial |
| **SensingChannel** | Admitted evidence in | Voice & capture · camera (future) · connectors · `modality` typed | Mic channel Mac partial |
| **AssistanceChannel** | Bounded support out | Cue audio · haptic · glance · silence · **separate from sensing** | HOLD (cues not shipped) |
| **CueCandidate** | Reversible min cue | Cue levels silence→conversation · fridge specimen | Specimen only |
| **AuthorityGate** | PROMOTE / HOLD / DEMOTE | Kings-Chamber arbiter kinship · gate on cue delivery | HOLD for assistance path |
| **ConsentGrant** | Scoped permission | Consent UX (not built) · TCC ≠ full consent | HOLD |
| **ReceiptPointer** | Evidence pointer | Proof drawer · Application Support receipts | Partial (objects, smoke) |

---

## 3. Sensing vs assistance (non-collapse)

| Direction | Ontology | DOJO Settings / pipeline |
|-----------|----------|---------------------------|
| **In** | `SensingChannel` · `microphone_intention_input` · `camera_scene` | Voice & capture mic · future camera · never same object as speakers |
| **Out** | `AssistanceChannel` · `spoken_audio` · `earcon` · `haptic` | Speakers / cue channel · Watch haptic · **typed separately** |

Even one wearable with mic + speaker = **two channels** in the model.

Voice pipeline (existing):

```text
mic (SensingChannel)
→ Murmur / SealedVoice packet
→ Hermen dock (surface handoff)
→ translator (optional text)
→ work object
→ optional CueCandidate (AssistanceChannel) only after AuthorityGate
```

---

## 4. Constraints → failure HOLDs (blocking)

| Constraint | Failure state | Suite implication |
|------------|---------------|-------------------|
| Core layers non-collapse | `HOLD.SurfaceOrAuthorityCollapse` | Inspector/Details/Proof stay separate |
| Geometry no authority | `HOLD.GeometryAuthorityOverreach` | Aikido Optics / scene match orient only |
| Restrained attention | `HOLD.AttentionCeilingExceeded` | CarPlay/physical_task cue density |
| Minimum retention | `HOLD.RetentionAuthorityMissing` | Raw media ephemeral by default |
| Medical claim boundary | `HOLD.MedicalClaimUnsupported` | Continuity cues ≠ diagnosis |

---

## 5. Relations (implementation order later)

1. Observer **witnesses** scene through sensing channel
2. Observation **aligned_to** observer (geo/sem/temp/epistemic)
3. Intention **precedes** observation (not automatic causality)
4. Attention **constrains** assistance channel
5. Cue **derived_from** observations (+ intention when present)
6. Human **confirms_or_rejects** intention / cue

---

## 6. Fridge continuity specimen (hypothesis only)

| Pin | Value |
|-----|--------|
| Intention | “retrieve milk for dinner” (EXPRESSED, 5 min window) |
| Observation | fridge door open (Hypothesis scene match) |
| Attention | physical_task · ceiling two_or_three_words |
| Gate | PROMOTE cue once · forbid diagnose/repeat/retain raw/third-party |
| Cue | “Milk for dinner” · CUE_PERMITTED · expires with window |

**Not runtime evidence.** Labels remain `HYPOTHESIS.NOT_RUNTIME_EVIDENCE`.

---

## 7. Acceptance contract (from handoff) — status

| Check | Status after this seat |
|-------|------------------------|
| Every line parses as JSON | **PASS** (revalidated) |
| Runtime-like examples labelled design_specimen | **PASS** |
| Axes present on ObservationEvent model | **PASS** (typed stubs) |
| Intention not from geometry alone | **PASS** (constraint + gate rules in types) |
| Audio in/out separately typed | **PASS** (Sensing vs Assistance enums) |
| Attention ceiling constrains cues | **PASS** (AttentionContext model) |
| Unknown/HOLD valid | **PASS** |
| Timezone-aware timestamps in specimen | **PASS** |
| No raw retention assumed | **PASS** |
| No runtime/medical/zero-loss efficacy claim | **PASS** (status holds) |

| Implementation gate item | Status |
|--------------------------|--------|
| Typed application contract | **This mapping + Swift stubs** (design) |
| Consent UX | **HOLD** |
| Local retention test | **HOLD** |
| Restrained-attention test | **HOLD** |
| Rejection path | **HOLD** (types allow REJECTED) |
| Receipt | **This mapping receipt** (design) |
| External observer seal | **HOLD** until human seal of mapping |

**Overall runtime:** still `HOLD.NOT_IMPLEMENTED_OR_VERIFIED`.

---

## 8. Next bounded runtime steps (not done here)

1. ConsentGrant UX (scoped mic/camera/cue)
2. AuthorityGate before any AssistanceChannel emit
3. CueCandidate delivery test (silence → 2–3 words) with rejection
4. Retention timer on EnvironmentScene features
5. External orbit seal of one dry-run specimen path

---

## One line

**Observations align to the observer across six axes; cues stay low-density and gated; camera, intention-mic, and assistance-audio never collapse — ontology preserved, runtime still HOLD.**
