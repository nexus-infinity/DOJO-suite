# DOJO Suite — Voice capture, Apple/iCloud custody & Perplexity benchmark addendum V0

**Object:** Preserve a live user example at the Apple-integrated external-surface boundary and translate it into bounded DOJO Suite requirements.

**Status:** `SEATED.CLASSIFICATION` · `OAW.intentionally_unsealed` · implementation `HOLD`

**Related contracts:**

- `docs/VOICE_CAPTURE_PACKET_PIPELINE_AND_HERMEN_DOCK_V0.md`
- `docs/DOJO_SUITE_STANDARD_SETTINGS_ATTRIBUTES_APPLE_ECOSYSTEM_V0.md`
- `docs/CONNECTOR_MANDELA_AUTH_STORAGE_MULTISURFACE_V0.md`
- `docs/PERPLEXITY_SPINNING_TOP_GAP_ANALYSIS_V0.md`

## Live example being preserved

The operator is using an iPhone connected to the local workplace and expects the recording to be available through iCloud. The same interaction is relevant to live-time benchmarking of the Perplexity application because Perplexity presents a close Apple-integrated comparison surface.

This is a **user-reported benchmark observation**, not yet a runtime witness that:

- the exact recording is present in iCloud;
- the local workplace has received the same asset;
- Perplexity can access that asset;
- an Apple handoff or iCloud sync completed; or
- any transcript or semantic interpretation is correct.

Do not promote any of those propositions from expectation to fact without a source witness and receipt.

## Boundary map

```text
iPhone / Apple tools
  owns capture, Apple account, iCloud, Continuity, and system permissions
        │
        │ explicit handoff or import; source identity and hash witnessed
        ▼
DOJO Suite
  seals the local work object, records provenance, and exposes bounded review
        │
        │ transcript remains probabilistic until witnessed
        ▼
Analysis → OAW alignment → explicit implementation authority

Perplexity
  external benchmark / guest comparison surface; never DOJO or FIELD authority
```

## What this means for DOJO Suite

The existing voice genotype is the correct starting point:

`capture → MurmurPacket / SealedVoiceObject → handoff or import → transcript candidate → work object → receipt`

The iPhone and iCloud path must be treated as an Apple-owned source and transport surface. DOJO may show status, request or receive an explicit handoff, and preserve a local sealed object. DOJO must not silently impersonate Apple’s device graph or claim iCloud synchronization merely because the user expects it.

The existing `SealedVoiceObject` already provides the important evidence spine: local file path, SHA-256, capture timestamp, device session, byte count, lifecycle, and explicit export policy. `HandoffWitnessSnapshot` is currently a read-only contract stub, so live cross-device handoff remains `Unknown` until witnessed.

## Benchmark record

| Surface | Current observation | Evidence class | Permitted use | Current state |
|---|---|---|---|---|
| iPhone | Operator-originated recording | User report; exact asset not confirmed | Benchmark intake expectation; source confirmation request | `CANDIDATE` |
| iCloud / Apple tools | Expected source or transport location | User expectation; no local sync witness | Test Apple-owned custody and handoff boundaries | `UNKNOWN` |
| Elephas | Local-first knowledge workspace with iCloud-backed cross-device brains | Vendor documentation plus local Mac witness of the app and its iCloud brains container | Test brain discovery, sync initiation, indexed-content availability, provider boundary, and recovery | `PARTIAL` · lived failure |
| Perplexity | Apple-integrated external comparison surface | User-reported live benchmark context | Compare friction, discoverability, and handoff affordances | `GUEST.BENCHMARK` |
| DOJO Suite | Local sealed voice and packet path exists in code | Static implementation evidence | Preserve hash, provenance, review, and HOLD states | `PARTIAL` |
| OAW / implementation | Not entered for this recording | No aligned authority | Reopen only after evidence gates pass | `HOLD` |

## Required acceptance gates

1. **Source identity:** user or a local witness confirms the exact iPhone/iCloud asset; a likely filename is not enough.
2. **Custody:** DOJO records whether the asset was imported, handed off, or merely referenced. The original is not overwritten or silently duplicated.
3. **Integrity:** the sealed local object records hash, byte count, duration, source surface, device/session, and a receipt pointer.
4. **Translator declaration:** ASR route, locale, privacy mode, and confidence are visible. A transcript is a candidate, not lived meaning or authority.
5. **Benchmark separation:** Perplexity observations are labelled as external comparison evidence. They do not become DOJO architecture, FIELD truth, or vendor capability claims without direct witness.
6. **OAW gate:** analysis and OAW alignment begin only after source and transcript evidence pass. Implementation requires explicit aligned authority.

## Failure states to keep visible

```text
HOLD.SourceIdentityUnconfirmed
HOLD.AppleSyncUnwitnessed
HOLD.HandoffUnwitnessed
HOLD.ASRTranscriptUnverified
HOLD.ExternalSurfaceClaimUnverified
HOLD.OAWNotEntered
```

## Periscope readout: integration is not synchronization

The first engineering distinction is **where continuity is implemented**:

| Pattern | Engineering shape | Phenotype the operator experiences | DOJO interpretation |
|---|---|---|---|
| iCloud Drive / ubiquitous documents | Files in an Apple container; metadata and file bytes may arrive at different times; the app must coordinate access and conflicts | A file can appear before it is locally usable, or remain delayed/offline | Show `metadata available`, `downloading`, `local`, `conflict`, or `unknown`; never reduce this to `iCloud=true` |
| CloudKit / record sync | Local store mirrored to CloudKit records; background scheduling depends on system conditions; app persists sync state and handles conflicts | Changes may be eventual rather than immediate; a local view may lag the remote record | Preserve local state, remote state, change token/sync receipt, and conflict state as separate pins |
| Vendor cloud | App owns an account/session service and uses Apple surfaces for entry, permissions, intents, or handoff | The experience can feel native while persistence and retention remain vendor-controlled | Label vendor custody and retention; Apple integration is not iCloud custody |

Apple’s documentation describes both document-based iCloud and CloudKit record-based designs. For iCloud documents, metadata may synchronize before data and version conflicts require application handling. For CloudKit, automatic sync timing is system-dependent, the app must persist sync state, and record conflicts require explicit resolution. These mechanisms explain why a written promise of “seamless” continuity may not match the lived experience of a file being unavailable, delayed, duplicated, or stale.

## Comparison against live benchmark surfaces

This is a bounded comparison, not a claim about private implementation internals.

| Surface | Written/public intention | Evidence-led engineering read | Lived-experience question | State |
|---|---|---|---|---|
| Apple iCloud Drive | Make app documents available across Apple devices | File/container path, metadata discovery, download state, coordination, and conflict handling matter | Does the exact asset exist, download, open, and remain unchanged on the Mac? | `PARTIAL` |
| Goodnotes | iCloud sync between iPhone, iPad, and Mac after enabling Cloud Sync with the same Apple Account | App-level iCloud toggle plus visible sync status; the vendor documents sync failures and local-data risk | Does the cloud status correspond to an actually usable local document? | `BENCHMARK.CANDIDATE` |
| Obsidian | iCloud Drive can sync a vault between Apple devices | File-folder placement is part of the contract; the vendor recommends keeping the folder downloaded and warns about some sync environments | Is the expected folder the one the app actually opens, and are local files current? | `BENCHMARK.CANDIDATE` |
| Things | Apple-device continuity, but not iCloud sync | Things explicitly uses Things Cloud and does not support iCloud or Dropbox as its sync service | Does the operator mistake Apple-native form for Apple-owned storage? | `NEGATIVE.CONTROL` |
| Perplexity iOS | A voice assistant layer over the device that integrates with selected apps and iOS shortcuts | Public documentation shows app actions, permissions, and vendor session History; the reviewed sources do not establish iCloud-backed persistence | What entered the vendor session, what remained on-device, and what was retained or deleted? | `GUEST.BENCHMARK` |

The local workplace currently witnesses that an iCloud Drive surface exists at `/Users/field/Library/Mobile Documents/com~apple~CloudDocs/●OB1Link`. That proves local iCloud Drive presence, not the identity, sync completion, or custody of the voice recording under review.

The Perplexity conclusion is intentionally qualified: its public iOS material supports an **Apple-integrated action and voice phenotype**, while its session and file-retention material points to a **Perplexity account/service persistence layer**. That is an inference from public documentation, not reverse-engineering or a claim that no iCloud mechanism exists.

## Elephas primary periscope

### Declared intention

Elephas publishes a local-first intention: index documents on the device, keep the index and text chunks locally, and use iCloud for access across Mac, iPhone, and iPad. Its current privacy description separates the two Apple paths: CloudKit mirrors app data such as Brain definitions and chat records, while iCloud Drive syncs indexed matter-file content. It also states that only relevant passages are sent to the configured AI provider when a question is asked. These are vendor statements to test, not automatically accepted truth.

### Lived result: complete failure of usable trust

The operator’s experienced result is recorded separately from the vendor’s intention:

> **Elephas has been a complete failure in practice. I avoid using it because I do not know what it is doing in backend processing, where the data goes, or how it mixes things up.**

This is a **witnessed user-experience failure**, not yet a proven claim that every Elephas sync or indexing operation is technically broken. It is sufficient to fail the product intention for this operator because the system is not currently predictable, inspectable, or trusted enough to use.

| Lived requirement | Current result | Consequence |
|---|---|---|
| Know what is being processed | `FAIL` — backend processing is unclear | Do not send sensitive material or rely on an unexplained answer |
| Know where data and derived indexes live | `FAIL` — custody and mixing are unclear | Keep Elephas outside the active DOJO evidence path |
| Understand what a Brain contains | `FAIL` — boundaries are not legible in use | Do not treat a Brain as a single trustworthy object |
| Correct or recover from unexpected results | `UNKNOWN` | Require an inspectable reset, export, and recovery witness |
| Feel able to use the system | `FAIL` — operator avoids it | Written “seamless” intention is not achieved for this user |

The positive gap is therefore sharper: DOJO must make processing lineage, custody, indexing scope, provider transmission, and mixing boundaries visible before it can claim continuity. “Stored in iCloud” is not enough if the operator cannot tell what is being transformed, where the derived material resides, or how to undo it.

**Current decision:** `HOLD.ElephasActiveUse` · preserve as a benchmark failure specimen · promote only the inspector and evidence requirements, not Elephas as a trusted route.

### Engineering surface identified

The public contract exposes several separate moving parts:

```text
source documents / connected sources
→ local index + SQLite text chunks + file metadata
→ CloudKit app records
→ iCloud Drive indexed matter files
→ local retrieval
→ selected passages
→ configured AI provider
→ answer with source context
```

The vendor also documents an app-specific storage path, manual and automatic refresh behaviour, a Mac-initiated sync requirement in some flows, and a recovery path based on backing up the `brains` folder and re-adopting a Brain by name. This is enough to define a testable engineering contract; it is not enough to claim that every device, version, Brain, or connected source is currently healthy.

### Local Mac witness

On this workplace, the following static facts were observed without modifying Elephas data:

| Witness | Result | Meaning |
|---|---|---|
| `/Applications/Elephas 2.app` | Present; bundle identifier `com.kamban.elephas-appstore` | Mac app is installed |
| `~/Library/Mobile Documents/iCloud~Elephas/Documents/brains` | Present; two immediate Brain directories | An Elephas iCloud storage surface is locally visible |
| Cross-device sync | Not exercised | `Unknown` |
| Brain contents and answer grounding | Not opened or queried | `Unknown` |
| Package trust/entitlements | Local `codesign` inspection reported `CSSMERR_TP_NOT_TRUSTED` and an invalid-entitlements warning | Separate packaging/runtime qualification; not treated as proof of sync failure |

The local witness therefore supports `storage surface present`, not `sync succeeded`, `content available on iPhone`, `index current`, or `answer grounded in the intended Brain`.

### Success-of-intention scorecard

| Intention to evaluate | Minimum success witness | Current result | Gap type |
|---|---|---|---|
| “My Brain is available across devices” | Same Brain identity appears on Mac and iPhone; a known test item is retrievable on both | `UNKNOWN` | Need a cross-device witness |
| “iCloud keeps the data available” | CloudKit/Drive route is enabled, local availability is visible, and a forced recheck completes | `PARTIAL` | Need explicit state and receipt |
| “Indexing is local/private” | Index location and provider request boundary are visible for one test item | `PARTIAL` | Need a user-facing custody explanation |
| “The Brain is usable” | User can create/select a Brain, add a test document, ask a question, and find the source | `HOLD` | Discoverability and guided-use gap |
| “Connected sources stay current” | A changed source is re-indexed under the stated manual/automatic policy | `UNKNOWN` | Need freshness and refresh witness |
| “The system is recoverable” | Backup/re-adopt procedure restores a test Brain without changing its identity | `CANDIDATE` | Recovery test not performed |

### Positive gap: what DOJO can add

The strongest enhancement is a **continuity and custody inspector**, not an Elephas clone. For any third-party Apple-integrated app, DOJO can present one quiet card with:

- the source app and exact surface: Mac, iPhone, iCloud Drive, CloudKit, or vendor cloud;
- the object identity: Brain, file, record, transcript, or work object;
- current custody: original, local index, iCloud record/file, provider request, or unknown;
- freshness: last witnessed, queued, syncing, stale, conflict, or unavailable;
- the operator action that will establish the next witness: open, refresh, import, export, test query, or recover;
- the declared intention versus the lived result and resulting repair.

That is the positive translation of the higher-order invariant: preserve the object and its provenance while making the Apple phenotype easier to understand and use on the Mac. The user should not have to reverse-engineer whether “iCloud” means a file, a record, an index, a cache, or a vendor session.

### Elephas test order

1. Select one non-sensitive test document and one named Brain.
2. Confirm the Brain’s Mac storage route and record its local witness.
3. Trigger the documented Mac-to-iPhone sync path and record the visible state change.
4. On iPhone, retrieve the same test item and ask one bounded question.
5. Compare source grounding, delay, freshness, and operator comprehension with the written intention.
6. Test a controlled source change and the documented recovery path.
7. Translate only the successful, witnessed invariants into a native DOJO Mac surface.

No production integration should be inferred from this scorecard. The scorecard is the periscope instrument; each result needs its own evidence anchor.

## Written intention versus experienced phenotype

For every benchmark sitting, keep four separate statements:

1. **Declared intention:** what Apple or the vendor says the feature should do.
2. **Engineering contract:** the observable mechanism required for it to work—container, account, permission, queue, sync state, conflict path, retention, and deletion.
3. **Lived result:** what the operator actually encountered on the iPhone and Mac, including delay, absence, duplication, stale content, or unclear ownership.
4. **DOJO translation:** the smallest native macOS behaviour that preserves identity, provenance, authority, uncertainty, and return path.

The lived result is not dismissed because it conflicts with the written intention. The discrepancy is itself benchmark evidence and becomes a `HOLD` until the mechanism explains it or a new witness resolves it.

## Mac phenotype translation for DOJO

The higher-order invariant is not “make DOJO look like an Apple-integrated app.” It is:

```text
preserve identity + provenance + custody + authority + uncertainty + return path
while the local Mac phenotype changes with the source mechanism
```

Therefore the native Mac surface should express:

- **Source card:** `iPhone`, `iCloud Drive`, `CloudKit`, `Perplexity`, or `Unknown`; never a generic “synced” badge.
- **Custody card:** where the original, local cache, transcript, work object, and vendor session are held.
- **Sync state:** `LOCAL_ONLY`, `METADATA_ONLY`, `DOWNLOADING`, `SYNCED`, `STALE`, `CONFLICT`, `UNAVAILABLE`, or `UNKNOWN`.
- **Explicit intake action:** import, open in place, or receive handoff; each action yields a receipt and hash where bytes are available.
- **Review boundary:** transcript and semantic interpretation remain candidates until witnessed; OAW and implementation remain closed until aligned authority exists.
- **Benchmark drawer:** written intention, engineering evidence, lived result, delta, and one next evidence gate.

This is the macOS phenotype of the geometric order: the surface may be quiet and native, but it must not conceal the difference between an Apple container, a vendor cloud, a local file, and a DOJO-authorised object.

## Periscope procedure for each future app

Use one dated, bounded pass per app and source pair:

```text
name the app and source
→ capture declared intention
→ identify the documented engineering mechanism
→ perform one observable cross-device action
→ record storage, delay, conflict, and deletion behaviour
→ compare lived result to declared intention
→ translate only the aligned invariant into native Mac form
→ HOLD any unresolved custody or authority claim
```

Do not bulk-connect accounts, scrape private app state, or infer a vendor’s internal architecture from a polished surface. Use public technical documentation, user-visible controls, local file witnesses, and explicit receipts.

## Positive gap analysis: enhance the intention

The gap is not that DOJO lacks an Apple-shaped surface. The positive gap is that the existing intention can become finer-grained and more trustworthy when it carries the engineering detail through to the operator.

| Existing intention | Finer detail learned | Positive enhancement for DOJO | Admission |
|---|---|---|---|
| Preserve a voice packet across surfaces | Apple file sync, CloudKit records, and vendor clouds have different custody and timing | Replace one generic sync state with a typed source, custody, transport, and freshness model | `PROMOTE.CANDIDATE` |
| Keep the original and hash it | A file can be discoverable before its bytes are local; a record can be remote without a file path | Add `assetAvailability` and `lastWitnessedAt` beside the existing sealed hash; never hash a placeholder | `PROMOTE.CANDIDATE` |
| Use Apple surfaces naturally | App Intents make app actions discoverable while the app remains the source of truth | Expose bounded DOJO actions—capture, import, review, resume, and HOLD—to Shortcuts/Siri/Apple system surfaces | `DESIGN.CANDIDATE` |
| Support iPhone → Mac continuity | Background sync is scheduled by system conditions and can be delayed | Make continuity resumable rather than instantaneous: queue locally, show the next lawful action, and restore by receipt | `PROMOTE.CANDIDATE` |
| Compare Perplexity’s low-friction integration | Perplexity’s public model is an external assistant layer with selected app actions and account/session history | Benchmark friction and affordance separately from custody; provide a DOJO proof drawer and explicit data-destination label | `PROMOTE.CANDIDATE` |
| Honour user experience | Written promises can differ from delay, stale state, missing asset, or unclear ownership | Treat `declared_intention → lived_result → delta → repair` as a first-class benchmark object | `PROMOTE.CANDIDATE` |
| Keep authority in the governed field | Apple or vendor integration can feel authoritative without being a chamber decision | Keep every external result advisory until source, provenance, policy, and OAW authority are witnessed | `LOCK` |

### Positive design target

```text
Apple-native entry and handoff
        +
mechanism-specific custody and freshness
        +
local sealed evidence and reversible queueing
        +
visible lived-result delta
        =
more truthful continuity on the Mac
```

This strengthens the original intention without collapsing Apple, the vendor, DOJO, or FIELD into one system. The enhancement is a better translation layer: the Mac surface tells the truth about what kind of continuity is actually present, while still making the next useful action easy.

### Recommended implementation order after authority is opened

1. **Typed intake contract:** add source kind, custody owner, availability, freshness, and witness fields to the voice/work-object boundary.
2. **Native action bridge:** expose a small App Intents surface for explicit capture/import/review/resume actions; return a result or HOLD, never silent completion.
3. **Benchmark ledger:** store the written intention, lived result, delta, source evidence, and repair decision as a local receipt-bearing comparison object.
4. **One-device proof:** test the iPhone → iCloud or vendor surface → Mac path with one non-sensitive recording before considering broader sync or provider integrations.

These are enhancement candidates, not completed implementation. They remain behind the same source-confirmation, transcript, OAW, and authority gates.

## Elephas acronym crosswalk

`Elephas` is a product name, not an acronym. The following terms are the useful vocabulary for the periscope. They are deliberately separated into product evidence, platform/integration vocabulary, and DOJO control vocabulary.

| Term | Meaning | Role in this periscope | Evidence status |
|---|---|---|---|
| AI | Artificial intelligence | Vendor feature and provider-processing category | Product-level term; mechanism still requires a provider/custody witness |
| API | Application programming interface | Provider connection and key boundary | Relevant integration term; not proof that a request was made |
| BYOK | Bring your own key | Useful label for user-supplied provider credentials | Standard vocabulary; do not assume Elephas uses this exact label |
| CloudKit / CK | Apple cloud record service | Possible record-sync layer for Brain definitions, workspaces, and chat records | Directly described in Elephas privacy material |
| FAISS | Facebook AI Similarity Search | Local vector-index technology named in Elephas Brain configuration | Directly described in Elephas support material |
| iCloud Drive | Apple file-sync surface | Indexed matter-file content and local availability boundary | Directly described; presence is not sync proof |
| LLM | Large language model | Provider/model class used to answer against retrieved content | Relevant provider vocabulary; exact model path is not witnessed here |
| OCR | Optical character recognition | Possible document/image extraction stage | Adjacent capability; not evidenced in this observation |
| PII | Personally identifiable information | Data category relevant to Smart Redaction and privacy review | Relevant to Elephas redaction claims |
| RAG | Retrieval-augmented generation | Useful architectural description for retrieval plus provider answer | Bounded inference, not a claim about undocumented internals |
| SQLite | Embedded relational database | Local text-chunk and metadata storage boundary | Directly described in Elephas storage material |
| ASR / STT | Automatic speech recognition / speech-to-text | Voice-packet intake vocabulary for the wider DOJO flow | DOJO-adjacent; not evidence that Elephas transcribed this packet |
| TCC | Transparency, Consent, and Control | macOS permission boundary affecting file/app observation | Platform control term; permission state remains unwitnessed |
| UI / UX | User interface / user experience | Visible phenotype versus lived operator experience | UI observation timed out; lived failure is user-attested |
| UUID | Universally unique identifier | Stable object identity for receipts and test objects | DOJO control term |
| SHA-256 | Secure Hash Algorithm, 256-bit | Byte-level identity seal when an asset is available | DOJO evidence term, not an Elephas sync signal |
| MCP | Model Context Protocol | FIELD/DOJO tooling vocabulary | Not an Elephas product claim |

## What a change means when no independent signal is emitted

A local application can mutate state without emitting a signal that an independent observer can verify. For example, Elephas may update a local index, cache, SQLite row, or iCloud container entry. That establishes at most a local state change. It does not establish that iCloud completed synchronization, that a provider processed the new state, that another device can retrieve it, or that alignment improved.

“Frequency changed” is therefore not a valid inference from a file, database, or UI mutation. A frequency claim would require a calibrated independent measurement over time. A digital timestamp, sync event, or notification is an event signal; it is not a physical frequency measurement.

| Claim | Minimum independent witness | Current classification |
|---|---|---|
| Elephas changed locally | Before/after app or storage observation | `PARTIAL`: app bundle and Elephas iCloud brains container are present; UI observation timed out |
| iCloud sync completed | Remote change notification/change token, or the same test object retrieved on a second device | `UNKNOWN`: not witnessed |
| Backend/provider processing changed | Controlled identical-input test plus provider-boundary evidence | `UNKNOWN`: not witnessed |
| A frequency changed | Calibrated independent sensor and time series | `NOT_MEASURED`: no such signal is implied or emitted by the current sample |
| Alignment improved | Independent observer seal comparing intention, actual result, and delta | `HOLD`: no seal |

The present sample therefore records: **local evidence exists, but no independent, verifiable, triangulatable signal is currently witnessed**. In DOJO terms, the correct positive enhancement is to expose these as separate fields—`localState`, `independentWitness`, `triangulation`, and `authorityDecision`—instead of one generic `changed` or `synced` badge. The next lawful move is a non-sensitive two-device test that produces a receipt at each boundary.

### Primary references consulted

- [Apple: Synchronizing documents in the iCloud environment](https://developer.apple.com/documentation/uikit/synchronizing-documents-in-the-icloud-environment)
- [Apple: Configuring iCloud services](https://developer.apple.com/documentation/Xcode/configuring-icloud-services)
- [Apple: CKSyncEngine](https://developer.apple.com/documentation/cloudkit/cksyncengine-4b4w9)
- [Apple: Debugging NSPersistentCloudKitContainer synchronization](https://developer.apple.com/documentation/technotes/tn3164-debugging-the-synchronization-of-nspersistentcloudkitcontainer)
- [Apple: App Intents](https://developer.apple.com/documentation/appintents)
- [Goodnotes: Sync documents between Apple devices](https://support.goodnotes.com/hc/en-us/articles/7353726793999-Sync-Goodnotes-documents-between-iPhones-iPads-Macs)
- [Obsidian: Sync your notes across devices](https://obsidian.md/help/sync-notes)
- [Things: Syncing with Things Cloud](https://culturedcode.com/things/support/articles/2803586/)
- [Elephas: Super Brain on iOS](https://elephas.app/support/iphone-ipad/ios-super-brain/)
- [Elephas: How your data is stored](https://elephas.app/support/privacy-data-protection/how-your-data-is-stored/)
- [Elephas: Privacy policy and iCloud/CloudKit description](https://elephas.app/privacy)
- [Elephas: Brain storage, refresh, and recovery](https://elephas.app/support/working-with-knowledge/brain-configuration/)
- [Perplexity: iOS Voice Assistant](https://www.perplexity.ai/help-center/en/articles/11132456-how-to-use-the-perplexity-voice-assistant-for-ios)
- [Perplexity: Which apps the Assistant can use](https://www.perplexity.ai/help-center/en/articles/10452641-which-apps-is-the-perplexity-assistant-able-to-use)
- [Perplexity: What is a Session?](https://www.perplexity.ai/help-center/en/articles/10354769-what-is-a-thread)
- [Perplexity: Security and Privacy with File Uploads](https://www.perplexity.ai/help-center/en/articles/10354810-security-and-privacy-with-file-uploads)

## Smallest next lawful move

Select one app/source pair—starting with the iPhone recording and its presumed iCloud path—and run the periscope procedure once. Confirm the exact asset, observe the handoff or import, and produce a sealed object and receipt. Record the Perplexity comparison separately as benchmark evidence; do not copy its integration model or promote an external result into DOJO authority.

**Action obligation:** `PRESERVE` this benchmark observation · `HOLD` implementation until the gates above are witnessed.
