"""Face recognition settings read from the environment."""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path

from app.settings import env

DETECTOR_FILE = "scrfd_10g_bnkps.onnx"
DETECTOR_SHA256 = "5838f7fe053675b1c7a08b633df49e7af5495cee0493c7dcf6697200b85b5b91"
EMBEDDER_FILE = "glintr100.onnx"
EMBEDDER_SHA256 = "4ab1d6435d639628a6f3e5008dd4f929edf4c4124b1a7169e1048f9fef534cdf"


def env_float(name: str, default: float) -> float:
    """Read a number from the environment.

    Args:
        name: Variable name.
        default: Value when the variable is unset or empty.

    Returns:
        The number.
    """
    return float(env(name, str(default)))


@dataclass(frozen=True)
class IdentitySettings:
    """Everything the face stage reads from its environment.

    The thresholds compare cosine similarities of averaged, normalised track embeddings. Their values and the
    measurements behind them are described in the analytics README.

    Attributes:
        models_dir: Folder holding the face detector and embedder ONNX files, mounted read-only.
        detector_size: Square input size of the face detector in pixels.
        embed_batch: Largest batch the embedder engine is built for.
        min_score: Lowest face detection score kept.
        min_face: Smallest face height in view pixels, at the muxer resolution, worth embedding.
        known_threshold: Lowest similarity to a person's samples that names the person.
        ir_extra: Added to the known threshold for grey night-vision faces.
        margin: How far the best person must lead the second best to be named.
        candidate_threshold: Lowest similarity at which an unknown face still records its closest person.
        cluster_threshold: Lowest similarity to an unknown cluster's centroid that joins the cluster.
        cooldown: Seconds during which the same person or cluster produces at most one event per view.
        faces_per_track: Most faces embedded per track.
        decide_faces: Embedded faces after which a track is decided without waiting.
        decide_seconds: Seconds after its first face after which a track with any embedded face is decided.
        track_gap: Seconds without a new face after which a track counts as gone.
    """

    models_dir: Path = field(default_factory=lambda: Path(env("HC_ANALYTICS_FACE_MODELS_DIR", "/face-models")))
    detector_size: int = 640
    embed_batch: int = 8

    min_score: float = field(default_factory=lambda: env_float("HC_FACES_MIN_SCORE", 0.6))
    min_face: float = field(default_factory=lambda: env_float("HC_FACES_MIN_SIZE", 36.0))

    known_threshold: float = field(default_factory=lambda: env_float("HC_FACES_KNOWN_THRESHOLD", 0.42))
    ir_extra: float = field(default_factory=lambda: env_float("HC_FACES_IR_EXTRA", 0.05))
    margin: float = field(default_factory=lambda: env_float("HC_FACES_MARGIN", 0.08))
    candidate_threshold: float = field(default_factory=lambda: env_float("HC_FACES_CANDIDATE_THRESHOLD", 0.28))
    cluster_threshold: float = field(default_factory=lambda: env_float("HC_FACES_CLUSTER_THRESHOLD", 0.45))

    cooldown: float = field(default_factory=lambda: env_float("HC_FACES_COOLDOWN_SECONDS", 600.0))

    faces_per_track: int = 5
    decide_faces: int = 3
    decide_seconds: float = 3.0
    track_gap: float = 6.0

    @property
    def detector_path(self) -> Path:
        """Path: The face detector ONNX file."""
        return self.models_dir / DETECTOR_FILE

    @property
    def embedder_path(self) -> Path:
        """Path: The face embedder ONNX file."""
        return self.models_dir / EMBEDDER_FILE
