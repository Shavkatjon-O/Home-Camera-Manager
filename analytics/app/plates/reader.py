"""Reading the plate of one vehicle picture, and voting over the reads of one vehicle event.

The vehicle picture is a full-resolution crop around the vehicle box. A grey picture is infrared night vision, which
glares on the plate, so it is not read. Otherwise a plate finder looks at the whole crop: by default PaddleOCR's DB
text detector, which finds plate-shaped lines of text, or NVIDIA's LPDNet where its licence suits. The best boxes are
widened a little and cut from the full-resolution crop, and the text recogniser reads each one; the read that fits a
plate format best wins.
"""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass, field
from typing import Protocol

import numpy as np

from app.plates.ctc import greedy
from app.plates.detect import PlateBox
from app.plates.text import PlateText, parse
from app.stages.crops import is_grey, text_line
from app.stages.models import PLATE_READER
from app.stages.runner import Runner

READ = "read"
INFRARED = "infrared"
NO_PLATE = "no_plate"
TOO_SMALL = "too_small"
UNREADABLE = "unreadable"

STATUS_ORDER = (READ, UNREADABLE, TOO_SMALL, NO_PLATE, INFRARED)

CROP_VARIANTS = ((0.1, 0.14), (0.1, 0.0), (-0.15, 0.0), (0.0, 0.08), (0.2, 0.0), (-0.15, 0.14))

TEXT_FINDER = "text"
LPD_FINDER = "lpdnet"


class Finder(Protocol):
    """What the reader needs from a plate finder.

    Attributes:
        kind: text or lpdnet.
    """

    kind: str

    def find(self, picture: np.ndarray, threshold: float) -> list[PlateBox]:
        """Find plate boxes in a vehicle picture.

        Args:
            picture: Height by width by 3 RGB pixels.
            threshold: Lowest box score kept.

        Returns:
            Plate boxes in the picture's pixels, best first.
        """


@dataclass(frozen=True)
class PlateSettings:
    """Thresholds of plate reading.

    Attributes:
        detect_threshold: Lowest LPDNet coverage kept.
        text_threshold: Lowest mean text probability of a DB text box kept.
        boxes: Plate boxes read per picture, best first.
        min_height: Smallest plate height in full-resolution pixels worth reading.
        widen_x: Share of the plate width added on each side before reading.
        widen_y: Share of the plate height added above and below before reading.
        min_confidence: Lowest character score of a read that is kept.
        grey_spread: Largest mean channel spread of a picture taken as infrared; infrared pictures measure about 0
            and dull daylight crops of dark cars on concrete still about 9.
    """

    detect_threshold: float = 0.3
    text_threshold: float = 0.6
    boxes: int = 3
    min_height: float = 12.0
    widen_x: float = 0.06
    widen_y: float = 0.2
    min_confidence: float = 0.5
    grey_spread: float = 2.0

    @classmethod
    def from_dict(cls, data: dict | None) -> PlateSettings:
        """Build the settings from a view's plate configuration, keeping defaults for missing keys.

        Args:
            data: Mapping of setting names to numbers, or None.

        Returns:
            The settings.
        """
        data = data or {}
        known = {}
        for name, value in cls.__dataclass_fields__.items():
            if name in data:
                known[name] = int(data[name]) if value.type == "int" else float(data[name])
        return cls(**known)


@dataclass(frozen=True)
class PlateRead:
    """The outcome of reading one vehicle picture.

    Attributes:
        status: read, infrared, no_plate, too_small or unreadable.
        plate: The plate text when read.
        confidence: Lowest character score times the format fitness, 0 when not read.
        raw: What the recogniser read before cleaning.
        box: Plate box in the vehicle picture's pixels, when one was found.
    """

    status: str
    plate: PlateText | None = None
    confidence: float = 0.0
    raw: str = ""
    box: tuple[float, float, float, float] | None = None


def variants(box: PlateBox, settings: PlateSettings, width: int, height: int) -> list[tuple[int, int, int, int]]:
    """Return the crops a plate box is read from: taller and shorter, with and without the flag on the right.

    A box from the DB text detector reaches above and below the characters while one from LPDNet can clip them, and
    the flag at the right end reads as a stray letter, so each box is read a few ways and the best fit wins.

    Args:
        box: Plate box in picture pixels.
        settings: Reading settings.
        width: Picture width.
        height: Picture height.

    Returns:
        Left, top, right and bottom of each crop, clipped to the picture, without duplicates.
    """
    box_width, box_height = box.right - box.left, box.bottom - box.top
    result = []
    for grow_y, trim_right in CROP_VARIANTS:
        left = max(0, int(box.left - settings.widen_x * box_width))
        right = min(width, int(np.ceil(box.right + settings.widen_x * box_width - trim_right * box_width)))
        top = max(0, int(box.top - grow_y * box_height))
        bottom = min(height, int(np.ceil(box.bottom + grow_y * box_height)))
        crop = (left, top, right, bottom)
        if right - left >= 4 and bottom - top >= 4 and crop not in result:
            result.append(crop)
    return result


def widen(box: PlateBox, settings: PlateSettings, width: int, height: int) -> tuple[int, int, int, int]:
    """Widen a plate box and clip it to the picture.

    Args:
        box: Plate box in picture pixels.
        settings: Reading settings.
        width: Picture width.
        height: Picture height.

    Returns:
        Left, top, right and bottom in whole pixels.
    """
    extra_x = (box.right - box.left) * settings.widen_x
    extra_y = (box.bottom - box.top) * settings.widen_y
    left = max(0, int(box.left - extra_x))
    top = max(0, int(box.top - extra_y))
    right = min(width, int(np.ceil(box.right + extra_x)))
    bottom = min(height, int(np.ceil(box.bottom + extra_y)))
    return left, top, right, bottom


class PlateReader:
    """Finds and reads the plate of vehicle pictures.

    Attributes:
        finder: The plate finder.
        recogniser: Runner of the text recogniser engine.
        characters: Class index to character of the recogniser.
        settings: Reading settings.
    """

    def __init__(self, finder: Finder, recogniser: Runner, characters: list[str], settings: PlateSettings):
        """Create the reader.

        Args:
            finder: The plate finder.
            recogniser: Runner of the text recogniser engine.
            characters: Class index to character of the recogniser.
            settings: Reading settings.
        """
        self.finder = finder
        self.recogniser = recogniser
        self.characters = characters
        self.settings = settings

    def find(self, picture: np.ndarray) -> list[PlateBox]:
        """Find plate boxes in a vehicle picture with the reader's finder and threshold.

        Args:
            picture: Height by width by 3 RGB pixels.

        Returns:
            Plate boxes in the picture's pixels, best first.
        """
        threshold = self.settings.text_threshold if self.finder.kind == TEXT_FINDER else self.settings.detect_threshold
        return self.finder.find(picture, threshold)

    def read(self, picture: np.ndarray) -> PlateRead:
        """Read the plate of one vehicle picture.

        Args:
            picture: Height by width by 3 RGB pixels around the vehicle, at full resolution.

        Returns:
            The best read, or the reason there is none.
        """
        if is_grey(picture, self.settings.grey_spread):
            return PlateRead(INFRARED)
        boxes = self.find(picture)[: self.settings.boxes]
        if not boxes:
            return PlateRead(NO_PLATE)
        height, width = picture.shape[:2]
        lines, spans = [], []
        _, line_height, line_width = PLATE_READER.input_shape
        for box in boxes:
            if box.bottom - box.top < self.settings.min_height:
                continue
            for left, top, right, bottom in variants(box, self.settings, width, height):
                lines.append(text_line(picture[top:bottom, left:right], line_height, line_width))
                spans.append((float(left), float(top), float(right), float(bottom)))
        if not lines:
            return PlateRead(TOO_SMALL)
        size = max(1, self.recogniser.max_batch)
        batch = np.stack(lines)
        scores = np.concatenate(
            [
                self.recogniser.run({self.recogniser.inputs[0]: batch[start : start + size]})[
                    self.recogniser.outputs[0]
                ]
                for start in range(0, len(batch), size)
            ]
        )
        best = PlateRead(UNREADABLE)
        for index, span in enumerate(spans):
            decoded = greedy(scores[index], self.characters)
            plate = parse(decoded.text)
            if plate is None or decoded.confidence < self.settings.min_confidence:
                if best.status != READ and not best.raw:
                    best = PlateRead(UNREADABLE, raw=decoded.text, box=span)
                continue
            confidence = round(decoded.confidence * plate.score, 4)
            if best.status != READ or confidence > best.confidence:
                best = PlateRead(READ, plate, confidence, decoded.text, span)
        return best


@dataclass
class PlateVotes:
    """The reads of one vehicle event and the candidates they vote for.

    Attributes:
        weights: Summed confidence per plate text.
        counts: Reads per plate text.
        plates: Latest parsed plate per text.
        statuses: Reads per status.
    """

    weights: dict[str, float] = field(default_factory=lambda: defaultdict(float))
    counts: dict[str, int] = field(default_factory=lambda: defaultdict(int))
    plates: dict[str, PlateText] = field(default_factory=dict)
    statuses: dict[str, int] = field(default_factory=lambda: defaultdict(int))

    def add(self, read: PlateRead) -> None:
        """Count one read.

        Args:
            read: The read.
        """
        self.statuses[read.status] += 1
        if read.status == READ and read.plate is not None:
            self.weights[read.plate.text] += read.confidence
            self.counts[read.plate.text] += 1
            self.plates[read.plate.text] = read.plate

    @property
    def status(self) -> str:
        """str: read when any read succeeded, otherwise the most telling failure, or pending without reads."""
        for status in STATUS_ORDER:
            if self.statuses.get(status):
                return status
        return "pending"

    def candidates(self, limit: int = 3) -> list[dict]:
        """Return the plate texts voted for, strongest first.

        Args:
            limit: Most candidates returned.

        Returns:
            Dicts with text, display, format, score as the mean confidence, reads and weight.
        """
        ranked = sorted(self.weights, key=lambda text: self.weights[text], reverse=True)[:limit]
        return [
            {
                "text": text,
                "display": self.plates[text].display,
                "format": self.plates[text].format,
                "score": round(self.weights[text] / self.counts[text], 3),
                "reads": self.counts[text],
                "weight": round(self.weights[text], 3),
            }
            for text in ranked
        ]
