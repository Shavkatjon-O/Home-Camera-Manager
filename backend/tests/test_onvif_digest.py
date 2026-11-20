import base64
from datetime import UTC, datetime, timedelta

from adapters.onvif.client import OnvifClient
from adapters.onvif.digest import format_created, password_digest, security_header


def test_digest_matches_the_onvif_programmers_guide_example():
    nonce = base64.b64decode("LKqI6G/AikKCQrN0zqZFlg==")
    assert password_digest(nonce, "2010-09-16T07:50:45Z", "userpassword") == "tuOSpGlFlIXsozq4HFNeeGeFLEI="


def test_created_is_utc_with_seconds():
    moment = datetime(2026, 11, 18, 22, 6, 41, 900000, tzinfo=UTC)
    assert format_created(moment) == "2026-11-18T22:06:41Z"


def test_security_header_carries_username_digest_nonce_and_created():
    nonce = b"0123456789abcdef"
    created = datetime(2026, 1, 2, 3, 4, 5, tzinfo=UTC)
    header = security_header("ad<min", "secret", created, nonce)
    assert "<wsse:Username>ad&lt;min</wsse:Username>" in header
    assert password_digest(nonce, "2026-01-02T03:04:05Z", "secret") in header
    assert base64.b64encode(nonce).decode() in header
    assert "<wsu:Created>2026-01-02T03:04:05Z</wsu:Created>" in header
    assert "PasswordDigest" in header


async def test_no_security_header_without_password():
    client = OnvifClient("192.0.2.10", 8899, username="admin", password=None)
    assert await client.security() == ""


async def test_created_follows_the_device_clock(monkeypatch):
    client = OnvifClient("192.0.2.10", 80, username="admin", password="secret")
    device_time = datetime.now(UTC) + timedelta(hours=3)

    async def fake_device_time():
        return device_time

    monkeypatch.setattr(client, "system_date_and_time", fake_device_time)
    header = await client.security()
    created = header.split("<wsu:Created>")[1].split("</wsu:Created>")[0]
    stamp = datetime.strptime(created, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=UTC)
    assert abs((stamp - device_time).total_seconds()) < 5
