"""The fall detector of one view: fast transition to lying, then stillness.

Each track keeps a short history of postures. A lying posture, by torso angle or by box shape, starts a fall
candidate when the same track was upright by the same measure within the transition time and its hips dropped by a
share of its standing height in between. Lying down slowly on a bed passes through sitting, which keeps the hips
low before the torso tips, and bending over keeps the hips up, so neither starts a candidate. The candidate becomes
a fall once the person has lain still for the still time, and ends without an event when the person gets up or the
wait runs out. Each fall produces one instant event of kind fall that spans from the fall to the end of the still
time, so its clip shows both.
"""

from __future__ import annotations

import collections
import uuid
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import datetime, tzinfo

from app.falls.posture import PoseSample, Posture, motion, posture
from app.rules.engine import Event, Update
from app.rules.kinds import ExtraKind
from app.rules.model import AlertMode, AlertPolicy, ArmMode, Box

HISTORY = 64
STANDING_SAMPLES = 40
STANDING_SHARE = 0.8

WATCH = "watch"
FALLEN = "fallen"
REPORTED = "reported"


@dataclass(frozen=True)
class FallSettings:
    """How a view detects falls.

    Attributes:
        enabled: Whether the view looks for falls.
        still_seconds: Seconds a person must lie still after the fall.
        transition_seconds: Longest time from upright to lying that counts as a fall.
        min_score: Lowest keypoint score that counts; without enough keypoints the box shape decides.
        upright_angle: Torso angles below this, in degrees from vertical, are upright.
        lying_angle: Torso angles above this are lying.
        upright_aspect: Box width over height below this is upright.
        lying_aspect: Box width over height above this is lying.
        drop: Share of the standing height the hips must drop during the transition.
        still_motion: Largest movement, as a share of the standing height, that still counts as lying still.
        rise_seconds: Seconds of not lying after which a fall candidate ends as getting up.
        max_wait: Seconds after the fall within which the stillness must come.
        cooldown: Seconds after a reported fall during which the same track reports no new one.
        track_gap: Seconds after which a track that is no longer seen is forgotten.
        alert: Alert policy of fall events; by default they always alert.
        alert_disarmed: Whether falls alert while the system is disarmed, because a fall is not an intrusion.
    """

    enabled: bool = False
    still_seconds: float = 8.0
    transition_seconds: float = 1.5
    min_score: float = 0.3
    upright_angle: float = 35.0
    lying_angle: float = 60.0
    upright_aspect: float = 0.8
    lying_aspect: float = 1.3
    drop: float = 0.3
    still_motion: float = 0.12
    rise_seconds: float = 1.0
    max_wait: float = 60.0
    cooldown: float = 120.0
    track_gap: float = 10.0
    alert: AlertPolicy = field(default_factory=lambda: AlertPolicy(mode=AlertMode.ALWAYS))
    alert_disarmed: bool = True

    @classmethod
    def from_dict(cls, data: dict | None) -> FallSettings:
        """Build the settings from the falls mapping, keeping defaults for missing keys.

        Args:
            data: The falls mapping, or None.

        Returns:
            The settings.
        """
        data = data or {}
        numbers = {
            name: float(data[name])
            for name in cls.__dataclass_fields__
            if name not in ("enabled", "alert", "alert_disarmed") and data.get(name) is not None
        }
        alert = AlertPolicy.from_dict(data["alert"]) if data.get("alert") else AlertPolicy(mode=AlertMode.ALWAYS)
        return cls(
            enabled=bool(data.get("enabled", False)),
            alert=alert,
            alert_disarmed=bool(data.get("alert_disarmed", True)),
            **numbers,
        )

    @classmethod
    def from_view(cls, raw: dict | None) -> FallSettings:
        """Build the settings from a view's configuration.

        Args:
            raw: The view configuration as the backend sent it.

        Returns:
            The settings of its falls key.
        """
        return cls.from_dict((raw or {}).get("falls"))


@dataclass
class TrackPose:
    """Fall state of one track.

    Attributes:
        history: Recent postures, oldest first.
        standing: Box heights of recent upright postures.
        phase: watch, fallen or reported.
        fell_at: Time the fall candidate started.
        anchor: Posture the stillness is measured from.
        still_since: Time since which the person has lain still.
        not_lying_since: Time since which the person has not been lying, during a candidate.
        reported_at: Time of the last reported fall.
        last_seen: Time of the latest sample.
        box: Latest box.
    """

    history: collections.deque = field(default_factory=lambda: collections.deque(maxlen=HISTORY))
    standing: collections.deque = field(default_factory=lambda: collections.deque(maxlen=STANDING_SAMPLES))
    phase: str = WATCH
    fell_at: float | None = None
    anchor: Posture | None = None
    still_since: float | None = None
    not_lying_since: float | None = None
    reported_at: float | None = None
    last_seen: float = 0.0
    box: Box = field(default_factory=lambda: Box(0.0, 0.0, 0.0, 0.0))

    def standing_height(self, fallback: float) -> float:
        """Return the person's standing height from their upright postures.

        Args:
            fallback: Height used when no upright posture was seen.

        Returns:
            A high percentile of the upright box heights, so sitting lowers it little.
        """
        if not self.standing:
            return fallback
        ordered = sorted(self.standing)
        return ordered[min(len(ordered) - 1, int(len(ordered) * STANDING_SHARE))]


class FallDetector:
    """Detects falls on one view.

    Attributes:
        view: View id.
        settings: Fall settings.
        timezone: Time zone of alert schedules.
        arm: Returns the current arm mode.
        tracks: Fall state per tracker id.
    """

    def __init__(
        self,
        view: str,
        settings: FallSettings,
        timezone: tzinfo,
        arm: Callable[[], ArmMode] = lambda: ArmMode.DISARMED,
    ):
        """Create the detector.

        Args:
            view: View id.
            settings: Fall settings.
            timezone: Time zone of alert schedules.
            arm: Returns the current arm mode.
        """
        self.view = view
        self.settings = settings
        self.timezone = timezone
        self.arm = arm
        self.tracks: dict[int, TrackPose] = {}

    def upright(self, item: Posture) -> tuple[bool, bool]:
        """Classify a posture as upright by torso angle and by box shape.

        Args:
            item: The posture.

        Returns:
            Upright by angle and upright by box shape.
        """
        settings = self.settings
        return (item.angle is not None and item.angle < settings.upright_angle, item.aspect < settings.upright_aspect)

    def lying(self, item: Posture) -> tuple[bool, bool]:
        """Classify a posture as lying by torso angle and by box shape.

        Args:
            item: The posture.

        Returns:
            Lying by angle and lying by box shape.
        """
        settings = self.settings
        return (item.angle is not None and item.angle > settings.lying_angle, item.aspect > settings.lying_aspect)

    def fell(self, state: TrackPose, item: Posture) -> bool:
        """Tell whether a lying posture ends a fast fall from upright.

        Args:
            state: The track's state, whose history does not hold the posture yet.
            item: The current posture.

        Returns:
            True when the track was upright by the same measure within the transition time and its hips dropped
            enough since.
        """
        by_angle, by_shape = self.lying(item)
        if not by_angle and not by_shape:
            return False
        for past in reversed(state.history):
            if item.at - past.at > self.settings.transition_seconds:
                break
            was_angle, was_shape = self.upright(past)
            if not ((by_angle and was_angle) or (by_shape and was_shape)):
                continue
            scale = state.standing_height(past.height)
            if item.hip_y - past.hip_y >= self.settings.drop * scale:
                return True
        return False

    def update(self, samples: list[PoseSample], now: float) -> list[Update]:
        """Fold the pose samples of one frame in.

        Args:
            samples: Pose samples of the view's tracked people.
            now: Frame time.

        Returns:
            Instant fall events for the falls that completed with this frame.
        """
        updates: list[Update] = []
        for sample in samples:
            state = self.tracks.setdefault(sample.track, TrackPose())
            item = posture(sample, self.settings.min_score)
            state.last_seen = sample.at
            state.box = sample.box
            update = self.step(sample.track, state, item)
            if update is not None:
                updates.append(update)
            if any(self.upright(item)):
                state.standing.append(item.height)
            state.history.append(item)
        return updates

    def step(self, track: int, state: TrackPose, item: Posture) -> Update | None:
        """Advance one track's fall state with a new posture.

        Args:
            track: Tracker id.
            state: The track's state.
            item: The new posture.

        Returns:
            The fall event when the fall completed, otherwise None.
        """
        settings = self.settings
        lying = any(self.lying(item))
        if state.phase == REPORTED:
            if all(not flag for flag in self.lying(item)) and any(self.upright(item)):
                state.phase = WATCH
            return None
        if state.phase == WATCH:
            cooling = state.reported_at is not None and item.at - state.reported_at < settings.cooldown
            if not cooling and self.fell(state, item):
                state.phase = FALLEN
                state.fell_at = item.at
                state.anchor = item
                state.still_since = item.at
                state.not_lying_since = None
            return None
        if not lying:
            state.anchor = item
            state.still_since = item.at
            if state.not_lying_since is None:
                state.not_lying_since = item.at
            if item.at - state.not_lying_since >= settings.rise_seconds:
                state.phase = WATCH
            return None
        state.not_lying_since = None
        scale = state.standing_height(item.height)
        if motion(state.anchor, item, scale) > settings.still_motion:
            state.anchor = item
            state.still_since = item.at
        if item.at - state.still_since >= settings.still_seconds:
            state.phase = REPORTED
            state.reported_at = item.at
            return Update("instant", self.event(track, state, item.at))
        if item.at - state.fell_at > settings.max_wait:
            state.phase = WATCH
        return None

    def event(self, track: int, state: TrackPose, now: float) -> Event:
        """Build the event of a completed fall.

        Args:
            track: Tracker id.
            state: The track's state.
            now: Time the stillness completed.

        Returns:
            An instant event from the fall to now.
        """
        started = state.fell_at if state.fell_at is not None else now
        arm = self.arm()
        moment = datetime.fromtimestamp(started, self.timezone)
        alert = self.settings.alert.alerts(arm, "person", moment)
        if arm == ArmMode.DISARMED and self.settings.alert_disarmed and self.settings.alert.mode != AlertMode.OFF:
            alert = True
        event = Event(
            id=str(uuid.uuid4()),
            view=self.view,
            kind=ExtraKind.FALL,
            label="person",
            started_at=started,
            ended_at=now,
            objects=[track],
            boxes=[{"object": track, "label": "person", "box": state.box.rounded(), "at": round(now, 3)}],
            count=1,
            alert=alert,
        )
        return event

    def tick(self, now: float) -> list[Update]:
        """Forget tracks that are no longer seen.

        Args:
            now: Current time.

        Returns:
            Always empty; a fall needs the person seen lying still, so a lost track never completes one.
        """
        for track in [key for key, state in self.tracks.items() if now - state.last_seen > self.settings.track_gap]:
            del self.tracks[track]
        return []

    def status(self) -> dict:
        """Return the fall state for the status endpoint.

        Returns:
            Tracks watched and tracks in a fall candidate.
        """
        return {
            "tracks": len(self.tracks),
            "candidates": sorted(track for track, state in self.tracks.items() if state.phase == FALLEN),
        }
