from datetime import UTC, datetime, timedelta
from uuid import UUID

import pytest
from pydantic import ValidationError

from app.core.rate_limit import RateLimiter
from app.core.security import hash_token, new_token
from app.models import Camera, TvPairing
from app.modules.devices.services import index_hosts
from app.modules.tv.enums import PairingState
from app.modules.tv.schemas import PairingApprove, PairingCreate, clean_device_name
from app.modules.tv.services import build_config, new_code, pairing_state, tile_label
from app.streaming.wall import wall_plan

NOW = datetime(2026, 11, 19, 12, 0, tzinfo=UTC)


class Clock:
    def __init__(self):
        self.now = 0.0

    def __call__(self) -> float:
        return self.now


def pairing(approved: bool = False, minutes: int = 5) -> TvPairing:
    return TvPairing(code="123456", device_name="TV", expires_at=NOW + timedelta(minutes=minutes), approved=approved)


def test_pairing_states():
    assert pairing_state(pairing(), NOW) == PairingState.PENDING
    assert pairing_state(pairing(minutes=-1), NOW) == PairingState.EXPIRED
    assert pairing_state(pairing(approved=True, minutes=-1), NOW) == PairingState.APPROVED


def test_codes_are_six_digits():
    for _ in range(200):
        code = new_code()
        assert len(code) == 6 and code.isdigit()


def test_tokens_hash_to_sha256_hex():
    token = new_token()
    assert len(token) >= 43
    assert hash_token(token) == hash_token(token)
    assert len(hash_token(token)) == 64
    assert hash_token(token) != hash_token(new_token())


def test_device_names_are_cleaned():
    assert clean_device_name("  Chromecast   HD ") == "Chromecast HD"
    assert clean_device_name("") == "TV"
    assert clean_device_name(None) == "TV"
    assert len(clean_device_name("x" * 300)) == 100
    assert PairingCreate(device_name=" sdk_google_atv64_amd64 ").device_name == "sdk_google_atv64_amd64"
    assert PairingCreate().device_name == "TV"


def test_approve_code_must_be_six_digits():
    assert PairingApprove(code=" 048 213 ").code == "048213"
    with pytest.raises(ValidationError):
        PairingApprove(code="12345")
    with pytest.raises(ValidationError):
        PairingApprove(code="12a456")


def test_rate_limiter_counts_per_key_and_window():
    clock = Clock()
    limiter = RateLimiter(2, 60, clock)
    assert limiter.allow("a")
    assert limiter.allow("a")
    assert not limiter.allow("a")
    assert limiter.allow("b")
    clock.now = 60.0
    assert limiter.allow("a")


def test_config_lists_tiles_with_rtsp_urls():
    gate = Camera(uuid=UUID(int=1), name="Gate", lenses=1, sub_path="/sub", ptz_enabled=False)
    yard = Camera(uuid=UUID(int=2), name="Yard", lenses=2, sub_path=None, ptz_enabled=True)
    plan = wall_plan([gate, yard])
    config = build_config(plan, "192.168.1.219", "tv", "secret")
    assert config.wall.url == "rtsp://tv:secret@192.168.1.219:8554/tv_wall"
    assert (config.wall.cols, config.wall.rows) == (2, 2)
    assert [(tile.index, tile.label, tile.lens, tile.ptz) for tile in config.tiles] == [
        (0, "Gate", None, False),
        (2, "Yard, lens 1", 0, True),
        (3, "Yard, lens 2", 1, True),
    ]
    assert config.tiles[1].url == "rtsp://tv:secret@192.168.1.219:8554/tv_tile_2"
    assert config.tiles[2].camera_uuid == yard.uuid
    assert tile_label(plan.cells[0]) == "Gate"


def test_config_without_cameras_has_no_wall_url():
    config = build_config(wall_plan([]), "h", "tv", "secret")
    assert config.wall.url == ""
    assert config.tiles == []


def test_discovery_matches_bridged_cameras_by_device_host():
    direct = Camera(uuid=UUID(int=1), host="192.168.1.104", device_host=None)
    bridged = Camera(uuid=UUID(int=2), host="smart-surveillance-system-v380-ptz-1", device_host="192.168.1.237")
    hosts = index_hosts([direct, bridged])
    assert hosts["192.168.1.104"] is direct
    assert hosts["192.168.1.237"] is bridged
    assert hosts["smart-surveillance-system-v380-ptz-1"] is bridged
