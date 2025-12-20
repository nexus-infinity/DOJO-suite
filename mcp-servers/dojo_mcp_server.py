#!/usr/bin/env python3
"""
◼︎ DOJO MCP Server — Training / Execution
Frequency: 396 Hz (Port 3960)
"""

from __future__ import annotations

import json
import logging
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from socketserver import ThreadingMixIn
from pathlib import Path
from typing import Any, Dict, List

SYMBOL = "◼︎"
NAME = "DOJO"
PORT = 3960
FREQUENCY = 396
FUNCTION = "Training / Execution"
VERSION = "1.0.0"

logging.basicConfig(
    level=logging.INFO,
    format=f"{SYMBOL} %(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)

DATA_DIR = Path(__file__).with_name("data")
TRAINING_PATH = DATA_DIR / "training_sessions.json"
EXECUTION_PATH = DATA_DIR / "execution_log.json"

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
    if not TRAINING_PATH.exists():
        save_json(TRAINING_PATH, [])
    if not EXECUTION_PATH.exists():
        save_json(EXECUTION_PATH, [])


ensure_store()


class DojoHandler(BaseHTTPRequestHandler):
    """Handle DOJO training and execution requests."""

    def do_GET(self):
        """Handle GET requests."""
        if self.path == "/health":
            self._respond(200, {"status": "healthy", "server": NAME, "frequency": FREQUENCY})
        elif self.path == "/training":
            sessions = load_json(TRAINING_PATH, [])
            self._respond(200, {"sessions": sessions})
        elif self.path == "/executions":
            logs = load_json(EXECUTION_PATH, [])
            self._respond(200, {"executions": logs})
        else:
            self._respond(404, {"error": "Not found"})

    def do_POST(self):
        """Handle POST requests."""
        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length).decode("utf-8")
        
        try:
            data = json.loads(body)
        except json.JSONDecodeError:
            self._respond(400, {"error": "Invalid JSON"})
            return

        if self.path == "/training/start":
            self._start_training(data)
        elif self.path == "/execution/run":
            self._run_execution(data)
        else:
            self._respond(404, {"error": "Not found"})

    def _start_training(self, data: Dict[str, Any]):
        """Start a training session."""
        sessions = load_json(TRAINING_PATH, [])
        session = {
            "id": len(sessions) + 1,
            "timestamp": datetime.now().isoformat(),
            "config": data,
            "status": "started"
        }
        sessions.append(session)
        save_json(TRAINING_PATH, sessions)
        logger.info(f"Training session started: {session['id']}")
        self._respond(201, {"session": session})

    def _run_execution(self, data: Dict[str, Any]):
        """Run an execution task."""
        logs = load_json(EXECUTION_PATH, [])
        execution = {
            "id": len(logs) + 1,
            "timestamp": datetime.now().isoformat(),
            "task": data,
            "status": "completed"
        }
        logs.append(execution)
        save_json(EXECUTION_PATH, logs)
        logger.info(f"Execution completed: {execution['id']}")
        self._respond(200, {"execution": execution})

    def _respond(self, code: int, payload: Dict[str, Any]):
        """Send JSON response."""
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(payload).encode("utf-8"))

    def log_message(self, format: str, *args):
        """Override to use custom logger."""
        logger.info(format % args)


class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """Handle requests in separate threads."""
    pass


def run_server():
    """Run the DOJO MCP server."""
    server = ThreadedHTTPServer(("0.0.0.0", PORT), DojoHandler)
    logger.info(f"{SYMBOL} DOJO MCP Server starting on port {PORT} ({FREQUENCY}Hz)")
    logger.info(f"{SYMBOL} Function: {FUNCTION}")
    server.serve_forever()


if __name__ == "__main__":
    run_server()
