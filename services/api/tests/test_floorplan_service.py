from datetime import UTC, datetime
from uuid import uuid4

import pytest
from sqlalchemy.dialects import postgresql

from app.core.exceptions import NotFound, Unprocessable
from app.models import FloorPlan
from app.modules.floorplans.schemas import FloorPlanCreate, FloorPlanUpdate
from app.modules.floorplans.services import FloorPlanService

NOW = datetime(2026, 11, 19, 12, 0, tzinfo=UTC)
IMAGE = "data:image/png;base64,iVBORw0KGgo="

WALL = {"id": "w1", "x1": 0.0, "y1": 0.0, "x2": 10.0, "y2": 0.0, "material": "concrete"}
ROUTER = {
    "id": "ap1",
    "name": "Router 1",
    "x": 9.0,
    "y": 7.0,
    "preset": "archer_c64",
    "band_24": True,
    "band_5": True,
    "power_24_dbm": 20.0,
    "power_5_dbm": 23.0,
    "locked": False,
}


class Rows:
    def __init__(self, rows):
        self.rows = rows

    def all(self):
        return self.rows


class FakeSession:
    def __init__(self, scalars=(), rows=()):
        self.scalar_results = list(scalars)
        self.rows = list(rows)
        self.statements = []
        self.added = []
        self.commits = 0

    def add(self, item):
        self.added.append(item)

    async def commit(self):
        self.commits += 1

    async def refresh(self, item):
        if item.uuid is None:
            item.uuid = uuid4()
        if item.created_at is None:
            item.created_at = NOW
            item.updated_at = NOW

    async def scalar(self, statement):
        self.statements.append(statement)
        return self.scalar_results.pop(0)

    async def execute(self, statement):
        self.statements.append(statement)
        return Rows(self.rows)


def stored_plan(**fields) -> FloorPlan:
    values = {
        "id": 1,
        "uuid": uuid4(),
        "name": "House",
        "width_m": 12.0,
        "height_m": 8.0,
        "walls": [WALL],
        "access_points": [ROUTER],
        "devices": [],
        "settings": {"path_loss_exponent": 2.5, "target_dbm": -70.0, "snap_m": 0.25},
        "background_image": None,
        "background_opacity": 0.5,
        "created_at": NOW,
        "updated_at": NOW,
        **fields,
    }
    return FloorPlan(**values)


def sql(statement) -> str:
    return str(statement.compile(dialect=postgresql.dialect()))


async def test_create_stores_plain_json_and_reads_it_back():
    session = FakeSession()
    service = FloorPlanService(session)
    read = await service.create(
        FloorPlanCreate(name="House", width_m=12, height_m=8, walls=[WALL], access_points=[ROUTER])
    )
    plan = session.added[0]
    assert session.commits == 1
    assert plan.walls == [WALL]
    assert plan.access_points == [ROUTER]
    assert plan.devices == []
    assert plan.settings == {"path_loss_exponent": 3.0, "target_dbm": -67.0, "snap_m": 0.1}
    assert read.uuid == plan.uuid
    assert read.has_background is False
    assert read.walls[0].material == "concrete"


async def test_list_pages_newest_first_without_loading_images():
    plans = [stored_plan(id=2), stored_plan(id=1)]
    session = FakeSession(scalars=[7], rows=[(plans[0], True), (plans[1], False)])
    page = await FloorPlanService(session).list_page(page=3, page_size=2)
    assert page.total == 7
    assert (page.page, page.page_size) == (3, 2)
    assert [item.has_background for item in page.items] == [True, False]
    assert page.items[0].settings.snap_m == 0.25
    assert not hasattr(page.items[0], "background_image")
    query = sql(session.statements[1])
    assert "ORDER BY floor_plans.created_at DESC, floor_plans.id DESC" in query
    assert "floor_plans.deleted_at IS NULL" in query
    assert "floor_plans.background_image IS NOT NULL AS has_background" in query
    assert "floor_plans.background_image," not in query
    compiled = session.statements[1].compile(dialect=postgresql.dialect())
    assert compiled.params["param_1"] == 2
    assert compiled.params["param_2"] == 4


async def test_detail_of_a_missing_plan_is_not_found():
    service = FloorPlanService(FakeSession(scalars=[None]))
    with pytest.raises(NotFound) as error:
        await service.detail(uuid4())
    assert error.value.code == "floor_plan_not_found"


async def test_update_changes_only_given_fields():
    plan = stored_plan()
    session = FakeSession(scalars=[plan])
    moved = {**ROUTER, "x": 2.0, "y": 3.0}
    read = await FloorPlanService(session).update(plan.uuid, FloorPlanUpdate(access_points=[moved]))
    assert session.commits == 1
    assert plan.access_points == [moved]
    assert plan.walls == [WALL]
    assert read.access_points[0].x == 2.0


async def test_update_sets_and_clears_the_background():
    plan = stored_plan()
    service = FloorPlanService(FakeSession(scalars=[plan, plan]))
    read = await service.update(plan.uuid, FloorPlanUpdate(background_image=IMAGE, background_opacity=0.3))
    assert read.has_background is True
    assert read.background_image == IMAGE
    assert plan.background_opacity == 0.3
    read = await service.update(plan.uuid, FloorPlanUpdate(background_image=""))
    assert plan.background_image is None
    assert read.has_background is False


async def test_update_refuses_to_shrink_the_plan_under_its_walls():
    plan = stored_plan()
    session = FakeSession(scalars=[plan])
    with pytest.raises(Unprocessable) as error:
        await FloorPlanService(session).update(plan.uuid, FloorPlanUpdate(width_m=9.5))
    assert error.value.code == "outside_plan"
    assert "Wall w1" in error.value.message
    assert plan.width_m == 12.0
    assert session.commits == 0


async def test_update_checks_new_items_against_the_stored_size():
    plan = stored_plan()
    session = FakeSession(scalars=[plan])
    outside = {"id": "d1", "name": "Phone", "x": 3.0, "y": 8.5, "band": "5"}
    with pytest.raises(Unprocessable):
        await FloorPlanService(session).update(plan.uuid, FloorPlanUpdate(devices=[outside]))
    assert plan.devices == []


async def test_update_replaces_settings_with_defaults_filled():
    plan = stored_plan()
    await FloorPlanService(FakeSession(scalars=[plan])).update(plan.uuid, FloorPlanUpdate(settings={"target_dbm": -60}))
    assert plan.settings == {"path_loss_exponent": 3.0, "target_dbm": -60.0, "snap_m": 0.1}


async def test_delete_is_soft():
    plan = stored_plan()
    session = FakeSession(scalars=[plan])
    await FloorPlanService(session).delete(plan.uuid)
    assert plan.deleted_at is not None
    assert session.commits == 1
