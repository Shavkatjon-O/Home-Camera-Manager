from app.core.config import settings
from app.modules.tenancy.services.sites import effective_retention


def test_a_site_keeps_events_for_the_shortest_of_its_setting_its_plan_and_the_server(monkeypatch):
    monkeypatch.setattr(settings, "events_retention_days", 30)
    assert effective_retention(None, None) == 30
    assert effective_retention(None, 14) == 14
    assert effective_retention(7, 14) == 7
    assert effective_retention(60, None) == 30
