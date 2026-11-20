from types import SimpleNamespace

import pytest

from app.modules.devices.services.control import CONNECTOR_REASON, CameraControlService, NotOffered


async def test_cameras_behind_a_connector_are_not_offered_rather_than_refused():
    service = CameraControlService.__new__(CameraControlService)
    with pytest.raises(NotOffered) as caught:
        await service.device_connection(SimpleNamespace(connector_id=3))
    assert str(caught.value) == CONNECTOR_REASON
    assert service.forbid(caught.value).code == "not_supported"
    service.reachable(SimpleNamespace(connector_id=None))
