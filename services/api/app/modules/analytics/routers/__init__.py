"""HTTP routers of the analytics module."""

from fastapi import APIRouter

from .follow import router as follow_router
from .internal import router as internal_router
from .reports import router as reports_router
from .status import router as status_router
from .views import router as views_router

analytics_router = APIRouter()
analytics_router.include_router(status_router)
analytics_router.include_router(views_router)

analytics_internal_router = APIRouter()
analytics_internal_router.include_router(internal_router)
analytics_internal_router.include_router(reports_router)
analytics_internal_router.include_router(follow_router)

__all__ = ["analytics_internal_router", "analytics_router"]
