from datetime import UTC, datetime, timedelta

import pytest

from app.models import ConnectorPairing
from app.modules.devices.enums import DEVICE_GRANT, DeviceGrantError
from app.modules.devices.services.connector_pairing import SLOW_DOWN_STEP, DeviceGrantRefusal, PairingService


class FakeSession:
    def __init__(self, pairing=None):
        self.pairing = pairing
        self.commits = 0

    async def scalar(self, statement):
        return self.pairing

    async def commit(self):
        self.commits += 1


def pairing(**fields):
    base = {
        "expires_at": datetime.now(UTC) + timedelta(minutes=5),
        "claimed_at": None,
        "delivered_at": None,
        "last_polled_at": None,
        "interval": 5,
    }
    base.update(fields)
    return ConnectorPairing(**base)


async def refusal(session, grant=DEVICE_GRANT):
    with pytest.raises(DeviceGrantRefusal) as caught:
        await PairingService(session).token(grant, "device-code")
    return caught.value


async def test_unsupported_grant_type():
    found = await refusal(FakeSession(), "password")
    assert found.error == DeviceGrantError.UNSUPPORTED


async def test_unknown_code():
    found = await refusal(FakeSession(None))
    assert found.error == DeviceGrantError.INVALID_GRANT


async def test_code_already_delivered():
    found = await refusal(FakeSession(pairing(delivered_at=datetime.now(UTC))))
    assert found.error == DeviceGrantError.INVALID_GRANT


async def test_expired_pairing():
    found = await refusal(FakeSession(pairing(expires_at=datetime.now(UTC) - timedelta(seconds=1))))
    assert found.error == DeviceGrantError.EXPIRED


async def test_first_poll_of_an_unclaimed_pairing_is_pending():
    session = FakeSession(pairing())
    found = await refusal(session)
    assert found.error == DeviceGrantError.PENDING
    assert session.commits == 1
    assert session.pairing.last_polled_at is not None


async def test_slow_poll_of_an_unclaimed_pairing_is_pending():
    session = FakeSession(pairing(last_polled_at=datetime.now(UTC) - timedelta(seconds=30)))
    assert (await refusal(session)).error == DeviceGrantError.PENDING


async def test_too_fast_poll_raises_slow_down_with_a_longer_interval():
    session = FakeSession(pairing(last_polled_at=datetime.now(UTC) - timedelta(seconds=1)))
    found = await refusal(session)
    assert found.error == DeviceGrantError.SLOW_DOWN
    assert found.interval == 5 + SLOW_DOWN_STEP
    assert session.pairing.interval == 5 + SLOW_DOWN_STEP
    assert session.commits == 1
