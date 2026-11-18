import asyncio
from dataclasses import dataclass
from datetime import UTC, datetime
from uuid import UUID

PROBE_TIMEOUT_SECONDS = 2.0


@dataclass(frozen=True)
class ProbeResult:
    online: bool | None = None
    checked_at: datetime | None = None
    error: str | None = None


UNKNOWN = ProbeResult()


class StatusStore:
    def __init__(self):
        self.results: dict[UUID, tuple[tuple[str, int], ProbeResult]] = {}

    def get(self, camera_uuid: UUID, host: str, port: int) -> ProbeResult:
        entry = self.results.get(camera_uuid)
        if entry is None or entry[0] != (host, port):
            return UNKNOWN
        return entry[1]

    def record(self, camera_uuid: UUID, host: str, port: int, result: ProbeResult) -> None:
        self.results[camera_uuid] = ((host, port), result)

    def forget(self, camera_uuid: UUID) -> None:
        self.results.pop(camera_uuid, None)

    def retain(self, camera_uuids: set[UUID]) -> None:
        for camera_uuid in list(self.results):
            if camera_uuid not in camera_uuids:
                self.results.pop(camera_uuid, None)


def probe_error(exc: BaseException) -> str:
    if isinstance(exc, TimeoutError):
        return f"No answer within {PROBE_TIMEOUT_SECONDS:g} s"
    if isinstance(exc, ConnectionRefusedError):
        return "Connection refused"
    if isinstance(exc, OSError) and exc.strerror:
        return exc.strerror
    return type(exc).__name__


async def probe(host: str, port: int, timeout: float = PROBE_TIMEOUT_SECONDS) -> ProbeResult:
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
