"""Camera stream addresses on go2rtc and the probing of their frame size."""

from __future__ import annotations

import logging
import re
import subprocess
from urllib.parse import quote

logger = logging.getLogger(__name__)

PROBE_TIMEOUT_SECONDS = 20
CREDENTIALS = re.compile(r"//[^/@\s]*@")


def stream_uri(base: str, stream: str, username: str, password: str) -> str:
    """Build the RTSP URI of a go2rtc stream with credentials.

    Args:
        base: go2rtc RTSP base URL such as rtsp://go2rtc:8554.
        stream: Stream name.
        username: RTSP user.
        password: RTSP password, empty for none.

    Returns:
        The URI.
    """
    scheme, _, host = base.partition("//")
    credentials = ""
    if username and password:
        credentials = f"{quote(username, safe='')}:{quote(password, safe='')}@"
    return f"{scheme}//{credentials}{host}/{stream}"


def redact(text: str) -> str:
    """Remove credentials from any URI inside a text.

    Args:
        text: Text that may hold URIs.

    Returns:
        The text with user and password parts replaced.
    """
    return CREDENTIALS.sub("//***@", text)


def probe_size(uri: str) -> tuple[int, int] | None:
    """Read the frame size of a stream with one short ffprobe session.

    Args:
        uri: The stream URI.

    Returns:
        Width and height, or None when the stream does not answer.
    """
    command = [
        "ffprobe",
        "-v",
        "error",
        "-rtsp_transport",
        "tcp",
        "-select_streams",
        "v:0",
        "-show_entries",
        "stream=width,height",
        "-of",
        "csv=p=0",
        uri,
    ]
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=PROBE_TIMEOUT_SECONDS, check=False)
    except subprocess.TimeoutExpired:
        logger.warning("Probing %s timed out", redact(uri))
        return None
    match = re.search(r"(\d+),(\d+)", result.stdout)
    if not match:
        logger.warning("Probing %s gave no frame size: %s", redact(uri), redact(result.stderr.strip())[-200:])
        return None
    return int(match.group(1)), int(match.group(2))
