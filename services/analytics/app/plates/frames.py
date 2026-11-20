"""Full-resolution pictures of a vehicle cut from a camera's recording buffer.

The pipeline analyses frames scaled to the stream muxer's 1920 by 1080, which shrinks Camera B's plates by a third,
so plates are read from the original stream instead: the buffered segment that holds the moment is decoded once
with ffmpeg, cropped to the lens and to the vehicle box with a margin, and returned as RGB pixels.
"""

from __future__ import annotations

import logging
import subprocess
from pathlib import Path

import numpy as np

from app.recorder import covering, crop_filter, list_segments

logger = logging.getLogger(__name__)

TIMEOUT_SECONDS = 30
MARGIN = 0.15


def parse_ppm(data: bytes) -> np.ndarray | None:
    """Decode a binary PPM picture.

    Args:
        data: The P6 file.

    Returns:
        Height by width by 3 RGB pixels, or None when the data is not a P6 picture.
    """
    fields: list[bytes] = []
    position = 0
    while len(fields) < 4:
        while position < len(data) and data[position : position + 1].isspace():
            position += 1
        if data[position : position + 1] == b"#":
            position = data.find(b"\n", position) + 1
            if position == 0:
                return None
            continue
        end = position
        while end < len(data) and not data[end : end + 1].isspace():
            end += 1
        if end == position:
            return None
        fields.append(data[position:end])
        position = end
    if fields[0] != b"P6" or fields[3] != b"255":
        return None
    width, height = int(fields[1]), int(fields[2])
    pixels = data[position + 1 : position + 1 + width * height * 3]
    if len(pixels) != width * height * 3:
        return None
    return np.frombuffer(pixels, np.uint8).reshape(height, width, 3)


def box_filter(box: tuple[float, float, float, float], margin: float) -> str:
    """Return the ffmpeg crop of a normalized box widened by a margin.

    Args:
        box: Left, top, right and bottom in normalized view coordinates.
        margin: Share of the box size added on every side.

    Returns:
        The crop filter.
    """
    left, top, right, bottom = box
    extra_x, extra_y = (right - left) * margin, (bottom - top) * margin
    left, top = max(0.0, left - extra_x), max(0.0, top - extra_y)
    right, bottom = min(1.0, right + extra_x), min(1.0, bottom + extra_y)
    return f"crop=iw*{right - left:.5f}:ih*{bottom - top:.5f}:iw*{left:.5f}:ih*{top:.5f}"


def picture_at(
    folder: Path,
    at: float,
    lens: int,
    lenses: int,
    box: tuple[float, float, float, float],
    seen: dict[str, float] | None = None,
    margin: float = MARGIN,
) -> np.ndarray | None:
    """Cut the full-resolution picture of a box at a moment from the buffer.

    Args:
        folder: The camera's buffer folder.
        at: Wall clock time of the frame.
        lens: Lens band, 0 for the whole frame.
        lenses: Bands in the frame.
        box: Box in normalized view coordinates.
        seen: Times the recorder saw each segment file appear.
        margin: Share of the box size added on every side.

    Returns:
        RGB pixels, or None when the buffer does not hold the moment or ffmpeg fails.
    """
    segments = covering(list_segments(folder, seen), at - 0.01, at + 0.01)
    if not segments:
        return None
    segment = segments[0]
    filters = crop_filter(lens, lenses) + [box_filter(box, margin)]
    command = ["ffmpeg", "-nostdin", "-hide_banner", "-loglevel", "error", "-i", str(segment.path)]
    command += ["-ss", f"{max(0.0, at - segment.start):.3f}", "-frames:v", "1", "-vf", ",".join(filters)]
    command += ["-f", "image2pipe", "-c:v", "ppm", "-pix_fmt", "rgb24", "pipe:1"]
    try:
        result = subprocess.run(command, capture_output=True, timeout=TIMEOUT_SECONDS, check=False)
    except (OSError, subprocess.SubprocessError) as exc:
        logger.warning("Cutting a vehicle picture failed: %s", exc)
        return None
    if result.returncode != 0:
        return None
    return parse_ppm(result.stdout)
