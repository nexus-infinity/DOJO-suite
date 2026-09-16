#!/usr/bin/env python3
"""Re-validate Observer-Aligned Assistance Ontology JSONL + emit mapping receipt.

Does not claim runtime implementation.
"""
from __future__ import annotations

import json
import sys
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path("/Users/field/DOJO-suite")
ONTOLOGY = ROOT / "docs" / "OBSERVER_ALIGNED_ASSISTANCE_ONTOLOGY_V0.jsonl"
MAPPING = ROOT / "docs" / "OBSERVER_ALIGNED_ASSISTANCE_ATTRIBUTE_MAPPING_V0.md"
RECEIPT_DIR = ROOT / "logs" / "state_patches"
EXPECTED = 32


def main() -> int:
    if not ONTOLOGY.is_file():
        print("FAIL: ontology missing", ONTOLOGY)
        return 1

    lines = [ln for ln in ONTOLOGY.read_text(encoding="utf-8").splitlines() if ln.strip()]
    rows = []
    for i, ln in enumerate(lines, 1):
        try:
            rows.append(json.loads(ln))
        except json.JSONDecodeError as e:
            print(f"FAIL: line {i} JSON: {e}")
            return 1

    kinds = Counter(r.get("record_kind") for r in rows)
    checks = {
        "physical_records_32": len(rows) == EXPECTED,
        "json_parsing": True,
        "has_header": kinds.get("ontology_header") == 1,
        "axes_6": kinds.get("alignment_axis_definition") == 6,
        "classes_12": kinds.get("class_definition") == 12,
        "relations_6": kinds.get("relation_definition") == 6,
        "constraints_5": kinds.get("constraint") == 5,
        "specimen_labelled": any(
            r.get("record_kind") == "design_specimen"
            and r.get("specimen_status") == "HYPOTHESIS.NOT_RUNTIME_EVIDENCE"
            for r in rows
        ),
        "handoff_present": kinds.get("handoff_contract") == 1,
        "mapping_doc_exists": MAPPING.is_file(),
        "runtime_status_hold": True,  # by contract
    }

    # Framing: sensing vs assistance non-collapse in class set
    class_names = {
        r["name"]
        for r in rows
        if r.get("record_kind") == "class_definition"
    }
    checks["sensing_and_assistance_classes"] = {
        "SensingChannel",
        "AssistanceChannel",
    }.issubset(class_names)
    checks["intention_class"] = "HumanIntention" in class_names

    failed = [k for k, v in checks.items() if not v]
    status = "PASS" if not failed else "FAIL"

    receipt = {
        "schema": "DOJO.ObserverAlignedAssistance.OntologySeatReceipt.V0",
        "sealed_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "ontology_path": str(ONTOLOGY),
        "mapping_path": str(MAPPING),
        "physical_records": len(rows),
        "record_kinds": dict(kinds),
        "checks": checks,
        "failed_checks": failed,
        "validation": status,
        "runtime_status": "HOLD.NOT_IMPLEMENTED_OR_VERIFIED",
        "specimen_status": "HYPOTHESIS.NOT_RUNTIME_EVIDENCE",
        "action_class": "PRESERVE",
        "swift_types": "Sources/DOJOShared/Contracts/ObserverAlignedAssistanceOntology.swift",
        "next_bounded": [
            "consent_UX",
            "restrained_attention_test",
            "rejection_path_runtime",
            "receipt_for_cue_dry_run",
            "external_observer_seal",
        ],
        "non_claims": [
            "No live camera",
            "No live cue engine",
            "No medical efficacy",
            "No runtime authority",
        ],
    }

    RECEIPT_DIR.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    out = RECEIPT_DIR / f"observer_aligned_assistance_ontology_seat_{stamp}.json"
    out.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")

    print(f"validation: {status}")
    print(f"records: {len(rows)}")
    print(f"kinds: {dict(kinds)}")
    if failed:
        print("failed:", failed)
    print(f"receipt: {out}")
    return 0 if status == "PASS" else 1


if __name__ == "__main__":
    sys.exit(main())
