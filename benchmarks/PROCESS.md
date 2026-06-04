# Benchmark Process — DOJO Suite × Claude Mac Application

## Four surfaces

| ID | Surface | Mode | Server required |
|----|---------|------|----------------|
| B1 | DOJOApp screenshot → Claude | image_ui | No |
| B2 | Claude Chat tab — context reasoning | text | No |
| B3 | Claude Cowork tab — task execution | task | No |
| B4 | Claude Chat + Desktop Commander → DOJO MCP | tool_call | Yes (port 7410) |

---

## Universal process: Build → Evaluate → Test

### BUILD
For each surface:
1. Confirm prerequisites (screenshot captured / server running / extension enabled)
2. Copy the canonical prompt from the packet `tasks` block
3. Open the correct Claude desktop tab

### EVALUATE
1. Submit the canonical prompt verbatim — no paraphrasing
2. Record verbatim response in the packet `response` field
3. Note latency if measurable
4. Screenshot the exchange and place in `benchmarks/screenshots/`

### TEST (score each dimension 1–5)

| Score | Meaning |
|-------|---------|
| 5 | Exact, complete, no errors |
| 4 | Correct with minor omission |
| 3 | Partially correct |
| 2 | Mostly wrong but on-topic |
| 1 | Hallucination or off-topic |

Set `tata_validation.triangle_status`:
- `resolved` if overall ≥ 3.5
- `unresolved` if overall < 3.5

Set `routing.tata_gate`:
- `pass` if triangle_status = resolved
- `fail` otherwise

---

## B1 — DOJOApp screenshot interpretation
**Status**: COMPLETE (score 4.7/5) → `packets/test_001.json`

---

## B2 — Claude Chat tab: FIELD context reasoning
**Prerequisites**: Claude desktop open on Chat tab. No server needed.

**Canonical prompts** (submit as one message):
```
You are operating within the FIELD system. Without searching or using tools, answer from memory:

1. Name all 7 FIELD chambers with their symbols and frequencies.
2. Which chamber is the deterministic infrastructure and translation bridge?
3. BEAR score is 0.75 — what does this indicate about system coherence?
4. A chamber shows state: false in /state response. What is its NodeHealthStatus?
```

**Score dimensions**: field_knowledge, chamber_accuracy, bear_interpretation, status_mapping

---

## B3 — Claude Cowork tab: DOJO operational task
**Prerequisites**: Claude desktop open on Cowork tab, "Work in a project" selected.

**Canonical prompt**:
```
Project: DOJO-suite at /Users/field/DOJO-suite

Task: All 7 FIELD chambers should be operational. Currently BEAR is 0.75 and 0/7 chambers are reporting alive in the ChamberRail. Produce a prioritised action plan (max 5 items) to get chambers online and benchmarkable. Reference specific files or ports where relevant.
```

**Score dimensions**: task_understanding, field_accuracy, actionability, file_specificity

---

## B4 — Desktop Commander → DOJO MCP (port 7410)
**Prerequisites**: Desktop Commander extension enabled in Claude desktop. DOJO spinning top server running at localhost:7410.

**Canonical prompt**:
```
Use Desktop Commander to run this exact command and report the full output:

curl -s http://localhost:7410/state

Then answer:
1. What is the coherence (BEAR) value?
2. How many nodes are reporting state: true?
3. Which specific chambers are alive?
```

**Score dimensions**: tool_invocation, data_accuracy, chamber_identification, interpretation

---

## Scoreboard columns
All results append to `scoreboards/outcome_009_ui_interpretation.csv`:
```
entry_id, ts, platform, model, input_type, dim1_1_5, dim2_1_5, dim3_1_5, dim4_1_5, overall_1_5, validation_status, notes
```

## Regression rule
If a surface scores lower than its previous run, set `regression_flag = true` in the scoreboard row.
