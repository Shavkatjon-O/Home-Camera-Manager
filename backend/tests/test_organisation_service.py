from types import SimpleNamespace

import pytest

from app.core.exceptions import Unprocessable
from app.modules.organisations.enums import Role
from app.modules.organisations.schemas import OrganisationUpdate
from app.modules.organisations.services import organisations as module
from app.modules.organisations.services.organisations import FACES_CONSENT, OrganisationService
from app.tenancy.access import OrganisationAccess
from tests.fakes import site_access


class FakeSession:
    def __init__(self):
        self.commits = 0
        self.refreshed = []

    async def commit(self):
        self.commits += 1

    async def refresh(self, item):
        self.refreshed.append(item)


@pytest.fixture
def setup(monkeypatch):
    organisation = SimpleNamespace(
        name="Acme", faces_enabled=False, faces_consent_at=None, faces_consent_by_id=None, faces_consent_version=None
    )
    user = site_access().user

    async def resolve(session, actor, uuid, needed=Role.VIEWER):
        return OrganisationAccess(
            user=actor, organisation=organisation, membership=SimpleNamespace(), role=Role.ADMIN, site_ids=None
        )

    monkeypatch.setattr(module, "resolve_organisation_access", resolve)
    session = FakeSession()
    service = OrganisationService(session, user)

    async def reads(items):
        return [items[0][0]]

    monkeypatch.setattr(service, "reads", reads)
    return service, organisation, session


@pytest.mark.parametrize(
    "payload",
    [
        {"faces_enabled": True},
        {"faces_enabled": True, "faces_consent": False, "consent_version": FACES_CONSENT.version},
        {"faces_enabled": True, "faces_consent": True},
        {"faces_enabled": True, "faces_consent": True, "consent_version": "1999-01-01"},
    ],
)
async def test_faces_on_without_current_consent_is_refused(setup, payload):
    service, organisation, session = setup
    with pytest.raises(Unprocessable) as caught:
        await service.update(organisation_uuid=None, payload=OrganisationUpdate(**payload))
    assert caught.value.code == "faces_consent_required"
    assert organisation.faces_enabled is False
    assert session.commits == 0


async def test_faces_on_with_current_consent_records_it(setup):
    service, organisation, session = setup
    payload = OrganisationUpdate(faces_enabled=True, faces_consent=True, consent_version=FACES_CONSENT.version)
    await service.update(organisation_uuid=None, payload=payload)
    assert organisation.faces_enabled is True
    assert organisation.faces_consent_version == FACES_CONSENT.version
    assert organisation.faces_consent_at is not None
    assert organisation.faces_consent_by_id == service.actor.id
    assert session.commits == 1


async def test_faces_off_needs_no_consent(setup):
    service, organisation, _ = setup
    organisation.faces_enabled = True
    await service.update(organisation_uuid=None, payload=OrganisationUpdate(faces_enabled=False))
    assert organisation.faces_enabled is False


async def test_rename_keeps_the_old_name_when_blank(setup):
    service, organisation, _ = setup
    await service.update(organisation_uuid=None, payload=OrganisationUpdate(name="   "))
    assert organisation.name == "Acme"
