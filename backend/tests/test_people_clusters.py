import re
from datetime import UTC, datetime
from itertools import count
from uuid import uuid4

import numpy as np
import pytest
from sqlalchemy.dialects import postgresql

from app.core.exceptions import NotFound, Unprocessable
from app.models import FaceSample, Person, UnknownCluster
from app.modules.people.embeddings import EMBEDDING_SIZE, mean_embedding, to_bytes, to_vector
from app.modules.people.schemas import ClusterName
from app.modules.people.services import ClusterService, recompute_centroid

NOW = datetime(2026, 11, 20, 5, 0, tzinfo=UTC)
CAMERA = uuid4()
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


def params(statement) -> dict:
    return statement.compile(dialect=postgresql.dialect()).params


class FakeSession:
    def __init__(self, scalar=(), scalars=(), execute=()):
        self.scalar_results = list(scalar)
        self.scalars_results = list(scalars)
        self.execute_results = list(execute)
        self.statements = []
        self.added = []
        self.commits = 0
        self.locks = 0
        self.ids = count(100)

    def add(self, item):
        self.added.append(item)

    async def flush(self):
        for item in self.added:
            if item.id is None:
                item.id = next(self.ids)

    async def commit(self):
        self.commits += 1

    async def refresh(self, item):
        if item.created_at is None:
            item.created_at = NOW
        if item.updated_at is None:
            item.updated_at = NOW

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


class FakeStore:
    def __init__(self):
        self.deleted = []

    async def delete(self, relatives):
        self.deleted.extend(relative for relative in relatives if relative)


def cluster_row(**fields) -> UnknownCluster:
    values = {
        "id": 7,
        "uuid": uuid4(),
        "number": 3,
        "seen_count": 5,
        "first_seen_at": datetime(2026, 11, 18, tzinfo=UTC),
        "last_seen_at": datetime(2026, 11, 19, tzinfo=UTC),
        "centroid": unit(1.0),
        "created_at": NOW,
        "updated_at": NOW,
        **fields,
    }
    return UnknownCluster(**values)


def person_row(**fields) -> Person:
    values = {
        "id": 5,
        "uuid": uuid4(),
        "name": "Alice",
        "notes": None,
        "color": "#4f8cff",
        "created_at": NOW,
        "updated_at": NOW,
        **fields,
    }
    return Person(**values)


def sample_row(**fields) -> FaceSample:
    values = {
        "id": 20,
        "uuid": uuid4(),
        "cluster_id": 7,
        "source": "event",
        "embedding": unit(1.0),
        "crop_path": "faces/2026/11/19/a.jpg",
        "quality": 0.7,
        "confidence": 0.5,
        "event_uuid": uuid4(),
        "camera_uuid": CAMERA,
        "view_name": "Door",
        "seen_at": datetime(2026, 11, 19, tzinfo=UTC),
        **fields,
    }
    return FaceSample(**values)


async def test_the_centroid_is_the_normalised_mean_of_the_cluster_samples():
    cluster = cluster_row(centroid=None)
    session = FakeSession(scalars=[[unit(1.0), unit(0.0, 1.0), unit(1.0)]])
    assert await recompute_centroid(session, cluster) == 3
    centroid = to_vector(cluster.centroid)
    expected = np.zeros(EMBEDDING_SIZE)
    expected[:2] = [2.0, 1.0]
    expected /= np.linalg.norm(expected)
    assert centroid == pytest.approx(expected.astype(np.float32), abs=1e-6)
    assert "face_samples.deleted_at IS NULL" in sql(session.statements[0])
    empty = cluster_row()
    assert await recompute_centroid(FakeSession(scalars=[[]]), empty) == 0
    assert empty.centroid is None


async def test_the_list_shows_newest_samples_and_sightings_per_cluster():
    cluster = cluster_row()
    upload = sample_row(id=21, source="event", seen_at=datetime(2026, 11, 19, 10, tzinfo=UTC))
    older = sample_row(id=22, seen_at=datetime(2026, 11, 19, 9, tzinfo=UTC))
    session = FakeSession(
        scalar=[1],
        scalars=[[cluster]],
        execute=[[(upload, 1, 1), (older, 2, 2)], [(CAMERA, "Front door")]],
    )
    page = await ClusterService(session, store=FakeStore()).list_page(page=1, page_size=50)
    item = page.items[0]
    assert page.total == 1
    assert item.label == "Unknown 3"
    assert item.seen_count == 5
    assert [sample.uuid for sample in item.samples] == [upload.uuid, older.uuid]
    assert [sighting.sample_uuid for sighting in item.sightings] == [upload.uuid, older.uuid]
    assert item.samples[0].camera_name == "Front door"
    assert "ORDER BY unknown_clusters.last_seen_at DESC" in sql(session.statements[1])
    ranked = sql(session.statements[2])
    assert "row_number() OVER (PARTITION BY face_samples.cluster_id ORDER BY face_samples.seen_at DESC" in ranked
    assert "PARTITION BY face_samples.cluster_id, face_samples.source" in ranked


async def test_naming_a_cluster_after_an_existing_person_moves_everything():
    cluster = cluster_row()
    person = person_row()
    session = FakeSession(scalar=[cluster, person])
    read = await ClusterService(session, store=FakeStore()).name(cluster.uuid, ClusterName(person=person.uuid))
    move, relabel = session.statements[2], session.statements[3]
    assert sql(move).startswith("UPDATE face_samples SET person_id=")
    assert "cluster_id=%(cluster_id)s" in sql(move)
    assert params(move)["person_id"] == person.id
    assert params(move)["cluster_id"] is None
    query = sql(relabel)
    assert query.startswith("UPDATE events SET kind=")
    assert "details=(events.details || " in query
    assert "events.kind = " in query
    assert "events.details ->> " in query
    values = params(relabel)
    assert values["kind"] == "face_known"
    assert {"person_uuid": str(person.uuid)} in values.values()
    assert "face_unknown" in values.values()
    assert str(cluster.uuid) in values.values()
    assert cluster.deleted_at is not None
    assert cluster.centroid is None
    assert read.uuid == person.uuid
    assert session.locks == 1
    assert session.commits == 1


async def test_naming_a_cluster_with_a_new_name_creates_the_person():
    cluster = cluster_row()
    session = FakeSession(scalar=[cluster], execute=[[("#4f8cff", 2), ("#45C25F", 1)]])
    read = await ClusterService(session, store=FakeStore()).name(cluster.uuid, ClusterName(name="  Bob  "))
    person = session.added[0]
    assert isinstance(person, Person)
    assert person.name == "Bob"
    assert person.color == "#f0a92e"
    assert person.id is not None
    assert params(session.statements[2])["person_id"] == person.id
    assert read.name == "Bob"


async def test_naming_needs_either_a_person_or_a_name():
    with pytest.raises(ValueError):
        ClusterName()
    with pytest.raises(ValueError):
        ClusterName(person=uuid4(), name="Bob")


async def test_naming_after_a_missing_person_is_not_found():
    session = FakeSession(scalar=[cluster_row(), None])
    with pytest.raises(NotFound) as error:
        await ClusterService(session, store=FakeStore()).name(uuid4(), ClusterName(person=uuid4()))
    assert error.value.code == "person_not_found"
    assert session.commits == 0


async def test_merging_clusters_adds_counts_and_recomputes_the_centroid():
    source = cluster_row(id=7, seen_count=3, first_seen_at=datetime(2026, 11, 10, tzinfo=UTC))
    target = cluster_row(id=8, number=4, seen_count=5, last_seen_at=datetime(2026, 11, 15, tzinfo=UTC))
    session = FakeSession(scalar=[source, target], scalars=[[unit(1.0), unit(0.0, 1.0)]])
    read = await ClusterService(session, store=FakeStore()).merge(source.uuid, target.uuid)
    move, relabel = session.statements[2], session.statements[3]
    assert params(move)["cluster_id"] == 8
    assert "WHERE face_samples.cluster_id = " in sql(move)
    assert {"cluster_uuid": str(target.uuid)} in params(relabel).values()
    assert "kind" not in params(relabel)
    assert target.seen_count == 8
    assert target.first_seen_at == datetime(2026, 11, 10, tzinfo=UTC)
    assert target.last_seen_at == datetime(2026, 11, 19, tzinfo=UTC)
    assert target.centroid == mean_embedding([unit(1.0), unit(0.0, 1.0)])
    assert source.deleted_at is not None
    assert target.deleted_at is None
    assert read.uuid == target.uuid
    assert read.seen_count == 8


async def test_a_cluster_cannot_merge_into_itself():
    same = uuid4()
    with pytest.raises(Unprocessable):
        await ClusterService(FakeSession(), store=FakeStore()).merge(same, same)


async def test_deleting_a_cluster_removes_samples_crops_and_event_crops():
    cluster = cluster_row()
    store = FakeStore()
    session = FakeSession(
        scalar=[cluster],
        execute=[[("faces/2026/11/19/a.jpg",)], [], [("faces/2026/11/19/a.jpg", "faces/2026/11/19/a.jpg")]],
    )
    await ClusterService(session, store=store).delete(cluster.uuid)
    assert sql(session.statements[2]).startswith("DELETE FROM face_samples WHERE face_samples.cluster_id = ")
    strip = sql(session.statements[4])
    assert strip.startswith("UPDATE events SET snapshot_path=%(snapshot_path)s, thumbnail_path=%(thumbnail_path)s")
    assert "events.kind = " in strip
    assert cluster.deleted_at is not None
    assert cluster.centroid is None
    assert sorted(set(store.deleted)) == ["faces/2026/11/19/a.jpg"]
    assert session.commits == 1
