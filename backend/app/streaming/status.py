"""Reachability probes of camera ports and their latest results."""

import asyncio
from dataclasses import dataclass
from datetime import UTC, datetime
from uuid import UUID

PROBE_TIMEOUT_SECONDS = 2.0


@dataclass(frozen=True)
class ProbeResult:
    """Outcome of a reachability probe.

    Attributes:
        online: Whether the port accepted a connection, or None when it has not been probed.
        checked_at: Time of the probe.
        error: Short reason when the probe failed.
    """

    online: bool | None = None
    checked_at: datetime | None = None
    error: str | None = None


UNKNOWN = ProbeResult()


class StatusStore:
    """In-memory store of the latest probe result of each camera.

    Attributes:
        results: Latest probe result of each camera together with the host and port it was probed on.
    """

    def __init__(self):
        """Create an empty store."""
        self.results: dict[UUID, tuple[tuple[str, int], ProbeResult]] = {}

    def get(self, camera_uuid: UUID, host: str, port: int) -> ProbeResult:
        """Return the stored result of a camera.

        Args:
            camera_uuid: Camera identifier.
            host: Camera host now in use.
            port: Camera port now in use.

        Returns:
            The stored result, or an unknown result when there is none or it was probed on another host or port.
        """
        entry = self.results.get(camera_uuid)
        if entry is None or entry[0] != (host, port):
            return UNKNOWN
        return entry[1]

    def record(self, camera_uuid: UUID, host: str, port: int, result: ProbeResult) -> None:
        """Store the result of a probe.

        Args:
            camera_uuid: Camera identifier.
            host: Host that was probed.
            port: Port that was probed.
            result: Outcome of the probe.
        """
        self.results[camera_uuid] = ((host, port), result)

    def forget(self, camera_uuid: UUID) -> None:
        """Drop the stored result of a camera.

        Args:
            camera_uuid: Camera identifier.
        """
        self.results.pop(camera_uuid, None)

    def retain(self, camera_uuids: set[UUID]) -> None:
        """Drop the results of every camera not in the given set.

        Args:
            camera_uuids: Identifiers of the cameras to keep.
        """
        for camera_uuid in list(self.results):
            if camera_uuid not in camera_uuids:
                self.results.pop(camera_uuid, None)


def probe_error(exc: BaseException) -> str:
    """Describe why a probe failed.

    Args:
        exc: Exception raised by the connection attempt.

    Returns:
        A short message for a timeout or refusal, the system error text when there is one, else the exception name.
    """
    if isinstance(exc, TimeoutError):
        return f"No answer within {PROBE_TIMEOUT_SECONDS:g} s"
    if isinstance(exc, ConnectionRefusedError):
        return "Connection refused"
    if isinstance(exc, OSError) and exc.strerror:
        return exc.strerror
    return type(exc).__name__


async def probe(host: str, port: int, timeout: float = PROBE_TIMEOUT_SECONDS) -> ProbeResult:
    """Try to open a TCP connection to a host and port.

    Args:
        host: Host to connect to.
        port: Port to connect to.
        timeout: Seconds allowed for connecting and for closing.

    Returns:
        An online result when the connection opened, otherwise an offline result with the reason.
    """
    try:
        reader, writer = await asyncio.wait_for(asyncio.open_connection(host, port), timeout)
    except (OSError, TimeoutError) as exc:
        return ProbeResult(online=False, checked_at=datetime.now(UTC), error=probe_error(exc))
    writer.close()
    try:
        await asyncio.wait_for(writer.wait_closed(), timeout)
    except (OSError, TimeoutError):
        pass
    return ProbeResult(online=True, checked_at=datetime.now(UTC), error=None)
