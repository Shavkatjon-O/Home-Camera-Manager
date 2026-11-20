"""Schemas of person appearances and journeys across cameras."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field, model_validator

__all__ = [
    "AppearanceIn",
    "AppearanceMatch",
    "JourneyIn",
    "JourneyList",
    "JourneyRead",
    "JourneyReportIn",
    "JourneyStepIn",
    "JourneyStepRead",
    "SimilarAppearanceQuery",
    "SimilarAppearances",
]

EMBEDDING_SIZE = 512


class AppearanceIn(BaseModel):
    """A finished person track's appearance as the analytics service reports it.

    Attributes:
        view: View id.
        camera: Camera id.
        track: Tracker id.
        start: First sighting, seconds since the epoch.
        end: Last sighting.
        embedding: The unit appearance vector.
        samples: Crops averaged into it.
        box: Best person box in normalized view coordinates.
        journey: Journey id, if the track was linked.
    """

    view: UUID
    camera: UUID
    track: int
    start: float
    end: float
    embedding: list[float] = Field(min_length=EMBEDDING_SIZE, max_length=EMBEDDING_SIZE)
    samples: int = Field(0, ge=0)
    box: list[float] = Field(default_factory=list, max_length=4)
    journey: UUID | None = None


class JourneyStepIn(BaseModel):
    """One step of a journey as the analytics service reports it.

    Attributes:
        view: View id.
        camera: Camera id.
        track: Tracker id.
        start: First sighting, seconds since the epoch.
        end: Last sighting.
        similarity: Centred appearance similarity to the step before, None for the first step.
    """

    view: UUID
    camera: UUID
    track: int
    start: float
    end: float
    similarity: float | None = None


class JourneyIn(BaseModel):
    """A journey as the analytics service reports it.

    Attributes:
        id: Journey id.
        steps: Steps in time order.
        updated_at: When the journey last changed, seconds since the epoch.
    """

    id: UUID
    steps: list[JourneyStepIn] = Field(min_length=1, max_length=50)
    updated_at: float | None = None


class JourneyReportIn(BaseModel):
    """Finished tracks and changed journeys from one tick of the analytics service.

    Attributes:
        journeys: Changed journeys.
        appearances: Finished track appearances.
    """

    journeys: list[JourneyIn] = Field(default_factory=list, max_length=500)
    appearances: list[AppearanceIn] = Field(default_factory=list, max_length=500)


class JourneyStepRead(BaseModel):
    """One step of a journey as the API returns it.

    Attributes:
        view_uuid: View of the step.
        view_name: Its name, None when the view was removed.
        camera_uuid: Camera of the step.
        camera_name: Its name, None when the camera was removed.
        track: Tracker id.
        started_at: First sighting.
        ended_at: Last sighting.
        similarity: Similarity to the step before.
        event_uuid: An analytics event of the track on that view, if any.
    """

    view_uuid: UUID
    view_name: str | None
    camera_uuid: UUID
    camera_name: str | None
    track: int
    started_at: datetime
    ended_at: datetime
    similarity: float | None
    event_uuid: UUID | None = None


class JourneyRead(BaseModel):
    """A journey as the API returns it.

    Attributes:
        uuid: Journey id.
        description: The views in order, such as Yard, then Entrance, then Corridor.
        started_at: Start of the first step.
        ended_at: End of the last step.
        steps: Steps in time order.
    """

    uuid: UUID
    description: str
    started_at: datetime
    ended_at: datetime
    steps: list[JourneyStepRead]


class JourneyList(BaseModel):
    """Journeys in a time range.

    Attributes:
        items: Journeys, newest first.
    """

    items: list[JourneyRead]


class SimilarAppearanceQuery(BaseModel):
    """A search for the same person across cameras by appearance.

    Attributes:
        event_uuid: A person event whose track to search for.
        appearance_uuid: A stored appearance to search for.
        start: Earliest sighting to consider.
        end: Latest sighting to consider.
        limit: Most matches returned.
    """

    event_uuid: UUID | None = None
    appearance_uuid: UUID | None = None
    start: datetime | None = None
    end: datetime | None = None
    limit: int = Field(20, ge=1, le=100)

    @model_validator(mode="after")
    def one_query(self) -> "SimilarAppearanceQuery":
        """Require exactly one thing to search for.

        Returns:
            The query.

        Raises:
            ValueError: If neither or both are given.
        """
        if (self.event_uuid is None) == (self.appearance_uuid is None):
            raise ValueError("Give exactly one of event_uuid and appearance_uuid")
        return self


class AppearanceMatch(BaseModel):
    """A track that looks like the query.

    Attributes:
        uuid: Appearance id.
        view_uuid: View of the track.
        view_name: Its name, None when the view was removed.
        camera_uuid: Camera of the track.
        camera_name: Its name, None when the camera was removed.
        started_at: First sighting.
        ended_at: Last sighting.
        similarity: Centred appearance similarity to the query.
        journey_uuid: Journey of the track, if linked.
        event_uuid: An analytics event of the track, if any.
    """

    uuid: UUID
    view_uuid: UUID
    view_name: str | None
    camera_uuid: UUID
    camera_name: str | None
    started_at: datetime
    ended_at: datetime
    similarity: float
    journey_uuid: UUID | None
    event_uuid: UUID | None


class SimilarAppearances(BaseModel):
    """The tracks most like the query.

    Attributes:
        query_uuid: Appearance searched for.
        items: Matches, most similar first.
    """

    query_uuid: UUID
    items: list[AppearanceMatch]
