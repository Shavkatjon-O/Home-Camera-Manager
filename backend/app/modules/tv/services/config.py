"""Service that builds the wall configuration and ffmpeg arguments for TV streams."""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.context import TvDeviceContext
from app.core.config import settings
from app.core.exceptions import NotFound
from app.models import Camera
from app.modules.tv.schemas import TvConfig, TvTile, TvWall
from app.streaming.liveness import TvLiveness, tv_liveness
from app.streaming.tv import TV_TILE_LIMIT, TV_WALL, stream_command, stream_sources, tile_name, tv_url
from app.streaming.wall import WallCell, WallPlan, wall_plan

__all__ = ["TvConfigService", "build_config", "tile_label"]


def tile_label(cell: WallCell) -> str:
    """Build the text shown for a wall cell.

    Args:
        cell: Wall cell to label.

    Returns:
        Camera name, followed by the one-based lens number for a multi-lens camera.
    """
    camera = cell.item.camera
    if cell.item.lens is None:
        return camera.name
    return f"{camera.name}, lens {cell.item.lens + 1}"


def build_config(plan: WallPlan, host: str, username: str, password: str) -> TvConfig:
    """Build the TV configuration for a wall plan.

    Args:
        plan: Layout of the wall.
        host: Host name or address the TV reaches the stream server on.
        username: RTSP user name placed in the stream URLs.
        password: RTSP password placed in the stream URLs; empty for none.

    Returns:
        Wall and tile streams, limited to the tiles a TV can play.
    """
    tiles = [
        TvTile(
            index=cell.index,
            label=tile_label(cell),
            camera_uuid=cell.item.camera.uuid,
            camera_name=cell.item.camera.name,
            lens=cell.item.lens,
            ptz=cell.item.camera.ptz_enabled,
            url=tv_url(tile_name(cell.index), host, username, password),
        )
        for cell in plan.cells
        if cell.index < TV_TILE_LIMIT
    ]
    wall_url = tv_url(TV_WALL, host, username, password) if plan.cells else ""
    return TvConfig(wall=TvWall(url=wall_url, cols=plan.cols, rows=plan.rows), tiles=tiles)


class TvConfigService:
    """Plan the camera wall and serve the TV configuration and stream commands.

    Attributes:
        session: Database session the service works in.
        device: Paired TV making the request, if any.
        liveness: Tracker of which camera streams are flowing.
    """

    def __init__(
        self,
        session: AsyncSession,
        device: TvDeviceContext | None = None,
        liveness: TvLiveness = tv_liveness,
    ):
        """Bind the service to a session, the requesting TV and a liveness tracker.

        Args:
            session: Database session the service works in.
            device: Paired TV making the request, if any.
            liveness: Tracker of which camera streams are flowing.
        """
        self.session = session
        self.device = device
        self.liveness = liveness

    async def plan(self) -> WallPlan:
        """Plan the wall from the enabled cameras.

        Returns:
            Wall layout of the cameras that are not deleted, in display order.
        """
        rows = await self.session.scalars(
            select(Camera)
            .where(Camera.deleted_at.is_(None), Camera.enabled.is_(True))
            .order_by(Camera.position.asc(), Camera.created_at.desc(), Camera.id.desc())
        )
        return wall_plan(rows)

    async def config(self, request_host: str) -> TvConfig:
        """Build the configuration a TV reads.

        Args:
            request_host: Host name the request arrived on, used when no LAN bind address is configured.

        Returns:
            Wall and tile streams with the configured RTSP credentials.
        """
        host = settings.lan_bind or request_host
        return build_config(await self.plan(), host, settings.tv_rtsp_username, settings.tv_rtsp_password)

    def known_offline(self, plan: WallPlan) -> set[UUID]:
        """Find the cameras that the status store already reports as offline.

        Args:
            plan: Wall layout whose cameras are checked.

        Returns:
            Public ids of the cameras whose status is known to be offline.
        """
        statuses = self.liveness.statuses
        return {
            cell.item.camera.uuid
            for cell in plan.cells
            if statuses.get(cell.item.camera.uuid, cell.item.camera.host, cell.item.camera.rtsp_port).online is False
        }

    async def stream_args(self, name: str, poll: bool = False) -> str:
        """Build the ffmpeg arguments of a TV stream, leaving out cameras that are offline.

        Args:
            name: Name of the TV stream, the wall or a tile.
            poll: Whether the caller is a repeated poll, which also checks that the camera streams issued earlier
                are still read.

        Returns:
            The arguments, one per line, ending with a newline.

        Raises:
            NotFound: When the stream shows no camera.
        """
        plan = await self.plan()
        sources = stream_sources(plan, name)
        if sources is None:
            raise NotFound("tv_stream_not_found", f"The TV stream {name} shows no camera")
        if poll:
            await self.liveness.watch(name)
        offline = await self.liveness.offline(sources, self.known_offline(plan), fresh=not poll)
        command = stream_command(plan, name, offline)
        self.liveness.remember(name, command, poll)
        return "\n".join(command.args) + "\n"

    def report_failure(self, name: str, stream: str) -> None:
        """Record that a camera stream of a TV stream failed to open.

        Args:
            name: Name of the TV stream.
            stream: Name of the camera stream that failed.
        """
        self.liveness.fail(name, stream)
