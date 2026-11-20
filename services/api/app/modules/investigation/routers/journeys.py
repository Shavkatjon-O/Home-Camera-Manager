"""Routes of person journeys across cameras and of finding a person by appearance."""

from datetime import UTC, datetime, timedelta
from uuid import UUID

from fastapi import APIRouter, Depends, Query

from app.modules.billing.deps import require_feature
from app.modules.billing.enums import Feature
from app.modules.investigation.deps import get_journey_service
from app.modules.investigation.schemas.journeys import (
    JourneyList,
    JourneyRead,
    SimilarAppearanceQuery,
    SimilarAppearances,
)
from app.modules.investigation.services.journeys import JourneyService

router = APIRouter()


@router.get("/journeys", response_model=JourneyList, dependencies=[Depends(require_feature(Feature.JOURNEYS))])
async def list_journeys(
    start: datetime | None = None,
    end: datetime | None = None,
    limit: int = Query(100, ge=1, le=500),
    service: JourneyService = Depends(get_journey_service),
) -> JourneyList:
    """List the journeys that started in a range, by default the last day.

    Args:
        start: Start of the range.
        end: End of the range.
        limit: Most journeys returned.
        service: Journey service.

    Returns:
        The journeys, newest first.
    """
    end = end or datetime.now(UTC)
    return await service.journeys(start or end - timedelta(days=1), end, limit)


@router.get(
    "/journeys/event/{uuid}", response_model=JourneyRead, dependencies=[Depends(require_feature(Feature.JOURNEYS))]
)
async def read_event_journey(uuid: UUID, service: JourneyService = Depends(get_journey_service)) -> JourneyRead:
    """Return the journey of an event's person.

    Args:
        uuid: Event id.
        service: Journey service.

    Returns:
        The journey.
    """
    return await service.journey_of_event(uuid)


@router.post(
    "/appearances/similar",
    response_model=SimilarAppearances,
    dependencies=[Depends(require_feature(Feature.APPEARANCE_SEARCH))],
)
async def find_person(
    query: SimilarAppearanceQuery, service: JourneyService = Depends(get_journey_service)
) -> SimilarAppearances:
    """Find the tracks on every camera that look like an event's person.

    Args:
        query: What to search for and where.
        service: Journey service.

    Returns:
        The matches, most similar first.
    """
    return await service.similar(query)
