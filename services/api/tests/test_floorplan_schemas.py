import pytest
from pydantic import ValidationError

from app.modules.operations.enums import AccessPointPreset, Band, WallMaterial
from app.modules.operations.schemas import (
    AccessPoint,
    Device,
    FloorPlanCreate,
    FloorPlanUpdate,
    PlanSettings,
    Wall,
    clean_background,
)

IMAGE = "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQ=="


def wall(**fields) -> dict:
    return {"id": "w1", "x1": 0, "y1": 0, "x2": 4, "y2": 0, "material": "brick", **fields}


def router(**fields) -> dict:
    return {"id": "ap1", "name": "Router 1", "x": 1, "y": 1, **fields}


def device(**fields) -> dict:
    return {"id": "d1", "name": "Phone", "x": 2, "y": 2, **fields}


def test_wall_accepts_every_material():
    for material in WallMaterial:
        assert Wall(**wall(material=material.value)).material == material


def test_wall_defaults_to_brick():
    fields = wall()
    fields.pop("material")
    assert Wall(**fields).material == WallMaterial.BRICK


@pytest.mark.parametrize(
    "fields",
    [
        {"material": "paper"},
        {"x2": 0, "y2": 0},
        {"x1": -0.5},
        {"y2": 200.5},
        {"id": "has space"},
        {"id": ""},
        {"id": "x" * 41},
        {"color": "red"},
        {"x1": float("nan")},
        {"x1": float("inf")},
    ],
)
def test_wall_rejects_bad_fields(fields):
    with pytest.raises(ValidationError):
        Wall(**wall(**fields))


def test_access_point_defaults_and_strips_its_name():
    access_point = AccessPoint(**router(name="  Hall router "))
    assert access_point.name == "Hall router"
    assert access_point.preset == AccessPointPreset.GENERIC
    assert access_point.band_24 and access_point.band_5
    assert access_point.power_24_dbm == 20
    assert access_point.power_5_dbm == 23
    assert access_point.locked is False


@pytest.mark.parametrize(
    "fields",
    [
        {"name": "   "},
        {"name": "x" * 61},
        {"power_24_dbm": -1},
        {"power_5_dbm": 30.5},
        {"preset": "archer_c80"},
        {"locked": "maybe"},
    ],
)
def test_access_point_rejects_bad_fields(fields):
    with pytest.raises(ValidationError):
        AccessPoint(**router(**fields))


def test_device_band_takes_both_bands_only():
    assert Device(**device()).band == Band.BAND_24
    assert Device(**device(band="5")).band == Band.BAND_5
    with pytest.raises(ValidationError):
        Device(**device(band="6"))


def test_settings_defaults_and_ranges():
    settings = PlanSettings()
    assert settings.path_loss_exponent == 3.0
    assert settings.target_dbm == -67
    assert settings.snap_m == 0.1
    assert PlanSettings(path_loss_exponent=4.0, target_dbm=-90, snap_m=0.05).snap_m == 0.05
    for fields in ({"path_loss_exponent": 1.5}, {"target_dbm": -39}, {"snap_m": 2}, {"grid": 1}):
        with pytest.raises(ValidationError):
            PlanSettings(**fields)


def test_create_fills_defaults():
    plan = FloorPlanCreate(name="  House ", width_m=15, height_m=12)
    assert plan.name == "House"
    assert plan.walls == [] and plan.access_points == [] and plan.devices == []
    assert plan.settings == PlanSettings()
    assert plan.background_image is None
    assert plan.background_opacity == 0.5


@pytest.mark.parametrize("size", [0.5, 200.1])
def test_create_rejects_plan_sizes_out_of_range(size):
    with pytest.raises(ValidationError):
        FloorPlanCreate(name="House", width_m=size, height_m=12)


@pytest.mark.parametrize(
    "items",
    [
        {"walls": [wall(x2=15.5)]},
        {"access_points": [router(y=12.01)]},
        {"devices": [device(x=16)]},
    ],
)
def test_create_rejects_items_outside_the_plan(items):
    with pytest.raises(ValidationError) as error:
        FloorPlanCreate(name="House", width_m=15, height_m=12, **items)
    assert "outside the 15 by 12 m plan" in str(error.value)


def test_create_accepts_items_on_the_plan_edge():
    plan = FloorPlanCreate(
        name="House",
        width_m=15,
        height_m=12,
        walls=[wall(x1=0, y1=12, x2=15, y2=12)],
        access_points=[router(x=15, y=12)],
    )
    assert plan.walls[0].y2 == 12


@pytest.mark.parametrize("field,item", [("walls", wall), ("access_points", router), ("devices", device)])
def test_create_rejects_repeated_ids(field, item):
    with pytest.raises(ValidationError) as error:
        FloorPlanCreate(name="House", width_m=15, height_m=12, **{field: [item(), item()]})
    assert "is used twice" in str(error.value)


def test_background_must_be_an_image_data_url():
    assert clean_background(IMAGE) == IMAGE
    assert clean_background("") is None
    assert clean_background(None) is None
    for value in ("http://example.com/plan.jpg", "data:text/html;base64,PGI+", "data:image/png;base64,***"):
        with pytest.raises(ValueError):
            clean_background(value)
    assert FloorPlanCreate(name="House", width_m=15, height_m=12, background_image=IMAGE).background_image == IMAGE


def test_background_has_a_size_limit():
    image = "data:image/jpeg;base64," + "A" * 4_000_000
    with pytest.raises(ValidationError):
        FloorPlanCreate(name="House", width_m=15, height_m=12, background_image=image)


def test_update_rejects_empty_required_fields():
    for field in ("name", "width_m", "walls", "settings", "background_opacity"):
        with pytest.raises(ValidationError):
            FloorPlanUpdate(**{field: None})


def test_update_clears_the_background_with_an_empty_string():
    update = FloorPlanUpdate(background_image="")
    assert update.background_image is None
    assert update.model_fields_set == {"background_image"}


def test_update_keeps_only_given_fields():
    update = FloorPlanUpdate(walls=[wall()], settings={"target_dbm": -70})
    assert update.model_fields_set == {"walls", "settings"}
    assert update.settings.path_loss_exponent == 3.0
    with pytest.raises(ValidationError):
        FloorPlanUpdate(width_m=10, unknown=1)
