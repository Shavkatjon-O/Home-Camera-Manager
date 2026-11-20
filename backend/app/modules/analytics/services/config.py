"""The configuration the analytics service runs on, built from the cameras, views, zones and lines."""

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import AnalyticsLine, AnalyticsSettings, AnalyticsView, AnalyticsZone, Camera, Organisation, Site
from app.modules.analytics.enums import ArmMode, ViewStream
from app.modules.analytics.services.views import rules_of, sync_views, view_stream
from app.streaming.names import MAIN, SUB, stream_name

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
        "left_seconds": zone.left_seconds,
        "taken_seconds": zone.taken_seconds,
        "object_labels": zone.object_labels,
        "background": zone.background,
        "animals": zone.animals,
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
        "animals": line.animals,
    }


def view_config(
    view: AnalyticsView,
    zones: list[AnalyticsZone],
    lines: list[AnalyticsLine],
    owner: dict | None = None,
    stream: ViewStream = ViewStream.MAIN,
    faces_allowed: bool = True,
) -> dict:
    """Return a view in the analytics service's form.

    References only matter on moving lenses, so fixed views run their zones without them. The tamper guard runs on
    moving lenses too and never reports them moved, because a lens that pans changes its scene on purpose.

    Args:
        view: The view.
        zones: Its zones.
        lines: Its lines.
        owner: Site and organisation ids of the view, as text.
        stream: Camera stream the view is analysed on.
        faces_allowed: Whether the view's organisation has face recognition on; faces stay off when it has not.

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
        "moving": view.moving,
        "appearance": view.appearance,
        "falls": {"enabled": view.falls},
        "plates": {"enabled": view.plates},
        "follow": {"enabled": view.follow},
        "zones": [zone_config(zone) for zone in zones],
        "lines": [line_config(line) for line in lines],
        "stream": stream.value,
        **(owner or {}),
    }
    if not view.moving:
        for item in data["zones"] + data["lines"]:
            item["reference"] = None
    if view.tamper is not None:
        data["tamper"] = view.tamper
    if not faces_allowed:
        data["faces"] = False
    elif view.faces is not None:
        data["faces"] = view.faces
    if view.tuning:
        data["tuning"] = view.tuning
    return data


def camera_stream(camera: Camera, streams: list[ViewStream]) -> str:
    """Choose the go2rtc stream the analytics service decodes for a camera, once for all its views.

    Args:
        camera: The camera.
        streams: Streams its enabled views are analysed on.

    Returns:
        The sub stream when the camera has one and every enabled view reads it, otherwise the main stream.
    """
    if camera.sub_path and streams and all(stream == ViewStream.SUB for stream in streams):
        return stream_name(camera.uuid, SUB)
    return stream_name(camera.uuid, MAIN)


async def site_context(session: AsyncSession, cameras: list[Camera]) -> tuple[dict, dict, dict]:
    """Load the sites, organisations and arm modes the cameras belong to.

    Args:
        session: Database session.
        cameras: The cameras.

    Returns:
        Sites by id, organisations by id and arm modes by site id.
    """
    site_ids = {camera.site_id for camera in cameras if camera.site_id is not None}
    organisation_ids = {camera.organisation_id for camera in cameras if camera.organisation_id is not None}
    sites = {row.id: row for row in await session.scalars(select(Site).where(Site.id.in_(site_ids)))}
    organisations = {
        row.id: row for row in await session.scalars(select(Organisation).where(Organisation.id.in_(organisation_ids)))
    }
    modes = dict((await session.execute(select(AnalyticsSettings.site_id, AnalyticsSettings.arm_mode))).all())
    return sites, organisations, modes


async def service_config(session: AsyncSession) -> dict:
    """Build the analytics service configuration.

    Every camera carries its site and organisation with the site's arm mode and time zone, and every view its site,
    organisation and stream. The top-level arm mode is that of the oldest site, for an analytics service that does
    not read the arm mode of each camera yet.

    Args:
        session: Database session.

    Returns:
        The arm mode and every enabled camera with its views.
    """
    cameras = list(
        await session.scalars(
            select(Camera)
            .join(Site, Site.id == Camera.site_id)
            .where(Camera.deleted_at.is_(None), Camera.enabled, Site.deleted_at.is_(None))
            .order_by(Camera.site_id, Camera.position, Camera.id)
        )
    )
    by_camera = await sync_views(session, cameras)
    await session.commit()
    views = [view for camera in cameras for view in by_camera[camera.uuid]]
    zones, lines = await rules_of(session, [view.id for view in views])
    sites, organisations, modes = await site_context(session, cameras)
    first_site = min(sites) if sites else None
    entries = []
    for camera in cameras:
        site = sites.get(camera.site_id)
        organisation = organisations.get(camera.organisation_id)
        owner = {
            "site": str(site.uuid) if site else None,
            "organisation": str(organisation.uuid) if organisation else None,
        }
        streams = {view.id: view_stream(view, camera) for view in by_camera[camera.uuid]}
        faces_allowed = bool(organisation and organisation.faces_enabled)
        entries.append(
            {
                "id": str(camera.uuid),
                "name": camera.name,
                "stream": camera_stream(camera, [streams[view.id] for view in by_camera[camera.uuid] if view.enabled]),
                "lenses": max(1, camera.lenses),
                **owner,
                "arm_mode": modes.get(camera.site_id, ArmMode.DISARMED.value),
                "timezone": site.timezone if site else None,
                "views": [
                    view_config(view, zones[view.id], lines[view.id], owner, streams[view.id], faces_allowed)
                    for view in by_camera[camera.uuid]
                ],
            }
        )
    return {
        "arm_mode": modes.get(first_site, ArmMode.DISARMED.value) if first_site is not None else ArmMode.DISARMED.value,
        "cameras": entries,
    }
