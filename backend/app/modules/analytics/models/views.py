"""Analytics view: one camera, or one lens of a multi-lens camera, and how it is analysed."""

from uuid import UUID

from sqlalchemy import Boolean, Float, Integer, String, UniqueConstraint, Uuid
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["AnalyticsView"]


class AnalyticsView(BaseModel):
    """An analysed picture: a whole camera frame or one lens band of it.

    Attributes:
        camera_uuid: Camera the view belongs to.
        lens: 0 for the whole frame, otherwise the lens band counted from 1 at the top.
        name: Display name.
        profile: Pipeline profile.
        enabled: Whether the analytics service analyses the view.
        fps: Analysis rate in frames per second.
        tamper: Whether the tamper watch runs, None for the profile's default.
        moving: Whether the lens moves, so zones need a reference snapshot.
        tuning: Optional overrides of the rules engine's timing and distance settings.
    """

    __tablename__ = "analytics_views"
    __table_args__ = (UniqueConstraint("camera_uuid", "lens"),)

    camera_uuid: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), nullable=False, index=True)
    lens: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    profile: Mapped[str] = mapped_column(String(20), nullable=False, default="perimeter")
    enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    fps: Mapped[float] = mapped_column(Float, nullable=False, default=8.0)
    tamper: Mapped[bool | None] = mapped_column(Boolean, nullable=True)
    moving: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    tuning: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
