"""Database model of a site."""

from sqlalchemy import BigInteger, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["Site"]


class Site(BaseModel):
    """A place with cameras: a home, a store, an office, a warehouse or another kind of place.

    Attributes:
        organisation_id: Organisation the site belongs to.
        name: Display name.
        kind: Site kind, one of the SiteKind members.
        timezone: IANA time zone of schedules, counts and area resets at the site.
        position: Order of the site within its organisation.
        event_retention_days: Days the site keeps its events, None for as long as the plan and the server allow.
    """

    __tablename__ = "sites"

    organisation_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("organisations.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    kind: Mapped[str] = mapped_column(String(20), nullable=False, default="home")
    timezone: Mapped[str] = mapped_column(String(64), nullable=False, default="UTC")
    position: Mapped[int] = mapped_column(Integer, nullable=False, default=0, server_default="0")
    event_retention_days: Mapped[int | None] = mapped_column(Integer, nullable=True)
