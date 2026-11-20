"""HTTP routers of the media module."""

from .webrtc import router as live_router

__all__ = ["live_router"]
