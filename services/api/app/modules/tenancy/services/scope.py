"""Row-level tenancy: the scope a database session reads in and the ownership new rows receive.

A request of a member installs a scope on its database session. Every ORM select, update and delete in that
session is then limited to the rows of the scope's sites and organisation, whatever service runs it, and every new
row that belongs to a site or an organisation is stamped with its owner before it is written. Sessions without a
scope, such as those of the background engines and the internal routes of the analytics service, see every row.
"""

from collections import defaultdict
from dataclasses import dataclass, field

from sqlalchemy import event, select
from sqlalchemy.orm import ORMExecuteState, Session, with_loader_criteria

from app.core.database import UNSCOPED_OPTION
from app.models import (
    AnalyticsAppearance,
    AnalyticsArea,
    AnalyticsCount,
    AnalyticsJourney,
    AnalyticsLine,
    AnalyticsSettings,
    AnalyticsView,
    AnalyticsZone,
    Camera,
    CameraLink,
    Connector,
    Device,
    DiscoveredCamera,
    Event,
    FaceSample,
    FloorPlan,
    HealthSample,
    NetworkDevice,
    Outage,
    PairingAttempt,
    Person,
    TelegramChat,
    TelegramLink,
    TvDevice,
    UnknownCluster,
    UsageRollup,
)
from app.models.ownership import OrganisationOwned, SiteOwned

__all__ = [
    "ORGANISATION_SCOPED",
    "PARENTS",
    "SCOPE_KEY",
    "SITE_SCOPED",
    "UNSCOPED_OPTION",
    "Scope",
    "install_scope",
    "scope_of",
]

SCOPE_KEY = "tenancy_scope"

SITE_SCOPED = (
    AnalyticsAppearance,
    AnalyticsArea,
    AnalyticsCount,
    AnalyticsJourney,
    AnalyticsLine,
    AnalyticsSettings,
    AnalyticsView,
    AnalyticsZone,
    Camera,
    CameraLink,
    Connector,
    Device,
    DiscoveredCamera,
    Event,
    FloorPlan,
    HealthSample,
    NetworkDevice,
    Outage,
    TvDevice,
)

ORGANISATION_SCOPED = (FaceSample, PairingAttempt, Person, TelegramChat, TelegramLink, UnknownCluster, UsageRollup)

PARENTS = {
    AnalyticsView: (("camera_uuid", Camera, "uuid"),),
    AnalyticsZone: (("view_id", AnalyticsView, "id"),),
    AnalyticsLine: (("view_id", AnalyticsView, "id"),),
    AnalyticsCount: (("view_uuid", AnalyticsView, "uuid"),),
    AnalyticsAppearance: (("view_uuid", AnalyticsView, "uuid"), ("camera_uuid", Camera, "uuid")),
    Event: (("camera_uuid", Camera, "uuid"),),
    CameraLink: (("camera_uuid", Camera, "uuid"),),
    Camera: (("device_id", Device, "id"), ("connector_id", Connector, "id")),
    Device: (("connector_id", Connector, "id"),),
    DiscoveredCamera: (("connector_id", Connector, "id"),),
    FaceSample: (("camera_uuid", Camera, "uuid"), ("person_id", Person, "id"), ("cluster_id", UnknownCluster, "id")),
    HealthSample: (("target_uuid", Camera, "uuid"), ("target_uuid", NetworkDevice, "uuid")),
    Outage: (("target_uuid", Camera, "uuid"), ("target_uuid", NetworkDevice, "uuid")),
}


@dataclass(frozen=True)
class Scope:
    """The rows a session may read and the owner of the rows it creates.

    Attributes:
        organisation_id: Organisation whose organisation-wide rows, such as the face gallery, are visible.
        site_ids: Sites whose rows are visible.
        site_id: Site new site rows belong to.
    """

    organisation_id: int
    site_ids: frozenset[int] = field(default_factory=frozenset)
    site_id: int | None = None


def install_scope(session, scope: Scope) -> None:
    """Limit a session to a scope from now on.

    Args:
        session: Async or sync database session.
        scope: The scope.
    """
    session.info[SCOPE_KEY] = scope


def scope_of(session) -> Scope | None:
    """Return the scope installed on a session.

    Args:
        session: Async or sync database session.

    Returns:
        The scope, or None for an unscoped session.
    """
    return session.info.get(SCOPE_KEY)


def scope_criteria(scope: Scope) -> list:
    """Build the loader criteria that limit statements to a scope.

    Args:
        scope: The scope.

    Returns:
        One criteria option per scoped model.
    """
    site_ids = sorted(scope.site_ids)
    options = [with_loader_criteria(model, model.site_id.in_(site_ids), include_aliases=True) for model in SITE_SCOPED]
    options.extend(
        with_loader_criteria(model, model.organisation_id == scope.organisation_id, include_aliases=True)
        for model in ORGANISATION_SCOPED
    )
    return options


@event.listens_for(Session, "do_orm_execute")
def limit_to_scope(state: ORMExecuteState) -> None:
    """Add the scope's criteria to every select, update and delete of a scoped session.

    Column and relationship loads of already scoped rows are left alone, and a statement run with the unscoped
    execution option, such as an ownership lookup, is not limited.

    Args:
        state: The statement about to run.
    """
    scope = scope_of(state.session)
    if scope is None:
        return
    if not (state.is_select or state.is_update or state.is_delete):
        return
    if state.is_select and (state.is_column_load or state.is_relationship_load):
        return
    if state.execution_options.get(UNSCOPED_OPTION):
        return
    state.statement = state.statement.options(*scope_criteria(scope))


def needs_owner(item) -> bool:
    """Tell whether a new row still lacks its owner.

    Args:
        item: A pending object.

    Returns:
        True for a site row without a site or an organisation row without an organisation.
    """
    if isinstance(item, SiteOwned):
        return item.site_id is None or item.organisation_id is None
    if isinstance(item, OrganisationOwned):
        return item.organisation_id is None
    return False


def pending_owner(session: Session, parent, key: str, value) -> tuple[int | None, int | None] | None:
    """Find the owner of a parent row that is written in the same flush.

    Args:
        session: The session.
        parent: Parent model.
        key: Key attribute of the parent.
        value: Key value.

    Returns:
        The parent's site and organisation, or None when no pending parent has the key.
    """
    for item in session.new:
        if isinstance(item, parent) and getattr(item, key, None) == value:
            return getattr(item, "site_id", None), item.organisation_id
    return None


def stored_owners(session: Session, parent, key: str, values: set) -> dict:
    """Load the owners of stored parent rows by key in one query, ignoring the session's scope.

    Args:
        session: The session.
        parent: Parent model.
        key: Key attribute of the parent.
        values: Key values.

    Returns:
        Key value to site and organisation.
    """
    column = getattr(parent, key)
    site = parent.site_id if issubclass(parent, SiteOwned) else None
    columns = [column, site, parent.organisation_id] if site is not None else [column, parent.organisation_id]
    rows = session.execute(
        select(*columns).where(column.in_(list(values))).execution_options(**{UNSCOPED_OPTION: True})
    ).all()
    if site is None:
        return {row[0]: (None, row[1]) for row in rows}
    return {row[0]: (row[1], row[2]) for row in rows}


def apply_owner(item, site_id: int | None, organisation_id: int | None) -> None:
    """Fill the missing owner fields of a row.

    Args:
        item: The pending object.
        site_id: Site to set when the row has none.
        organisation_id: Organisation to set when the row has none.
    """
    if isinstance(item, SiteOwned) and item.site_id is None and site_id is not None:
        item.site_id = site_id
    if item.organisation_id is None and organisation_id is not None:
        item.organisation_id = organisation_id


def assign_from_parents(session: Session, items: list) -> None:
    """Give new rows the owner of the row they hang off, such as a view the site of its camera.

    Args:
        session: The session.
        items: Pending objects that lack an owner.
    """
    wanted: dict[tuple, set] = defaultdict(set)
    for item in items:
        for attribute, parent, key in PARENTS.get(type(item), ()):
            value = getattr(item, attribute, None)
            if value is not None and pending_owner(session, parent, key, value) is None:
                wanted[(parent, key)].add(value)
    found = {target: stored_owners(session, *target, values) for target, values in wanted.items() if values}
    for item in items:
        for attribute, parent, key in PARENTS.get(type(item), ()):
            if not needs_owner(item):
                break
            value = getattr(item, attribute, None)
            if value is None:
                continue
            owner = pending_owner(session, parent, key, value) or found.get((parent, key), {}).get(value)
            if owner is not None:
                apply_owner(item, *owner)


@event.listens_for(Session, "before_flush")
def stamp_owners(session: Session, flush_context, instances) -> None:
    """Stamp new rows with their site and organisation before they are written.

    A row takes the owner of its parent first, so that a view or an event written by the analytics service belongs
    to its camera's site; a row without a parent takes the site of the session's scope.

    Args:
        session: The session being flushed.
        flush_context: Flush context of SQLAlchemy.
        instances: Objects passed to flush, unused.
    """
    items = [item for item in session.new if needs_owner(item)]
    if not items:
        return
    assign_from_parents(session, items)
    scope = scope_of(session)
    if scope is None:
        return
    for item in items:
        if needs_owner(item):
            apply_owner(item, scope.site_id, scope.organisation_id)
