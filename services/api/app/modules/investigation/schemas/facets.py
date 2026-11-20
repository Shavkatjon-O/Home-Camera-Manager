"""Schemas of the values the event search can filter by."""

from uuid import UUID

from pydantic import BaseModel

__all__ = ["ClusterFacet", "Facets", "LineFacet", "PersonFacet", "ViewFacet", "ZoneFacet"]


class ViewFacet(BaseModel):
    """Camera view to filter by.

    Attributes:
        id: Id of the view.
        name: Name of the view.
        camera_uuid: Camera the view belongs to.
    """

    id: str
    name: str
    camera_uuid: UUID


class ZoneFacet(BaseModel):
    """Zone to filter by.

    Attributes:
        id: Id of the zone.
        name: Name of the zone.
        view: Id of the view the zone is drawn on.
    """

    id: str
    name: str
    view: str


class LineFacet(BaseModel):
    """Line to filter by.

    Attributes:
        id: Id of the line.
        name: Name of the line.
        view: Id of the view the line is drawn on.
    """

    id: str
    name: str
    view: str


class PersonFacet(BaseModel):
    """Person to filter by.

    Attributes:
        uuid: Public id of the person.
        name: Name of the person.
        color: Color of the person.
    """

    uuid: UUID
    name: str
    color: str


class ClusterFacet(BaseModel):
    """Unknown cluster to filter by.

    Attributes:
        uuid: Public id of the cluster.
        label: Label of the cluster, Unknown N.
    """

    uuid: UUID
    label: str


class Facets(BaseModel):
    """Values the event search can filter by.

    Attributes:
        kinds: Event kinds that occur.
        labels: Object labels that occur.
        views: Camera views.
        zones: Zones.
        lines: Lines.
        people: Live people.
        clusters: Live unknown clusters.
    """

    kinds: list[str]
    labels: list[str]
    views: list[ViewFacet]
    zones: list[ZoneFacet]
    lines: list[LineFacet]
    people: list[PersonFacet]
    clusters: list[ClusterFacet]
