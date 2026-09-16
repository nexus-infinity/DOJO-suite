# Connector Mandela — Auth, Storage Discipline & Multi-Surface DOJO Suite V0

**Status:** `SEATED.SPEC` · design lock for dual-use (local FIELD + commercial attach)
**Overview lens:** Metamorphosis · Mandela mirror genotype
**Not:** live PayPal/Square wiring · financial-cyber product · new FIELD ecosystem per editor

**Parents:**
`docs/MANDELA_MIRROR_SUBSYSTEM_GENOTYPE_V0.md` ·
`DOJO-suite/docs/DOJO_TODAY_EXTERNAL_MCP_CONNECTION_READINESS_CONTRACT_V0.md` ·
`DOJO-suite/docs/DOJO_TODAY_UNDER_THE_HOOD_INSPECTOR_CONTRACT_V0.md` ·
`docs/HOST_SURFACE_CHANNEL_GENOTYPE_V0.md` ·
`DOJO-suite/docs/CARPLAY_DOJO_CHANNEL_CONTRACT_V0.md` ·
`docs/EDITOR_AGENT_BOUNDARY_CENSUS_V0.md` ·
`docs/FIELD_CANONICAL_SOURCE_INDEX.md` (singular MCP / one field many editors)

---

## Product law

```text
One FIELD · many editors · many DOJO surfaces.
Editors and commercial fronts may USE infrastructure.
They must NOT create a private parallel ecosystem of truth, MCP, or storage.

Connectors are Mandela mirrors of one attach genotype.
Categories (Finance, Personal, …) are browse planes — not new architectures.
Plane-test guest software → like it → reverse-engineer and implement properly later.
```

```text
Inspection is not operation.
Proof is not workspace.
Settings are not explanations.
Guest connectors are not FIELD authorities.
```

---

## 1. Mandela connector genotype (shared DNA)

Every connector — PayPal, Square, Crypto.com, Gmail, GitHub, or a customer MCP — is the **same genotype**, different **phenotype**.

| Genotype landmark | Meaning |
|-------------------|---------|
| **Catalog entry** | Declared in the store (standard population) |
| **Category plane** | Finance · Personal · Comms · Code · Docs · Calendar · Research · Other |
| **Open to try** | Expanded into Settings / in-play candidate (not all empty forms) |
| **Auth both sides** | See §2 |
| **Storage covenant** | See §3 — where data may land |
| **Smoke** | Read-only probe + receipt; never fake success |
| **Write policy** | Default `read_only` for new / Finance plane-test |
| **In-play** | Short list only |
| **Hide / disable** | Contract surface; catalog remains |
| **Promote candidate** | LIKE → native implement later (not permanent guest authority) |

**Repair rule:** broken connector UX → restore genotype (stages, smoke, storage homes), do not invent a special-case Perplexity-only or Claude-only private stack.

---

## 2. Authorisation — what both sides must do

“Plug in” is **two-party**. Neither side alone is enough.

### 2.1 User / host side (DOJO Suite · FIELD · operator)

| Duty | Requirement |
|------|-------------|
| **Intent** | Explicit open/try — not silent bulk connect of the whole store |
| **Identity** | Operator knows which account/email is authorizing (jb@… vs org) |
| **Secret home** | API keys / tokens in **Keychain** (or platform secure store), not chat logs or ad-hoc files |
| **Policy** | Write policy chosen (Finance default read-only) |
| **Smoke** | Operator or suite runs read-only test; records receipt |
| **Surface fit** | Only enable connectors lawful on that surface (CarPlay ≠ full OAuth browser by default) |
| **Revocation path** | Disconnect / remove key / revoke OAuth known and one-click-ish |
| **No private ecosystem** | No second MCP truth list that diverges from singular FIELD config for FIELD work |

### 2.2 Connector / provider side (PayPal, Square, Crypto.com, MCP server, …)

| Duty | Requirement |
|------|-------------|
| **Auth mode declared** | OAuth · API key · device code · remote MCP URL · unknown |
| **Scopes minimal** | Least privilege for plane-test; escalate only with confirmation |
| **Token endpoint / refresh** | Documented; refresh stored only in secure store |
| **Redirect / callback** | Known, owned by DOJO/FIELD host — not random web tabs without receipt |
| **Webhook (if any)** | Optional later; HOLD until storage covenant + surface map |
| **Rate / meter** | Mode meters declared (subscription vs credit) — Perplexity Ask vs Computer lesson |
| **Revocation** | Provider-side disconnect must be possible |
| **Data residency claim** | What they store on *their* cloud — disclosed in catalog card |

### 2.3 Auth modes (catalog field)

| Mode | User does | Provider does | Plane-test default |
|------|-----------|---------------|--------------------|
| **OAuth** | Approve consent screen | Issues access + refresh | Prefer; scopes read-only first |
| **API key** | Paste key · Save & Test | Validates key on smoke | Keychain only |
| **Remote MCP** | URL + auth | Serves tools/list | Smoke before composer |
| **Device / pairing** | Code on device | Binds session | Surface-specific (Watch / iPhone / iPad) |
| **Unknown** | HOLD | HOLD | Cannot promote |

### 2.4 Dual-side checklist (before “Connected”)

```text
[ ] Catalog entry exists (category + phenotype name)
[ ] Auth mode known (not unknown)
[ ] User secret in Keychain / secure store (not clipboard forever)
[ ] Provider token/scopes recorded in receipt (non-secret summary)
[ ] Read-only smoke OK (or Limited with reason)
[ ] Storage covenant accepted for this surface set (§3–4)
[ ] Write policy set
[ ] Revoke path stated
[ ] Composer exposure false until smoke + policy allow
```

---

## 3. Storage covenant — “will it save in the right places?”

The recurring fear when plugging into Perplexity (or any new front): **where does the data go, and does it obey FIELD?**

### 3.1 One FIELD · many editors (hard)

```text
Welcome: use FIELD infrastructure (chambers, MCP singular config, Keychain pattern, receipts).
Forbidden: create a private parallel ecosystem of MCP servers, truth, or “my own vault”
            that pretends to be FIELD for this operator/product.

Kings-Chamber: deterministic translation / governance host for FIELD infrastructure.
DOJO Suite:    multimodal product glove (Mac · iPhone · iPad · CarPlay · Watch phenotypes).
External editor (Claude, Perplexity, Cursor…): guest surface — may attach tools;
            must not become second FIELD root.
```

### 3.2 Data classes and lawful homes

| Class | May land | Must not land |
|-------|----------|----------------|
| **Secrets** | Keychain / platform secure enclave equivalents | Chat threads, screenshots, plain JSON on Desktop |
| **Connection registry** | App Support / suite config (non-secret) | Random editor plugin folders as sole copy |
| **Smoke / attach receipts** | Application Support · suite logs · optional Proof drawer | Provider chat as only receipt |
| **Plane-test observations** | OBI-WAN observer paths / chronicle when promoted | Silent only-in-Perplexity |
| **Work objects (answers, docs)** | DOJO generated-object store / user-visible export | Assumed synced to guest without disclosure |
| **FIELD chamber truth** | Chambers · AKRON · canon paths | Guest connector response as authority |

### 3.3 Guest front rules (Perplexity, Claude, …)

When the operator connects the **same** Gmail/PayPal-class tool inside a **guest** product:

| Rule | Meaning |
|------|---------|
| **Disclose** | Catalog notes “data may also reside with Vendor X under their ToS” |
| **Do not dual-own secrets** | Prefer one Keychain/OAuth home; avoid copying keys into every front |
| **Do not promote guest store to FIELD** | Perplexity/Claude connector state ≠ FIELD registry until mirrored with receipt |
| **Export before trust** | Building stage: export or screenshot entitlement; HOLD if storage opaque |
| **Mode meters** | Guest product modes (Ask vs Computer) labeled; credit burn is not FIELD |

### 3.4 Storage questions every catalog card must answer

```text
1. Where does the auth token live (user device)?
2. What does the provider retain (cloud)?
3. What does DOJO Suite retain (local objects/receipts)?
4. What does FIELD retain if any (observer/chronicle)?
5. What does a guest editor retain if also connected?
6. How does the operator revoke each of 1–5?
```

If any answer is Unknown → **stage cannot exceed Limited**; no composer write tools.

---

## 4. DOJO Suite multi-surface map (Mac · iPhone · iPad · CarPlay · Watch)

Same connector genotype and **same workspace shell DNA**; **surface phenotypes** differ for intake/outtake, layout, and what “optimal” means.

**Hard split:** **iPhone ≠ iPad.** Same Apple platform family, different space (pocket vessel vs tablet workbench). Do not ship one “iOS layout” for both.

### 4.0 Workspace shell layout law (three panels)

The glove shell is always:

```text
Places | Work (centre) | Utility (Details / Review / …)
+ persistent composer
```

How those regions **compose** depends on space:

| Form factor | Layout phenotype | Behaviour |
|-------------|------------------|-----------|
| **Mac** | **Side-by-side** (or collapsible rails) | Places · centre · utility can sit adjacent; rails collapse to icons; full Inspector sheets |
| **iPad** | **Hybrid** | Often two-up (work + one utility) or split; Places as sidebar or overlay; more canvas than phone; catalog/auth more comfortable than phone |
| **iPhone** | **Stack / fold-behind** | The three panels **do not** sit side-by-side as on a computer. They **fold behind each other** — one primary plane at a time; Places / Work / Utility navigate by push, sheet, or tab — not a permanent triple column |
| **CarPlay / Watch** | **Reduced single plane** | Not a three-panel shell; constrained channel / glance only |

```text
Phone law:
  One plane in focus.
  Other shell regions remain available by navigation, not by permanent columns.
  Composer may dock; must not fight stacked navigation.

iPad law:
  More room than phone — may show work + utility together.
  Still not “Mac clone” by default; respect tablet posture (touch, split, Stage Manager optional later).

Mac law:
  Side-by-side workspace shell is the reference glove layout.
```

This is **layout phenotype**, not a different product identity. Same Mandela shell genotype; different expression of space.

### 4.1 Surface matrix

| Surface | Role | Intake (typical) | Outtake (typical) | Connector posture | Shell layout |
|---------|------|------------------|-------------------|-------------------|--------------|
| **Mac DOJO app** | Primary multimodal glove · Settings · Inspector · full OAuth/browser | Voice, text, drop, files, deep Settings | Objects, export, Proof, rich Review | Full catalog browse · plane-test · smoke | Side-by-side panels + collapsible rails |
| **iPad DOJO** | Tablet workbench · larger canvas · mid-weight Settings | Touch, pencil optional later, split share-in, voice | Objects, side utility, export when sensible | Catalog browse comfortable · OAuth OK · less clutter than Mac dump | Hybrid: work + utility; Places sidebar/overlay |
| **iPhone DOJO** | Pocket vessel · packets · glance · handoff hub | Voice, camera, share sheet, short text | Notifications, short answers, handoff to Mac/iPad | Subset catalog · phone OAuth · **no** triple-column store | **Stack / fold-behind** three regions |
| **Apple CarPlay** | Constrained vehicle channel (via iPhone) | Short voice · safe cues | Short audio · HOLD · do-later handoff | Pre-authorized only · Finance **not** interactive in-car | Single constrained plane |
| **Apple Watch** | Glance + capture edge | Complications, short voice, haptics | Glance status, confirm/cancel | Pre-bound only · no catalog browser | Single glance plane |

Canon: CarPlay = constrained DOJO surface, not full cockpit (`CARPLAY_DOJO_CHANNEL_CONTRACT_V0.md`).

### 4.2 Intake / outtake genotype (every surface)

```text
INTAKE  — what may enter this surface (capture, auth return, smoke result, object open)
OUTTAKE — what may leave (display, speech, export, handoff to another surface)
HOLD    — what must not happen here (silent write, full connector store, credit-burn Computer)
```

| Surface | Intake allowed | Outtake allowed | Explicit HOLD |
|---------|----------------|-----------------|---------------|
| Mac | Auth return, full smoke, file drop, catalog open | Full objects, MD export, Proof, Inspector | Guest editor as sole storage · forced phone stack layout |
| iPad | Auth, catalog open, split work+utility, share-in | Objects, utility dock, export | Treating iPad as phone-only stack forever without hybrid option |
| iPhone | Auth where platform allows, share-in, voice | Short objects, notifications, queue, handoff | Permanent three-column desktop layout · desktop-only OAuth without handoff |
| CarPlay | Pre-authorized voice intents only | Short speech, status, “later on iPhone” | OAuth UI · finance mutate · long connector lists · three-panel shell |
| Watch | Pre-bound glance / confirm | Haptic + short status | Catalog · API key paste · destructive confirm without phone |

### 4.3 Orchestration (when multi-surface is “optimal”)

Connectors participate in orchestration **only if** the surface map allows that step:

```text
Example plane-test (Finance, read-only):
  Watch/CarPlay  → capture intent “check status later”
  iPhone         → handoff · optional short auth · stacked UI
  iPad           → optional mid-weight review / split utility
  Mac            → catalog · full auth · smoke · receipt · Review/Proof
  Not:           CarPlay completes PayPal OAuth mid-drive
  Not:           iPhone forced into Mac side-by-side three columns
```

**Optimal** = least surface that can lawfully complete the stage, then hand off — not “all surfaces show all connectors,” not “one layout for all Apple devices.”

### 4.4 Murmur / suite coherence

DOJO Suite murmurous (shared product language across **Mac · iPad · iPhone · CarPlay · Watch**):

| Shared | Surface-specific |
|--------|------------------|
| Genotype stages · Proof language · HOLD plain text | Catalog depth · OAuth UI · object canvas size |
| Shell regions: Places · Work · Utility · Composer | **How regions compose** (side-by-side vs hybrid vs stack) |
| In-play short list idea | Which IDs appear in-play on device class |
| One Keychain/account story per operator | Platform secure storage API · iCloud Keychain later HOLD |
| No private MCP ecosystem | Editor guests still separate |

---

## 5. Category planes (Mandela petals) — Finance first

| Category | Plane-test default | Example phenotypes |
|----------|--------------------|--------------------|
| **Finance** | `read_only` · smoke OBSERVE · high scrutiny | PayPal, Square, Crypto.com, banks |
| **Personal** | `read_only` | Health, local files, personal mail |
| **Comms** | `read_only` → escalate | Gmail, Outlook, Slack |
| **Code** | `read_only` for public; write+confirm for push | GitHub |
| **Docs** | `read_only` | Drive, Notion (guest) |
| **Calendar** | `read_only` | Google Calendar |
| **Research / agent** | Meter labels required | Perplexity connectors / Computer-class |
| **Other** | Unknown until classified | — |

**LIKE path:** plane-test success + operator intent → `HOLD.PromoteCandidate` for native implementation — not automatic elevation of guest to FIELD finance cyber.

---

## 6. Web store UX (no clutter)

```text
Connectors
├── In-play (short)
├── Try another (chips by category)
└── Browse store
      ├── Finance → PayPal · Square · Crypto.com · …
      ├── Personal · Comms · Code · …
      └── card: auth mode · storage answers · meter · Open to try
```

Building stage: catalog may list more than we use.
Using stage: in-play stays short.
Commercial stage: same store grammar for customer ecosystems.

---

## 7. System Inspector & Proof placement

| Concern | Home |
|---------|------|
| Connection stages · MCP/connector summary | System Inspector → MCP Connections / Tools |
| Object-scoped evidence of a plane-test | Proof drawer |
| Configure keys / enable connector | Settings → Connectors / API keys |
| Raw traces | Diagnostics (Developer) |
| Ordinary work | Workspace — no connector dump |

---

## 8. Relation to singular MCP config

For **FIELD chamber / editor MCP** (Cursor, Claude, VS Code, Xcode):

```text
scripts/generate_canonical_mcp_config.py
→ one generated set · many editors
```

For **product connectors** (PayPal, Square, …) and **customer MCP attach**:

```text
DOJO Suite connector registry + smoke receipts
→ product glove · commercial attach
→ must not fork a second “truth MCP” for FIELD chambers
```

Editors invited into FIELD: **use generated config**.
Customers of DOJO Suite product: **use connector Mandela store**.
Same genotype landmarks; different phenotype homes.

---

## 9. HOLD register (open)

| HOLD | Meaning |
|------|---------|
| `HOLD.ConnectorStoreNotPopulated` | Standard population not yet filled |
| `HOLD.FinancePlaneTestNotRun` | No PayPal/Square/Crypto smoke yet |
| `HOLD.GuestStorageOpaque` | Guest front storage not fully mapped |
| `HOLD.CarPlayConnectorAuthNotLawful` | No in-car OAuth promotion |
| `HOLD.WatchCatalogNotApplicable` | Watch has no full store |
| `HOLD.iPadSurfaceNotShipped` | iPad phenotype named; app layout not proven |
| `HOLD.iPhoneStackShellNotShipped` | Phone fold-behind three-panel law seated; UI not proven |
| `HOLD.PromoteGuestToNative` | LIKE path not yet a formal promotion packet |

---

## 10. Minimal implementation sequence (later)

1. Catalog JSON: categories + stub phenotypes (Finance: PayPal, Square, Crypto.com) — **no live auth**
2. Settings → Connectors: in-play empty + Browse Finance stubs
3. Auth dual-side checklist UI (disabled Connect until wired)
4. Storage covenant text on each card
5. Surface flags: mac full · iPad hybrid · iPhone stack subset · CarPlay/Watch pre-auth only
6. First live: one read-only finance smoke with receipt
7. Phone shell: implement Places/Work/Utility as **stacked** navigation (not Mac columns)
8. iPad shell: hybrid work+utility before cloning Mac three-column default

---

## One line

**Mandela attach genotype for every connector; both sides authorize; data homes are covenanted under one FIELD / DOJO glove; Mac side-by-side · iPad hybrid · iPhone fold-behind panels · CarPlay/Watch reduced — each only intake/outtake what it can lawfully hold; plane-test Finance first; implement properly only when we like it.**
