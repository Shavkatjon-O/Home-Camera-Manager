import re
from datetime import UTC, datetime
from uuid import uuid4

import pytest
from pydantic import ValidationError
from sqlalchemy.dialects import postgresql

from app.core.exceptions import NotFound, Unprocessable
from app.modules.people.models import FaceSample, Person
from app.modules.people.schemas import PersonCreate, PersonUpdate
from app.modules.people.services import PersonService, SampleService

NOW = datetime(2026, 11, 20, 5, 0, tzinfo=UTC)
CAMERA = uuid4()
EMBEDDING = b"\x00" * 2048
CASTS = re.compile(r"::(?:TIMESTAMP WITH TIME ZONE|VARCHAR|INTEGER|BIGINT|UUID|JSONB|TEXT|BOOLEAN|FLOAT)")


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

    def add(self, item):
        self.added.append(item)

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
    def __init__(self, root=None):
        self.deleted = []
        self.root = root

    async def delete(self, relatives):
        self.deleted.extend(relative for relative in relatives if relative)

    def resolve(self, relative):
        return None if not relative or self.root is None else self.root / relative


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
        "person_id": 5,
        "source": "event",
        "embedding": EMBEDDING,
        "crop_path": "faces/2026/11/19/a.jpg",
        "quality": 0.7,
        "confidence": 0.6,
        "event_uuid": uuid4(),
        "camera_uuid": CAMERA,
        "view_name": "PTZ 2 Lens 2",
        "seen_at": datetime(2026, 11, 19, 8, tzinfo=UTC),
        **fields,
    }
    return FaceSample(**values)


async def test_people_list_by_name_with_counts_samples_and_sightings():
    alice = person_row()
    bob = person_row(id=6, name="bob")
    upload = sample_row(id=21, source="upload", event_uuid=None, camera_uuid=None, view_name=None, confidence=None)
    seen = sample_row(id=22)
    last_seen = datetime(2026, 11, 19, 8, tzinfo=UTC)
    session = FakeSession(
        scalar=[2],
        scalars=[[alice, bob]],
        execute=[
            [(5, 2, 1, last_seen)],
            [(upload, 1, 1), (seen, 2, 1)],
            [(CAMERA, "Front door")],
        ],
    )
    page = await PersonService(session, store=FakeStore()).list_page(page=1, page_size=50)
    first, second = page.items
    assert page.total == 2
    assert (first.sample_count, first.upload_count, first.last_seen_at) == (2, 1, last_seen)
    assert [sample.uuid for sample in first.samples] == [upload.uuid, seen.uuid]
    assert [sighting.sample_uuid for sighting in first.sightings] == [seen.uuid]
    assert first.sightings[0].camera_name == "Front door"
    assert first.sightings[0].view_name == "PTZ 2 Lens 2"
    assert first.samples[0].camera_name is None
    assert (second.sample_count, second.samples, second.last_seen_at) == (0, [], None)
    listing = sql(session.statements[1])
    assert "ORDER BY lower(people.name), people.id" in listing
    assert "people.deleted_at IS NULL" in listing
    stats = sql(session.statements[2])
    assert "count(*) FILTER (WHERE face_samples.source = " in stats
    assert "max(face_samples.seen_at) FILTER (WHERE face_samples.source = " in stats
    ranked = session.statements[3].compile(dialect=postgresql.dialect())
    assert 6 in ranked.params.values()
    assert 5 in ranked.params.values()


async def test_a_new_person_gets_the_least_used_palette_color():
    session = FakeSession(execute=[[("#4f8cff", 1), ("#45c25f", 1), ("#f0a92e", 1)]])
    read = await PersonService(session, store=FakeStore()).create(PersonCreate(name=" Carol ", notes="  "))
    person = session.added[0]
    assert person.name == "Carol"
    assert person.notes is None
    assert person.color == "#f2555a"
    assert read.sample_count == 0
    assert session.commits == 1


async def test_a_given_color_is_kept_in_lower_case():
    session = FakeSession()
    await PersonService(session, store=FakeStore()).create(PersonCreate(name="Dan", color="#ABCDEF"))
    assert session.added[0].color == "#abcdef"
    assert session.statements == []


def test_person_fields_are_validated():
    with pytest.raises(ValidationError):
        PersonCreate(name="   ")
    with pytest.raises(ValidationError):
        PersonCreate(name="Eve", color="blue")
    with pytest.raises(ValidationError):
        PersonCreate(name="x" * 81)
    with pytest.raises(ValidationError):
        PersonUpdate(name=None)
    assert PersonUpdate(notes=None).model_fields_set == {"notes"}


async def test_update_changes_only_given_fields():
    person = person_row(notes="Neighbour")
    session = FakeSession(scalar=[person])
    read = await PersonService(session, store=FakeStore()).update(person.uuid, PersonUpdate(name="Alicia"))
    assert person.name == "Alicia"
    assert person.notes == "Neighbour"
    assert read.name == "Alicia"
    await PersonService(FakeSession(scalar=[person]), store=FakeStore()).update(person.uuid, PersonUpdate(notes=None))
    assert person.notes is None


async def test_deleting_a_person_removes_samples_and_crops_and_strips_events():
    person = person_row()
    store = FakeStore()
    session = FakeSession(
        scalar=[person],
        execute=[
            [("faces/2026/11/19/a.jpg",), (f"people/{person.uuid}/s.jpg",)],
            [],
            [("faces/2026/11/19/a.jpg", "faces/2026/11/19/a.jpg"), ("faces/2026/11/18/b.jpg", None)],
        ],
    )
    await PersonService(session, store=store).delete(person.uuid)
    assert "DELETE FROM face_samples WHERE face_samples.person_id = " in sql(session.statements[2])
    select_events = sql(session.statements[3])
    assert "events.kind IN (__[POSTCOMPILE_kind_1])" in select_events
    assert "events.details ->> " in select_events
    assert str(person.uuid) in params(session.statements[4]).values()
    assert person.deleted_at is not None
    assert sorted(set(store.deleted)) == sorted(
        {"faces/2026/11/19/a.jpg", f"people/{person.uuid}/s.jpg", "faces/2026/11/18/b.jpg"}
    )
    assert session.locks == 1
    assert session.commits == 1


async def test_merging_people_moves_samples_and_events_to_the_target():
    source = person_row()
    target = person_row(id=6, name="Alicia")
    session = FakeSession(scalar=[source, target])
    read = await PersonService(session, store=FakeStore()).merge(source.uuid, target.uuid)
    move, relabel = session.statements[2], session.statements[3]
    assert params(move)["person_id"] == 6
    assert "WHERE face_samples.person_id = " in sql(move)
    assert {"person_uuid": str(target.uuid)} in params(relabel).values()
    assert str(source.uuid) in params(relabel).values()
    assert source.deleted_at is not None
    assert read.uuid == target.uuid


async def test_a_person_cannot_merge_into_themselves():
    same = uuid4()
    with pytest.raises(Unprocessable):
        await PersonService(FakeSession(), store=FakeStore()).merge(same, same)


async def test_deleting_one_sample_strips_its_event_crop():
    person = person_row()
    sample = sample_row()
    store = FakeStore()
    session = FakeSession(scalar=[person, sample], execute=[[], [(sample.crop_path, sample.crop_path)]])
    await SampleService(session, store=store).delete(person.uuid, sample.uuid)
    lookup = sql(session.statements[1])
    assert "face_samples.person_id = " in lookup
    assert "DELETE FROM face_samples WHERE face_samples.id = " in sql(session.statements[2])
    assert sample.event_uuid in params(session.statements[3]).values()
    assert set(store.deleted) == {sample.crop_path}
    assert session.commits == 1


async def test_deleting_a_sample_of_someone_else_is_not_found():
    session = FakeSession(scalar=[person_row(), None])
    with pytest.raises(NotFound) as error:
        await SampleService(session, store=FakeStore()).delete(uuid4(), uuid4())
    assert error.value.code == "sample_not_found"
    assert session.commits == 0


async def test_a_crop_is_served_only_when_its_file_exists(tmp_path):
    sample = sample_row(crop_path="people/x/s.jpg")
    (tmp_path / "people/x").mkdir(parents=True)
    store = FakeStore(tmp_path)
    with pytest.raises(NotFound) as error:
        await SampleService(FakeSession(scalar=[sample]), store=store).crop(sample.uuid)
    assert error.value.code == "crop_not_found"
    (tmp_path / "people/x/s.jpg").write_bytes(b"\xff\xd8")
    assert (
        await SampleService(FakeSession(scalar=[sample]), store=store).crop(sample.uuid) == tmp_path / "people/x/s.jpg"
    )
    with pytest.raises(NotFound) as error:
        await SampleService(FakeSession(scalar=[None]), store=store).crop(uuid4())
    assert error.value.code == "sample_not_found"
