import numpy as np

from app.identity.align import TEMPLATE
from app.identity.gallery import encode_vector
from app.identity.probe import Candidate
from app.identity.settings import IdentitySettings


def unit(seed, size=512):
    vector = np.random.default_rng(seed).normal(size=size).astype(np.float32)
    return vector / np.linalg.norm(vector)


def blend(base, other, weight):
    vector = base * (1 - weight) + other * weight
    return (vector / np.linalg.norm(vector)).astype(np.float32)


def with_similarity(base, similarity, seed):
    noise = unit(seed)
    noise = noise - (noise @ base) * base
    noise /= np.linalg.norm(noise)
    vector = similarity * base + np.sqrt(1 - similarity**2) * noise
    return vector.astype(np.float32)


def settings(**changes):
    values = {
        "known_threshold": 0.42,
        "ir_extra": 0.05,
        "margin": 0.08,
        "candidate_threshold": 0.28,
        "cluster_threshold": 0.45,
        "cooldown": 600.0,
        "min_score": 0.6,
        "min_face": 36.0,
    }
    values.update(changes)
    return IdentitySettings(**values)


def aligned_marker(marker):
    pixels = np.zeros((112, 112, 3), dtype=np.uint8)
    pixels[0, 0, 0] = marker
    pixels[1, 1] = (10, 60, 120)
    return pixels.tobytes()


def candidate(track, at, marker=1, quality=0.8, pad=0, grey=False):
    return Candidate(
        pad=pad,
        track=track,
        at=at,
        box=(0.4, 0.2, 0.45, 0.3),
        score=0.9,
        quality=quality,
        size=80.0,
        frontal=0.9,
        sharpness=0.7,
        grey=grey,
        aligned=aligned_marker(marker),
        crop=bytes(160 * 160 * 3),
    )


class FakeModels:
    def __init__(self, vectors):
        self.vectors = vectors
        self.loaded = True
        self.calls = []

    def load(self):
        return None

    def embed(self, faces):
        self.calls.append(len(faces))
        return np.stack([self.vectors[int(face[0, 0, 0])] for face in faces])

    def status(self):
        return {"loaded": True}


def gallery_payload(people=(), clusters=(), version="v1"):
    return {
        "version": version,
        "people": [
            {"uuid": key, "name": name, "embeddings": [encode_vector(v) for v in vectors]}
            for key, name, vectors in people
        ],
        "clusters": [
            {"uuid": key, "number": number, "centroid": encode_vector(vector), "count": count}
            for key, number, vector, count in clusters
        ],
    }


def template_landmarks(scale=1.0, shift=(0.0, 0.0)):
    return TEMPLATE * scale + np.array(shift, dtype=np.float32)
