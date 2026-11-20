"""Dependencies of the billing module: its services and the feature check routes use."""

from collections.abc import Callable

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.core.database import get_db
from app.modules.billing.enums import Feature
from app.modules.billing.services.entitlements import Entitlements, entitlements_for
from app.modules.billing.services.plans import PlanService
from app.modules.identity.deps import get_current_user
from app.modules.tenancy.deps import get_site_access
from app.modules.tenancy.services.access import SiteAccess

__all__ = ["get_entitlements", "get_plan_service", "require_feature"]


def get_plan_service(
    session: AsyncSession = Depends(get_db), actor: UserContext = Depends(get_current_user)
) -> PlanService:
    """Build the plan service for a signed-in request.

    Args:
        session: Request-scoped database session.
        actor: Signed-in user.

    Returns:
        The service.
    """
    return PlanService(session, actor)


async def get_entitlements(
    access: SiteAccess = Depends(get_site_access), session: AsyncSession = Depends(get_db)
) -> Entitlements:
    """Load the entitlements of the organisation of the request's site.

    Args:
        access: Access of the signed-in member to the request's site.
        session: Request-scoped database session.

    Returns:
        The entitlements.
    """
    return await entitlements_for(session, access.organisation_id)


def require_feature(feature: Feature) -> Callable:
    """Build a dependency that refuses requests when a feature is off for the request's organisation.

    Args:
        feature: The feature the route needs.

    Returns:
        The dependency.
    """

    async def dependency(granted: Entitlements = Depends(get_entitlements)) -> Entitlements:
        """Refuse the request when the feature is off.

        Args:
            granted: The organisation's entitlements.

        Returns:
            The entitlements.
        """
        granted.require(feature)
        return granted

    return dependency
