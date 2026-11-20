"""The control socket of a stream process: one JSON request and one JSON answer per line, over a Unix socket.

A stream process holds the camera's only session, so other processes on the same host, such as the connector
agent or the relay's HTTP API, send their PTZ, light, siren and picture commands through its socket.
"""

import asyncio
import contextlib
import json
import logging
import os
from collections.abc import Awaitable, Callable
from pathlib import Path

__all__ = ["DEFAULT_DIRECTORY", "ControlServer", "send", "socket_path"]

logger = logging.getLogger(__name__)

DEFAULT_DIRECTORY = "/tmp/sss-v380"
LINE_LIMIT = 4096
TIMEOUT_SECONDS = 5.0

Handler = Callable[[dict], Awaitable[dict]]


def socket_path(directory: str, device_id: int | str, stream: str) -> Path:
    """Name the control socket of a camera stream.

    Args:
        directory: Directory of the sockets.
        device_id: Device id of the camera.
        stream: main or sub.

    Returns:
        The socket path.
    """
    return Path(directory) / f"{device_id}-{stream}.sock"


class ControlServer:
    """Serves control requests on a Unix socket.

    Attributes:
        path: Socket path.
        handler: Coroutine that answers a request.
        server: The running server, if any.
    """

    def __init__(self, path: Path, handler: Handler):
        """Create the server, not yet listening.

        Args:
            path: Socket path.
            handler: Coroutine that answers a request.
        """
        self.path = path
        self.handler = handler
        self.server: asyncio.base_events.Server | None = None

    async def start(self) -> None:
        """Listen, replacing a stale socket file that nobody serves."""
        self.path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        if self.path.exists():
            try:
                await send(self.path, {"command": "facts"}, timeout=1.0)
            except OSError:
                self.path.unlink(missing_ok=True)
            else:
                raise OSError(f"Another stream process serves {self.path}")
        self.server = await asyncio.start_unix_server(self.serve, path=str(self.path), limit=LINE_LIMIT)
        os.chmod(self.path, 0o600)

    async def serve(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter) -> None:
        """Answer the requests of one client.

        Args:
            reader: Client reader.
            writer: Client writer.
        """
        try:
            while line := await reader.readline():
                try:
                    request = json.loads(line)
                    answer = await self.handler(request) if isinstance(request, dict) else {"ok": False}
                except ValueError:
                    answer = {"ok": False, "error": "invalid"}
                writer.write(json.dumps(answer).encode() + b"\n")
                await writer.drain()
        except (OSError, asyncio.LimitOverrunError, ValueError):
            pass
        finally:
            writer.close()

    async def stop(self) -> None:
        """Stop listening and remove the socket file."""
        if self.server is not None:
            self.server.close()
            with contextlib.suppress(OSError):
                await self.server.wait_closed()
        self.path.unlink(missing_ok=True)


async def send(path: Path | str, request: dict, timeout: float = TIMEOUT_SECONDS) -> dict:
    """Send one request to a control socket.

    Args:
        path: Socket path.
        request: The request.
        timeout: Seconds to wait for the answer.

    Returns:
        The answer.

    Raises:
        OSError: Nobody serves the socket or the answer did not come in time.
    """
    try:
        reader, writer = await asyncio.wait_for(asyncio.open_unix_connection(str(path)), timeout)
    except TimeoutError:
        raise OSError(f"The control socket {path} does not answer")
    try:
        writer.write(json.dumps(request).encode() + b"\n")
        await writer.drain()
        line = await asyncio.wait_for(reader.readline(), timeout)
    except TimeoutError:
        raise OSError(f"The control socket {path} does not answer")
    finally:
        writer.close()
    if not line:
        raise OSError(f"The control socket {path} closed without an answer")
    try:
        return json.loads(line)
    except ValueError:
        raise OSError(f"The control socket {path} answered with invalid JSON")
