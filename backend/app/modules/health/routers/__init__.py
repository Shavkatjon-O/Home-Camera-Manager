from fastapi import APIRouter

from .devices import router as devices_router
from .links import router as links_router
from .outages import router as outages_router
from .overview import router as overview_router

health_router = APIRouter()
health_router.include_router(overview_router)
health_router.include_router(outages_router)
health_router.include_router(devices_router, prefix="/devices")
health_router.include_router(links_router, prefix="/camera-links")

__all__ = ["health_router"]
