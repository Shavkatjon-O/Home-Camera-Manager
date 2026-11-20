"""Plate boxes from PaddleOCR's DB text detector, the permissively licensed plate finder.

The DB detector outputs, for every input pixel, the probability that it belongs to text. Pixels above a threshold
form connected regions; a region whose mean probability is high enough becomes a box, grown by the detector's own
unclip rule, because the probability map marks a shrunk core of each text line. A number plate is a short line of
large characters, so boxes are ranked by their score and by how close their shape is to a plate's.
"""

from __future__ import annotations

import numpy as np

from app.objects.background import components
from app.plates.detect import PlateBox
from app.stages.crops import resize
from app.stages.models import PLATE_TEXT
from app.stages.runner import Runner

BGR_MEAN = np.array([0.485, 0.456, 0.406], np.float32)
BGR_STD = np.array([0.229, 0.224, 0.225], np.float32)

PIXEL_THRESHOLD = 0.3
BOX_THRESHOLD = 0.6
UNCLIP_RATIO = 1.5
MIN_PIXELS = 6

MIN_ASPECT = 1.8
MAX_ASPECT = 9.0
PLATE_ASPECT = 4.0


def text_input(picture: np.ndarray) -> tuple[np.ndarray, float]:
    """Fit a picture into the text detector's input without distortion.

    Args:
        picture: Height by width by 3 RGB pixels.

    Returns:
        The 3 by height by width float32 input, BGR with the ImageNet normalization and zeros as padding, and the
        scale from picture pixels to input pixels.
    """
    _, height, width = PLATE_TEXT.input_shape
    rows, cols = picture.shape[:2]
    scale = min(width / cols, height / rows)
    scaled_width, scaled_height = max(1, round(cols * scale)), max(1, round(rows * scale))
    scaled = resize(picture[:, :, ::-1], scaled_width, scaled_height) / 255.0
    result = np.zeros((3, height, width), np.float32)
    result[:, :scaled_height, :scaled_width] = ((scaled - BGR_MEAN) / BGR_STD).transpose(2, 0, 1)
    return result, scale


def text_boxes(probabilities: np.ndarray) -> list[PlateBox]:
    """Turn a probability map into text boxes in input pixels.

    Args:
        probabilities: Height by width text probabilities.

    Returns:
        Boxes with their mean probability as the score, unordered.
    """
    height, width = probabilities.shape
    result = []
    for pixels in components(probabilities > PIXEL_THRESHOLD):
        if len(pixels) < MIN_PIXELS:
            continue
        score = float(probabilities[pixels[:, 0], pixels[:, 1]].mean())
        if score < BOX_THRESHOLD:
            continue
        top, left = pixels.min(axis=0)
        bottom, right = pixels.max(axis=0) + 1
        box_width, box_height = float(right - left), float(bottom - top)
        grow = box_width * box_height * UNCLIP_RATIO / (2 * (box_width + box_height))
        result.append(
            PlateBox(
                max(0.0, left - grow),
                max(0.0, top - grow),
                min(float(width), right + grow),
                min(float(height), bottom + grow),
                score,
            )
        )
    return result


def plate_likeness(box: PlateBox) -> float:
    """Rate how much a text box looks like a plate line.

    Args:
        box: The box.

    Returns:
        0 for shapes no plate has, up to 1 for the typical plate line shape.
    """
    width, height = box.right - box.left, box.bottom - box.top
    if height <= 0:
        return 0.0
    aspect = width / height
    if not MIN_ASPECT <= aspect <= MAX_ASPECT:
        return 0.0
    return float(np.exp(-abs(np.log(aspect / PLATE_ASPECT))))


class TextFinder:
    """Finds plate candidates with the DB text detector.

    Attributes:
        runner: Runner of the text detector engine.
        kind: Name of the finder in settings.
    """

    kind = "text"

    def __init__(self, runner: Runner):
        """Wrap an engine runner.

        Args:
            runner: Runner of the text detector engine.
        """
        self.runner = runner

    def find(self, picture: np.ndarray, threshold: float = BOX_THRESHOLD) -> list[PlateBox]:
        """Find plate-shaped text boxes in a vehicle picture.

        Args:
            picture: Height by width by 3 RGB pixels.
            threshold: Lowest mean probability of a box.

        Returns:
            Boxes in the picture's pixels, the most plate-like first, with the text score times the shape rating as
            their score.
        """
        array, scale = text_input(picture)
        output = self.runner.run({self.runner.inputs[0]: array[None]})[self.runner.outputs[0]]
        found = []
        for box in text_boxes(output.reshape(output.shape[-2:])):
            rating = plate_likeness(box)
            if box.score < threshold or rating <= 0:
                continue
            found.append(
                PlateBox(box.left / scale, box.top / scale, box.right / scale, box.bottom / scale, box.score * rating)
            )
        return sorted(found, key=lambda item: item.score, reverse=True)
