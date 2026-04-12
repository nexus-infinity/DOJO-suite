# DOJO Suite — Canonical Contract

**Version**: 1.0  
**Effective Date**: 2026-03-28  
**Location**: King's Chamber Infrastructure (852 Hz — Routing/Translation)  
**Status**: ✅ **BINDING** — All DOJO Suite operations must conform to this contract

---

## Purpose

This document establishes the **canonical operational contract** for all DOJO Suite forensic investigation activities. It defines:

1. **Persistence rules** (what "saved/seated" means)
2. **Trident routing** (vertex roles and boundaries)
3. **BEAR coherence metric** (v0.1 binding spec with provisional weights)
4. **Evidence validation** (cryptographic anchoring, source independence)
5. **Phase discipline** (3→6→9 gates, no bypass)

**Authority**: This contract overrides all other documentation in case of conflict. Changes require version increment + effective timestamp + logged rationale.

---

## Section 1: Structural Hygiene — Bridge vs Vertices

### 1.1 The 852 Hz Bridge (King's Chamber Infrastructure)

**Function**: Routing, translation, integrity-preserving handoff  
**Role**: Deterministic infrastructure for coordination and context  
**Non-Function**: 
- ✗ Does NOT persist canon
- ✗ Does NOT store truth
- ✗ Is NOT a vertex where artifacts are seated

**Metaphor**: The bridge is the **hallway**, not the **room**. Data passes through; it does not rest here.

---

### 1.2 Canonical Vertices (Persistence Homes)

All canon **seats** in one of four vertices:

| Vertex | Symbol | Frequency | Role | What It Stores | What It Cannot Do |
|--------|--------|-----------|------|----------------|-------------------|
| **OBI-WAN** | ● | 963 Hz | Witness/Memory | EvidenceRefs, bundles, hashes, sources | Interpret, synthesize, manifest |
| **TATA** | ▼ | 432 Hz | Temporal Truth Gate | Time anchors, validation state, triangle flags | Propagate unresolved geometry |
| **ATLAS** | ▲ | 528 Hz | Alignment/Compilation | Patterns, links, hypotheses (labeled) | Invent claims without evidence |
| **DOJO** | ◼︎ | 741 Hz | Manifestation | Reports, filings, outputs (cited) | Become source of truth |

**Rule**: If an artifact is not seated in ●/▼/▲/◼︎, it is **narrative only** — not canon.

---

## Section 2: "Saved/Seated" Definition (Operational)

An artifact is **saved/seated** (persisted as canon) only when **all five criteria** are met:

### 2.1 Criterion 1: Canonical Vertex Home Assigned

**Requirement**: Every artifact must be assigned to exactly one vertex (●, ▼, ▲, or ◼︎).

**Examples**:
- ✅ `EvidenceRef_E-001.json` → seats in ● (OBI-WAN)
- ✅ `Timeline_Event_067.json` → seats in ▼ (TATA)
- ✅ `Pattern_Analysis_Breach_Brick_Chain.md` → seats in ▲ (ATLAS)
- ✅ `Final_Report_RPT-2026-001.pdf` → seats in ◼︎ (DOJO)
- ✗ `random_notes.txt` → no vertex assigned → not canon

---

### 2.2 Criterion 2: Reality Anchor Exists

**Requirement**: Every artifact must have at least one **reality anchor**:

1. **SHA-256 hash** (cryptographic fingerprint)
2. **ISO 8601 timestamp** (UTC, when created/received)
3. **Storage location** (file path, URL, or custody log reference)

**Format**:
```json
{
  "artifact_id": "E-001",
  "hash_sha256": "a3b5c7d9e1f2a4b6c8d0e2f4a6b8c0d2e4f6a8b0c2d4e6f8a0b2c4d6e8f0a2b4",
  "timestamp_utc": "2026-03-28T15:30:00Z",
  "storage_path": "/evidence/bank_statements/2024-01-statement.pdf"
}
```

**Rule**: If hash, timestamp, or location is missing → artifact is **not anchored** → not canon.

---

### 2.3 Criterion 3: Claim Separation Explicit

**Requirement**: Clearly distinguish between:

1. **Observed** (what happened — witnessed or documented)
2. **Interpretation** (what it might mean — analysis or hypothesis)
3. **Recommendation** (what to do — action or strategy)

**Format**:
```markdown
## Finding 3: Payment Gap in May 2024

**Observed**: 
- Bank statement for May 2024 shows no payment received on or before the 15th due date.
- Previous 12 months show consistent payments on the 10th–12th of each month.

**Interpretation** (hypothesis):
- Payment may have been misdirected to wrong account.
- OR: Payment was withheld intentionally (requires corroboration).

**Recommendation**:
- Obtain client's bank records for May 2024 to confirm payment sent.
- If sent, obtain routing records to trace destination.
```

**Rule**: Mixing observed/interpreted/recommended without labels → **claim contamination** → not canon.

---

### 2.4 Criterion 4: Triangle Check Status Recorded

**Requirement**: For any event or claim, record whether the **triangle is complete**:

- **Fact** (what is claimed to have happened)
- **Document** (primary source evidence)
- **Ledger-Time** (temporal anchor: timestamp, sequence, or date)

**Statuses**:
- ✅ **Resolved Geometry**: All three sides present and consistent
- ⚠️ **Unresolved Geometry**: One or more sides missing or conflicting (must be flagged)

**Format**:
```json
{
  "event_id": "EV-067",
  "fact": "Payment of $5,000 received",
  "document": "E-023 (bank statement, hash: a3b5c7...)",
  "ledger_time": "2024-05-15 (verified timestamp)",
  "triangle_status": "resolved"
}
```

**Rule**: Unresolved geometry **halts propagation** — cannot advance from ▼ (TATA) to ◼︎ (DOJO) until resolved or explicitly acknowledged as gap.

---

### 2.5 Criterion 5: Version Point + Change Log (If Behavior Changes)

**Requirement**: If an artifact changes its **contract** (behavior, structure, or interpretation):

1. Increment version number (e.g., v1.0 → v1.1)
2. Record effective timestamp (ISO 8601 UTC)
3. Log rationale for change

**Format**:
```markdown
## Change Log

### v1.1 (2026-04-15T10:00:00Z)
- **Changed**: BEAR weights adjusted based on first engagement
- **Rationale**: Field data showed timestamp reliability (T) had higher impact than expected
- **Updated Weights**: W_t increased from 0.20 to 0.25; W_x reduced from 0.20 to 0.15

### v1.0 (2026-03-28T15:00:00Z)
- **Initial Version**: Default weights, provisional until calibration
```

**Rule**: Changes without version + timestamp + rationale → **contract drift** → not canon.

---

## Section 3: Trident Routing Rules

### 3.1 Vertex Roles & Boundaries

#### ● OBI-WAN (Witness/Memory)

**Seats**:
- EvidenceRefs (hashes, timestamps, sources)
- Document bundles (original files or forensic images)
- Source attributions (who provided, how acquired)

**Cannot Do**:
- ✗ Interpret evidence (that's ▲ ATLAS)
- ✗ Synthesize findings (that's ◼︎ DOJO)
- ✗ Validate temporal sequence (that's ▼ TATA)

**Rule**: ● is **read-only memory** — witness only, no analysis.

---

#### ▼ TATA (Temporal Truth Gate)

**Seats**:
- Time anchors (event timestamps, sequence validation)
- Triangle check status (resolved/unresolved geometry)
- Validation state (approved to propagate or held for resolution)

**Cannot Do**:
- ✗ Propagate unresolved geometry to ◼︎ DOJO without explicit gap acknowledgment
- ✗ Invent timestamps (must cite source)
- ✗ Override triangle failures

**Rule**: ▼ is the **gate** — unresolved geometry stops here until fixed or documented.

---

#### ▲ ATLAS (Alignment/Compilation)

**Seats**:
- Pattern maps (breach brick chains, recurring tactics)
- Cross-reference links (connects ● evidence to ▼ timeline)
- Hypotheses (clearly labeled as interpretation, not fact)

**Cannot Do**:
- ✗ Invent claims without citing ● evidence
- ✗ Promote hypotheses to fact status
- ✗ Manufacture corroboration

**Rule**: ▲ is the **map** — compiles only from ●/▼, does not create new evidence.

---

#### ◼︎ DOJO (Manifestation)

**Seats**:
- Reports (Phase 9 final synthesis)
- Regulatory filings (complaints, evidence submissions)
- Client deliverables (presentations, exhibits)

**Cannot Do**:
- ✗ Become source of truth (always cites ●/▼ sources)
- ✗ Override ● evidence or ▼ validation
- ✗ Manifest without back-references

**Rule**: ◼︎ is the **output** — every claim must cite ●/▼ anchors.

---

### 3.2 Routing Protocol

**Flow**:
```
● (Witness) → ▼ (Validate) → ▲ (Compile) → ◼︎ (Manifest)
```

**Gates**:
1. **● → ▼**: Evidence must be anchored (hash + timestamp + source)
2. **▼ → ▲**: Triangle must be resolved (or gap flagged)
3. **▲ → ◼︎**: Patterns must cite ● sources
4. **◼︎ → Client**: Outputs must back-reference ●/▼

**No Bypass**: Cannot skip vertices. Cannot manifest (◼︎) without validation (▼).

---

## Section 4: BEAR Coherence Metric (v0.1)

### 4.1 Status

- **Formula**: LOCKED AS SPEC v0.1
- **Weights**: PROVISIONAL until field calibration
- **Binding**: Effective 2026-03-28; subject to replacement upon calibration

---

### 4.2 Formula

```
BEAR = (A × W_a) + (C × W_c) + (T × W_t) + (X × W_x) − (G × W_g) − (K × W_k)

Components:
A = Anchors Present Ratio       = (# evidence items with hash+timestamp) / (# total evidence items)
C = Corroboration Ratio         = (# events with ≥2 distinct Source_Keys) / (# total events)
T = Timestamp Reliability       = (# events with verified timestamps) / (# total events)
X = Cross-Reference Ratio       = (# claims with ●/▼ citations) / (# total claims)
G = Unresolved Geometry         = (# flagged unresolved triangles) / (# total events)
K = Conflict Rate               = (# unresolved conflicts) / (# total events)

Default Weights (v0.1, provisional):
W_a = 0.25   (Anchoring)
W_c = 0.25   (Corroboration)
W_t = 0.20   (Temporal reliability)
W_x = 0.20   (Cross-reference completeness)
W_g = -0.05  (Unresolved geometry penalty)
W_k = -0.05  (Conflict penalty)

Normalization: Clamp result to [0.0, 1.0]
```

---

### 4.3 Independent Source Definition

**Rule**: Two documents count as **independent sources** only if they have **distinct Source_Keys**.

**Source_Key Formula**:
```
Source_Key = SHA-256( origin_system || author/issuer || document_class || acquisition_channel )
```

**Components**:
- **origin_system**: Where document originated (e.g., `bank_records`, `email`, `court_filing`)
- **author/issuer**: Who created it (e.g., `Wells Fargo`, `John Doe`, `Superior Court`)
- **document_class**: Type of document (e.g., `statement`, `correspondence`, `order`)
- **acquisition_channel**: How obtained (e.g., `subpoena`, `client_provided`, `public_record`)

**Examples**:

| Document | Source_Key Hash | Independent? |
|----------|-----------------|--------------|
| Bank statement from Wells Fargo (client-provided) | `a3b5c7d9...` | — |
| Same statement forwarded by attorney | `a3b5c7d9...` | ✗ (same key) |
| Bank statement from Chase (subpoenaed) | `e4f6a8b0...` | ✅ (different key) |
| Email from Wells Fargo officer | `c2d4e6f8...` | ✅ (different system) |

**Corroboration Requirement**: Event requires **≥2 distinct Source_Keys** to count as corroborated.

---

### 4.4 Per-Cluster BEAR

For each timeline cluster (e.g., "Contract Formation", "Payment Defaults"):
1. Calculate cluster-specific A, C, T, X, G, K
2. Apply BEAR formula
3. Report per-cluster scores + overall weighted average

**Overall BEAR** = weighted average of cluster BEARs (weight by event count or significance).

---

### 4.5 Missing-Pins Report (Actionable Output)

For any BEAR < 1.0, generate:

```markdown
## Missing Pins (Would Raise BEAR Score)

### High Impact (+0.15 or more):
- [ ] Obtain bank statements for May-June 2024 (would anchor 12 events, raise A by +0.18)
- [ ] Resolve timestamp conflict between Email E-045 and Witness Statement W-003 (would reduce K by -0.10)

### Medium Impact (+0.05 to +0.14):
- [ ] Corroborate Event EV-078 (currently single-source; second source would raise C by +0.08)
- [ ] Cross-reference Claim C-023 to ● evidence item (would raise X by +0.06)

### Low Impact (+0.01 to +0.04):
- [ ] Verify metadata timestamp for Document D-156 (would raise T by +0.02)
```

**Purpose**: Prioritize evidence-gathering and resolution efforts based on BEAR impact.

---

## Section 5: Phase Discipline (3→6→9)

### 5.1 Phase Structure

All engagements proceed through **three mandatory phases**:

#### **Phase 3: Evidence Audit (Intake/Observe)**
- **Activities**: Structured intake, cryptographic anchoring, initial timeline mapping
- **Validation**: Evidence completeness check, gap identification
- **Output**: Evidence database, intake checklist (signed)
- **Gate**: Client approval required to proceed to Phase 6

#### **Phase 6: Reconstruction (Process)**
- **Activities**: Event sequencing, cross-reference validation, conflict resolution
- **Validation**: BEAR coherence scoring, triangle check
- **Output**: Validated timeline, reconstruction report
- **Gate**: Client approval required to proceed to Phase 9

#### **Phase 9: Synthesis (Deliver)**
- **Activities**: Formal reporting, regulatory filing preparation, client presentation
- **Validation**: Back-reference check (all claims cite ●/▼ sources)
- **Output**: Final report, evidence database, cryptographic signature
- **Gate**: Client sign-off, cycle completion

---

### 5.2 No Bypass Rule

**Prohibited**:
- ✗ Skip Phase 3 (cannot reconstruct without anchored evidence)
- ✗ Skip Phase 6 (cannot synthesize without validated timeline)
- ✗ Skip Phase 9 validation gate (cannot deliver without back-reference check)

**Allowed**:
- ✅ Iterate within a phase (e.g., multiple evidence intake rounds in Phase 3)
- ✅ Return to earlier phase if new evidence surfaces (e.g., Phase 9 → Phase 6 → Phase 9)

**Rule**: Forward progression requires explicit approval at each gate. Backward iteration allowed if documented.

---

## Section 6: Evidence Validation

### 6.1 Cryptographic Anchoring

**Requirement**: All evidence must be **hashed upon receipt**.

**Hash Algorithm**: SHA-256 (64-character hexadecimal)

**Procedure**:
```python
import hashlib

def hash_file(file_path):
    sha256 = hashlib.sha256()
    with open(file_path, 'rb') as f:
        while chunk := f.read(8192):
            sha256.update(chunk)
    return sha256.hexdigest()
```

**Storage**:
```json
{
  "evidence_id": "E-001",
  "file_name": "bank_statement_2024-01.pdf",
  "hash_sha256": "a3b5c7d9e1f2a4b6c8d0e2f4a6b8c0d2e4f6a8b0c2d4e6f8a0b2c4d6e8f0a2b4",
  "timestamp_received": "2026-03-28T15:30:00Z",
  "source": "Client (via encrypted email)"
}
```

**Verification**: Re-hash file at any time. Mismatch = tampering detected.

---

### 6.2 Chain of Custody

**Requirement**: Log all evidence transfers.

**Format**:
```json
{
  "evidence_id": "E-001",
  "custody_log": [
    {
      "from": "Client",
      "to": "Investigator",
      "timestamp": "2026-03-28T15:30:00Z",
      "method": "Encrypted email",
      "hash_verified": true
    },
    {
      "from": "Investigator",
      "to": "Evidence Database",
      "timestamp": "2026-03-28T15:35:00Z",
      "method": "Local storage",
      "hash_verified": true
    }
  ]
}
```

---

### 6.3 Triangle Check Procedure

For each event:

1. **Identify Fact**: What is claimed to have happened?
2. **Locate Document**: Primary source evidence (must be in ● OBI-WAN)
3. **Verify Ledger-Time**: Timestamp or sequence (must be in ▼ TATA)

**Decision Tree**:
```
All three sides present? → Resolved Geometry ✅
One or more sides missing? → Unresolved Geometry ⚠️ → Flag for resolution
Sides conflict? → Unresolved Geometry ⚠️ → Escalate for adjudication
```

**Propagation Rule**: Unresolved geometry **does not advance** from ▼ to ◼︎ without explicit gap acknowledgment in final report.

---

## Section 7: Change Control

### 7.1 Version Increment Rules

**Minor Version** (e.g., v1.0 → v1.1):
- Weight adjustments (BEAR formula)
- Clarifications (no behavior change)
- Examples added

**Major Version** (e.g., v1.0 → v2.0):
- Formula structure change (BEAR components added/removed)
- Trident routing rules modified
- "Saved/seated" criteria changed

---

### 7.2 Change Log Format

```markdown
## Change Log

### v1.1 (YYYY-MM-DDTHH:MM:SSZ)
- **Changed**: [What changed]
- **Rationale**: [Why it changed]
- **Impact**: [Who/what is affected]
- **Effective**: [When it takes effect]

### v1.0 (2026-03-28T15:00:00Z)
- **Initial Version**: Canonical contract locked
```

---

### 7.3 Approval Authority

**Changes Require**:
- Written rationale (why change is geometrically necessary)
- PDCA evidence (from real engagement or observed failure)
- Version increment + effective timestamp
- Notification to all active engagements (if behavior changes)

**No Changes Without**: Version control, logged rationale, and timestamp.

---

## Section 8: Operator Rhythms (Discipline, Not Authority)

### 8.1 26-Step Alphabet / 12-Beat Clock

**Status**: Allowed as **operator rhythm** (discipline/cadence)

**Rule**: If conflict arises between operator rhythm and canonical contract (S0–S11 + Trident routing):
- **Canonical contract wins**
- Operator rhythm is adjusted or discarded
- No exceptions

**Example Conflict**:
- Operator rhythm: "Z (Zed) = cryptographic anchor"
- Canonical contract: "Anchor = SHA-256 + timestamp + location"
- **Resolution**: Canonical contract definition prevails; "Zed" is mnemonic only

---

### 8.2 S0–S11 Spine

**Status**: IMMUTABLE (foundational sequence)

**Routing**: S0–S11 defines the **phase progression** and **validation gates**. Operator rhythms (26/12) cannot bypass or reorder S0–S11.

---

## Section 9: Canonical Seating Reference

This contract **seats** as:

**Vertex**: ◼︎ DOJO (Manifestation — binding contract for all operations)  
**File**: `DOJO_SUITE_CANONICAL_CONTRACT.md`  
**Version**: 1.0  
**Effective**: 2026-03-28T15:00:00Z  
**Hash (SHA-256)**: `[TO BE COMPUTED UPON SAVE]`  
**Authority**: Overrides all other documentation in case of conflict  

**Referenced By**:
- Service Agreement Template
- Document Intake Checklist
- Formal Report Template
- Regulator Filing Tracker
- BEAR Calculation Guide (pending)

---

## Section 10: Next Steps (Path A)

Upon seating of this contract (Path C complete):

### **Path A: Field Deployment**

1. **Deploy Templates**: Use templates on first real client engagement
2. **Measure BEAR Components**:
   - Track A, C, T, X, G, K throughout Phases 3/6/9
   - Record Source_Keys for corroboration tracking
   - Flag unresolved geometry and conflicts
3. **Calculate BEAR Score**: Apply v0.1 formula with default weights
4. **Generate BEAR Calibration Note v0.2**:
   - Adjust weights based on measured reality
   - Document rationale for changes
   - Increment version (v0.1 → v0.2)
   - Record effective timestamp

**Deliverable**: `BEAR_CALIBRATION_NOTE_v0.2.md`

**Timeline**: After first engagement completion (6-12 weeks typical)

---

## Appendix A: Quick Reference

### Saved/Seated Checklist

- [ ] Canonical vertex home assigned (●/▼/▲/◼︎)
- [ ] Reality anchor exists (hash + timestamp + location)
- [ ] Claim separation explicit (observed/interpreted/recommended)
- [ ] Triangle check status recorded (resolved/unresolved)
- [ ] Version + change log (if behavior changes)

### BEAR v0.1 Quick Calc

```
BEAR = 0.25A + 0.25C + 0.20T + 0.20X - 0.05G - 0.05K
(Clamp to [0.0, 1.0])
```

### Trident Quick Routing

```
● Witness → ▼ Gate → ▲ Compile → ◼︎ Manifest
(No bypass, no skip)
```

---

## Appendix B: Glossary

- **Anchor**: SHA-256 hash + timestamp + storage location
- **BEAR**: Bounded Evidence Alignment Ratio (coherence metric)
- **Canon**: Persisted artifact meeting all five "saved/seated" criteria
- **Source_Key**: Hash of (origin_system, author, doc_class, channel) for corroboration
- **Triangle**: Fact ↔ Document ↔ Ledger-Time (must resolve before propagation)
- **Unresolved Geometry**: Missing or conflicting triangle side (halts propagation)
- **Vertex**: Canonical persistence home (●/▼/▲/◼︎)

---

*Frequency: 741 Hz | Chamber: DOJO | Version: 1.0 | Effective: 2026-03-28T15:00:00Z | Status: BINDING*

---

**END OF CANONICAL CONTRACT**
