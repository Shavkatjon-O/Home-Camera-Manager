"""TCP reachability probe and its result."""

import asyncio
import time
from dataclasses import dataclass

PROBE_TIMEOUT_SECONDS = 1.5
ERROR_MAX_CHARS = 100
LATENCY_DECIMALS = 1


@dataclass(frozen=True)
class ProbeOutcome:
    """Result of one probe.

    Attributes:
        ok: True when the connection was established.
        latency_ms: Time to connect in milliseconds, set only when the probe succeeded.
        error: Short reason the probe failed, set only when it did not succeed.
    """

    ok: bool
    latency_ms: float | None = None
    error: str | None = None


def probe_error(exc: BaseException, timeout: float) -> str:
    """Describe why a probe failed in a short message.

    Args:
        exc: Exception raised while connecting.
        timeout: Timeout in seconds that was applied, quoted in the timeout message.

    Returns:
        A message naming a timeout, a refused connection, the operating system error text or the exception
        class, cut to 100 characters.
    """
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
    """Open a TCP connection to a host and port and measure how long it takes.

    Args:
        host: Address to connect to.
        port: TCP port to connect to.
        timeout: Seconds allowed for connecting, and again for closing the connection.

    Returns:
        A successful outcome with the connect latency, or a failed outcome with the reason.
    """
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
