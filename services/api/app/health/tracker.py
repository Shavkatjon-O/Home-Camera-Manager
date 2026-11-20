"""Outage tracking from successive probe results, including attribution to upstream devices."""

from dataclasses import dataclass
from datetime import datetime, timedelta
from uuid import UUID

from app.health.targets import Target, depth_order

FAILURES_TO_OPEN = 2


@dataclass(eq=False)
class OutageRecord:
    """In-memory copy of an outage row.

    Attributes:
        target_kind: Kind of the target, a TargetKind value.
        target_uuid: Public id of the device or camera that went down.
        started_at: Time of the first failed sample of the outage.
        failed_samples: Number of failed samples counted in the outage.
        upstream_uuid: Public id of the device whose outage caused this one, if one was found.
        ended_at: Time the target recovered, or None while the outage is open.
        id: Database id once the outage has been stored.
        dirty: True while the record is queued for saving.
    """

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
    """Run of consecutive failed samples of one target.

    Attributes:
        failures: Number of failed samples in the run.
        first_failure_at: Time of the first failure in the run.
    """

    failures: int
    first_failure_at: datetime


class OutageTracker:
    """Turn probe results into outages and trace each outage to the upstream device that caused it.

    An outage opens after a target fails several samples in a row and closes on its next success. An outage that
    overlaps one on the device the target connects through points at that device's root cause.

    Attributes:
        slack: How long before a cause starts a downstream failure still counts as part of it.
        threshold: Consecutive failures needed to open an outage.
        streaks: Current failure run per target.
        open: Open outage per target.
        closed: Most recent closed outage per target.
        parents: Parent device per target as of the last observation.
        unsaved: Records changed since they were last saved.
    """

    def __init__(self, slack: timedelta, threshold: int = FAILURES_TO_OPEN):
        """Create a tracker with no history.

        Args:
            slack: How long before a cause starts a downstream failure still counts as part of it.
            threshold: Consecutive failures needed to open an outage.
        """
        self.slack = slack
        self.threshold = threshold

        self.streaks: dict[UUID, Streak] = {}
        self.open: dict[UUID, OutageRecord] = {}
        self.closed: dict[UUID, OutageRecord] = {}
        self.parents: dict[UUID, UUID | None] = {}

        self.unsaved: list[OutageRecord] = []

    def restore(self, outages: list[OutageRecord], failing: dict[UUID, datetime]) -> None:
        """Load state saved earlier so tracking continues across a restart.

        Args:
            outages: Stored outages, open and closed.
            failing: Time of the latest failed sample for each target whose latest sample failed.
        """
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
        """Queue a record to be saved.

        Args:
            outage: Record that changed.
        """
        if not outage.dirty:
            outage.dirty = True
            self.unsaved.append(outage)

    def saved(self) -> None:
        """Mark every queued record as saved."""
        for outage in self.unsaved:
            outage.dirty = False
        self.unsaved.clear()

    def overlaps(self, cause: OutageRecord, started_at: datetime) -> bool:
        """Check whether a failure starting at a moment belongs to the time span of an outage.

        Args:
            cause: Candidate causing outage.
            started_at: Start time of the failure being attributed.

        Returns:
            True when the failure starts no earlier than the slack before the cause and no later than the cause's end.
        """
        if cause.started_at - self.slack > started_at:
            return False
        return cause.ended_at is None or started_at <= cause.ended_at

    def outage_at(self, target_uuid: UUID, started_at: datetime) -> OutageRecord | None:
        """Find an outage of a target that overlaps a moment.

        Args:
            target_uuid: Public id of the target.
            started_at: Moment to match.

        Returns:
            The open outage, else the last closed one, whichever overlaps, or None.
        """
        for outage in (self.open.get(target_uuid), self.closed.get(target_uuid)):
            if outage is not None and self.overlaps(outage, started_at):
                return outage
        return None

    def cause(self, target_uuid: UUID, started_at: datetime) -> UUID | None:
        """Find the root cause of a target's failure from the device it connects through.

        Args:
            target_uuid: Public id of the failing target.
            started_at: Start time of the failure.

        Returns:
            Public id of the root device that is down, or None when the target has no parent or the parent is not down.
        """
        parent = self.parents.get(target_uuid)
        if parent is None:
            return None
        outage = self.outage_at(parent, started_at)
        if outage is None:
            return None
        return outage.upstream_uuid or outage.target_uuid

    def records(self) -> list[OutageRecord]:
        """List every tracked outage.

        Returns:
            The open outages followed by the closed ones.
        """
        return [*self.open.values(), *self.closed.values()]

    def repoint(self, source: OutageRecord, root: UUID) -> None:
        """Move outages attributed to one outage onto a deeper root cause.

        Args:
            source: Outage that is now itself attributed elsewhere.
            root: Public id of the new root cause.
        """
        for outage in self.records():
            if outage.upstream_uuid == source.target_uuid and self.overlaps(source, outage.started_at):
                outage.upstream_uuid = root
                self.touch(outage)

    def adopt(self, cause: OutageRecord) -> None:
        """Attribute outages of dependent targets to a newly opened outage.

        Only outages without a cause that overlap the new outage are adopted, and outages that pointed at them are
        repointed to the same root.

        Args:
            cause: Outage that has just opened.
        """
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
        """Record a failed sample of a target.

        Extends its open outage, or opens one once the failure run reaches the threshold.

        Args:
            target: Target that failed.
            at: Time of the sample.
        """
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
        """Record a recovery of a target and close its open outage.

        Args:
            target_uuid: Public id of the target that answered.
            at: Time of the sample.
        """
        self.streaks.pop(target_uuid, None)
        outage = self.open.pop(target_uuid, None)
        if outage is None:
            return
        outage.ended_at = at
        self.closed[target_uuid] = outage
        self.touch(outage)

    def observe(self, targets: list[Target], results: dict[UUID, bool], at: datetime) -> None:
        """Apply one round of probe results.

        Outages and streaks of targets that no longer exist are dropped or closed. Targets are processed parents first,
        so a parent's outage exists before its children are attributed.

        Args:
            targets: Targets that were probed.
            results: Whether each probe succeeded, keyed by target id. Targets without a result are skipped.
            at: Time of the round.
        """
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
