"""Movers carry follow commands out: through the backend, and back to the start by preset or by retracing.

The analytics service holds no camera credentials, so the backend moves the lens on its behalf through internal
endpoints that need the shared token. The recording mover wraps it: it asks the camera to store the start position
as a preset and, when the camera keeps no presets, records every move with its duration so it can retrace them in
reverse, which brings a lens without presets back to where it started.
"""

from __future__ import annotations

import json
import logging
import time
import urllib.error
import urllib.request
from collections.abc import Callable
from dataclasses import dataclass
from typing import Protocol

from app.follow.controller import Command, CommandKind

logger = logging.getLogger(__name__)

TIMEOUT_SECONDS = 3.0
NO_PRESETS = 409


class Mover(Protocol):
    """Moves one camera's lens."""

    def move(self, pan: float, tilt: float) -> None:
        """Start a continuous move.

        Args:
            pan: Pan speed from -1 to 1.
            tilt: Tilt speed from -1 to 1.
        """

    def stop(self) -> None:
        """Stop any move."""

    def save_home(self) -> bool:
        """Store the current position.

        Returns:
            True when the camera stored it as a preset it can return to.
        """

    def return_home(self) -> None:
        """Go back to the stored position."""


def execute(mover: Mover, command: Command) -> None:
    """Carry out one controller command.

    Args:
        mover: The mover of the followed camera.
        command: The command.
    """
    if command.kind == CommandKind.MOVE:
        mover.move(command.pan, command.tilt)
    elif command.kind == CommandKind.STOP:
        mover.stop()
    elif command.kind == CommandKind.SAVE_HOME:
        mover.save_home()
    elif command.kind == CommandKind.RETURN_HOME:
        mover.return_home()


Opener = Callable[[urllib.request.Request, float], object]


def default_opener(request: urllib.request.Request, timeout: float):
    """Open a request with urllib.

    Args:
        request: The request.
        timeout: Timeout in seconds.

    Returns:
        The response, a context manager.
    """
    return urllib.request.urlopen(request, timeout=timeout)


class BackendMover:
    """Moves a camera through the backend's internal analytics PTZ endpoints.

    Errors are logged and never raised, so a camera that does not answer never stops the analytics loop.

    Attributes:
        url: Backend base URL.
        token: Shared token sent as a bearer token.
        camera: Camera id.
        opener: Opens a request with a timeout; urllib by default, replaceable in tests.
        errors: Number of failed calls.
        last_error: Latest failure.
    """

    def __init__(self, url: str, token: str, camera: str, opener: Opener | None = None):
        """Create the mover.

        Args:
            url: Backend base URL such as http://backend:8000.
            token: Shared token.
            camera: Camera id.
            opener: Request opener, urllib when None.
        """
        self.url = url.rstrip("/")
        self.token = token
        self.camera = camera
        self.opener = opener or default_opener
        self.errors = 0
        self.last_error: str | None = None

    def post(self, action: str, body: dict | None = None) -> int | None:
        """Send one PTZ request.

        Args:
            action: Path below the camera, such as move, stop or home.
            body: JSON body, if any.

        Returns:
            The HTTP status, or None when the backend could not be reached.
        """
        data = json.dumps(body or {}).encode()
        request = urllib.request.Request(
            f"{self.url}/internal/analytics/ptz/{self.camera}/{action}", data=data, method="POST"
        )
        request.add_header("Authorization", f"Bearer {self.token}")
        request.add_header("Content-Type", "application/json")
        try:
            with self.opener(request, TIMEOUT_SECONDS) as response:
                response.read()
                return int(getattr(response, "status", 200))
        except urllib.error.HTTPError as exc:
            if exc.code != NO_PRESETS:
                self.fail(action, f"HTTP {exc.code}")
            return exc.code
        except (OSError, ValueError) as exc:
            self.fail(action, f"{type(exc).__name__}: {exc}")
            return None

    def fail(self, action: str, message: str) -> None:
        """Record a failed call.

        Args:
            action: The PTZ action.
            message: What went wrong.
        """
        self.errors += 1
        self.last_error = f"{action}: {message}"
        logger.warning("Follow %s on camera %s failed: %s", action, self.camera, message)

    def move(self, pan: float, tilt: float) -> None:
        """Start a continuous move.

        Args:
            pan: Pan speed from -1 to 1.
            tilt: Tilt speed from -1 to 1.
        """
        self.post("move", {"pan": round(pan, 3), "tilt": round(tilt, 3)})

    def stop(self) -> None:
        """Stop any move."""
        self.post("stop")

    def save_home(self) -> bool:
        """Ask the camera to store the current position as the follow preset.

        Returns:
            True when the camera stored it; False when it keeps no presets or the call failed.
        """
        status = self.post("home", {"action": "save"})
        return status is not None and 200 <= status < 300

    def return_home(self) -> None:
        """Move the camera to the stored follow preset."""
        self.post("home", {"action": "return"})


@dataclass
class Segment:
    """One recorded move.

    Attributes:
        pan: Pan speed.
        tilt: Tilt speed.
        seconds: How long the move ran.
    """

    pan: float
    tilt: float
    seconds: float


class RecordingMover:
    """Remembers how the lens left its start position so it can go back.

    By default return_home replays the recorded moves in reverse order with negated speeds and the same durations,
    then stops; every move command is mirrored by one, so cameras that turn a fixed step per command come back too.
    With presets on, save_home asks the wrapped mover for a preset and return_home goes to it when the camera stored
    one. The replay blocks for as long as the moves took, so the caller runs it off the analysis loop.

    Attributes:
        raw: The mover that talks to the camera.
        clock: Returns the current time.
        sleep: Waits a number of seconds.
        use_presets: Whether to save and return to a preset instead of retracing.
        presets: Whether the camera stored the start position as a preset.
        segments: Moves since the start position, finished ones only.
        current: The move running now and its start time, or None.
    """

    def __init__(
        self,
        raw: Mover,
        clock: Callable[[], float] = time.monotonic,
        sleep: Callable[[float], None] = time.sleep,
        use_presets: bool = False,
    ):
        """Wrap a mover.

        Args:
            raw: The mover that talks to the camera.
            clock: Monotonic clock.
            sleep: Sleep function.
            use_presets: Whether to save and return to a preset instead of retracing.
        """
        self.raw = raw
        self.use_presets = use_presets
        self.clock = clock
        self.sleep = sleep
        self.presets = False
        self.segments: list[Segment] = []
        self.current: tuple[float, float, float] | None = None

    def close_current(self) -> None:
        """Finish the running move's record."""
        if self.current is None:
            return
        pan, tilt, started = self.current
        seconds = max(0.0, self.clock() - started)
        if seconds > 0:
            self.segments.append(Segment(pan, tilt, seconds))
        self.current = None

    def move(self, pan: float, tilt: float) -> None:
        """Start a continuous move and record it.

        Args:
            pan: Pan speed from -1 to 1.
            tilt: Tilt speed from -1 to 1.
        """
        self.close_current()
        self.raw.move(pan, tilt)
        self.current = (pan, tilt, self.clock())

    def stop(self) -> None:
        """Stop any move and close its record."""
        self.raw.stop()
        self.close_current()

    def save_home(self) -> bool:
        """Store the current position and start a new record.

        Returns:
            True when the camera stored a preset; the record is kept either way.
        """
        self.close_current()
        self.segments = []
        self.presets = bool(self.raw.save_home()) if self.use_presets else False
        return self.presets

    def return_home(self) -> None:
        """Go back to the start: by preset when the camera keeps one, otherwise by retracing the record."""
        if self.current is not None:
            self.raw.stop()
            self.close_current()
        if self.presets:
            self.raw.return_home()
        else:
            for segment in reversed(self.segments):
                self.raw.move(-segment.pan, -segment.tilt)
                self.sleep(segment.seconds)
            if self.segments:
                self.raw.stop()
        self.segments = []
