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
    min: float
    max: float


class ResolutionRead(BaseModel):
    width: int
    height: int


class ClockRead(BaseModel):
    camera_utc: datetime | None
    server_utc: datetime
    offset_seconds: float | None
    mode: str | None
    timezone: str | None
    daylight_savings: bool | None


class DeviceRead(BaseModel):
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
    encoding: str
    resolutions: list[ResolutionRead]
    fps_values: list[float]
    fps: RangeRead | None
    bitrate: RangeRead | None
    gop: RangeRead | None
    quality: RangeRead | None
    profiles: list[str]


class EncoderRead(BaseModel):
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
    camera_uuid: UUID
    supported: bool
    reason: str | None = None
    service: str | None = None
    encoders: list[EncoderRead] = []


class EncoderUpdate(BaseModel):
    encoding: str | None = Field(default=None, max_length=20)
    width: int | None = Field(default=None, ge=16, le=16384)
    height: int | None = Field(default=None, ge=16, le=16384)
    fps: float | None = Field(default=None, gt=0, le=240)
    bitrate: int | None = Field(default=None, ge=1, le=1_000_000)
    gop: int | None = Field(default=None, ge=1, le=10_000)
    quality: float | None = Field(default=None, ge=0, le=1000)
    profile: str | None = Field(default=None, max_length=30)


class ImageSettings(BaseModel):
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
    levels: dict[str, RangeRead]
    ir_cut_filter_modes: list[str]
    wdr_modes: list[str]
    wdr_level: RangeRead | None
    backlight_modes: list[str]
    backlight_level: RangeRead | None


class ImageRead(BaseModel):
    camera_uuid: UUID
    supported: bool
    reason: str | None = None
    source_token: str | None = None
    settings: ImageSettings | None = None
    options: ImageOptionsRead | None = None


class MotionRead(BaseModel):
    camera_uuid: UUID
    supported: bool
    reason: str | None = None
    sensitivity: int | None = None
    sensitivity_range: RangeRead | None = None
    enabled: bool | None = None
    active_cells: int | None = None
    cells: int | None = None


class MotionUpdate(BaseModel):
    sensitivity: int | None = Field(default=None, ge=0, le=100)
    enabled: bool | None = None


class PresetRead(BaseModel):
    token: str
    name: str


class PresetsRead(BaseModel):
    camera_uuid: UUID
    supported: bool
    reason: str | None = None
    endpoint: str | None = None
    presets: list[PresetRead] = []
    max_presets: int | None = None
    home_supported: bool = False


class PresetName(BaseModel):
    name: str = Field(min_length=1, max_length=NAME_MAX)

    @field_validator("name", mode="before")
    @classmethod
    def strip_name(cls, value):
        return value.strip() if isinstance(value, str) else value


class SegmentRead(BaseModel):
    start: datetime
    end: datetime


class RecordingsRead(BaseModel):
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
    start: datetime
    session: str | None = Field(default=None, max_length=64)


class ReplayRead(BaseModel):
    active: bool
    session: str | None = None
    stream: str | None = None
    start: datetime | None = None
    failure: str | None = None


class ExtrasRead(BaseModel):
    camera_uuid: UUID
    supported: bool
    reason: str | None = None
    light: bool = False
    siren: bool = False


class LightRequest(BaseModel):
    mode: str = Field(pattern="^(on|off|auto)$")


class SirenRequest(BaseModel):
    seconds: int = Field(default=0, ge=0, le=300)


class AudioRead(BaseModel):
    camera_uuid: UUID
    supported: bool
    reason: str | None = None
    codec: str | None = None
