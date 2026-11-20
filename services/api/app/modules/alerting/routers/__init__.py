"""HTTP routers of the alerting module."""

from .settings import router as arm_router
from .targets import router as push_router

__all__ = ["arm_router", "push_router"]
