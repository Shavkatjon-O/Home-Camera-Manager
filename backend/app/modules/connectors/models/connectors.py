"""Database model of a connector."""

from datetime import datetime

from sqlalchemy import DateTime, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel
from app.models.ownership import SiteOwned

__all__ = ["Connector"]


class Connector(SiteOwned, BaseModel):
    """A paired site agent: go2rtc and the agent on a machine in the site's network.

    Central reaches the connector at its address, which in direct mode is an address on the site's network or a
    public one and in tunnel mode its overlay address; nothing else differs between the two modes.

    Attributes:
        name: Display name.
        token_hash: SHA-256 of the connector's token for its calls to the backend.
        agent_key_encrypted: Encrypted key central sends on its calls to the connector's agent.
        stream_username: RTSP user of the connector's go2rtc.
        stream_password_encrypted: Encrypted RTSP password of the connector's go2rtc.
        version: Agent version it last reported.
        mode: direct or tunnel.
        address: Address central reaches the connector at.
        api_port: Port of the agent API.
        rtsp_port: RTSP port of the connector's go2rtc.
        public_key: WireGuard public key the connector sent when pairing, for the tunnel.
        tunnel_address: Overlay address assigned in tunnel mode.
        last_seen_at: When the last heartbeat arrived.
        health: Health the connector last reported.
        discovery_requested_at: When a member last asked for a discovery run.
        discovered_at: When the connector last reported discovery results.
        revoked_at: When the connector was removed, or None while it is paired.
    """

    __tablename__ = "connectors"

    name: Mapped[str] = mapped_column(String(100), nullable=False)
    token_hash: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    agent_key_encrypted: Mapped[str] = mapped_column(Text, nullable=False)
    stream_username: Mapped[str] = mapped_column(String(40), nullable=False)
    stream_password_encrypted: Mapped[str] = mapped_column(Text, nullable=False)

    version: Mapped[str | None] = mapped_column(String(40), nullable=True)
    mode: Mapped[str] = mapped_column(String(10), nullable=False, default="direct", server_default="direct")
    address: Mapped[str | None] = mapped_column(String(255), nullable=True)
    api_port: Mapped[int] = mapped_column(Integer, nullable=False, default=8780, server_default="8780")
    rtsp_port: Mapped[int] = mapped_column(Integer, nullable=False, default=8554, server_default="8554")

    public_key: Mapped[str | None] = mapped_column(String(64), nullable=True)
    tunnel_address: Mapped[str | None] = mapped_column(String(45), nullable=True)

    last_seen_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    health: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
    discovery_requested_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    discovered_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
