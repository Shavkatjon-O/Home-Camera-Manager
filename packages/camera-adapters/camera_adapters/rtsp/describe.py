"""A minimal RTSP client that asks a stream for its description, to test addresses and credentials."""

import asyncio
import base64
import hashlib
import re
from dataclasses import dataclass
from urllib.parse import unquote, urlsplit

from adapters.base import AdapterError

__all__ = ["StreamInfo", "authorization", "describe", "parse_challenge", "parse_sdp", "parse_url"]

USER_AGENT = "smart-surveillance-connector"
MAX_RESPONSE = 64 * 1024
CHALLENGE = re.compile(r'(\w+)="?([^",]*)"?')


@dataclass(frozen=True)
class StreamInfo:
    """What a stream's description says.

    Attributes:
        codec: Video codec, such as h264 or h265.
        audio: Whether the stream carries sound.
    """

    codec: str | None
    audio: bool


def parse_url(url: str) -> tuple[str, int, str, str | None, str | None]:
    """Split an RTSP address.

    Args:
        url: The address.

    Returns:
        Host, port, the address without credentials, user and password.

    Raises:
        AdapterError: The address is not an RTSP address.
    """
    parts = urlsplit(url.strip())
    if parts.scheme not in ("rtsp", "rtsps") or not parts.hostname:
        raise AdapterError("invalid", "The address must start with rtsp:// and name a host")
    port = parts.port or 554
    path = parts.path or "/"
    if parts.query:
        path = f"{path}?{parts.query}"
    clean = f"{parts.scheme}://{parts.hostname}:{port}{path}"
    username = unquote(parts.username) if parts.username else None
    password = unquote(parts.password) if parts.password else None
    return parts.hostname, port, clean, username, password


def parse_challenge(header: str) -> tuple[str, dict[str, str]]:
    """Read a WWW-Authenticate header.

    Args:
        header: The header value.

    Returns:
        The scheme in lower case and its parameters.
    """
    scheme, _, rest = header.strip().partition(" ")
    return scheme.lower(), {key.lower(): value for key, value in CHALLENGE.findall(rest)}


def authorization(scheme: str, params: dict[str, str], method: str, url: str, username: str, password: str) -> str:
    """Build the Authorization header answering a challenge.

    Args:
        scheme: basic or digest.
        params: Challenge parameters.
        method: RTSP method.
        url: Request address.
        username: Login.
        password: Password.

    Returns:
        The header value.
    """
    if scheme == "basic":
        return "Basic " + base64.b64encode(f"{username}:{password}".encode()).decode()
    realm = params.get("realm", "")
    nonce = params.get("nonce", "")
    first = hashlib.md5(f"{username}:{realm}:{password}".encode()).hexdigest()
    second = hashlib.md5(f"{method}:{url}".encode()).hexdigest()
    response = hashlib.md5(f"{first}:{nonce}:{second}".encode()).hexdigest()
    return f'Digest username="{username}", realm="{realm}", nonce="{nonce}", uri="{url}", response="{response}"'


def parse_sdp(sdp: str) -> StreamInfo:
    """Read the video codec and whether there is sound from a session description.

    Args:
        sdp: The description.

    Returns:
        What it says.
    """
    codec = None
    audio = False
    section = None
    for line in sdp.splitlines():
        if line.startswith("m="):
            section = line[2:].split(" ", 1)[0]
            audio = audio or section == "audio"
        elif line.startswith("a=rtpmap:") and section == "video" and codec is None and " " in line:
            encoding = line.split(" ", 1)[1].split("/", 1)[0].lower()
            codec = {"hevc": "h265"}.get(encoding, encoding) or None
    return StreamInfo(codec=codec, audio=audio)


async def request(
    reader: asyncio.StreamReader, writer: asyncio.StreamWriter, lines: list[str], timeout: float
) -> tuple[int, dict[str, str], str]:
    """Send one RTSP request and read its answer.

    Args:
        reader: Stream reader.
        writer: Stream writer.
        lines: Request line and headers.
        timeout: Seconds to wait.

    Returns:
        Status code, headers with lower-case names, and the body.

    Raises:
        AdapterError: The answer is not RTSP.
    """
    writer.write(("\r\n".join(lines) + "\r\n\r\n").encode())
    await writer.drain()
    head = await asyncio.wait_for(reader.readuntil(b"\r\n\r\n"), timeout)
    text = head.decode(errors="replace").split("\r\n")
    status_line = text[0].split(" ", 2)
    if len(status_line) < 2 or not status_line[0].startswith("RTSP/"):
        raise AdapterError("no_stream", "The port does not answer RTSP")
    headers = {}
    for line in text[1:]:
        name, _, value = line.partition(":")
        if name:
            headers[name.strip().lower()] = value.strip()
    length = min(int(headers.get("content-length", "0") or 0), MAX_RESPONSE)
    body = (await asyncio.wait_for(reader.readexactly(length), timeout)).decode(errors="replace") if length else ""
    return int(status_line[1]), headers, body


def describe_request(url: str, sequence: int, header: str | None = None) -> list[str]:
    """Build the lines of a DESCRIBE request.

    Args:
        url: Address without credentials.
        sequence: CSeq number.
        header: Authorization header value, if any.

    Returns:
        The request line and headers.
    """
    lines = [f"DESCRIBE {url} RTSP/1.0", f"CSeq: {sequence}", "Accept: application/sdp", f"User-Agent: {USER_AGENT}"]
    if header:
        lines.append(f"Authorization: {header}")
    return lines


async def describe(
    url: str, username: str | None = None, password: str | None = None, timeout: float = 5.0
) -> StreamInfo:
    """Ask a stream for its description, answering one authentication challenge.

    Args:
        url: RTSP address, with or without credentials.
        username: Login, overriding the one in the address.
        password: Password, overriding the one in the address.
        timeout: Seconds to wait for each step.

    Returns:
        What the stream's description says.

    Raises:
        AdapterError: unreachable when nothing answers, unauthorized when the credentials are refused, no_stream
            when the address has no stream.
    """
    host, port, clean, url_user, url_password = parse_url(url)
    username = username if username is not None else url_user
    password = password if password is not None else url_password
    try:
        reader, writer = await asyncio.wait_for(asyncio.open_connection(host, port), timeout)
    except (OSError, TimeoutError):
        raise AdapterError("unreachable", f"Nothing answers RTSP at {host}:{port}")
    try:
        status, headers, body = await request(reader, writer, describe_request(clean, 1), timeout)
        if status == 401:
            challenge = headers.get("www-authenticate")
            if not challenge or not username:
                raise AdapterError("unauthorized", "The stream needs a login")
            scheme, params = parse_challenge(challenge)
            header = authorization(scheme, params, "DESCRIBE", clean, username, password or "")
            status, headers, body = await request(reader, writer, describe_request(clean, 2, header), timeout)
            if status == 401:
                raise AdapterError("unauthorized", "The camera refused the login")
        if status != 200:
            raise AdapterError("no_stream", f"The camera answered RTSP {status} for this path")
        return parse_sdp(body)
    except (OSError, TimeoutError, asyncio.IncompleteReadError, asyncio.LimitOverrunError, ValueError):
        raise AdapterError("no_stream", "The stream did not answer properly")
    finally:
        writer.close()
