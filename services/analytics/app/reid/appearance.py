"""Appearance samples of person crops and their average per track."""

from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np

from app.rules.model import Box

MIN_HEIGHT_PX = 48.0
FULL_HEIGHT_PX = 160.0
MIN_WEIGHT = 0.1


def normalize(vector: np.ndarray) -> np.ndarray | None:
    """Scale a vector to unit length.

    Args:
        vector: The vector.

    Returns:
        The unit vector as float32, or None when the vector is zero or not finite.
    """
    vector = np.asarray(vector, dtype=np.float32).reshape(-1)
    norm = float(np.linalg.norm(vector))
    if not np.isfinite(norm) or norm == 0.0:
        return None
    return vector / norm


@dataclass(frozen=True)
class AppearanceSample:
    """One embedded person crop.

    Attributes:
        view: View id.
        camera: Camera id.
        track: Tracker id within the view.
        at: Frame time.
        box: Person box in normalized view coordinates.
        embedding: Appearance embedding; normalized when folded into a track.
        height_px: Height of the crop in muxer pixels, the main sign of its quality.
    """

    view: str
    camera: str
    track: int
    at: float
    box: Box
    embedding: np.ndarray
    height_px: float


def sample_weight(height_px: float, min_height: float = MIN_HEIGHT_PX, full_height: float = FULL_HEIGHT_PX) -> float:
    """Return how much a crop counts in its track's average.

    Args:
        height_px: Crop height in muxer pixels.
        min_height: Crops below this height do not count at all.
        full_height: Crops at or above this height count fully.

    Returns:
        0 for crops below the minimum, otherwise a weight from a small floor up to 1.
    """
    if height_px < min_height:
        return 0.0
    if full_height <= min_height:
        return 1.0
    return float(min(1.0, max(MIN_WEIGHT, (height_px - min_height) / (full_height - min_height))))


@dataclass
class TrackAppearance:
    """The average appearance of one track.

    Attributes:
        view: View id.
        camera: Camera id.
        track: Tracker id.
        first: Time of the first counted sample.
        last: Time of the latest sample, counted or not.
        total: Sum of the weighted unit embeddings.
        weight: Sum of the weights.
        samples: Number of counted samples.
        box: Box of the largest crop.
        best_height: Height of the largest crop.
        journey: Journey id once the track is linked.
    """

    view: str
    camera: str
    track: int
    first: float
    last: float
    total: np.ndarray | None = None
    weight: float = 0.0
    samples: int = 0
    box: Box = field(default_factory=lambda: Box(0.0, 0.0, 0.0, 0.0))
    best_height: float = 0.0
    journey: str | None = None

    @property
    def key(self) -> tuple[str, int]:
        """tuple[str, int]: The view and tracker id."""
        return (self.view, self.track)

    def add(
        self, sample: AppearanceSample, min_height: float = MIN_HEIGHT_PX, full_height: float = FULL_HEIGHT_PX
    ) -> bool:
        """Fold one sample in.

        Args:
            sample: The sample, of this track.
            min_height: Crops below this height are skipped.
            full_height: Crops at or above this height count fully.

        Returns:
            True when the sample counted.
        """
        self.last = max(self.last, sample.at)
        weight = sample_weight(sample.height_px, min_height, full_height)
        unit = normalize(sample.embedding) if weight > 0 else None
        if unit is None:
            return False
        if self.total is None:
            self.total = np.zeros_like(unit)
            self.first = sample.at
        if unit.shape != self.total.shape:
            return False
        self.total = self.total + weight * unit
        self.weight += weight
        self.samples += 1
        if sample.height_px >= self.best_height:
            self.best_height = sample.height_px
            self.box = sample.box
        return True

    def vector(self) -> np.ndarray | None:
        """Return the track's average appearance.

        Returns:
            The unit vector, or None before any sample counted.
        """
        if self.total is None:
            return None
        return normalize(self.total)

    def overlaps(self, other: TrackAppearance) -> bool:
        """Tell whether two tracks were seen at the same time.

        Args:
            other: The other track.

        Returns:
            True when their time spans overlap.
        """
        return self.first <= other.last and other.first <= self.last

    def as_dict(self) -> dict:
        """Return the track for the backend.

        Returns:
            View, camera, track, times, the averaged embedding rounded to 5 decimals, the sample count, the best
            box and the journey id.
        """
        vector = self.vector()
        return {
            "view": self.view,
            "camera": self.camera,
            "track": self.track,
            "start": round(self.first, 3),
            "end": round(self.last, 3),
            "embedding": [round(float(value), 5) for value in vector] if vector is not None else [],
            "samples": self.samples,
            "box": self.box.rounded(),
            "journey": self.journey,
        }
