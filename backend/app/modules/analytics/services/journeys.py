"""Person appearances and journeys from the analytics service, and finding a person across cameras by look.

Appearance vectors of different people already agree to about 0.5 in raw cosine, so every comparison first takes
away the mean vector of the appearances around the query and scales the rest back to unit length. In that centred
space unrelated tracks score near zero and the same person seen in the same light scores well above.
"""

from datetime import UTC, datetime, timedelta
from uuid import UUID

import numpy as np
from sqlalchemy import and_, func, select
from sqlalchemy.dialects.postgresql import insert

from app.core.base_service import BaseModelService
from app.core.exceptions import NotFound
from app.models import AnalyticsAppearance, AnalyticsJourney, AnalyticsView, Event
from app.modules.analytics.schemas.journeys import (
    AppearanceMatch,
    JourneyList,
    JourneyRead,
    JourneyReportIn,
    JourneyStepRead,
    SimilarAppearanceQuery,
    SimilarAppearances,
)
from app.modules.events.services.events import camera_names
from app.modules.people.embeddings import to_bytes, to_vector

__all__ = ["JourneyService", "centred_scores", "describe", "unit"]

DEFAULT_WINDOW = timedelta(days=7)
MATCH_MIN = 0.3
EVENT_SLACK = timedelta(seconds=5)
STEP_SLACK = timedelta(seconds=1)
NORM_FLOOR = 1e-12


def unit(vector: np.ndarray) -> np.ndarray:
    """Scale a vector to unit length.

    Args:
        vector: The vector.

    Returns:
        The unit vector, or the vector itself when it is all zeros.
    """
    norm = float(np.linalg.norm(vector))
    return vector / norm if norm > NORM_FLOOR else vector


def centred_scores(query: np.ndarray, candidates: np.ndarray) -> np.ndarray:
    """Score candidates against a query after taking away their common mean.

    Args:
        query: Unit query vector.
        candidates: N by D unit candidate vectors.

    Returns:
        N similarities from -1 to 1.
    """
    if not len(candidates):
        return np.zeros(0, np.float32)
    mean = np.vstack([candidates, query[None]]).mean(axis=0)
    centred = candidates - mean
    centred /= np.maximum(np.linalg.norm(centred, axis=1, keepdims=True), NORM_FLOOR)
    return centred @ unit(query - mean)


def describe(names: list[str | None]) -> str:
    """Describe a journey by its views in order, merging repeats.

    Args:
        names: View name of every step.

    Returns:
        A text such as Yard, then Entrance, then Corridor.
    """
    parts: list[str] = []
    for name in names:
        name = name or "Removed view"
        if not parts or parts[-1] != name:
            parts.append(name)
    return ", then ".join(parts)


def moment(value: float) -> datetime:
    """Convert epoch seconds to an aware time.

    Args:
        value: Seconds since the epoch.

    Returns:
        The time in UTC.
    """
    return datetime.fromtimestamp(value, UTC)


class JourneyService(BaseModelService[AnalyticsJourney]):
    """Stores appearances and journeys and searches appearances.

    Attributes:
        model: Journeys across views.
        not_found_code: Error code of an unknown journey.
    """

    model = AnalyticsJourney
    not_found_code = "journey_not_found"

    async def ingest(self, report: JourneyReportIn) -> None:
        """Store finished appearances and changed journeys.

        Args:
            report: The report.
        """
        if report.appearances:
            rows = [
                {
                    "view_uuid": item.view,
                    "camera_uuid": item.camera,
                    "track_id": item.track,
                    "started_at": moment(item.start),
                    "ended_at": moment(item.end),
                    "samples": item.samples,
                    "embedding": to_bytes(unit(np.asarray(item.embedding, np.float32))),
                    "box": [round(value, 4) for value in item.box],
                    "journey_uuid": item.journey,
                }
                for item in report.appearances
            ]
            statement = insert(AnalyticsAppearance).values(rows)
            statement = statement.on_conflict_do_update(
                index_elements=["view_uuid", "track_id", "started_at"],
                set_={
                    "ended_at": statement.excluded.ended_at,
                    "samples": statement.excluded.samples,
                    "embedding": statement.excluded.embedding,
                    "box": statement.excluded.box,
                    "journey_uuid": func.coalesce(statement.excluded.journey_uuid, AnalyticsAppearance.journey_uuid),
                },
            )
            await self.session.execute(statement)
        for journey in report.journeys:
            steps = [step.model_dump(mode="json") for step in journey.steps]
            values = {
                "steps": steps,
                "started_at": moment(min(step.start for step in journey.steps)),
                "ended_at": moment(max(step.end for step in journey.steps)),
                "views": len({step.view for step in journey.steps}),
            }
            statement = insert(AnalyticsJourney).values(uuid=journey.id, **values)
            statement = statement.on_conflict_do_update(index_elements=["uuid"], set_=values)
            await self.session.execute(statement)
            for step in journey.steps:
                rows = await self.session.scalars(
                    select(AnalyticsAppearance).where(
                        AnalyticsAppearance.view_uuid == step.view,
                        AnalyticsAppearance.track_id == step.track,
                        AnalyticsAppearance.started_at >= moment(step.start) - STEP_SLACK,
                        AnalyticsAppearance.started_at <= moment(step.start) + STEP_SLACK,
                    )
                )
                for row in rows:
                    row.journey_uuid = journey.id
        await self.session.commit()

    async def view_names(self) -> dict[UUID, str]:
        """Return every view's name by id, including deleted views.

        Returns:
            View id to name.
        """
        rows = await self.session.execute(select(AnalyticsView.uuid, AnalyticsView.name))
        return {view_uuid: name for view_uuid, name in rows.all()}

    async def event_of(self, view: UUID, track: int, start: datetime, end: datetime) -> UUID | None:
        """Find an analytics event of a track on a view.

        Args:
            view: View id.
            track: Tracker id.
            start: First sighting of the track.
            end: Last sighting.

        Returns:
            The earliest overlapping event that names the track, or None.
        """
        rows = await self.session.scalars(
            select(Event)
            .where(
                Event.view_uuid == view,
                Event.deleted_at.is_(None),
                Event.started_at <= end + EVENT_SLACK,
                Event.started_at >= start - EVENT_SLACK - timedelta(minutes=10),
            )
            .order_by(Event.started_at)
        )
        fallback = None
        for event in rows:
            if event.ended_at is not None and event.ended_at < start - EVENT_SLACK:
                continue
            if track in (event.details or {}).get("objects", []):
                return event.uuid
            fallback = fallback or event.uuid
        return fallback

    async def read(self, journey: AnalyticsJourney, views: dict[UUID, str], cameras: dict[UUID, str]) -> JourneyRead:
        """Build the API form of a journey.

        Args:
            journey: The journey.
            views: View names by id.
            cameras: Camera names by id.

        Returns:
            The journey with names and the event of each step.
        """
        steps = []
        for step in journey.steps:
            view, camera = UUID(step["view"]), UUID(step["camera"])
            start, end = moment(step["start"]), moment(step["end"])
            steps.append(
                JourneyStepRead(
                    view_uuid=view,
                    view_name=views.get(view),
                    camera_uuid=camera,
                    camera_name=cameras.get(camera),
                    track=int(step["track"]),
                    started_at=start,
                    ended_at=end,
                    similarity=step.get("similarity"),
                    event_uuid=await self.event_of(view, int(step["track"]), start, end),
                )
            )
        return JourneyRead(
            uuid=journey.uuid,
            description=describe([step.view_name for step in steps]),
            started_at=journey.started_at,
            ended_at=journey.ended_at,
            steps=steps,
        )

    async def journeys(self, start: datetime, end: datetime, limit: int = 100) -> JourneyList:
        """List journeys that started in a range.

        Args:
            start: Start of the range.
            end: End of the range.
            limit: Most journeys returned.

        Returns:
            The journeys, newest first.
        """
        rows = await self.session.scalars(
            select(AnalyticsJourney)
            .where(AnalyticsJourney.started_at >= start, AnalyticsJourney.started_at < end)
            .order_by(AnalyticsJourney.started_at.desc())
            .limit(limit)
        )
        views, cameras = await self.view_names(), await camera_names(self.session)
        return JourneyList(items=[await self.read(journey, views, cameras) for journey in rows])

    async def appearances_of_event(self, event: Event) -> list[AnalyticsAppearance]:
        """Find the appearances of the tracks an event names.

        Args:
            event: The event.

        Returns:
            The appearances on the event's view that overlap it and name one of its objects, or any that overlap it
            when none names one.
        """
        if event.view_uuid is None:
            return []
        end = event.ended_at or datetime.now(UTC)
        rows = list(
            await self.session.scalars(
                select(AnalyticsAppearance).where(
                    AnalyticsAppearance.view_uuid == event.view_uuid,
                    AnalyticsAppearance.started_at <= end + EVENT_SLACK,
                    AnalyticsAppearance.ended_at >= event.started_at - EVENT_SLACK,
                )
            )
        )
        objects = set((event.details or {}).get("objects", []))
        named = [row for row in rows if row.track_id in objects]
        return named or rows

    async def journey_of_event(self, uuid: UUID) -> JourneyRead:
        """Return the journey an event's person belongs to.

        Args:
            uuid: Event id.

        Returns:
            The journey.

        Raises:
            NotFound: If the event does not exist or its person was not linked into a journey.
        """
        event = await self.session.scalar(select(Event).where(Event.uuid == uuid, Event.deleted_at.is_(None)))
        if event is None:
            raise NotFound("event_not_found", f"Event {uuid} does not exist")
        journeys = [row.journey_uuid for row in await self.appearances_of_event(event) if row.journey_uuid]
        if not journeys:
            raise NotFound(self.not_found_code, "The person of this event was not linked across cameras")
        journey = await self.get(journeys[0])
        return await self.read(journey, await self.view_names(), await camera_names(self.session))

    async def similar(self, query: SimilarAppearanceQuery) -> SimilarAppearances:
        """Find the tracks that look most like an event's person or a stored appearance.

        Args:
            query: What to search for, the time range and the number of matches.

        Returns:
            The matches, most similar first, without the query's own track.

        Raises:
            NotFound: If the event or appearance does not exist or the event has no stored appearance.
        """
        if query.appearance_uuid is not None:
            own = await self.session.scalar(
                select(AnalyticsAppearance).where(AnalyticsAppearance.uuid == query.appearance_uuid)
            )
            if own is None:
                raise NotFound("appearance_not_found", f"Appearance {query.appearance_uuid} does not exist")
            sources = [own]
        else:
            event = await self.session.scalar(
                select(Event).where(Event.uuid == query.event_uuid, Event.deleted_at.is_(None))
            )
            if event is None:
                raise NotFound("event_not_found", f"Event {query.event_uuid} does not exist")
            sources = await self.appearances_of_event(event)
            if not sources:
                raise NotFound("appearance_not_found", "No appearance was stored for the person of this event")
        vector = unit(np.mean([to_vector(row.embedding) for row in sources], axis=0))
        anchor = sources[0].started_at
        start = query.start or anchor - DEFAULT_WINDOW
        end = query.end or anchor + DEFAULT_WINDOW
        own_ids = {row.id for row in sources}
        candidates = [
            row
            for row in await self.session.scalars(
                select(AnalyticsAppearance).where(
                    and_(AnalyticsAppearance.started_at >= start, AnalyticsAppearance.started_at < end)
                )
            )
            if row.id not in own_ids
        ]
        scores = (
            centred_scores(vector, np.stack([to_vector(row.embedding) for row in candidates])) if candidates else []
        )
        ranked = sorted(zip(candidates, scores), key=lambda pair: float(pair[1]), reverse=True)
        views, cameras = await self.view_names(), await camera_names(self.session)
        items = []
        for row, score in ranked:
            if float(score) < MATCH_MIN or len(items) >= query.limit:
                break
            items.append(
                AppearanceMatch(
                    uuid=row.uuid,
                    view_uuid=row.view_uuid,
                    view_name=views.get(row.view_uuid),
                    camera_uuid=row.camera_uuid,
                    camera_name=cameras.get(row.camera_uuid),
                    started_at=row.started_at,
                    ended_at=row.ended_at,
                    similarity=round(float(score), 3),
                    journey_uuid=row.journey_uuid,
                    event_uuid=await self.event_of(row.view_uuid, row.track_id, row.started_at, row.ended_at),
                )
            )
        return SimilarAppearances(query_uuid=sources[0].uuid, items=items)
