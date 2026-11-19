"""HTTP routers of the analytics module."""

from fastapi import APIRouter

from .internal import router as analytics_internal_router
from .settings import router as settings_router
from .status import router as status_router
from .views import router as views_router

analytics_router = APIRouter()
analytics_router.include_router(settings_router)
analytics_router.include_router(status_router)
analytics_router.include_router(views_router)

__all__ = ["analytics_internal_router", "analytics_router"]
