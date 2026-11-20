"""Database model of a camera."""

from sqlalchemy import BigInteger, Boolean, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel
from app.models.ownership import SiteOwned

__all__ = ["Camera"]


class Camera(SiteOwned, BaseModel):
    """Camera registered on the wall.

    Attributes:
        name: Display name.
        brand: Camera brand value, one of the CameraBrand members.
        location: Free-text place the camera watches.
        host: Address the streams are pulled from.
        device_host: Address of the camera itself when it differs from host, as for a bridged V380.
        rtsp_port: RTSP port of host.
        onvif_port: ONVIF port, or None when the camera has none.
        username: Camera login name.
        password_encrypted: Encrypted camera password.
        main_path: RTSP path of the main stream.
        sub_path: RTSP path of the sub stream, or None when there is none.
        lenses: Number of lenses the camera has.
        ptz_enabled: Whether pan, tilt and zoom control is on.
        position: Place of the camera in the wall order.
        enabled: Whether the camera is streamed.
        connector_id: Connector that reaches the camera on its site's network, or None when the backend reaches
            the camera itself; the password of a connector camera stays on the connector.
        device_id: Device the camera is a channel of.
        channel: Channel number of the camera on its device, from 1.
        capabilities: Normalised capability manifest of the camera, which the apps show controls by.
    """

    __tablename__ = "cameras"

    name: Mapped[str] = mapped_column(String(100), nullable=False)
    brand: Mapped[str] = mapped_column(String(20), nullable=False)
    location: Mapped[str | None] = mapped_column(String(100), nullable=True)

    host: Mapped[str] = mapped_column(String(255), nullable=False)
    device_host: Mapped[str | None] = mapped_column(String(255), nullable=True)
    rtsp_port: Mapped[int] = mapped_column(Integer, nullable=False, default=554)
    onvif_port: Mapped[int | None] = mapped_column(Integer, nullable=True)

    username: Mapped[str | None] = mapped_column(String(100), nullable=True)
    password_encrypted: Mapped[str | None] = mapped_column(Text, nullable=True)

    main_path: Mapped[str] = mapped_column(String(255), nullable=False)
    sub_path: Mapped[str | None] = mapped_column(String(255), nullable=True)
    lenses: Mapped[int] = mapped_column(Integer, nullable=False, default=1, server_default="1")

    ptz_enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    position: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)

    connector_id: Mapped[int | None] = mapped_column(BigInteger, ForeignKey("connectors.id"), nullable=True, index=True)

    device_id: Mapped[int | None] = mapped_column(BigInteger, ForeignKey("devices.id"), nullable=True, index=True)
    channel: Mapped[int | None] = mapped_column(Integer, nullable=True)
    capabilities: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict, server_default="{}")
