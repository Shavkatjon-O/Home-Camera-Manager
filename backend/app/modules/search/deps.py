"""FastAPI dependencies of the search module."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import UserContext
from app.auth.dependencies import get_current_user
from app.core.database import get_db
from app.modules.people.analytics import AnalyticsClient
from app.modules.people.deps import get_analytics_client
from app.modules.search.services import EventSearchService, FacetService, SimilarService


def get_event_search_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> EventSearchService:
    """Build the event search service for a signed-in user.

    Args:
        session: Database session for the request.
        actor: Signed-in user making the request.

    Returns:
        Event search service acting for the user.
    """
    return EventSearchService(session, actor)


def get_facet_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
) -> FacetService:
    """Build the facet service for a signed-in user.

    Args:
        session: Database session for the request.
        actor: Signed-in user making the request.

    Returns:
        Facet service acting for the user.
    """
    return FacetService(session, actor)


def get_similar_service(
    session: AsyncSession = Depends(get_db),
    actor: UserContext = Depends(get_current_user),
    analytics: AnalyticsClient = Depends(get_analytics_client),
) -> SimilarService:
    """Build the similarity search service for a signed-in user.

    Args:
        session: Database session for the request.
        actor: Signed-in user making the request.
        analytics: Client of the analytics enrollment endpoint for photo queries.

    Returns:
        Similarity search service acting for the user.
    """
    return SimilarService(session, actor, analytics)
