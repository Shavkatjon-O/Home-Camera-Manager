from dataclasses import dataclass
from datetime import datetime, timedelta
from uuid import UUID

from app.health.targets import Target, depth_order

FAILURES_TO_OPEN = 2


@dataclass(eq=False)
class OutageRecord:
    target_kind: str
    target_uuid: UUID
    started_at: datetime
    failed_samples: int
    upstream_uuid: UUID | None = None
    ended_at: datetime | None = None
    id: int | None = None
    dirty: bool = False


@dataclass
class Streak:
    failures: int
    first_failure_at: datetime


class OutageTracker:
    def __init__(self, slack: timedelta, threshold: int = FAILURES_TO_OPEN):
        self.slack = slack
        self.threshold = threshold

        self.streaks: dict[UUID, Streak] = {}
        self.open: dict[UUID, OutageRecord] = {}
        self.closed: dict[UUID, OutageRecord] = {}
        self.parents: dict[UUID, UUID | None] = {}

        self.unsaved: list[OutageRecord] = []

    def restore(self, outages: list[OutageRecord], failing: dict[UUID, datetime]) -> None:
        for outage in sorted(outages, key=lambda item: item.started_at):
            if outage.ended_at is None:
                self.open[outage.target_uuid] = outage
                self.streaks[outage.target_uuid] = Streak(outage.failed_samples, outage.started_at)
            else:
                self.closed[outage.target_uuid] = outage
        for target_uuid, failed_at in failing.items():
            if target_uuid not in self.open:
                self.streaks[target_uuid] = Streak(1, failed_at)

    def touch(self, outage: OutageRecord) -> None:
        if not outage.dirty:
            outage.dirty = True
            self.unsaved.append(outage)

    def saved(self) -> None:
        for outage in self.unsaved:
            outage.dirty = False
        self.unsaved.clear()

    def overlaps(self, cause: OutageRecord, started_at: datetime) -> bool:
        if cause.started_at - self.slack > started_at:
            return False
        return cause.ended_at is None or started_at <= cause.ended_at

    def outage_at(self, target_uuid: UUID, started_at: datetime) -> OutageRecord | None:
        for outage in (self.open.get(target_uuid), self.closed.get(target_uuid)):
            if outage is not None and self.overlaps(outage, started_at):
                return outage
        return None

    def cause(self, target_uuid: UUID, started_at: datetime) -> UUID | None:
        parent = self.parents.get(target_uuid)
        if parent is None:
            return None
        outage = self.outage_at(parent, started_at)
        if outage is None:
            return None
        return outage.upstream_uuid or outage.target_uuid

    def records(self) -> list[OutageRecord]:
        return [*self.open.values(), *self.closed.values()]

    def repoint(self, source: OutageRecord, root: UUID) -> None:
        for outage in self.records():
            if outage.upstream_uuid == source.target_uuid and self.overlaps(source, outage.started_at):
                outage.upstream_uuid = root
                self.touch(outage)

    def adopt(self, cause: OutageRecord) -> None:
        root = cause.upstream_uuid or cause.target_uuid
        for child, parent in self.parents.items():
            if parent != cause.target_uuid:
                continue
            for outage in (self.open.get(child), self.closed.get(child)):
                if outage is None or outage.upstream_uuid is not None or not self.overlaps(cause, outage.started_at):
                    continue
                outage.upstream_uuid = root
                self.touch(outage)
                self.repoint(outage, root)

    def fail(self, target: Target, at: datetime) -> None:
        streak = self.streaks.get(target.uuid)
        if streak is None:
            streak = Streak(0, at)
            self.streaks[target.uuid] = streak
        streak.failures += 1
        outage = self.open.get(target.uuid)
        if outage is not None:
            outage.failed_samples += 1
            self.touch(outage)
            return
        if streak.failures < self.threshold:
            return
        outage = OutageRecord(
            target_kind=target.kind,
            target_uuid=target.uuid,
            started_at=streak.first_failure_at,
            failed_samples=streak.failures,
            upstream_uuid=self.cause(target.uuid, streak.first_failure_at),
        )
        self.open[target.uuid] = outage
        self.touch(outage)
        self.adopt(outage)

    def end(self, target_uuid: UUID, at: datetime) -> None:
        self.streaks.pop(target_uuid, None)
        outage = self.open.pop(target_uuid, None)
        if outage is None:
            return
        outage.ended_at = at
        self.closed[target_uuid] = outage
        self.touch(outage)

    def observe(self, targets: list[Target], results: dict[UUID, bool], at: datetime) -> None:
        self.parents = {target.uuid: target.parent_uuid for target in targets}
        for target_uuid in list(self.open):
            if target_uuid not in self.parents:
                self.end(target_uuid, at)
        for target_uuid in list(self.streaks):
            if target_uuid not in self.parents:
                self.streaks.pop(target_uuid, None)
        for target in depth_order(targets):
            ok = results.get(target.uuid)
            if ok is None:
                continue
            if ok:
                self.end(target.uuid, at)
            else:
                self.fail(target, at)
