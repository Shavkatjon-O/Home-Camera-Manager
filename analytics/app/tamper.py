"""Picture helpers shared by the tamper guard and scene registration: lens bands, gradients and correlation.

Both compare small grey keyframe pictures by the structure of their gradients, which survives the day and night
switch, rather than by their pixel values. The tamper guard itself is app.tampering.
"""

from __future__ import annotations

import numpy as np


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
