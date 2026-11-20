"""Faces collected per person track until the track is decided.

Each track keeps its few best faces by quality. Only those are embedded, never every frame, and the track's
identity is the quality-weighted mean of their embeddings.
"""

from __future__ import annotations

import uuid
from dataclasses import dataclass, field

import numpy as np

from app.identity.gallery import Match
from app.identity.probe import Candidate


@dataclass
class Face:
    """One collected face of a track.

    Attributes:
        candidate: The face as the pipeline sent it.
        embedding: Its unit embedding once computed.
    """

    candidate: Candidate
    embedding: np.ndarray | None = None


@dataclass
class TrackFaces:
    """The faces of one person track.

    Attributes:
        view: View id.
        track: Tracker id.
        first_at: Time of the first face.
        last_at: Time of the latest face.
        faces: The best faces, highest quality first.
        event: Face event id, chosen when the track is first decided.
        match: The decision, once made.
        decided_with: Embedded faces the decision used.
        deferred: Embedded faces when the track was last too poor to start a cluster.
        published: True once an event went out for the track.
    """

    view: str
    track: int
    first_at: float
    last_at: float
    faces: list[Face] = field(default_factory=list)
    event: str = field(default_factory=lambda: str(uuid.uuid4()))
    match: Match | None = None
    decided_with: int = 0
    deferred: int = 0
    published: bool = False

    def add(self, candidate: Candidate, keep: int) -> bool:
        """Keep a face when it is among the best of the track.

        Args:
            candidate: The face.
            keep: Most faces kept.

        Returns:
            True when the face was kept.
        """
        self.last_at = max(self.last_at, candidate.at)
        if len(self.faces) >= keep and candidate.quality <= self.faces[-1].candidate.quality:
            return False
        self.faces.append(Face(candidate))
        self.faces.sort(key=lambda face: face.candidate.quality, reverse=True)
        del self.faces[keep:]
        return True

    def pending(self) -> list[Face]:
        """Return the kept faces still waiting for their embedding.

        Returns:
            Faces without an embedding.
        """
        return [face for face in self.faces if face.embedding is None]

    def embedded(self) -> list[Face]:
        """Return the kept faces with an embedding.

        Returns:
            Faces with an embedding, highest quality first.
        """
        return [face for face in self.faces if face.embedding is not None]

    def embedding(self) -> np.ndarray | None:
        """Return the quality-weighted mean embedding of the track.

        Returns:
            The unit mean, or None without embedded faces.
        """
        faces = self.embedded()
        if not faces:
            return None
        weights = np.array([max(face.candidate.quality, 1e-3) for face in faces], dtype=np.float32)
        total = (np.stack([face.embedding for face in faces]) * weights[:, None]).sum(axis=0)
        return (total / max(float(np.linalg.norm(total)), 1e-12)).astype(np.float32)

    def grey(self) -> bool:
        """Tell whether most embedded faces were seen in night vision.

        Returns:
            True when at least half the embedded faces are grey.
        """
        faces = self.embedded()
        return bool(faces) and sum(face.candidate.grey for face in faces) * 2 >= len(faces)

    def best(self) -> Face | None:
        """Return the best embedded face.

        Returns:
            The highest quality embedded face, or None.
        """
        faces = self.embedded()
        return faces[0] if faces else None

    def quality(self) -> float:
        """Return the mean quality of the embedded faces.

        Returns:
            The mean, 0 without embedded faces.
        """
        faces = self.embedded()
        return float(np.mean([face.candidate.quality for face in faces])) if faces else 0.0
