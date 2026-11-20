"""Route that serves a paired TV its configuration."""

from fastapi import APIRouter, Depends, Request

from app.modules.tv.deps import get_tv_config_service
from app.modules.tv.schemas import TvConfig
from app.modules.tv.services import TvConfigService

router = APIRouter()


@router.get("/config", response_model=TvConfig)
async def tv_config(request: Request, service: TvConfigService = Depends(get_tv_config_service)) -> TvConfig:
    """Return the wall and tile streams for the requesting TV.

    Args:
        request: Incoming request; its host name is used when no LAN bind address is configured.
        service: Config service for the requesting device.

    Returns:
        Stream URLs of the wall and of every tile.
    """
    return await service.config(request.url.hostname or "")
