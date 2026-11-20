"""The connector's go2rtc: started by the agent with its configuration inline, and its stream API."""

import asyncio
import json
import logging

import httpx

__all__ = ["Go2rtc", "Go2rtcError", "go2rtc_config"]

logger = logging.getLogger(__name__)

RESTART_SECONDS = 3.0
TIMEOUT_SECONDS = 5.0


class Go2rtcError(Exception):
    """go2rtc could not be reached or refused a change."""


def go2rtc_config(api: str, rtsp_port: int, username: str, password: str) -> str:
    """Build go2rtc's configuration.

    The configuration is passed inline rather than written to a file, so go2rtc has no file to write camera
    passwords back into when streams are added through its API.

    Args:
        api: Loopback address of the API.
        rtsp_port: RTSP port central pulls the streams from.
        username: RTSP user central signs in with.
        password: Its password.

    Returns:
        The configuration as JSON, which go2rtc reads as YAML.
    """
    return json.dumps(
        {
            "log": {"level": "info"},
            "api": {"listen": api},
            "rtsp": {"listen": f":{rtsp_port}", "username": username, "password": password},
            "webrtc": {"listen": ""},
            "streams": {},
        }
    )


class Go2rtc:
    """Runs go2rtc as a child process, restarts it when it exits, and changes its streams.

    Attributes:
        binary: Path of the go2rtc program.
        api: Loopback address of its API.
        process: The running child, if any.
        task: Task supervising it.
        config: Configuration it runs with.
        transport: HTTP transport of the API calls, replaced in tests.
    """

    def __init__(self, binary: str, api: str, transport: httpx.AsyncBaseTransport | None = None):
        """Create the manager, not yet running.

        Args:
            binary: Path of the go2rtc program.
            api: Loopback address of its API.
            transport: HTTP transport, the default when omitted.
        """
        self.binary = binary
        self.api = api
        self.transport = transport
        self.process: asyncio.subprocess.Process | None = None
        self.task: asyncio.Task | None = None
        self.config = ""

    async def start(self, config: str) -> None:
        """Start supervising go2rtc with a configuration.

        Args:
            config: The inline configuration.
        """
        self.config = config
        if self.task is None or self.task.done():
            self.task = asyncio.create_task(self.supervise(), name="go2rtc")

    async def supervise(self) -> None:
        """Run go2rtc and start it again whenever it exits."""
        while True:
            try:
                self.process = await asyncio.create_subprocess_exec(self.binary, "-config", self.config)
                code = await self.process.wait()
                logger.warning("go2rtc exited with %s; starting it again", code)
            except OSError as exc:
                logger.error("go2rtc could not be started: %s", exc)
            await asyncio.sleep(RESTART_SECONDS)

    async def stop(self) -> None:
        """Stop go2rtc and its supervision."""
        if self.task is not None:
            self.task.cancel()
            await asyncio.gather(self.task, return_exceptions=True)
        if self.process is not None and self.process.returncode is None:
            self.process.terminate()
            try:
                await asyncio.wait_for(self.process.wait(), TIMEOUT_SECONDS)
            except TimeoutError:
                self.process.kill()

    async def request(self, method: str, params: list[tuple[str, str]] | None = None) -> httpx.Response:
        """Call the stream endpoint of go2rtc's API.

        Args:
            method: HTTP method.
            params: Query parameters.

        Returns:
            The response.

        Raises:
            Go2rtcError: go2rtc does not answer.
        """
        try:
            async with httpx.AsyncClient(
                base_url=f"http://{self.api}", timeout=TIMEOUT_SECONDS, transport=self.transport
            ) as http:
                return await http.request(method, "/api/streams", params=params)
        except httpx.HTTPError as exc:
            raise Go2rtcError(f"go2rtc does not answer ({type(exc).__name__})")

    async def streams(self) -> dict[str, list[str]]:
        """List the sources of every stream.

        Returns:
            Stream name to its producer addresses.
        """
        response = await self.request("GET")
        if response.status_code != 200:
            raise Go2rtcError(f"go2rtc answered HTTP {response.status_code}")
        data = response.json() or {}
        return {
            name: [producer["url"] for producer in (info or {}).get("producers") or [] if producer.get("url")]
            for name, info in data.items()
        }

    async def apply(self, desired: dict[str, list[str]]) -> None:
        """Bring go2rtc's streams in line with the desired ones, removing every other stream.

        Args:
            desired: Stream name to its sources.
        """
        current = await self.streams()
        for name, sources in desired.items():
            if current.get(name) != sources:
                await self.request("PUT", [("name", name), *(("src", source) for source in sources)])
        for name in current:
            if name not in desired:
                await self.request("DELETE", [("src", name)])
