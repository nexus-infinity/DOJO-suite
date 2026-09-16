# Credential Custody & Capability Boundary Certification V0

**Status:** `IMPLEMENTED.LOCAL` · live provider results remain per-receipt
`PASS | FAIL | UNKNOWN | HOLD`

## Object

Certify the operational boundary of existing FIELD credentials without exposing,
copying, migrating, rotating, or deleting secret material.

This is a support seam for DOJO Today. It does not merge wireframe
infrastructure, processing, or experience.

## Custody law

- DOJO hosted-provider keys remain in the existing macOS Keychain service
  `org.field.dojo.m1.api-keys`.
- FIELD Gemini CLI remains on the existing `/Users/field/.env` path, governed by
  `FIELD_GEMINI_API_CREDENTIAL_ORDER_V0.md`.
- Other `.env` files are inventory-only until a lawful owner and purpose are
  established.
- The Apple worksheet and any passcode remain metadata-only `HOLD`.

No command in this project prints key material, authorization headers, response
bodies, worksheet contents, or passcodes.

## Scope

The allowlist covers DOJO hosted providers (OpenAI, Anthropic, Google/Gemini,
xAI) and existing FIELD connector references (Hugging Face, GitHub, Vercel,
Notion, Linear, Figma, Keymate, and GCP ADC where a canonical safe probe is
available). Payment, trading, database, Supabase, and unrelated application
secrets are excluded.

The bounded runner is:

```text
/Users/field/scripts/test_all_credentials.py
```

Default mode performs metadata inventory only. `--smoke` performs minimal
read-only provider calls using credentials already present in the process
environment. DOJO Keychain credentials are not imported into the runner.

## Capability boundary

```text
provider
  → non-secret custody reference
  → configured
  → reachable
  → responding
  → model-compatible
  → composer-eligible
```

Key presence alone never promotes a provider. The DOJO app projects the status
through `CapabilityBoundaryResult`; composer exposure remains closed in this
support contract. External MCP exposure continues to follow the existing
`DOJO.Today.MCPSmokeReceipt.V0` readiness contract.

## Receipts

The runner emits `FIELD.CredentialCapabilityReceipt.V0` receipts under:

```text
/Users/field/◎Kings-Chamber/chronicle/receipts/
```

Each receipt contains only provider/capability, non-secret reference, endpoint,
probe type, status code, stage, decision, timestamp, and required next evidence.
Receipts are local evidence. Notion receives a pointer/status projection only;
it is not credential authority.

The existing Tier 2 admission loader accepts receipts only from these approved
homes: `/Users/field/logs/mcp/`, the DOJO application support receipt home,
and the canonical Chronicle receipt home
`/Users/field/◎Kings-Chamber/chronicle/receipts/`. The allowlist is path-bound
and does not permit arbitrary filesystem locations.

## Verification

Required checks are static inventory, redaction, offline boundary tests, Gemini
model-order compatibility, provider smoke results, and external observation of
unchanged secret custody. Unsupported or untestable paths remain `HOLD`.
