"""Plate text: cleaning what the recogniser read and fitting it to the plate formats in use.

Uzbek plates carry a two-digit region code and then either a letter, three digits and two letters for private cars,
or three digits and three letters for organisations, followed by the flag and UZ. The recogniser confuses letters
and digits that look alike, so a read is fitted to each format, swapping look-alikes only where the format needs the
other kind, and the format that needs the fewest swaps wins; stray characters before or after, such as the flag,
cost a little. The two region digits sit in their own framed box, which the recogniser often misreads when the
plate is small, so a read whose body fits but whose region does not is kept as a partial plate such as ?? A 123 BC,
still found by searching the body. Reads that fit no format are kept with a lower score, so plates from elsewhere
still reach the search.
"""

from __future__ import annotations

from dataclasses import dataclass

DIGIT_FOR = {
    "O": "0",
    "Q": "0",
    "D": "0",
    "I": "1",
    "L": "1",
    "J": "1",
    "Z": "2",
    "S": "5",
    "B": "8",
    "G": "6",
    "T": "7",
}
LETTER_FOR = {"0": "O", "1": "I", "2": "Z", "5": "S", "8": "B", "6": "G", "7": "T", "4": "A"}

FORMATS = {
    "private": "DDLDDDLL",
    "organisation": "DDDDDLLL",
}
GROUPS = {
    "private": (2, 1, 3, 2),
    "organisation": (2, 3, 3),
}
BODIES = {
    "private": "LDDDLL",
    "organisation": "DDDLLL",
}
BODY_GROUPS = {
    "private": (1, 3, 2),
    "organisation": (3, 3),
}

MIN_LENGTH = 4
MAX_LENGTH = 10
SWAP_PENALTY = 0.1
STRAY_PENALTY = 0.05
PARTIAL_SCORE = 0.75
UNFORMATTED_SCORE = 0.5
COUNTRY_MARK = "UZ"
UNKNOWN_REGION = "??"


@dataclass(frozen=True)
class PlateText:
    """A cleaned plate read.

    Attributes:
        text: Letters and digits without spaces, such as 01A123BC.
        display: The text grouped as printed on the plate, such as 01 A 123 BC.
        format: Name of the format it fits, or None.
        swaps: Look-alike characters swapped to fit the format.
        score: Fitness from 0 to 1, lower for swaps and for reads that fit no format.
    """

    text: str
    display: str
    format: str | None
    swaps: int
    score: float


def clean(raw: str) -> str:
    """Keep the letters and digits of a read in upper case.

    Args:
        raw: Text as the recogniser read it.

    Returns:
        Upper-case letters A to Z and digits only.
    """
    return "".join(character for character in raw.upper() if character.isascii() and character.isalnum())


def fit(text: str, template: str) -> tuple[str, int] | None:
    """Fit a cleaned read to a format template of D for digits and L for letters.

    Args:
        text: Cleaned read.
        template: The format.

    Returns:
        The fitted text and the number of swaps, or None when it cannot fit.
    """
    if len(text) != len(template):
        return None
    result = []
    swaps = 0
    for character, kind in zip(text, template):
        if kind == "D" and not character.isdigit():
            if character not in DIGIT_FOR:
                return None
            character, swaps = DIGIT_FOR[character], swaps + 1
        elif kind == "L" and not character.isalpha():
            if character not in LETTER_FOR:
                return None
            character, swaps = LETTER_FOR[character], swaps + 1
        result.append(character)
    return "".join(result), swaps


def grouped(text: str, sizes: tuple[int, ...]) -> str:
    """Split a plate text into its printed groups.

    Args:
        text: Plate text.
        sizes: Length of each group.

    Returns:
        The groups joined by spaces.
    """
    parts, start = [], 0
    for size in sizes:
        parts.append(text[start : start + size])
        start += size
    return " ".join(parts)


def windows(text: str, length: int) -> list[tuple[int, str]]:
    """List every run of a length inside a text.

    Args:
        text: The text.
        length: Run length.

    Returns:
        Start and run, from the left.
    """
    return [(start, text[start : start + length]) for start in range(0, len(text) - length + 1)]


def parse(raw: str) -> PlateText | None:
    """Clean a read and fit it to the best plate format, whole or without its region.

    Args:
        raw: Text as the recogniser read it.

    Returns:
        The plate text, or None when the read is too short or too long to be a plate.
    """
    text = clean(raw)
    best: PlateText | None = None
    for name, template in FORMATS.items():
        for _, part in windows(text, len(template)):
            fitted = fit(part, template)
            if fitted is None:
                continue
            value, swaps = fitted
            stray = len(text) - len(template)
            if text.endswith(COUNTRY_MARK) and stray >= len(COUNTRY_MARK):
                stray -= len(COUNTRY_MARK)
            score = max(0.0, 1.0 - SWAP_PENALTY * swaps - STRAY_PENALTY * stray)
            plate = PlateText(value, grouped(value, GROUPS[name]), name, swaps, round(score, 3))
            if best is None or plate.score > best.score:
                best = plate
    if best is not None:
        return best
    for name, template in BODIES.items():
        for _, part in windows(text, len(template)):
            fitted = fit(part, template)
            if fitted is None:
                continue
            value, swaps = fitted
            score = max(0.0, PARTIAL_SCORE - SWAP_PENALTY * swaps)
            display = f"{UNKNOWN_REGION} {grouped(value, BODY_GROUPS[name])}"
            plate = PlateText(value, display, name, swaps, round(score, 3))
            if best is None or plate.score > best.score:
                best = plate
    if best is not None:
        return best
    if not MIN_LENGTH <= len(text) <= MAX_LENGTH:
        return None
    return PlateText(text, text, None, 0, UNFORMATTED_SCORE)
