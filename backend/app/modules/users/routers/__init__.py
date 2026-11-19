"""HTTP routers of the users module."""

from .auth import router as auth_router

__all__ = ["auth_router"]
