"""Small HTTP server for the status endpoint, the live objects and health."""

from __future__ import annotations

import json
import logging
import threading
from collections.abc import Callable
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

logger = logging.getLogger(__name__)


class StatusServer:
    """Serves the service state as JSON.

    Routes: GET /health, GET /status and GET /views/<view id>/objects.

    Attributes:
        port: TCP port.
        routes: Path to a callable returning the JSON body, or None for 404.
    """

    def __init__(self, port: int, status: Callable[[], dict], objects: Callable[[str], dict | None]):
        """Create the server; call start to serve.

        Args:
            port: TCP port.
            status: Returns the full status.
            objects: Returns the live objects of a view, or None for an unknown view.
        """
        self.port = port
        self.status = status
        self.objects = objects
        self.server: ThreadingHTTPServer | None = None

    def start(self) -> None:
        """Serve in a background thread."""
        owner = self

        class Handler(BaseHTTPRequestHandler):
            """Answers the status routes."""

            def do_GET(self) -> None:
                """Answer a GET request."""
                path = self.path.split("?", 1)[0].rstrip("/")
                body: dict | None
                if path == "/health":
                    body = {"status": "ok"}
                elif path == "/status":
                    body = owner.status()
                elif path.startswith("/views/") and path.endswith("/objects"):
                    body = owner.objects(path[len("/views/") : -len("/objects")])
                else:
                    body = None
                payload = json.dumps(body if body is not None else {"detail": "not found"}).encode()
                self.send_response(200 if body is not None else 404)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(payload)))
                self.send_header("Cache-Control", "no-store")
                self.end_headers()
                self.wfile.write(payload)

            def log_message(self, format: str, *args) -> None:
                """Silence the per-request access log.

                Args:
                    format: Log format.
                    *args: Format arguments.
                """

        self.server = ThreadingHTTPServer(("0.0.0.0", self.port), Handler)
        threading.Thread(target=self.server.serve_forever, name="status", daemon=True).start()
        logger.info("Status endpoint on port %d", self.port)

    def stop(self) -> None:
        """Stop serving."""
        if self.server:
            self.server.shutdown()
