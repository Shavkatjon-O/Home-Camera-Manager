from types import SimpleNamespace

from app.models import Device
from app.modules.tenancy.services.bootstrap import BootstrapReport, backfill_devices


class Session:
    def __init__(self, cameras):
        self.cameras = cameras
        self.added = []

    async def scalars(self, statement):
        return self.cameras

    def add(self, item):
        self.added.append(item)

    async def flush(self):
        for position, item in enumerate(self.added, start=1):
            if getattr(item, "id", None) is None:
                item.id = 100 + position


def legacy_camera(**changes):
    values = {
        "site_id": 7,
        "organisation_id": 3,
        "connector_id": None,
        "brand": "onvif",
        "name": "Gate",
        "host": "192.168.1.20",
        "device_host": None,
        "onvif_port": 80,
        "rtsp_port": 554,
        "ptz_enabled": True,
        "sub_path": "/sub",
        "deleted_at": None,
        "capabilities": {},
        "device_id": None,
        "channel": None,
    }
    values.update(changes)
    return SimpleNamespace(**values)


def test_a_report_without_work_changes_nothing():
    assert not BootstrapReport().changed
    assert BootstrapReport(devices=1).changed
    assert BootstrapReport(assigned={"cameras": 2}).changed


async def test_legacy_cameras_become_the_first_channel_of_their_own_device():
    camera = legacy_camera()
    session = Session([camera])
    report = BootstrapReport()
    await backfill_devices(session, report)
    device = session.added[0]
    assert isinstance(device, Device) and report.devices == 1
    assert (device.site_id, device.organisation_id, device.adapter, device.host) == (7, 3, "onvif", "192.168.1.20")
    assert camera.device_id == device.id and camera.channel == 1
    assert camera.capabilities["control"]["ptz"] and camera.capabilities["media"]["sub"]


async def test_an_unknown_brand_falls_back_to_plain_rtsp_and_keeps_stored_capabilities():
    camera = legacy_camera(brand="mystery", capabilities={"adapter": "kept"})
    session = Session([camera])
    await backfill_devices(session, BootstrapReport())
    assert session.added[0].capabilities["adapter"] == "rtsp"
    assert camera.capabilities == {"adapter": "kept"}

