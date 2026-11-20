import base64
from datetime import UTC, datetime
from uuid import uuid4

import numpy as np
import pytest
from pydantic import ValidationError
from sqlalchemy.dialects import postgresql

from app.core.exceptions import NotFound, Unprocessable
from app.models import FaceSample
from app.modules.investigation.embeddings import EMBEDDING_SIZE, to_bytes
from app.modules.investigation.schemas import DetectedFace, SimilarQuery
from app.modules.investigation.services import SimilarService, rank_samples

NOW = datetime(2026, 11, 20, 5, 0, tzinfo=UTC)
CAMERA = uuid4()
JPEG = b"\xff\xd8\xff\xe0" + b"\x00" * 60
PHOTO = "data:image/jpeg;base64," + base64.b64encode(JPEG).decode()


def unit(*values) -> bytes:
    vector = np.zeros(EMBEDDING_SIZE, dtype=np.float32)
    vector[: len(values)] = values
    return to_bytes(vector / np.linalg.norm(vector))


class Rows:
    def __init__(self, rows):
        self.rows = list(rows)

    def all(self):
        return self.rows


class FakeSession:
    def __init__(self, scalar=(), execute=()):
        self.scalar_results = list(scalar)
        self.execute_results = list(execute)
        self.statements = []

    async def scalar(self, statement):
        self.statements.append(statement)
        return self.scalar_results.pop(0)

    async def execute(self, statement):
        self.statements.append(statement)
        return Rows(self.execute_results.pop(0) if self.execute_results else [])


class FakeAnalytics:
    def __init__(self, faces):
        self.faces = faces

    async def embed(self, content, content_type):
        return self.faces


def detected(embedding: bytes, size: float = 120.0) -> DetectedFace:
    return DetectedFace(
        box=[0.0, 0.0, size, size],
        score=0.9,
        size=size,
        quality=0.8,
        embedding=embedding,
        crop=base64.b64encode(JPEG).decode(),
    )


def sample_row(sample_id: int, embedding: bytes, **fields) -> FaceSample:
    values = {
        "id": sample_id,
        "uuid": uuid4(),
        "source": "event",
        "embedding": embedding,
        "crop_path": f"faces/2026/11/19/{sample_id}.jpg",
        "quality": 0.7,
        "event_uuid": uuid4(),
        "camera_uuid": CAMERA,
        "view_name": "Door",
        "seen_at": NOW,
        **fields,
    }
    return FaceSample(**values)


STORED = {
    1: unit(1.0),
    2: unit(1.0, 0.1),
    3: unit(0.0, 1.0),
    4: unit(1.0, 1.0),
    5: unit(1.0, 3.0),
}


def test_ranking_excludes_the_query_and_low_scores():
    ranked = rank_samples(unit(1.0), list(STORED.items()), exclude=1)
    assert [sample_id for sample_id, _ in ranked] == [2, 4, 5]
    assert ranked[-1][1] == pytest.approx(1 / np.sqrt(10))
    assert all(score >= 0.25 for _, score in ranked)


def test_ranking_skips_embeddings_of_the_wrong_size():
    assert rank_samples(unit(1.0), [(1, b"\x00" * 10), (2, unit(1.0))], exclude=None) == [(2, pytest.approx(1.0))]


async def test_a_sample_query_ranks_every_other_sample_and_pages_on_the_server():
    query_sample = sample_row(1, STORED[1])
    second = sample_row(4, STORED[4], cluster_id=7)
    cluster = uuid4()
    session = FakeSession(
        scalar=[query_sample],
        execute=[
            list(STORED.items()),
            [(second, None, None, None, cluster, 3)],
            [(CAMERA, "Front door")],
        ],
    )
    page = await SimilarService(session).similar(SimilarQuery(sample=query_sample.uuid, page=2, page_size=1))
    assert (page.total, page.page, page.page_size) == (3, 2, 1)
    item = page.items[0]
    assert item.sample_uuid == second.uuid
    assert item.score == pytest.approx(0.7071, abs=1e-4)
    assert item.cluster_label == "Unknown 3"
    assert item.cluster_uuid == cluster
    assert item.person_uuid is None
    assert item.camera_name == "Front door"
    assert item.has_crop is True
    detail = session.statements[2].compile(dialect=postgresql.dialect())
    assert detail.params["id_1"] == [4]
    assert "people.deleted_at IS NULL" in str(detail)
    assert "face_samples.deleted_at IS NULL" in str(session.statements[1].compile(dialect=postgresql.dialect()))


async def test_a_page_past_the_end_is_empty():
    session = FakeSession(scalar=[sample_row(1, STORED[1])], execute=[list(STORED.items())])
    page = await SimilarService(session).similar(SimilarQuery(sample=uuid4(), page=5, page_size=10))
    assert page.items == []
    assert page.total == 3


async def test_an_event_query_uses_the_face_sample_of_the_event():
    session = FakeSession(scalar=[None])
    with pytest.raises(NotFound) as error:
        await SimilarService(session).similar(SimilarQuery(event=uuid4()))
    assert error.value.code == "face_event_not_found"
    assert "face_samples.event_uuid = " in str(session.statements[0].compile(dialect=postgresql.dialect()))


async def test_a_photo_query_needs_exactly_one_face():
    service = SimilarService(FakeSession(), analytics=FakeAnalytics([detected(unit(1.0)), detected(unit(0.0, 1.0))]))
    with pytest.raises(Unprocessable) as error:
        await service.similar(SimilarQuery(photo=PHOTO))
    assert error.value.code == "photo_rejected"
    assert error.value.message == "2 faces found; use a photo of one person"


async def test_a_photo_query_excludes_nothing():
    person = uuid4()
    best = sample_row(1, STORED[1], person_id=5, source="upload", event_uuid=None, camera_uuid=None)
    session = FakeSession(
        execute=[list(STORED.items()), [(best, person, "Alice", "#4f8cff", None, None)]],
    )
    service = SimilarService(session, analytics=FakeAnalytics([detected(unit(1.0))]))
    page = await service.similar(SimilarQuery(photo=PHOTO, page_size=1))
    assert page.total == 4
    assert page.items[0].sample_uuid == best.uuid
    assert page.items[0].score == pytest.approx(1.0)
    assert page.items[0].person_name == "Alice"
    assert page.items[0].source == "upload"
    assert page.items[0].camera_name is None


def test_exactly_one_query_is_sent():
    with pytest.raises(ValidationError):
        SimilarQuery()
    with pytest.raises(ValidationError):
        SimilarQuery(sample=uuid4(), event=uuid4())
    with pytest.raises(ValidationError):
        SimilarQuery(sample=uuid4(), page_size=500)
