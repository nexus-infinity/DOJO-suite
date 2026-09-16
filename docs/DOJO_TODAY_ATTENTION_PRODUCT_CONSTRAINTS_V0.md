# DOJO Today — Attention Product Constraints V0

**Status:** `SEATED.PRODUCT_RULES`
**Not:** new ontology · main-screen doctrine · cognitive-benefit claim · attention-maximising design
**Use:** plain product rules and testable gates for the Today shell
**Stack reference:** attention/continuity crosswalk in `DIMENSIONAL_ATTENTION_LINEAGE_TO_PULSE_AND_ELIZA_HOMEFIELD_V0.md`

---

## Research → product (not more abstraction)

```text
Research → practical constraints → M1 working app loop
```

Not:

```text
Research → more ontology → more abstraction → no app
```

**Line:** Use the attention research to **constrain** the interface. Do not let it become the interface.

---

## What research does / does not justify

| Justifies | Does not justify |
|-----------|------------------|
| Orient → Engage → Sustain → Release → Recover | Universal attention span |
| Conserve attention | Fixed timer law |
| Motion only when necessary | Constant animation |
| Prefer task-boundary interruption | Attention-maximising design |
| Preserve recovery cues | Colour/motion as authority |
| Measure outcomes before claiming benefit | Medical/cognitive benefit claim |

---

## Phase rules (product)

### 1. Orient
Help the person understand where they are.
Use: stable layout, clear current object, low-noise contrast, one obvious input/action, left navigation, calm centre.
Avoid: dashboard cards everywhere, pulsing decoration, competing signals, unexplained symbolic surfaces.

### 2. Engage
Let the person start work.
Use: persistent composer, selected object in centre, model/action controls, clear submit/send, output as object.
Avoid: forcing system inspection; settings/proof/debug on the primary work path.

### 3. Sustain
Reduce load while work continues.
Use: stable object space, right utility only when useful, minimal state changes, no repeated animation, no unnecessary panel transitions.
Avoid: motion to keep things “alive”, attention-grabbing status effects, arbitrary timers.

### 4. Release
Mark a natural boundary (response received, saved, decision, file change, closed, pause, external wait).
Offer: review · save/export · continue · close/recover.

### 5. Recover
Return after interruption. A recovery cue should carry:

```text
Object:
Last stable point:
Unfinished intention:
Next action:
Changed while away:
```

Not only: “You were working on X.”

---

## Ontology placement

`OBSERVER_ALIGNED_ASSISTANCE_ONTOLOGY_V0.jsonl` stays in **contract / inspector / under-the-hood** — not main UI.

Product safety gates (not main-screen content):

```text
Geometry may orient, but not authorize.
Scene meaning is not human intention.
Human intention needs explicit evidence.
Attention ceiling controls cue density.
Consent to sensing is not consent to retention/inference/action.
Raw sensory retention is not assumed.
No medical or cognitive efficacy claim.
```

---

## Pre-cue checklist (implementation gate)

Before any cue, animation, colour, right-panel reveal, notification, or assistant suggestion:

1. What phase? Orient / Engage / Sustain / Release / Recover
2. Is this signal necessary now?
3. Is the user at a task boundary?
4. Is motion required, or would stillness work?
5. What object is preserved?
6. What is the next action?
7. What authority? Observe only / cue / suggestion / confirmation required / HOLD
8. What is the recovery path?
9. Are we implying consent, truth, diagnosis, or authority by accident?

---

## Implemented behaviours (this pass)

### A. No decorative motion
Stillness by default. Motion only for send/loading/result/error or explicitly time-critical condition. Single transition allowed on lawful panel open/close.

### B. Boundary-aware reveal
Right panel opens when: object selected · result generated · user asks for review/details.
Does not keep unfolding because it exists.

### C. Recovery metadata on generated objects
Every answer stores: source prompt · provider/model · created time · last stable point · next available action · changed while away.
Details tab shows this plainly.

### Do not
- Claim cognitive benefit
- Expose observer ontology on the main screen
- Block M1 loop for more attention doctrine

---

## M1 loop (supported, not delayed)

```text
composer → hosted model API → Answer object → details → save/export/continue
```

---

## One line

**Use the attention research to constrain the interface. Do not let it become the interface.**
