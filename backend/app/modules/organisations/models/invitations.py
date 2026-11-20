"""Database model of an invitation."""

from datetime import datetime

from sqlalchemy import BigInteger, Boolean, DateTime, ForeignKey, String, true
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["Invitation"]


class Invitation(BaseModel):
    """A single-use invitation to join an organisation with a role, sent by email.

    Attributes:
        organisation_id: Organisation the invitee joins.
        email: Address the invitation was sent to, in lower case.
        role: Role value the invitee receives.
        all_sites: Whether the membership covers every site.
        site_uuids: Sites the membership covers when it does not cover all, as UUID strings.
        token_hash: SHA-256 of the invitation token; the token itself is only in the email.
        expires_at: When the invitation stops working.
        invited_by_id: Member who sent it.
        accepted_at: When it was accepted.
        accepted_by_id: User who accepted it.
        revoked_at: When an admin withdrew it.
    """

    __tablename__ = "invitations"

    organisation_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("organisations.id", ondelete="CASCADE"), nullable=False, index=True
    )
    email: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[str] = mapped_column(String(10), nullable=False)
    all_sites: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True, server_default=true())
    site_uuids: Mapped[list] = mapped_column(JSONB, nullable=False, default=list)
    token_hash: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    invited_by_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    accepted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    accepted_by_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
