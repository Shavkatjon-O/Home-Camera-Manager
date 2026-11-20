"""Audit log endpoint of an organisation, for its admins and owners."""

from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query

from app.modules.operations.deps import get_audit_service
from app.modules.operations.schemas.audit import AuditList
from app.modules.operations.services.audit import AuditService

router = APIRouter()


@router.get("/{organisation}/audit", response_model=AuditList)
async def read_organisation_audit(
    organisation: UUID,
    action: str | None = Query(None, max_length=40),
    since: datetime | None = Query(None),
    until: datetime | None = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=200),
    service: AuditService = Depends(get_audit_service),
) -> AuditList:
    """Read who did what in the organisation; admins and owners only.

    Args:
        organisation: Public id of the organisation.
        action: Only this action.
        since: Only records from this time on.
        until: Only records before this time.
        page: Page from 1.
        page_size: Records per page.
        service: Audit service.

    Returns:
        The page, newest first.
    """
    return await service.list(organisation, action, since, until, page, page_size)
