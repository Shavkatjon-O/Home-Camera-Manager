import base64
import math

import numpy as np
import pytest

from app.modules.investigation.embeddings import (
    EMBEDDING_BYTES,
    EMBEDDING_SIZE,
    decode_embedding,
    encode_embedding,
    mean_embedding,
    normalise,
    rank,
    stack,
    to_bytes,
    to_vector,
)


def unit(*values) -> bytes:
    vector = np.zeros(EMBEDDING_SIZE, dtype=np.float32)
    vector[: len(values)] = values
    return to_bytes(vector / np.linalg.norm(vector))


def test_embeddings_round_trip_through_base64():
    raw = unit(0.6, 0.8)
    text = encode_embedding(raw)
    assert len(base64.b64decode(text)) == EMBEDDING_BYTES
    assert decode_embedding(text) == raw
    vector = to_vector(raw)
    assert vector.dtype == np.float32
    assert vector[:2].tolist() == pytest.approx([0.6, 0.8])


def test_embeddings_are_little_endian_float32():
    raw = unit(1.0)
    assert raw[:4] == np.array([1.0], dtype="<f4").tobytes()


def test_decoding_rejects_bad_text_and_wrong_sizes():
    with pytest.raises(ValueError, match="base64"):
        decode_embedding("not base64 at all!")
    with pytest.raises(ValueError, match="2048"):
        decode_embedding(base64.b64encode(b"\x00" * 100).decode())
    nan = np.full(EMBEDDING_SIZE, np.nan, dtype="<f4").tobytes()
    with pytest.raises(ValueError, match="finite"):
        decode_embedding(base64.b64encode(nan).decode())


def test_decoding_accepts_raw_bytes_of_the_right_size():
    raw = unit(0.0, 1.0)
    assert decode_embedding(raw) == raw


def test_normalise_scales_to_unit_length_and_refuses_zero():
    assert np.linalg.norm(normalise(np.array([3.0, 4.0]))) == pytest.approx(1.0)
    with pytest.raises(ValueError):
        normalise(np.zeros(4))


def test_mean_is_the_normalised_mean_of_normalised_vectors():
    first = unit(1.0, 0.0)
    second = to_bytes(np.concatenate([[0.0, 5.0], np.zeros(EMBEDDING_SIZE - 2)]))
    mean = to_vector(mean_embedding([first, second]))
    assert mean[:2].tolist() == pytest.approx([1 / math.sqrt(2), 1 / math.sqrt(2)], abs=1e-6)
    assert np.linalg.norm(mean) == pytest.approx(1.0)


def test_mean_skips_zero_vectors_and_handles_nothing_to_average():
    zero = np.zeros(EMBEDDING_SIZE, dtype="<f4").tobytes()
    assert mean_embedding([]) is None
    assert mean_embedding([zero]) is None
    assert mean_embedding([zero, unit(1.0)]) == unit(1.0)
    assert mean_embedding([unit(1.0), unit(-1.0)]) is None


def test_stack_builds_one_row_per_embedding():
    matrix = stack([unit(1.0), unit(0.0, 1.0), unit(0.0, 0.0, 1.0)])
    assert matrix.shape == (3, EMBEDDING_SIZE)
    assert matrix[1, 1] == pytest.approx(1.0)
    assert stack([]).shape == (0, EMBEDDING_SIZE)


def test_rank_orders_by_cosine_and_drops_scores_under_the_threshold():
    matrix = stack([unit(0.0, 1.0), unit(1.0, 1.0), unit(1.0, 0.1), unit(-1.0)])
    ranked = rank(to_vector(unit(1.0)), matrix, 0.25)
    assert [index for index, _ in ranked] == [2, 1]
    assert ranked[0][1] == pytest.approx(1 / math.sqrt(1.01))
    assert ranked[1][1] == pytest.approx(1 / math.sqrt(2))


def test_rank_keeps_the_threshold_itself_and_the_order_of_ties():
    matrix = stack([unit(1.0), unit(0.0, 1.0), unit(1.0)])
    ranked = rank(to_vector(unit(1.0)), matrix, 0.0)
    assert [index for index, _ in ranked] == [0, 2, 1]
    assert ranked[2][1] == pytest.approx(0.0)
    assert rank(to_vector(unit(1.0)), stack([]), 0.25) == []
