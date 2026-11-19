"""Tamper watch on keyframe thumbnails: covered or blinded lens, lost focus and a moved camera.

Each view keeps a slowly learned reference of its edge structure. A covered lens leaves a dark or flat picture, a
defocused or smeared lens loses most of its edges, and a turned camera keeps edges that no longer line up with the
reference. Day and night switching changes brightness and colour but keeps the structure, so the scene check
compares normalized gradients rather than pixel values. A condition must hold for several keyframes in a row before
it is reported, and the reference stops learning while a condition holds. A moved camera that stays moved for
long becomes the new reference, so a deliberate re-aim ends the condition by itself.
"""

from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np

DARK_MEAN = 12.0
FLAT_STD = 5.0
BLUR_RATIO = 0.3
SCENE_CORRELATION = 0.35
HOLD_SAMPLES = 4
ACCEPT_SAMPLES = 90
WARMUP_SAMPLES = 5
LEARNING_RATE = 0.05


def lens_band(thumbnail: np.ndarray, lens: int, lenses: int) -> np.ndarray:
    """Cut a lens band out of a stacked thumbnail.

    Args:
        thumbnail: Grey thumbnail of the whole frame.
        lens: Lens band counted from 1 at the top, 0 for the whole frame.
        lenses: Bands in the frame.

    Returns:
        The band as float32.
    """
    image = thumbnail.astype(np.float32)
    if not lens or lenses <= 1:
        return image
    band = image.shape[0] // lenses
    return image[band * (lens - 1) : band * lens]


def gradients(image: np.ndarray) -> np.ndarray:
    """Return the gradient magnitude of a grey image.

    Args:
        image: Grey image as float32.

    Returns:
        Gradient magnitude, one pixel smaller in each direction.
    """
    dx = np.abs(np.diff(image, axis=1))[:-1, :]
    dy = np.abs(np.diff(image, axis=0))[:, :-1]
    return dx + dy


def correlation(a: np.ndarray, b: np.ndarray) -> float:
    """Return the normalized correlation of two arrays of the same shape.

    Args:
        a: First array.
        b: Second array.

    Returns:
        A value from -1 to 1, or 1 when either array is constant.
    """
    a = a - a.mean()
    b = b - b.mean()
    norm = float(np.sqrt((a * a).sum() * (b * b).sum()))
    if norm == 0:
        return 1.0
    return float((a * b).sum() / norm)


@dataclass
class TamperWatch:
    """Tamper state of one view.

    Attributes:
        reference: Learned gradient map of the scene.
        reference_energy: Mean gradient of the reference.
        samples: Keyframes seen.
        streaks: Consecutive keyframes each condition held.
        active: Conditions currently reported.
        last: Measurements of the latest keyframe.
    """

    reference: np.ndarray | None = None
    reference_energy: float = 0.0
    samples: int = 0
    streaks: dict[str, int] = field(default_factory=lambda: {"covered": 0, "blurred": 0, "moved": 0})
    active: set[str] = field(default_factory=set)
    last: dict[str, float] = field(default_factory=dict)

    def update(self, image: np.ndarray) -> tuple[set[str], set[str]]:
        """Fold one keyframe in.

        Args:
            image: Grey band of the view as float32.

        Returns:
            Conditions that started and conditions that ended with this keyframe.
        """
        self.samples += 1
        mean, std = float(image.mean()), float(image.std())
        edges = gradients(image)
        energy = float(edges.mean())
        conditions = {"covered": mean < DARK_MEAN or std < FLAT_STD}
        if self.reference is None:
            self.reference, self.reference_energy = edges, energy
            scene = 1.0
        else:
            scene = correlation(edges, self.reference)
            ready = self.samples > WARMUP_SAMPLES and self.reference_energy > 0
            conditions["blurred"] = ready and not conditions["covered"] and energy < BLUR_RATIO * self.reference_energy
            conditions["moved"] = ready and not conditions["covered"] and scene < SCENE_CORRELATION
        self.last = {"mean": round(mean, 1), "std": round(std, 1), "edges": round(energy, 2), "scene": round(scene, 3)}
        started, ended = set(), set()
        for name in self.streaks:
            if conditions.get(name):
                self.streaks[name] += 1
                if self.streaks[name] >= HOLD_SAMPLES and name not in self.active:
                    self.active.add(name)
                    started.add(name)
            else:
                self.streaks[name] = 0
                if name in self.active:
                    self.active.discard(name)
                    ended.add(name)
        if self.streaks["moved"] >= ACCEPT_SAMPLES:
            self.rebase()
            ended.add("moved")
            return started, ended
        if not any(conditions.values()) and self.reference is not None:
            self.reference = (1 - LEARNING_RATE) * self.reference + LEARNING_RATE * edges
            self.reference_energy = (1 - LEARNING_RATE) * self.reference_energy + LEARNING_RATE * energy
        return started, ended

    def rebase(self) -> None:
        """Forget the reference, for instance after the owner moved a camera on purpose."""
        self.reference = None
        self.samples = 0
        self.active.clear()
        self.streaks = {name: 0 for name in self.streaks}
