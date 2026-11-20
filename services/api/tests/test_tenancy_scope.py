from types import SimpleNamespace
from uuid import uuid4

from app.models import Camera, Person
from app.modules.tenancy.services.scope import (
    ORGANISATION_SCOPED,
    SITE_SCOPED,
    Scope,
    apply_owner,
    install_scope,
    needs_owner,
    scope_criteria,
    scope_of,
)


def camera(**fields):
    return Camera(uuid=uuid4(), name="Door", **fields)


def test_scope_criteria_has_one_option_per_scoped_model():
    options = scope_criteria(Scope(organisation_id=1, site_ids=frozenset({1, 2}), site_id=1))
    assert len(options) == len(SITE_SCOPED) + len(ORGANISATION_SCOPED)


def test_scope_without_sites_still_builds_criteria():
    assert len(scope_criteria(Scope(organisation_id=1))) == len(SITE_SCOPED) + len(ORGANISATION_SCOPED)


def test_site_row_without_owner_needs_one():
    assert needs_owner(camera())


def test_site_row_with_only_a_site_still_needs_the_organisation():
    assert needs_owner(camera(site_id=1))


def test_site_row_with_both_owners_needs_nothing():
    assert not needs_owner(camera(site_id=1, organisation_id=2))


def test_organisation_row_needs_only_the_organisation():
    assert needs_owner(Person(name="Alice"))
    assert not needs_owner(Person(name="Alice", organisation_id=2))


def test_object_that_is_not_owned_never_needs_an_owner():
    assert not needs_owner(object())


def test_apply_owner_fills_the_missing_fields():
    item = camera()
    apply_owner(item, 3, 4)
    assert (item.site_id, item.organisation_id) == (3, 4)


def test_apply_owner_keeps_existing_values():
    item = camera(site_id=1, organisation_id=2)
    apply_owner(item, 3, 4)
    assert (item.site_id, item.organisation_id) == (1, 2)


def test_apply_owner_without_a_site_leaves_it_empty():
    item = camera()
    apply_owner(item, None, 4)
    assert item.site_id is None
    assert item.organisation_id == 4


def test_apply_owner_gives_an_organisation_row_only_the_organisation():
    item = Person(name="Alice")
    apply_owner(item, 3, 4)
    assert item.organisation_id == 4
    assert not hasattr(item, "site_id")


def test_scope_round_trips_through_the_session_info():
    session = SimpleNamespace(info={})
    assert scope_of(session) is None
    scope = Scope(organisation_id=1, site_ids=frozenset({2}), site_id=2)
    install_scope(session, scope)
    assert scope_of(session) is scope
