"""The V380 adapter: V380 cameras over their own LAN protocol, or through a relay that serves one camera.

A camera reached directly is identified and controlled with the protocol client; go2rtc reads its video from the
exec source of go2rtc.exec_source. A relay host, which serves one camera over RTSP at /main and /sub, is
identified and controlled through the relay's HTTP API. A target with a device id is a camera; one without is a
relay.
"""

from dataclasses import replace

import httpx

from camera_adapters.base import (
    Adapter,
    AdapterError,
    AdapterName,
    Channel,
    ControlCapability,
    Fingerprint,
    Identity,
    LabelInfo,
    Streams,
    Target,
)
from camera_adapters.classifier import V380_MANUFACTURER, V380_PORT
from camera_adapters.manifest import CapabilityManifest, ControlManifest, MediaManifest
from camera_adapters.sweep import port_open
from camera_adapters.v380.client import Camera, Facts, Session, Timeouts, first_key_frame
from camera_adapters.v380.errors import V380Error
from camera_adapters.v380.go2rtc import control_directory, exec_source
from camera_adapters.v380.labels import parse_v380_label
from camera_adapters.v380.records import LightMode, PictureMode, Stream
from camera_adapters.v380.router import router_for

__all__ = ["RELAY_API_PORT", "RELAY_RTSP_PORT", "V380Adapter", "axis_move"]

RELAY_RTSP_PORT = 8554
RELAY_API_PORT = 8080
MAIN_PATH = "/main"
SUB_PATH = "/sub"
VENDOR = "Macro-Video V380"
SIREN_SECONDS = 10
KEY_FRAME_SECONDS = 8.0
ERROR_CODES = ("unreachable", "unauthorized", "invalid", "unsupported", "no_stream")


def axis_move(pan: float, tilt: float) -> str:
    """Turn pan and tilt speeds into one move along the stronger axis, as the protocol moves one axis at a time.

    Args:
        pan: Pan speed from -1 to 1, negative to the left.
        tilt: Tilt speed from -1 to 1, negative down.

    Returns:
        left, right, up, down or stop.
    """
    if pan == 0 and tilt == 0:
        return "stop"
    if abs(pan) >= abs(tilt):
        return "left" if pan < 0 else "right"
    return "down" if tilt < 0 else "up"


class V380Adapter(Adapter, ControlCapability):
    """Reaches V380 cameras over their LAN protocol, or through a relay.

    Attributes:
        name: v380.
        title: V380 camera.
        priority: Above every other adapter, since the V380 port says enough.
        timeouts: Timers of the protocol sessions.
    """

    name = AdapterName.V380.value
    title = "V380 camera"
    priority = 40

    def __init__(self, timeouts: Timeouts = Timeouts()):
        """Create the adapter.

        Args:
            timeouts: Timers of the protocol sessions.
        """
        self.timeouts = timeouts

    def match(self, fingerprint: Fingerprint, hints: dict | None = None) -> int:
        """Score a V380 camera by its LAN protocol port, its manufacturer or its catalog entry.

        Args:
            fingerprint: What is known about the address.
            hints: Catalog entry that matched, if any.

        Returns:
            70 for a V380 camera, otherwise 0.
        """
        manufacturer = (fingerprint.manufacturer or "").lower()
        if fingerprint.v380 or V380_MANUFACTURER in manufacturer or (hints and hints.get("adapter") == self.name):
            return 70
        return 0

    def camera(self, target: Target) -> Camera:
        """Turn a target into the protocol client's camera.

        Args:
            target: A target with a device id.

        Returns:
            The camera.

        Raises:
            AdapterError: The device id is missing or not a number.
        """
        device_id = str(target.device_id or "").strip()
        if not device_id.isdigit():
            raise AdapterError("invalid", "A V380 camera needs the device id from its label")
        return Camera(
            host=target.host,
            device_id=int(device_id),
            password=target.password or "",
            username=target.username or "admin",
            port=target.port or V380_PORT,
        )

    async def facts(self, camera: Camera, stream: Stream) -> Facts:
        """Open a session, wait for its first key frame and close it.

        Args:
            camera: The camera.
            stream: Main or sub stream.

        Returns:
            The session's facts.

        Raises:
            AdapterError: The camera cannot be reached, refuses the login or sends no video.
        """
        try:
            async with Session(camera, stream, timeouts=self.timeouts) as session:
                await first_key_frame(session, KEY_FRAME_SECONDS)
                return session.facts
        except V380Error as exc:
            raise AdapterError(exc.code, exc.message)

    async def identify(self, target: Target) -> Identity:
        """Identify a V380 camera over its protocol, or the camera behind a relay.

        A camera is identified by a session on each stream in turn, never two at once, which also checks its
        login and reads its codec and picture sizes.

        Args:
            target: A camera with its device id and password, or a relay without a device id.

        Returns:
            The identity.

        Raises:
            AdapterError: The camera cannot be reached or refuses the login, or the address is neither.
        """
        if not target.device_id:
            return await self.identify_relay(target)
        camera = self.camera(target)
        sub = await self.facts(camera, Stream.SUB)
        main = await self.facts(camera, Stream.MAIN)
        channel = Channel(
            index=1,
            name="Camera",
            main_path=MAIN_PATH,
            sub_path=SUB_PATH,
            width=main.width,
            height=main.height,
            encoding=main.codec,
            ptz=True,
        )
        identity = Identity(
            adapter=self.name,
            vendor=VENDOR,
            firmware=f"device version {main.device_version}",
            serial=str(camera.device_id),
            rtsp_port=RELAY_RTSP_PORT,
            channels=(channel,),
        )
        codecs = tuple(sorted({item.codec for item in (main, sub) if item.codec}))
        return replace(identity, manifest=self.manifest(identity, codecs=codecs))

    async def relay_status(self, host: str, timeout: float) -> dict | None:
        """Read a relay's status.

        Args:
            host: Relay host.
            timeout: Seconds to wait.

        Returns:
            The status, or None when no relay answers.
        """
        try:
            async with httpx.AsyncClient(timeout=timeout) as http:
                response = await http.get(f"http://{host}:{RELAY_API_PORT}/api/status")
            return response.json() if response.status_code == 200 else None
        except (httpx.HTTPError, ValueError):
            return None

    async def identify_relay(self, target: Target) -> Identity:
        """Identify the camera behind a relay.

        Args:
            target: The relay's address.

        Returns:
            The identity.

        Raises:
            AdapterError: No relay answers, or the address is a V380 camera given without its device id.
        """
        if not await port_open(target.host, RELAY_RTSP_PORT, target.timeout):
            if await port_open(target.host, V380_PORT, target.timeout):
                raise AdapterError("invalid", "This is a V380 camera; give the device id from its label")
            raise AdapterError("unreachable", f"No V380 relay answers at {target.host}")
        status = await self.relay_status(target.host, target.timeout)
        if status is None or "streams" not in status:
            raise AdapterError("unsupported", f"{target.host} serves RTSP but no V380 relay API")
        facts = next(iter((status.get("streams") or {}).values()), None) or {}
        channel = Channel(
            index=1,
            name="Camera",
            main_path=MAIN_PATH,
            sub_path=SUB_PATH,
            width=facts.get("width"),
            height=facts.get("height"),
            encoding=facts.get("codec") or "h265",
            ptz=True,
        )
        identity = Identity(adapter=self.name, vendor=VENDOR, rtsp_port=RELAY_RTSP_PORT, channels=(channel,))
        return replace(identity, manifest=self.manifest(identity))

    async def streams(self, target: Target, channel: int = 1) -> Streams:
        """Return the stream paths a relay or connector serves the camera at.

        Args:
            target: The camera's or relay's target.
            channel: Channel number, 1 for a camera.

        Returns:
            /main and /sub on the relay's RTSP port, unless the target names others.
        """
        return Streams(
            main=target.main_path or MAIN_PATH,
            sub=target.sub_path or SUB_PATH,
            rtsp_port=target.rtsp_port or RELAY_RTSP_PORT,
        )

    def go2rtc_source(self, target: Target, stream: str = "main") -> str:
        """Build the go2rtc exec source that streams a camera directly.

        Args:
            target: The camera's target, with its device id and password.
            stream: main or sub.

        Returns:
            The exec source.

        Raises:
            AdapterError: The device id is missing.
        """
        camera = self.camera(target)
        return exec_source(
            camera.host, camera.device_id, camera.password, stream=stream, port=camera.port, username=camera.username
        )

    def parse_label(self, text: str) -> LabelInfo | None:
        """Read a V380 label QR code.

        Args:
            text: Decoded QR text.

        Returns:
            The device id, or None.
        """
        return parse_v380_label(text)

    def manifest(self, identity: Identity | None = None, **known) -> CapabilityManifest:
        """Build the manifest of a V380 camera.

        The protocol moves along one axis at a time and knows no zoom, presets or home position; it has light,
        siren and picture commands, unverified on the cameras so far. A camera registered by hand without an
        identity keeps the manifest it had behind its earlier stream server, with presets and a home position,
        until known passes bridged=False.

        Args:
            identity: The identity, when identified.
            **known: ptz, sub, codecs, extras, and bridged for a camera registered by hand.

        Returns:
            The manifest.
        """
        movable = any(channel.ptz for channel in identity.channels) if identity else bool(known.get("ptz", True))
        bridged = bool(known.get("bridged", identity is None))
        extras = bool(known.get("extras", True))
        sub = any(channel.sub_path for channel in identity.channels) if identity else bool(known.get("sub", False))
        codecs = tuple(known.get("codecs") or ("h265",))
        return CapabilityManifest(
            adapter=self.name,
            identify=True,
            media=MediaManifest(main=True, sub=sub, codecs=codecs),
            control=ControlManifest(
                ptz=movable, presets=movable and bridged, home=movable and bridged, light=extras, siren=extras
            ),
        )

    async def command(self, target: Target, request: dict) -> None:
        """Send a control command to a camera, or to the relay that serves it.

        Args:
            target: The camera's or relay's target.
            request: The command, as the control socket takes it.

        Raises:
            AdapterError: The command failed.
        """
        if not target.device_id:
            await self.relay_command(target, request)
            return
        answer = await router_for(self.camera(target), control_directory()).command(request)
        if not answer.get("ok"):
            code = answer.get("error") if answer.get("error") in ERROR_CODES else "unreachable"
            raise AdapterError(code, answer.get("message") or f"The camera did not take the command ({code})")

    async def relay_command(self, target: Target, request: dict) -> None:
        """Send a control command to a relay's HTTP API.

        Args:
            target: The relay's target.
            request: The command.

        Raises:
            AdapterError: The relay does not answer or refuses.
        """
        name = request["command"]
        params = None
        if name == "ptz":
            path = f"/api/ptz/{request['move']}"
        elif name in ("light", "picture"):
            path = f"/api/{name}/{request['mode']}"
        elif name == "siren":
            seconds = float(request.get("seconds") or 0)
            path = "/api/siren/on" if seconds > 0 else "/api/siren/off"
            params = {"seconds": str(int(seconds))} if seconds > 0 else None
        else:
            path = f"/api/{name}"
        try:
            async with httpx.AsyncClient(timeout=target.timeout) as http:
                response = await http.post(f"http://{target.host}:{RELAY_API_PORT}{path}", params=params)
        except httpx.HTTPError:
            raise AdapterError("unreachable", f"No V380 relay answers at {target.host}")
        if response.status_code == 404:
            raise AdapterError("unsupported", "The camera's stream server does not offer this command")
        if not response.is_success:
            raise AdapterError("unreachable", f"The V380 relay answered HTTP {response.status_code}")

    async def move(self, target: Target, channel: int, pan: float, tilt: float, zoom: float) -> None:
        """Start a continuous move along the stronger axis; a stop must follow.

        Args:
            target: The camera's or relay's target.
            channel: Channel number.
            pan: Pan speed.
            tilt: Tilt speed.
            zoom: Zoom speed; the protocol has no zoom.

        Raises:
            AdapterError: Only a zoom was asked for, or the command failed.
        """
        if pan == 0 and tilt == 0 and zoom != 0:
            raise AdapterError("unsupported", "V380 cameras have no zoom command")
        await self.command(target, {"command": "ptz", "move": axis_move(pan, tilt)})

    async def stop(self, target: Target, channel: int) -> None:
        """Stop a move.

        Args:
            target: The camera's or relay's target.
            channel: Channel number.
        """
        await self.command(target, {"command": "ptz", "move": "stop"})

    async def set_light(self, target: Target, channel: int, mode: str) -> None:
        """Switch the light.

        Args:
            target: The camera's or relay's target.
            channel: Channel number.
            mode: on, off or auto.

        Raises:
            AdapterError: The mode is unknown or the command failed.
        """
        try:
            mode = LightMode(mode).value
        except ValueError:
            raise AdapterError("invalid", f"Unknown light mode {mode}")
        await self.command(target, {"command": "light", "mode": mode})

    async def set_siren(self, target: Target, channel: int, on: bool) -> None:
        """Sound the siren for SIREN_SECONDS, repeated as the protocol requires, or silence it.

        Args:
            target: The camera's or relay's target.
            channel: Channel number.
            on: Whether to sound it.
        """
        await self.command(target, {"command": "siren", "seconds": SIREN_SECONDS if on else 0})

    async def set_picture(self, target: Target, channel: int, mode: str) -> None:
        """Switch the picture between colour, black and white and automatic.

        Args:
            target: The camera's or relay's target.
            channel: Channel number.
            mode: colour, black_and_white or auto.

        Raises:
            AdapterError: The mode is unknown or the command failed.
        """
        try:
            mode = PictureMode(mode).value
        except ValueError:
            raise AdapterError("invalid", f"Unknown picture mode {mode}")
        await self.command(target, {"command": "picture", "mode": mode})

    async def flip(self, target: Target, channel: int) -> None:
        """Turn the picture by 180 degrees.

        Args:
            target: The camera's or relay's target.
            channel: Channel number.
        """
        await self.command(target, {"command": "flip"})
