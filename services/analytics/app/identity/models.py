"""The face detector and embedder run directly with TensorRT in the service process.

The pipeline runs the detector inside nvinfer on person objects; this module runs the same detector engine on whole
photos for enrollment and searches, and runs the embedder on aligned faces from both paths.
"""

from __future__ import annotations

import logging
import threading
import time
from pathlib import Path

import numpy as np

from app.identity import align, scrfd
from app.identity.engines import detector_engine, embedder_engine
from app.identity.runtime import Cuda, EngineRunner
from app.identity.settings import IdentitySettings

logger = logging.getLogger(__name__)

DETECTOR_MEAN = 127.5
DETECTOR_STD = 128.0
EMBEDDER_MEAN = 127.5
EMBEDDER_STD = 127.5


def normalise(vectors: np.ndarray) -> np.ndarray:
    """Scale vectors to unit length.

    Args:
        vectors: Array whose last axis holds the vectors.

    Returns:
        The unit vectors, zero vectors left at zero.
    """
    norms = np.linalg.norm(vectors, axis=-1, keepdims=True)
    return (vectors / np.maximum(norms, 1e-12)).astype(np.float32)


def planar(images: np.ndarray, mean: float, std: float) -> np.ndarray:
    """Turn RGB pictures into the normalised planar layout the networks read.

    Args:
        images: Pictures, n by height by width by 3, uint8.
        mean: Value subtracted from every channel.
        std: Value every channel is divided by.

    Returns:
        Float array, n by 3 by height by width.
    """
    return ((images.astype(np.float32) - mean) / std).transpose(0, 3, 1, 2).copy()


class FaceModels:
    """The face detector and embedder engines, loaded on first use.

    Attributes:
        settings: Face settings.
        engine_dir: Writable engine cache.
        workspace_mb: Builder workspace limit for a first build.
        error: Why loading failed, or None.
        embed_ms: Recent embedding times per face in milliseconds.
    """

    def __init__(self, settings: IdentitySettings, engine_dir: Path, workspace_mb: int):
        """Prepare the models without loading them.

        Args:
            settings: Face settings.
            engine_dir: Writable engine cache.
            workspace_mb: Builder workspace limit for a first build.
        """
        self.settings = settings
        self.engine_dir = engine_dir
        self.workspace_mb = workspace_mb
        self.lock = threading.Lock()
        self.cuda: Cuda | None = None
        self.detector: EngineRunner | None = None
        self.embedder: EngineRunner | None = None
        self.error: str | None = None
        self.embed_ms: list[float] = []

    @property
    def loaded(self) -> bool:
        """bool: True once both engines are loaded."""
        return self.detector is not None and self.embedder is not None

    def load(self) -> None:
        """Load both engines, building them first when the cache has none.

        Raises:
            Exception: Whatever building or loading raised; the message is kept in error.
        """
        with self.lock:
            if self.loaded:
                return
            try:
                self.cuda = self.cuda or Cuda()
                detector = detector_engine(self.settings, self.engine_dir, self.workspace_mb)
                embedder = embedder_engine(self.settings, self.engine_dir, self.workspace_mb)
                self.detector = EngineRunner(detector, self.cuda)
                self.embedder = EngineRunner(embedder, self.cuda)
                self.error = None
                logger.info("Face models loaded: %s and %s", detector.name, embedder.name)
            except Exception as exc:
                self.error = f"{type(exc).__name__}: {exc}"
                raise

    def embed(self, faces: list[np.ndarray]) -> np.ndarray:
        """Embed aligned faces.

        Args:
            faces: Aligned faces, 112 by 112 by 3 RGB, uint8.

        Returns:
            Unit embeddings, n by 512.
        """
        self.load()
        if not faces:
            return np.zeros((0, 512), dtype=np.float32)
        started = time.perf_counter()
        results = []
        batch = self.embedder.max_batch
        for start in range(0, len(faces), batch):
            chunk = np.stack(faces[start : start + batch])
            output = self.embedder.run({"image": planar(chunk, EMBEDDER_MEAN, EMBEDDER_STD)})
            results.append(output["embedding"])
        elapsed = (time.perf_counter() - started) * 1000 / len(faces)
        self.embed_ms = (self.embed_ms + [elapsed])[-200:]
        return normalise(np.concatenate(results))

    def detect(self, image: np.ndarray, threshold: float) -> list[scrfd.RawFace]:
        """Find faces in a whole picture.

        Args:
            image: Picture, height by width by 3 RGB, uint8.
            threshold: Lowest detection score kept.

        Returns:
            Faces in picture pixels, highest score first.
        """
        self.load()
        size = self.settings.detector_size
        height, width = image.shape[:2]
        scale = scrfd.letterbox_scale(width, height, size)
        matrix = np.array([[scale, 0.0, 0.0], [0.0, scale, 0.0]])
        letterboxed = align.warp(image, matrix, size)
        outputs = self.detector.run({"image": planar(letterboxed[None], DETECTOR_MEAN, DETECTOR_STD)})
        return [face.mapped(scale, 0.0, 0.0) for face in scrfd.decode(outputs, size, threshold)]

    def status(self) -> dict:
        """Return the models' state for the status endpoint.

        Returns:
            Whether they are loaded, the last error and the median embedding time per face.
        """
        ordered = sorted(self.embed_ms)
        return {
            "loaded": self.loaded,
            "error": self.error,
            "embed_ms_per_face": round(ordered[len(ordered) // 2], 2) if ordered else None,
        }
