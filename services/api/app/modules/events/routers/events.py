"""Routes of the events: list, counts, details, pictures, clips and the live event stream."""

import asyncio
import json
from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Request
from fastapi.responses import FileResponse, StreamingResponse

from app.camera_events.engine import camera_events
from app.modules.events.deps import get_event_service
from app.modules.events.enums import EventKind, EventSource
from app.modules.events.schemas import EventCounts, EventList, EventRead, EventSourceList
from app.modules.events.services import EventFilters, EventService, site_cameras, stream_hello
from app.modules.tenancy.deps import get_stream_site_access, require_operator, site_scope
from app.modules.tenancy.services.access import SiteAccess

router = APIRouter()

PAGE_SIZE_DEFAULT = 50
PAGE_SIZE_MAX = 200

HEARTBEAT_SECONDS = 15.0
RETRY_MILLISECONDS = 5000

CAMERAS_REFRESH_SECONDS = 30.0

IMAGE_HEADERS = {"Cache-Control": "private, max-age=86400"}
CLIP_HEADERS = {"Cache-Control": "private, max-age=3600"}

JPEG_RESPONSE = {200: {"content": {"image/jpeg": {"schema": {"type": "string", "format": "binary"}}}}}
MP4_RESPONSE = {200: {"content": {"video/mp4": {"schema": {"type": "string", "format": "binary"}}}}}
STREAM_RESPONSE = {200: {"content": {"text/event-stream": {"schema": {"type": "string"}}}}}


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
async def list_event_sources(service: EventService = Depends(get_event_service)) -> EventSourceList:
    """List the state of the event subscription of every camera of the site.

    Args:
        service: Event service.

    Returns:
        The sources.
    """
    return await service.sources()


def message_camera(message: dict) -> str | None:
    """Return the camera a stream message is about.

    Args:
        message: Message with type and data.

    Returns:
        The camera id as text, or None for a message about no camera.
    """
    data = message.get("data") or {}
    value = data.get("camera_uuid")
    return str(value) if value is not None else None


@router.get("/stream", response_class=StreamingResponse, responses=STREAM_RESPONSE)
async def stream_events(request: Request, access: SiteAccess = Depends(get_stream_site_access)) -> StreamingResponse:
    """Stream the event changes and source states of the site's cameras as server-sent events.

    Args:
        request: The request, to notice a disconnect.
        access: Access of the signed-in member to the request's site.

    Returns:
        The streaming response.
    """
    scope = site_scope(access)

    async def body():
        """Send the hello, then every published change of the site, with a ping when the stream is quiet.

        Yields:
            Server-sent event frames until the client disconnects.
        """
        with camera_events.broker.subscribe() as queue:
            cameras = await site_cameras(scope)
            loaded = asyncio.get_running_loop().time()
            yield f"retry: {RETRY_MILLISECONDS}\n\n"
            yield sse("hello", await stream_hello(scope))
            while True:
                try:
                    message = await asyncio.wait_for(queue.get(), HEARTBEAT_SECONDS)
                except TimeoutError:
                    if await request.is_disconnected():
                        return
                    yield ": ping\n\n"
                    continue
                camera = message_camera(message)
                if camera is not None and camera not in cameras:
                    if asyncio.get_running_loop().time() - loaded < CAMERAS_REFRESH_SECONDS:
                        continue
                    cameras = await site_cameras(scope)
                    loaded = asyncio.get_running_loop().time()
                    if camera not in cameras:
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


@router.post("/{uuid}/acknowledge", response_model=EventRead, dependencies=[Depends(require_operator)])
async def acknowledge_event(uuid: UUID, service: EventService = Depends(get_event_service)) -> EventRead:
    """Mark an event's alert as seen; operators, admins and owners only.

    Args:
        uuid: Event id.
        service: Event service.

    Returns:
        The event.
    """
    return await service.acknowledge(uuid)


@router.get("/{uuid}/snapshot", response_class=FileResponse, responses=JPEG_RESPONSE)
async def get_event_snapshot(uuid: UUID, service: EventService = Depends(get_event_service)) -> FileResponse:
    """Return an event's snapshot.

    Args:
        uuid: Event id.
        service: Event service.

    Returns:
        The JPEG.
    """
    return FileResponse(await service.image(uuid, thumbnail=False), media_type="image/jpeg", headers=IMAGE_HEADERS)


@router.get("/{uuid}/thumbnail", response_class=FileResponse, responses=JPEG_RESPONSE)
async def get_event_thumbnail(uuid: UUID, service: EventService = Depends(get_event_service)) -> FileResponse:
    """Return an event's thumbnail.

    Args:
        uuid: Event id.
        service: Event service.

    Returns:
        The JPEG.
    """
    return FileResponse(await service.image(uuid, thumbnail=True), media_type="image/jpeg", headers=IMAGE_HEADERS)


@router.get("/{uuid}/clip", response_class=FileResponse, responses=MP4_RESPONSE)
async def get_event_clip(uuid: UUID, service: EventService = Depends(get_event_service)) -> FileResponse:
    """Return an event's clip; range requests let the browser seek.

    Args:
        uuid: Event id.
        service: Event service.

    Returns:
        The MP4.
    """
    return FileResponse(await service.clip(uuid), media_type="video/mp4", headers=CLIP_HEADERS)
