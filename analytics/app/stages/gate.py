"""Which tracked objects are worth a secondary model this frame.

Every analysed frame carries every tracked person, but a person's appearance changes slowly and a fall takes a
second or more, so each stage takes a track at its own pace: appearance about once a second up to a number of
crops per track, pose several times a second while the person is in view.
"""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass(frozen=True)
class Pace:
    """How often a stage takes one track.

    Attributes:
        interval: Seconds between two takes of one track.
        limit: Most takes per track, 0 for no limit.
    """

    interval: float
    limit: int = 0


@dataclass
class TrackGate:
    """Takes of one track by one stage.

    Attributes:
        last: Time of the latest take.
        taken: Takes so far.
        seen: Time the track was last offered.
    """

    last: float = float("-inf")
    taken: int = 0
    seen: float = 0.0


@dataclass
class StageGate:
    """Decides per stage, view and track whether a frame's object is taken.

    Attributes:
        paces: Pace per stage name.
        forget: Seconds after which a track not offered is dropped.
        tracks: Record per stage, muxer pad and tracker id.
    """

    paces: dict[str, Pace]
    forget: float = 30.0
    tracks: dict[tuple[str, int, int], TrackGate] = field(default_factory=dict)

    def want(self, stage: str, pad: int, track: int, now: float) -> bool:
        """Tell whether a stage takes an object now, and count the take when it does.

        Args:
            stage: Stage name.
            pad: Muxer pad of the view.
            track: Tracker id.
            now: Frame time.

        Returns:
            True when the object should be cropped for the stage.
        """
        pace = self.paces.get(stage)
        if pace is None:
            return False
        gate = self.tracks.setdefault((stage, pad, track), TrackGate())
        gate.seen = now
        if pace.limit and gate.taken >= pace.limit:
            return False
        if now - gate.last < pace.interval:
            return False
        gate.last = now
        gate.taken += 1
        return True

    def prune(self, now: float) -> None:
        """Drop the records of tracks not offered for a while.

        Args:
            now: Current time.
        """
        for key in [key for key, gate in self.tracks.items() if now - gate.seen > self.forget]:
            del self.tracks[key]
