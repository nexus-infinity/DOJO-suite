# MacWarp Salvage Mapping v0

**Status:** `SEATED.SPEC` · salvage map only
**Relation:** Feeds DOJO Today Panel Contract v0 — does **not** rebuild MacWarp
**Do not:** promote MacWarp production readiness

---

## KEEP

| Concept | Role in DOJO Today |
|---------|-------------------|
| Intent-to-output object idea | Composer → canvas / generated object space |
| Durable command/action/output record | Object history + optional receipt attach |
| Workspace/session continuity | Left rail Places (Today, Threads, Projects) |
| Snippets as reusable action seeds | Reusable actions/templates (later Settings/Templates) |
| Provider abstraction | Settings → Models / Providers |
| Keychain/API key handling | Settings → Keys (Keychain) |
| Local JSON persistence | Local mode + storage policy |
| Config import/export discipline | Settings → Storage / import-export |

---

## ADAPT

| MacWarp | DOJO Today |
|---------|------------|
| Blocks | DOJO object events / capture records |
| Workflows | Recipes / playbooks |
| Command history | Object history / receipt-attached timeline |
| AI provider config | Settings → Models / Providers |
| Snippets | Reusable actions / templates |
| Registry / routing | Hidden system / Developer Space only |
| Terminal sessions | Developer Space only |
| FIELD / Sacred Mirror hooks | Governed integration contracts — not first-screen claims |

---

## DO NOT

- Rebuild MacWarp
- Expose terminal shell as DOJO Today
- Expose shell / API / registry as ordinary surface
- Make generated output live in a terminal log
- Make settings or receipts the workspace
- Carry direct shell execution into ordinary Today use
- Promote MacWarp production readiness

---

## One line

**Salvage intent, objects, continuity, providers, and local persistence — hide terminal, registry, and FIELD machinery from ordinary Today.**
