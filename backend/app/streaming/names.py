"""Names and source URLs of the go2rtc streams of cameras."""

import re
from urllib.parse import quote
from uuid import UUID

from app.core.config import settings

MAIN = "main"
SUB = "sub"

NAME_PATTERN = re.compile(r"^[0-9a-f]{32}_(main|sub)$")
TRANSCODE_VIDEO = "#video=h264"


def stream_name(camera_uuid: UUID, kind: str) -> str:
    """Build the go2rtc stream name of a camera.

    Args:
        camera_uuid: Camera identifier.
        kind: Stream kind, main or sub.

    Returns:
        The camera UUID in hex followed by the kind.
    """
    return f"{camera_uuid.hex}_{kind}"


def is_managed(name: str) -> bool:
    """Tell whether a stream name follows the pattern of the camera streams.

    Args:
        name: Stream name.

    Returns:
        True for a name made of a 32 digit hex UUID and a main or sub kind.
    """
    return NAME_PATTERN.match(name) is not None


def belongs_to(name: str, camera_uuid: UUID) -> bool:
    """Tell whether a stream is a camera stream of one camera.

    Args:
        name: Stream name.
        camera_uuid: Camera identifier.

    Returns:
        True when the name follows the camera stream pattern and starts with the camera UUID.
    """
    return is_managed(name) and name.startswith(f"{camera_uuid.hex}_")


def rtsp_url(host: str, port: int, path: str, username: str | None, password: str | None) -> str:
    """Build an RTSP URL with percent-encoded credentials.

    Args:
        host: Camera host.
        port: RTSP port.
        path: Stream path, given a leading slash when it has none.
        username: Login name, omitted from the URL when empty.
        password: Password, used only together with a username.

    Returns:
        The RTSP URL.
    """
    credentials = ""
    if username:
        credentials = quote(username, safe="")
        if password:
            credentials = f"{credentials}:{quote(password, safe='')}"
        credentials = f"{credentials}@"
    if not path.startswith("/"):
        path = f"/{path}"
    return f"rtsp://{credentials}{host}:{port}{path}"


def transcode_options() -> str:
    """Build the go2rtc option suffix of the video transcode.

    Returns:
        An h264 video transcode, with the configured hardware option when one is set.
    """
    if settings.transcode_hardware:
        return f"{TRANSCODE_VIDEO}#hardware={settings.transcode_hardware}"
    return TRANSCODE_VIDEO


def stream_sources(name: str, url: str) -> list[str]:
    """Build the sources of a camera stream.

    Args:
        name: Stream name.
        url: Camera RTSP URL.

    Returns:
        The camera URL and an ffmpeg source that transcodes the stream to h264 video.
    """
    return [url, f"ffmpeg:{name}{transcode_options()}"]


def camera_streams(
    camera_uuid: UUID,
    host: str,
    port: int,
    main_path: str,
    sub_path: str | None,
    username: str | None,
    password: str | None,
) -> dict[str, list[str]]:
    """Build the go2rtc streams of a camera.

    Args:
        camera_uuid: Camera identifier.
        host: Camera host.
        port: RTSP port.
        main_path: RTSP path of the main stream.
        sub_path: RTSP path of the sub stream, or None when the camera has none.
        username: Login name.
        password: Password.

    Returns:
        The sources of each stream, keyed by stream name, with no entry for a missing path.
    """
    streams = {}
    paths = {MAIN: main_path, SUB: sub_path}
    for kind, path in paths.items():
        if not path:
            continue
        name = stream_name(camera_uuid, kind)
        streams[name] = stream_sources(name, rtsp_url(host, port, path, username, password))
    return streams
