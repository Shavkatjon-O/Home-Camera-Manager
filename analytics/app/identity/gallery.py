"""The gallery of known people and unknown clusters, and the matching of a track's face against it.

A track is named only when its averaged embedding is close enough to one person's samples and clearly closer to
that person than to anyone else; everything else stays unknown. An unknown face joins the nearest unknown cluster
when it is close enough to the cluster's centroid, and otherwise starts a new cluster, so repeated visitors gather
into one cluster the owner can name.
"""

from __future__ import annotations

import base64
import time
import uuid
from dataclasses import dataclass, field

import numpy as np

from app.identity.settings import IdentitySettings

EMBEDDING_SIZE = 512
PENDING_SECONDS = 120.0


def decode_vector(text: str) -> np.ndarray:
    """Decode a base64 embedding.

    Args:
        text: Base64 of 512 little-endian float32 values.

    Returns:
        The unit vector.

    Raises:
        ValueError: If the text does not hold 512 values.
    """
    vector = np.frombuffer(base64.b64decode(text), dtype="<f4").astype(np.float32)
    if vector.size != EMBEDDING_SIZE:
        raise ValueError(f"An embedding has {vector.size} values instead of {EMBEDDING_SIZE}")
    return vector / max(float(np.linalg.norm(vector)), 1e-12)


def encode_vector(vector: np.ndarray) -> str:
    """Encode an embedding as base64.

    Args:
        vector: 512 values.

    Returns:
        Base64 of the little-endian float32 bytes.
    """
    return base64.b64encode(np.asarray(vector, dtype="<f4").tobytes()).decode()


@dataclass
class Cluster:
    """An unknown cluster as the matcher sees it.

    Attributes:
        uuid: Cluster id.
        number: Display number, 0 until the backend assigns one.
        centroid: Unit mean of the cluster's embeddings.
        count: Faces in the cluster.
        created: Time the cluster was created here, for clusters the backend does not list yet.
    """

    uuid: str
    number: int
    centroid: np.ndarray
    count: int
    created: float = 0.0

    def absorb(self, embedding: np.ndarray) -> None:
        """Move the centroid towards a new member.

        Args:
            embedding: Unit embedding of the new member.
        """
        total = self.centroid * self.count + embedding
        self.count += 1
        self.centroid = (total / max(float(np.linalg.norm(total)), 1e-12)).astype(np.float32)


@dataclass(frozen=True)
class Match:
    """Who a track is.

    Attributes:
        known: True when the track is a known person.
        person: Person id when known.
        person_name: Person name when known.
        cluster: Cluster id when unknown.
        cluster_new: True when the cluster was created for this track.
        confidence: Similarity to the matched person or cluster, 0 for a new cluster.
        candidate: Closest person and its similarity for an unknown track that came near one.
    """

    known: bool
    person: str | None = None
    person_name: str | None = None
    cluster: str | None = None
    cluster_new: bool = False
    confidence: float = 0.0
    candidate: tuple[str, float] | None = None


@dataclass
class Gallery:
    """Known people and unknown clusters.

    Attributes:
        version: Version reported by the backend.
        people: Person id to name.
        samples: Unit embeddings of every person's samples, one row each.
        owners: Person id of every row of samples.
        clusters: Unknown clusters by id.
    """

    version: str = ""
    people: dict[str, str] = field(default_factory=dict)
    samples: np.ndarray = field(default_factory=lambda: np.zeros((0, EMBEDDING_SIZE), dtype=np.float32))
    owners: list[str] = field(default_factory=list)
    clusters: dict[str, Cluster] = field(default_factory=dict)

    @classmethod
    def from_payload(cls, data: dict, previous: Gallery | None = None, now: float | None = None) -> Gallery:
        """Build the gallery from the backend's payload.

        Clusters created here in the last two minutes that the payload does not list yet are kept, because the
        backend may not have stored them when it built the payload.

        Args:
            data: The gallery payload.
            previous: The gallery being replaced.
            now: Current time.

        Returns:
            The gallery.
        """
        now = time.time() if now is None else now
        people, rows, owners = {}, [], []
        for person in data.get("people") or []:
            people[str(person["uuid"])] = str(person.get("name") or "")
            for text in person.get("embeddings") or []:
                rows.append(decode_vector(text))
                owners.append(str(person["uuid"]))
        clusters = {}
        for item in data.get("clusters") or []:
            if not item.get("centroid"):
                continue
            key = str(item["uuid"])
            clusters[key] = Cluster(
                key, int(item.get("number") or 0), decode_vector(item["centroid"]), int(item["count"])
            )
        if previous is not None:
            for key, cluster in previous.clusters.items():
                if key not in clusters and cluster.created and now - cluster.created < PENDING_SECONDS:
                    clusters[key] = cluster
        samples = np.stack(rows) if rows else np.zeros((0, EMBEDDING_SIZE), dtype=np.float32)
        return cls(str(data.get("version") or ""), people, samples, owners, clusters)

    def person_scores(self, embedding: np.ndarray) -> list[tuple[str, float]]:
        """Score every person against an embedding.

        Args:
            embedding: Unit embedding.

        Returns:
            Person id and its best sample similarity, highest first.
        """
        if not self.owners:
            return []
        similarities = self.samples @ embedding
        best: dict[str, float] = {}
        for owner, value in zip(self.owners, similarities):
            best[owner] = max(best.get(owner, -1.0), float(value))
        return sorted(best.items(), key=lambda item: item[1], reverse=True)

    def nearest_cluster(self, embedding: np.ndarray) -> tuple[Cluster | None, float]:
        """Find the cluster whose centroid is closest to an embedding.

        Args:
            embedding: Unit embedding.

        Returns:
            The cluster and its similarity, or None and -1 without clusters.
        """
        best, best_value = None, -1.0
        for cluster in self.clusters.values():
            value = float(cluster.centroid @ embedding)
            if value > best_value:
                best, best_value = cluster, value
        return best, best_value


class Matcher:
    """Applies the thresholds to decide who a track is.

    Attributes:
        settings: Face settings with the thresholds.
    """

    def __init__(self, settings: IdentitySettings):
        """Create the matcher.

        Args:
            settings: Face settings.
        """
        self.settings = settings

    def known_threshold(self, grey: bool) -> float:
        """Return the similarity needed to name a person.

        Args:
            grey: True for a night-vision face.

        Returns:
            The threshold, stricter for grey faces.
        """
        return self.settings.known_threshold + (self.settings.ir_extra if grey else 0.0)

    def match(self, gallery: Gallery, embedding: np.ndarray, grey: bool, now: float) -> Match:
        """Decide who a track is and update the unknown clusters.

        Args:
            gallery: Gallery to match against; a new or joined cluster is updated in it.
            embedding: The track's unit embedding.
            grey: True for a night-vision face.
            now: Current time.

        Returns:
            The match.
        """
        scores = gallery.person_scores(embedding)
        if scores:
            person, best = scores[0]
            second = scores[1][1] if len(scores) > 1 else -1.0
            if best >= self.known_threshold(grey) and best - second >= self.settings.margin:
                return Match(True, person=person, person_name=gallery.people.get(person), confidence=round(best, 4))
        candidate = None
        if scores and scores[0][1] >= self.settings.candidate_threshold:
            candidate = (scores[0][0], round(scores[0][1], 4))
        cluster, similarity = gallery.nearest_cluster(embedding)
        if cluster is not None and similarity >= self.settings.cluster_threshold:
            cluster.absorb(embedding)
            return Match(False, cluster=cluster.uuid, confidence=round(similarity, 4), candidate=candidate)
        key = str(uuid.uuid4())
        gallery.clusters[key] = Cluster(key, 0, embedding.astype(np.float32), 1, created=now)
        return Match(False, cluster=key, cluster_new=True, candidate=candidate)
