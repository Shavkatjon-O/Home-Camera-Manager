"""The V380 relay: one camera served over RTSP by a go2rtc child that runs the V380 client, plus an HTTP API.

The relay stands where a stream server for one V380 camera is needed outside a connector, as in the
all-in-one deployment: go2rtc serves the camera's main and sub streams at /main and /sub, and the HTTP API takes
PTZ, light, siren and picture commands. Its light and siren paths match the ones the API already calls on a
camera's stream server.
"""

import asyncio
import contextlib
import json
import logging
import os
from dataclasses import dataclass
from urllib.parse import parse_qs, urlsplit

from camera_adapters.v380.client import Camera
from camera_adapters.v380.control import send, socket_path
from camera_adapters.v380.go2rtc import control_directory, exec_source
from camera_adapters.v380.records import DEFAULT_PORT, LightMode, PictureMode, PtzMove
from camera_adapters.v380.router import CommandRouter

__all__ = ["Relay", "RelayConfig", "go2rtc_config", "handle"]

logger = logging.getLogger(__name__)

RESTART_SECONDS = 3.0
PROBE_SECONDS = 1.0
REQUEST_LIMIT = 8192
STATUS_TEXT = {200: "OK", 400: "Bad Request", 404: "Not Found", 405: "Method Not Allowed", 503: "Unavailable"}


@dataclass(frozen=True)
class RelayConfig:
    """What the relay serves.

    Attributes:
        camera: The camera.
        streams: Streams to serve, main and sub.
        rtsp_port: RTSP port of go2rtc.
        rtsp_username: RTSP user, none when empty.
        rtsp_password: RTSP password.
        api_port: Port of the HTTP API.
        go2rtc: Path of the go2rtc program.
        go2rtc_api: Loopback address of go2rtc's own API.
        directory: Directory of the control sockets and password file.
    """

    camera: Camera
    streams: tuple[str, ...] = ("main", "sub")
    rtsp_port: int = 8554
    rtsp_username: str = ""
    rtsp_password: str = ""
    api_port: int = 8080
    go2rtc: str = "go2rtc"
    go2rtc_api: str = "127.0.0.1:1984"
    directory: str = "/tmp/sss-v380"

    @classmethod
    def from_env(cls, env: dict[str, str] | None = None) -> "RelayConfig":
        """Read the configuration from SSS_V380_ environment variables.

        Args:
            env: The environment, os.environ when omitted.

        Returns:
            The configuration.

        Raises:
            ValueError: The host, device id or password is missing.
        """
        env = dict(os.environ if env is None else env)
        host = env.get("SSS_V380_HOST", "")
        device_id = env.get("SSS_V380_DEVICE_ID", "")
        password = env.get("SSS_V380_PASSWORD")
        if not host or not device_id.isdigit() or password is None:
            raise ValueError("Set SSS_V380_HOST, SSS_V380_DEVICE_ID and SSS_V380_PASSWORD")
        camera = Camera(
            host=host,
            device_id=int(device_id),
            password=password,
            username=env.get("SSS_V380_USERNAME") or "admin",
            port=int(env.get("SSS_V380_PORT") or DEFAULT_PORT),
        )
        streams = tuple(item for item in (env.get("SSS_V380_STREAMS") or "main,sub").split(",") if item)
        return cls(
            camera=camera,
            streams=tuple(item for item in streams if item in ("main", "sub")) or ("main",),
            rtsp_port=int(env.get("SSS_V380_RTSP_PORT") or 8554),
            rtsp_username=env.get("SSS_V380_RTSP_USERNAME", ""),
            rtsp_password=env.get("SSS_V380_RTSP_PASSWORD", ""),
            api_port=int(env.get("SSS_V380_API_PORT") or 8080),
            go2rtc=env.get("SSS_V380_GO2RTC") or "go2rtc",
            go2rtc_api=env.get("SSS_V380_GO2RTC_API") or "127.0.0.1:1984",
            directory=env.get("SSS_V380_CONTROL_DIR") or control_directory(),
        )


def go2rtc_config(config: RelayConfig) -> str:
    """Build go2rtc's configuration, passed inline so no file holds the stream sources.

    Args:
        config: The relay configuration.

    Returns:
        The configuration as JSON, which go2rtc reads as YAML.
    """
    rtsp: dict = {"listen": f":{config.rtsp_port}"}
    if config.rtsp_username:
        rtsp |= {"username": config.rtsp_username, "password": config.rtsp_password}
    camera = config.camera
    streams = {
        stream: exec_source(
            camera.host,
            camera.device_id,
            camera.password,
            stream=stream,
            port=camera.port,
            username=camera.username,
            directory=config.directory,
        )
        for stream in config.streams
    }
    return json.dumps(
        {
            "log": {"level": "info"},
            "api": {"listen": config.go2rtc_api},
            "rtsp": rtsp,
            "webrtc": {"listen": ""},
            "streams": streams,
        }
    )


class Relay:
    """Runs go2rtc and the HTTP API for one camera.

    Attributes:
        config: Its configuration.
        router: Router of the control commands.
        process: The go2rtc child, if running.
    """

    def __init__(self, config: RelayConfig):
        """Create the relay, not yet running.

        Args:
            config: Its configuration.
        """
        self.config = config
        self.router = CommandRouter(config.camera, config.directory)
        self.process: asyncio.subprocess.Process | None = None

    async def run(self) -> None:
        """Serve the API and keep go2rtc running until cancelled."""
        server = await asyncio.start_server(self.http, "0.0.0.0", self.config.api_port, limit=REQUEST_LIMIT)
        try:
            await self.supervise()
        finally:
            server.close()
            await self.router.close()
            if self.process is not None and self.process.returncode is None:
                self.process.terminate()
                with contextlib.suppress(TimeoutError):
                    await asyncio.wait_for(self.process.wait(), 10)

    async def supervise(self) -> None:
        """Run go2rtc and start it again whenever it exits."""
        settings = go2rtc_config(self.config)
        while True:
            try:
                self.process = await asyncio.create_subprocess_exec(self.config.go2rtc, "-config", settings)
                code = await self.process.wait()
                logger.warning("go2rtc exited with %s; starting it again", code)
            except OSError as exc:
                logger.error("go2rtc could not be started: %s", exc)
            await asyncio.sleep(RESTART_SECONDS)

    async def http(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter) -> None:
        """Serve one HTTP request.

        Args:
            reader: Client reader.
            writer: Client writer.
        """
        try:
            line = (await reader.readline()).decode("latin-1").strip()
            length = 0
            while header := (await reader.readline()).strip():
                name, _, value = header.decode("latin-1").partition(":")
                if name.strip().lower() == "content-length" and value.strip().isdigit():
                    length = int(value.strip())
            if length:
                await reader.readexactly(min(length, REQUEST_LIMIT))
            method, _, rest = line.partition(" ")
            target = rest.rpartition(" ")[0] or rest
            status, body = await handle(self, method, target)
            payload = json.dumps(body).encode()
            head = (
                f"HTTP/1.1 {status} {STATUS_TEXT.get(status, 'Error')}\r\nContent-Type: application/json\r\n"
                f"Content-Length: {len(payload)}\r\nConnection: close\r\n\r\n"
            )
            writer.write(head.encode() + payload)
            await writer.drain()
        except (OSError, asyncio.IncompleteReadError, asyncio.LimitOverrunError, ValueError):
            pass
        finally:
            writer.close()

    async def status(self) -> dict:
        """Report whether the camera can be served.

        Returns:
            running when a stream process holds a session or the camera answers, otherwise unreachable, with the
            facts of the open sessions.
        """
        facts = {}
        for stream in self.config.streams:
            path = socket_path(self.config.directory, self.config.camera.device_id, stream)
            if not path.exists():
                continue
            with contextlib.suppress(OSError):
                answer = await send(path, {"command": "facts"}, timeout=PROBE_SECONDS)
                if answer.get("open"):
                    facts[stream] = answer.get("facts")
        reachable = bool(facts)
        if not reachable:
            camera = self.config.camera
            try:
                _, writer = await asyncio.wait_for(asyncio.open_connection(camera.host, camera.port), PROBE_SECONDS)
                writer.close()
                reachable = True
            except (OSError, TimeoutError):
                reachable = False
        return {"status": "running" if reachable else "unreachable", "streams": facts}


async def handle(relay: Relay, method: str, target: str) -> tuple[int, dict]:
    """Answer an API request.

    Args:
        relay: The relay.
        method: HTTP method.
        target: Request path and query.

    Returns:
        The HTTP status and the JSON body.
    """
    parts = urlsplit(target)
    path = [item for item in parts.path.split("/") if item]
    query = parse_qs(parts.query)
    if path == ["api", "status"] and method == "GET":
        return 200, await relay.status()
    if len(path) < 2 or path[0] != "api":
        return 404, {"ok": False, "error": "not_found"}
    if method != "POST":
        return 405, {"ok": False, "error": "method_not_allowed"}
    kind, value = path[1], path[2] if len(path) > 2 else ""
    try:
        if kind == "ptz":
            request = {"command": "ptz", "move": PtzMove(value).value}
        elif kind == "light":
            request = {"command": "light", "mode": LightMode(value).value}
        elif kind == "picture":
            request = {"command": "picture", "mode": PictureMode(value).value}
        elif kind == "flip" and not value:
            request = {"command": "flip"}
        elif kind == "siren" and value in ("on", "off"):
            seconds = float((query.get("seconds") or ["10"])[0]) if value == "on" else 0.0
            request = {"command": "siren", "seconds": max(0.0, min(seconds, 300.0))}
        else:
            return 404, {"ok": False, "error": "not_found"}
    except ValueError:
        return 400, {"ok": False, "error": "invalid"}
    answer = await relay.router.command(request)
    if answer.get("ok"):
        return 200, answer
    if answer.get("error") in ("invalid", "unknown_command"):
        return 400, answer
    return 503, answer
