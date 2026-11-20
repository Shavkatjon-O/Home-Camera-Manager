"""Supervisor that keeps the go2rtc streams in line with the cameras and probes their ports."""

import asyncio
import logging
from collections.abc import Callable
from uuid import UUID

from sqlalchemy import select

from app.core.config import settings
from app.core.database import async_session_maker
from app.core.security import decrypt_secret
from app.models import Camera, Connector
from app.modules.devices.agent import agent_address
from app.streaming.go2rtc import Go2rtcClient, Go2rtcError
from app.streaming.names import MAIN, SUB, belongs_to, camera_streams, is_managed, stream_name
from app.streaming.status import ProbeResult, StatusStore, probe

logger = logging.getLogger(__name__)

PROBE_CONCURRENCY = 32
RETRY_SECONDS = 5.0


def connector_streams(camera: Camera, connector: Connector | None) -> dict[str, list[str]]:
    """Build the go2rtc streams of a camera that central pulls from its connector's go2rtc.

    The connector's go2rtc names the camera's streams as central does, so only the address differs, and that
    address is the same in direct and tunnel mode apart from its value.

    Args:
        camera: Connector camera.
        connector: Its connector, if loaded.

    Returns:
        The sources of each stream, empty while the connector is removed or has no address.
    """
    if connector is None or connector.revoked_at is not None:
        return {}
    address = agent_address(connector)
    if not address:
        return {}
    main = f"/{stream_name(camera.uuid, MAIN)}"
    sub = f"/{stream_name(camera.uuid, SUB)}" if camera.sub_path else None
    return camera_streams(
        camera.uuid,
        address,
        connector.rtsp_port,
        main,
        sub,
        connector.stream_username,
        decrypt_secret(connector.stream_password_encrypted),
    )


def streams_for(camera: Camera, connector: Connector | None = None) -> dict[str, list[str]]:
    """Build the go2rtc streams a camera should have.

    Args:
        camera: Camera to build the streams for.
        connector: The camera's connector, for a connector camera.

    Returns:
        The sources of each stream keyed by stream name, empty for a disabled or deleted camera.
    """
    if not camera.enabled or camera.deleted_at is not None:
        return {}
    if camera.connector_id is not None:
        return connector_streams(camera, connector)
    return camera_streams(
        camera.uuid,
        camera.host,
        camera.rtsp_port,
        camera.main_path,
        camera.sub_path,
        camera.username,
        decrypt_secret(camera.password_encrypted),
    )


class CameraSupervisor:
    """Registers the camera streams in go2rtc and keeps their reachability up to date.

    Attributes:
        go2rtc: Client used to read and change the streams.
        statuses: Store of the latest reachability results.
        interval: Seconds between supervision rounds.
        lock: Lock that serializes changes to the go2rtc streams.
        task: Task running the supervision loop.
        background: Probe tasks started by probe_later.
        connectors: Connectors of the connector cameras, as last loaded.
    """

    def __init__(self, go2rtc: Go2rtcClient, statuses: StatusStore, interval: float):
        """Create the supervisor, not yet running.

        Args:
            go2rtc: Client used to read and change the streams.
            statuses: Store of the latest reachability results.
            interval: Seconds between supervision rounds.
        """
        self.go2rtc = go2rtc
        self.statuses = statuses
        self.interval = interval

        self.lock = asyncio.Lock()
        self.task: asyncio.Task | None = None
        self.background: set[asyncio.Task] = set()
        self.connectors: dict[int, Connector] = {}

    async def start(self) -> None:
        """Start the supervision loop unless it is already running."""
        if self.task is None or self.task.done():
            self.task = asyncio.create_task(self.run(), name="camera-supervisor")

    async def stop(self) -> None:
        """Cancel the supervision loop and the probe tasks and close the go2rtc client."""
        tasks = [task for task in (self.task, *self.background) if task is not None]
        for task in tasks:
            task.cancel()
        await asyncio.gather(*tasks, return_exceptions=True)
        self.task = None
        self.background.clear()
        await self.go2rtc.close()

    async def run(self) -> None:
        """Run supervision rounds forever, retrying sooner after a failed round."""
        while True:
            healthy = await self.tick()
            await asyncio.sleep(self.interval if healthy else min(self.interval, RETRY_SECONDS))

    async def tick(self) -> bool:
        """Run one supervision round.

        The round loads the cameras, reconciles go2rtc and probes every camera.

        Returns:
            False when the cameras could not be loaded or go2rtc could not be reconciled, otherwise True.
        """
        try:
            cameras = await self.load()
        except Exception:
            logger.exception("Loading the cameras failed")
            return False
        self.statuses.retain({camera.uuid for camera in cameras})
        healthy = True
        try:
            await self.reconcile(cameras)
        except Go2rtcError as exc:
            logger.warning("Reconciling go2rtc failed: %s", exc)
            healthy = False
        await self.probe_all(cameras)
        return healthy

    async def load(self) -> list[Camera]:
        """Load the cameras that are not deleted.

        Returns:
            The cameras.
        """
        async with async_session_maker() as session:
            rows = list(await session.scalars(select(Camera).where(Camera.deleted_at.is_(None))))
            ids = {camera.connector_id for camera in rows if camera.connector_id is not None}
            if ids:
                self.connectors = {
                    connector.id: connector
                    for connector in await session.scalars(select(Connector).where(Connector.id.in_(ids)))
                }
            else:
                self.connectors = {}
            return rows

    async def apply(self, desired: dict[str, list[str]], scope: Callable[[str], bool]) -> None:
        """Bring the go2rtc streams in line with the desired ones.

        Streams that are missing or differ are registered. Streams inside the scope that are not wanted are removed;
        streams outside it are left alone.

        Args:
            desired: Wanted sources keyed by stream name.
            scope: Tells whether a stream name is managed by this call.
        """
        async with self.lock:
            current = await self.go2rtc.streams()
            for name, sources in desired.items():
                if current.get(name) != sources:
                    await self.go2rtc.put(name, sources)
                    logger.info("Registered the go2rtc stream %s", name)
            for name in current:
                if scope(name) and name not in desired:
                    await self.go2rtc.delete(name)
                    logger.info("Removed the go2rtc stream %s", name)

    async def reconcile(self, cameras: list[Camera]) -> None:
        """Bring all managed go2rtc streams in line with the given cameras.

        Args:
            cameras: Cameras that should have streams.
        """
        desired = {}
        for camera in cameras:
            desired.update(streams_for(camera, self.connectors.get(camera.connector_id)))
        await self.apply(desired, is_managed)

    async def sync(self, camera: Camera) -> None:
        """Bring the go2rtc streams of one camera in line with its settings, logging a failure.

        Args:
            camera: Camera whose streams to update.
        """
        camera_uuid = camera.uuid
        connector = None
        if camera.connector_id is not None:
            async with async_session_maker() as session:
                connector = await session.get(Connector, camera.connector_id)
        try:
            await self.apply(streams_for(camera, connector), lambda name: belongs_to(name, camera_uuid))
        except Go2rtcError as exc:
            logger.warning("Updating go2rtc for camera %s failed: %s", camera_uuid, exc)

    async def remove(self, camera_uuid: UUID) -> None:
        """Forget a camera and remove its go2rtc streams, logging a failure.

        Args:
            camera_uuid: Camera identifier.
        """
        self.statuses.forget(camera_uuid)
        try:
            await self.apply({}, lambda name: belongs_to(name, camera_uuid))
        except Go2rtcError as exc:
            logger.warning("Removing the go2rtc streams of camera %s failed: %s", camera_uuid, exc)

    async def probe_target(self, camera_uuid: UUID, host: str, port: int) -> ProbeResult:
        """Probe a host and port and store the result for a camera.

        Args:
            camera_uuid: Camera identifier.
            host: Host to probe.
            port: Port to probe.

        Returns:
            The probe result.
        """
        result = await probe(host, port)
        self.statuses.record(camera_uuid, host, port, result)
        return result

    async def probe_camera(self, camera: Camera) -> ProbeResult:
        """Probe the RTSP port of a camera and store the result.

        Args:
            camera: Camera to probe.

        Returns:
            The probe result.
        """
        return await self.probe_target(camera.uuid, camera.host, camera.rtsp_port)

    async def probe_all(self, cameras: list[Camera]) -> None:
        """Probe the RTSP ports of the cameras with a limited number at a time.

        Args:
            cameras: Cameras to probe.
        """
        semaphore = asyncio.Semaphore(PROBE_CONCURRENCY)

        async def limited(camera: Camera) -> None:
            """Probe one camera once a slot is free.

            Args:
                camera: Camera to probe.
            """
            async with semaphore:
                await self.probe_camera(camera)

        await asyncio.gather(*(limited(camera) for camera in cameras if camera.connector_id is None))

    def probe_later(self, camera: Camera) -> None:
        """Start a background probe of a camera.

        Args:
            camera: Camera to probe.
        """
        task = asyncio.create_task(self.probe_target(camera.uuid, camera.host, camera.rtsp_port))
        self.background.add(task)
        task.add_done_callback(self.background.discard)


supervisor = CameraSupervisor(
    Go2rtcClient(settings.go2rtc_url),
    StatusStore(),
    settings.monitor_interval_seconds,
)
