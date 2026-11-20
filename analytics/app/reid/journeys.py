"""Links the tracks of one person across views into journeys.

Samples are folded into the appearance of their track while it lives. A track that has not been seen for the track
gap is finalized and compared with the tracks finalized before it: tracks of other views that ended within the time
window before it started, or overlapped it, and tracks of the same view that ended before it started.

Raw cosine similarities of person embeddings share a high floor, because every crop is a person seen by the same
few cameras, so different people often score as high as the same person seen from another camera. The linker
therefore keeps a running mean of the finalized track vectors and compares tracks after subtracting it and scaling
back to unit length, which removes the shared part. It links nothing until the mean has seen enough tracks to be
trusted. The service persists the mean and restores it on start.

The most similar journey wins when its centred similarity reaches the threshold and leads the next journey by the
margin, so two people who look alike stay apart rather than merge. The match must also be mutual: the earlier
track's best later candidate within the window must be the track being linked, so one earlier track never collects
several people. A journey never holds two tracks of one view at the same time, because one person cannot be in the
same picture twice.
"""

from __future__ import annotations

import uuid
from collections.abc import Iterable, Mapping
from dataclasses import dataclass, field

import numpy as np

from app.reid.appearance import FULL_HEIGHT_PX, MIN_HEIGHT_PX, AppearanceSample, TrackAppearance, normalize


@dataclass(frozen=True)
class JourneySettings:
    """How tracks are linked.

    Attributes:
        track_gap: Seconds without a sample after which a track is finalized.
        window_seconds: Longest time between the end of one track and the start of the next for them to link.
        threshold: Lowest centred cosine similarity that links two tracks.
        margin: How far the best journey must lead the second best, in centred similarity.
        min_samples: Counted samples a track needs before it can link.
        min_height: Crops below this height in muxer pixels are skipped.
        full_height: Crops at or above this height count fully.
        keep_seconds: Seconds finalized tracks stay in memory for linking and quick searches.
        mean_weight: Weight of each new track in the running mean once it is seeded; the first tracks are averaged
            evenly until their count reaches the inverse of this weight.
        min_tracks: Tracks the running mean must have seen before anything is linked.
    """

    track_gap: float = 5.0
    window_seconds: float = 180.0
    threshold: float = 0.35
    margin: float = 0.05
    min_samples: int = 2
    min_height: float = MIN_HEIGHT_PX
    full_height: float = FULL_HEIGHT_PX
    keep_seconds: float = 3600.0
    mean_weight: float = 0.02
    min_tracks: int = 20

    @classmethod
    def from_dict(cls, data: dict | None) -> JourneySettings:
        """Build the settings, keeping defaults for missing keys.

        Args:
            data: Mapping of setting names to numbers, or None.

        Returns:
            The settings.
        """
        data = data or {}
        values = {}
        for name, kind in (
            ("track_gap", float),
            ("window_seconds", float),
            ("threshold", float),
            ("margin", float),
            ("min_samples", int),
            ("min_height", float),
            ("full_height", float),
            ("keep_seconds", float),
            ("mean_weight", float),
            ("min_tracks", int),
        ):
            if data.get(name) is not None:
                values[name] = kind(data[name])
        return cls(**values)


@dataclass
class Step:
    """One track in a journey.

    Attributes:
        view: View id.
        camera: Camera id.
        track: Tracker id.
        start: First time of the track.
        end: Last time of the track.
        similarity: Centred similarity with which the track joined, None for the first track.
    """

    view: str
    camera: str
    track: int
    start: float
    end: float
    similarity: float | None = None

    def as_dict(self) -> dict:
        """Return the step for the backend.

        Returns:
            The step fields with times and similarity rounded.
        """
        return {
            "view": self.view,
            "camera": self.camera,
            "track": self.track,
            "start": round(self.start, 3),
            "end": round(self.end, 3),
            "similarity": round(self.similarity, 4) if self.similarity is not None else None,
        }


@dataclass
class Journey:
    """The linked tracks of one person.

    Attributes:
        id: Journey id.
        steps: Tracks in time order.
        updated_at: Time of the latest change.
    """

    id: str
    steps: list[Step] = field(default_factory=list)
    updated_at: float = 0.0

    def add(self, track: TrackAppearance, similarity: float | None, now: float) -> None:
        """Add a track and keep the steps in time order.

        Args:
            track: The track.
            similarity: Similarity with which it joined.
            now: Current time.
        """
        self.steps.append(Step(track.view, track.camera, track.track, track.first, track.last, similarity))
        self.steps.sort(key=lambda step: (step.start, step.end))
        self.updated_at = now

    def clashes(self, track: TrackAppearance) -> bool:
        """Tell whether a track overlaps a step of the same view.

        Args:
            track: The track.

        Returns:
            True when the journey already holds a track of that view at the same time.
        """
        return any(
            step.view == track.view and step.start <= track.last and track.first <= step.end for step in self.steps
        )

    def as_dict(self) -> dict:
        """Return the journey for the backend.

        Returns:
            Id, steps and update time.
        """
        return {
            "id": self.id,
            "steps": [step.as_dict() for step in self.steps],
            "updated_at": round(self.updated_at, 3),
        }


def describe(journey: dict | Journey, names: Mapping[str, str]) -> str:
    """Describe a journey in words, such as Yard, then Entrance, then Corridor.

    Args:
        journey: The journey or its dict form.
        names: View id to display name.

    Returns:
        The views in order, with repeated neighbours named once.
    """
    steps = journey.steps if isinstance(journey, Journey) else journey["steps"]
    labels: list[str] = []
    for step in steps:
        view = step.view if isinstance(step, Step) else step["view"]
        name = names.get(view, view)
        if not labels or labels[-1] != name:
            labels.append(name)
    return ", then ".join(labels)


def may_continue(earlier: TrackAppearance, later: TrackAppearance, window: float) -> bool:
    """Tell whether a track may be the continuation of another by time and view.

    Args:
        earlier: The track that would come first.
        later: The track that would continue it.
        window: Longest gap between the end of the first and the start of the second.

    Returns:
        True for another view when the first ended within the window before the second started or overlapped it,
        and for the same view when the first ended before the second started, within the window.
    """
    if earlier.view == later.view:
        return earlier.last <= later.first and later.first - earlier.last <= window
    return earlier.last >= later.first - window and earlier.first <= later.last


class JourneyLinker:
    """Keeps the appearance of live tracks and links finished ones into journeys.

    Attributes:
        settings: Linking settings.
        active: Live tracks by view and tracker id.
        finished: Finalized tracks with an appearance, oldest first.
        journeys: Journeys by id.
        mean: Running mean of finalized track vectors, None before the first.
        mean_tracks: Tracks folded into the running mean.
    """

    def __init__(self, settings: JourneySettings | None = None):
        """Create the linker.

        Args:
            settings: Linking settings, the defaults when None.
        """
        self.settings = settings or JourneySettings()
        self.active: dict[tuple[str, int], TrackAppearance] = {}
        self.finished: list[TrackAppearance] = []
        self.journeys: dict[str, Journey] = {}
        self.mean: np.ndarray | None = None
        self.mean_tracks = 0

    @property
    def ready(self) -> bool:
        """bool: True once the running mean has seen enough tracks to link."""
        return self.mean is not None and self.mean_tracks >= self.settings.min_tracks

    def learn(self, vector: np.ndarray) -> None:
        """Fold a finalized track vector into the running mean.

        Args:
            vector: The track's unit vector.
        """
        if self.mean is None or self.mean.shape != vector.shape:
            self.mean = vector.astype(np.float32).copy()
            self.mean_tracks = 1
            return
        self.mean_tracks += 1
        weight = max(self.settings.mean_weight, 1.0 / self.mean_tracks)
        self.mean = ((1.0 - weight) * self.mean + weight * vector).astype(np.float32)

    def mean_state(self) -> dict | None:
        """Return the running mean for the service to persist.

        Returns:
            The mean as a list of floats and the number of tracks it has seen, or None before the first track.
        """
        if self.mean is None:
            return None
        return {"mean": [round(float(value), 6) for value in self.mean], "tracks": self.mean_tracks}

    def restore_mean(self, data: dict | None) -> bool:
        """Restore a persisted running mean.

        Args:
            data: What mean_state returned, or None.

        Returns:
            True when the mean was restored.
        """
        if not data or not data.get("mean"):
            return False
        mean = np.asarray(data["mean"], dtype=np.float32).reshape(-1)
        if not np.all(np.isfinite(mean)):
            return False
        self.mean = mean
        self.mean_tracks = max(1, int(data.get("tracks") or 1))
        return True

    def centred(self, vector: np.ndarray | None) -> np.ndarray | None:
        """Remove the running mean from a vector and scale it back to unit length.

        Args:
            vector: A unit vector, or None.

        Returns:
            The centred unit vector, the vector itself without a matching mean, or None.
        """
        if vector is None:
            return None
        if self.mean is None or self.mean.shape != vector.shape:
            return normalize(vector)
        return normalize(vector - self.mean)

    def similarity(self, first: TrackAppearance, second: TrackAppearance) -> float | None:
        """Return the centred cosine similarity of two tracks.

        Args:
            first: One track.
            second: The other track.

        Returns:
            The similarity, or None when either has no usable vector.
        """
        one, two = self.centred(first.vector()), self.centred(second.vector())
        if one is None or two is None or one.shape != two.shape:
            return None
        return float(np.dot(one, two))

    def add(self, sample: AppearanceSample) -> bool:
        """Fold one sample into its track.

        Args:
            sample: The sample.

        Returns:
            True when the sample counted towards the track's appearance.
        """
        key = (sample.view, sample.track)
        track = self.active.get(key)
        if track is None:
            track = self.active[key] = TrackAppearance(sample.view, sample.camera, sample.track, sample.at, sample.at)
        return track.add(sample, self.settings.min_height, self.settings.full_height)

    def tick(self, now: float) -> tuple[list[dict], list[dict]]:
        """Finalize tracks that ended, link them and forget old ones.

        Args:
            now: Current time.

        Returns:
            The journeys that changed and the finalized track appearances, both as dicts for the backend.
        """
        ended = [track for track in self.active.values() if now - track.last >= self.settings.track_gap]
        ended.sort(key=lambda track: (track.last, track.first))
        for track in ended:
            del self.active[track.key]
        ended = [track for track in ended if track.samples > 0]
        changed: dict[str, Journey] = {}
        appearances = []
        for track in ended:
            journey = self.link(track, now, ended) if self.ready else None
            if journey is not None:
                changed[journey.id] = journey
            vector = track.vector()
            if vector is not None:
                self.learn(vector)
            self.finished.append(track)
            appearances.append(track.as_dict())
        self.prune(now)
        return [journey.as_dict() for journey in changed.values()], appearances

    def usable(self, track: TrackAppearance) -> bool:
        """Tell whether a track has enough samples and a vector to link.

        Args:
            track: The track.

        Returns:
            True when it can link.
        """
        return track.samples >= self.settings.min_samples and track.vector() is not None

    def candidates(self, track: TrackAppearance) -> list[TrackAppearance]:
        """Return the finalized tracks a track may continue.

        Args:
            track: The track being finalized.

        Returns:
            Finalized usable tracks the track may continue by time and view.
        """
        window = self.settings.window_seconds
        return [
            other
            for other in self.finished
            if other is not track and self.usable(other) and may_continue(other, track, window)
        ]

    def best_later(self, earlier: TrackAppearance, pool: Iterable[TrackAppearance]) -> TrackAppearance | None:
        """Return the track most similar to an earlier one among those that may continue it.

        Args:
            earlier: The earlier track.
            pool: Tracks to consider: finalized, being finalized and live.

        Returns:
            The most similar continuation, or None.
        """
        window = self.settings.window_seconds
        best, best_score = None, float("-inf")
        for later in pool:
            if later is earlier or not self.usable(later) or not may_continue(earlier, later, window):
                continue
            score = self.similarity(earlier, later)
            if score is not None and score > best_score:
                best, best_score = later, score
        return best

    def link(self, track: TrackAppearance, now: float, batch: list[TrackAppearance] | None = None) -> Journey | None:
        """Link a finalized track to the journey it most likely continues.

        Args:
            track: The track.
            now: Current time.
            batch: Tracks finalized in the same tick, which compete for the same earlier tracks.

        Returns:
            The journey the track joined, or None when it stays alone.
        """
        if not self.usable(track):
            return None
        groups: dict[str, list[tuple[float, TrackAppearance]]] = {}
        for other in self.candidates(track):
            journey = self.journeys.get(other.journey) if other.journey else None
            if journey is not None and journey.clashes(track):
                continue
            score = self.similarity(track, other)
            if score is None:
                continue
            group = other.journey or f"track:{other.view}:{other.track}"
            groups.setdefault(group, []).append((score, other))
        if not groups:
            return None
        ranked = sorted(groups.values(), key=lambda members: max(score for score, _ in members), reverse=True)
        best = max(score for score, _ in ranked[0])
        second = max(score for score, _ in ranked[1]) if len(ranked) > 1 else -1.0
        if best < self.settings.threshold or best - second < self.settings.margin:
            return None
        pool = [*self.finished, *(batch or []), *self.active.values()]
        for score, member in sorted(ranked[0], key=lambda item: item[0], reverse=True):
            if score < self.settings.threshold:
                break
            if self.best_later(member, pool) is not track:
                continue
            journey = self.journeys.get(member.journey) if member.journey else None
            if journey is None:
                journey = Journey(str(uuid.uuid4()))
                journey.add(member, None, now)
                member.journey = journey.id
                self.journeys[journey.id] = journey
            journey.add(track, score, now)
            track.journey = journey.id
            return journey
        return None

    def prune(self, now: float) -> None:
        """Forget finalized tracks and journeys older than the keep time.

        Args:
            now: Current time.
        """
        limit = now - self.settings.keep_seconds
        self.finished = [track for track in self.finished if track.last >= limit]
        self.journeys = {
            key: journey for key, journey in self.journeys.items() if any(step.end >= limit for step in journey.steps)
        }

    def journey_of(self, view: str, track: int) -> str | None:
        """Return the journey a track belongs to.

        Args:
            view: View id.
            track: Tracker id.

        Returns:
            The journey id, or None while the track is live or unlinked.
        """
        for item in self.finished:
            if item.view == view and item.track == track:
                return item.journey
        return None

    def find(self, vector: np.ndarray, since: float, limit: int = 10) -> list[dict]:
        """Find the finalized tracks that look most like an appearance, by centred similarity.

        Args:
            vector: The appearance to look for.
            since: Only tracks that ended at or after this time.
            limit: Most results returned.

        Returns:
            Matches, most similar first, with view, camera, track, times, similarity and journey.
        """
        query = self.centred(normalize(vector))
        if query is None:
            return []
        scored = []
        for track in self.finished:
            other = self.centred(track.vector())
            if track.last < since or other is None or other.shape != query.shape:
                continue
            scored.append((float(np.dot(query, other)), track))
        scored.sort(key=lambda item: item[0], reverse=True)
        return [
            {
                "view": track.view,
                "camera": track.camera,
                "track": track.track,
                "start": round(track.first, 3),
                "end": round(track.last, 3),
                "similarity": round(similarity, 4),
                "journey": track.journey,
            }
            for similarity, track in scored[:limit]
        ]

    def status(self) -> dict:
        """Return counts for the status endpoint.

        Returns:
            Live tracks, finalized tracks, journeys in memory, tracks the running mean has seen and whether linking
            is on.
        """
        return {
            "active": len(self.active),
            "finished": len(self.finished),
            "journeys": len(self.journeys),
            "mean_tracks": self.mean_tracks,
            "linking": self.ready,
        }
