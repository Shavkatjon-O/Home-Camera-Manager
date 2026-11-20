"""FastAPI dependencies of the people module."""

import hmac

from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.camera_events.engine import camera_events
from app.core.config import settings
from app.core.database import get_db
from app.core.exceptions import Unauthorized
from app.modules.people.analytics import AnalyticsClient
from app.modules.people.crops import CropStore
from app.modules.people.services import (
    ClusterService,
    FaceResultService,
    GalleryService,
    PersonService,
    SampleService,
)
from app.tenancy.access import SiteAccess
from app.tenancy.dependencies import get_site_access

analytics_bearer = HTTPBearer(auto_error=False)


def check_analytics_token(sent: str | None, expected: str | None) -> None:
    """Check the bearer token of an internal request in constant time.

    Args:
        sent: Token the request carried, if any.
        expected: Token the backend is configured with; an empty one refuses every request.

    Raises:
        Unauthorized: When no token is configured, none was sent or the two differ.
    """
    if not expected or not sent or not hmac.compare_digest(sent.encode("utf-8"), expected.encode("utf-8")):
        raise Unauthorized("invalid_analytics_token", "The analytics token is missing or wrong")


async def require_analytics_token(
    credentials: HTTPAuthorizationCredentials | None = Depends(analytics_bearer),
) -> None:
    """Require the analytics service's bearer token on an internal request.

    Args:
        credentials: Bearer credentials of the request, if sent.
    """
    check_analytics_token(credentials.credentials if credentials is not None else None, settings.analytics_token)


def get_crop_store() -> CropStore:
    """Build the storage of face crops under the events folder.

    Returns:
        Crop storage rooted at the configured events folder.
    """
    return CropStore(settings.events_dir)


def get_analytics_client() -> AnalyticsClient:
    """Build the client of the analytics enrollment endpoint from the settings.

    Returns:
        Client for the configured analytics address and token.
    """
    return AnalyticsClient(settings.analytics_url, settings.analytics_token)


def get_person_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
    store: CropStore = Depends(get_crop_store),
    analytics: AnalyticsClient = Depends(get_analytics_client),
) -> PersonService:
    """Build the person service for a signed-in user.

    Args:
        session: Database session for the request.
        access: Access of the signed-in member to the request's site.
        store: Storage of face crops.
        analytics: Client of the analytics enrollment endpoint.

    Returns:
        Person service acting for the user.
    """
    return PersonService(session, access.user, store, analytics)


def get_cluster_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
    store: CropStore = Depends(get_crop_store),
) -> ClusterService:
    """Build the unknown cluster service for a signed-in user.

    Args:
        session: Database session for the request.
        access: Access of the signed-in member to the request's site.
        store: Storage of face crops.

    Returns:
        Cluster service acting for the user.
    """
    return ClusterService(session, access.user, store)


def get_sample_service(
    session: AsyncSession = Depends(get_db),
    access: SiteAccess = Depends(get_site_access),
    store: CropStore = Depends(get_crop_store),
) -> SampleService:
    """Build the face sample service for a signed-in user.

    Args:
        session: Database session for the request.
        access: Access of the signed-in member to the request's site.
        store: Storage of face crops.

    Returns:
        Sample service acting for the user.
    """
    return SampleService(session, access.user, store)


def get_face_result_service(session: AsyncSession = Depends(get_db)) -> FaceResultService:
    """Build the face result service for the analytics service, announcing its events on the event stream.

    Args:
        session: Database session for the request.

    Returns:
        Face result service.
    """
    return FaceResultService(session, camera_events.broker.publish)


def get_gallery_service(session: AsyncSession = Depends(get_db)) -> GalleryService:
    """Build the gallery service for the analytics service.

    Args:
        session: Database session for the request.

    Returns:
        Gallery service.
    """
    return GalleryService(session)
