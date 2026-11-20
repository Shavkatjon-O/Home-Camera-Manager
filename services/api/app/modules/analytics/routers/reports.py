"""Internal routes for the analytics service's count and journey reports; nginx never proxies them."""

from fastapi import APIRouter, Depends, Response, status

from app.modules.insights.deps import get_count_ingest_service
from app.modules.insights.schemas.counts import CountReportIn
from app.modules.insights.services.counts import CountService
from app.modules.investigation.deps import get_journey_ingest_service
from app.modules.investigation.schemas.journeys import JourneyReportIn
from app.modules.investigation.services.journeys import JourneyService

router = APIRouter()


@router.post("/counts", status_code=status.HTTP_204_NO_CONTENT)
async def ingest_counts(report: CountReportIn, service: CountService = Depends(get_count_ingest_service)) -> Response:
    """Store the minute counts of a report.

    Args:
        report: The report.
        service: Count service.

    Returns:
        Empty response.
    """
    await service.ingest(report)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/journeys", status_code=status.HTTP_204_NO_CONTENT)
async def ingest_journeys(
    report: JourneyReportIn, service: JourneyService = Depends(get_journey_ingest_service)
) -> Response:
    """Store finished appearances and changed journeys.

    Args:
        report: The report.
        service: Journey service.

    Returns:
        Empty response.
    """
    await service.ingest(report)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
