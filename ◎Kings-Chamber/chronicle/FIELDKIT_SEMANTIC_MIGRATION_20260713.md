## FieldKit semantic migration - additive model seal

**Timestamp:** 2026-07-13 (Melbourne)

**Observed:** `Packet.swift` and `PacketReceipt.swift` now carry optional semantic fields:
`resonance`, `workLayerStatus`, and `semanticHoldReasons`.

**Validation:** Old packet and receipt JSON decode still passes. New encode includes
all semantic fields. Xcode build and native/SwiftPM-style typechecks pass.

**Boundary:** No upload, persistence, repository, state, UI, or ParticleBoard
semantics changed. Semantic fields are carried as contract metadata only and are
not treated as proof.

**Status:** Implemented and validated. Commit: `ac7b96c`.
