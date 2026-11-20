"""Internal routes the analytics service calls with the shared token; nginx never proxies them."""

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.modules.analytics.deps import get_ingest_service
from app.modules.analytics.schemas import AnalyticsEventIn, ObservationReport
from app.modules.analytics.services import AnalyticsIngestService, service_config
from app.modules.investigation.deps import require_analytics_token

router = APIRouter()


@router.get("/config", dependencies=[Depends(require_analytics_token)])
async def read_config(session: AsyncSession = Depends(get_db)) -> dict:
    """Return the configuration the analytics service runs on.

    Args:
        session: Request-scoped database session.

    Returns:
        The arm mode and every enabled camera with its views, zones and lines.
    """
    return await service_config(session)


@router.post("/events", status_code=status.HTTP_204_NO_CONTENT)
async def ingest_event(
    data: AnalyticsEventIn, service: AnalyticsIngestService = Depends(get_ingest_service)
) -> Response:
    """Store one event change.

    Args:
        data: The event change.
        service: Ingest service.

    Returns:
        Empty response.
    """
    await service.event(data)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/observations", status_code=status.HTTP_204_NO_CONTENT)
async def ingest_observations(
    report: ObservationReport,
    service: AnalyticsIngestService = Depends(get_ingest_service),
) -> Response:
    """Keep the latest observations.

    Args:
        report: The report.
        service: Ingest service.

    Returns:
        Empty response.
    """
    service.observe(report)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
