"""HTTP routers of the tenancy module."""

from .invitations import router as invitations_router
from .members import router as members_router
from .organisations import router as organisations_router
from .sites import router as sites_router

__all__ = ["invitations_router", "members_router", "organisations_router", "sites_router"]
