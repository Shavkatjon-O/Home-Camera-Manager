"""HTTP routers of the investigation module."""

from .internal import router as people_internal_router
from .journeys import router as journeys_router
from .people import router as people_router
from .search import router as search_router

__all__ = ["journeys_router", "people_internal_router", "people_router", "search_router"]
