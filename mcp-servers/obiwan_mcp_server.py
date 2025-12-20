#!/usr/bin/env python3
"""
● OBI-WAN MCP Server — Observer / Memory
Frequency: 639 Hz (Port 6390)
"""

from __future__ import annotations

import json
import logging
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from socketserver import ThreadingMixIn
from pathlib import Path
from typing import Any, Dict, List

SYMBOL = "●"
NAME = "OBI-WAN"
PORT = 6390
FREQUENCY = 639
FUNCTION = "Observer / Memory"
VERSION = "1.0.0"

logging.basicConfig(
    level=logging.INFO,
    format=f"{SYMBOL} %(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)

DATA_DIR = Path(__file__).with_name("data")
MEMORY_PATH = DATA_DIR / "memory_store.json"
OBSERVATION_PATH = DATA_DIR / "observation_log.json"

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
    if not MEMORY_PATH.exists():
        save_json(MEMORY_PATH, [])
    if not OBSERVATION_PATH.exists():
        save_json(OBSERVATION_PATH, [])


ensure_store()


class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """Serve each request in its own thread."""


class OBIWANRequestHandler(BaseHTTPRequestHandler):
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
        elif self.path.startswith("/observe/"):
            entity = self.path.rsplit("/", 1)[-1]
            self._write_json(self._observe_entity(entity))
        elif self.path.startswith("/memory/"):
            memory_id = self.path.rsplit("/", 1)[-1]
            self._write_json(self._retrieve_memory(memory_id))
        elif self.path == "/memories":
            self._write_json(self._list_memories())
        elif self.path == "/observations":
            self._write_json(self._observation_history())
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

        if self.path == "/memory/store":
            self._write_json(self._store_memory(data))
        elif self.path == "/observe/record":
            self._write_json(self._record_observation(data))
        elif self.path == "/memory/retire":
            self._write_json(self._retire_memory(data))
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
            "geometric_position": "Observer/Memory Node",
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
                "/observe/{entity}",
                "/observe/record",
                "/memory/{id}",
                "/memory/store",
                "/memory/retire",
                "/memories",
                "/observations",
            ],
            "description": "Observer and memory anchoring node for the Sacred FIELD lattice.",
        }

    def _observe_entity(self, entity: str) -> Dict[str, Any]:
        logger.info("Observing entity %s", entity)
        return {
            "entity": entity,
            "observation_state": "recorded",
            "timestamp": datetime.now().isoformat(),
            "observer": f"{SYMBOL} {NAME}",
        }

    def _retrieve_memory(self, memory_id: str) -> Dict[str, Any]:
        store: List[Dict[str, Any]] = load_json(MEMORY_PATH, [])
        for memory in store:
            if memory["memory_id"] == memory_id:
                logger.info("Retrieving memory %s", memory_id)
                memory["retrieved_at"] = datetime.now().isoformat()
                return {"status": "found", "memory": memory}
        logger.info("Memory %s not found", memory_id)
        return {"status": "missing", "memory_id": memory_id}

    def _store_memory(self, data: Dict[str, Any]) -> Dict[str, Any]:
        title = data.get("title", "untitled_memory")
        store: List[Dict[str, Any]] = load_json(MEMORY_PATH, [])
        memory_record = {
            "memory_id": f"mem-{datetime.now().timestamp():.0f}",
            "title": title,
            "content": data.get("content", ""),
            "tags": data.get("tags", []),
            "created_at": datetime.now().isoformat(),
        }
        logger.info("Storing memory %s (tags=%s)", title, ",".join(memory_record["tags"]))
        store.append(memory_record)
        save_json(MEMORY_PATH, store[-500:])
        return {"status": "stored", "memory": memory_record}

    def _record_observation(self, data: Dict[str, Any]) -> Dict[str, Any]:
        entity = data.get("entity", "unspecified")
        observation = {
            "observation_id": f"obs-{datetime.now().timestamp():.0f}",
            "entity": entity,
            "details": data.get("details", ""),
            "confidence": data.get("confidence", 0.75),
            "timestamp": datetime.now().isoformat(),
        }
        logger.info("Recording observation for %s (confidence=%.2f)", entity, observation["confidence"])
        history: List[Dict[str, Any]] = load_json(OBSERVATION_PATH, [])
        history.append(observation)
        save_json(OBSERVATION_PATH, history[-500:])
        return {"status": "recorded", "observation": observation}

    def _retire_memory(self, data: Dict[str, Any]) -> Dict[str, Any]:
        memory_id = data.get("memory_id")
        if not memory_id:
            return {"status": "error", "message": "memory_id required"}
        store: List[Dict[str, Any]] = load_json(MEMORY_PATH, [])
        retained = [memory for memory in store if memory["memory_id"] != memory_id]
        removed = len(store) - len(retained)
        save_json(MEMORY_PATH, retained)
        logger.info("Retired memory %s (removed=%s)", memory_id, bool(removed))
        return {"status": "retired" if removed else "missing", "memory_id": memory_id}

    def _list_memories(self) -> Dict[str, Any]:
        store: List[Dict[str, Any]] = load_json(MEMORY_PATH, [])
        return {"count": len(store), "memories": store}

    def _observation_history(self) -> Dict[str, Any]:
        history: List[Dict[str, Any]] = load_json(OBSERVATION_PATH, [])
        return {"count": len(history), "observations": history}


def run() -> None:
    server = ThreadedHTTPServer(("", PORT), OBIWANRequestHandler)
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
