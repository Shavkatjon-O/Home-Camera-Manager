from datetime import UTC, datetime, timedelta
from types import SimpleNamespace
from uuid import uuid4

import pytest
from pydantic import ValidationError

from app.models import Invitation
from app.modules.identity.schemas.auth import AccountRegister, TokenRequest, clean_email
from app.modules.tenancy.enums import Role
from app.modules.tenancy.schemas import InvitationCreate, InvitationStatus, SiteCreate, check_timezone
from app.modules.tenancy.services.invitations import display_name, invitation_status

NOW = datetime(2026, 11, 20, 12, 0, tzinfo=UTC)


def test_clean_email_lowercases_and_trims():
    assert clean_email("  Alice@Example.ORG ") == "alice@example.org"


@pytest.mark.parametrize("value", ["alice", "alice@example", "@example.org", "al ice@example.org", "alice@"])
def test_clean_email_refuses_a_malformed_address(value):
    with pytest.raises(ValueError):
        clean_email(value)


def test_register_refuses_a_short_password():
    with pytest.raises(ValidationError):
        AccountRegister(email="a@example.org", password="1234567")


def test_register_accepts_eight_characters_and_cleans_the_fields():
    account = AccountRegister(email="A@Example.org", password="12345678", name="  Alice ")
    assert account.email == "a@example.org"
    assert account.name == "Alice"


def test_register_turns_a_blank_name_into_none():
    assert AccountRegister(email="a@example.org", password="12345678", name="   ").name is None


def test_token_request_defaults():
    request = TokenRequest(email="a@example.org", password="x")
    assert request.device_name == "Phone"
    assert request.platform == "android"


def test_invitation_refuses_the_owner_role():
    with pytest.raises(ValidationError):
        InvitationCreate(email="a@example.org", role=Role.OWNER)


def test_invitation_refuses_no_sites_when_not_all_sites():
    with pytest.raises(ValidationError):
        InvitationCreate(email="a@example.org", all_sites=False, sites=[])


def test_invitation_accepts_a_named_site():
    invitation = InvitationCreate(email="A@example.org", all_sites=False, sites=[uuid4()])
    assert invitation.email == "a@example.org"
    assert invitation.role == Role.VIEWER


def test_site_refuses_an_unknown_time_zone():
    with pytest.raises(ValidationError):
        SiteCreate(name="Home", timezone="Mars/Olympus")


def test_site_refuses_a_blank_name():
    with pytest.raises(ValidationError):
        SiteCreate(name="   ")


def test_site_defaults_to_utc_and_trims_the_name():
    site = SiteCreate(name=" Home ")
    assert site.name == "Home"
    assert site.timezone == "UTC"


def test_check_timezone_accepts_tashkent():
    assert check_timezone(" Asia/Tashkent ") == "Asia/Tashkent"


def invitation(**fields):
    base = {"accepted_at": None, "revoked_at": None, "expires_at": NOW + timedelta(days=1)}
    base.update(fields)
    return Invitation(**base)


def test_pending_invitation():
    assert invitation_status(invitation(), NOW) == InvitationStatus.PENDING


def test_accepted_invitation_wins_over_expiry():
    found = invitation(accepted_at=NOW, expires_at=NOW - timedelta(days=1))
    assert invitation_status(found, NOW) == InvitationStatus.ACCEPTED


def test_revoked_invitation():
    assert invitation_status(invitation(revoked_at=NOW), NOW) == InvitationStatus.REVOKED


def test_expired_invitation():
    assert invitation_status(invitation(expires_at=NOW), NOW) == InvitationStatus.EXPIRED


def test_display_name_prefers_name_then_email_then_username():
    assert display_name(SimpleNamespace(name="Alice", email="a@x.org", username="a")) == "Alice"
    assert display_name(SimpleNamespace(name=None, email="a@x.org", username="a")) == "a@x.org"
    assert display_name(SimpleNamespace(name=None, email=None, username="a")) == "a"
    assert display_name(None) is None
