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

    The thresholds compare cosine similarities of averaged, normalised track embeddings. They were calibrated on
    the 6000 pairs of a public face verification benchmark, with each face also shrunk to a 40 pixel door-camera
    face and turned grey as in night vision: no pair of different people scored above 0.27 in any condition, while
    the median for the same person was 0.63 to 0.71. Naming a person at 0.45, and at 0.50 for grey faces, keeps a
    wide distance from strangers and lookalike relatives and still accepts about 98 percent of small daylight faces
    and 92 percent of small grey faces against an enrolled photo, before averaging over a track improves them.

    Attributes:
        models_dir: Mount point of the face model folder; SSS_ANALYTICS_FACE_MODELS_DIR names the host folder compose
            mounts there read-only.
        detector_size: Square input size of the face detector in pixels.
        embed_batch: Largest batch the embedder engine is built for.
        min_score: Lowest face detection score kept.
        min_face: Smallest face height in view pixels, at the muxer resolution, worth embedding.
        min_quality: Lowest quality of a face the pipeline sends.
        cluster_quality: Lowest mean quality of a track that may start a new unknown cluster.
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

    models_dir: Path = Path("/face-models")
    detector_size: int = 640
    embed_batch: int = 8

    min_score: float = field(default_factory=lambda: env_float("SSS_FACES_MIN_SCORE", 0.6))
    min_face: float = field(default_factory=lambda: env_float("SSS_FACES_MIN_SIZE", 36.0))
    min_quality: float = field(default_factory=lambda: env_float("SSS_FACES_MIN_QUALITY", 0.15))
    cluster_quality: float = field(default_factory=lambda: env_float("SSS_FACES_CLUSTER_QUALITY", 0.35))

    known_threshold: float = field(default_factory=lambda: env_float("SSS_FACES_KNOWN_THRESHOLD", 0.45))
    ir_extra: float = field(default_factory=lambda: env_float("SSS_FACES_IR_EXTRA", 0.05))
    margin: float = field(default_factory=lambda: env_float("SSS_FACES_MARGIN", 0.08))
    candidate_threshold: float = field(default_factory=lambda: env_float("SSS_FACES_CANDIDATE_THRESHOLD", 0.3))
    cluster_threshold: float = field(default_factory=lambda: env_float("SSS_FACES_CLUSTER_THRESHOLD", 0.45))

    cooldown: float = field(default_factory=lambda: env_float("SSS_FACES_COOLDOWN_SECONDS", 600.0))

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
