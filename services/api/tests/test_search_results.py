import re
from datetime import UTC, datetime, timedelta
from uuid import uuid4

from sqlalchemy.dialects import postgresql

from app.models import AnalyticsLine, AnalyticsView, AnalyticsZone, Event
from app.modules.events.schemas import event_read
from app.modules.investigation.schemas import EventFilters
from app.modules.investigation.services import EventSearchService, FacetService, result_fields

NOW = datetime(2026, 11, 20, 5, 0, tzinfo=UTC)
CAMERA = uuid4()
CASTS = re.compile(r"::(?:TIMESTAMP WITH TIME ZONE|VARCHAR|INTEGER|BIGINT|UUID|JSONB|TEXT|BOOLEAN|FLOAT)")


class Rows:
    def __init__(self, rows):
        self.rows = list(rows)

    def all(self):
        return self.rows


class FakeSession:
    def __init__(self, scalar=(), scalars=(), execute=()):
        self.scalar_results = list(scalar)
        self.scalars_results = list(scalars)
        self.execute_results = list(execute)
        self.statements = []

    async def scalar(self, statement):
        self.statements.append(statement)
        return self.scalar_results.pop(0)

    async def scalars(self, statement):
        self.statements.append(statement)
        return list(self.scalars_results.pop(0))

    async def execute(self, statement):
        self.statements.append(statement)
        return Rows(self.execute_results.pop(0) if self.execute_results else [])


def sql(statement) -> str:
    return " ".join(CASTS.sub("", str(statement.compile(dialect=postgresql.dialect()))).split())


def event_row(**fields) -> Event:
    values = {
        "id": 1,
        "uuid": uuid4(),
        "camera_uuid": CAMERA,
        "kind": "motion",
        "source_topic": "tns1:RuleEngine/CellMotionDetector/Motion",
        "started_at": NOW - timedelta(seconds=30),
        "ended_at": NOW - timedelta(seconds=10),
        "camera_time": None,
        "snapshot_path": "2026/11/20/a.jpg",
        "thumbnail_path": "2026/11/20/a.thumb.jpg",
        "details": {},
        "created_at": NOW,
        "updated_at": NOW,
        **fields,
    }
    return Event(**values)


def test_known_kinds_keep_the_fields_of_the_events_list():
    event = event_row()
    fields = result_fields(event, "Door", NOW)
    expected = event_read(event, "Door", NOW).model_dump()
    del expected["face"]
    assert fields == expected


def test_face_kinds_get_the_same_fields():
    event = event_row(kind="face_known", ended_at=None, details={"person_uuid": None})
    fields = result_fields(event, None, NOW)
    assert fields["kind"] == "face_known"
    assert fields["ongoing"] is True
    assert fields["duration_seconds"] == 30.0
    assert fields["has_snapshot"] is True
    assert set(fields) == set(event_read(event_row(), None, NOW).model_dump()) - {"face"}


async def test_the_search_pages_newest_first_and_adds_the_face():
    person = uuid4()
    sample = uuid4()
    face = event_row(id=2, kind="face_known", details={"person_uuid": str(person), "confidence": 0.62})
    motion = event_row(id=1)
    session = FakeSession(
        scalar=[12],
        scalars=[[face, motion]],
        execute=[
            [(CAMERA, "Front door")],
            [(person, "Alice", "#4f8cff")],
            [(face.uuid, sample, "faces/2026/11/20/x.jpg")],
        ],
    )
    page = await EventSearchService(session).search(EventFilters(kinds=["face_known", "motion"]), 2, 2)
    assert (page.total, page.page, page.page_size) == (12, 2, 2)
    first, second = page.items
    assert first.kind == "face_known"
    assert first.camera_name == "Front door"
    assert first.face.person_name == "Alice"
    assert first.face.sample_uuid == sample
    assert first.face.confidence == 0.62
    assert second.kind == "motion"
    assert second.face is None
    listing = session.statements[1].compile(dialect=postgresql.dialect())
    assert "ORDER BY events.started_at DESC, events.id DESC" in str(listing)
    assert listing.params["param_1"] == 2
    assert listing.params["param_2"] == 2


async def test_an_empty_search_reads_no_names():
    session = FakeSession(scalar=[0], scalars=[[]])
    page = await EventSearchService(session).search(EventFilters(), 1, 50)
    assert page.items == []
    assert len(session.statements) == 2


async def test_facets_list_kinds_labels_views_people_and_clusters():
    alice, cluster, camera = uuid4(), uuid4(), uuid4()
    view = AnalyticsView(id=7, uuid=uuid4(), camera_uuid=camera, lens=2, name="PTZ 2 Lens 2")
    zone = AnalyticsZone(id=1, uuid=uuid4(), view_id=7, name="Entrance")
    line = AnalyticsLine(id=2, uuid=uuid4(), view_id=7, name="Door")
    orphan = AnalyticsLine(id=3, uuid=uuid4(), view_id=99, name="Gone")
    session = FakeSession(
        scalars=[["face_known", "motion"], ["car", "person"], [view], [zone], [line, orphan]],
        execute=[[(alice, "Alice", "#4f8cff")], [(cluster, 3)]],
    )
    facets = await FacetService(session).facets()
    assert facets.kinds == ["face_known", "motion"]
    assert facets.labels == ["car", "person"]
    assert facets.views[0].model_dump() == {"id": str(view.uuid), "name": "PTZ 2 Lens 2", "camera_uuid": camera}
    assert facets.zones[0].model_dump() == {"id": str(zone.uuid), "name": "Entrance", "view": str(view.uuid)}
    assert [item.name for item in facets.lines] == ["Door"]
    assert facets.people[0].model_dump() == {"uuid": alice, "name": "Alice", "color": "#4f8cff"}
    assert facets.clusters[0].model_dump() == {"uuid": cluster, "label": "Unknown 3"}
    assert "SELECT DISTINCT events.label" in sql(session.statements[1])
    assert "people.deleted_at IS NULL" in sql(session.statements[5])
    assert "unknown_clusters.deleted_at IS NULL" in sql(session.statements[6])
