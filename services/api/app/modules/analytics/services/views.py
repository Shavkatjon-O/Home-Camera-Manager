"""Analytics views of the cameras, their zones and lines."""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.analytics.observations import observations
from app.auth.context import UserContext
from app.core.base_service import BaseModelService
from app.core.exceptions import Unprocessable
from app.models import AnalyticsLine, AnalyticsView, AnalyticsZone, Camera
from app.modules.analytics.enums import Profile, ViewStream
from app.modules.analytics.schemas import LineRead, RulesUpdate, ViewList, ViewRead, ViewUpdate, ZoneRead

__all__ = ["AnalyticsViewService", "sync_views", "view_lenses"]


def view_lenses(camera: Camera) -> list[int]:
    """Return the lens numbers a camera's views use.

    Args:
        camera: The camera.

    Returns:
        [0] for a single-lens camera, otherwise 1 to the number of lenses.
    """
    return [0] if camera.lenses <= 1 else list(range(1, camera.lenses + 1))


def default_name(camera: Camera, lens: int) -> str:
    """Return the default name of a view.

    Args:
        camera: The camera.
        lens: Lens number.

    Returns:
        The camera name, with the lens for multi-lens cameras.
    """
    return camera.name if lens == 0 else f"{camera.name} Lens {lens}"


def view_stream(view: AnalyticsView, camera: Camera) -> ViewStream:
    """Return the camera stream a view is analysed on.

    A view without a choice reads the main stream, as views did before the choice existed; a choice of the sub
    stream falls back to the main one when the camera has no sub stream or the view reads faces or plates, which
    need the full resolution.

    Args:
        view: The view.
        camera: Its camera.

    Returns:
        The stream.
    """
    needs_detail = view.faces is True or view.plates or (view.faces is None and view.profile == Profile.IDENTITY.value)
    if view.stream == ViewStream.SUB.value and camera.sub_path and not needs_detail:
        return ViewStream.SUB
    return ViewStream.MAIN


async def sync_views(session: AsyncSession, cameras: list[Camera]) -> dict[UUID, list[AnalyticsView]]:
    """Create the missing views of cameras and return each camera's current views.

    New views start disabled with the perimeter profile; the second and later lenses of a PTZ camera are marked
    as moving.

    Args:
        session: Database session.
        cameras: Live cameras.

    Returns:
        Camera id to its views in lens order, without views of lenses the camera no longer has.
    """
    ids = [camera.uuid for camera in cameras]
    rows = (
        list(
            await session.scalars(
                select(AnalyticsView).where(AnalyticsView.camera_uuid.in_(ids), AnalyticsView.deleted_at.is_(None))
            )
        )
        if ids
        else []
    )
    existing = {(row.camera_uuid, row.lens): row for row in rows}
    result: dict[UUID, list[AnalyticsView]] = {}
    created = False
    for camera in cameras:
        views = []
        for lens in view_lenses(camera):
            row = existing.get((camera.uuid, lens))
            if row is None:
                row = AnalyticsView(
                    camera_uuid=camera.uuid,
                    lens=lens,
                    name=default_name(camera, lens),
                    profile=Profile.PERIMETER.value,
                    enabled=False,
                    fps=8.0,
                    moving=lens >= 2 and camera.ptz_enabled,
                    tuning={},
                    stream=ViewStream.SUB.value if camera.connector_id and camera.sub_path else None,
                )
                session.add(row)
                created = True
            views.append(row)
        result[camera.uuid] = views
    if created:
        await session.flush()
    return result


async def rules_of(session: AsyncSession, view_ids: list[int]) -> tuple[dict, dict]:
    """Load the zones and lines of views.

    Args:
        session: Database session.
        view_ids: Internal view ids.

    Returns:
        View id to its zones and view id to its lines, each in position order.
    """
    zones: dict[int, list[AnalyticsZone]] = {view_id: [] for view_id in view_ids}
    lines: dict[int, list[AnalyticsLine]] = {view_id: [] for view_id in view_ids}
    if not view_ids:
        return zones, lines
    for zone in await session.scalars(
        select(AnalyticsZone)
        .where(AnalyticsZone.view_id.in_(view_ids), AnalyticsZone.deleted_at.is_(None))
        .order_by(AnalyticsZone.position, AnalyticsZone.id)
    ):
        zones[zone.view_id].append(zone)
    for line in await session.scalars(
        select(AnalyticsLine)
        .where(AnalyticsLine.view_id.in_(view_ids), AnalyticsLine.deleted_at.is_(None))
        .order_by(AnalyticsLine.position, AnalyticsLine.id)
    ):
        lines[line.view_id].append(line)
    return zones, lines


def view_read(view: AnalyticsView, camera: Camera, zones: list[AnalyticsZone], lines: list[AnalyticsLine]) -> ViewRead:
    """Build the API form of a view with its live status.

    Args:
        view: The view.
        camera: Its camera.
        zones: Its zones.
        lines: Its lines.

    Returns:
        The view.
    """
    status = observations.view(str(view.uuid))
    suspended = set(status.get("suspended") or []) if status else set()
    return ViewRead(
        uuid=view.uuid,
        camera_uuid=view.camera_uuid,
        camera_name=camera.name,
        lens=view.lens,
        lenses=max(1, camera.lenses),
        name=view.name,
        profile=Profile(view.profile),
        enabled=view.enabled,
        fps=view.fps,
        tamper=view.tamper,
        faces=view.faces,
        moving=view.moving,
        appearance=view.appearance,
        falls=view.falls,
        plates=view.plates,
        follow=view.follow,
        stream=view_stream(view, camera),
        zones=[
            ZoneRead(
                uuid=zone.uuid,
                name=zone.name,
                polygon=zone.polygon,
                whole_view=zone.whole_view,
                labels=zone.labels,
                min_dwell=zone.min_dwell,
                loiter_seconds=zone.loiter_seconds,
                crowd_count=zone.crowd_count,
                schedule=zone.schedule,
                alert=zone.alert,
                enabled=zone.enabled,
                reference=zone.reference,
                suspended=str(zone.uuid) in suspended,
                left_seconds=zone.left_seconds,
                taken_seconds=zone.taken_seconds,
                object_labels=zone.object_labels,
                background=zone.background,
                animals=zone.animals,
            )
            for zone in zones
        ],
        lines=[
            LineRead(
                uuid=line.uuid,
                name=line.name,
                points=line.points,
                labels=line.labels,
                direction=line.direction,
                schedule=line.schedule,
                alert=line.alert,
                enabled=line.enabled,
                reference=line.reference,
                suspended=str(line.uuid) in suspended,
                animals=line.animals,
            )
            for line in lines
        ],
        status=status,
    )


class AnalyticsViewService(BaseModelService[AnalyticsView]):
    """Lists and changes analytics views and their rules.

    Attributes:
        model: Analytics views.
        not_found_code: Error code of an unknown view.
    """

    model = AnalyticsView
    not_found_code = "analytics_view_not_found"

    def __init__(self, session: AsyncSession, actor: UserContext | None = None):
        """Bind the service to a session.

        Args:
            session: Database session.
            actor: User making the request.
        """
        super().__init__(session, actor)

    async def cameras(self, camera_uuid: UUID | None = None) -> list[Camera]:
        """Load live cameras in wall order.

        Args:
            camera_uuid: Only this camera.

        Returns:
            The cameras.
        """
        query = select(Camera).where(Camera.deleted_at.is_(None)).order_by(Camera.position, Camera.id)
        if camera_uuid is not None:
            query = query.where(Camera.uuid == camera_uuid)
        return list(await self.session.scalars(query))

    async def list(self, camera_uuid: UUID | None = None) -> ViewList:
        """List views, creating missing ones.

        Args:
            camera_uuid: Only the views of this camera.

        Returns:
            The views in camera and lens order.
        """
        cameras = await self.cameras(camera_uuid)
        by_camera = await sync_views(self.session, cameras)
        await self.session.commit()
        views = [view for camera in cameras for view in by_camera[camera.uuid]]
        zones, lines = await rules_of(self.session, [view.id for view in views])
        names = {camera.uuid: camera for camera in cameras}
        return ViewList(
            items=[view_read(view, names[view.camera_uuid], zones[view.id], lines[view.id]) for view in views]
        )

    async def detail(self, uuid: UUID) -> ViewRead:
        """Return one view.

        Args:
            uuid: View id.

        Returns:
            The view.

        Raises:
            Unprocessable: The view's camera no longer exists.
        """
        view = await self.get(uuid)
        cameras = await self.cameras(view.camera_uuid)
        if not cameras:
            raise Unprocessable("camera_removed", "The camera of this view was removed")
        zones, lines = await rules_of(self.session, [view.id])
        return view_read(view, cameras[0], zones[view.id], lines[view.id])

    async def update(self, uuid: UUID, data: ViewUpdate) -> ViewRead:
        """Change a view.

        Args:
            uuid: View id.
            data: The changes.

        Returns:
            The view after the change.
        """
        view = await self.get(uuid)
        changes = data.model_dump(exclude_unset=True)
        for name in ("name", "enabled", "fps", "moving", "appearance", "falls", "plates", "follow"):
            if name in changes and changes[name] is not None:
                setattr(view, name, changes[name])
        if "profile" in changes and changes["profile"] is not None:
            view.profile = changes["profile"].value
        if "tamper" in changes:
            view.tamper = changes["tamper"]
        if "faces" in changes:
            view.faces = changes["faces"]
        if changes.get("stream") is not None:
            camera = await self.session.scalar(select(Camera).where(Camera.uuid == view.camera_uuid))
            if changes["stream"] == ViewStream.SUB and (camera is None or not camera.sub_path):
                raise Unprocessable("no_sub_stream", "The camera has no sub stream")
            view.stream = changes["stream"].value
        await self.session.commit()
        return await self.detail(uuid)

    async def replace_rules(self, uuid: UUID, data: RulesUpdate) -> ViewRead:
        """Replace every zone and line of a view.

        Zones and lines that come back with their uuid keep it, so their counts and references stay linked.

        Args:
            uuid: View id.
            data: The new zones and lines.

        Returns:
            The view after the change.

        Raises:
            Unprocessable: A zone has too few points.
        """
        view = await self.get(uuid)
        zones, lines = await rules_of(self.session, [view.id])
        for item in zones[view.id] + lines[view.id]:
            await self.session.delete(item)
        await self.session.flush()
        for position, zone in enumerate(data.zones):
            try:
                polygon = zone.full_polygon()
            except ValueError as exc:
                raise Unprocessable("invalid_zone", str(exc))
            row = AnalyticsZone(
                view_id=view.id,
                position=position,
                name=zone.name,
                polygon=polygon,
                whole_view=zone.whole_view,
                labels=zone.labels,
                min_dwell=zone.min_dwell,
                loiter_seconds=zone.loiter_seconds,
                crowd_count=zone.crowd_count,
                schedule=[window.model_dump() for window in zone.schedule],
                alert=zone.alert.model_dump(mode="json"),
                enabled=zone.enabled,
                reference=zone.reference,
                left_seconds=zone.left_seconds,
                taken_seconds=zone.taken_seconds,
                object_labels=zone.object_labels,
                background=zone.background,
                animals=zone.animals.value,
            )
            if zone.uuid is not None:
                row.uuid = zone.uuid
            self.session.add(row)
        for position, line in enumerate(data.lines):
            row = AnalyticsLine(
                view_id=view.id,
                position=position,
                name=line.name,
                points=[[round(x, 4), round(y, 4)] for x, y in line.points],
                labels=line.labels,
                direction=line.direction.value,
                schedule=[window.model_dump() for window in line.schedule],
                alert=line.alert.model_dump(mode="json"),
                enabled=line.enabled,
                reference=line.reference,
                animals=line.animals.value,
            )
            if line.uuid is not None:
                row.uuid = line.uuid
            self.session.add(row)
        await self.session.commit()
        return await self.detail(uuid)
