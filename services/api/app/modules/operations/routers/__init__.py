"""Routers of the operations module combined under one router."""

from fastapi import APIRouter

from .admin import router as admin_router
from .audit import router as audit_router
from .devices import router as devices_router
from .floorplans import router as floorplans_router
from .links import router as links_router
from .outages import router as outages_router
from .overview import router as overview_router

health_router = APIRouter()
health_router.include_router(overview_router)
health_router.include_router(outages_router)
health_router.include_router(devices_router, prefix="/devices")
health_router.include_router(links_router, prefix="/camera-links")

__all__ = ["admin_router", "audit_router", "floorplans_router", "health_router"]
