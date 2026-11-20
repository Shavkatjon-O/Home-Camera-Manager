import pytest

from app.devkit.seed import DemoSettings, parse_names, seed


def test_camera_names_are_read_by_address():
    assert parse_names("172.31.250.11=Gate, 172.31.250.12 = Yard,broken,=x") == {
        "172.31.250.11": "Gate",
        "172.31.250.12": "Yard",
    }


def test_members_get_an_address_per_role(monkeypatch):
    monkeypatch.setenv("SSS_DEMO_EMAIL_DOMAIN", "example.test")
    monkeypatch.setenv("DEVKIT_STORE_NAMES", "10.0.0.5=Till")
    demo = DemoSettings()
    assert demo.email("viewer") == "viewer@example.test"
    assert demo.store_names == {"10.0.0.5": "Till"}


async def test_the_seed_refuses_to_run_without_a_demo_password(monkeypatch):
    monkeypatch.delenv("SSS_DEMO_PASSWORD", raising=False)
    with pytest.raises(SystemExit, match="SSS_DEMO_PASSWORD"):
        await seed(DemoSettings())
