import re
from urllib.parse import quote
from uuid import UUID

from app.core.config import settings

MAIN = "main"
SUB = "sub"

NAME_PATTERN = re.compile(r"^[0-9a-f]{32}_(main|sub)$")
TRANSCODE_VIDEO = "#video=h264"


def stream_name(camera_uuid: UUID, kind: str) -> str:
    return f"{camera_uuid.hex}_{kind}"


def is_managed(name: str) -> bool:
    return NAME_PATTERN.match(name) is not None


def belongs_to(name: str, camera_uuid: UUID) -> bool:
    return is_managed(name) and name.startswith(f"{camera_uuid.hex}_")


def rtsp_url(host: str, port: int, path: str, username: str | None, password: str | None) -> str:
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
    if settings.transcode_hardware:
        return f"{TRANSCODE_VIDEO}#hardware={settings.transcode_hardware}"
    return TRANSCODE_VIDEO


def stream_sources(name: str, url: str) -> list[str]:
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
    streams = {}
    paths = {MAIN: main_path, SUB: sub_path}
    for kind, path in paths.items():
        if not path:
            continue
        name = stream_name(camera_uuid, kind)
        streams[name] = stream_sources(name, rtsp_url(host, port, path, username, password))
    return streams
