"""Greedy decoding of the text recogniser's per-column character scores.

The recogniser outputs, for each of its columns, a softmax over a blank, the characters of its dictionary in file
order and a final space. Greedy decoding takes the best class per column, merges repeats and drops blanks.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

import numpy as np

BLANK = 0


def load_characters(path: Path) -> list[str]:
    """Read the recogniser's dictionary into its class list.

    Args:
        path: Dictionary file with one character per line.

    Returns:
        Class index to character, with the blank first as an empty string and the space last.
    """
    lines = path.read_text(encoding="ascii").split("\n")
    if lines and lines[-1] == "":
        lines = lines[:-1]
    return ["", *lines, " "]


@dataclass(frozen=True)
class Decoded:
    """A decoded line of text.

    Attributes:
        text: The characters read.
        scores: Score of each character, the best column score of its run.
    """

    text: str
    scores: tuple[float, ...]

    @property
    def confidence(self) -> float:
        """float: The lowest character score, 0 for an empty text."""
        return min(self.scores) if self.scores else 0.0


def greedy(probabilities: np.ndarray, characters: list[str]) -> Decoded:
    """Decode one line by taking the best class of each column.

    Args:
        probabilities: Columns by classes softmax scores.
        characters: Class index to character.

    Returns:
        The text with a score per character.
    """
    best = probabilities.argmax(axis=-1)
    peaks = probabilities.max(axis=-1)
    text: list[str] = []
    scores: list[float] = []
    previous = BLANK
    for column, index in enumerate(best):
        index = int(index)
        if index != BLANK and index < len(characters):
            if index != previous:
                text.append(characters[index])
                scores.append(float(peaks[column]))
            else:
                scores[-1] = max(scores[-1], float(peaks[column]))
        previous = index
    return Decoded("".join(text), tuple(round(value, 4) for value in scores))
