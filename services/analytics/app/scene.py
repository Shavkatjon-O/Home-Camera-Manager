"""Scene registration for lenses that move: are zones still on the scene they were drawn on.

A zone or line drawn on a moving lens stores the snapshot it was drawn on. Every keyframe of the view is compared
with that snapshot by the correlation of their gradient maps, which ignores day and night changes in brightness. A
zone is suspended after two keyframes in a row that do not match and resumed after two that match again.
"""

from __future__ import annotations

import logging
import subprocess
from dataclasses import dataclass
from pathlib import Path

import numpy as np

from app.recorder import THUMB_HEIGHT, THUMB_WIDTH
from app.tamper import correlation, gradients

logger = logging.getLogger(__name__)

SUSPEND_BELOW = 0.45
RESUME_ABOVE = 0.55
STREAK = 2


def load_reference(path: Path) -> np.ndarray | None:
    """Decode a reference snapshot to the gradient map of its keyframe sized grey picture.

    Args:
        path: The JPEG.

    Returns:
        The gradient map, or None when the file cannot be decoded.
    """
    command = ["ffmpeg", "-nostdin", "-hide_banner", "-loglevel", "error", "-i", str(path)]
    command += ["-vf", f"scale={THUMB_WIDTH}:{THUMB_HEIGHT}:flags=area,format=gray", "-f", "rawvideo", "pipe:1"]
    try:
        result = subprocess.run(command, capture_output=True, timeout=20, check=False)
    except (OSError, subprocess.SubprocessError) as exc:
        logger.warning("Reading the reference %s failed: %s", path.name, exc)
        return None
    if result.returncode != 0 or len(result.stdout) != THUMB_WIDTH * THUMB_HEIGHT:
        logger.warning("The reference %s could not be decoded", path.name)
        return None
    image = np.frombuffer(result.stdout, dtype=np.uint8).reshape(THUMB_HEIGHT, THUMB_WIDTH).astype(np.float32)
    return gradients(image)


@dataclass
class Match:
    """Match state of one reference in one view.

    Attributes:
        matched: Whether the view currently shows the reference scene.
        score: Latest correlation.
        streak: Consecutive keyframes that disagreed with the current state.
    """

    matched: bool = True
    score: float | None = None
    streak: int = 0


class SceneMatcher:
    """Keeps the match state of every reference snapshot per view.

    Attributes:
        root: Events folder the reference paths are relative to.
        references: Decoded references by path.
        states: Match state by view id and reference path.
    """

    def __init__(self, root: Path):
        """Create the matcher.

        Args:
            root: Events folder the reference paths are relative to.
        """
        self.root = root
        self.references: dict[str, np.ndarray | None] = {}
        self.states: dict[tuple[str, str], Match] = {}

    def reference(self, relative: str) -> np.ndarray | None:
        """Return a decoded reference, decoding it on first use.

        Args:
            relative: Path relative to the events folder.

        Returns:
            The gradient map, or None when it is missing or broken.
        """
        if relative not in self.references:
            path = (self.root / relative).resolve()
            if self.root.resolve() not in path.parents or not path.is_file():
                logger.warning("Reference %s is missing", relative)
                self.references[relative] = None
            else:
                self.references[relative] = load_reference(path)
        return self.references[relative]

    def update(self, view: str, band: np.ndarray, relatives: set[str]) -> bool:
        """Compare a keyframe of a view with each of its references.

        Args:
            view: View id.
            band: Grey keyframe band of the view as float32.
            relatives: References of the view's zones and lines.

        Returns:
            True when any reference changed between matched and not matched.
        """
        edges = gradients(band)
        changed = False
        for relative in relatives:
            reference = self.reference(relative)
            state = self.states.setdefault((view, relative), Match())
            if reference is None or reference.shape != edges.shape:
                continue
            state.score = round(correlation(edges, reference), 3)
            disagrees = state.score < SUSPEND_BELOW if state.matched else state.score >= RESUME_ABOVE
            state.streak = state.streak + 1 if disagrees else 0
            if state.streak >= STREAK:
                state.matched = not state.matched
                state.streak = 0
                changed = True
                logger.info(
                    "View %s %s its reference scene (score %.2f)",
                    view,
                    "matches" if state.matched else "no longer matches",
                    state.score,
                )
        return changed

    def matched(self, view: str, relative: str) -> bool:
        """Tell whether a view currently matches a reference.

        Args:
            view: View id.
            relative: Reference path.

        Returns:
            True until two keyframes in a row disagree with the reference.
        """
        state = self.states.get((view, relative))
        return state is None or state.matched

    def report(self, view: str) -> dict:
        """Return the match state of a view's references.

        Args:
            view: View id.

        Returns:
            Reference path to whether it matches and the latest score.
        """
        return {
            relative: {"matched": state.matched, "score": state.score}
            for (owner, relative), state in self.states.items()
            if owner == view
        }
