import base64
import json
from datetime import UTC, datetime
from uuid import uuid4

import httpx
import numpy as np
import pytest

from app.core.exceptions import BadGateway, Unavailable
from app.modules.people import photos
from app.modules.people.analytics import AnalyticsClient
from app.modules.people.crops import CropStore
from app.modules.people.embeddings import EMBEDDING_SIZE, to_bytes
from app.modules.people.models import FaceSample, Person
from app.modules.people.photos import (
    NO_FACE,
    SMALL_FACE,
    UNREADABLE,
    PhotoRejected,
    choose_face,
    decode_photo,
)
from app.modules.people.schemas import DetectedFace, PhotoUploadRequest
from app.modules.people.services import PersonService

NOW = datetime(2026, 11, 20, 5, 0, tzinfo=UTC)
JPEG = b"\xff\xd8\xff\xe0" + b"\x00" * 60
PHOTO = "data:image/jpeg;base64," + base64.b64encode(JPEG).decode()


def unit(*values) -> bytes:
    vector = np.zeros(EMBEDDING_SIZE, dtype=np.float32)
    vector[: len(values)] = values
    return to_bytes(vector / np.linalg.norm(vector))


def face_json(size=178.2, score=0.93, quality=0.81, embedding=None) -> dict:
    return {
        "box": [412.0, 230.5, 412.0 + size, 455.0],
        "score": score,
        "landmarks": [[450.1, 320.2], [540.3, 318.9], [497.0, 370.4], [460.2, 410.8], [535.5, 409.9]],
        "size": size,
        "quality": quality,
        "frontal": 0.94,
        "sharpness": 0.77,
        "embedding": base64.b64encode(embedding or unit(1.0)).decode(),
        "crop": base64.b64encode(JPEG).decode(),
    }


def face(**fields) -> DetectedFace:
    return DetectedFace.model_validate(face_json(**fields))


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
        self.added = []
        self.commits = 0

    def add(self, item):
        self.added.append(item)

    async def commit(self):
        self.commits += 1

    async def scalar(self, statement):
        self.statements.append(statement)
        return self.scalar_results.pop(0)

    async def execute(self, statement):
        self.statements.append(statement)
        return Rows(self.execute_results.pop(0) if self.execute_results else [])


class FakeAnalytics:
    def __init__(self, answers):
        self.answers = list(answers)
        self.calls = []

    async def embed(self, content, content_type):
        self.calls.append((content, content_type))
        answer = self.answers.pop(0)
        if isinstance(answer, Exception):
            raise answer
        return answer


def stored_person() -> Person:
    return Person(id=4, uuid=uuid4(), name="Alice", notes=None, color="#4f8cff", created_at=NOW, updated_at=NOW)


def test_photos_decode_from_data_urls():
    assert decode_photo(PHOTO) == (JPEG, "image/jpeg")
    webp = "data:image/webp;base64," + base64.b64encode(b"RIFF").decode()
    assert decode_photo(webp) == (b"RIFF", "image/webp")


@pytest.mark.parametrize(
    "data",
    [
        "data:image/gif;base64," + base64.b64encode(b"GIF8").decode(),
        "data:image/jpeg;base64,%%%",
        "data:image/jpeg;base64,",
        "data:image/jpeg," + base64.b64encode(JPEG).decode(),
        base64.b64encode(JPEG).decode(),
    ],
)
def test_unreadable_photos_are_rejected(data):
    with pytest.raises(PhotoRejected) as error:
        decode_photo(data)
    assert error.value.reason == UNREADABLE


def test_photos_over_the_size_limit_are_rejected(monkeypatch):
    monkeypatch.setattr(photos, "PHOTO_MAX_BYTES", 10)
    with pytest.raises(PhotoRejected) as error:
        decode_photo(PHOTO)
    assert error.value.reason == UNREADABLE


def test_a_photo_needs_exactly_one_large_enough_face():
    with pytest.raises(PhotoRejected) as error:
        choose_face([])
    assert error.value.reason == NO_FACE
    with pytest.raises(PhotoRejected) as error:
        choose_face([face(), face(size=120.0)])
    assert error.value.reason == "2 faces found; use a photo of one person"
    with pytest.raises(PhotoRejected) as error:
        choose_face([face(size=63.9)])
    assert error.value.reason == SMALL_FACE
    good = face(size=64.0)
    assert choose_face([good, face(score=0.3)]) is good


async def test_the_analytics_client_posts_the_raw_image_with_the_token():
    seen = []

    def answer(request: httpx.Request) -> httpx.Response:
        seen.append(request)
        return httpx.Response(200, json={"width": 1600, "height": 1200, "faces": [face_json()]})

    client = AnalyticsClient("http://analytics:8080/", "secret", transport=httpx.MockTransport(answer))
    faces = await client.embed(JPEG, "image/jpeg")
    request = seen[0]
    assert str(request.url) == "http://analytics:8080/identity/embed"
    assert request.headers["authorization"] == "Bearer secret"
    assert request.headers["content-type"] == "image/jpeg"
    assert request.content == JPEG
    assert faces[0].embedding == unit(1.0)
    assert faces[0].crop == JPEG
    assert faces[0].size == 178.2


@pytest.mark.parametrize(
    ("status", "error", "code"),
    [
        (401, BadGateway, "analytics_refused"),
        (503, Unavailable, "face_models_unavailable"),
        (500, BadGateway, "analytics_failed"),
    ],
)
async def test_the_analytics_client_maps_failures(status, error, code):
    client = AnalyticsClient(
        "http://analytics:8080", "secret", transport=httpx.MockTransport(lambda _: httpx.Response(status))
    )
    with pytest.raises(error) as raised:
        await client.embed(JPEG, "image/jpeg")
    assert raised.value.code == code


async def test_an_image_the_analytics_service_cannot_decode_is_unreadable():
    transport = httpx.MockTransport(lambda _: httpx.Response(400, json={"detail": "cannot decode"}))
    with pytest.raises(PhotoRejected) as error:
        await AnalyticsClient("http://analytics:8080", "secret", transport=transport).embed(JPEG, "image/png")
    assert error.value.reason == "The photo could not be read"


async def test_connection_failures_become_unavailable():
    def refuse(request):
        raise httpx.ConnectError("connection refused", request=request)

    client = AnalyticsClient("http://analytics:8080", "secret", transport=httpx.MockTransport(refuse))
    with pytest.raises(Unavailable) as error:
        await client.embed(JPEG, "image/jpeg")
    assert error.value.code == "analytics_unavailable"
    assert "does not answer" in error.value.message


async def test_unreadable_answers_and_missing_addresses_are_errors():
    garbage = httpx.MockTransport(lambda _: httpx.Response(200, content=json.dumps({"faces": [{"size": 1}]})))
    with pytest.raises(BadGateway) as error:
        await AnalyticsClient("http://analytics:8080", "secret", transport=garbage).embed(JPEG, "image/jpeg")
    assert error.value.code == "analytics_bad_answer"
    with pytest.raises(Unavailable) as error:
        await AnalyticsClient("", "secret").embed(JPEG, "image/jpeg")
    assert error.value.code == "analytics_not_configured"


async def test_enrollment_keeps_good_photos_and_explains_the_rest(tmp_path):
    person = stored_person()
    session = FakeSession(scalar=[person])
    analytics = FakeAnalytics([[], [face(), face()], [face(size=40.0)], [face(embedding=unit(0.0, 1.0), quality=0.7)]])
    service = PersonService(session, store=CropStore(tmp_path), analytics=analytics)
    payload = PhotoUploadRequest(
        photos=[
            {"name": "empty.jpg", "data": PHOTO},
            {"name": "group.jpg", "data": PHOTO},
            {"name": "far.jpg", "data": PHOTO},
            {"name": "broken.jpg", "data": "data:image/jpeg;base64,%%%"},
            {"name": "good.jpg", "data": PHOTO},
        ]
    )
    result = await service.add_photos(person.uuid, payload)
    assert [(item.name, item.reason) for item in result.rejected] == [
        ("empty.jpg", "No face found"),
        ("group.jpg", "2 faces found; use a photo of one person"),
        ("far.jpg", "The face is too small; use a closer photo"),
        ("broken.jpg", "The photo could not be read"),
    ]
    assert len(analytics.calls) == 4
    assert analytics.calls[0] == (JPEG, "image/jpeg")
    sample = session.added[0]
    assert isinstance(sample, FaceSample)
    assert len(session.added) == 1
    assert sample.source == "upload"
    assert sample.person_id == person.id
    assert sample.cluster_id is None
    assert sample.embedding == unit(0.0, 1.0)
    assert sample.quality == 0.7
    assert sample.event_uuid is None
    assert sample.crop_path == f"people/{person.uuid}/{sample.uuid}.jpg"
    assert (tmp_path / sample.crop_path).read_bytes() == JPEG
    assert session.commits == 1
    assert [item.uuid for item in result.added] == [sample.uuid]
    assert result.added[0].has_crop is True
    assert result.person.uuid == person.uuid


async def test_enrollment_with_only_rejections_commits_nothing(tmp_path):
    person = stored_person()
    session = FakeSession(scalar=[person])
    service = PersonService(session, store=CropStore(tmp_path), analytics=FakeAnalytics([[]]))
    result = await service.add_photos(person.uuid, PhotoUploadRequest(photos=[{"name": "a.jpg", "data": PHOTO}]))
    assert result.added == []
    assert session.commits == 0
    assert session.added == []


async def test_a_failed_enrollment_removes_the_crops_it_wrote(tmp_path):
    person = stored_person()
    session = FakeSession(scalar=[person])
    analytics = FakeAnalytics([[face()], Unavailable("analytics_unavailable", "down")])
    service = PersonService(session, store=CropStore(tmp_path), analytics=analytics)
    payload = PhotoUploadRequest(photos=[{"name": "a.jpg", "data": PHOTO}, {"name": "b.jpg", "data": PHOTO}])
    with pytest.raises(Unavailable):
        await service.add_photos(person.uuid, payload)
    assert session.commits == 0
    assert not (tmp_path / "people" / str(person.uuid)).exists()


async def test_enrollment_without_an_analytics_client_is_unavailable(tmp_path):
    person = stored_person()
    service = PersonService(FakeSession(scalar=[person]), store=CropStore(tmp_path))
    with pytest.raises(Unavailable):
        await service.add_photos(person.uuid, PhotoUploadRequest(photos=[{"name": "a.jpg", "data": PHOTO}]))
