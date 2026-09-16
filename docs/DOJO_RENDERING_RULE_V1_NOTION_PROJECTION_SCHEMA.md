# DOJO Rendering Rule v1 — Notion Projection Schema

**Status:** `SEATED.LIVE.DB` · local Today renders the witnessed `dojo` snapshot · live Notion MCP still HOLD
**Object:** `DOJO.RenderProjection.V1`
**Not:** live Notion MCP · Swift colour migration · Trek restore · SOMA embodiment · broad Today rewrite

**Parents:** messy Notion workshop · quiet DOJO typed projection · four live teamspaces witnessed 2026-08-25
**Lawful home:** `/Users/field/DOJO-suite`
**Live Notion parent:** FIELD-DOJO-HUB — Active Consciousness Navigator (`2fe04c15-e4f1-81ce-8be8-f688f76f212c`)
**Live database:** https://app.notion.com/p/c96d49fc3b9f4ce78a26c0cb498490ba
**Live data source:** `collection://61eb4b55-e283-454b-a628-5656c228dfc6`

This database is **not** the Development Diary Index. Diary = memory/registration. This = render feed.

---

## Consume tuple (hard)

DOJO consumes only:

```text
{geometry, chamber, role, evidence, authority, next, prime_state}
```

Everything else is workshop provenance. Page body, title styling, bullets, bold, emoji, Notion option colours, and teamspace chrome are **not consumed**.

Fail closed: if any consume field is empty or unknown → do not render the row. Surface `HOLD`.

---

## 1:1 map — six steps → properties

| Step | Consume key | Notion property | Type | Allowed values |
|------|-------------|-----------------|------|----------------|
| 1 | `geometry` | `geometry` | SELECT | `pyramid` · `octagon` · `spiral` · `neural` · `walk-on` |
| 1 | `chamber` | `chamber` | SELECT | `dojo` · `obiwan` · `tata` · `atlas` · `akron` · `arkadas` · `kings` |
| 2 | `role` | `role` | SELECT | `structure` · `flow` · `interface` · `observer` · `validation` |
| 3 | `evidence` | `evidence` | SELECT | `SEALED` · `HOLD` · `PROMOTE` |
| 4 | `authority` | `authority` | SELECT | `observe` · `compose` · `record` · `none` |
| 5 | `next` | `next` | RICH_TEXT | one plain sentence · no markdown |
| 6 | `prime_state` | `prime_state` | SELECT | `HOLD · not embodied` · `Unknown` |

Notion requires a title column. Name it `Name`. It is an object key, not a rendered heading.

### Workshop-only pins (filter / provenance — not consumed)

| Property | Type | Purpose |
|----------|------|---------|
| `workplace` | SELECT | Source teamspace filter |
| `source_page` | URL | Pointer back to the messy page |
| `Created` | CREATED_TIME | Workshop clock |
| `Last edited` | LAST_EDITED_TIME | Workshop clock |

`workplace` values:

| Value | Live teamspace | Geometry |
|-------|----------------|----------|
| `field-dojo-hub` | FIELD - Dojo Hub | `pyramid` |
| `stories-matter` | Stories Matter | `octagon` |
| `days-of-future-past` | Days of Future Past | `spiral` |
| `nexus-infinity` | Nexus-Infinity | `neural` |
| `trek-walk-on` | Trek - walk on (trash) | `walk-on` |

Trek is reserved. Do not seed a row until restore is asked.

---

## Colour law

Role colour is **derived in DOJO**, never stored in Notion.

| `role` | DOJO colour | Meaning |
|--------|-------------|---------|
| `structure` | Blue | structure |
| `flow` | Teal | flow |
| `interface` | Cyan | interface |
| `observer` | Purple-Indigo | observer |
| `validation` | Gold | validation |

Green is reserved. No `role` option may be green. Notion SELECT colours on this database must all be `gray` so workshop chrome cannot impersonate role.

`chamber` is identity (symbol + vertex). `role` is function. `evidence` is lifecycle. These three never share a colour channel.

**HOLD.RoleColourRetinting:** local Today keeps existing chamber identity colours for this pass. This schema does not retint the renderer by role.

---

## Authority ceiling

Caps what the surface may even offer:

| Value | Allowed to show |
|-------|-----------------|
| `observe` | read / point only |
| `compose` | observe + write the next-evidence sentence |
| `record` | observe + compose + attach a receipt pointer |
| `none` | no action affordance |

No live control of Notion, Google, GitHub, Vercel, finance, legal, or trading from a projected card.

---

## Prime fractal

Default: `HOLD · not embodied`.

SOMA genotype is acknowledged in the house. It is not forced to render. Do not add `embodied` until a later sitting with a seal.

---

## Leak strip (on `next` only)

Before consume, strip: markdown, bold, bullets, emoji, URLs, Notion mention syntax. If stripping empties the field → fail closed `HOLD`.

Do not project page body. Ever.

---

## CREATE TABLE (witnessed live)

```sql
CREATE TABLE (
  "Name" TITLE COMMENT 'Object key only; never rendered as Notion title styling',
  "geometry" SELECT('pyramid':gray, 'octagon':gray, 'spiral':gray, 'neural':gray, 'walk-on':gray) COMMENT 'Sacred-geometry type. Option colour discarded.',
  "chamber" SELECT('dojo':gray, 'obiwan':gray, 'tata':gray, 'atlas':gray, 'akron':gray, 'arkadas':gray, 'kings':gray) COMMENT 'Chamber vertex. Option colour discarded.',
  "role" SELECT('structure':gray, 'flow':gray, 'interface':gray, 'observer':gray, 'validation':gray) COMMENT 'Functional identity. DOJO maps colour locally. Green forbidden.',
  "evidence" SELECT('SEALED':gray, 'HOLD':gray, 'PROMOTE':gray) COMMENT 'Lifecycle pill. Not role.',
  "authority" SELECT('observe':gray, 'compose':gray, 'record':gray, 'none':gray) COMMENT 'Action ceiling',
  "next" RICH_TEXT COMMENT 'One next-evidence sentence. No markdown.',
  "prime_state" SELECT('HOLD · not embodied':gray, 'Unknown':gray) COMMENT 'SOMA genotype visible, not rendered',
  "workplace" SELECT('field-dojo-hub':gray, 'stories-matter':gray, 'days-of-future-past':gray, 'nexus-infinity':gray, 'trek-walk-on':gray) COMMENT 'Source filter only. Not consumed.',
  "source_page" URL COMMENT 'Provenance pointer. Not rendered.',
  "Created" CREATED_TIME,
  "Last edited" LAST_EDITED_TIME
)
```

Parent page_id: `2fe04c15e4f181ce8be8f688f76f212c`
Title: `DOJO Render Projection v1`

---

## MCP query DOJO will consume

After fetch, query **only** the consume columns.

Live data source: `collection://61eb4b55-e283-454b-a628-5656c228dfc6`

```sql
SELECT
  url,
  "geometry",
  "chamber",
  "role",
  "evidence",
  "authority",
  "next",
  "prime_state"
FROM "collection://61eb4b55-e283-454b-a628-5656c228dfc6"
WHERE "geometry" IS NOT NULL
  AND "chamber" IS NOT NULL
  AND "role" IS NOT NULL
  AND "evidence" IS NOT NULL
  AND "authority" IS NOT NULL
  AND TRIM("next") != ''
  AND "prime_state" IS NOT NULL
```

MCP call shape:

```json
{
  "data": {
    "mode": "sql",
    "data_source_urls": ["collection://61eb4b55-e283-454b-a628-5656c228dfc6"],
    "query": "SELECT url, \"geometry\", \"chamber\", \"role\", \"evidence\", \"authority\", \"next\", \"prime_state\" FROM \"collection://61eb4b55-e283-454b-a628-5656c228dfc6\" WHERE \"geometry\" IS NOT NULL AND \"chamber\" IS NOT NULL AND \"role\" IS NOT NULL AND \"evidence\" IS NOT NULL AND \"authority\" IS NOT NULL AND TRIM(\"next\") != '' AND \"prime_state\" IS NOT NULL"
  }
}
```

Tool: `notion-query-data-sources`
Do not `SELECT *`. Do not read page body via `notion-fetch` for render.

One-chamber first test: add `AND "chamber" = 'dojo'` (or the chamber under test).

---

## Seed rows (created 2026-08-25)

Four workplaces, one row each. Trek omitted. One-chamber `dojo` query returned the pyramid + octagon rows as typed tuples only.

| Name | geometry | chamber | role | evidence | authority | next | prime_state | workplace |
|------|----------|---------|------|----------|-----------|------|-------------|-----------|
| Sovereign chamber OS | pyramid | dojo | structure | HOLD | observe | Feed one chamber row and watch the quiet projection. | HOLD · not embodied | field-dojo-hub |
| Octagon narrative room | octagon | dojo | flow | HOLD | compose | Choose one rail and write one next-evidence sentence. | HOLD · not embodied | stories-matter |
| Spiral myth-engine | spiral | kings | observer | HOLD | none | Keep story non-authoritative; return one architectural question only. | HOLD · not embodied | days-of-future-past |
| Neural commercial interface | neural | atlas | interface | HOLD | observe | Label this workplace external; do not promote it as sovereign FIELD. | HOLD · not embodied | nexus-infinity |

Trek later: `geometry=walk-on`, `workplace=trek-walk-on`. No schema change.

---

## Holds

- `HOLD.LocalDojoNotConsumingLiveNotionMCP` — Today consumes the verified local snapshot; live Notion MCP is not invoked from the app
- `HOLD.RoleColourRetinting` — renderer is not migrated to role-derived tinting in this pass
- `HOLD.SomaPrimeNotEmbodied`
- `HOLD.TrekInTrash` — `walk-on` rows are dropped

**Witnessed this sitting:** local read-only snapshot of the two `dojo` tuples is WIRED on Investigations.

---

## Next lawful move

Keep the snapshot until a read-only Notion MCP smoke receipt exists. Do not restore Trek. Do not retint existing cards by role.
