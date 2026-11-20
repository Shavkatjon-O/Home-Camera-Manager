"""The configuration the analytics service runs on, built from the cameras, views, zones and lines."""

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import AnalyticsLine, AnalyticsView, AnalyticsZone, Camera
from app.modules.analytics.services.settings import load_settings
from app.modules.analytics.services.views import rules_of, sync_views
from app.streaming.names import MAIN, stream_name

__all__ = ["service_config", "view_config"]


def zone_config(zone: AnalyticsZone) -> dict:
    """Return a zone in the analytics service's form.

    Args:
        zone: The zone.

    Returns:
        The zone configuration.
    """
    return {
        "id": str(zone.uuid),
        "name": zone.name,
        "polygon": zone.polygon,
        "labels": zone.labels,
        "min_dwell": zone.min_dwell,
        "loiter_seconds": zone.loiter_seconds,
        "crowd_count": zone.crowd_count,
        "schedule": zone.schedule,
        "alert": zone.alert,
        "enabled": zone.enabled,
        "reference": None if zone.whole_view else zone.reference,
    }


def line_config(line: AnalyticsLine) -> dict:
    """Return a line in the analytics service's form.

    Args:
        line: The line.

    Returns:
        The line configuration.
    """
    return {
        "id": str(line.uuid),
        "name": line.name,
        "points": line.points,
        "labels": line.labels,
        "direction": line.direction,
        "schedule": line.schedule,
        "alert": line.alert,
        "enabled": line.enabled,
        "reference": line.reference,
    }


def view_config(view: AnalyticsView, zones: list[AnalyticsZone], lines: list[AnalyticsLine]) -> dict:
    """Return a view in the analytics service's form.

    References only matter on moving lenses, so fixed views run their zones without them, and the tamper watch is
    off on moving lenses unless set, because a lens that pans looks like a moved camera.

    Args:
        view: The view.
        zones: Its zones.
        lines: Its lines.

    Returns:
        The view configuration.
    """
    data = {
        "id": str(view.uuid),
        "name": view.name,
        "lens": view.lens,
        "profile": view.profile,
        "enabled": view.enabled,
        "fps": view.fps,
        "zones": [zone_config(zone) for zone in zones],
        "lines": [line_config(line) for line in lines],
    }
    if not view.moving:
        for item in data["zones"] + data["lines"]:
            item["reference"] = None
    if view.tamper is not None:
        data["tamper"] = view.tamper
    elif view.moving:
        data["tamper"] = False
    if view.faces is not None:
        data["faces"] = view.faces
    if view.tuning:
        data["tuning"] = view.tuning
    return data


async def service_config(session: AsyncSession) -> dict:
    """Build the analytics service configuration.

    Args:
        session: Database session.

    Returns:
        The arm mode and every enabled camera with its views.
    """
    settings_row = await load_settings(session)
    cameras = list(
        await session.scalars(
            select(Camera).where(Camera.deleted_at.is_(None), Camera.enabled).order_by(Camera.position, Camera.id)
        )
    )
    by_camera = await sync_views(session, cameras)
    await session.commit()
    views = [view for camera in cameras for view in by_camera[camera.uuid]]
    zones, lines = await rules_of(session, [view.id for view in views])
    return {
        "arm_mode": settings_row.arm_mode,
        "cameras": [
            {
                "id": str(camera.uuid),
                "name": camera.name,
                "stream": stream_name(camera.uuid, MAIN),
                "lenses": max(1, camera.lenses),
                "views": [view_config(view, zones[view.id], lines[view.id]) for view in by_camera[camera.uuid]],
            }
            for camera in cameras
        ],
    }
