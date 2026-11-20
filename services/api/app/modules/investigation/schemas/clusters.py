"""Schemas of unknown face clusters, their naming and their merging."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, model_validator

from .people import Color, PersonName, Strict
from .samples import SampleRead, SightingRead

__all__ = ["ClusterList", "ClusterMerge", "ClusterName", "ClusterRead"]


class ClusterRead(BaseModel):
    """Unknown cluster with its newest samples and latest sightings.

    Attributes:
        uuid: Public id of the cluster.
        number: Number of the cluster.
        label: Label shown for the cluster, Unknown N.
        seen_count: Number of face events attributed to the cluster.
        first_seen_at: When the cluster's first face was seen.
        last_seen_at: When the cluster's latest face was seen.
        samples: The 6 newest samples.
        sightings: The 5 latest sightings.
        created_at: When the cluster was created.
        updated_at: When the cluster last changed.
    """

    uuid: UUID
    number: int
    label: str
    seen_count: int
    first_seen_at: datetime
    last_seen_at: datetime
    samples: list[SampleRead]
    sightings: list[SightingRead]
    created_at: datetime
    updated_at: datetime


class ClusterList(BaseModel):
    """One page of unknown clusters.

    Attributes:
        items: Clusters on the page.
        total: Number of clusters across all pages.
        page: One-based page number.
        page_size: Number of clusters per page.
    """

    items: list[ClusterRead]
    total: int
    page: int
    page_size: int


class ClusterName(Strict):
    """Request body that names an unknown cluster.

    Exactly one of person and name is sent.

    Attributes:
        person: Public id of an existing person the cluster joins.
        name: Name of a new person created from the cluster.
        color: Color of the person as #rrggbb, if it should be set.
    """

    person: UUID | None = None
    name: PersonName | None = None
    color: Color | None = None

    @model_validator(mode="after")
    def one_target(self):
        """Require exactly one of person and name.

        Returns:
            The validated request.

        Raises:
            ValueError: When both or neither are sent.
        """
        if (self.person is None) == (self.name is None):
            raise ValueError("send either person or name")
        return self


class ClusterMerge(Strict):
    """Request body that merges one unknown cluster into another.

    Attributes:
        into: Public id of the cluster that receives the samples and face events.
    """

    into: UUID
