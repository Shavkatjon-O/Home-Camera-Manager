"""Plate boxes from the plate detector's grid outputs.

LPDNet is a DetectNet_v2 network: for every cell of a 16-pixel grid over its 640 by 480 input it outputs a coverage
score and four box distances from the cell centre, scaled by 35. Cells above the threshold give candidate boxes,
which non-maximum suppression thins to one box per plate. This is the decoding nvinfer's built-in parser applies.
"""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np

from app.rules.geometry import iou

STRIDE = 16
BOX_NORM = 35.0
CENTRE_OFFSET = 0.5
COVERAGE_OUTPUT = "output_cov/Sigmoid:0"
BOX_OUTPUT = "output_bbox/BiasAdd:0"


@dataclass(frozen=True)
class PlateBox:
    """A plate found in the detector input.

    Attributes:
        left: Left edge in input pixels.
        top: Top edge in input pixels.
        right: Right edge in input pixels.
        bottom: Bottom edge in input pixels.
        score: Coverage score.
    """

    left: float
    top: float
    right: float
    bottom: float
    score: float

    def scaled(self, x: float, y: float) -> PlateBox:
        """Return the box scaled from the detector input to another picture.

        Args:
            x: Horizontal scale.
            y: Vertical scale.

        Returns:
            The scaled box.
        """
        return PlateBox(self.left * x, self.top * y, self.right * x, self.bottom * y, self.score)


def decode(coverage: np.ndarray, boxes: np.ndarray, threshold: float, nms_iou: float = 0.3) -> list[PlateBox]:
    """Decode one picture's detector outputs.

    Args:
        coverage: 1 by rows by columns coverage scores.
        boxes: 4 by rows by columns box distances.
        threshold: Lowest coverage kept.
        nms_iou: Overlap above which the weaker of two boxes is dropped.

    Returns:
        Plate boxes in detector input pixels, best first.
    """
    scores = coverage.reshape(coverage.shape[-2:])
    rows, columns = np.nonzero(scores >= threshold)
    candidates = []
    for row, column in zip(rows, columns):
        centre_x = (column * STRIDE + CENTRE_OFFSET) / BOX_NORM
        centre_y = (row * STRIDE + CENTRE_OFFSET) / BOX_NORM
        left = (boxes[0, row, column] - centre_x) * -BOX_NORM
        top = (boxes[1, row, column] - centre_y) * -BOX_NORM
        right = (boxes[2, row, column] + centre_x) * BOX_NORM
        bottom = (boxes[3, row, column] + centre_y) * BOX_NORM
        if right > left and bottom > top:
            candidates.append(
                PlateBox(float(left), float(top), float(right), float(bottom), float(scores[row, column]))
            )
    candidates.sort(key=lambda item: item.score, reverse=True)
    kept: list[PlateBox] = []
    for candidate in candidates:
        box = (candidate.left, candidate.top, candidate.right, candidate.bottom)
        if all(iou(box, (item.left, item.top, item.right, item.bottom)) <= nms_iou for item in kept):
            kept.append(candidate)
    return kept
