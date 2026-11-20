"""Client of the backend's internal analytics endpoints: configuration, events and observations."""

from __future__ import annotations

import hashlib
import json
import logging
import queue
import threading
import time
import urllib.error
import urllib.request

logger = logging.getLogger(__name__)

TIMEOUT_SECONDS = 5
OUTBOX_LIMIT = 2000
RETRY_DELAYS = (1, 2, 5, 10, 30)


class BackendClient:
    """Talks to the backend with the shared token.

    Attributes:
        url: Backend base URL.
        token: Shared token.
    """

    def __init__(self, url: str, token: str):
        """Create the client.

        Args:
            url: Backend base URL such as http://backend:8000.
            token: Shared token sent as a bearer token.
        """
        self.url = url.rstrip("/")
        self.token = token

    def request(self, method: str, path: str, body: dict | None = None) -> dict | None:
        """Send one request.

        Args:
            method: HTTP method.
            path: Path below the base URL.
            body: JSON body, if any.

        Returns:
            The decoded JSON answer, or None for an empty one.

        Raises:
            OSError: If the backend cannot be reached or answers with an error status.
        """
        data = json.dumps(body).encode() if body is not None else None
        request = urllib.request.Request(f"{self.url}{path}", data=data, method=method)
        request.add_header("Authorization", f"Bearer {self.token}")
        if data is not None:
            request.add_header("Content-Type", "application/json")
        with urllib.request.urlopen(request, timeout=TIMEOUT_SECONDS) as response:
            payload = response.read()
        return json.loads(payload) if payload else None


class BackendConfigSource:
    """Polls the backend for the configuration and reports it only when it changed.

    Attributes:
        client: The backend client.
        digest: Digest of the last configuration returned.
    """

    def __init__(self, client: BackendClient):
        """Create the source.

        Args:
            client: The backend client.
        """
        self.client = client
        self.digest: str | None = None

    def poll(self) -> dict | None:
        """Fetch the configuration.

        Returns:
            The configuration when it changed since the last call, otherwise None.

        Raises:
            OSError: If the backend cannot be reached.
        """
        data = self.client.request("GET", "/internal/analytics/config")
        if data is None:
            return None
        digest = hashlib.sha256(json.dumps(data, sort_keys=True).encode()).hexdigest()
        if digest == self.digest:
            return None
        self.digest = digest
        return data


class Outbox:
    """Delivers events and observations to the backend in order, retrying while it is away.

    Attributes:
        client: The backend client.
        items: Pending deliveries.
        delivered: Deliveries that succeeded.
        failures: Consecutive failed attempts.
        last_error: Latest delivery error.
    """

    def __init__(self, client: BackendClient):
        """Create the outbox; call start to deliver.

        Args:
            client: The backend client.
        """
        self.client = client
        self.items: queue.Queue = queue.Queue(maxsize=OUTBOX_LIMIT)
        self.delivered = 0
        self.failures = 0
        self.last_error: str | None = None
        self.stopping = threading.Event()

    def start(self) -> None:
        """Deliver in a background thread."""
        threading.Thread(target=self.loop, name="outbox", daemon=True).start()

    def send(self, path: str, body: dict, droppable: bool = False) -> None:
        """Queue a delivery.

        Args:
            path: Endpoint path.
            body: JSON body.
            droppable: True for observations, which are dropped rather than queued while the backend is away.
        """
        if droppable and self.failures:
            return
        try:
            self.items.put_nowait((path, body, droppable))
        except queue.Full:
            logger.warning("The backend outbox is full, dropping a delivery to %s", path)

    def loop(self) -> None:
        """Deliver queued items one by one."""
        while not self.stopping.is_set():
            try:
                path, body, droppable = self.items.get(timeout=1)
            except queue.Empty:
                continue
            while not self.stopping.is_set():
                try:
                    self.client.request("POST", path, body)
                except (OSError, ValueError) as exc:
                    self.failures += 1
                    self.last_error = f"{time.strftime('%H:%M:%S')} {type(exc).__name__}: {exc}"
                    if droppable:
                        break
                    if isinstance(exc, urllib.error.HTTPError) and 400 <= exc.code < 500 and exc.code != 429:
                        logger.warning("The backend refused a delivery to %s: %s", path, exc)
                        break
                    self.stopping.wait(RETRY_DELAYS[min(self.failures - 1, len(RETRY_DELAYS) - 1)])
                    continue
                self.failures = 0
                self.delivered += 1
                break
