"""Database models of a membership and the sites it is limited to."""

from sqlalchemy import BigInteger, Boolean, ForeignKey, String, UniqueConstraint, true
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["Membership", "MembershipSite"]


class Membership(BaseModel):
    """A user's role in an organisation and the sites it covers.

    Attributes:
        user_id: Member.
        organisation_id: Organisation.
        role: Role value, one of the Role members.
        all_sites: Whether the membership covers every site, including sites added later.
    """

    __tablename__ = "memberships"
    __table_args__ = (UniqueConstraint("user_id", "organisation_id"),)

    user_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    organisation_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("organisations.id", ondelete="CASCADE"), nullable=False, index=True
    )
    role: Mapped[str] = mapped_column(String(10), nullable=False)
    all_sites: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True, server_default=true())


class MembershipSite(BaseModel):
    """A site a membership limited to a list of sites covers.

    Attributes:
        membership_id: Membership.
        site_id: Site it covers.
    """

    __tablename__ = "membership_sites"
    __table_args__ = (UniqueConstraint("membership_id", "site_id"),)

    membership_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("memberships.id", ondelete="CASCADE"), nullable=False, index=True
    )
    site_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("sites.id", ondelete="CASCADE"), nullable=False)
