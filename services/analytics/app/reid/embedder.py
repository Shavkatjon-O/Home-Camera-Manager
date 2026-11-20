"""Appearance vectors of person crops from the re-identification engine.

OSNet-AIN x1.0 trained on MSMT17 takes a person box stretched to 128 by 256 pixels with the ImageNet normalization
and returns 512 values, which are scaled to unit length so a dot product is the cosine similarity.
"""

from __future__ import annotations

import numpy as np

from app.stages.crops import imagenet, resize
from app.stages.models import REID
from app.stages.runner import Runner

INPUT_HEIGHT = REID.input_shape[1]
INPUT_WIDTH = REID.input_shape[2]
MIN_NORM = 1e-6


def prepare(crop: np.ndarray) -> np.ndarray:
    """Turn a person crop into the model's input.

    Args:
        crop: Height by width by 3 RGB pixels of the person box.

    Returns:
        A 3 by 256 by 128 float32 array.
    """
    return imagenet(resize(crop, INPUT_WIDTH, INPUT_HEIGHT))


def unit_rows(vectors: np.ndarray) -> np.ndarray:
    """Scale every row to unit length, leaving rows of zeros as they are.

    Args:
        vectors: N by D array.

    Returns:
        The scaled float32 array.
    """
    norms = np.linalg.norm(vectors, axis=1, keepdims=True)
    return (vectors / np.maximum(norms, MIN_NORM)).astype(np.float32)


class Embedder:
    """Embeds person crops in batches.

    Attributes:
        runner: The engine runner.
    """

    def __init__(self, runner: Runner):
        """Wrap an engine runner.

        Args:
            runner: Runner of the re-identification engine.
        """
        self.runner = runner

    def embed(self, crops: list[np.ndarray]) -> np.ndarray:
        """Embed person crops.

        Args:
            crops: RGB person crops of any size.

        Returns:
            An N by 512 float32 array of unit vectors, empty when there are no crops.
        """
        if not crops:
            return np.zeros((0, 0), np.float32)
        batch = np.stack([prepare(crop) for crop in crops])
        name, output = self.runner.inputs[0], self.runner.outputs[0]
        size = max(1, self.runner.max_batch)
        parts = [self.runner.run({name: batch[start : start + size]})[output] for start in range(0, len(batch), size)]
        return unit_rows(np.concatenate(parts).reshape(len(crops), -1))
