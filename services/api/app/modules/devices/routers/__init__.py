"""HTTP routers of the camera registry module."""

from .cameras import router as cameras_router

__all__ = ["cameras_router"]
