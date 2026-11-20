"""Straightening a plate crop into a level line of characters for the recogniser.

Plates seen from a camera above the yard lean by several degrees, and an upright box around a leaning plate takes in
the grille above and below it, which the recogniser reads as letters. The characters' vertical strokes give strong
horizontal gradients while grille bars and plate borders do not, so the crop is sheared by the angle at which the rows
of horizontal gradient bunch up most, and cut to the band of rows the characters fill.
"""

from __future__ import annotations

import numpy as np

ANGLES = tuple(range(-12, 13))
KEEP = 0.35


def offsets(width: int, angle: float) -> np.ndarray:
    """Return the row shift of every column for a shear by an angle around the middle column.

    Args:
        width: Columns of the picture.
        angle: Shear angle in degrees; a line rising to the right is levelled by a negative angle.

    Returns:
        Whole-row shift per column.
    """
    middle = (width - 1) / 2
    return np.round((np.arange(width) - middle) * np.tan(np.radians(angle))).astype(int)


def straighten(crop: np.ndarray, pad: float = 0.2) -> tuple[np.ndarray, float]:
    """Level a plate crop and cut it to the characters' rows.

    Args:
        crop: Height by width by 3 RGB pixels around one plate, taller than the plate.
        pad: Share of the character band's height kept above and below it.

    Returns:
        The levelled band as height by width by 3 pixels, and the angle in degrees the crop was sheared by.
    """
    rows, cols = crop.shape[:2]
    if rows < 4 or cols < 4:
        return crop, 0.0
    grey = crop.astype(np.float32).mean(axis=2)
    strokes = np.abs(np.diff(grey, axis=1))
    margin = int(np.ceil(cols * np.tan(np.radians(max(abs(angle) for angle in ANGLES))) / 2)) + 1
    size = rows + 2 * margin
    best_score, best_angle, best_profile = -1.0, 0.0, None
    for angle in ANGLES:
        shift = offsets(cols - 1, angle)
        target = (np.arange(rows)[:, None] - shift[None, :] + margin).ravel()
        profile = np.bincount(target, weights=strokes.ravel(), minlength=size)[:size]
        score = float((profile**2).sum())
        if score > best_score:
            best_score, best_angle, best_profile = score, float(angle), profile
    shift = offsets(cols, best_angle)
    levelled = np.zeros((size, cols, crop.shape[2]), crop.dtype)
    for column in range(cols):
        start = margin - shift[column]
        levelled[start : start + rows, column] = crop[:, column]
    smooth = np.convolve(best_profile, np.ones(3) / 3, mode="same")
    peak = int(np.argmax(smooth))
    limit = KEEP * smooth[peak]
    top = bottom = peak
    while top > 0 and smooth[top - 1] >= limit:
        top -= 1
    while bottom < size - 1 and smooth[bottom + 1] >= limit:
        bottom += 1
    extra = int(round((bottom - top + 1) * pad))
    return levelled[max(0, top - extra) : min(size, bottom + 1 + extra)], best_angle
