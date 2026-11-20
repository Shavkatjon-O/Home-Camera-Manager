"""Routes for the event search, the face similarity search and the filter values."""

from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query

from app.modules.search.deps import get_event_search_service, get_facet_service, get_similar_service
from app.modules.search.schemas import EventFilters, Facets, ResultPage, SimilarPage, SimilarQuery
from app.modules.search.services import EventSearchService, FacetService, SimilarService

router = APIRouter()

PAGE_SIZE_DEFAULT = 50
PAGE_SIZE_MAX = 200


@router.get("/events", response_model=ResultPage)
async def search_events(
    start: datetime | None = Query(None, alias="from"),
    end: datetime | None = Query(None, alias="to"),
    camera: list[UUID] | None = Query(None),
    view: list[str] | None = Query(None),
    kind: list[str] | None = Query(None),
    label: list[str] | None = Query(None),
    zone: list[str] | None = Query(None),
    line: list[str] | None = Query(None),
    person: UUID | None = Query(None),
    cluster: UUID | None = Query(None),
    alert: bool = Query(False),
    page: int = Query(1, ge=1),
    page_size: int = Query(PAGE_SIZE_DEFAULT, ge=1, le=PAGE_SIZE_MAX),
    service: EventSearchService = Depends(get_event_search_service),
) -> ResultPage:
    """Search events, newest first.

    Camera, view, kind, label, zone and line may repeat to keep any of several values.

    Args:
        start: Earliest start time, inclusive.
        end: Latest start time, exclusive.
        camera: Cameras to keep.
        view: Camera views to keep.
        kind: Event kinds to keep.
        label: Object labels to keep.
        zone: Zones to keep.
        line: Lines to keep.
        person: Person whose face events to keep.
        cluster: Unknown cluster whose face events to keep.
        alert: Whether to keep alerting events only.
        page: One-based page number.
        page_size: Number of results per page.
        service: Event search service for the signed-in user.

    Returns:
        One page of results with the total count.
    """
    filters = EventFilters(
        start=start,
        end=end,
        cameras=camera or [],
        kinds=kind or [],
        views=view or [],
        labels=label or [],
        zones=zone or [],
        lines=line or [],
        person=person,
        cluster=cluster,
        alert=alert,
    )
    return await service.search(filters, page, page_size)


@router.post("/similar", response_model=SimilarPage)
async def search_similar(
    payload: SimilarQuery,
    service: SimilarService = Depends(get_similar_service),
) -> SimilarPage:
    """Find the stored faces most similar to a sample, a face event or a photo.

    Args:
        payload: The query and the page.
        service: Similarity search service for the signed-in user.

    Returns:
        One page of similar faces with the total count.
    """
    return await service.similar(payload)


@router.get("/facets", response_model=Facets)
async def get_facets(service: FacetService = Depends(get_facet_service)) -> Facets:
    """Return the values the event search can filter by.

    Args:
        service: Facet service for the signed-in user.

    Returns:
        Kinds, labels, views, zones, lines, people and clusters.
    """
    return await service.facets()
