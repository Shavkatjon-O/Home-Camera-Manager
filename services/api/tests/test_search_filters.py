import re
from datetime import UTC, datetime
from uuid import uuid4

import pytest
from sqlalchemy import select
from sqlalchemy.dialects import postgresql

from app.core.exceptions import Unprocessable
from app.models import Event
from app.modules.investigation.schemas import EventFilters
from app.modules.investigation.services import analytics_filters, event_filters

START = datetime(2026, 11, 19, tzinfo=UTC)
END = datetime(2026, 11, 20, tzinfo=UTC)


CASTS = re.compile(r"::(?:TIMESTAMP WITH TIME ZONE|VARCHAR|UUID|JSONB|TEXT)")


def compiled(conditions):
    return select(Event.id).where(*conditions).compile(dialect=postgresql.dialect())


def text_of(query) -> str:
    return " ".join(CASTS.sub("", str(query)).split())


def test_no_filters_keep_every_live_event():
    query = compiled(event_filters(EventFilters()))
    assert text_of(query).endswith("WHERE events.deleted_at IS NULL")


def test_camera_kind_and_time_filter_on_the_event_columns():
    cameras = [uuid4(), uuid4()]
    query = compiled(event_filters(EventFilters(start=START, end=END, cameras=cameras, kinds=["motion", "face_known"])))
    text = text_of(query)
    assert "events.started_at >= %(started_at_1)s" in text
    assert "events.started_at < %(started_at_2)s" in text
    assert "events.camera_uuid IN (__[POSTCOMPILE_camera_uuid_1])" in text
    assert "events.kind IN (__[POSTCOMPILE_kind_1])" in text
    assert query.params["started_at_1"] == START
    assert query.params["started_at_2"] == END
    assert query.params["camera_uuid_1"] == cameras
    assert query.params["kind_1"] == ["motion", "face_known"]


def test_person_and_cluster_filter_through_the_face_samples():
    person, cluster = uuid4(), uuid4()
    text = text_of(compiled(event_filters(EventFilters(person=person, cluster=cluster))))
    assert (
        "events.uuid IN (SELECT face_samples.event_uuid FROM face_samples "
        "JOIN people ON people.id = face_samples.person_id WHERE people.uuid = "
    ) in text
    assert (
        "events.uuid IN (SELECT face_samples.event_uuid FROM face_samples "
        "JOIN unknown_clusters ON unknown_clusters.id = face_samples.cluster_id WHERE unknown_clusters.uuid = "
    ) in text
    assert text.count("face_samples.deleted_at IS NULL") == 2


def test_analytics_filters_use_the_event_columns_and_details():
    view = uuid4()
    query = compiled(analytics_filters([str(view), "not-a-view"], ["person", "car"], ["porch"], ["gate"], True))
    text = text_of(query)
    assert "events.view_uuid IN " in text
    assert "events.label IN " in text
    assert text.count("events.details ->> ") == 2
    assert "events.alert IS true" in text
    values = list(query.params.values())
    assert [view] in values
    assert ["person", "car"] in values
    assert "zone" in values and "line" in values


def test_unset_analytics_filters_add_nothing():
    assert analytics_filters([], [], [], [], False) == []


def test_the_search_uses_the_analytics_filters():
    text = text_of(compiled(event_filters(EventFilters(views=[str(uuid4())], alert=True))))
    assert "events.view_uuid IN " in text
    assert "events.alert IS true" in text


def test_a_range_that_ends_before_it_starts_is_refused():
    with pytest.raises(Unprocessable) as error:
        event_filters(EventFilters(start=END, end=START))
    assert error.value.code == "invalid_range"
