import base64
import re
from uuid import uuid4

import numpy as np
from sqlalchemy.dialects import postgresql

from app.modules.investigation.embeddings import EMBEDDING_SIZE, to_bytes
from app.modules.investigation.schemas import GalleryCluster, GalleryPerson
from app.modules.investigation.services import GalleryService, gallery_version

CASTS = re.compile(r"::(?:TIMESTAMP WITH TIME ZONE|VARCHAR|INTEGER|BIGINT|UUID|JSONB|TEXT|BOOLEAN|FLOAT)")


def unit(*values) -> bytes:
    vector = np.zeros(EMBEDDING_SIZE, dtype=np.float32)
    vector[: len(values)] = values
    return to_bytes(vector / np.linalg.norm(vector))


def b64(raw: bytes) -> str:
    return base64.b64encode(raw).decode()


class Rows:
    def __init__(self, rows):
        self.rows = list(rows)

    def all(self):
        return self.rows


class FakeSession:
    def __init__(self, execute=()):
        self.execute_results = list(execute)
        self.statements = []

    async def execute(self, statement):
        self.statements.append(statement)
        return Rows(self.execute_results.pop(0))


def sql(statement) -> str:
    return " ".join(CASTS.sub("", str(statement.compile(dialect=postgresql.dialect()))).split())


async def test_the_gallery_groups_embeddings_per_person_in_query_order():
    alice, bob, cluster = uuid4(), uuid4(), uuid4()
    session = FakeSession(
        execute=[
            [(alice, "Alice", unit(1.0)), (alice, "Alice", unit(0.0, 1.0)), (bob, "Bob", unit(0.0, 0.0, 1.0))],
            [(cluster, 3, unit(0.5, 0.5), 5)],
        ]
    )
    gallery = await GalleryService(session).build()
    assert [(person.uuid, person.name) for person in gallery.people] == [(alice, "Alice"), (bob, "Bob")]
    assert gallery.people[0].embeddings == [b64(unit(1.0)), b64(unit(0.0, 1.0))]
    assert gallery.people[1].embeddings == [b64(unit(0.0, 0.0, 1.0))]
    assert gallery.clusters[0].model_dump() == {
        "uuid": cluster,
        "number": 3,
        "centroid": b64(unit(0.5, 0.5)),
        "count": 5,
    }
    assert re.fullmatch(r"[0-9a-f]{16}", gallery.version)


async def test_an_empty_gallery_still_has_a_version():
    gallery = await GalleryService(FakeSession(execute=[[], []])).build()
    assert (gallery.people, gallery.clusters) == ([], [])
    assert len(gallery.version) == 16


def test_the_version_follows_the_content():
    person = GalleryPerson(uuid=uuid4(), name="Alice", embeddings=[b64(unit(1.0))])
    cluster = GalleryCluster(uuid=uuid4(), number=3, centroid=b64(unit(0.0, 1.0)), count=2)
    version = gallery_version([person], [cluster])
    assert gallery_version([person.model_copy()], [cluster.model_copy()]) == version
    renamed = person.model_copy(update={"name": "Alicia"})
    more = person.model_copy(update={"embeddings": [*person.embeddings, b64(unit(0.0, 0.0, 1.0))]})
    counted = cluster.model_copy(update={"count": 3})
    versions = {
        version,
        gallery_version([renamed], [cluster]),
        gallery_version([more], [cluster]),
        gallery_version([person], [counted]),
        gallery_version([person], []),
        gallery_version([], [cluster]),
    }
    assert len(versions) == 6


def test_people_get_uploads_first_then_camera_samples_by_quality_capped_at_30():
    statement = GalleryService(None).people_statement()
    query = sql(statement)
    assert "PARTITION BY face_samples.person_id ORDER BY CASE WHEN (face_samples.source = " in query
    assert "THEN face_samples.seen_at END DESC NULLS LAST, face_samples.quality DESC, face_samples.id DESC" in query
    assert "face_samples.person_id IS NOT NULL AND face_samples.deleted_at IS NULL" in query
    assert "people.deleted_at IS NULL" in query
    assert "ORDER BY lower(people.name), people.id, anon_1.rank" in query
    values = statement.compile(dialect=postgresql.dialect()).params.values()
    assert "upload" in values
    assert 30 in values


def test_clusters_need_a_centroid_and_count_their_live_samples():
    query = sql(GalleryService(None).clusters_statement())
    assert "count(face_samples.id)" in query
    assert "LEFT OUTER JOIN face_samples ON face_samples.cluster_id = unknown_clusters.id" in query
    assert "face_samples.deleted_at IS NULL" in query
    assert "unknown_clusters.deleted_at IS NULL AND unknown_clusters.centroid IS NOT NULL" in query
