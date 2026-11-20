"""Database model of a connector pairing request."""

from datetime import datetime

from sqlalchemy import BigInteger, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["ConnectorPairing"]


class ConnectorPairing(BaseModel):
    """An RFC 8628 device authorization that a connector opened and a member claims for a site.

    Attributes:
        device_code_hash: SHA-256 of the device code the connector polls with.
        user_code: Code the connector shows and the member types or scans, without its hyphen.
        name: Name the connector asked to be paired under.
        version: Agent version of the connector.
        public_key: WireGuard public key of the connector, if it sent one.
        expires_at: When the codes stop working.
        interval: Seconds the connector must wait between polls.
        last_polled_at: When the connector last polled.
        site_id: Site the pairing was claimed for.
        claimed_by_id: Member who claimed it.
        claimed_at: When it was claimed.
        connector_id: Connector created when the token was delivered.
        delivered_at: When the connector received its token; the pairing is spent from then on.
    """

    __tablename__ = "connector_pairings"

    device_code_hash: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    user_code: Mapped[str] = mapped_column(String(8), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    version: Mapped[str | None] = mapped_column(String(40), nullable=True)
    public_key: Mapped[str | None] = mapped_column(String(64), nullable=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    interval: Mapped[int] = mapped_column(Integer, nullable=False, default=5)
    last_polled_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    site_id: Mapped[int | None] = mapped_column(BigInteger, ForeignKey("sites.id", ondelete="CASCADE"), nullable=True)
    claimed_by_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    claimed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    connector_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("connectors.id", ondelete="SET NULL"), nullable=True
    )
    delivered_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
