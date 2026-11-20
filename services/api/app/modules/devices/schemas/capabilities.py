"""Schemas of the normalised capability manifest that the apps show a camera's controls by."""

from pydantic import BaseModel

from camera_adapters.manifest import CapabilityManifest

__all__ = [
    "CapabilitiesRead",
    "ControlCapabilities",
    "EventCapabilities",
    "ImagingCapabilities",
    "MaintenanceCapabilities",
    "MediaCapabilities",
    "PlaybackCapabilities",
    "ProvisioningCapabilities",
    "capabilities_read",
]


class MediaCapabilities(BaseModel):
    """What the camera streams.

    Attributes:
        main: Whether it has a main stream.
        sub: Whether it has a sub stream.
        snapshot: Whether it serves still pictures itself.
        audio: Whether its streams carry sound.
        codecs: Video codecs it was seen streaming.
    """

    main: bool = True
    sub: bool = False
    snapshot: bool = False
    audio: bool = False
    codecs: list[str] = []


class ControlCapabilities(BaseModel):
    """What the camera can be moved or switched with.

    Attributes:
        ptz: Continuous pan and tilt.
        zoom: Continuous zoom.
        presets: Stored positions.
        home: A home position.
        light: A light.
        siren: A siren.
    """

    ptz: bool = False
    zoom: bool = False
    presets: bool = False
    home: bool = False
    light: bool = False
    siren: bool = False


class ImagingCapabilities(BaseModel):
    """Picture settings the camera exposes.

    Attributes:
        settings: Names of the settings.
        encoders: Whether its video encoders can be changed.
        motion: Whether its own motion detection can be tuned.
    """

    settings: list[str] = []
    encoders: bool = False
    motion: bool = False


class EventCapabilities(BaseModel):
    """Events the camera reports itself.

    Attributes:
        kinds: Normalised kinds such as motion, tamper, storage and reboot.
    """

    kinds: list[str] = []


class PlaybackCapabilities(BaseModel):
    """Recordings the camera keeps itself.

    Attributes:
        recordings: Whether it lists recordings.
        replay: Whether it replays them.
    """

    recordings: bool = False
    replay: bool = False


class MaintenanceCapabilities(BaseModel):
    """Maintenance the camera allows.

    Attributes:
        time: Whether its clock can be read and set.
        reboot: Whether it can be restarted.
    """

    time: bool = False
    reboot: bool = False


class ProvisioningCapabilities(BaseModel):
    """Ways a factory-new device of this kind joins Wi-Fi.

    Attributes:
        methods: Provisioning method ids it supports.
    """

    methods: list[str] = []


class CapabilitiesRead(BaseModel):
    """The capability manifest of a camera or device.

    Attributes:
        adapter: Adapter that reaches it.
        version: Manifest format version.
        kind: camera, nvr or dvr.
        channels: Video channels of its device.
        identify: Whether its vendor and model can be read.
        media: Its streams.
        control: Its movement and switches.
        imaging: Its picture settings.
        events: Its own events.
        playback: Its own recordings.
        maintenance: Its clock and restart.
        provisioning: Its Wi-Fi provisioning.
    """

    adapter: str
    version: int
    kind: str
    channels: int
    identify: bool
    media: MediaCapabilities
    control: ControlCapabilities
    imaging: ImagingCapabilities
    events: EventCapabilities
    playback: PlaybackCapabilities
    maintenance: MaintenanceCapabilities
    provisioning: ProvisioningCapabilities


def capabilities_read(manifest: CapabilityManifest | dict | None) -> CapabilitiesRead:
    """Build the API view of a manifest.

    Args:
        manifest: The manifest, or its stored JSON form.

    Returns:
        The manifest with every section filled in.
    """
    value = manifest if isinstance(manifest, CapabilityManifest) else CapabilityManifest.from_dict(manifest)
    return CapabilitiesRead.model_validate(value.to_dict())
