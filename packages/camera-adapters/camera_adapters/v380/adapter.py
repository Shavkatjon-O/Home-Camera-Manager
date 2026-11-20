"""The V380 adapter: V380 cameras through the bridge, which turns their LAN protocol into RTSP, ONVIF and an API.

The bridge runs as a container of its own next to the connector, on a private network, because it listens on
every interface, answers WS-Discovery and has no authentication. The target of a V380 camera is its bridge.
"""

from dataclasses import replace

from adapters.base import (
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
from adapters.classifier import V380_MANUFACTURER, V380_PORT
from adapters.manifest import CapabilityManifest, ControlManifest, MediaManifest
from adapters.onvif.adapter import OnvifAdapter
from adapters.sweep import port_open
from adapters.v380.bridge import BridgeClient, BridgeError
from adapters.v380.labels import parse_v380_label

__all__ = ["BRIDGE_ONVIF_PORT", "BRIDGE_PATH", "BRIDGE_RTSP_PORT", "V380Adapter"]

BRIDGE_ONVIF_PORT = 8080
BRIDGE_RTSP_PORT = 8554
BRIDGE_PATH = "/live"
SIREN_SECONDS = 10


class V380Adapter(Adapter, ControlCapability):
    """Reaches V380 cameras through their bridge.

    Attributes:
        name: v380.
        title: V380 camera.
        priority: Above every other adapter, since the V380 port says enough.
        onvif: ONVIF adapter that talks to the bridge's ONVIF service.
    """

    name = AdapterName.V380.value
    title = "V380 camera"
    priority = 40

    def __init__(self):
        """Create the adapter."""
        self.onvif = OnvifAdapter()

    def bridge_target(self, target: Target) -> Target:
        """Point a target at the bridge's ONVIF service, which asks for no credentials.

        Args:
            target: The camera's target, whose host is its bridge.

        Returns:
            The bridge's ONVIF target.
        """
        return Target(host=target.host, port=BRIDGE_ONVIF_PORT, timeout=target.timeout)

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

    async def identify(self, target: Target) -> Identity:
        """Identify a V380 camera through its bridge.

        Args:
            target: The camera's target, whose host is its bridge.

        Returns:
            The identity.

        Raises:
            AdapterError: The address is the camera itself rather than its bridge, or no bridge answers.
        """
        if not await port_open(target.host, BRIDGE_RTSP_PORT, target.timeout):
            if await port_open(target.host, V380_PORT, target.timeout):
                raise AdapterError(
                    "unsupported", "This is a V380 camera; start its bridge with its device id and add the bridge"
                )
            raise AdapterError("unreachable", f"No V380 bridge answers at {target.host}")
        found = None
        try:
            found = await self.onvif.identify(self.bridge_target(target))
        except AdapterError:
            found = None
        movable = any(channel.ptz for channel in found.channels) if found else True
        extras = await BridgeClient(target.host).available()
        identity = Identity(
            adapter=self.name,
            vendor="Macro-Video V380",
            model=found.model if found else None,
            firmware=found.firmware if found else None,
            rtsp_port=BRIDGE_RTSP_PORT,
            channels=(Channel(index=1, name="Camera", main_path=BRIDGE_PATH, ptz=movable),),
        )
        return replace(identity, manifest=self.manifest(identity, extras=extras))

    async def streams(self, target: Target, channel: int = 1) -> Streams:
        """Return the bridge's stream path.

        Args:
            target: The camera's target.
            channel: Channel number, 1 for a camera.

        Returns:
            The bridge stream; a V380 camera has no separate sub stream.
        """
        return Streams(main=target.main_path or BRIDGE_PATH, sub=None, rtsp_port=target.rtsp_port or BRIDGE_RTSP_PORT)

    def parse_label(self, text: str) -> LabelInfo | None:
        """Read a V380 label QR code.

        Args:
            text: Decoded QR text.

        Returns:
            The device id, or None.
        """
        return parse_v380_label(text)

    def manifest(self, identity: Identity | None = None, **known) -> CapabilityManifest:
        """Build the manifest of a V380 camera behind its bridge.

        Args:
            identity: The identity, when identified.
            **known: extras, whether the bridge API with light and siren answers; ptz for a hand-registered camera.

        Returns:
            The manifest.
        """
        movable = any(channel.ptz for channel in identity.channels) if identity else bool(known.get("ptz", True))
        extras = bool(known.get("extras", identity is None))
        return CapabilityManifest(
            adapter=self.name,
            identify=True,
            media=MediaManifest(main=True, sub=False, codecs=("h265",)),
            control=ControlManifest(ptz=movable, presets=movable, home=movable, light=extras, siren=extras),
        )

    async def move(self, target: Target, channel: int, pan: float, tilt: float, zoom: float) -> None:
        """Start a continuous move through the bridge.

        Args:
            target: The camera's target.
            channel: Channel number.
            pan: Pan speed.
            tilt: Tilt speed.
            zoom: Zoom speed.
        """
        await self.onvif.move(self.bridge_target(target), channel, pan, tilt, zoom)

    async def stop(self, target: Target, channel: int) -> None:
        """Stop a move through the bridge.

        Args:
            target: The camera's target.
            channel: Channel number.
        """
        await self.onvif.stop(self.bridge_target(target), channel)

    async def set_light(self, target: Target, channel: int, mode: str) -> None:
        """Switch the light through the bridge API.

        Args:
            target: The camera's target.
            channel: Channel number.
            mode: on, off or auto.

        Raises:
            AdapterError: The bridge refuses.
        """
        try:
            await BridgeClient(target.host).light(mode)
        except BridgeError as exc:
            raise AdapterError("unreachable", str(exc))

    async def set_siren(self, target: Target, channel: int, on: bool) -> None:
        """Switch the siren through the bridge API.

        Args:
            target: The camera's target.
            channel: Channel number.
            on: Whether to sound it for a few seconds.

        Raises:
            AdapterError: The bridge refuses.
        """
        try:
            await BridgeClient(target.host).siren(SIREN_SECONDS if on else None)
        except BridgeError as exc:
            raise AdapterError("unreachable", str(exc))
