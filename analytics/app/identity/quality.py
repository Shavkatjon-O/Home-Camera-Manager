"""Face quality: how useful one sighting of a face is for recognition.

Four signals combine into one score from 0 to 1: the face's size, how frontal it is judged from its landmarks, how
sharp the aligned face is, and the detector's confidence. Each signal is scaled so that 1 means good enough, and the
score is their weighted geometric mean, so one poor signal pulls the whole score down.
"""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np

GOOD_SIZE = 96.0
SHARPNESS_HALF = 60.0
GREY_CHROMA = 6.0

WEIGHTS = {"size": 1.0, "frontal": 1.5, "sharpness": 1.0, "score": 0.5}


@dataclass(frozen=True)
class Quality:
    """Quality signals of one face.

    Attributes:
        size: Size signal from 0 to 1.
        frontal: Frontality signal from 0 to 1.
        sharpness: Sharpness signal from 0 to 1.
        score: Detection score from 0 to 1.
        value: The combined score from 0 to 1.
    """

    size: float
    frontal: float
    sharpness: float
    score: float
    value: float


def size_signal(height: float, smallest: float) -> float:
    """Scale a face height to a signal.

    Args:
        height: Face box height in pixels.
        smallest: Height at which the signal starts above zero.

    Returns:
        0 at or below the smallest height, rising to 1 at GOOD_SIZE pixels.
    """
    if height <= smallest:
        return 0.0
    return float(min(1.0, (height - smallest) / max(GOOD_SIZE - smallest, 1.0)))


def frontality(landmarks: np.ndarray) -> float:
    """Judge from the five landmarks how directly the face looks at the camera.

    A turned head moves the nose tip towards one eye and one mouth corner, and a tilted head moves it towards the
    eyes or the mouth. Roll does not count, because alignment removes it.

    Args:
        landmarks: Eyes, nose tip and mouth corners, shape 5 by 2.

    Returns:
        1 for a frontal face, falling towards 0 for profiles and strong tilts.
    """
    points = np.asarray(landmarks, dtype=np.float64)
    left_eye, right_eye, nose, left_mouth, right_mouth = points
    axis = right_eye - left_eye
    width = float(np.hypot(*axis))
    if width < 1e-6:
        return 0.0
    unit = axis / width
    normal = np.array([-unit[1], unit[0]])
    eye_centre = (left_eye + right_eye) / 2
    mouth_centre = (left_mouth + right_mouth) / 2
    nose_offset = float(np.dot(nose - eye_centre, unit)) / width
    mouth_offset = float(np.dot(mouth_centre - eye_centre, unit)) / width
    yaw = abs(nose_offset - mouth_offset / 2) * 2
    depth = float(np.dot(mouth_centre - eye_centre, normal))
    if depth <= 1e-6:
        return 0.0
    pitch_position = float(np.dot(nose - eye_centre, normal)) / depth
    pitch = abs(pitch_position - 0.5) * 2
    return float(np.clip(1.0 - max(0.0, yaw - 0.1) * 1.4 - max(0.0, pitch - 0.25) * 1.2, 0.0, 1.0))


def sharpness(aligned: np.ndarray) -> float:
    """Measure how sharp an aligned face is.

    Args:
        aligned: Aligned face, 112 by 112 by 3, uint8.

    Returns:
        The variance of the Laplacian over the face's centre, mapped to 0 to 1.
    """
    grey = aligned.astype(np.float32).mean(axis=2)[16:-16, 16:-16]
    laplacian = grey[1:-1, :-2] + grey[1:-1, 2:] + grey[:-2, 1:-1] + grey[2:, 1:-1] - 4 * grey[1:-1, 1:-1]
    variance = float(laplacian.var())
    return variance / (variance + SHARPNESS_HALF)


def is_grey(aligned: np.ndarray) -> bool:
    """Tell whether a face was seen in night vision, which cameras deliver without colour.

    Args:
        aligned: Aligned face, 112 by 112 by 3, uint8.

    Returns:
        True when the face carries almost no colour.
    """
    pixels = aligned.astype(np.float32)
    chroma = np.abs(pixels - pixels.mean(axis=2, keepdims=True)).mean()
    return float(chroma) < GREY_CHROMA


def combine(size: float, frontal: float, sharp: float, score: float) -> float:
    """Combine the signals into one score.

    Args:
        size: Size signal.
        frontal: Frontality signal.
        sharp: Sharpness signal.
        score: Detection score.

    Returns:
        The weighted geometric mean, 0 when any signal is 0.
    """
    signals = {"size": size, "frontal": frontal, "sharpness": sharp, "score": score}
    if min(signals.values()) <= 0.0:
        return 0.0
    total = sum(WEIGHTS.values())
    return float(np.exp(sum(WEIGHTS[name] * np.log(value) for name, value in signals.items()) / total))


def assess(height: float, landmarks: np.ndarray, aligned: np.ndarray, score: float, smallest: float) -> Quality:
    """Assess one face.

    Args:
        height: Face box height in pixels.
        landmarks: Its five landmarks.
        aligned: The aligned face.
        score: Detection score.
        smallest: Smallest useful face height in pixels.

    Returns:
        The quality signals and their combination.
    """
    size = size_signal(height, smallest)
    frontal = frontality(landmarks)
    sharp = sharpness(aligned)
    return Quality(size, frontal, sharp, score, combine(size, frontal, sharp, score))
