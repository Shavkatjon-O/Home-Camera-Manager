import base64
import re
from datetime import UTC, datetime
from itertools import count
from uuid import uuid4

import numpy as np
import pytest
from pydantic import ValidationError
from sqlalchemy.dialects import postgresql

from app.core.exceptions import NotFound
from app.models import Event, FaceSample, Person, UnknownCluster
from app.modules.investigation.embeddings import EMBEDDING_SIZE, mean_embedding, to_bytes
from app.modules.investigation.schemas import FaceResult
from app.modules.investigation.services import FaceResultService, face_summaries

NOW = datetime(2026, 11, 20, 5, 0, tzinfo=UTC)
STARTED = 1763600000.25
SEEN = 1763600001.5
FACE_ID = uuid4()
CAMERA = uuid4()
CROP = "faces/2026/11/20/face.jpg"
VIEW = uuid4()

DETAIL_KEYS = {
    "person_uuid",
    "cluster_uuid",
    "confidence",
    "candidate",
    "view",
    "view_name",
    "track",
    "related_event",
    "faces",
    "quality",
    "box",
    "alert",
}
CASTS = re.compile(r"::(?:TIMESTAMP WITH TIME ZONE|VARCHAR|INTEGER|BIGINT|UUID|JSONB|TEXT|BOOLEAN|FLOAT)")


def unit(*values) -> bytes:
    vector = np.zeros(EMBEDDING_SIZE, dtype=np.float32)
    vector[: len(values)] = values
    return to_bytes(vector / np.linalg.norm(vector))


class Rows:
    def __init__(self, rows):
        self.rows = list(rows)

    def all(self):
        return self.rows


def sql(statement) -> str:
    return " ".join(CASTS.sub("", str(statement.compile(dialect=postgresql.dialect()))).split())


class FakeSession:
    def __init__(self, scalar=(), scalars=(), execute=()):
        self.scalar_results = list(scalar)
        self.scalars_results = list(scalars)
        self.execute_results = list(execute)
        self.statements = []
        self.added = []
        self.commits = 0
        self.flushes = 0
        self.locks = 0
        self.ids = count(100)

    def add(self, item):
        self.added.append(item)

    async def flush(self):
        self.flushes += 1
        for item in self.added:
            if item.id is None:
                item.id = next(self.ids)

    async def commit(self):
        self.commits += 1

    async def refresh(self, item):
        item.created_at = item.created_at or datetime.fromtimestamp(SEEN, UTC)
        item.updated_at = item.updated_at or datetime.fromtimestamp(SEEN, UTC)

    async def scalar(self, statement):
        self.statements.append(statement)
        return self.scalar_results.pop(0)

    async def scalars(self, statement):
        self.statements.append(statement)
        return list(self.scalars_results.pop(0))

    async def execute(self, statement):
        if "pg_advisory_xact_lock" in sql(statement):
            self.locks += 1
            return Rows([])
        self.statements.append(statement)
        return Rows(self.execute_results.pop(0) if self.execute_results else [])


def result(**fields) -> FaceResult:
    values = {
        "id": str(FACE_ID),
        "action": "open",
        "camera": str(CAMERA),
        "view": "ptz2-lens2",
        "view_name": "PTZ 2 Lens 2",
        "track": 4123,
        "related_event": "a1b2",
        "started_at": STARTED,
        "seen_at": SEEN,
        "status": "unknown",
        "person": None,
        "cluster": None,
        "cluster_new": True,
        "confidence": 0.62,
        "candidate": None,
        "embedding": base64.b64encode(unit(1.0)).decode(),
        "quality": 0.73,
        "faces": 3,
        "crop": CROP,
        "box": [0.41, 0.12, 0.47, 0.25],
        "alert": False,
        **fields,
    }
    return FaceResult.model_validate(values)


def person_row() -> Person:
    return Person(id=5, uuid=uuid4(), name="Alice", notes=None, color="#4f8cff")


def cluster_row(**fields) -> UnknownCluster:
    values = {
        "id": 7,
        "uuid": uuid4(),
        "number": 3,
        "seen_count": 4,
        "first_seen_at": datetime(2025, 11, 19, tzinfo=UTC),
        "last_seen_at": datetime(2025, 11, 19, 12, tzinfo=UTC),
        "centroid": unit(1.0),
        **fields,
    }
    return UnknownCluster(**values)


def added(session, kind):
    return [item for item in session.added if isinstance(item, kind)]


async def test_a_known_face_creates_its_event_and_sample():
    person = person_row()
    session = FakeSession(scalar=[person, None, None])
    candidate = {"person": str(uuid4()), "score": 0.41}
    ack = await FaceResultService(session).store(
        result(status="known", person=str(person.uuid), cluster_new=False, candidate=candidate)
    )
    event = added(session, Event)[0]
    sample = added(session, FaceSample)[0]
    assert event.uuid == FACE_ID
    assert event.kind == "face_known"
    assert event.source_topic == "analytics/face_known"
    assert event.source == "analytics"
    assert event.label == "person"
    assert event.camera_uuid == CAMERA
    assert event.started_at == datetime.fromtimestamp(STARTED, UTC)
    assert event.ended_at == datetime.fromtimestamp(SEEN, UTC)
    assert event.snapshot_path == CROP
    assert event.thumbnail_path == CROP
    assert set(event.details) == DETAIL_KEYS
    assert event.details["person_uuid"] == str(person.uuid)
    assert event.details["cluster_uuid"] is None
    assert event.details["candidate"] == candidate
    assert event.details["view_name"] == "PTZ 2 Lens 2"
    assert "Alice" not in str(event.details)
    assert sample.source == "event"
    assert sample.person_id == person.id
    assert sample.cluster_id is None
    assert sample.event_uuid == FACE_ID
    assert sample.embedding == unit(1.0)
    assert sample.crop_path == CROP
    assert (sample.quality, sample.confidence) == (0.73, 0.62)
    assert (sample.camera_uuid, sample.view, sample.track_id) == (CAMERA, "ptz2-lens2", 4123)
    assert sample.seen_at == datetime.fromtimestamp(SEEN, UTC)
    assert ack.event == FACE_ID
    assert ack.sample == sample.uuid
    assert ack.cluster_number is None
    assert session.locks == 1
    assert session.commits == 1


async def test_an_unknown_face_starts_a_cluster_with_the_next_number():
    cluster_uuid = uuid4()
    session = FakeSession(scalar=[None, 2, None, None], scalars=[[unit(1.0)]])
    ack = await FaceResultService(session).store(result(cluster=str(cluster_uuid)))
    cluster = added(session, UnknownCluster)[0]
    sample = added(session, FaceSample)[0]
    event = added(session, Event)[0]
    assert cluster.uuid == cluster_uuid
    assert cluster.number == 3
    assert cluster.seen_count == 1
    assert cluster.first_seen_at == cluster.last_seen_at == datetime.fromtimestamp(SEEN, UTC)
    assert cluster.centroid == unit(1.0)
    assert sample.cluster_id == cluster.id
    assert sample.person_id is None
    assert event.kind == "face_unknown"
    assert event.details["cluster_uuid"] == str(cluster_uuid)
    assert event.details["person_uuid"] is None
    assert ack.cluster_number == 3
    assert "max(unknown_clusters.number)" in sql(session.statements[1])
    centroid_query = sql(session.statements[-1])
    assert "SELECT face_samples.embedding" in centroid_query
    assert "face_samples.cluster_id = " in centroid_query


async def test_a_new_cluster_without_an_id_gets_one():
    session = FakeSession(scalar=[None, None, None], scalars=[[unit(1.0)]])
    ack = await FaceResultService(session).store(result(cluster=None, cluster_new=True))
    cluster = added(session, UnknownCluster)[0]
    assert cluster.uuid is not None
    assert cluster.number == 1
    assert ack.cluster_number == 1


async def test_a_new_face_event_of_a_known_cluster_counts_and_moves_the_centroid():
    cluster = cluster_row()
    session = FakeSession(scalar=[cluster, None, None], scalars=[[unit(1.0), unit(0.0, 1.0)]])
    await FaceResultService(session).store(result(cluster=str(cluster.uuid), cluster_new=False))
    assert added(session, UnknownCluster) == []
    assert cluster.seen_count == 5
    assert cluster.last_seen_at == datetime.fromtimestamp(SEEN, UTC)
    assert cluster.first_seen_at == datetime(2025, 11, 19, tzinfo=UTC)
    assert cluster.centroid == mean_embedding([unit(1.0), unit(0.0, 1.0)])


async def test_a_repeated_open_does_not_count_twice():
    cluster = cluster_row()
    event = Event(id=9, uuid=FACE_ID, kind="face_unknown", source_topic="analytics/faces", details={})
    sample = FaceSample(id=11, uuid=uuid4(), cluster_id=7, source="event", event_uuid=FACE_ID)
    session = FakeSession(scalar=[cluster, event, sample], scalars=[[unit(1.0)]])
    ack = await FaceResultService(session).store(result(cluster=str(cluster.uuid), cluster_new=True))
    assert session.added == []
    assert cluster.seen_count == 4
    assert ack.sample == sample.uuid


async def test_an_update_relabels_the_event_and_empties_the_old_cluster():
    person = person_row()
    cluster = cluster_row(seen_count=1)
    event = Event(
        id=9,
        uuid=FACE_ID,
        camera_uuid=CAMERA,
        kind="face_unknown",
        source_topic="analytics/faces",
        snapshot_path=CROP,
        thumbnail_path=CROP,
        details={"cluster_uuid": str(cluster.uuid)},
    )
    sample = FaceSample(id=11, uuid=uuid4(), cluster_id=7, source="event", event_uuid=FACE_ID, embedding=unit(1.0))
    session = FakeSession(scalar=[person, event, sample, cluster], scalars=[[]])
    ack = await FaceResultService(session).store(
        result(
            action="update",
            status="known",
            person=str(person.uuid),
            cluster_new=False,
            embedding=base64.b64encode(unit(0.0, 1.0)).decode(),
            confidence=0.8,
        )
    )
    assert session.added == []
    assert event.kind == "face_known"
    assert event.details["person_uuid"] == str(person.uuid)
    assert event.details["cluster_uuid"] is None
    assert event.details["confidence"] == 0.8
    assert sample.person_id == person.id
    assert sample.cluster_id is None
    assert sample.embedding == unit(0.0, 1.0)
    assert cluster.seen_count == 0
    assert cluster.centroid is None
    assert cluster.deleted_at is not None
    assert ack.sample == sample.uuid
    assert ack.cluster_number is None
    assert session.commits == 1


async def test_an_update_into_another_cluster_moves_the_count():
    old = cluster_row(id=7, seen_count=2)
    new = cluster_row(id=8, number=4, seen_count=0)
    event = Event(id=9, uuid=FACE_ID, kind="face_unknown", source_topic="analytics/faces", details={})
    sample = FaceSample(id=11, uuid=uuid4(), cluster_id=7, source="event", event_uuid=FACE_ID)
    session = FakeSession(scalar=[new, event, sample, old], scalars=[[unit(1.0)], [unit(0.0, 1.0)]])
    ack = await FaceResultService(session).store(result(action="update", cluster=str(new.uuid), cluster_new=False))
    assert sample.cluster_id == 8
    assert new.seen_count == 1
    assert old.seen_count == 1
    assert old.deleted_at is None
    assert old.centroid == unit(0.0, 1.0)
    assert ack.cluster_number == 4


async def test_a_face_of_a_deleted_cluster_brings_it_back():
    cluster = cluster_row(deleted_at=NOW)
    session = FakeSession(scalar=[cluster, None, None], scalars=[[unit(1.0)]])
    await FaceResultService(session).store(result(cluster=str(cluster.uuid), cluster_new=False))
    assert cluster.deleted_at is None
    assert added(session, UnknownCluster) == []


async def test_a_known_face_of_a_missing_person_is_not_found():
    session = FakeSession(scalar=[None])
    with pytest.raises(NotFound) as error:
        await FaceResultService(session).store(result(status="known", person=str(uuid4()), cluster_new=False))
    assert error.value.code == "person_not_found"
    assert session.commits == 0


@pytest.mark.parametrize(
    "fields",
    [
        {"status": "known", "person": None},
        {"status": "unknown", "cluster": None, "cluster_new": False},
        {"crop": "../secret.jpg"},
        {"crop": "/data/events/faces/a.jpg"},
        {"embedding": base64.b64encode(b"\x00" * 16).decode()},
        {"box": [0.1, 0.2]},
    ],
)
def test_face_results_are_validated(fields):
    with pytest.raises(ValidationError):
        result(**fields)


async def test_face_events_resolve_names_when_read():
    person = person_row()
    cluster_uuid = uuid4()
    sample_uuid = uuid4()
    known = Event(
        uuid=uuid4(),
        kind="face_known",
        snapshot_path=None,
        details={"person_uuid": str(person.uuid), "confidence": 0.9},
    )
    unknown = Event(uuid=uuid4(), kind="face_unknown", snapshot_path=CROP, details={"cluster_uuid": str(cluster_uuid)})
    motion = Event(uuid=uuid4(), kind="motion", details={})
    session = FakeSession(
        execute=[
            [(person.uuid, "Alice", "#4f8cff")],
            [(cluster_uuid, 3)],
            [(known.uuid, sample_uuid, CROP)],
        ]
    )
    faces = await face_summaries(session, [known, unknown, motion])
    assert set(faces) == {known.uuid, unknown.uuid}
    assert faces[known.uuid].status == "known"
    assert faces[known.uuid].person_name == "Alice"
    assert faces[known.uuid].person_color == "#4f8cff"
    assert faces[known.uuid].confidence == 0.9
    assert faces[known.uuid].sample_uuid == sample_uuid
    assert faces[known.uuid].has_crop is True
    assert faces[unknown.uuid].status == "unknown"
    assert faces[unknown.uuid].cluster_label == "Unknown 3"
    assert faces[unknown.uuid].person_uuid is None
    assert faces[unknown.uuid].sample_uuid is None
    assert faces[unknown.uuid].has_crop is True
    assert "people.deleted_at IS NULL" in sql(session.statements[0])


async def test_a_stored_face_event_is_announced_with_its_face():
    person = person_row()
    sample_uuid = uuid4()
    session = FakeSession(
        scalar=[person, None, None, "Front door"],
        execute=[[(person.uuid, person.name, person.color)], [(FACE_ID, sample_uuid, CROP)]],
    )
    published = []
    await FaceResultService(session, lambda kind, data: published.append((kind, data))).store(
        result(status="known", person=str(person.uuid), cluster_new=False, view=str(VIEW))
    )
    assert len(published) == 1
    kind, data = published[0]
    assert kind == "event"
    assert data["kind"] == "face_known" and data["source"] == "analytics" and data["label"] == "person"
    assert data["camera_name"] == "Front door"
    assert data["view_uuid"] == str(VIEW)
    assert data["face"]["person_name"] == person.name
    assert data["face"]["sample_uuid"] == str(sample_uuid)
