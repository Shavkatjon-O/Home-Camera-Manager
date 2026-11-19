import asyncio
import time
from dataclasses import dataclass

PROBE_TIMEOUT_SECONDS = 1.5
ERROR_MAX_CHARS = 100
LATENCY_DECIMALS = 1


@dataclass(frozen=True)
class ProbeOutcome:
    ok: bool
    latency_ms: float | None = None
    error: str | None = None


def probe_error(exc: BaseException, timeout: float) -> str:
    if isinstance(exc, TimeoutError):
        message = f"No answer within {timeout:g} s"
    elif isinstance(exc, ConnectionRefusedError):
        message = "Connection refused"
    elif isinstance(exc, OSError) and exc.strerror:
        message = exc.strerror
    else:
        message = type(exc).__name__
    return message[:ERROR_MAX_CHARS]


async def tcp_probe(host: str, port: int, timeout: float = PROBE_TIMEOUT_SECONDS) -> ProbeOutcome:
    started = time.perf_counter()
    try:
        reader, writer = await asyncio.wait_for(asyncio.open_connection(host, port), timeout)
    except (OSError, TimeoutError) as exc:
        return ProbeOutcome(ok=False, error=probe_error(exc, timeout))
    latency_ms = round((time.perf_counter() - started) * 1000, LATENCY_DECIMALS)
    writer.close()
    try:
        await asyncio.wait_for(writer.wait_closed(), timeout)
    except (OSError, TimeoutError):
        pass
    return ProbeOutcome(ok=True, latency_ms=latency_ms)
