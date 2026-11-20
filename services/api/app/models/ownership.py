"""Mixins that tie a row to the organisation and site it belongs to."""

from sqlalchemy import BigInteger, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

__all__ = ["OrganisationOwned", "SiteOwned"]


class OrganisationOwned:
    """Row that belongs to one organisation, such as a person of its face gallery.

    The column is nullable so that rows written before the organisations existed survive the migration; the
    bootstrap assigns them at start.

    Attributes:
        organisation_id: Organisation the row belongs to.
    """

    organisation_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("organisations.id"), nullable=True, index=True
    )


class SiteOwned(OrganisationOwned):
    """Row that belongs to one site of an organisation, such as a camera or an event.

    Attributes:
        site_id: Site the row belongs to.
    """

    site_id: Mapped[int | None] = mapped_column(BigInteger, ForeignKey("sites.id"), nullable=True, index=True)
