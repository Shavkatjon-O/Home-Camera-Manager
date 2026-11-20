from uuid import uuid4

import pytest
from starlette.requests import Request

from app.core.exceptions import Forbidden
from app.modules.organisations.enums import Role, role_rank
from app.tenancy import dependencies
from app.tenancy.access import OrganisationAccess, check_role
from app.tenancy.bootstrap import BootstrapReport
from app.tenancy.scope import Scope
from tests.fakes import site_access


def request(query="", cookie=""):
    headers = [(b"cookie", cookie.encode())] if cookie else []
    return Request({"type": "http", "query_string": query.encode(), "headers": headers})


def test_role_rank_orders_the_roles():
    assert role_rank(Role.VIEWER) < role_rank(Role.OPERATOR) < role_rank(Role.ADMIN) < role_rank(Role.OWNER)


def test_role_rank_accepts_the_value_text():
    assert role_rank("admin") == role_rank(Role.ADMIN)


@pytest.mark.parametrize(
    "role,needed",
    [(Role.VIEWER, Role.OPERATOR), (Role.OPERATOR, Role.ADMIN), (Role.ADMIN, Role.OWNER), (Role.VIEWER, Role.OWNER)],
)
def test_check_role_refuses_a_weaker_role(role, needed):
    with pytest.raises(Forbidden) as caught:
        check_role(role, needed)
    assert caught.value.code == "role_required"
    assert needed.value in caught.value.message


@pytest.mark.parametrize(
    "role,needed", [(Role.OPERATOR, Role.OPERATOR), (Role.OWNER, Role.VIEWER), (Role.ADMIN, Role.OPERATOR)]
)
def test_check_role_accepts_an_equal_or_stronger_role(role, needed):
    check_role(role, needed)


def test_site_access_allows_by_rank():
    access = site_access(role=Role.OPERATOR)
    assert access.allows(Role.VIEWER)
    assert access.allows(Role.OPERATOR)
    assert not access.allows(Role.ADMIN)


def test_organisation_access_allows_by_rank():
    access = OrganisationAccess(user=None, organisation=None, membership=None, role=Role.ADMIN, site_ids=None)
    assert access.allows(Role.OPERATOR)
    assert access.allows(Role.ADMIN)
    assert not access.allows(Role.OWNER)


def test_site_header_wins_over_query_and_cookie():
    header, query, cookie = uuid4(), uuid4(), uuid4()
    found = dependencies.requested_site(request(f"site={query}", f"sss_site={cookie}"), header)
    assert found == (header, True)


def test_site_query_wins_over_cookie_and_is_strict():
    query, cookie = uuid4(), uuid4()
    found = dependencies.requested_site(request(f"site={query}", f"sss_site={cookie}"), None)
    assert found == (query, True)


def test_site_cookie_is_not_strict():
    cookie = uuid4()
    assert dependencies.requested_site(request(cookie=f"sss_site={cookie}"), None) == (cookie, False)


def test_invalid_query_uuid_falls_to_the_cookie():
    cookie = uuid4()
    found = dependencies.requested_site(request("site=nope", f"sss_site={cookie}"), None)
    assert found == (cookie, False)


def test_invalid_cookie_uuid_is_ignored():
    assert dependencies.requested_site(request(cookie="sss_site=nope"), None) == (None, False)


def test_no_site_named_gives_none():
    assert dependencies.requested_site(request(), None) == (None, False)


def test_site_scope_covers_one_site_and_its_organisation():
    access = site_access()
    assert dependencies.site_scope(access) == Scope(
        organisation_id=access.organisation_id, site_ids=frozenset({access.site_id}), site_id=access.site_id
    )


@pytest.mark.parametrize(
    "fields",
    [{}, {"organisation_created": False}],
)
def test_empty_bootstrap_report_did_not_change(fields):
    assert not BootstrapReport(**fields).changed


@pytest.mark.parametrize("field", ["organisation_created", "site_created", "membership_created"])
def test_bootstrap_report_changed_by_any_creation(field):
    assert BootstrapReport(**{field: True}).changed


def test_bootstrap_report_changed_by_assigned_rows():
    assert BootstrapReport(assigned={"cameras": 3}).changed
    assert not BootstrapReport(assigned={"cameras": 0}).changed
