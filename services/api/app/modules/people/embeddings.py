"""Face embeddings: their wire and stored forms and the vector maths on them.

An embedding is 512 little-endian float32 values, L2-normalised, stored as 2048 raw bytes and sent as standard base64
of those bytes. For normalised vectors the cosine similarity is the dot product.
"""

import base64
import binascii
from collections.abc import Iterable, Sequence

import numpy as np

EMBEDDING_SIZE = 512
EMBEDDING_BYTES = 2048
EMBEDDING_DTYPE = np.dtype("<f4")

NORM_FLOOR = 1e-12


def to_vector(raw: bytes) -> np.ndarray:
    """Turn stored embedding bytes into a vector.

    Args:
        raw: The 2048 raw bytes of an embedding.

    Returns:
        A writable float32 vector of 512 values.
    """
    return np.frombuffer(raw, dtype=EMBEDDING_DTYPE).astype(np.float32)


def to_bytes(vector: np.ndarray) -> bytes:
    """Turn a vector into stored embedding bytes.

    Args:
        vector: Vector of 512 values.

    Returns:
        The values as little-endian float32 bytes.
    """
    return np.asarray(vector, dtype=EMBEDDING_DTYPE).tobytes()


def decode_embedding(text: str | bytes) -> bytes:
    """Decode an embedding from its base64 wire form and check it.

    Args:
        text: Standard base64 of the 2048 raw bytes, or the raw bytes themselves.

    Returns:
        The raw bytes.

    Raises:
        ValueError: When the text is not base64, does not hold 2048 bytes or holds values that are not finite.
    """
    if isinstance(text, bytes) and len(text) == EMBEDDING_BYTES:
        raw = text
    else:
        try:
            raw = base64.b64decode(text, validate=True)
        except (binascii.Error, ValueError) as exc:
            raise ValueError("the embedding is not valid base64") from exc
    if len(raw) != EMBEDDING_BYTES:
        raise ValueError(f"the embedding must hold {EMBEDDING_BYTES} bytes")
    if not np.isfinite(to_vector(raw)).all():
        raise ValueError("the embedding holds values that are not finite")
    return raw


def encode_embedding(raw: bytes) -> str:
    """Encode stored embedding bytes in their base64 wire form.

    Args:
        raw: The raw bytes of an embedding.

    Returns:
        Standard base64 of the bytes.
    """
    return base64.b64encode(raw).decode("ascii")


def normalise(vector: np.ndarray) -> np.ndarray:
    """Scale a vector to unit length.

    Args:
        vector: Vector to scale.

    Returns:
        The vector divided by its L2 norm.

    Raises:
        ValueError: When the vector has no length or its norm is not finite.
    """
    norm = float(np.linalg.norm(vector))
    if not np.isfinite(norm) or norm < NORM_FLOOR:
        raise ValueError("the vector has no direction")
    return vector / norm


def mean_embedding(raws: Iterable[bytes]) -> bytes | None:
    """Average embeddings into one, as the normalised mean of the normalised vectors.

    Embeddings without a direction are left out of the mean.

    Args:
        raws: Raw bytes of the embeddings.

    Returns:
        The raw bytes of the mean, or None when there is nothing to average or the vectors cancel out.
    """
    vectors = []
    for raw in raws:
        try:
            vectors.append(normalise(to_vector(raw)))
        except ValueError:
            continue
    if not vectors:
        return None
    try:
        return to_bytes(normalise(np.mean(vectors, axis=0)))
    except ValueError:
        return None


def stack(raws: Sequence[bytes]) -> np.ndarray:
    """Stack embeddings into a matrix with one row per embedding.

    Args:
        raws: Raw bytes of the embeddings, each 2048 bytes long.

    Returns:
        A float32 matrix of shape (len(raws), 512).
    """
    if not raws:
        return np.empty((0, EMBEDDING_SIZE), dtype=np.float32)
    flat = np.frombuffer(b"".join(raws), dtype=EMBEDDING_DTYPE)
    return flat.reshape(len(raws), EMBEDDING_SIZE).astype(np.float32)


def rank(query: np.ndarray, matrix: np.ndarray, threshold: float) -> list[tuple[int, float]]:
    """Rank the rows of a matrix by their cosine similarity to a query vector.

    Args:
        query: Query vector of 512 values.
        matrix: Matrix with one embedding per row.
        threshold: Lowest similarity to keep.

    Returns:
        Row index and similarity of every row at or above the threshold, most similar first; rows with equal
        similarity keep their order.
    """
    if len(matrix) == 0:
        return []
    direction = normalise(np.asarray(query, dtype=np.float32))
    norms = np.maximum(np.linalg.norm(matrix, axis=1), NORM_FLOOR)
    scores = np.clip(matrix @ direction / norms, -1.0, 1.0)
    keep = np.flatnonzero(scores >= threshold)
    order = keep[np.argsort(-scores[keep], kind="stable")]
    return [(int(index), float(scores[index])) for index in order]
