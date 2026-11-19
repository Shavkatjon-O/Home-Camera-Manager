from datetime import UTC, datetime, timedelta
from uuid import UUID

from app.health.targets import Target
from app.health.tracker import OutageRecord, OutageTracker

START = datetime(2026, 11, 19, 20, 0, tzinfo=UTC)
STEP = timedelta(seconds=10)

ROUTER = Target(kind="device", uuid=UUID(int=1), host="192.168.1.1", port=80)
REPEATER = Target(kind="device", uuid=UUID(int=2), host="192.168.1.218", port=80, parent_uuid=ROUTER.uuid)
CAMERA = Target(kind="camera", uuid=UUID(int=3), host="192.168.1.104", port=554, parent_uuid=REPEATER.uuid)
OTHER = Target(kind="camera", uuid=UUID(int=4), host="192.168.1.106", port=554, parent_uuid=ROUTER.uuid)

TARGETS = [CAMERA, OTHER, REPEATER, ROUTER]


def at(tick: int) -> datetime:
    return START + STEP * tick


def tracker() -> OutageTracker:
    return OutageTracker(slack=STEP * 2)


def run(subject: OutageTracker, ticks: list[set[UUID]], first: int = 0) -> None:
    for offset, down in enumerate(ticks):
        results = {target.uuid: target.uuid not in down for target in TARGETS}
        subject.observe(TARGETS, results, at(first + offset))


def test_one_failed_sample_is_not_an_outage():
    subject = tracker()
    run(subject, [set(), {CAMERA.uuid}, set()])
    assert subject.open == {}
    assert subject.closed == {}
    assert subject.unsaved == []


def test_two_failed_samples_open_an_outage_from_the_first_failure():
    subject = tracker()
    run(subject, [set(), {CAMERA.uuid}, {CAMERA.uuid}])
    outage = subject.open[CAMERA.uuid]
    assert outage.started_at == at(1)
    assert outage.ended_at is None
    assert outage.failed_samples == 2
    assert outage.target_kind == "camera"
    assert outage.upstream_uuid is None
    assert subject.unsaved == [outage]


def test_more_failures_count_and_the_first_success_closes():
    subject = tracker()
    run(subject, [{CAMERA.uuid}, {CAMERA.uuid}, {CAMERA.uuid}, {CAMERA.uuid}, set()])
    assert CAMERA.uuid not in subject.open
    outage = subject.closed[CAMERA.uuid]
    assert outage.failed_samples == 4
    assert outage.started_at == at(0)
    assert outage.ended_at == at(4)


def test_a_new_streak_after_recovery_opens_a_new_outage():
    subject = tracker()
    run(subject, [{CAMERA.uuid}, {CAMERA.uuid}, set(), {CAMERA.uuid}, {CAMERA.uuid}])
    first = subject.closed[CAMERA.uuid]
    second = subject.open[CAMERA.uuid]
    assert first is not second
    assert second.started_at == at(3)
    assert subject.unsaved == [first, second]


def test_saved_clears_the_pending_list_and_later_changes_queue_again():
    subject = tracker()
    run(subject, [{CAMERA.uuid}, {CAMERA.uuid}])
    outage = subject.open[CAMERA.uuid]
    outage.id = 7
    subject.saved()
    assert subject.unsaved == []
    assert outage.dirty is False
    run(subject, [set()], first=2)
    assert subject.unsaved == [outage]
    assert outage.ended_at == at(2)


def test_a_camera_failing_alone_has_no_upstream():
    subject = tracker()
    run(subject, [{CAMERA.uuid}, {CAMERA.uuid}])
    assert subject.open[CAMERA.uuid].upstream_uuid is None


def test_a_camera_behind_a_failed_repeater_is_attributed_to_it():
    subject = tracker()
    down = {REPEATER.uuid, CAMERA.uuid}
    run(subject, [down, down, down, set()])
    assert subject.closed[REPEATER.uuid].upstream_uuid is None
    assert subject.closed[CAMERA.uuid].upstream_uuid == REPEATER.uuid


def test_the_root_device_is_the_cause_for_the_whole_chain():
    subject = tracker()
    down = {ROUTER.uuid, REPEATER.uuid, CAMERA.uuid, OTHER.uuid}
    run(subject, [down, down])
    assert subject.open[ROUTER.uuid].upstream_uuid is None
    assert subject.open[REPEATER.uuid].upstream_uuid == ROUTER.uuid
    assert subject.open[CAMERA.uuid].upstream_uuid == ROUTER.uuid
    assert subject.open[OTHER.uuid].upstream_uuid == ROUTER.uuid


def test_a_camera_that_failed_well_before_its_parent_failed_by_itself():
    subject = tracker()
    run(subject, [{CAMERA.uuid}, {CAMERA.uuid}, {CAMERA.uuid}])
    subject.saved()
    run(subject, [{CAMERA.uuid, REPEATER.uuid}, {CAMERA.uuid, REPEATER.uuid}], first=3)
    camera = subject.open[CAMERA.uuid]
    assert subject.open[REPEATER.uuid].started_at == at(3)
    assert camera.started_at == at(0)
    assert camera.upstream_uuid is None
    assert subject.unsaved == [camera, subject.open[REPEATER.uuid]]


def test_a_camera_within_the_slack_of_its_parent_is_attributed_when_the_parent_opens():
    subject = tracker()
    run(subject, [{CAMERA.uuid}, {CAMERA.uuid, REPEATER.uuid}])
    camera = subject.open[CAMERA.uuid]
    assert camera.upstream_uuid is None
    run(subject, [{CAMERA.uuid, REPEATER.uuid}], first=2)
    assert subject.open[REPEATER.uuid].started_at == at(1)
    assert camera.upstream_uuid == REPEATER.uuid
    assert camera in subject.unsaved


def test_a_late_root_outage_repoints_the_children_to_the_root():
    subject = tracker()
    run(subject, [{CAMERA.uuid, REPEATER.uuid}, {CAMERA.uuid, REPEATER.uuid, ROUTER.uuid}])
    assert subject.open[CAMERA.uuid].upstream_uuid == REPEATER.uuid
    assert subject.open[REPEATER.uuid].upstream_uuid is None
    run(subject, [{CAMERA.uuid, REPEATER.uuid, ROUTER.uuid}], first=2)
    assert subject.open[REPEATER.uuid].upstream_uuid == ROUTER.uuid
    assert subject.open[CAMERA.uuid].upstream_uuid == ROUTER.uuid


def test_a_parent_that_recovered_before_the_camera_failed_is_not_the_cause():
    subject = tracker()
    run(subject, [{REPEATER.uuid}, {REPEATER.uuid}, set(), {CAMERA.uuid}, {CAMERA.uuid}])
    assert subject.closed[REPEATER.uuid].ended_at == at(2)
    assert subject.open[CAMERA.uuid].upstream_uuid is None


def test_a_camera_failing_while_the_parent_is_still_down_counts_as_upstream():
    subject = tracker()
    run(subject, [{REPEATER.uuid}, {REPEATER.uuid}, {REPEATER.uuid}, {REPEATER.uuid, CAMERA.uuid}])
    run(subject, [{REPEATER.uuid, CAMERA.uuid}], first=4)
    assert subject.open[CAMERA.uuid].started_at == at(3)
    assert subject.open[CAMERA.uuid].upstream_uuid == REPEATER.uuid


def test_a_removed_target_closes_its_outage():
    subject = tracker()
    run(subject, [{CAMERA.uuid}, {CAMERA.uuid}])
    remaining = [target for target in TARGETS if target.uuid != CAMERA.uuid]
    subject.observe(remaining, {target.uuid: True for target in remaining}, at(2))
    assert CAMERA.uuid not in subject.open
    assert subject.closed[CAMERA.uuid].ended_at == at(2)


def test_restore_continues_an_open_outage_and_seeds_a_failing_streak():
    subject = tracker()
    stored = OutageRecord(
        target_kind="device",
        target_uuid=REPEATER.uuid,
        started_at=at(0),
        failed_samples=5,
        id=3,
    )
    subject.restore([stored], {CAMERA.uuid: at(4)})
    assert subject.open[REPEATER.uuid] is stored
    assert subject.unsaved == []
    run(subject, [{REPEATER.uuid, CAMERA.uuid}], first=5)
    assert stored.failed_samples == 6
    camera = subject.open[CAMERA.uuid]
    assert camera.started_at == at(4)
    assert camera.failed_samples == 2
    assert camera.upstream_uuid == REPEATER.uuid
    run(subject, [set()], first=6)
    assert stored.ended_at == at(6)
    assert stored in subject.unsaved
