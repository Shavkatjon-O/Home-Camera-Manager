"""Schemas of the audit log."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

__all__ = ["AuditList", "AuditRead"]


class AuditRead(BaseModel):
    """One audit record.

    Attributes:
        uuid: Public id.
        at: When it happened.
        action: What was done.
        actor: Sign-in name of who did it, if known.
        actor_name: Display name of the acting account, if it still exists and has one.
        actor_email: Email address of the acting account, if it still exists and has one.
        organisation: Organisation concerned, if any.
        site: Site concerned, if any.
        target_kind: Kind of the thing acted on.
        target_uuid: Public id of the thing acted on.
        details: Further facts.
        ip: Address of the request.
    """

    uuid: UUID
    at: datetime
    action: str
    actor: str | None
    actor_name: str | None = None
    actor_email: str | None = None
    organisation: UUID | None
    site: UUID | None
    target_kind: str | None
    target_uuid: UUID | None
    details: dict
    ip: str | None


class AuditList(BaseModel):
    """A page of audit records, newest first.

    Attributes:
        items: The records.
        total: Records matching the filters.
        page: Page from 1.
        page_size: Records per page.
    """

    items: list[AuditRead]
    total: int
    page: int
    page_size: int
