import re
from collections import namedtuple
from datetime import UTC, datetime, timedelta
from uuid import uuid4

import numpy as np
from sqlalchemy.dialects import postgresql

from app.models import UnknownCluster
from app.modules.investigation.embeddings import EMBEDDING_SIZE, to_bytes
from app.modules.investigation.services import expired_samples, purge_expired_samples
from app.modules.investigation.services import retention as retention_module

NOW = datetime(2026, 11, 20, 5, 0, tzinfo=UTC)
Expired = namedtuple("Expired", "id crop_path event_uuid cluster_id")
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
    def __init__(self, scalars=(), execute=()):
        self.scalars_results = list(scalars)
        self.execute_results = list(execute)
        self.statements = []
        self.commits = 0
        self.locks = 0

    async def commit(self):
        self.commits += 1

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
    values = {"id": 7, "uuid": uuid4(), "number": 3, "seen_count": 2, "centroid": unit(1.0), **fields}
    return UnknownCluster(**values)


def test_only_camera_samples_older_than_the_cutoff_expire():
    cutoff = NOW - timedelta(days=30)
    statement = expired_samples(cutoff)
    query = sql(statement)
    assert "WHERE face_samples.source = %(source_1)s AND face_samples.seen_at < %(seen_at_1)s" in query
    values = statement.compile(dialect=postgresql.dialect()).params
    assert values["source_1"] == "event"
    assert values["seen_at_1"] == cutoff
    assert values["param_1"] == 500


async def test_expired_samples_go_with_their_crops_and_empty_clusters():
    emptied = cluster_row(id=7)
    kept = cluster_row(id=8, centroid=None)
    first_event, second_event = uuid4(), uuid4()
    store = FakeStore()
    session = FakeSession(
        scalars=[[emptied, kept]],
        execute=[
            [
                Expired(1, "faces/2026/10/01/a.jpg", first_event, 7),
                Expired(2, None, second_event, 8),
                Expired(3, "faces/2026/10/01/c.jpg", None, None),
            ],
            [],
            [("faces/2026/10/01/a.jpg", "faces/2026/10/01/a.jpg")],
            [],
            [(8, unit(0.0, 1.0))],
        ],
    )
    total = await purge_expired_samples(session, NOW, 30, store=store)
    assert total == 3
    assert sql(session.statements[1]).startswith("DELETE FROM face_samples WHERE face_samples.id IN")
    assert session.statements[1].compile(dialect=postgresql.dialect()).params["id_1"] == [1, 2, 3]
    strip = session.statements[2].compile(dialect=postgresql.dialect()).params
    assert sorted(strip["uuid_1"]) == sorted([first_event, second_event])
    assert emptied.deleted_at == NOW
    assert emptied.centroid is None
    assert kept.deleted_at is None
    assert kept.centroid == unit(0.0, 1.0)
    assert set(store.deleted) == {"faces/2026/10/01/a.jpg", "faces/2026/10/01/c.jpg"}
    assert session.commits == 1
    assert session.locks == 1


async def test_nothing_expired_changes_nothing():
    store = FakeStore()
    session = FakeSession(execute=[[]])
    assert await purge_expired_samples(session, NOW, 30, store=store) == 0
    assert len(session.statements) == 1
    assert store.deleted == []
    assert session.commits == 1


async def test_full_batches_repeat_until_a_short_one(monkeypatch):
    monkeypatch.setattr(retention_module, "PURGE_BATCH", 2)
    original = retention_module.expired_samples
    monkeypatch.setattr(retention_module, "expired_samples", lambda cutoff: original(cutoff, 2))
    session = FakeSession(
        execute=[
            [Expired(1, None, None, None), Expired(2, None, None, None)],
            [],
            [Expired(3, None, None, None)],
            [],
        ]
    )
    assert await purge_expired_samples(session, NOW, 30, store=FakeStore()) == 3
    assert session.commits == 2
    assert session.locks == 2
