"""The generic ONVIF adapter: Profile S and T cameras, and NVRs and DVRs with one channel per video source."""

from dataclasses import replace
from datetime import datetime
from urllib.parse import urlsplit
from xml.sax.saxutils import escape

from camera_adapters.base import (
    Adapter,
    AdapterError,
    AdapterName,
    Channel,
    ControlCapability,
    DeviceKind,
    EventsCapability,
    Fingerprint,
    Identity,
    LabelInfo,
    MaintenanceCapability,
    Streams,
    Target,
)
from camera_adapters.manifest import (
    CapabilityManifest,
    ControlManifest,
    EventsManifest,
    ImagingManifest,
    MaintenanceManifest,
    MediaManifest,
    PlaybackManifest,
)
from camera_adapters.onvif import media, ptz, system
from camera_adapters.onvif.client import OnvifClient, Profile, parse_device_time, pick_streams, uri_path
from camera_adapters.onvif.soap import OnvifError, OnvifFault, OnvifRefused, descendant_text

__all__ = ["DEFAULT_ONVIF_PORT", "OnvifAdapter", "group_channels", "normalise_topic", "stream_port"]

DEFAULT_ONVIF_PORT = 80
DEFAULT_RTSP_PORT = 554
EVENT_KINDS = ("motion", "tamper", "storage", "reboot")
IMAGING_SETTINGS = ("brightness", "contrast", "saturation", "sharpness", "ir_cut")
TOPIC_KINDS = (
    ("motionalarm", "motion"),
    ("cellmotiondetector", "motion"),
    ("motion", "motion"),
    ("imagetooblurry", "tamper"),
    ("imagetoodark", "tamper"),
    ("imagetoobright", "tamper"),
    ("globalscenechange", "tamper"),
    ("tamper", "tamper"),
    ("storage", "storage"),
    ("lastreboot", "reboot"),
)


def normalise_topic(topic: str) -> str | None:
    """Map an ONVIF event topic to a normalised kind.

    Args:
        topic: Topic such as tns1:VideoSource/MotionAlarm.

    Returns:
        motion, tamper, storage or reboot, or None for another topic.
    """
    lowered = topic.lower().replace("_", "")
    for needle, kind in TOPIC_KINDS:
        if needle in lowered:
            return kind
    return None


def group_channels(profiles: list[Profile]) -> list[Channel]:
    """Group media profiles into channels, one per video source.

    Profiles of the same source are the streams of one channel: the largest is the main stream, the smallest the
    sub stream. Profiles without a source token form one channel together.

    Args:
        profiles: Profiles with their stream addresses.

    Returns:
        The channels in the order their sources first appear, numbered from 1.
    """
    groups: dict[str, list[Profile]] = {}
    for profile in profiles:
        groups.setdefault(profile.source or "", []).append(profile)
    channels = []
    for source, members in groups.items():
        main, sub = pick_streams(members)
        if main is None:
            continue
        channels.append(
            Channel(
                index=len(channels) + 1,
                name=source or main.name,
                token=source or None,
                main_path=uri_path(main.stream_uri)[0],
                sub_path=uri_path(sub.stream_uri)[0] if sub is not None else None,
                width=main.width,
                height=main.height,
                encoding=(main.encoding or "").lower() or None,
                ptz=any(member.ptz for member in members),
            )
        )
    return channels


def stream_port(profiles: list[Profile]) -> int | None:
    """Return the RTSP port the profiles' stream addresses use.

    Args:
        profiles: Profiles with stream addresses.

    Returns:
        The port of the first address that names one.
    """
    for profile in profiles:
        if profile.stream_uri:
            port = uri_path(profile.stream_uri)[1]
            if port is not None:
                return port
    return None


def refused_login(exc: OnvifFault) -> bool:
    """Tell whether a SOAP fault refuses the credentials.

    Args:
        exc: The fault.

    Returns:
        True for a not authorized fault.
    """
    return "notauthorized" in str(exc).lower().replace(" ", "")


class OnvifAdapter(Adapter, ControlCapability, EventsCapability, MaintenanceCapability):
    """Reaches any ONVIF device.

    Attributes:
        name: onvif.
        title: ONVIF camera or recorder.
        priority: Below the vendor adapters, above plain RTSP.
    """

    name = AdapterName.ONVIF.value
    title = "ONVIF camera or recorder"
    priority = 10

    def client(self, target: Target) -> OnvifClient:
        """Build the ONVIF client of a target.

        Args:
            target: How to reach the device.

        Returns:
            The client.
        """
        return OnvifClient(
            target.host, target.port or DEFAULT_ONVIF_PORT, target.username, target.password, timeout=target.timeout
        )

    def match(self, fingerprint: Fingerprint, hints: dict | None = None) -> int:
        """Score an ONVIF device: one that answered ONVIF or announced ONVIF scopes fits.

        Args:
            fingerprint: What is known about the address.
            hints: Catalog entry that matched, if any.

        Returns:
            40 for a catalog entry of this adapter, 30 for an ONVIF device, 5 for a host with a web port.
        """
        if hints and hints.get("adapter") == self.name:
            return 40
        if fingerprint.onvif_port is not None or any("onvif" in scope for scope in fingerprint.scopes):
            return 30
        if 80 in fingerprint.open_ports:
            return 5
        return 0

    async def profiles(self, client: OnvifClient) -> list[Profile]:
        """Read every media profile with its stream address, through Media2 when Media1 gives none.

        Args:
            client: The device's client.

        Returns:
            The profiles.

        Raises:
            AdapterError: The device refuses the credentials or does not answer.
        """
        try:
            profiles = await client.stream_profiles()
        except OnvifRefused:
            raise AdapterError("unreachable", f"{client.host} refuses ONVIF connections on port {client.port}")
        except OnvifFault as exc:
            if refused_login(exc):
                raise AdapterError("unauthorized", "The device refused the login")
            profiles = []
        except OnvifError as exc:
            raise AdapterError("unreachable", str(exc))
        if any(profile.stream_uri for profile in profiles):
            return profiles
        return await self.media2_profiles(client)

    async def media2_profiles(self, client: OnvifClient) -> list[Profile]:
        """Read the profiles and stream addresses of a Profile T device through Media2.

        Args:
            client: The device's client.

        Returns:
            The profiles, empty when the device has no Media2 either.
        """
        address = client.local_address(None, "/onvif/media2_service")
        try:
            services = await client.services()
            address = services.get("media2", address)
            body = await client.call(address, media.profiles_body(media.MEDIA2))
        except OnvifError:
            return []
        result = []
        for item in media.parse_profiles(body, media.MEDIA2):
            try:
                answer = await client.call(
                    address,
                    "<tr2:GetStreamUri><tr2:Protocol>RTSP</tr2:Protocol>"
                    f"<tr2:ProfileToken>{escape(item.token)}</tr2:ProfileToken></tr2:GetStreamUri>",
                )
            except OnvifError:
                continue
            result.append(
                Profile(
                    token=item.token,
                    name=item.name,
                    encoding=None,
                    width=None,
                    height=None,
                    ptz=False,
                    stream_uri=descendant_text(answer, "Uri"),
                    source=item.source_token,
                )
            )
        return result

    async def services(self, client: OnvifClient) -> set[str]:
        """List the ONVIF services a device offers.

        Args:
            client: The device's client.

        Returns:
            Service names such as ptz, imaging, events and recording.
        """
        try:
            return set(await client.services())
        except OnvifError:
            return set()

    async def identify(self, target: Target) -> Identity:
        """Identify an ONVIF device: its vendor, its channels and what it can do.

        Args:
            target: How to reach it.

        Returns:
            The identity; a device with several video sources is a recorder.

        Raises:
            AdapterError: The device cannot be reached, refuses the credentials or has no stream.
        """
        client = self.client(target)
        try:
            info = await client.device_information()
        except OnvifRefused:
            raise AdapterError("unreachable", f"{target.host} refuses ONVIF connections")
        except OnvifFault:
            raise AdapterError("unauthorized", "The device refused the login")
        except OnvifError as exc:
            raise AdapterError("unreachable", str(exc))
        profiles = await self.profiles(client)
        channels = group_channels(profiles)
        if not channels:
            raise AdapterError("no_stream", "The device reported no stream")
        services = await self.services(client)
        identity = Identity(
            adapter=self.name,
            kind=DeviceKind.NVR if len(channels) > 1 else DeviceKind.CAMERA,
            vendor=info.manufacturer,
            model=info.model,
            firmware=info.firmware,
            serial=info.serial,
            rtsp_port=stream_port(profiles) or DEFAULT_RTSP_PORT,
            channels=tuple(channels),
        )
        return replace(identity, manifest=self.manifest(identity, services=services))

    async def streams(self, target: Target, channel: int = 1) -> Streams:
        """Return a channel's stream paths, read over ONVIF unless the target knows them.

        Args:
            target: How to reach the device.
            channel: Channel number from 1.

        Returns:
            The paths.

        Raises:
            AdapterError: The device has no such channel.
        """
        if target.main_path:
            return Streams(main=target.main_path, sub=target.sub_path, rtsp_port=target.rtsp_port)
        profiles = await self.profiles(self.client(target))
        channels = group_channels(profiles)
        if channel < 1 or channel > len(channels):
            raise AdapterError("no_stream", f"The device has no channel {channel}")
        found = channels[channel - 1]
        return Streams(main=found.main_path, sub=found.sub_path, rtsp_port=stream_port(profiles))

    def parse_label(self, text: str) -> LabelInfo | None:
        """Read a label that carries an ONVIF device service address.

        Args:
            text: Decoded QR text.

        Returns:
            The address as a label, or None for another text.
        """
        value = text.strip()
        parts = urlsplit(value)
        if parts.scheme in ("http", "https") and parts.hostname and "/onvif/" in parts.path.lower():
            return LabelInfo(
                adapter=self.name,
                format="onvif_service_address",
                confirmed=True,
                host=parts.hostname,
                port=parts.port or (443 if parts.scheme == "https" else 80),
                url=value,
            )
        return None

    def manifest(self, identity: Identity | None = None, **known) -> CapabilityManifest:
        """Build the manifest of an ONVIF device.

        Args:
            identity: The identity, when identified.
            **known: services, the ONVIF services found; or ptz and sub for a camera registered by hand.

        Returns:
            The manifest.
        """
        services = set(known.get("services") or ())
        channels = identity.channels if identity is not None else ()
        movable = any(item.ptz for item in channels) if channels else bool(known.get("ptz"))
        has_sub = any(item.sub_path for item in channels) if channels else bool(known.get("sub"))
        codecs = tuple(sorted({item.encoding for item in channels if item.encoding}))
        identified = identity is not None
        return CapabilityManifest(
            adapter=self.name,
            kind=identity.kind.value if identity is not None else "camera",
            channels=max(1, len(channels)),
            identify=True,
            media=MediaManifest(main=True, sub=has_sub, codecs=codecs),
            control=ControlManifest(ptz=movable, zoom=movable, presets=movable, home=movable),
            imaging=ImagingManifest(
                settings=IMAGING_SETTINGS if ("imaging" in services or not identified) else (),
                encoders=True,
                motion="analytics" in services or not identified,
            ),
            events=EventsManifest(kinds=EVENT_KINDS if ("events" in services or not identified) else ()),
            playback=PlaybackManifest(recordings="recording" in services, replay="replay" in services),
            maintenance=MaintenanceManifest(time=True, reboot=True),
        )

    async def ptz_profile(self, client: OnvifClient, channel: int) -> tuple[str, str]:
        """Find the PTZ service address and the profile that moves a channel.

        Args:
            client: The device's client.
            channel: Channel number from 1.

        Returns:
            The PTZ address and the profile token.

        Raises:
            AdapterError: The channel cannot be moved.
        """
        try:
            addresses = await client.service_addresses()
            profiles = await client.profiles(addresses.media)
        except OnvifError as exc:
            raise AdapterError("unreachable", str(exc))
        sources = list(dict.fromkeys(profile.source or "" for profile in profiles))
        wanted = sources[channel - 1] if 0 < channel <= len(sources) else None
        for profile in profiles:
            if profile.ptz and (wanted is None or (profile.source or "") == wanted):
                return addresses.ptz, profile.token
        raise AdapterError("unsupported", "The camera cannot be moved")

    async def move(self, target: Target, channel: int, pan: float, tilt: float, zoom: float) -> None:
        """Start a continuous move.

        Args:
            target: How to reach the device.
            channel: Channel number.
            pan: Pan speed.
            tilt: Tilt speed.
            zoom: Zoom speed.

        Raises:
            AdapterError: The camera refuses the move.
        """
        client = self.client(target)
        address, token = await self.ptz_profile(client, channel)
        try:
            await client.continuous_move(address, token, pan, tilt, zoom)
        except OnvifError as exc:
            raise AdapterError("unreachable", str(exc))

    async def stop(self, target: Target, channel: int) -> None:
        """Stop a move.

        Args:
            target: How to reach the device.
            channel: Channel number.

        Raises:
            AdapterError: The camera refuses the stop.
        """
        client = self.client(target)
        address, token = await self.ptz_profile(client, channel)
        try:
            await client.stop(address, token)
        except OnvifError as exc:
            raise AdapterError("unreachable", str(exc))

    async def goto_home(self, target: Target, channel: int) -> None:
        """Move to the home position.

        Args:
            target: How to reach the device.
            channel: Channel number.

        Raises:
            AdapterError: The camera refuses.
        """
        client = self.client(target)
        address, token = await self.ptz_profile(client, channel)
        try:
            await client.call(address, ptz.goto_home_body(token))
        except OnvifError as exc:
            raise AdapterError("unsupported", str(exc))

    def normalise(self, topic: str) -> str | None:
        """Map an ONVIF event topic to a normalised kind.

        Args:
            topic: The topic.

        Returns:
            The kind, or None.
        """
        return normalise_topic(topic)

    async def clock(self, target: Target) -> datetime | None:
        """Read the device's clock without authentication.

        Args:
            target: How to reach the device.

        Returns:
            Its UTC time, or None.

        Raises:
            AdapterError: The device does not answer.
        """
        client = self.client(target)
        try:
            body = await client.call(client.device_address, system.DATE_AND_TIME, secure=False)
        except OnvifError as exc:
            raise AdapterError("unreachable", str(exc))
        return parse_device_time(body)

    async def reboot(self, target: Target) -> None:
        """Restart the device.

        Args:
            target: How to reach the device.

        Raises:
            AdapterError: The device refuses.
        """
        client = self.client(target)
        try:
            await client.call(client.device_address, system.REBOOT)
        except OnvifError as exc:
            raise AdapterError("unreachable", str(exc))
