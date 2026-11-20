"""Database model of a camera a connector found on its network."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import BigInteger, DateTime, ForeignKey, Integer, String, UniqueConstraint, Uuid
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel
from app.models.ownership import SiteOwned

__all__ = ["DiscoveredCamera"]


class DiscoveredCamera(SiteOwned, BaseModel):
    """A camera candidate a connector reported from WS-Discovery and its port sweep.

    Attributes:
        connector_id: Connector that found it.
        host: Address on the site's network.
        open_ports: Ports that accepted a connection.
        brand: Guessed brand, if any.
        manufacturer: Manufacturer it reported over ONVIF.
        model: Model it reported over ONVIF.
        onvif_port: ONVIF port that answered or was guessed.
        found_by: wsd, sweep or both.
        scopes: WS-Discovery scopes it announced.
        seen_at: When it was last reported.
        camera_uuid: Camera registered from it, if any.
    """

    __tablename__ = "discovered_cameras"
    __table_args__ = (UniqueConstraint("connector_id", "host"),)

    connector_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("connectors.id", ondelete="CASCADE"), nullable=False, index=True
    )
    host: Mapped[str] = mapped_column(String(255), nullable=False)
    open_ports: Mapped[list] = mapped_column(JSONB, nullable=False, default=list)
    brand: Mapped[str | None] = mapped_column(String(20), nullable=True)
    manufacturer: Mapped[str | None] = mapped_column(String(100), nullable=True)
    model: Mapped[str | None] = mapped_column(String(100), nullable=True)
    onvif_port: Mapped[int | None] = mapped_column(Integer, nullable=True)
    found_by: Mapped[str] = mapped_column(String(10), nullable=False, default="sweep")
    scopes: Mapped[list] = mapped_column(JSONB, nullable=False, default=list)
    seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    camera_uuid: Mapped[UUID | None] = mapped_column(Uuid(as_uuid=True), nullable=True)
