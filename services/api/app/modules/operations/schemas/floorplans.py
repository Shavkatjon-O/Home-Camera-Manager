"""Schemas of floor plans, with validation of their geometry and ids."""

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
    """Check a background image value.

    Args:
        value: Background as sent, if any.

    Returns:
        The data URL, or None when the value is None or empty.

    Raises:
        ValueError: When the value is not a base64 png, jpeg, webp or gif data URL.
    """
    if value is None or value == "":
        return None
    if not BACKGROUND_PATTERN.fullmatch(value):
        raise ValueError("must be a base64 image data URL")
    return value


def outside_plan(width_m: float, height_m: float, walls: list, access_points: list, devices: list) -> str | None:
    """Find the first item that lies outside the plan area.

    A small tolerance keeps items exactly on the far edge inside the plan.

    Args:
        width_m: Plan width in meters.
        height_m: Plan height in meters.
        walls: Walls of the plan.
        access_points: Routers of the plan.
        devices: Devices of the plan.

    Returns:
        A message naming the first item outside the plan, or None when every item is inside.
    """
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
    """Find an id that more than one item uses.

    Args:
        items: Items that carry an id.

    Returns:
        The first id seen twice, or None when all ids are unique.
    """
    seen: set[str] = set()
    for item in items:
        if item.id in seen:
            return item.id
        seen.add(item.id)
    return None


class Strict(BaseModel):
    """Base model that rejects unknown fields and non-finite numbers.

    Attributes:
        model_config: Forbids extra fields and infinite or NaN numbers.
    """

    model_config = ConfigDict(extra="forbid", allow_inf_nan=False)


class Item(Strict):
    """Plan item identified by an id that is unique within its list.

    Attributes:
        id: Identifier of the item, chosen by the editor.
    """

    id: str = Field(pattern=ITEM_ID_PATTERN)


class NamedItem(Item):
    """Plan item with a name and a position.

    Attributes:
        name: Display name of the item.
        x: Horizontal position in meters.
        y: Vertical position in meters.
    """

    name: str = Field(min_length=1, max_length=ITEM_NAME_MAX)
    x: Coordinate
    y: Coordinate

    @field_validator("name", mode="before")
    @classmethod
    def strip_name(cls, value):
        """Strip surrounding whitespace from the name.

        Args:
            value: Name as sent.

        Returns:
            The stripped name, or the value unchanged when it is not a string.
        """
        return value.strip() if isinstance(value, str) else value


class Wall(Item):
    """Straight wall segment between two points.

    Attributes:
        x1: Horizontal position of the first end in meters.
        y1: Vertical position of the first end in meters.
        x2: Horizontal position of the second end in meters.
        y2: Vertical position of the second end in meters.
        material: Material of the wall.
    """

    x1: Coordinate
    y1: Coordinate
    x2: Coordinate
    y2: Coordinate
    material: WallMaterial = WallMaterial.BRICK

    @model_validator(mode="after")
    def has_length(self):
        """Reject a wall whose two ends are the same point.

        Returns:
            The validated wall.

        Raises:
            ValueError: When both ends coincide.
        """
        if self.x1 == self.x2 and self.y1 == self.y2:
            raise ValueError("a wall needs two different ends")
        return self


class AccessPoint(NamedItem):
    """Router placed on the plan.

    Attributes:
        preset: Router model, or generic.
        band_24: Whether the 2.4 GHz band is on.
        band_5: Whether the 5 GHz band is on.
        power_24_dbm: Transmit power on 2.4 GHz in dBm.
        power_5_dbm: Transmit power on 5 GHz in dBm.
        locked: Whether the router stays where it is when the planner suggests router positions.
    """

    preset: AccessPointPreset = AccessPointPreset.GENERIC

    band_24: bool = True
    band_5: bool = True

    power_24_dbm: Power = POWER_24_DEFAULT_DBM
    power_5_dbm: Power = POWER_5_DEFAULT_DBM

    locked: bool = False


class Device(NamedItem):
    """Client device placed on the plan.

    Attributes:
        band: Band the device connects on.
    """

    band: Band = Band.BAND_24


class PlanSettings(Strict):
    """Propagation and editor settings of a plan.

    Attributes:
        path_loss_exponent: Exponent of the signal loss over distance.
        target_dbm: Signal strength in dBm that counts as good coverage.
        snap_m: Grid step in meters that the editor snaps items to.
    """

    path_loss_exponent: float = Field(
        default=PATH_LOSS_EXPONENT_DEFAULT, ge=PATH_LOSS_EXPONENT_MIN, le=PATH_LOSS_EXPONENT_MAX
    )
    target_dbm: float = Field(default=TARGET_DEFAULT_DBM, ge=TARGET_MIN_DBM, le=TARGET_MAX_DBM)
    snap_m: float = Field(default=SNAP_DEFAULT_M, ge=SNAP_MIN_M, le=SNAP_MAX_M)


class PlanFields(Strict):
    """Validators shared by the create and update schemas."""

    @field_validator("name", mode="before", check_fields=False)
    @classmethod
    def strip_name(cls, value):
        """Strip surrounding whitespace from the plan name.

        Args:
            value: Name as sent.

        Returns:
            The stripped name, or the value unchanged when it is not a string.
        """
        return value.strip() if isinstance(value, str) else value

    @field_validator("background_image", check_fields=False)
    @classmethod
    def check_background(cls, value):
        """Validate the background image.

        Args:
            value: Background as sent, if any.

        Returns:
            The data URL, or None when it is empty.
        """
        return clean_background(value)

    @field_validator("walls", "access_points", "devices", check_fields=False)
    @classmethod
    def unique_ids(cls, value):
        """Reject a list in which an id appears twice.

        Args:
            value: Walls, routers or devices as sent, if any.

        Returns:
            The list unchanged.

        Raises:
            ValueError: When two items share an id.
        """
        if value is None:
            return value
        repeated = repeated_id(value)
        if repeated is not None:
            raise ValueError(f"the id {repeated} is used twice")
        return value


class FloorPlanCreate(PlanFields):
    """Request body that creates a floor plan.

    Attributes:
        name: Name of the plan.
        width_m: Plan width in meters.
        height_m: Plan height in meters.
        walls: Walls of the plan.
        access_points: Routers of the plan.
        devices: Devices of the plan.
        settings: Propagation and editor settings.
        background_image: Background image as a base64 data URL, if any.
        background_opacity: Opacity of the background image from 0 to 1.
    """

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
        """Reject a plan with an item outside its area.

        Returns:
            The validated plan.

        Raises:
            ValueError: When a wall, router or device lies outside the plan.
        """
        problem = outside_plan(self.width_m, self.height_m, self.walls, self.access_points, self.devices)
        if problem is not None:
            raise ValueError(problem)
        return self


class FloorPlanUpdate(PlanFields):
    """Request body that changes some fields of a floor plan.

    Fields that are left out are kept. The fields in REQUIRED_ON_UPDATE cannot be set to null.

    Attributes:
        name: New name of the plan.
        width_m: New plan width in meters.
        height_m: New plan height in meters.
        walls: New list of walls.
        access_points: New list of routers.
        devices: New list of devices.
        settings: New propagation and editor settings.
        background_image: New background image as a base64 data URL; null removes it.
        background_opacity: New opacity of the background image from 0 to 1.
    """

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
        """Reject an explicit null for a field that cannot be empty.

        Returns:
            The validated update.

        Raises:
            ValueError: When a required field was sent as null.
        """
        for field in REQUIRED_ON_UPDATE:
            if field in self.model_fields_set and getattr(self, field) is None:
                raise ValueError(f"{field} cannot be empty")
        return self


class FloorPlanSummary(BaseModel):
    """Floor plan as listed, without its background image.

    Attributes:
        uuid: Public id of the plan.
        name: Name of the plan.
        width_m: Plan width in meters.
        height_m: Plan height in meters.
        walls: Walls of the plan.
        access_points: Routers of the plan.
        devices: Devices of the plan.
        settings: Propagation and editor settings.
        has_background: Whether the plan has a background image.
        background_opacity: Opacity of the background image from 0 to 1.
        created_at: Time the plan was created.
        updated_at: Time the plan was last changed.
    """

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
    """Floor plan with its background image.

    Attributes:
        background_image: Background image as a base64 data URL, if any.
    """

    background_image: str | None


class FloorPlanList(BaseModel):
    """One page of floor plans.

    Attributes:
        items: Plan summaries on the page.
        total: Number of plans across all pages.
        page: One-based page number.
        page_size: Number of plans per page.
    """

    items: list[FloorPlanSummary]
    total: int
    page: int
    page_size: int
