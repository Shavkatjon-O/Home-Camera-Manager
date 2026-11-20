"""Routers of the people module."""

from .internal import router as people_internal_router
from .people import router as people_router

__all__ = ["people_internal_router", "people_router"]
