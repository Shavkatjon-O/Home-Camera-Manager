"""Face alignment: a similarity transform from five landmarks to the standard 112 by 112 template, and crops.

The embedder was trained on faces warped so that the eyes, the nose tip and the mouth corners land on fixed points.
The transform is the least squares similarity (rotation, uniform scale and shift, no reflection) that maps the
detected landmarks onto those points, and the picture is resampled through its inverse with bilinear interpolation.
"""

from __future__ import annotations

import numpy as np

ALIGNED_SIZE = 112
CROP_SIZE = 160
CROP_MARGIN = 0.5

TEMPLATE = np.array(
    [
        [38.2946, 51.6963],
        [73.5318, 51.5014],
        [56.0252, 71.7366],
        [41.5493, 92.3655],
        [70.7299, 92.2041],
    ],
    dtype=np.float32,
)


def similarity(source: np.ndarray, target: np.ndarray) -> np.ndarray:
    """Estimate the similarity transform that maps source points onto target points.

    Args:
        source: Points, shape n by 2.
        target: Corresponding points, shape n by 2.

    Returns:
        The 2 by 3 matrix taking a source point (x, y, 1) to its target point.
    """
    source = np.asarray(source, dtype=np.float64)
    target = np.asarray(target, dtype=np.float64)
    source_mean, target_mean = source.mean(axis=0), target.mean(axis=0)
    source_centred, target_centred = source - source_mean, target - target_mean
    covariance = target_centred.T @ source_centred / len(source)
    left, singular, right = np.linalg.svd(covariance)
    sign = np.eye(2)
    if np.linalg.det(left) * np.linalg.det(right) < 0:
        sign[1, 1] = -1
    rotation = left @ sign @ right
    variance = (source_centred**2).sum() / len(source)
    scale = float((singular * np.diag(sign)).sum() / max(variance, 1e-12))
    matrix = np.zeros((2, 3))
    matrix[:, :2] = scale * rotation
    matrix[:, 2] = target_mean - scale * rotation @ source_mean
    return matrix


def warp(image: np.ndarray, matrix: np.ndarray, size: int) -> np.ndarray:
    """Resample a picture through a similarity transform into a square output.

    Args:
        image: Picture, height by width by channels, uint8.
        matrix: 2 by 3 matrix taking picture points to output points.
        size: Output side in pixels.

    Returns:
        The output, size by size by channels, uint8; points outside the picture are black.
    """
    full = np.vstack([matrix, [0.0, 0.0, 1.0]])
    inverse = np.linalg.inv(full)[:2]
    ys, xs = np.mgrid[:size, :size].astype(np.float64)
    source_x = inverse[0, 0] * xs + inverse[0, 1] * ys + inverse[0, 2]
    source_y = inverse[1, 0] * xs + inverse[1, 1] * ys + inverse[1, 2]
    height, width = image.shape[:2]
    left = np.floor(source_x).astype(np.int64)
    top = np.floor(source_y).astype(np.int64)
    fx = (source_x - left)[..., None]
    fy = (source_y - top)[..., None]
    inside = (left >= 0) & (top >= 0) & (left + 1 < width) & (top + 1 < height)
    left = np.clip(left, 0, width - 2)
    top = np.clip(top, 0, height - 2)
    pixels = image.astype(np.float32)
    value = (
        pixels[top, left] * (1 - fx) * (1 - fy)
        + pixels[top, left + 1] * fx * (1 - fy)
        + pixels[top + 1, left] * (1 - fx) * fy
        + pixels[top + 1, left + 1] * fx * fy
    )
    value[~inside] = 0.0
    return np.clip(value + 0.5, 0, 255).astype(np.uint8)


def align(image: np.ndarray, landmarks: np.ndarray, size: int = ALIGNED_SIZE) -> np.ndarray:
    """Warp a face onto the embedder's template.

    Args:
        image: Picture holding the face, height by width by 3, uint8.
        landmarks: The face's five landmarks in picture pixels.
        size: Output side; the template is scaled when it is not 112.

    Returns:
        The aligned face, size by size by 3.
    """
    target = TEMPLATE * (size / ALIGNED_SIZE)
    return warp(image, similarity(landmarks, target), size)


def crop(image: np.ndarray, box: tuple[float, float, float, float], size: int = CROP_SIZE) -> np.ndarray:
    """Cut a square, upright crop around a face for display.

    Args:
        image: Picture holding the face, height by width by 3, uint8.
        box: Face box in picture pixels.
        size: Output side in pixels.

    Returns:
        The crop, size by size by 3, with a margin around the face.
    """
    x1, y1, x2, y2 = box
    side = max(x2 - x1, y2 - y1) * (1 + 2 * CROP_MARGIN)
    centre_x, centre_y = (x1 + x2) / 2, (y1 + y2) / 2
    scale = size / max(side, 1.0)
    matrix = np.array(
        [[scale, 0.0, size / 2 - scale * centre_x], [0.0, scale, size / 2 - scale * centre_y]], dtype=np.float64
    )
    return warp(image, matrix, size)
