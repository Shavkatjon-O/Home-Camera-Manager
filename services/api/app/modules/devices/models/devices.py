"""Database model of a device: a camera, NVR or DVR whose channels are cameras."""

from datetime import datetime

from sqlalchemy import BigInteger, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel
from app.models.ownership import SiteOwned

__all__ = ["Device"]


class Device(SiteOwned, BaseModel):
    """A physical device at a site; a camera has one channel, a recorder one per video input.

    Attributes:
        connector_id: Connector that reaches the device, or None when the backend reaches it.
        kind: camera, nvr or dvr.
        adapter: Adapter that reaches it.
        name: Display name.
        vendor: Manufacturer it reported.
        model: Model it reported.
        host: Address on the site's network, or of the bridge that speaks for it.
        onvif_port: Control port, if any.
        rtsp_port: RTSP port.
        username: Login, for a device the backend reaches itself.
        password_encrypted: Encrypted password, for a device the backend reaches itself; a connector keeps its own.
        channel_count: Video channels it reported.
        capabilities: Capability manifest of the device.
        identified_at: When an adapter last identified it.
    """

    __tablename__ = "devices"

    connector_id: Mapped[int | None] = mapped_column(BigInteger, ForeignKey("connectors.id"), nullable=True, index=True)
    kind: Mapped[str] = mapped_column(String(10), nullable=False, default="camera", server_default="camera")
    adapter: Mapped[str] = mapped_column(String(20), nullable=False)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    vendor: Mapped[str | None] = mapped_column(String(100), nullable=True)
    model: Mapped[str | None] = mapped_column(String(100), nullable=True)
    host: Mapped[str] = mapped_column(String(255), nullable=False)
    onvif_port: Mapped[int | None] = mapped_column(Integer, nullable=True)
    rtsp_port: Mapped[int | None] = mapped_column(Integer, nullable=True)
    username: Mapped[str | None] = mapped_column(String(100), nullable=True)
    password_encrypted: Mapped[str | None] = mapped_column(Text, nullable=True)
    channel_count: Mapped[int] = mapped_column(Integer, nullable=False, default=1, server_default="1")
    capabilities: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict, server_default="{}")
    identified_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
