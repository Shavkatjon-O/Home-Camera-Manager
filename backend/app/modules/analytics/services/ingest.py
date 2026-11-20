"""Events and observations the analytics service sends."""

from datetime import UTC, datetime

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.analytics.observations import observations
from app.camera_events.engine import CameraEventsEngine, camera_events
from app.models import Camera, Event
from app.modules.analytics.schemas import AnalyticsEventIn, ObservationReport
from app.modules.events.enums import EventSource
from app.modules.events.schemas import event_read

__all__ = ["AnalyticsIngestService"]

DETAIL_FIELDS = ("view_name", "profile", "zone", "zone_name", "line", "line_name", "direction", "objects", "count")
LATER_FIELDS = ("plates", "plate_status")


def moment(value: float | None) -> datetime | None:
    """Convert epoch seconds to an aware time.

    Args:
        value: Seconds since the epoch, or None.

    Returns:
        The time in UTC, or None.
    """
    return datetime.fromtimestamp(value, UTC) if value is not None else None


class AnalyticsIngestService:
    """Stores what the analytics service reports and announces events on the event stream.

    Attributes:
        session: Database session.
        engine: The camera events engine, whose broker feeds the event stream.
    """

    def __init__(self, session: AsyncSession, engine: CameraEventsEngine = camera_events):
        """Bind the service to a session.

        Args:
            session: Database session.
            engine: The camera events engine.
        """
        self.session = session
        self.engine = engine

    async def event(self, data: AnalyticsEventIn) -> None:
        """Create or update an event from one change.

        Every change of an event carries the whole event, so a lost change is repaired by the next one. The alert
        flag only ever turns on.

        Args:
            data: The event change.
        """
        row = await self.session.scalar(select(Event).where(Event.uuid == data.id))
        details = {name: getattr(data, name) for name in DETAIL_FIELDS}
        details.update({name: getattr(data, name) for name in LATER_FIELDS if getattr(data, name) is not None})
        details["boxes"] = data.boxes
        if row is None:
            row = Event(
                uuid=data.id,
                camera_uuid=data.camera,
                kind=data.kind.value,
                source=EventSource.ANALYTICS.value,
                source_topic=f"analytics/{data.kind.value}",
                label=data.label,
                alert=data.alert,
                view_uuid=data.view,
                started_at=moment(data.started_at),
                details=details,
            )
            self.session.add(row)
        else:
            row.alert = row.alert or data.alert
            row.details = {**(row.details or {}), **details}
        if data.ended_at is not None:
            row.ended_at = moment(data.ended_at)
        for name in ("snapshot_path", "thumbnail_path", "clip_path"):
            value = getattr(data, name)
            if value:
                setattr(row, name, value)
        await self.session.commit()
        await self.session.refresh(row)
        camera_name = await self.session.scalar(select(Camera.name).where(Camera.uuid == row.camera_uuid))
        read = event_read(row, camera_name, datetime.now(UTC))
        self.engine.broker.publish("event", read.model_dump(mode="json"))

    def observe(self, report: ObservationReport) -> None:
        """Keep the latest observations.

        Args:
            report: The report.
        """
        observations.store(report.model_dump())
