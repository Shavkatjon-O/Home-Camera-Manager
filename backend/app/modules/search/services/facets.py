"""Service for the values the event search can filter by."""

from sqlalchemy import func, select

from app.core.base_service import BaseModelService
from app.models import Event, Person, UnknownCluster
from app.modules.people.services import cluster_label
from app.modules.search.schemas import ClusterFacet, Facets, PersonFacet

from .analytics import label_facets, rule_facets

__all__ = ["FacetService"]


class FacetService(BaseModelService[Event]):
    """List the kinds, labels, people and clusters that searches can filter by.

    Attributes:
        model: Events.
        not_found_code: Error code of an unknown event.
    """

    model = Event
    not_found_code = "event_not_found"

    async def facets(self) -> Facets:
        """Load the filter values.

        Returns:
            The kinds and labels that occur, the analytics views with their zones and lines, the live people by
            name and the live clusters by number.
        """
        kinds = list(
            await self.session.scalars(
                select(Event.kind).where(Event.deleted_at.is_(None)).distinct().order_by(Event.kind)
            )
        )
        labels = await label_facets(self.session)
        views, zones, lines = await rule_facets(self.session)
        people = (
            await self.session.execute(
                select(Person.uuid, Person.name, Person.color)
                .where(Person.deleted_at.is_(None))
                .order_by(func.lower(Person.name), Person.id)
            )
        ).all()
        clusters = (
            await self.session.execute(
                select(UnknownCluster.uuid, UnknownCluster.number)
                .where(UnknownCluster.deleted_at.is_(None))
                .order_by(UnknownCluster.number)
            )
        ).all()
        return Facets(
            kinds=kinds,
            labels=labels,
            views=views,
            zones=zones,
            lines=lines,
            people=[PersonFacet(uuid=uuid, name=name, color=color) for uuid, name, color in people],
            clusters=[ClusterFacet(uuid=uuid, label=cluster_label(number)) for uuid, number in clusters],
        )
