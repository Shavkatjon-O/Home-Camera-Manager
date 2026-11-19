from fastapi import APIRouter, Depends, Request

from app.modules.tv.deps import get_tv_config_service
from app.modules.tv.schemas import TvConfig
from app.modules.tv.services import TvConfigService

router = APIRouter()


@router.get("/config", response_model=TvConfig)
async def tv_config(request: Request, service: TvConfigService = Depends(get_tv_config_service)) -> TvConfig:
    return await service.config(request.url.hostname or "")
