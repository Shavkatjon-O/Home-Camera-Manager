from uuid import uuid4

import pytest
from pydantic import ValidationError

from app.models import AnalyticsLine, AnalyticsView, AnalyticsZone
from app.modules.analytics.schemas import LineInput, RulesUpdate, ZoneInput
from app.modules.analytics.services.config import view_config
from tests.fakes import entitlements


def view(moving=False, tamper=None, faces=None, **flags):
    return AnalyticsView(
        appearance=flags.get("appearance", True),
        falls=flags.get("falls", False),
        plates=flags.get("plates", False),
        follow=flags.get("follow", False),
        uuid=uuid4(),
        camera_uuid=uuid4(),
        lens=2,
        name="PTZ Lens 2",
        profile="perimeter",
        enabled=True,
        fps=8.0,
        tamper=tamper,
        faces=faces,
        moving=moving,
        tuning={},
    )


def zone(whole=False):
    return AnalyticsZone(
        uuid=uuid4(),
        name="Entrance",
        polygon=[[0, 0], [1, 0], [1, 1]],
        whole_view=whole,
        labels=["person"],
        min_dwell=1.0,
        loiter_seconds=0.0,
        crowd_count=0,
        schedule=[],
        alert={},
        enabled=True,
        reference="analytics/references/x/1.jpg",
    )


def line():
    return AnalyticsLine(
        uuid=uuid4(),
        name="Door",
        points=[[0.1, 0.5], [0.9, 0.5]],
        labels=[],
        direction="in",
        schedule=[],
        alert={},
        enabled=True,
        reference="analytics/references/x/1.jpg",
    )


def test_fixed_views_drop_references_and_keep_the_profile_tamper_default():
    data = view_config(view(), [zone()], [line()])
    assert data["zones"][0]["reference"] is None
    assert data["lines"][0]["reference"] is None
    assert "tamper" not in data


def test_moving_views_keep_references_except_whole_view_and_send_moving():
    data = view_config(view(moving=True), [zone(), zone(whole=True)], [line()])
    assert data["zones"][0]["reference"] == "analytics/references/x/1.jpg"
    assert data["zones"][1]["reference"] is None
    assert data["lines"][0]["reference"] == "analytics/references/x/1.jpg"
    assert "tamper" not in data
    assert data["moving"] is True
    assert view_config(view(moving=True, tamper=True), [], [])["tamper"] is True


def test_whole_view_zone_needs_no_points_and_a_polygon_needs_three():
    assert ZoneInput(name="All", whole_view=True).full_polygon() == [[0.0, 0.0], [1.0, 0.0], [1.0, 1.0], [0.0, 1.0]]
    with pytest.raises(ValueError):
        ZoneInput(name="Bad", polygon=[(0.1, 0.1), (0.2, 0.2)]).full_polygon()


def test_rules_validation():
    with pytest.raises(ValidationError):
        ZoneInput(name="Yard", polygon=[(0.1, 0.1), (0.2, 0.2), (1.5, 0.3)])
    with pytest.raises(ValidationError):
        ZoneInput(name="Yard", labels=["unicorn"])
    with pytest.raises(ValidationError):
        LineInput(name="Gate", points=((0.5, 0.5), (0.5, 0.501)))
    with pytest.raises(ValidationError):
        ZoneInput(name="Yard", schedule=[{"start": "25:00", "end": "06:00"}])
    with pytest.raises(ValidationError):
        ZoneInput(name="Yard", reference="../../etc/passwd")
    rules = RulesUpdate(
        zones=[{"name": "Yard", "polygon": [[0, 0], [1, 0], [1, 1]], "labels": ["person", "vehicle"]}],
        lines=[{"name": "Gate", "points": [[0.1, 0.2], [0.4, 0.2]], "direction": "in"}],
    )
    assert rules.zones[0].labels == ["person", "vehicle"]
    assert rules.lines[0].direction == "in"


def test_faces_are_sent_only_when_the_view_overrides_its_profile():
    assert "faces" not in view_config(view(), [], [])
    assert view_config(view(faces=True), [], [])["faces"] is True
    assert view_config(view(faces=False), [], [])["faces"] is False


def test_features_a_plan_leaves_out_are_not_run():
    granted = entitlements(features=frozenset({"journeys"}))
    data = view_config(
        view(falls=True, plates=True, follow=True, faces=True), [zone()], [line()], faces_allowed=True, granted=granted
    )
    assert not data["falls"]["enabled"] and not data["plates"]["enabled"] and not data["follow"]["enabled"]
    assert data["faces"] is False and data["appearance"] is True
    assert data["zones"][0]["object_labels"] == [] and data["zones"][0]["left_seconds"] == 0.0
    everything = view_config(view(falls=True), [zone()], [line()], granted=entitlements())
    assert everything["falls"]["enabled"]
