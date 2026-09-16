# Voice capture → packet → text pipeline & Hermen dock V0

**Status:** `SEATED.SPEC` · Mac Voice & capture Settings wired; full STT route optimal HOLD
**Simple story first** — layers not collapsed.

---

## Simple story (what we want)

```text
1. Microphone receives sound
2. DOJO packages it as a voice packet (Murmur / SealedVoice)
3. If the app needs text, a translator turns speech → text
4. Text becomes a work object (or packet field) — not a log row
5. Hosted models / FIELD chambers only see what policy allows
```

**Optimal:** pick the best translator **for this device and job** — not one global collapse.

| Layer | Job | Examples (candidates) |
|-------|-----|------------------------|
| **Capture** | Sound → packet | Mic + MurmurPacket + SealedVoiceObject |
| **Transport / dock** | Move packet across surfaces | iPhone → Mac/iPad handoff (“Hermen” dock — see below) |
| **ASR / translator** | Speech → text | Apple Speech · cloud STT · Whisper (local later) · “Max translator” when optimal |
| **Understanding** | Text → answer / action | Hosted models (M1), not capture layer |

**Do not collapse:** capture channel ≠ STT channel ≠ chat model ≠ FIELD chamber truth.

Zero-loss intent (Arkadaş / HAL): packet keeps hash, device, sequence; SealedVoice seals original audio locally; upload/AKRON only with explicit promote. Known gap historically: captured audio not always end-to-end zero-loss to AKRON — HOLD until receipt.

## Primary invariant — Herman core / replaceable shell

The `Herman` reference from *The Electric State* is a design lens for this
multi-surface architecture, not a claim that the film's mechanism exists in
the runtime.

```text
Persistent core
  identity · package ID · payload hash · semantic intent
  authority scope · provenance · return route · local receipt state

Replaceable shell
  iPhone · iPad · Mac Studio · CarPlay · another bounded vessel
  exposes only the capabilities available on that surface
```

The shell may scale up, scale down, disconnect, or be replaced. The core
invariants must remain unchanged. A smaller shell may capture, seal, queue,
and provide bounded local interpretation; it may not claim home ratification,
canonical authority, or capabilities it cannot witness.

This is the number-one device rule:

> **Capacity changes the shell, not the identity, provenance, authority scope,
> or return path.**

The existing `CapabilityShapedPackage` and `DeviceCapabilityExpression`
implement this rule at the contract level. The existing two-device coherence
specimen proves different capability-shaped expressions from one conserved
package; live device transport remains separately held.

---

## Architecture already in suite

| Piece | Path / role |
|-------|-------------|
| **HAL capabilities** | `DOJOHALContract` — sense/process/store/relay/act tiers |
| **Murmor protocol** | Devices declare capability; rejoin without ceremony |
| **MurmurPacket** | 16 kHz mono PCM chunks + quality frames |
| **SealedVoiceObject** | Local sealed capture + hash; lifecycle local → queued → AKRON only with receipt |
| **AudioDeviceManager / G6** | Mac input enumeration + Murmur capture gate |
| **Audio Surface PEP** | Body + digital observer; device ≠ identity |

### “Hermen” docking (name as used)

No separate file named Hermen was found in this pass. **Operational meaning we seat:**

> **Hermen dock** = iOS (phone/watch vessel) **sealed voice / murmur packet handoff** into the multi-surface DOJO application (Mac/iPad workbench) so capture on one surface can become text/work on another **without inventing a second ecosystem**.

Maps to:

- `SealedVoiceObject` / `SealedVoiceObjectStore`
- `MurmurPacket` + `MurmurQueue` / transport
- `HandoffWitnessSnapshot` / BoundaryCapacity (reporting; not auto-promote)
- Multi-surface intake/outtake in Connector Mandela (phone stack → Mac side-by-side)

When Hermen-named docs appear later, fold them under this genotype — do not fork a parallel protocol.

---

## Capability handshake (hearing aids / multi-mic)

```text
IF a connected device advertises multi-mic or enhanced-hearing capability
  THEN show those settings
ELSE hide them
```

- No empty “hearing aid mode” when no such device is present.
- Same expand/contract law as connectors and API keys.
- Heuristics may miss devices → show under generic input list always; **enhanced section only when capability seen**.

---

## Settings → Voice & capture (Mac first)

Implemented:

- Mic permission status + Request + Open System Settings
- Preferred input / output pickers (System default + live devices)
- Test capture (live level; does not claim STT success)
- Enhanced hearing section **only if** connected device capabilities match

---

## Optimal translator note

| Situation | Lean toward |
|-----------|-------------|
| On-device, privacy-first, offline | Local STT (Whisper-class later) or Apple Speech |
| Quality / multilingual / already in cloud path | Hosted STT (“Max translator” when that is the optimal route) |
| Multi-motor app needs text object | Always: packet first → then translator → object |

Settings should eventually expose **preferred STT route** as a separate control from **preferred mic** — not one mega-toggle.

---

## One line

**Mic → packet (zero-loss intent) → dock across surfaces → translate only when text is needed → never collapse hearing-device settings until the device is actually there.**
