#!/usr/bin/env python3
"""
▲ ATLAS MCP Server — Intelligence / Design
Frequency: 528 Hz (Port 5280)
"""

from __future__ import annotations

import json
import logging
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from socketserver import ThreadingMixIn
from pathlib import Path
from typing import Any, Dict, List

SYMBOL = "▲"
NAME = "ATLAS"
PORT = 5280
FREQUENCY = 528
FUNCTION = "Intelligence / Design"
VERSION = "1.0.0"

logging.basicConfig(
    level=logging.INFO,
    format=f"{SYMBOL} %(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)

DATA_DIR = Path(__file__).with_name("data")
DESIGNS_PATH = DATA_DIR / "design_registry.json"
ANALYTICS_PATH = DATA_DIR / "intelligence_history.json"

DATA_DIR.mkdir(exist_ok=True)


def load_json(path: Path, default: Any) -> Any:
    if not path.exists():
        return default
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        logger.warning("Failed to parse %s; resetting.", path)
        return default


def save_json(path: Path, payload: Any) -> None:
    path.write_text(json.dumps(payload, indent=2), encoding="utf-8")


def ensure_store() -> None:
    if not DESIGNS_PATH.exists():
        save_json(DESIGNS_PATH, [])
    if not ANALYTICS_PATH.exists():
        save_json(ANALYTICS_PATH, [])


ensure_store()


class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """Handle requests in their own threads."""


class ATLASRequestHandler(BaseHTTPRequestHandler):
    server_version = f"{NAME}-MCP/{VERSION}"

    def log_message(self, format: str, *args: Any) -> None:  # noqa: A003
        logger.info("%s - %s", self.address_string(), format % args)

    def _write_json(self, payload: Dict[str, Any]) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:  # noqa: N802
        if self.path == "/health":
            self._write_json(self._health_payload())
        elif self.path == "/resonance":
            self._write_json(self._resonance_payload())
        elif self.path.startswith("/design/"):
            pattern = self.path.rsplit("/", 1)[-1]
            self._write_json(self._design_pattern(pattern))
        elif self.path == "/designs":
            self._write_json(self._list_designs())
        elif self.path == "/intelligence/history":
            self._write_json(self._intelligence_history())
        else:
            self._write_json(self._root_payload())

    def do_POST(self) -> None:  # noqa: N802
        length = int(self.headers.get("Content-Length", "0") or "0")
        raw = self.rfile.read(length)
        try:
            envelope = json.loads(raw.decode("utf-8"))
        except json.JSONDecodeError:
            self.send_error(400, "Invalid JSON payload")
            return

        context = envelope.get("geometric_context") if isinstance(envelope, dict) else None
        if context:
            logger.debug("Received geometric context: %s", context)
        data = envelope.get("payload") if isinstance(envelope, dict) and "payload" in envelope else envelope
        if not isinstance(data, dict):
            self.send_error(400, "Payload must be a JSON object")
            return

        if self.path == "/design/create":
            self._write_json(self._create_design(data))
        elif self.path == "/intelligence/analyze":
            self._write_json(self._analyze_intelligence(data))
        elif self.path == "/design/archive":
            self._write_json(self._archive_design(data))
        else:
            self.send_error(404, "Unknown endpoint")

    def _health_payload(self) -> Dict[str, Any]:
        return {
            "status": "operational",
            "name": f"{SYMBOL} {NAME}",
            "frequency_hz": FREQUENCY,
            "port": PORT,
            "function": FUNCTION,
            "timestamp": datetime.now().isoformat(),
            "version": VERSION,
        }

    def _resonance_payload(self) -> Dict[str, Any]:
        return {
            "resonance_status": "aligned",
            "harmonic_layer": "Sacred Trident",
            "geometric_position": "Intelligence/Design Node",
            "frequency_hz": FREQUENCY,
            "timestamp": datetime.now().isoformat(),
        }

    def _root_payload(self) -> Dict[str, Any]:
        return {
            "service": f"{SYMBOL} {NAME} MCP Server",
            "frequency_hz": FREQUENCY,
            "function": FUNCTION,
            "endpoints": [
                "/health",
                "/resonance",
                "/design/{pattern}",
                "/design/create",
                 "/design/archive",
                "/designs",
                "/intelligence/analyze",
                "/intelligence/history",
            ],
            "description": "Pattern intelligence and design synthesis node for the Sacred FIELD lattice.",
        }

    def _design_pattern(self, pattern: str) -> Dict[str, Any]:
        registry: List[Dict[str, Any]] = load_json(DESIGNS_PATH, [])
        for design in registry:
            if design["name"] == pattern:
                logger.info("Retrieving stored design %s", pattern)
                return {"status": "found", "design": design}

        logger.info("Synthetically generating design %s", pattern)
        return {
            "status": "generated",
            "design": {
                "name": pattern,
                "components": ["core", "boundary", "flow"],
                "geometric_basis": "tetrahedral",
                "created_at": datetime.now().isoformat(),
            },
        }

    def _create_design(self, data: Dict[str, Any]) -> Dict[str, Any]:
        name = data.get("name", "unnamed_design")
        registry: List[Dict[str, Any]] = load_json(DESIGNS_PATH, [])
        design_record = {
            "name": name,
            "intent": data.get("intent", ""),
            "geometry": data.get("geometry", "tetrahedral"),
            "components": data.get("components", ["core", "boundary", "flow"]),
            "created_at": datetime.now().isoformat(),
        }
        logger.info("Creating design %s (geometry=%s)", name, design_record["geometry"])
        registry.append(design_record)
        save_json(DESIGNS_PATH, registry[-500:])
        return {"status": "created", "design": design_record}

    def _analyze_intelligence(self, data: Dict[str, Any]) -> Dict[str, Any]:
        pattern = data.get("pattern", "unspecified")
        vectors = data.get("vectors", [])

        intelligence_score = 0.4
        if vectors:
            intelligence_score = min(1.0, 0.5 + 0.1 * len(vectors))
        if "symmetry" in pattern.lower():
            intelligence_score = min(1.0, intelligence_score + 0.2)

        logger.info(
            "Analyzing intelligence pattern %s (score=%.2f vectors=%d)",
            pattern,
            intelligence_score,
            len(vectors),
        )

        record = {
            "pattern": pattern,
            "intelligence_score": intelligence_score,
            "recognized_geometry": data.get("geometry", "tetrahedral"),
            "vectors": vectors,
            "timestamp": datetime.now().isoformat(),
        }
        history: List[Dict[str, Any]] = load_json(ANALYTICS_PATH, [])
        history.append(record)
        save_json(ANALYTICS_PATH, history[-300:])

        return {"status": "analyzed", **record}

    def _archive_design(self, data: Dict[str, Any]) -> Dict[str, Any]:
        name = data.get("name")
        if not name:
            return {"status": "error", "message": "Design name required"}
        registry: List[Dict[str, Any]] = load_json(DESIGNS_PATH, [])
        retained = [design for design in registry if design["name"] != name]
        removed = len(registry) - len(retained)
        save_json(DESIGNS_PATH, retained)
        logger.info("Archived design %s (removed=%s)", name, bool(removed))
        return {"status": "archived" if removed else "missing", "design_name": name}

    def _list_designs(self) -> Dict[str, Any]:
        registry: List[Dict[str, Any]] = load_json(DESIGNS_PATH, [])
        return {"count": len(registry), "designs": registry}

    def _intelligence_history(self) -> Dict[str, Any]:
        history: List[Dict[str, Any]] = load_json(ANALYTICS_PATH, [])
        return {"count": len(history), "analyses": history}


def run() -> None:
    server = ThreadedHTTPServer(("", PORT), ATLASRequestHandler)
    logger.info("Starting %s %s MCP server on port %s", SYMBOL, NAME, PORT)
    logger.info("Frequency: %s Hz — Function: %s", FREQUENCY, FUNCTION)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        logger.info("Stopping %s MCP server", NAME)
    finally:
        server.server_close()


if __name__ == "__main__":
    run()
