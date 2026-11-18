import re
from datetime import datetime
from typing import Annotated
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

from app.modules.floorplans.enums import AccessPointPreset, Band, WallMaterial

__all__ = [
    "AccessPoint",
    "Device",
    "FloorPlanCreate",
    "FloorPlanList",
    "FloorPlanRead",
    "FloorPlanSummary",
    "FloorPlanUpdate",
    "PlanSettings",
    "Wall",
    "clean_background",
    "outside_plan",
]

PLAN_SIZE_MIN_M = 1.0
PLAN_SIZE_MAX_M = 200.0
EDGE_TOLERANCE_M = 1e-6

PLAN_NAME_MAX = 100
ITEM_NAME_MAX = 60
ITEM_ID_PATTERN = r"^[A-Za-z0-9_-]{1,40}$"

WALLS_MAX = 2000
ACCESS_POINTS_MAX = 20
DEVICES_MAX = 200

POWER_MIN_DBM = 0.0
POWER_MAX_DBM = 30.0
POWER_24_DEFAULT_DBM = 20.0
POWER_5_DEFAULT_DBM = 23.0

PATH_LOSS_EXPONENT_MIN = 1.6
PATH_LOSS_EXPONENT_MAX = 4.0
PATH_LOSS_EXPONENT_DEFAULT = 3.0

TARGET_MIN_DBM = -90.0
TARGET_MAX_DBM = -40.0
TARGET_DEFAULT_DBM = -67.0

SNAP_MIN_M = 0.05
SNAP_MAX_M = 1.0
SNAP_DEFAULT_M = 0.1

BACKGROUND_MAX_CHARS = 4_000_000
BACKGROUND_PATTERN = re.compile(r"data:image/(?:png|jpeg|webp|gif);base64,[A-Za-z0-9+/]+={0,2}")
BACKGROUND_OPACITY_DEFAULT = 0.5

REQUIRED_ON_UPDATE = (
    "name",
    "width_m",
    "height_m",
    "walls",
    "access_points",
    "devices",
    "settings",
    "background_opacity",
)

Coordinate = Annotated[float, Field(ge=0.0, le=PLAN_SIZE_MAX_M)]
PlanSize = Annotated[float, Field(ge=PLAN_SIZE_MIN_M, le=PLAN_SIZE_MAX_M)]
Power = Annotated[float, Field(ge=POWER_MIN_DBM, le=POWER_MAX_DBM)]
Opacity = Annotated[float, Field(ge=0.0, le=1.0)]


def clean_background(value: str | None) -> str | None:
    if value is None or value == "":
        return None
    if not BACKGROUND_PATTERN.fullmatch(value):
        raise ValueError("must be a base64 image data URL")
    return value


def outside_plan(width_m: float, height_m: float, walls: list, access_points: list, devices: list) -> str | None:
    limit_x = width_m + EDGE_TOLERANCE_M
    limit_y = height_m + EDGE_TOLERANCE_M
    size = f"{width_m:g} by {height_m:g} m"
    for wall in walls:
        if max(wall.x1, wall.x2) > limit_x or max(wall.y1, wall.y2) > limit_y:
            return f"Wall {wall.id} lies outside the {size} plan"
    for access_point in access_points:
        if access_point.x > limit_x or access_point.y > limit_y:
            return f"Router {access_point.name} lies outside the {size} plan"
    for device in devices:
        if device.x > limit_x or device.y > limit_y:
            return f"Device {device.name} lies outside the {size} plan"
    return None


def repeated_id(items: list) -> str | None:
    seen: set[str] = set()
    for item in items:
        if item.id in seen:
            return item.id
        seen.add(item.id)
    return None


class Strict(BaseModel):
    model_config = ConfigDict(extra="forbid", allow_inf_nan=False)


class Item(Strict):
    id: str = Field(pattern=ITEM_ID_PATTERN)


class NamedItem(Item):
    name: str = Field(min_length=1, max_length=ITEM_NAME_MAX)
    x: Coordinate
    y: Coordinate

    @field_validator("name", mode="before")
    @classmethod
    def strip_name(cls, value):
        return value.strip() if isinstance(value, str) else value


class Wall(Item):
    x1: Coordinate
    y1: Coordinate
    x2: Coordinate
    y2: Coordinate
    material: WallMaterial = WallMaterial.BRICK

    @model_validator(mode="after")
    def has_length(self):
        if self.x1 == self.x2 and self.y1 == self.y2:
            raise ValueError("a wall needs two different ends")
        return self


class AccessPoint(NamedItem):
    preset: AccessPointPreset = AccessPointPreset.GENERIC

    band_24: bool = True
    band_5: bool = True

    power_24_dbm: Power = POWER_24_DEFAULT_DBM
    power_5_dbm: Power = POWER_5_DEFAULT_DBM

    locked: bool = False


class Device(NamedItem):
    band: Band = Band.BAND_24


class PlanSettings(Strict):
    path_loss_exponent: float = Field(
        default=PATH_LOSS_EXPONENT_DEFAULT, ge=PATH_LOSS_EXPONENT_MIN, le=PATH_LOSS_EXPONENT_MAX
    )
    target_dbm: float = Field(default=TARGET_DEFAULT_DBM, ge=TARGET_MIN_DBM, le=TARGET_MAX_DBM)
    snap_m: float = Field(default=SNAP_DEFAULT_M, ge=SNAP_MIN_M, le=SNAP_MAX_M)


class PlanFields(Strict):
    @field_validator("name", mode="before", check_fields=False)
    @classmethod
    def strip_name(cls, value):
        return value.strip() if isinstance(value, str) else value

    @field_validator("background_image", check_fields=False)
    @classmethod
    def check_background(cls, value):
        return clean_background(value)

    @field_validator("walls", "access_points", "devices", check_fields=False)
    @classmethod
    def unique_ids(cls, value):
        if value is None:
            return value
        repeated = repeated_id(value)
        if repeated is not None:
            raise ValueError(f"the id {repeated} is used twice")
        return value


class FloorPlanCreate(PlanFields):
    name: str = Field(min_length=1, max_length=PLAN_NAME_MAX)

    width_m: PlanSize
    height_m: PlanSize

    walls: list[Wall] = Field(default_factory=list, max_length=WALLS_MAX)
    access_points: list[AccessPoint] = Field(default_factory=list, max_length=ACCESS_POINTS_MAX)
    devices: list[Device] = Field(default_factory=list, max_length=DEVICES_MAX)
    settings: PlanSettings = Field(default_factory=PlanSettings)

    background_image: str | None = Field(default=None, max_length=BACKGROUND_MAX_CHARS)
    background_opacity: Opacity = BACKGROUND_OPACITY_DEFAULT

    @model_validator(mode="after")
    def inside_plan(self):
        problem = outside_plan(self.width_m, self.height_m, self.walls, self.access_points, self.devices)
        if problem is not None:
            raise ValueError(problem)
        return self


class FloorPlanUpdate(PlanFields):
    name: str | None = Field(default=None, min_length=1, max_length=PLAN_NAME_MAX)

    width_m: PlanSize | None = None
    height_m: PlanSize | None = None

    walls: list[Wall] | None = Field(default=None, max_length=WALLS_MAX)
    access_points: list[AccessPoint] | None = Field(default=None, max_length=ACCESS_POINTS_MAX)
    devices: list[Device] | None = Field(default=None, max_length=DEVICES_MAX)
    settings: PlanSettings | None = None

    background_image: str | None = Field(default=None, max_length=BACKGROUND_MAX_CHARS)
    background_opacity: Opacity | None = None

    @model_validator(mode="after")
    def reject_null_required(self):
        for field in REQUIRED_ON_UPDATE:
            if field in self.model_fields_set and getattr(self, field) is None:
                raise ValueError(f"{field} cannot be empty")
        return self


class FloorPlanSummary(BaseModel):
    uuid: UUID
    name: str

    width_m: float
    height_m: float

    walls: list[Wall]
    access_points: list[AccessPoint]
    devices: list[Device]
    settings: PlanSettings

    has_background: bool
    background_opacity: float

    created_at: datetime
    updated_at: datetime


class FloorPlanRead(FloorPlanSummary):
    background_image: str | None


class FloorPlanList(BaseModel):
    items: list[FloorPlanSummary]
    total: int
    page: int
    page_size: int
