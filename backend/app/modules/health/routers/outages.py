from uuid import UUID

from fastapi import APIRouter, Depends, Query

from app.modules.health.deps import get_outage_service
from app.modules.health.schemas import OutageList
from app.modules.health.services import OutageService

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
    return await service.list_page(page, page_size, target_uuid)
