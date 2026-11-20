"""Routes of the events: list, counts, details, pictures, clips and the live event stream."""

import asyncio
import json
from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Request
from fastapi.responses import FileResponse, StreamingResponse

from app.auth.context import UserContext
from app.auth.dependencies import get_stream_user
from app.camera_events.engine import camera_events
from app.modules.events.deps import get_event_service
from app.modules.events.enums import EventKind, EventSource
from app.modules.events.schemas import EventCounts, EventList, EventRead, EventSourceList
from app.modules.events.services import EventFilters, EventService, stream_hello

router = APIRouter()

PAGE_SIZE_DEFAULT = 50
PAGE_SIZE_MAX = 200

HEARTBEAT_SECONDS = 15.0
RETRY_MILLISECONDS = 5000

IMAGE_HEADERS = {"Cache-Control": "private, max-age=86400"}
CLIP_HEADERS = {"Cache-Control": "private, max-age=3600"}


def sse(kind: str, payload: dict) -> str:
    """Format one server-sent event.

    Args:
        kind: Event name.
        payload: JSON data.

    Returns:
        The event text.
    """
    return f"event: {kind}\ndata: {json.dumps(payload, separators=(',', ':'))}\n\n"


def event_filters(
    camera_uuid: UUID | None = Query(None),
    kind: EventKind | None = Query(None),
    label: str | None = Query(None, max_length=20),
    source: EventSource | None = Query(None),
    start: datetime | None = Query(None, alias="from"),
    end: datetime | None = Query(None, alias="to"),
    plate: str | None = Query(None, max_length=20),
) -> EventFilters:
    """Read the event filters from the query string.

    Args:
        camera_uuid: Only this camera.
        kind: Only this kind.
        label: Only this label.
        source: Only this source.
        start: Only events that started at or after this time.
        end: Only events that started before this time.
        plate: Only vehicle events whose number plate candidates contain this text.

    Returns:
        The filters.
    """
    return EventFilters(camera_uuid, kind, label, source, start, end, plate)


@router.get("", response_model=EventList)
async def list_events(
    page: int = Query(1, ge=1),
    page_size: int = Query(PAGE_SIZE_DEFAULT, ge=1, le=PAGE_SIZE_MAX),
    filters: EventFilters = Depends(event_filters),
    service: EventService = Depends(get_event_service),
) -> EventList:
    """List events newest first.

    Args:
        page: Page number from 1.
        page_size: Events per page.
        filters: The filters.
        service: Event service.

    Returns:
        One page of events.
    """
    return await service.list_page(page, page_size, filters)


@router.get("/counts", response_model=EventCounts)
async def count_events(
    filters: EventFilters = Depends(event_filters),
    service: EventService = Depends(get_event_service),
) -> EventCounts:
    """Count events per kind and label.

    Args:
        filters: The filters.
        service: Event service.

    Returns:
        The counts.
    """
    return await service.counts(filters)


@router.get("/sources", response_model=EventSourceList)
async def list_sources(service: EventService = Depends(get_event_service)) -> EventSourceList:
    """List the state of every camera's event subscription.

    Args:
        service: Event service.

    Returns:
        The sources.
    """
    return service.sources()


@router.get("/stream")
async def stream_events(request: Request, user: UserContext = Depends(get_stream_user)) -> StreamingResponse:
    """Stream event changes and source states as server-sent events.

    Args:
        request: The request, to notice a disconnect.
        user: Signed-in user.

    Returns:
        The streaming response.
    """

    async def body():
        """Send the hello, then every published change, with a ping when the stream is quiet.

        Yields:
            Server-sent event frames until the client disconnects.
        """
        with camera_events.broker.subscribe() as queue:
            yield f"retry: {RETRY_MILLISECONDS}\n\n"
            yield sse("hello", await stream_hello())
            while True:
                try:
                    message = await asyncio.wait_for(queue.get(), HEARTBEAT_SECONDS)
                except TimeoutError:
                    if await request.is_disconnected():
                        return
                    yield ": ping\n\n"
                    continue
                yield sse(message["type"], message["data"])

    return StreamingResponse(
        body(),
        media_type="text/event-stream",
        headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"},
    )


@router.get("/{uuid}", response_model=EventRead)
async def get_event(uuid: UUID, service: EventService = Depends(get_event_service)) -> EventRead:
    """Return one event.

    Args:
        uuid: Event id.
        service: Event service.

    Returns:
        The event.
    """
    return await service.detail(uuid)


@router.get("/{uuid}/snapshot")
async def get_snapshot(uuid: UUID, service: EventService = Depends(get_event_service)) -> FileResponse:
    """Return an event's snapshot.

    Args:
        uuid: Event id.
        service: Event service.

    Returns:
        The JPEG.
    """
    return FileResponse(await service.image(uuid, thumbnail=False), media_type="image/jpeg", headers=IMAGE_HEADERS)


@router.get("/{uuid}/thumbnail")
async def get_thumbnail(uuid: UUID, service: EventService = Depends(get_event_service)) -> FileResponse:
    """Return an event's thumbnail.

    Args:
        uuid: Event id.
        service: Event service.

    Returns:
        The JPEG.
    """
    return FileResponse(await service.image(uuid, thumbnail=True), media_type="image/jpeg", headers=IMAGE_HEADERS)


@router.get("/{uuid}/clip")
async def get_clip(uuid: UUID, service: EventService = Depends(get_event_service)) -> FileResponse:
    """Return an event's clip; range requests let the browser seek.

    Args:
        uuid: Event id.
        service: Event service.

    Returns:
        The MP4.
    """
    return FileResponse(await service.clip(uuid), media_type="video/mp4", headers=CLIP_HEADERS)
