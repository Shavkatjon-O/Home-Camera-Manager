from uuid import uuid4

import numpy as np
import pytest
from pydantic import ValidationError

from app.modules.analytics.schemas.journeys import JourneyReportIn, SimilarAppearanceQuery
from app.modules.analytics.services.journeys import centred_scores, describe, unit


def test_describe_merges_repeated_views():
    assert describe(["Yard", "Entrance", "Entrance", "Corridor"]) == "Yard, then Entrance, then Corridor"
    assert describe(["Yard", None]) == "Yard, then Removed view"


def test_centred_scores_remove_the_shared_floor():
    generator = np.random.default_rng(3)
    floor = unit(generator.normal(size=512))
    people = [unit(floor * 3 + generator.normal(size=512)) for _ in range(12)]
    query = unit(people[0] + generator.normal(size=512) * 0.3)
    raw = np.array([vector @ query for vector in people])
    assert raw[1:].min() > 0.5
    scores = centred_scores(query, np.stack(people))
    assert scores[0] > 0.6
    assert np.abs(scores[1:]).max() < 0.4
    assert centred_scores(query, np.zeros((0, 512))).shape == (0,)


def test_query_needs_exactly_one_target():
    with pytest.raises(ValidationError):
        SimilarAppearanceQuery()
    with pytest.raises(ValidationError):
        SimilarAppearanceQuery(event_uuid=uuid4(), appearance_uuid=uuid4())
    assert SimilarAppearanceQuery(event_uuid=uuid4()).limit == 20


def test_report_shapes():
    view, camera = str(uuid4()), str(uuid4())
    report = JourneyReportIn(
        journeys=[
            {"id": str(uuid4()), "steps": [{"view": view, "camera": camera, "track": 4, "start": 1.0, "end": 2.0}]}
        ],
        appearances=[{"view": view, "camera": camera, "track": 4, "start": 1.0, "end": 2.0, "embedding": [0.0] * 512}],
    )
    assert report.journeys[0].steps[0].similarity is None
    with pytest.raises(ValidationError):
        JourneyReportIn(
            appearances=[{"view": view, "camera": camera, "track": 4, "start": 1.0, "end": 2.0, "embedding": [0.0] * 3}]
        )
