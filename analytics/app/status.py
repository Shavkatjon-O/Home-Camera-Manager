"""Small HTTP server for the status endpoint, the live objects, health and photo embedding."""

from __future__ import annotations

import hmac
import json
import logging
import threading
from collections.abc import Callable
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

logger = logging.getLogger(__name__)

EMBED_MAX_BYTES = 12 * 1024 * 1024


class StatusServer:
    """Serves the service state as JSON and fresh view pictures as JPEG.

    Routes: GET /health, GET /status, GET /views/<view id>/objects and GET /views/<view id>/snapshot.jpg, the
    last with reference=1 to keep the picture as a zone reference, and POST /identity/embed, which finds and embeds
    the faces of a photo sent as the request body. Every route but /health needs the shared token as a bearer token
    when one is set.

    Attributes:
        port: TCP port.
        token: Shared token, empty to serve without one.
        status: Returns the full status.
        objects: Returns the live objects of a view.
        snapshot: Returns a fresh picture of a view.
        embed: Answers a photo with the HTTP status and the JSON body of its faces.
    """

    def __init__(
        self,
        port: int,
        token: str,
        status: Callable[[], dict],
        objects: Callable[[str], dict | None],
        snapshot: Callable[[str, bool], tuple[bytes, str | None] | None],
        embed: Callable[[bytes], tuple[int, dict]] | None = None,
    ):
        """Create the server; call start to serve.

        Args:
            port: TCP port.
            token: Shared token, empty to serve without one.
            status: Returns the full status.
            objects: Returns the live objects of a view, or None for an unknown view.
            snapshot: Returns a JPEG of a view and its reference path, or None.
            embed: Answers a photo with the HTTP status and the JSON body of its faces, None to refuse photos.
        """
        self.port = port
        self.token = token
        self.status = status
        self.objects = objects
        self.snapshot = snapshot
        self.embed = embed
        self.server: ThreadingHTTPServer | None = None

    def start(self) -> None:
        """Serve in a background thread."""
        owner = self

        class Handler(BaseHTTPRequestHandler):
            """Answers the status routes."""

            def reply(self, code: int, payload: bytes, content_type: str, headers: dict | None = None) -> None:
                """Send a complete response.

                Args:
                    code: HTTP status.
                    payload: Body.
                    content_type: Media type of the body.
                    headers: Extra headers.
                """
                self.send_response(code)
                self.send_header("Content-Type", content_type)
                self.send_header("Content-Length", str(len(payload)))
                self.send_header("Cache-Control", "no-store")
                for name, value in (headers or {}).items():
                    self.send_header(name, value)
                self.end_headers()
                self.wfile.write(payload)

            def authorised(self) -> bool:
                """Check the shared token and refuse the request without it.

                Returns:
                    True when the request may go on.
                """
                if owner.token and not hmac.compare_digest(
                    self.headers.get("Authorization", ""), f"Bearer {owner.token}"
                ):
                    self.reply(401, b'{"detail": "unauthorized"}', "application/json")
                    return False
                return True

            def do_POST(self) -> None:
                """Answer a POST request."""
                path = self.path.partition("?")[0].rstrip("/")
                if not self.authorised():
                    return
                if path != "/identity/embed" or owner.embed is None:
                    self.reply(404, b'{"detail": "not found"}', "application/json")
                    return
                length = int(self.headers.get("Content-Length") or 0)
                if length <= 0 or length > EMBED_MAX_BYTES:
                    self.reply(
                        413 if length else 400, b'{"detail": "send one photo of at most 12 MB"}', "application/json"
                    )
                    return
                code, body = owner.embed(self.rfile.read(length))
                self.reply(code, json.dumps(body).encode(), "application/json")

            def do_GET(self) -> None:
                """Answer a GET request."""
                path, _, query = self.path.partition("?")
                path = path.rstrip("/")
                if path != "/health" and not self.authorised():
                    return
                body: dict | None = None
                if path == "/health":
                    body = {"status": "ok"}
                elif path == "/status":
                    body = owner.status()
                elif path.startswith("/views/") and path.endswith("/objects"):
                    body = owner.objects(path[len("/views/") : -len("/objects")])
                elif path.startswith("/views/") and path.endswith("/snapshot.jpg"):
                    picture = owner.snapshot(path[len("/views/") : -len("/snapshot.jpg")], "reference=1" in query)
                    if picture is not None:
                        data, reference = picture
                        self.reply(200, data, "image/jpeg", {"X-Reference": reference} if reference else None)
                        return
                if body is None:
                    self.reply(404, b'{"detail": "not found"}', "application/json")
                    return
                self.reply(200, json.dumps(body).encode(), "application/json")

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
