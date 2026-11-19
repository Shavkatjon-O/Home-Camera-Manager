"""Routers of the TV module."""

from fastapi import APIRouter

from .config import router as config_router
from .devices import router as devices_router
from .pairings import router as pairings_router
from .ptz import router as ptz_router
from .streams import router as tv_internal_router

tv_router = APIRouter()
tv_router.include_router(pairings_router)
tv_router.include_router(devices_router)
tv_router.include_router(config_router)
tv_router.include_router(ptz_router)

__all__ = ["tv_internal_router", "tv_router"]
