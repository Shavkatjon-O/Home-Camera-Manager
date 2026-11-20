"""HTTP routers of the alerting module."""

from .settings import router as arm_router
from .targets import router as push_router
from .telegram import router as telegram_router
from .telegram import webhook_router as telegram_webhook_router

__all__ = ["arm_router", "push_router", "telegram_router", "telegram_webhook_router"]
