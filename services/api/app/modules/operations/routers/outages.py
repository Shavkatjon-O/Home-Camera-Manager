"""Outage endpoint."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query

from app.modules.operations.deps import get_outage_service
from app.modules.operations.schemas import OutageList
from app.modules.operations.services import OutageService

router = APIRouter()

PAGE_SIZE_DEFAULT = 20
PAGE_SIZE_MAX = 200


@router.get("/outages", response_model=OutageList)
async def list_outages(
    page: int = Query(1, ge=1),
    page_size: int = Query(PAGE_SIZE_DEFAULT, ge=1, le=PAGE_SIZE_MAX),
    target_uuid: UUID | None = Query(None),
    service: OutageService = Depends(get_outage_service),
) -> OutageList:
    """List outages, newest first.

    Args:
        page: One-based page number.
        page_size: Outages per page.
        target_uuid: Only list outages of this device or camera.
        service: Outage service for the request.

    Returns:
        The requested page of outages.
    """
    return await service.list_page(page, page_size, target_uuid)
