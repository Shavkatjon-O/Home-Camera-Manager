import asyncio
import logging
from collections.abc import Callable
from uuid import UUID

from sqlalchemy import select

from app.core.config import settings
from app.core.database import async_session_maker
from app.core.security import decrypt_secret
from app.models import Camera
from app.streaming.go2rtc import Go2rtcClient, Go2rtcError
from app.streaming.names import belongs_to, camera_streams, is_managed
from app.streaming.status import ProbeResult, StatusStore, probe

logger = logging.getLogger(__name__)

PROBE_CONCURRENCY = 32
RETRY_SECONDS = 5.0


def streams_for(camera: Camera) -> dict[str, list[str]]:
    if not camera.enabled or camera.deleted_at is not None:
        return {}
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
    def __init__(self, go2rtc: Go2rtcClient, statuses: StatusStore, interval: float):
        self.go2rtc = go2rtc
        self.statuses = statuses
        self.interval = interval

        self.lock = asyncio.Lock()
        self.task: asyncio.Task | None = None
        self.background: set[asyncio.Task] = set()

    async def start(self) -> None:
        if self.task is None or self.task.done():
            self.task = asyncio.create_task(self.run(), name="camera-supervisor")

    async def stop(self) -> None:
        tasks = [task for task in (self.task, *self.background) if task is not None]
        for task in tasks:
            task.cancel()
        await asyncio.gather(*tasks, return_exceptions=True)
        self.task = None
        self.background.clear()
        await self.go2rtc.close()

    async def run(self) -> None:
        while True:
            healthy = await self.tick()
            await asyncio.sleep(self.interval if healthy else min(self.interval, RETRY_SECONDS))

    async def tick(self) -> bool:
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
        async with async_session_maker() as session:
            rows = await session.scalars(select(Camera).where(Camera.deleted_at.is_(None)))
            return list(rows)

    async def apply(self, desired: dict[str, list[str]], scope: Callable[[str], bool]) -> None:
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
        desired = {}
        for camera in cameras:
            desired.update(streams_for(camera))
        await self.apply(desired, is_managed)

    async def sync(self, camera: Camera) -> None:
        camera_uuid = camera.uuid
        try:
            await self.apply(streams_for(camera), lambda name: belongs_to(name, camera_uuid))
        except Go2rtcError as exc:
            logger.warning("Updating go2rtc for camera %s failed: %s", camera_uuid, exc)

    async def remove(self, camera_uuid: UUID) -> None:
        self.statuses.forget(camera_uuid)
        try:
            await self.apply({}, lambda name: belongs_to(name, camera_uuid))
        except Go2rtcError as exc:
            logger.warning("Removing the go2rtc streams of camera %s failed: %s", camera_uuid, exc)

    async def probe_target(self, camera_uuid: UUID, host: str, port: int) -> ProbeResult:
        result = await probe(host, port)
        self.statuses.record(camera_uuid, host, port, result)
        return result

    async def probe_camera(self, camera: Camera) -> ProbeResult:
        return await self.probe_target(camera.uuid, camera.host, camera.rtsp_port)

    async def probe_all(self, cameras: list[Camera]) -> None:
        semaphore = asyncio.Semaphore(PROBE_CONCURRENCY)

        async def limited(camera: Camera) -> None:
            async with semaphore:
                await self.probe_camera(camera)

        await asyncio.gather(*(limited(camera) for camera in cameras))

    def probe_later(self, camera: Camera) -> None:
        task = asyncio.create_task(self.probe_target(camera.uuid, camera.host, camera.rtsp_port))
        self.background.add(task)
        task.add_done_callback(self.background.discard)


supervisor = CameraSupervisor(
    Go2rtcClient(settings.go2rtc_url),
    StatusStore(),
    settings.monitor_interval_seconds,
)
