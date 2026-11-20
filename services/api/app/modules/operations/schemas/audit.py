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
