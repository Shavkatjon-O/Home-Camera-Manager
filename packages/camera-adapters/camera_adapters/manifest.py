"""The normalised capability manifest a camera stores, so the apps show only the controls it really has."""

from dataclasses import asdict, dataclass, field, fields

__all__ = [
    "MANIFEST_VERSION",
    "CapabilityManifest",
    "ControlManifest",
    "EventsManifest",
    "ImagingManifest",
    "MaintenanceManifest",
    "MediaManifest",
    "PlaybackManifest",
    "ProvisioningManifest",
]

MANIFEST_VERSION = 1


@dataclass(frozen=True)
class MediaManifest:
    """What the camera streams.

    Attributes:
        main: Whether it has a main stream.
        sub: Whether it has a sub stream.
        snapshot: Whether it serves still pictures.
        audio: Whether its streams carry sound.
        codecs: Video codecs it was seen streaming, such as h264.
    """

    main: bool = True
    sub: bool = False
    snapshot: bool = False
    audio: bool = False
    codecs: tuple[str, ...] = ()


@dataclass(frozen=True)
class ControlManifest:
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


@dataclass(frozen=True)
class ImagingManifest:
    """Picture settings the camera exposes.

    Attributes:
        settings: Names of the settings, such as brightness or ir_cut.
        encoders: Whether its video encoders can be changed.
        motion: Whether its own motion detection can be tuned.
    """

    settings: tuple[str, ...] = ()
    encoders: bool = False
    motion: bool = False


@dataclass(frozen=True)
class EventsManifest:
    """Events the camera reports itself, in normalised kinds.

    Attributes:
        kinds: Kinds such as motion, tamper, storage and reboot.
    """

    kinds: tuple[str, ...] = ()


@dataclass(frozen=True)
class PlaybackManifest:
    """Recordings the camera keeps itself.

    Attributes:
        recordings: Whether it lists recordings.
        replay: Whether it replays them over RTSP.
    """

    recordings: bool = False
    replay: bool = False


@dataclass(frozen=True)
class MaintenanceManifest:
    """Maintenance the camera allows.

    Attributes:
        time: Whether its clock can be read and set.
        reboot: Whether it can be restarted.
    """

    time: bool = False
    reboot: bool = False


@dataclass(frozen=True)
class ProvisioningManifest:
    """Ways a factory-new camera of this kind joins Wi-Fi.

    Attributes:
        methods: Provisioning method ids it supports; none is offered yet.
    """

    methods: tuple[str, ...] = ()


SECTIONS = {
    "media": MediaManifest,
    "control": ControlManifest,
    "imaging": ImagingManifest,
    "events": EventsManifest,
    "playback": PlaybackManifest,
    "maintenance": MaintenanceManifest,
    "provisioning": ProvisioningManifest,
}


@dataclass(frozen=True)
class CapabilityManifest:
    """Everything a camera or channel can do, normalised across adapters.

    Attributes:
        adapter: Adapter that reaches it.
        version: Manifest format version.
        kind: camera, nvr or dvr.
        channels: Video channels of the device it belongs to.
        identify: Whether its vendor and model can be read.
        media: Its streams.
        control: Its movement and switches.
        imaging: Its picture settings.
        events: Its own events.
        playback: Its own recordings.
        maintenance: Its clock and restart.
        provisioning: Its Wi-Fi provisioning.
    """

    adapter: str = "rtsp"
    version: int = MANIFEST_VERSION
    kind: str = "camera"
    channels: int = 1
    identify: bool = False
    media: MediaManifest = field(default_factory=MediaManifest)
    control: ControlManifest = field(default_factory=ControlManifest)
    imaging: ImagingManifest = field(default_factory=ImagingManifest)
    events: EventsManifest = field(default_factory=EventsManifest)
    playback: PlaybackManifest = field(default_factory=PlaybackManifest)
    maintenance: MaintenanceManifest = field(default_factory=MaintenanceManifest)
    provisioning: ProvisioningManifest = field(default_factory=ProvisioningManifest)

    def to_dict(self) -> dict:
        """Return the manifest as JSON data.

        Returns:
            A mapping with lists for the tuples.
        """
        data = asdict(self)
        for section in data.values():
            if isinstance(section, dict):
                for key, value in section.items():
                    if isinstance(value, tuple):
                        section[key] = list(value)
        return data

    @classmethod
    def from_dict(cls, data: dict | None) -> "CapabilityManifest":
        """Read a manifest from JSON data, ignoring unknown keys and filling missing ones.

        Args:
            data: The mapping, if any.

        Returns:
            The manifest.
        """
        data = data or {}
        values = {}
        for item in fields(cls):
            if item.name not in data:
                continue
            value = data[item.name]
            section = SECTIONS.get(item.name)
            if section is not None:
                known = {part.name for part in fields(section)}
                value = section(
                    **{
                        key: tuple(entry) if isinstance(entry, list) else entry
                        for key, entry in (value or {}).items()
                        if key in known
                    }
                )
            values[item.name] = value
        return cls(**values)

    def replaced(self, **changes) -> "CapabilityManifest":
        """Return a copy with some fields or section fields changed.

        Args:
            **changes: Top-level fields, or sections as mappings of the fields to change.

        Returns:
            The new manifest.
        """
        data = self.to_dict()
        for key, value in changes.items():
            if key in SECTIONS and isinstance(value, dict):
                data[key] = {**data[key], **value}
            else:
                data[key] = value
        return CapabilityManifest.from_dict(data)
