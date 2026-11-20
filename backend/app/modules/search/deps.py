"""FastAPI dependencies of the search module."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.modules.people.analytics import AnalyticsClient
from app.modules.people.deps import get_analytics_client
from app.modules.search.services import EventSearchService, FacetService, SimilarService
from app.tenancy.access import SiteAccess
from app.tenancy.dependencies import get_site_access


def get_event_search_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> EventSearchService:
    """Build the event search service for a signed-in user.

    Args:
        session: Database session for the request.
        access: Access of the signed-in member to the request's site.

    Returns:
        Event search service acting for the user.
    """
    return EventSearchService(session, access.user)


def get_facet_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
) -> FacetService:
    """Build the facet service for a signed-in user.

    Args:
        session: Database session for the request.
        access: Access of the signed-in member to the request's site.

    Returns:
        Facet service acting for the user.
    """
    return FacetService(session, access.user)


def get_similar_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
    analytics: AnalyticsClient = Depends(get_analytics_client),
) -> SimilarService:
    """Build the similarity search service for a signed-in user.

    Args:
        session: Database session for the request.
        access: Access of the signed-in member to the request's site.
        analytics: Client of the analytics enrollment endpoint for photo queries.

    Returns:
        Similarity search service acting for the user.
    """
    return SimilarService(session, access.user, analytics)
