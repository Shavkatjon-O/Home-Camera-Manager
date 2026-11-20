"""Line counts from the analytics service, their hourly and daily sums and the occupancy of areas."""

from collections import defaultdict
from collections.abc import Iterable
from datetime import UTC, datetime, timedelta
from uuid import UUID, uuid4
from zoneinfo import ZoneInfo

from sqlalchemy import func, select
from sqlalchemy.dialects.postgresql import insert

from app.core.base_service import BaseModelService
from app.core.config import settings
from app.core.exceptions import Conflict, Unprocessable
from app.models import AnalyticsArea, AnalyticsCount, AnalyticsLine, AnalyticsView
from app.modules.analytics.schemas.counts import (
    AreaCreate,
    AreaLineInput,
    AreaLineRead,
    AreaList,
    AreaRead,
    AreaReset,
    AreaUpdate,
    CountBucketRead,
    CountLineRead,
    CountReportIn,
    CountsRead,
    CountTotalRead,
)
from app.modules.events.services.events import camera_names
from app.tenancy.owners import view_owners

__all__ = ["AreaService", "CountService", "aggregate", "local_bucket", "occupancy", "occupancy_start"]

MAX_RANGE = {"hour": timedelta(days=2, hours=1), "day": timedelta(days=93)}
COUNT_KEYS = ("boot", "line_uuid", "start", "direction", "label")

CountRow = tuple[UUID, datetime, str, str, int]


def local_bucket(moment: datetime, bucket: str, zone: ZoneInfo) -> datetime:
    """Return the local start of the hour or day that holds a moment.

    Args:
        moment: An aware time.
        bucket: hour or day.
        zone: Local time zone.

    Returns:
        The aware local start of the bucket.
    """
    local = moment.astimezone(zone)
    return datetime(local.year, local.month, local.day, local.hour if bucket == "hour" else 0, tzinfo=zone)


def aggregate(
    rows: Iterable[CountRow], bucket: str, zone: ZoneInfo
) -> tuple[list[CountBucketRead], list[CountTotalRead]]:
    """Sum minute rows into hours or days per line and label, and into totals per line.

    Args:
        rows: Line, minute start, direction, label and count of every stored row.
        bucket: hour or day.
        zone: Local time zone of the buckets.

    Returns:
        The non-empty buckets in time order and the totals per line.
    """
    sums: dict[tuple[UUID, datetime, str], dict[str, int]] = defaultdict(lambda: {"in": 0, "out": 0})
    totals: dict[UUID, dict[str, dict[str, int]]] = defaultdict(dict)
    for line, start, direction, label, count in rows:
        sums[(line, local_bucket(start, bucket, zone), label)][direction] += count
        per_label = totals[line].setdefault(label, {"in": 0, "out": 0})
        per_label[direction] += count
    buckets = [
        CountBucketRead(line_uuid=line, at=at, label=label, in_=value["in"], out=value["out"])
        for (line, at, label), value in sorted(sums.items(), key=lambda item: (item[0][1], str(item[0][0]), item[0][2]))
    ]
    result = [
        CountTotalRead(
            line_uuid=line,
            in_=sum(value["in"] for value in labels.values()),
            out=sum(value["out"] for value in labels.values()),
            labels=labels,
        )
        for line, labels in totals.items()
    ]
    return buckets, result


def occupancy_start(now: datetime, reset_at: str | None, since: datetime, zone: ZoneInfo) -> tuple[datetime, bool]:
    """Return when an area's current count began and whether its hand-set occupancy still applies.

    Args:
        now: Current aware time.
        reset_at: Daily reset time as HH:MM, or None.
        since: When the occupancy was last set by hand or the area created.
        zone: Local time zone of the reset time.

    Returns:
        The start of the count and True when it is the hand-set start, False when it is the latest daily reset.
    """
    if reset_at:
        hours, minutes = (int(part) for part in reset_at.split(":"))
        local = now.astimezone(zone)
        daily = datetime(local.year, local.month, local.day, hours, minutes, tzinfo=zone)
        if daily > local:
            daily -= timedelta(days=1)
        if daily > since:
            return daily, False
    return since, True


def occupancy(
    lines: dict[UUID, str], labels: set[str], rows: Iterable[tuple[UUID, str, str, int]], base: int
) -> tuple[int, int, int]:
    """Work out an area's occupancy from the crossings of its lines.

    Args:
        lines: Line to the crossing direction that enters the area.
        labels: Labels counted, empty for every label.
        rows: Line, direction, label and count of the crossings since the count began.
        base: Occupancy at the start of the count.

    Returns:
        Occupancy, never below zero, crossings in and crossings out.
    """
    entered = exited = 0
    for line, direction, label, count in rows:
        if line not in lines or (labels and label not in labels):
            continue
        if direction == lines[line]:
            entered += count
        else:
            exited += count
    return max(0, base + entered - exited), entered, exited


def timezone() -> ZoneInfo:
    """Return the time zone of schedules and counts.

    Returns:
        The zone named by SSS_TIMEZONE.
    """
    return ZoneInfo(settings.timezone)


class CountService(BaseModelService[AnalyticsCount]):
    """Stores the analytics service's minute counts and sums them for the Counts page.

    Attributes:
        model: Minute counts of the lines.
    """

    model = AnalyticsCount

    async def ingest(self, report: CountReportIn) -> None:
        """Store a report, replacing the count of every minute it carries.

        Args:
            report: The report.
        """
        if not report.buckets:
            return
        owners = await view_owners(self.session, {item.view for item in report.buckets})
        empty = {"site_id": None, "organisation_id": None}
        rows = [
            {
                **owners.get(item.view, empty),
                "uuid": uuid4(),
                "boot": report.boot,
                "view_uuid": item.view,
                "line_uuid": item.line,
                "start": datetime.fromtimestamp(item.start, UTC),
                "direction": item.direction,
                "label": item.label,
                "count": item.count,
            }
            for item in report.buckets
        ]
        statement = insert(AnalyticsCount).values(rows)
        statement = statement.on_conflict_do_update(
            index_elements=list(COUNT_KEYS), set_={"count": statement.excluded.count, "updated_at": func.now()}
        )
        await self.session.execute(statement)
        await self.session.commit()

    async def lines(self) -> list[CountLineRead]:
        """List every counting line with its view and camera.

        Returns:
            The lines in view and position order.
        """
        rows = await self.session.execute(
            select(AnalyticsLine, AnalyticsView)
            .join(AnalyticsView, AnalyticsView.id == AnalyticsLine.view_id)
            .where(AnalyticsLine.deleted_at.is_(None), AnalyticsView.deleted_at.is_(None))
            .order_by(AnalyticsView.name, AnalyticsLine.position)
        )
        names = await camera_names(self.session)
        return [
            CountLineRead(
                uuid=line.uuid,
                name=line.name,
                view_uuid=view.uuid,
                view_name=view.name,
                camera_uuid=view.camera_uuid,
                camera_name=names.get(view.camera_uuid),
                direction=line.direction,
                enabled=line.enabled,
            )
            for line, view in rows.all()
        ]

    async def counts(self, start: datetime, end: datetime, bucket: str) -> CountsRead:
        """Sum the crossings of every line over a range.

        Args:
            start: Start of the range, inclusive.
            end: End of the range, exclusive.
            bucket: hour or day.

        Returns:
            The lines, the non-empty buckets and the totals.

        Raises:
            Unprocessable: If the range is empty or too long for the bucket.
        """
        if bucket not in MAX_RANGE:
            raise Unprocessable("invalid_bucket", "The bucket must be hour or day")
        if end <= start:
            raise Unprocessable("invalid_range", "The end must be after the start")
        if end - start > MAX_RANGE[bucket]:
            raise Unprocessable("range_too_long", f"A {bucket} range may span at most {MAX_RANGE[bucket].days} days")
        rows = await self.session.execute(
            select(
                AnalyticsCount.line_uuid,
                AnalyticsCount.start,
                AnalyticsCount.direction,
                AnalyticsCount.label,
                func.sum(AnalyticsCount.count),
            )
            .where(AnalyticsCount.start >= start, AnalyticsCount.start < end)
            .group_by(AnalyticsCount.line_uuid, AnalyticsCount.start, AnalyticsCount.direction, AnalyticsCount.label)
        )
        zone = timezone()
        buckets, totals = aggregate(
            ((line, at, direction, label, int(count)) for line, at, direction, label, count in rows.all()), bucket, zone
        )
        return CountsRead(
            start=start,
            end=end,
            bucket=bucket,
            timezone=zone.key,
            lines=await self.lines(),
            buckets=buckets,
            totals=totals,
        )


class AreaService(BaseModelService[AnalyticsArea]):
    """Areas bounded by counting lines and their occupancy.

    Attributes:
        model: Areas bounded by lines.
        not_found_code: Error code of an unknown area.
    """

    model = AnalyticsArea
    not_found_code = "area_not_found"

    async def check_lines(self, lines: list[AreaLineInput]) -> None:
        """Make sure every bounding line exists.

        Args:
            lines: The bounding lines.

        Raises:
            Conflict: If a line does not exist.
        """
        wanted = {item.line_uuid for item in lines}
        found = set(
            await self.session.scalars(
                select(AnalyticsLine.uuid).where(AnalyticsLine.uuid.in_(wanted), AnalyticsLine.deleted_at.is_(None))
            )
        )
        missing = wanted - found
        if missing:
            raise Conflict("line_not_found", f"Line {sorted(map(str, missing))[0]} does not exist")

    async def read(self, area: AnalyticsArea, now: datetime | None = None) -> AreaRead:
        """Build the API form of an area with its occupancy now.

        Args:
            area: The area.
            now: Current time, the clock when None.

        Returns:
            The area.
        """
        now = now or datetime.now(UTC)
        zone = timezone()
        start, hand_set = occupancy_start(now, area.reset_at, area.since, zone)
        lines = {UUID(str(item["line_uuid"])): item["entering"] for item in area.lines}
        rows = await self.session.execute(
            select(
                AnalyticsCount.line_uuid, AnalyticsCount.direction, AnalyticsCount.label, func.sum(AnalyticsCount.count)
            )
            .where(
                AnalyticsCount.line_uuid.in_(list(lines)),
                AnalyticsCount.start >= start.replace(second=0, microsecond=0),
            )
            .group_by(AnalyticsCount.line_uuid, AnalyticsCount.direction, AnalyticsCount.label)
        )
        value, entered, exited = occupancy(
            lines,
            set(area.labels or []),
            ((line, direction, label, int(count)) for line, direction, label, count in rows.all()),
            area.base if hand_set else 0,
        )
        details = await self.session.execute(
            select(AnalyticsLine.uuid, AnalyticsLine.name, AnalyticsView.name)
            .join(AnalyticsView, AnalyticsView.id == AnalyticsLine.view_id)
            .where(AnalyticsLine.uuid.in_(list(lines)), AnalyticsLine.deleted_at.is_(None))
        )
        named = {line_uuid: (line_name, view_name) for line_uuid, line_name, view_name in details.all()}
        return AreaRead(
            uuid=area.uuid,
            name=area.name,
            occupancy=value,
            entered=entered,
            exited=exited,
            since=start,
            reset_at=area.reset_at,
            labels=list(area.labels or []),
            lines=[
                AreaLineRead(
                    line_uuid=line,
                    line_name=named.get(line, (None, None))[0],
                    view_name=named.get(line, (None, None))[1],
                    entering=entering,
                )
                for line, entering in lines.items()
            ],
            updated_at=area.updated_at,
        )

    async def areas(self) -> AreaList:
        """List every area with its occupancy.

        Returns:
            The areas in creation order.
        """
        areas = await self.session.scalars(
            select(AnalyticsArea).where(AnalyticsArea.deleted_at.is_(None)).order_by(AnalyticsArea.id)
        )
        return AreaList(items=[await self.read(area) for area in areas])

    async def create(self, payload: AreaCreate) -> AreaRead:
        """Create an area whose occupancy starts at zero now.

        Args:
            payload: The area.

        Returns:
            The created area.
        """
        await self.check_lines(payload.lines)
        area = AnalyticsArea(
            name=payload.name,
            lines=[item.model_dump(mode="json") for item in payload.lines],
            labels=payload.labels,
            reset_at=payload.reset_at,
            since=datetime.now(UTC),
            base=0,
        )
        self.session.add(area)
        await self.session.commit()
        await self.session.refresh(area)
        return await self.read(area)

    async def update(self, uuid: UUID, payload: AreaUpdate) -> AreaRead:
        """Change an area.

        Args:
            uuid: Area id.
            payload: The changes; reset_at is changed only when sent.

        Returns:
            The area after the change.
        """
        area = await self.get(uuid)
        if payload.lines is not None:
            await self.check_lines(payload.lines)
            area.lines = [item.model_dump(mode="json") for item in payload.lines]
        if payload.name is not None:
            area.name = payload.name
        if payload.labels is not None:
            area.labels = payload.labels
        if "reset_at" in payload.model_fields_set:
            area.reset_at = payload.reset_at
        await self.session.commit()
        await self.session.refresh(area)
        return await self.read(area)

    async def delete(self, uuid: UUID) -> None:
        """Delete an area.

        Args:
            uuid: Area id.
        """
        area = await self.get(uuid)
        area.deleted_at = datetime.now(UTC)
        await self.session.commit()

    async def reset(self, uuid: UUID, payload: AreaReset) -> AreaRead:
        """Set an area's occupancy now and count on from it.

        Args:
            uuid: Area id.
            payload: The occupancy now.

        Returns:
            The area after the change.
        """
        area = await self.get(uuid)
        area.since = datetime.now(UTC)
        area.base = payload.occupancy
        await self.session.commit()
        await self.session.refresh(area)
        return await self.read(area)
