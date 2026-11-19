from datetime import UTC, datetime, timedelta
from uuid import UUID, uuid4

import pytest
from pydantic import ValidationError
from sqlalchemy.dialects import postgresql

from app.core.exceptions import Conflict, Unprocessable
from app.health.prober import build_targets
from app.health.stats import bucket_window
from app.health.targets import BRIDGED_DEVICE_PORT, Target, camera_address, depth_order
from app.models import Camera, CameraLink, NetworkDevice
from app.modules.health.enums import TargetStatus
from app.modules.health.schemas import CameraLinkUpdate, NetworkDeviceCreate, NetworkDeviceUpdate
from app.modules.health.services import (
    HealthOverviewService,
    Latest,
    NetworkDeviceService,
    creates_cycle,
    duration_seconds,
    in_use_message,
    target_status,
)

NOW = datetime(2026, 11, 19, 20, 0, tzinfo=UTC)


class Rows:
    def __init__(self, rows):
        self.rows = rows

    def all(self):
        return self.rows


class FakeSession:
    def __init__(self, scalars=(), rows=()):
        self.scalar_results = list(scalars)
        self.rows = list(rows)
        self.statements = []
        self.commits = 0

    async def commit(self):
        self.commits += 1

    async def scalar(self, statement):
        self.statements.append(statement)
        return self.scalar_results.pop(0)

    async def execute(self, statement):
        self.statements.append(statement)
        return Rows(self.rows.pop(0) if self.rows else [])


def sql(statement) -> str:
    return str(statement.compile(dialect=postgresql.dialect()))


def test_status_follows_outages_and_the_latest_sample():
    fresh = Latest(ok=True, at=NOW - timedelta(seconds=5), error=None)
    failed = Latest(ok=False, at=NOW - timedelta(seconds=5), error="Connection refused")
    stale = Latest(ok=True, at=NOW - timedelta(seconds=31), error=None)
    assert target_status(False, True, fresh, NOW, 10) == TargetStatus.DISABLED
    assert target_status(True, True, fresh, NOW, 10) == TargetStatus.DOWN
    assert target_status(True, False, fresh, NOW, 10) == TargetStatus.UP
    assert target_status(True, False, failed, NOW, 10) == TargetStatus.DEGRADED
    assert target_status(True, False, stale, NOW, 10) == TargetStatus.UNKNOWN
    assert target_status(True, False, None, NOW, 10) == TargetStatus.UNKNOWN


def test_duration_runs_to_now_while_ongoing():
    assert duration_seconds(NOW - timedelta(seconds=90), NOW - timedelta(seconds=30), NOW) == 60.0
    assert duration_seconds(NOW - timedelta(seconds=90), None, NOW) == 90.0
    assert duration_seconds(NOW, NOW - timedelta(seconds=5), NOW) == 0.0


def test_bridged_cameras_are_probed_on_the_device_port():
    assert camera_address("home-cameras-v380-ptz-1", "192.168.1.237", 8554) == (
        "192.168.1.237",
        BRIDGED_DEVICE_PORT,
    )
    assert camera_address("192.168.1.104", None, 554) == ("192.168.1.104", 554)


def test_targets_take_camera_parents_from_their_links():
    router = NetworkDevice(uuid=uuid4(), name="Router", host="192.168.1.1", probe_port=80, parent_uuid=None)
    bridged = Camera(uuid=uuid4(), host="home-cameras-v380-ptz-2", device_host="192.168.1.127", rtsp_port=8554)
    direct = Camera(uuid=uuid4(), host="192.168.1.106", device_host=None, rtsp_port=554)
    link = CameraLink(camera_uuid=bridged.uuid, parent_uuid=router.uuid, link="cable")
    targets = build_targets([router], [bridged, direct], [link])
    assert targets[0] == Target(kind="device", uuid=router.uuid, host="192.168.1.1", port=80, parent_uuid=None)
    assert targets[1] == Target(
        kind="camera", uuid=bridged.uuid, host="192.168.1.127", port=8800, parent_uuid=router.uuid
    )
    assert targets[2].parent_uuid is None
    assert targets[2].port == 554


def test_depth_order_puts_parents_first_and_survives_cycles():
    root = Target(kind="device", uuid=UUID(int=1), host="a", port=80)
    child = Target(kind="device", uuid=UUID(int=2), host="b", port=80, parent_uuid=root.uuid)
    leaf = Target(kind="camera", uuid=UUID(int=3), host="c", port=554, parent_uuid=child.uuid)
    assert depth_order([leaf, child, root]) == [root, child, leaf]
    looped = [
        Target(kind="device", uuid=UUID(int=4), host="d", port=80, parent_uuid=UUID(int=5)),
        Target(kind="device", uuid=UUID(int=5), host="e", port=80, parent_uuid=UUID(int=4)),
    ]
    assert len(depth_order(looped)) == 2


def test_creates_cycle_walks_up_the_parents():
    first, second, third = UUID(int=1), UUID(int=2), UUID(int=3)
    parents = {first: None, second: first, third: second}
    assert creates_cycle(first, third, parents) is True
    assert creates_cycle(third, first, parents) is False
    assert creates_cycle(second, None, parents) is False


def test_in_use_message_names_what_is_connected():
    assert in_use_message("Reyee EW300N", 0, 2) == "Move the 2 cameras connected through Reyee EW300N first"
    assert in_use_message("Archer C64", 1, 1) == "Move the 1 device and 1 camera connected through Archer C64 first"


def test_device_payloads_clean_and_validate():
    device = NetworkDeviceCreate(name="  Archer C64 ", kind="router", host="192.168.1.1")
    assert device.name == "Archer C64"
    assert device.probe_port == 80
    assert device.enabled is True
    with pytest.raises(ValidationError):
        NetworkDeviceCreate(name="Bad", kind="router", host="not a host")
    with pytest.raises(ValidationError):
        NetworkDeviceCreate(name="Bad", kind="modem", host="192.168.1.1")
    with pytest.raises(ValidationError):
        NetworkDeviceUpdate(name=None)
    assert NetworkDeviceUpdate(parent_uuid=None).model_fields_set == {"parent_uuid"}


def test_camera_link_needs_a_link_with_a_parent():
    parent = uuid4()
    assert CameraLinkUpdate(parent_uuid=parent, link="wifi_24").link == "wifi_24"
    assert CameraLinkUpdate(parent_uuid=None).link is None
    with pytest.raises(ValidationError):
        CameraLinkUpdate(parent_uuid=parent)
    with pytest.raises(ValidationError):
        CameraLinkUpdate(parent_uuid=None, link="cable")


async def test_a_device_cannot_connect_through_one_behind_it():
    root, child = uuid4(), uuid4()
    session = FakeSession(rows=[[(root, None), (child, root)]])
    with pytest.raises(Unprocessable) as error:
        await NetworkDeviceService(session).check_parent(root, child)
    assert error.value.code == "invalid_parent"


async def test_a_device_with_connected_cameras_is_not_deleted():
    device = NetworkDevice(id=1, uuid=uuid4(), name="Reyee EW300N", deleted_at=None)
    session = FakeSession(scalars=[device, 0, 2])
    with pytest.raises(Conflict) as error:
        await NetworkDeviceService(session).delete(device.uuid)
    assert error.value.code == "network_device_in_use"
    assert session.commits == 0
    assert device.deleted_at is None
    assert "camera_links.deleted_at IS NULL" in sql(session.statements[2])


async def test_bucket_counts_group_by_date_bin_from_the_window_start():
    window = bucket_window(NOW, 3600, 60)
    target = uuid4()
    rows = [type("Row", (), {"target_uuid": target, "bucket": window.start(3), "samples": 6, "ok": 5, "latency": 9.5})]
    session = FakeSession(rows=[rows])
    counts = await HealthOverviewService(session, interval=10).bucket_counts([target], window)
    assert counts[target][window.start(3)].samples == 6
    assert counts[target][window.start(3)].ok == 5
    query = sql(session.statements[0])
    assert "date_bin(" in query
    assert "count(*) FILTER (WHERE health_samples.ok IS true)" in query
    assert "health_samples.created_at >=" in query
