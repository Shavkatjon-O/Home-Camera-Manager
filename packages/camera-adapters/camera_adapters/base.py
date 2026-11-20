"""The adapter interface: what every adapter does, and the optional capabilities an adapter may add.

An adapter always fingerprints, identifies, streams and reads labels. Control, imaging, events, playback,
maintenance and provisioning are separate capabilities: an adapter that has one subclasses its class, and the
manifest an adapter builds for a camera says which of the capability's features that camera really has.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from datetime import datetime
from enum import StrEnum

from camera_adapters.manifest import CapabilityManifest

__all__ = [
    "Adapter",
    "AdapterError",
    "AdapterName",
    "Channel",
    "ControlCapability",
    "DeviceKind",
    "EventsCapability",
    "Fingerprint",
    "Identity",
    "ImagingCapability",
    "LabelInfo",
    "MaintenanceCapability",
    "PlaybackCapability",
    "ProvisioningCapability",
    "ProvisioningMethod",
    "ProvisioningPayload",
    "Recording",
    "Streams",
    "Target",
    "WifiNetwork",
]


class AdapterName(StrEnum):
    """Names of the built-in adapters, which are also the camera brands the backend stores."""

    EZVIZ = "ezviz"
    V380 = "v380"
    ONVIF = "onvif"
    RTSP = "rtsp"


class DeviceKind(StrEnum):
    """Kind of device behind an address."""

    CAMERA = "camera"
    NVR = "nvr"
    DVR = "dvr"


class AdapterError(Exception):
    """An adapter could not do what was asked.

    Attributes:
        code: Stable code: unreachable, unauthorized, unsupported, no_stream or invalid.
        message: Explanation.
    """

    def __init__(self, code: str, message: str):
        """Create the error.

        Args:
            code: Stable code.
            message: Explanation.
        """
        super().__init__(message)
        self.code = code
        self.message = message


@dataclass(frozen=True)
class Target:
    """How to reach one device.

    Attributes:
        host: Address on the device's network, or of the bridge that speaks for it.
        port: Control port, such as the ONVIF port.
        rtsp_port: RTSP port.
        username: Login.
        password: Password.
        device_id: Device id of a V380 camera.
        main_path: Known main stream path.
        sub_path: Known sub stream path.
        url: A full stream address, for the RTSP adapter.
        timeout: Seconds to wait for each answer.
    """

    host: str
    port: int | None = None
    rtsp_port: int | None = None
    username: str | None = None
    password: str | None = None
    device_id: str | None = None
    main_path: str | None = None
    sub_path: str | None = None
    url: str | None = None
    timeout: float = 5.0


@dataclass(frozen=True)
class Fingerprint:
    """What can be learned about an address without credentials.

    Attributes:
        host: The address.
        open_ports: Ports that accepted a connection.
        manufacturer: Manufacturer reported over ONVIF.
        model: Model reported over ONVIF.
        firmware: Firmware reported over ONVIF.
        onvif_port: Port that answered ONVIF.
        http_server: Server header of the web page on port 80.
        http_title: Title of that page.
        mac: Hardware address seen on the local network.
        scopes: WS-Discovery scopes.
        v380: Whether the V380 LAN protocol port answers.
    """

    host: str
    open_ports: tuple[int, ...] = ()
    manufacturer: str | None = None
    model: str | None = None
    firmware: str | None = None
    onvif_port: int | None = None
    http_server: str | None = None
    http_title: str | None = None
    mac: str | None = None
    scopes: tuple[str, ...] = ()
    v380: bool = False


@dataclass(frozen=True)
class Channel:
    """One video source of a device: the camera itself, or one input of an NVR or DVR.

    Attributes:
        index: Channel number from 1.
        name: Name the device gives it.
        token: Device token of the source, such as an ONVIF video source token.
        main_path: Main stream path.
        sub_path: Sub stream path, if any.
        width: Width of the main stream.
        height: Height of the main stream.
        encoding: Codec of the main stream.
        ptz: Whether the channel can be moved.
    """

    index: int
    name: str
    token: str | None = None
    main_path: str | None = None
    sub_path: str | None = None
    width: int | None = None
    height: int | None = None
    encoding: str | None = None
    ptz: bool = False


@dataclass(frozen=True)
class Identity:
    """What an adapter learned about a device with its credentials.

    Attributes:
        adapter: Adapter that identified it.
        kind: camera, nvr or dvr.
        vendor: Manufacturer.
        model: Model.
        firmware: Firmware version.
        serial: Serial number; it stays on the side that identified the device and never enters telemetry.
        rtsp_port: RTSP port its streams use.
        channels: Its video sources.
        manifest: Its capabilities.
    """

    adapter: str
    kind: DeviceKind = DeviceKind.CAMERA
    vendor: str | None = None
    model: str | None = None
    firmware: str | None = None
    serial: str | None = None
    rtsp_port: int | None = None
    channels: tuple[Channel, ...] = ()
    manifest: CapabilityManifest = field(default_factory=CapabilityManifest)


@dataclass(frozen=True)
class Streams:
    """Stream paths of one channel, without credentials.

    Attributes:
        main: Main stream path.
        sub: Sub stream path, if any.
        rtsp_port: RTSP port.
    """

    main: str
    sub: str | None = None
    rtsp_port: int | None = None


@dataclass(frozen=True)
class LabelInfo:
    """What a label QR code on a device says.

    Attributes:
        adapter: Adapter the label belongs to.
        format: Name of the label format that matched.
        confirmed: Whether the format follows a published standard; other formats are tolerant guesses.
        vendor: Vendor.
        model: Model.
        serial: Serial number.
        code: Verification or claim code printed with it.
        device_id: Device id, such as a V380 id.
        host: Address, when the label carries one.
        port: Port, when the label carries one.
        url: Stream or service address, when the label carries one.
        kind: camera, nvr or dvr.
    """

    adapter: str
    format: str
    confirmed: bool = False
    vendor: str | None = None
    model: str | None = None
    serial: str | None = None
    code: str | None = None
    device_id: str | None = None
    host: str | None = None
    port: int | None = None
    url: str | None = None
    kind: DeviceKind = DeviceKind.CAMERA


@dataclass(frozen=True)
class Recording:
    """A stretch of video the camera recorded itself.

    Attributes:
        start: Start time.
        end: End time.
        token: Device token of the recording.
    """

    start: datetime
    end: datetime
    token: str | None = None


@dataclass(frozen=True)
class WifiNetwork:
    """A Wi-Fi network a camera is to join during provisioning.

    Attributes:
        ssid: Network name.
        password: Network password.
        security: WPA, WPA2, WPA3 or open.
        hidden: Whether the network hides its name.
    """

    ssid: str
    password: str
    security: str = "WPA2"
    hidden: bool = False


@dataclass(frozen=True)
class ProvisioningMethod:
    """One way a factory-new device joins Wi-Fi, as the pairing catalog describes it.

    Attributes:
        id: Method id: wifi_qr, soft_ap, ble, sound_wave or matter.
        transport: What carries the network details: a QR code the camera reads, the camera's own access
            point, Bluetooth Low Energy, sound, or Matter commissioning.
        requires: What the phone needs, such as camera, bluetooth, wifi_join or microphone.
        steps: Steps shown to the user, in order.
    """

    id: str
    transport: str
    requires: tuple[str, ...] = ()
    steps: tuple[str, ...] = ()


@dataclass(frozen=True)
class ProvisioningPayload:
    """What the phone sends or shows to provision one device.

    Attributes:
        method: Method id.
        media_type: Kind of payload: text/plain for a QR text, audio/wav for a sound wave, or
            application/octet-stream for a Bluetooth or access point message.
        data: The payload.
        expires_in: Seconds the payload stays valid, if it carries a one-time token.
        claim: Token the device presents when it first reaches the backend, binding it to the site.
    """

    method: str
    media_type: str
    data: bytes
    expires_in: int | None = None
    claim: str | None = None


class Adapter(ABC):
    """Base of every adapter.

    Attributes:
        name: Adapter name.
        title: Name shown to people.
        priority: Rank among adapters that match equally well; higher wins.
    """

    name: str = ""
    title: str = ""
    priority: int = 0

    @abstractmethod
    def match(self, fingerprint: Fingerprint, hints: dict | None = None) -> int:
        """Score how well a fingerprint fits this adapter.

        Args:
            fingerprint: What is known about the address.
            hints: Catalog entry that matched the fingerprint, as a mapping with its adapter and kind, if any.

        Returns:
            0 when the adapter does not fit, otherwise a score where higher fits better.
        """

    @abstractmethod
    async def identify(self, target: Target) -> Identity:
        """Read a device's vendor, model, channels and capabilities.

        Args:
            target: How to reach it.

        Returns:
            The identity.

        Raises:
            AdapterError: The device cannot be reached, refuses the credentials or is not of this kind.
        """

    @abstractmethod
    async def streams(self, target: Target, channel: int = 1) -> Streams:
        """Return the stream paths of a channel.

        Args:
            target: How to reach the device.
            channel: Channel number from 1.

        Returns:
            The paths.

        Raises:
            AdapterError: The streams cannot be found.
        """

    async def snapshot(self, target: Target, channel: int = 1) -> bytes | None:
        """Return a still picture of a channel when the device serves one.

        Args:
            target: How to reach the device.
            channel: Channel number from 1.

        Returns:
            The JPEG, or None when the device serves no pictures.
        """
        return None

    def parse_label(self, text: str) -> LabelInfo | None:
        """Read a label QR code of a device of this kind.

        Args:
            text: The decoded QR text.

        Returns:
            What the label says, or None when it is not a label of this kind.
        """
        return None

    @abstractmethod
    def manifest(self, identity: Identity | None = None, **known) -> CapabilityManifest:
        """Build the capability manifest of a device.

        Args:
            identity: The device's identity, when it was identified.
            **known: Facts known without identification, such as ptz or sub for a camera registered by hand.

        Returns:
            The manifest.
        """


class ControlCapability(ABC):
    """Moving a channel and switching its extras."""

    @abstractmethod
    async def move(self, target: Target, channel: int, pan: float, tilt: float, zoom: float) -> None:
        """Start a continuous move.

        Args:
            target: How to reach the device.
            channel: Channel number.
            pan: Pan speed from -1 to 1.
            tilt: Tilt speed from -1 to 1.
            zoom: Zoom speed from -1 to 1.
        """

    @abstractmethod
    async def stop(self, target: Target, channel: int) -> None:
        """Stop a move.

        Args:
            target: How to reach the device.
            channel: Channel number.
        """

    async def goto_home(self, target: Target, channel: int) -> None:
        """Move to the home position.

        Args:
            target: How to reach the device.
            channel: Channel number.

        Raises:
            AdapterError: The device has no home position.
        """
        raise AdapterError("unsupported", "The camera has no home position")

    async def set_light(self, target: Target, channel: int, mode: str) -> None:
        """Switch the light.

        Args:
            target: How to reach the device.
            channel: Channel number.
            mode: on, off or auto.

        Raises:
            AdapterError: The camera has no light.
        """
        raise AdapterError("unsupported", "The camera has no light")

    async def set_siren(self, target: Target, channel: int, on: bool) -> None:
        """Switch the siren.

        Args:
            target: How to reach the device.
            channel: Channel number.
            on: Whether to sound it.

        Raises:
            AdapterError: The camera has no siren.
        """
        raise AdapterError("unsupported", "The camera has no siren")


class ImagingCapability(ABC):
    """Reading and changing picture settings."""

    @abstractmethod
    async def imaging(self, target: Target, channel: int) -> dict[str, float | str | bool]:
        """Read the picture settings of a channel.

        Args:
            target: How to reach the device.
            channel: Channel number.

        Returns:
            Setting name to value.
        """


class EventsCapability(ABC):
    """Turning a device's own events into normalised kinds."""

    @abstractmethod
    def normalise(self, topic: str) -> str | None:
        """Map one of the device's event topics to a normalised kind.

        Args:
            topic: Topic as the device names it.

        Returns:
            motion, tamper, storage, reboot or another normalised kind, or None for a topic of no interest.
        """


class PlaybackCapability(ABC):
    """Listing the recordings a device keeps itself."""

    @abstractmethod
    async def recordings(self, target: Target, channel: int, start: datetime, end: datetime) -> list[Recording]:
        """List the recordings of a channel in a time range.

        Args:
            target: How to reach the device.
            channel: Channel number.
            start: Range start.
            end: Range end.

        Returns:
            The recordings.
        """


class MaintenanceCapability(ABC):
    """Reading the clock of a device and restarting it."""

    @abstractmethod
    async def clock(self, target: Target) -> datetime | None:
        """Read the device's clock.

        Args:
            target: How to reach the device.

        Returns:
            Its time in UTC, or None when it reports none.
        """

    @abstractmethod
    async def reboot(self, target: Target) -> None:
        """Restart the device.

        Args:
            target: How to reach the device.
        """


class ProvisioningCapability(ABC):
    """Bringing a factory-new device onto Wi-Fi and binding it to a site.

    This is the contract the Wi-Fi provisioning methods implement when they are built: wifi_qr (the camera reads a
    QR code the phone shows, with a payload the adapter generates), soft_ap (the phone joins the camera's own
    access point and sends the network), ble (Improv Wi-Fi or a vendor Bluetooth protocol), sound_wave (the phone
    plays the network as sound) and matter (Matter commissioning). No adapter implements it yet, and the pairing
    catalog offers a method only once an adapter implements it.
    """

    @abstractmethod
    def provisioning_methods(self) -> list[ProvisioningMethod]:
        """List the provisioning methods the adapter implements.

        Returns:
            The methods.
        """

    @abstractmethod
    async def provisioning_payload(
        self, method: str, network: WifiNetwork, claim: str, label: LabelInfo | None = None
    ) -> ProvisioningPayload:
        """Build what the phone shows, plays or sends to provision a device.

        Args:
            method: Method id.
            network: Network the device joins.
            claim: One-time token the device presents when it first reaches the backend.
            label: The device's label, when it was scanned.

        Returns:
            The payload.
        """

    @abstractmethod
    async def provisioned(self, fingerprint: Fingerprint, claim: str) -> bool:
        """Tell whether a device that appeared on the network is the one provisioned with a claim.

        Args:
            fingerprint: The new device.
            claim: The claim token of the provisioning.

        Returns:
            True when it is.
        """
