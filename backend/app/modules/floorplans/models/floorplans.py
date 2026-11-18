from sqlalchemy import Double, String, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["FloorPlan"]


class FloorPlan(BaseModel):
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
