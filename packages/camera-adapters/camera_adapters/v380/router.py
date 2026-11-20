"""Routing of control commands to the session that streams a camera, or to a short session of their own."""

import asyncio
import contextlib
import logging
from dataclasses import asdict

from camera_adapters.v380.client import Camera, Session, Timeouts
from camera_adapters.v380.control import send, socket_path
from camera_adapters.v380.errors import SessionLost, V380Error
from camera_adapters.v380.records import LightMode, PictureMode, PtzMove, Stream

__all__ = ["CommandRouter", "router_for"]

logger = logging.getLogger(__name__)

LINGER_SECONDS = 30.0
STREAMS = ("main", "sub")

ROUTERS: dict[tuple[str, int, int], "CommandRouter"] = {}


class CommandRouter:
    """Sends control commands to a camera.

    A stream process that holds the camera's session serves a control socket, and commands go there first, so
    the camera keeps a single session. Without one, the router opens a sub stream session without sound of its
    own, keeps it while commands keep coming, and closes it LINGER_SECONDS after the last one or once a running
    siren has finished; closing sends a stop while a move runs.

    Attributes:
        camera: The camera.
        directory: Directory of the stream processes' control sockets.
        linger: Seconds the own session stays open after the last command.
        timeouts: Timers of the own session.
        session: The own session, if open.
        drain: Task that reads and discards the own session's media.
        closer: Task that closes the own session when idle.
        lock: Serialises opening and closing the own session.
    """

    def __init__(self, camera: Camera, directory: str, linger: float = LINGER_SECONDS, timeouts: Timeouts = Timeouts()):
        """Create the router.

        Args:
            camera: The camera.
            directory: Directory of the control sockets.
            linger: Seconds the own session stays open after the last command.
            timeouts: Timers of the own session.
        """
        self.camera = camera
        self.directory = directory
        self.linger = linger
        self.timeouts = timeouts
        self.session: Session | None = None
        self.drain: asyncio.Task | None = None
        self.closer: asyncio.Task | None = None
        self.lock = asyncio.Lock()

    async def command(self, request: dict) -> dict:
        """Carry out a command.

        Args:
            request: The command, as the control socket takes it.

        Returns:
            The answer, ok or an error code.
        """
        for stream in STREAMS:
            path = socket_path(self.directory, self.camera.device_id, stream)
            if not path.exists():
                continue
            try:
                answer = await send(path, request)
            except OSError:
                continue
            if answer.get("error") != "no_session":
                return answer
        return await self.own(request)

    async def own(self, request: dict) -> dict:
        """Carry out a command on the router's own session.

        Args:
            request: The command.

        Returns:
            The answer.
        """
        try:
            session = await self.open()
            name = request.get("command")
            hold = 0.0
            if name == "ptz":
                await session.ptz(PtzMove(str(request.get("move"))))
            elif name == "light":
                await session.light(LightMode(str(request.get("mode"))))
            elif name == "siren":
                hold = float(request.get("seconds") or 0)
                await session.siren(hold)
            elif name == "picture":
                await session.picture(PictureMode(str(request.get("mode"))))
            elif name == "flip":
                await session.flip()
            elif name == "facts":
                return {"ok": True, "facts": asdict(session.facts), "open": True}
            else:
                return {"ok": False, "error": "unknown_command"}
        except ValueError:
            return {"ok": False, "error": "invalid"}
        except V380Error as exc:
            await self.close()
            return {"ok": False, "error": exc.code, "message": exc.message}
        self.schedule(hold)
        return {"ok": True}

    async def open(self) -> Session:
        """Open the own session unless it is open.

        Returns:
            The session.
        """
        async with self.lock:
            if self.session is not None and self.session.is_open:
                return self.session
            session = Session(self.camera, Stream.SUB, sound=False, timeouts=self.timeouts)
            await session.open()
            self.session = session
            self.drain = asyncio.create_task(self.discard(session))
            return session

    async def discard(self, session: Session) -> None:
        """Read and discard the own session's media so the camera keeps sending.

        Args:
            session: The session.
        """
        with contextlib.suppress(SessionLost):
            async for _ in session.frames():
                pass
        if self.session is session:
            self.session = None

    def schedule(self, hold: float) -> None:
        """Close the own session once it has been idle long enough.

        Args:
            hold: Seconds a running command, such as the siren, needs the session for.
        """
        if self.closer is not None:
            self.closer.cancel()
        self.closer = asyncio.create_task(self.close_later(max(self.linger, hold + 1.0)))

    async def close_later(self, seconds: float) -> None:
        """Close the own session after a delay.

        Args:
            seconds: The delay.
        """
        await asyncio.sleep(seconds)
        await self.close()

    async def close(self) -> None:
        """Close the own session, sending a stop while a move runs."""
        async with self.lock:
            session, self.session = self.session, None
            if session is not None:
                await session.close()
            if self.drain is not None:
                self.drain.cancel()
                await asyncio.gather(self.drain, return_exceptions=True)
                self.drain = None
        if self.closer is not None and self.closer is not asyncio.current_task():
            self.closer.cancel()
        self.closer = None


def router_for(camera: Camera, directory: str) -> CommandRouter:
    """Return the router of a camera, shared within the process so it holds at most one session.

    Args:
        camera: The camera.
        directory: Directory of the control sockets.

    Returns:
        The router; a changed password replaces it.
    """
    key = (camera.host, camera.port, camera.device_id)
    router = ROUTERS.get(key)
    if router is None or router.camera != camera:
        router = CommandRouter(camera, directory)
        ROUTERS[key] = router
    return router
