"""The follow controller: turns the tracked people of one view into pan and tilt commands.

The controller saves the lens position once when follow starts, picks the largest person, ties going to the most
central one, and keeps that track. While the target's box centre is outside a small dead zone around the view's
centre point it sends proportional ContinuousMove speeds, clamped between a minimum the motors respond to and a
maximum, smoothed and rate limited. Inside the dead zone, or once the target has been lost for a moment, it stops.
After a longer time without anyone it sends the lens back to the saved position once. The controller does no I/O:
each call returns at most one command for a mover to carry out.
"""

from __future__ import annotations

import math
from collections.abc import Sequence
from dataclasses import dataclass
from enum import StrEnum

from app.follow.settings import FollowSettings
from app.rules.geometry import Point, distance
from app.rules.model import Detection

SAME_SPEED = 0.05


class CommandKind(StrEnum):
    """What a command asks the lens to do."""

    MOVE = "move"
    STOP = "stop"
    SAVE_HOME = "save_home"
    RETURN_HOME = "return_home"


@dataclass(frozen=True)
class Command:
    """One instruction for a mover.

    Attributes:
        kind: What to do.
        pan: Pan speed from -1 to 1 for a move, positive turning right.
        tilt: Tilt speed from -1 to 1 for a move, positive turning up.
    """

    kind: CommandKind
    pan: float = 0.0
    tilt: float = 0.0


def centre_of(detection: Detection) -> Point:
    """Return the centre of a detection's box.

    Args:
        detection: The detection.

    Returns:
        The box centre in normalized view coordinates.
    """
    return detection.box.centre


def area_of(detection: Detection) -> float:
    """Return the area of a detection's box.

    Args:
        detection: The detection.

    Returns:
        The area in normalized units.
    """
    box = detection.box
    return max(0.0, box.right - box.left) * max(0.0, box.bottom - box.top)


def axis_speed(error: float, dead: float, settings: FollowSettings) -> float:
    """Return the speed of one axis for a centring error.

    Args:
        error: Signed distance of the target from the centre point along the axis.
        dead: Half width of the dead zone along the axis.
        settings: Follow settings.

    Returns:
        A signed speed, 0 inside the dead zone, otherwise between the minimum and maximum speed.
    """
    if abs(error) <= dead:
        return 0.0
    magnitude = min(settings.max_speed, max(settings.min_speed, settings.gain * abs(error)))
    return math.copysign(magnitude, error)


class FollowController:
    """Follow state of one view.

    Attributes:
        settings: Follow settings.
        enabled: Whether the controller sends commands.
        saved: Whether the start position was saved since follow was enabled.
        dirty: Whether the lens moved since the position was saved or last returned.
        target: Track id of the followed person, or None.
        last_seen: Time the target was last seen.
        last_point: Box centre of the target when last seen.
        idle_since: Time since which no target has been seen.
        moving: Whether the last command sent was a move.
        velocity: Pan and tilt of the last move sent.
        last_command_at: Time of the last move or stop sent.
        returned: Whether the lens was sent back since the last target.
    """

    def __init__(self, settings: FollowSettings, now: float = 0.0):
        """Create the controller.

        Args:
            settings: Follow settings; the controller starts enabled when they say so.
            now: Current time, which starts the idle timer.
        """
        self.settings = settings
        self.enabled = settings.enabled
        self.saved = False
        self.dirty = False
        self.target: int | None = None
        self.last_seen: float | None = None
        self.last_point: Point | None = None
        self.idle_since = now
        self.moving = False
        self.velocity: tuple[float, float] = (0.0, 0.0)
        self.last_command_at = float("-inf")
        self.returned = True

    def enable(self, now: float) -> None:
        """Start following; the next update saves the lens position first.

        Args:
            now: Current time.
        """
        if self.enabled:
            return
        self.enabled = True
        self.saved = False
        self.dirty = False
        self.target = None
        self.last_seen = None
        self.last_point = None
        self.idle_since = now
        self.returned = True

    def disable(self) -> list[Command]:
        """Stop following.

        Returns:
            A stop when the lens is moving, then a return when it moved since its position was saved.
        """
        commands = []
        if not self.enabled:
            return commands
        if self.moving:
            commands.append(Command(CommandKind.STOP))
        if self.dirty:
            commands.append(Command(CommandKind.RETURN_HOME))
        self.enabled = False
        self.moving = False
        self.dirty = False
        self.target = None
        self.velocity = (0.0, 0.0)
        return commands

    def configure(self, settings: FollowSettings, now: float) -> list[Command]:
        """Apply new settings, enabling or disabling as they say.

        Args:
            settings: The new settings.
            now: Current time.

        Returns:
            Commands that disabling requires, if it does.
        """
        self.settings = settings
        if settings.enabled and not self.enabled:
            self.enable(now)
        elif not settings.enabled and self.enabled:
            return self.disable()
        return []

    def choose(self, people: Sequence[Detection], now: float) -> Detection | None:
        """Pick the person to follow in this frame.

        The current target wins while it is in the frame. A new track close to where the target was lost, within
        the reacquire time, continues it. Otherwise the largest person wins, ties going to the most central.

        Args:
            people: Followable detections of the frame.
            now: Frame time.

        Returns:
            The detection to follow, or None.
        """
        if not people:
            return None
        for detection in people:
            if detection.track_id == self.target:
                return detection
        if self.last_point is not None and self.last_seen is not None:
            if now - self.last_seen <= self.settings.reacquire_seconds:
                near = [
                    detection
                    for detection in people
                    if distance(centre_of(detection), self.last_point) <= self.settings.reacquire_distance
                ]
                if near:
                    return min(near, key=lambda detection: distance(centre_of(detection), self.last_point))
        centre = self.settings.centre
        return max(
            people, key=lambda detection: (round(area_of(detection), 4), -distance(centre_of(detection), centre))
        )

    def update(self, detections: Sequence[Detection], now: float) -> Command | None:
        """Fold one analysed frame in.

        Args:
            detections: Tracked objects of the followed view's frame; an empty list when the frame had none.
            now: Frame time.

        Returns:
            The command to carry out, or None.
        """
        if not self.enabled:
            return None
        if not self.saved:
            self.saved = True
            return Command(CommandKind.SAVE_HOME)
        people = [detection for detection in detections if detection.label in self.settings.labels]
        chosen = self.choose(people, now)
        if chosen is None:
            return self.without_target(now)
        self.target = chosen.track_id
        self.last_seen = now
        self.last_point = centre_of(chosen)
        self.idle_since = now
        self.returned = False
        return self.steer(self.last_point, now)

    def without_target(self, now: float) -> Command | None:
        """Decide what to do in a frame without the target.

        Args:
            now: Frame time.

        Returns:
            A stop once the target has been lost long enough, a return once the view stayed empty for the idle
            time, or None.
        """
        last = self.last_seen if self.last_seen is not None else self.idle_since
        if self.moving and now - last >= self.settings.lost_seconds:
            return self.stop(now)
        if self.last_seen is not None and now - self.last_seen > self.settings.reacquire_seconds:
            self.target = None
        if not self.moving and not self.returned and now - self.idle_since >= self.settings.idle_seconds:
            self.returned = True
            if self.dirty:
                self.dirty = False
                self.target = None
                self.last_point = None
                self.last_seen = None
                return Command(CommandKind.RETURN_HOME)
        return None

    def stop(self, now: float) -> Command:
        """Return a stop and record it.

        Args:
            now: Current time.

        Returns:
            The stop command.
        """
        self.moving = False
        self.velocity = (0.0, 0.0)
        self.last_command_at = now
        return Command(CommandKind.STOP)

    def steer(self, point: Point, now: float) -> Command | None:
        """Return the move or stop that centres a point.

        Args:
            point: Box centre of the target.
            now: Frame time.

        Returns:
            A move, a stop when the point entered the dead zone, or None when the last command still holds.
        """
        settings = self.settings
        error_x = point[0] - settings.centre[0]
        error_y = point[1] - settings.centre[1]
        pan = axis_speed(error_x, settings.dead_zone[0], settings)
        tilt = -axis_speed(error_y, settings.dead_zone[1], settings)
        if settings.invert_pan:
            pan = -pan
        if settings.invert_tilt:
            tilt = -tilt
        if pan == 0.0 and tilt == 0.0:
            return self.stop(now) if self.moving else None
        previous_pan, previous_tilt = self.velocity
        flipped = pan * previous_pan < 0 or tilt * previous_tilt < 0
        if self.moving and not flipped:
            pan = self.smooth(pan, previous_pan)
            tilt = self.smooth(tilt, previous_tilt)
        waited = now - self.last_command_at
        if self.moving and not flipped and waited < settings.interval:
            return None
        same = abs(pan - previous_pan) < SAME_SPEED and abs(tilt - previous_tilt) < SAME_SPEED
        if self.moving and same and waited < settings.refresh:
            return None
        self.moving = True
        self.dirty = True
        self.velocity = (pan, tilt)
        self.last_command_at = now
        return Command(CommandKind.MOVE, round(pan, 3), round(tilt, 3))

    def smooth(self, new: float, previous: float) -> float:
        """Blend a new axis speed with the previous one, keeping it above the minimum speed.

        Args:
            new: Speed the error asks for.
            previous: Speed last sent.

        Returns:
            The blended speed, 0 when the axis needs no movement.
        """
        if new == 0.0:
            return 0.0
        weight = self.settings.smoothing
        blended = weight * new + (1 - weight) * previous
        if blended * new <= 0:
            return new
        magnitude = min(self.settings.max_speed, max(self.settings.min_speed, abs(blended)))
        return math.copysign(magnitude, new)

    def status(self) -> dict:
        """Return the follow state for the status endpoint.

        Returns:
            Whether follow is on, the target, whether the lens moves and its last speeds.
        """
        return {
            "enabled": self.enabled,
            "target": self.target,
            "moving": self.moving,
            "pan": round(self.velocity[0], 3),
            "tilt": round(self.velocity[1], 3),
            "away_from_home": self.dirty,
        }
