"""Platform administration endpoints, for platform admins only."""

from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query

from app.modules.operations.deps import get_admin_service
from app.modules.operations.schemas.admin import (
    AdminConnectorList,
    AdminOrganisationList,
    AdminOrganisationRead,
    AdminOrganisationUpdate,
    AdminSuspend,
)
from app.modules.operations.schemas.audit import AuditList
from app.modules.operations.services.admin import AdminService

router = APIRouter()


@router.get("/organisations", response_model=AdminOrganisationList)
async def list_all_organisations(
    search: str | None = Query(None, max_length=100),
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=200),
    service: AdminService = Depends(get_admin_service),
) -> AdminOrganisationList:
    """List every organisation with its plan, limits, features and usage.

    Args:
        search: Part of the name or of the owner's address.
        page: Page from 1.
        page_size: Organisations per page.
        service: Admin service.

    Returns:
        The page.
    """
    return await service.organisations(search, page, page_size)


@router.patch("/organisations/{uuid}", response_model=AdminOrganisationRead)
async def update_organisation_plan(
    uuid: UUID, payload: AdminOrganisationUpdate, service: AdminService = Depends(get_admin_service)
) -> AdminOrganisationRead:
    """Change an organisation's plan or its overrides.

    Args:
        uuid: Public id of the organisation.
        payload: The change.
        service: Admin service.

    Returns:
        The organisation.
    """
    return await service.update(uuid, payload)


@router.post("/organisations/{uuid}/suspend", response_model=AdminOrganisationRead)
async def suspend_organisation(
    uuid: UUID, payload: AdminSuspend, service: AdminService = Depends(get_admin_service)
) -> AdminOrganisationRead:
    """Suspend an organisation: its members can no longer use it until it is restored.

    Args:
        uuid: Public id of the organisation.
        payload: The reason.
        service: Admin service.

    Returns:
        The organisation.
    """
    return await service.suspend(uuid, payload.reason)


@router.post("/organisations/{uuid}/restore", response_model=AdminOrganisationRead)
async def restore_organisation(uuid: UUID, service: AdminService = Depends(get_admin_service)) -> AdminOrganisationRead:
    """Restore a suspended organisation.

    Args:
        uuid: Public id of the organisation.
        service: Admin service.

    Returns:
        The organisation.
    """
    return await service.suspend(uuid, None)


@router.get("/connectors", response_model=AdminConnectorList)
async def list_all_connectors(
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=200),
    service: AdminService = Depends(get_admin_service),
) -> AdminConnectorList:
    """List every connector with its organisation, site, last heartbeat and version.

    Args:
        page: Page from 1.
        page_size: Connectors per page.
        service: Admin service.

    Returns:
        The page.
    """
    return await service.connectors(page, page_size)


@router.get("/audit", response_model=AuditList)
async def read_platform_audit(
    organisation: UUID | None = Query(None),
    action: str | None = Query(None, max_length=40),
    since: datetime | None = Query(None),
    until: datetime | None = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=200),
    service: AdminService = Depends(get_admin_service),
) -> AuditList:
    """Read the audit log of every organisation, or of one.

    Args:
        organisation: Only this organisation's records.
        action: Only this action.
        since: Only records from this time on.
        until: Only records before this time.
        page: Page from 1.
        page_size: Records per page.
        service: Admin service.

    Returns:
        The page, newest first.
    """
    return await service.audit(organisation, action, since, until, page, page_size)
