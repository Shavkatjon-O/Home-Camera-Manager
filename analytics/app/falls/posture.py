"""Pose samples and the posture features fall detection reads from them.

Keypoints follow the COCO order of 17 body points in normalized view coordinates. Normalized x and y have different
units on a 16 by 9 view, so every distance and angle first scales x by the view's aspect ratio, which measures them
in units of the view height.
"""

from __future__ import annotations

import math
from dataclasses import dataclass

import numpy as np

from app.rules.model import Box

KEYPOINTS = 17
DEFAULT_ASPECT = 16 / 9

NOSE = 0
LEFT_SHOULDER = 5
RIGHT_SHOULDER = 6
LEFT_HIP = 11
RIGHT_HIP = 12

SHOULDERS = (LEFT_SHOULDER, RIGHT_SHOULDER)
HIPS = (LEFT_HIP, RIGHT_HIP)

MIN_SHARED_POINTS = 4


@dataclass(frozen=True)
class PoseSample:
    """The keypoints of one tracked person in one frame.

    Attributes:
        view: View id.
        track: Tracker id.
        at: Frame time.
        box: Person box in normalized view coordinates.
        keypoints: Array of shape (17, 3) holding x, y and score per COCO keypoint, in normalized view coordinates.
        aspect: Width over height of the view in pixels.
    """

    view: str
    track: int
    at: float
    box: Box
    keypoints: np.ndarray
    aspect: float = DEFAULT_ASPECT


@dataclass(frozen=True)
class Posture:
    """Posture features of one sample, in units of the view height.

    Attributes:
        at: Frame time.
        angle: Torso angle from vertical in degrees, from 0 upright to 90 horizontal; None without a shoulder and a
            hip.
        aspect: Box width over box height in pixels.
        hip_y: Height of the hip centre in the view, the box centre when no hip was found.
        height: Box height.
        centre: Box centre with x scaled to view height units.
        points: Keypoint positions scaled to view height units, NaN where the score is too low.
    """

    at: float
    angle: float | None
    aspect: float
    hip_y: float
    height: float
    centre: tuple[float, float]
    points: np.ndarray


def midpoint(points: np.ndarray, indices: tuple[int, ...]) -> tuple[float, float] | None:
    """Return the mean of the valid points among some indices.

    Args:
        points: Scaled keypoint positions, NaN where invalid.
        indices: Keypoints to average.

    Returns:
        The mean point, or None when none of them is valid.
    """
    chosen = points[list(indices)]
    valid = chosen[~np.isnan(chosen[:, 0])]
    if not len(valid):
        return None
    return (float(valid[:, 0].mean()), float(valid[:, 1].mean()))


def posture(sample: PoseSample, min_score: float) -> Posture:
    """Compute the posture features of a sample.

    Args:
        sample: The pose sample.
        min_score: Lowest keypoint score that counts.

    Returns:
        The posture.
    """
    keypoints = np.asarray(sample.keypoints, dtype=np.float32).reshape(KEYPOINTS, 3)
    points = np.stack([keypoints[:, 0] * sample.aspect, keypoints[:, 1]], axis=1).astype(np.float32)
    points[keypoints[:, 2] < min_score] = np.nan
    box = sample.box
    width = max(0.0, box.right - box.left) * sample.aspect
    height = max(1e-6, box.bottom - box.top)
    shoulders = midpoint(points, SHOULDERS)
    hips = midpoint(points, HIPS)
    angle = None
    if shoulders is not None and hips is not None:
        dx, dy = shoulders[0] - hips[0], shoulders[1] - hips[1]
        if dx or dy:
            angle = math.degrees(math.atan2(abs(dx), abs(dy)))
    centre_x, centre_y = box.centre
    return Posture(
        at=sample.at,
        angle=angle,
        aspect=width / height,
        hip_y=hips[1] if hips is not None else centre_y,
        height=height,
        centre=(centre_x * sample.aspect, centre_y),
        points=points,
    )


def motion(first: Posture, second: Posture, scale: float) -> float:
    """Return how much a person moved between two postures, relative to their standing height.

    Args:
        first: Earlier posture.
        second: Later posture.
        scale: Standing height of the person in view height units.

    Returns:
        Mean keypoint displacement over the scale when enough keypoints are valid in both, otherwise the box
        centre displacement plus the change of box height over the scale.
    """
    scale = max(scale, 1e-6)
    shared = ~np.isnan(first.points[:, 0]) & ~np.isnan(second.points[:, 0])
    if int(shared.sum()) >= MIN_SHARED_POINTS:
        moved = np.linalg.norm(first.points[shared] - second.points[shared], axis=1)
        return float(moved.mean()) / scale
    shift = math.hypot(first.centre[0] - second.centre[0], first.centre[1] - second.centre[1])
    return (shift + abs(first.height - second.height)) / scale
