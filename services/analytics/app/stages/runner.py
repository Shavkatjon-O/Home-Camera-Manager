"""What the secondary stages need from a TensorRT engine runner.

The pipeline and service processes run the secondary engines with the CUDA runtime wrapper of the face stage; the
stages only depend on this protocol, so their tests feed them fakes.
"""

from __future__ import annotations

from typing import Protocol

import numpy as np


class Runner(Protocol):
    """A loaded engine that runs on host arrays.

    Attributes:
        inputs: Input tensor names.
        outputs: Output tensor names.
        max_batch: Largest batch the engine accepts.
    """

    inputs: list[str]
    outputs: list[str]
    max_batch: int

    def run(self, feeds: dict[str, np.ndarray]) -> dict[str, np.ndarray]:
        """Run the engine.

        Args:
            feeds: One array per input name.

        Returns:
            One array per output name.
        """
