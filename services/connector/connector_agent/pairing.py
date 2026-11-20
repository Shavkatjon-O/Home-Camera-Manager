"""Pairing with the backend by the RFC 8628 device authorization grant, shown as a code, a QR code and over mDNS."""

import asyncio
import io
import logging

import segno

from connector_agent.backend import BackendClient, BackendError, GrantPending
from connector_agent.state import Pairing

__all__ = ["SLOW_DOWN_SECONDS", "pair", "qr_svg", "qr_text"]

logger = logging.getLogger(__name__)

SLOW_DOWN_SECONDS = 5
RETRY_SECONDS = 10


def qr_text(link: str) -> str:
    """Draw a link as a QR code in text, for the log.

    Args:
        link: The link.

    Returns:
        The QR code drawn with ASCII characters.
    """
    rows = segno.make(link, error="m").matrix_iter(scale=1, border=2)
    return "\n".join("".join("##" if dark else "  " for dark in row) for row in rows)


def qr_svg(link: str) -> str:
    """Draw a link as an SVG QR code, for the pairing page.

    Args:
        link: The link.

    Returns:
        The SVG document.
    """
    buffer = io.BytesIO()
    segno.make(link, error="m").save(buffer, kind="svg", scale=6, border=2)
    return buffer.getvalue().decode()


async def pair(client: BackendClient, name: str, version: str, shown, sleep=asyncio.sleep) -> Pairing:
    """Pair the connector, opening a new pairing whenever one expires or is refused.

    Args:
        client: Backend client without a token.
        name: Name the connector suggests.
        version: Agent version.
        shown: Called with each new device authorization, to show its code; None when pairing ends.
        sleep: Coroutine function that waits, replaced in tests.

    Returns:
        The pairing the backend issued.
    """
    while True:
        try:
            authorization = await client.device_code(name, version)
        except BackendError as exc:
            logger.warning("Opening a pairing failed: %s", exc)
            await sleep(RETRY_SECONDS)
            continue
        shown(authorization)
        logger.info(
            "Pair this connector: enter %s or open %s",
            authorization["user_code"],
            authorization["verification_uri_complete"],
        )
        interval = int(authorization.get("interval") or 5)
        while True:
            await sleep(interval)
            try:
                token = await client.token_for(authorization["device_code"])
            except GrantPending as exc:
                if exc.error == "authorization_pending":
                    continue
                if exc.error == "slow_down":
                    interval = exc.interval or interval + SLOW_DOWN_SECONDS
                    continue
                logger.info("The pairing ended with %s; opening a new one", exc.error)
                break
            except BackendError as exc:
                logger.warning("Polling the pairing failed: %s", exc)
                continue
            shown(None)
            return Pairing(
                connector=str(token["connector"]),
                site=str(token["site"]),
                organisation=str(token["organisation"]),
                token=token["access_token"],
                agent_key=token["agent_key"],
                stream_username=token["stream_username"],
                stream_password=token["stream_password"],
                heartbeat_interval=int(token.get("heartbeat_interval") or 30),
            )
