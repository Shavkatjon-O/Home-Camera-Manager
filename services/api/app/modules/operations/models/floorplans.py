"""Model of a floor plan."""

from sqlalchemy import Double, String, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel
from app.models.ownership import SiteOwned

__all__ = ["FloorPlan"]


class FloorPlan(SiteOwned, BaseModel):
    """Floor plan with its walls, routers and devices.

    Attributes:
        name: Name of the plan.
        width_m: Plan width in meters.
        height_m: Plan height in meters.
        walls: Walls as stored JSON objects.
        access_points: Routers as stored JSON objects.
        devices: Devices as stored JSON objects.
        settings: Propagation and editor settings as a stored JSON object.
        background_image: Background image as a base64 data URL, if any.
        background_opacity: Opacity of the background image from 0 to 1.
    """

    __tablename__ = "floor_plans"

    name: Mapped[str] = mapped_column(String(100), nullable=False)

    width_m: Mapped[float] = mapped_column(Double, nullable=False)
    height_m: Mapped[float] = mapped_column(Double, nullable=False)

    walls: Mapped[list[dict]] = mapped_column(JSONB, nullable=False, default=list)
    access_points: Mapped[list[dict]] = mapped_column(JSONB, nullable=False, default=list)
    devices: Mapped[list[dict]] = mapped_column(JSONB, nullable=False, default=list)
    settings: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)

    background_image: Mapped[str | None] = mapped_column(Text, nullable=True)
    background_opacity: Mapped[float] = mapped_column(Double, nullable=False, default=0.5)
