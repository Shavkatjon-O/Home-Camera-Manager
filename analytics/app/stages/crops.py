"""Cutting, resizing and normalizing object crops for the secondary models, in plain numpy.

The secondary models run on crops copied out of the decoded frame, so their preprocessing matches what each model
was trained with exactly: the pose model wants the person box widened by a quarter to its own aspect ratio with
black outside the frame, the re-identification model a stretched person box, and the text recogniser a line of text
scaled to its height and padded on the right.
"""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np

IMAGENET_MEAN = np.array([0.485, 0.456, 0.406], np.float32) * 255.0
IMAGENET_STD = np.array([0.229, 0.224, 0.225], np.float32) * 255.0


@dataclass(frozen=True)
class Region:
    """A rectangle of the frame, possibly reaching past its edges.

    Attributes:
        left: Left edge in frame pixels; may be negative.
        top: Top edge in frame pixels; may be negative.
        width: Width in pixels.
        height: Height in pixels.
    """

    left: float
    top: float
    width: float
    height: float

    def clipped(self, frame_width: int, frame_height: int) -> tuple[int, int, int, int]:
        """Return the part of the region inside the frame.

        Args:
            frame_width: Frame width in pixels.
            frame_height: Frame height in pixels.

        Returns:
            Left, top, width and height in whole pixels, with a width and height of at least one when the region
            touches the frame, otherwise zero.
        """
        left = max(0, int(np.floor(self.left)))
        top = max(0, int(np.floor(self.top)))
        right = min(frame_width, int(np.ceil(self.left + self.width)))
        bottom = min(frame_height, int(np.ceil(self.top + self.height)))
        if right <= left or bottom <= top:
            return left, top, 0, 0
        return left, top, right - left, bottom - top


def widened(box: tuple[float, float, float, float], factor: float, aspect: float) -> Region:
    """Widen a box around its centre and bring it to an aspect ratio, as top-down pose models expect.

    Args:
        box: Left, top, right and bottom in pixels.
        factor: Scale applied to both sides, such as 1.25.
        aspect: Width over height of the result, such as 0.75 for a 192 by 256 input.

    Returns:
        The widened region, which may reach past the frame.
    """
    left, top, right, bottom = box
    width, height = (right - left) * factor, (bottom - top) * factor
    if width > aspect * height:
        height = width / aspect
    else:
        width = height * aspect
    centre_x, centre_y = (left + right) / 2, (top + bottom) / 2
    return Region(centre_x - width / 2, centre_y - height / 2, width, height)


def canvas(pixels: np.ndarray, region: Region, origin: tuple[int, int]) -> np.ndarray:
    """Place copied frame pixels into a black canvas the size of a region.

    Args:
        pixels: The part of the region inside the frame, height by width by 3.
        region: The whole region.
        origin: Frame position of the copied pixels' top left corner.

    Returns:
        The region as height by width by 3 uint8 pixels, black outside the frame.
    """
    height, width = max(1, int(round(region.height))), max(1, int(round(region.width)))
    result = np.zeros((height, width, 3), np.uint8)
    x = int(round(origin[0] - region.left))
    y = int(round(origin[1] - region.top))
    rows, cols = pixels.shape[:2]
    y0, x0 = max(0, y), max(0, x)
    y1, x1 = min(height, y + rows), min(width, x + cols)
    if y1 > y0 and x1 > x0:
        result[y0:y1, x0:x1] = pixels[y0 - y : y1 - y, x0 - x : x1 - x, :3]
    return result


def resize(image: np.ndarray, width: int, height: int) -> np.ndarray:
    """Resize an image with bilinear interpolation, sampling pixel centres as OpenCV does.

    Args:
        image: Height by width by channels array.
        width: Output width.
        height: Output height.

    Returns:
        The resized image as float32.
    """
    source = image.astype(np.float32)
    rows, cols = source.shape[:2]
    ys = np.clip((np.arange(height, dtype=np.float32) + 0.5) * rows / height - 0.5, 0, rows - 1)
    xs = np.clip((np.arange(width, dtype=np.float32) + 0.5) * cols / width - 0.5, 0, cols - 1)
    y0 = np.floor(ys).astype(np.int64)
    x0 = np.floor(xs).astype(np.int64)
    y1 = np.minimum(y0 + 1, rows - 1)
    x1 = np.minimum(x0 + 1, cols - 1)
    wy = (ys - y0)[:, None, None]
    wx = (xs - x0)[None, :, None]
    top = source[y0][:, x0] * (1 - wx) + source[y0][:, x1] * wx
    bottom = source[y1][:, x0] * (1 - wx) + source[y1][:, x1] * wx
    return top * (1 - wy) + bottom * wy


def imagenet(image: np.ndarray) -> np.ndarray:
    """Normalize an RGB image with the ImageNet mean and deviation and move channels first.

    Args:
        image: Height by width by 3 RGB values from 0 to 255.

    Returns:
        A 3 by height by width float32 array.
    """
    return ((image.astype(np.float32) - IMAGENET_MEAN) / IMAGENET_STD).transpose(2, 0, 1)


def text_line(image: np.ndarray, height: int, width: int) -> np.ndarray:
    """Prepare a line of text for the recogniser: scale to the height, pad the width on the right.

    The recogniser was trained on BGR pictures scaled to minus one to one, with zeros as padding.

    Args:
        image: Height by width by 3 RGB pixels of the text line.
        height: Input height of the recogniser.
        width: Input width of the recogniser.

    Returns:
        A 3 by height by width float32 array.
    """
    rows, cols = image.shape[:2]
    scaled_width = int(min(width, max(1, np.ceil(height * cols / max(1, rows)))))
    scaled = resize(image[:, :, ::-1], scaled_width, height)
    result = np.zeros((3, height, width), np.float32)
    result[:, :, :scaled_width] = (scaled / 255.0 - 0.5).transpose(2, 0, 1) / 0.5
    return result


def is_grey(image: np.ndarray, threshold: float = 6.0) -> bool:
    """Tell whether a picture carries no colour, as under infrared night vision.

    Args:
        image: Height by width by 3 RGB pixels.
        threshold: Largest mean channel spread, in pixel values, that still counts as grey.

    Returns:
        True when the channels barely differ.
    """
    pixels = image.reshape(-1, 3).astype(np.float32)
    if not len(pixels):
        return True
    spread = pixels.max(axis=1) - pixels.min(axis=1)
    return float(spread.mean()) < threshold
