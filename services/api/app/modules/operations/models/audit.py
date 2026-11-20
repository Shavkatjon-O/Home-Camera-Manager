"""Database model of an audit record."""

from uuid import UUID

from sqlalchemy import BigInteger, ForeignKey, String, Uuid, text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["AuditRecord"]


class AuditRecord(BaseModel):
    """An append-only record of who did what, where and when.

    Records are only ever added; the retention job is the one place that deletes them. The organisation and site
    are plain columns rather than tenancy ownership, because platform records belong to no organisation.

    Attributes:
        organisation_id: Organisation the action concerned, None for account and platform actions.
        site_id: Site the action concerned, if any.
        actor_id: User who acted, None when the account no longer exists or a system job acted.
        actor: Sign-in name of the actor when it acted, kept after the account is gone.
        action: What was done, an AuditAction value.
        target_kind: Kind of the thing acted on, such as camera or member.
        target_uuid: Public id of the thing acted on, if it has one.
        details: Further facts, such as the HTTP method and path, without secrets.
        ip: Address the request came from.
    """

    __tablename__ = "audit_records"

    organisation_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("organisations.id", ondelete="SET NULL"), nullable=True, index=True
    )
    site_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("sites.id", ondelete="SET NULL"), nullable=True, index=True
    )
    actor_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True
    )
    actor: Mapped[str | None] = mapped_column(String(255), nullable=True)
    action: Mapped[str] = mapped_column(String(40), nullable=False, index=True)
    target_kind: Mapped[str | None] = mapped_column(String(30), nullable=True)
    target_uuid: Mapped[UUID | None] = mapped_column(Uuid(as_uuid=True), nullable=True)
    details: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict, server_default=text("'{}'::jsonb"))
    ip: Mapped[str | None] = mapped_column(String(45), nullable=True)
