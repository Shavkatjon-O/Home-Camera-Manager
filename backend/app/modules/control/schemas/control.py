"""Schemas for reading and changing camera device, video, image, motion, PTZ, recording and extras settings."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field, field_validator

__all__ = [
    "AudioRead",
    "ClockRead",
    "DeviceRead",
    "EncoderOptionsRead",
    "EncoderRead",
    "EncoderUpdate",
    "ExtrasRead",
    "ImageOptionsRead",
    "ImageRead",
    "ImageSettings",
    "LightRequest",
    "MotionRead",
    "MotionUpdate",
    "PresetName",
    "PresetRead",
    "PresetsRead",
    "RangeRead",
    "RecordingsRead",
    "ReplayCreate",
    "ReplayRead",
    "ResolutionRead",
    "SegmentRead",
    "SirenRequest",
    "VideoRead",
]

NAME_MAX = 60


class RangeRead(BaseModel):
    """Inclusive numeric range a camera accepts for a setting.

    Attributes:
        min: Lowest accepted value.
        max: Highest accepted value.
    """

    min: float
    max: float


class ResolutionRead(BaseModel):
    """Video resolution a camera offers.

    Attributes:
        width: Width in pixels.
        height: Height in pixels.
    """

    width: int
    height: int


class ClockRead(BaseModel):
    """Camera clock compared with this server's clock.

    Attributes:
        camera_utc: Camera time in UTC, or None when the camera reported none.
        server_utc: This server's time in UTC when the camera was read.
        offset_seconds: Camera time minus server time in seconds, or None when the camera time is unknown.
        mode: Time setting mode the camera reports, such as manual or NTP.
        timezone: Time zone the camera reports.
        daylight_savings: Whether the camera applies daylight saving time.
    """

    camera_utc: datetime | None
    server_utc: datetime
    offset_seconds: float | None
    mode: str | None
    timezone: str | None
    daylight_savings: bool | None


class DeviceRead(BaseModel):
    """ONVIF device details of a camera.

    Attributes:
        camera_uuid: Public id of the camera.
        supported: Whether the camera could be read over ONVIF.
        reason: Why the camera could not be read, when it could not.
        endpoint: Label of the ONVIF endpoint that answered.
        manufacturer: Manufacturer the camera reports.
        model: Model the camera reports.
        firmware: Firmware version the camera reports.
        serial: Serial number the camera reports.
        hardware_id: Hardware id the camera reports.
        clock: Camera clock, when it could be read.
        can_reboot: Whether the camera can be rebooted through this API.
    """

    camera_uuid: UUID
    supported: bool
    reason: str | None = None
    endpoint: str | None = None
    manufacturer: str | None = None
    model: str | None = None
    firmware: str | None = None
    serial: str | None = None
    hardware_id: str | None = None
    clock: ClockRead | None = None
    can_reboot: bool = False


class EncoderOptionsRead(BaseModel):
    """Settings a camera offers for one encoding of a video encoder.

    Attributes:
        encoding: Encoding these options apply to, such as H264.
        resolutions: Resolutions offered.
        fps_values: Discrete frame rates offered.
        fps: Frame rate range, when the camera reports one.
        bitrate: Bitrate range, when the camera reports one.
        gop: Key frame interval range, when the camera reports one.
        quality: Quality range, when the camera reports one.
        profiles: Encoding profiles offered.
    """

    encoding: str
    resolutions: list[ResolutionRead]
    fps_values: list[float]
    fps: RangeRead | None
    bitrate: RangeRead | None
    gop: RangeRead | None
    quality: RangeRead | None
    profiles: list[str]


class EncoderRead(BaseModel):
    """Current settings of one video encoder and the options it offers.

    Attributes:
        token: ONVIF token of the encoder.
        name: Name of the encoder.
        profiles: Names of the media profiles that use the encoder.
        encoding: Current encoding.
        width: Current width in pixels.
        height: Current height in pixels.
        fps: Current frame rate.
        bitrate: Current bitrate.
        gop: Current key frame interval.
        quality: Current quality.
        profile: Current encoding profile.
        options: Settings the camera offers for each encoding.
    """

    token: str
    name: str
    profiles: list[str]
    encoding: str | None
    width: int | None
    height: int | None
    fps: float | None
    bitrate: int | None
    gop: int | None
    quality: float | None
    profile: str | None
    options: list[EncoderOptionsRead]


class VideoRead(BaseModel):
    """Video encoders of a camera.

    Attributes:
        camera_uuid: Public id of the camera.
        supported: Whether the encoders could be read over ONVIF.
        reason: Why they could not be read, when they could not.
        service: ONVIF media service the encoders were read from.
        encoders: Encoders of the camera.
    """

    camera_uuid: UUID
    supported: bool
    reason: str | None = None
    service: str | None = None
    encoders: list[EncoderRead] = []


class EncoderUpdate(BaseModel):
    """Video encoder values to change; fields left out stay as they are.

    Attributes:
        encoding: New encoding.
        width: New width in pixels; give it with height.
        height: New height in pixels; give it with width.
        fps: New frame rate.
        bitrate: New bitrate.
        gop: New key frame interval.
        quality: New quality.
        profile: New encoding profile.
    """

    encoding: str | None = Field(default=None, max_length=20)
    width: int | None = Field(default=None, ge=16, le=16384)
    height: int | None = Field(default=None, ge=16, le=16384)
    fps: float | None = Field(default=None, gt=0, le=240)
    bitrate: int | None = Field(default=None, ge=1, le=1_000_000)
    gop: int | None = Field(default=None, ge=1, le=10_000)
    quality: float | None = Field(default=None, ge=0, le=1000)
    profile: str | None = Field(default=None, max_length=30)


class ImageSettings(BaseModel):
    """Imaging settings of a camera; as a request, only the fields given are changed.

    Attributes:
        brightness: Image brightness.
        contrast: Image contrast.
        saturation: Color saturation.
        sharpness: Image sharpness.
        ir_cut_filter: Infrared cut filter mode.
        wdr_mode: Wide dynamic range mode.
        wdr_level: Wide dynamic range level.
        backlight_mode: Backlight compensation mode.
        backlight_level: Backlight compensation level.
    """

    brightness: float | None = None
    contrast: float | None = None
    saturation: float | None = None
    sharpness: float | None = None
    ir_cut_filter: str | None = Field(default=None, max_length=20)
    wdr_mode: str | None = Field(default=None, max_length=20)
    wdr_level: float | None = None
    backlight_mode: str | None = Field(default=None, max_length=20)
    backlight_level: float | None = None


class ImageOptionsRead(BaseModel):
    """Imaging settings a camera offers.

    Attributes:
        levels: Accepted range of each level setting, keyed by setting name.
        ir_cut_filter_modes: Infrared cut filter modes offered.
        wdr_modes: Wide dynamic range modes offered.
        wdr_level: Wide dynamic range level range, when the camera reports one.
        backlight_modes: Backlight compensation modes offered.
        backlight_level: Backlight compensation level range, when the camera reports one.
    """

    levels: dict[str, RangeRead]
    ir_cut_filter_modes: list[str]
    wdr_modes: list[str]
    wdr_level: RangeRead | None
    backlight_modes: list[str]
    backlight_level: RangeRead | None


class ImageRead(BaseModel):
    """Imaging settings of a camera and the options it offers.

    Attributes:
        camera_uuid: Public id of the camera.
        supported: Whether the settings could be read over ONVIF.
        reason: Why they could not be read, when they could not.
        source_token: ONVIF token of the video source the settings belong to.
        settings: Current imaging settings.
        options: Imaging settings the camera offers.
    """

    camera_uuid: UUID
    supported: bool
    reason: str | None = None
    source_token: str | None = None
    settings: ImageSettings | None = None
    options: ImageOptionsRead | None = None


class MotionRead(BaseModel):
    """Motion detection setup of a camera.

    Attributes:
        camera_uuid: Public id of the camera.
        supported: Whether the setup could be read over ONVIF.
        reason: Why it could not be read, when it could not.
        sensitivity: Current motion sensitivity.
        sensitivity_range: Range the sensitivity can be set in.
        enabled: Whether any detection cell is active, or None when the cells are unknown.
        active_cells: Number of active detection cells.
        cells: Total number of detection cells.
    """

    camera_uuid: UUID
    supported: bool
    reason: str | None = None
    sensitivity: int | None = None
    sensitivity_range: RangeRead | None = None
    enabled: bool | None = None
    active_cells: int | None = None
    cells: int | None = None


class MotionUpdate(BaseModel):
    """Motion detection values to change; fields left out stay as they are.

    Attributes:
        sensitivity: New motion sensitivity from 0 to 100.
        enabled: Whether detection should be on.
    """

    sensitivity: int | None = Field(default=None, ge=0, le=100)
    enabled: bool | None = None


class PresetRead(BaseModel):
    """One PTZ preset.

    Attributes:
        token: ONVIF token of the preset.
        name: Name of the preset.
    """

    token: str
    name: str


class PresetsRead(BaseModel):
    """PTZ presets of a camera.

    Attributes:
        camera_uuid: Public id of the camera.
        supported: Whether the presets could be read over ONVIF.
        reason: Why they could not be read, when they could not.
        endpoint: Label of the ONVIF endpoint that serves PTZ.
        presets: Presets stored on the camera.
        max_presets: Number of presets the camera can store.
        home_supported: Whether the camera has a PTZ home position.
    """

    camera_uuid: UUID
    supported: bool
    reason: str | None = None
    endpoint: str | None = None
    presets: list[PresetRead] = []
    max_presets: int | None = None
    home_supported: bool = False


class PresetName(BaseModel):
    """Name for a PTZ preset.

    Attributes:
        name: Preset name with surrounding whitespace removed.
    """

    name: str = Field(min_length=1, max_length=NAME_MAX)

    @field_validator("name", mode="before")
    @classmethod
    def strip_name(cls, value):
        """Remove surrounding whitespace from a preset name before validation.

        Args:
            value: Raw value of the name field.

        Returns:
            The stripped string, or the value unchanged when it is not a string.
        """
        return value.strip() if isinstance(value, str) else value


class SegmentRead(BaseModel):
    """One stretch of continuous recording.

    Attributes:
        start: Start of the stretch.
        end: End of the stretch.
    """

    start: datetime
    end: datetime


class RecordingsRead(BaseModel):
    """Recordings on a camera's SD card and the segments within a time range.

    Attributes:
        camera_uuid: Public id of the camera.
        supported: Whether the recordings could be read over ONVIF.
        reason: Why they could not be read, or why the segment search failed.
        recordings: Number of recordings the camera reports.
        data_from: Time of the oldest recorded data.
        data_until: Time of the newest recorded data.
        start: Start of the requested range.
        end: End of the requested range.
        segments: Recorded segments inside the range.
        playback: Whether SD card playback is available.
        playback_reason: Why playback is unavailable, when it is.
    """

    camera_uuid: UUID
    supported: bool
    reason: str | None = None
    recordings: int | None = None
    data_from: datetime | None = None
    data_until: datetime | None = None
    start: datetime | None = None
    end: datetime | None = None
    segments: list[SegmentRead] = []
    playback: bool = False
    playback_reason: str | None = None


class ReplayCreate(BaseModel):
    """Request to start SD card playback.

    Attributes:
        start: Time to start playing from.
        session: Id of the client's playback session, if it has one.
    """

    start: datetime
    session: str | None = Field(default=None, max_length=64)


class ReplayRead(BaseModel):
    """State of a camera's SD card playback session.

    Attributes:
        active: Whether a session is running.
        session: Id of the session.
        stream: Name of the go2rtc stream carrying the playback.
        start: Time the playback started from.
        failure: Why the last session ended, when it failed.
    """

    active: bool
    session: str | None = None
    stream: str | None = None
    start: datetime | None = None
    failure: str | None = None


class ExtrasRead(BaseModel):
    """Light and siren availability behind a V380 bridge.

    Attributes:
        camera_uuid: Public id of the camera.
        supported: Whether the bridge is reachable.
        reason: Why the extras are unavailable, when they are.
        light: Whether the light can be controlled.
        siren: Whether the siren can be controlled.
    """

    camera_uuid: UUID
    supported: bool
    reason: str | None = None
    light: bool = False
    siren: bool = False


class LightRequest(BaseModel):
    """Request to set the light mode.

    Attributes:
        mode: One of on, off or auto.
    """

    mode: str = Field(pattern="^(on|off|auto)$")


class SirenRequest(BaseModel):
    """Request to sound or silence the siren.

    Attributes:
        seconds: How long to sound the siren; 0 turns it off.
    """

    seconds: int = Field(default=0, ge=0, le=300)


class AudioRead(BaseModel):
    """Audio of a camera stream.

    Attributes:
        camera_uuid: Public id of the camera.
        supported: Whether the stream carries audio the browser player can play.
        reason: Why the audio is unavailable, when it is.
        codec: Name of the audio codec.
    """

    camera_uuid: UUID
    supported: bool
    reason: str | None = None
    codec: str | None = None
