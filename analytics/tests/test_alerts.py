from datetime import datetime

from app.rules.model import AlertPolicy, ArmMode

NIGHT = {"mode": "schedule", "labels": ["person"], "schedule": [{"start": "23:00", "end": "06:00"}]}


def test_disarmed_never_alerts_and_away_always_does():
    policy = AlertPolicy.from_dict(None)
    assert not policy.alerts(ArmMode.DISARMED, "person", datetime(2026, 11, 20, 2, 0))
    assert policy.alerts(ArmMode.AWAY, "dog", datetime(2026, 11, 20, 12, 0))


def test_schedule_mode_follows_the_alert_windows_and_labels():
    policy = AlertPolicy.from_dict(NIGHT)
    assert policy.alerts(ArmMode.SCHEDULE, "person", datetime(2026, 11, 20, 2, 0))
    assert not policy.alerts(ArmMode.SCHEDULE, "person", datetime(2026, 11, 20, 12, 0))
    assert not policy.alerts(ArmMode.SCHEDULE, "car", datetime(2026, 11, 20, 2, 0))
    assert not policy.alerts(ArmMode.HOME, "person", datetime(2026, 11, 20, 2, 0))


def test_always_policy_alerts_at_home():
    policy = AlertPolicy.from_dict({"mode": "always"})
    assert policy.alerts(ArmMode.HOME, "person", datetime(2026, 11, 20, 12, 0))
