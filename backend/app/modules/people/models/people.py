"""Model of a person the cameras can recognise."""

from sqlalchemy import String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["Person"]


class Person(BaseModel):
    """Person known by name, recognised from the face samples that belong to them.

    Attributes:
        name: Name shown for the person.
        notes: Free notes about the person, if any.
        color: Color that marks the person in the interface, as #rrggbb.
    """

    __tablename__ = "people"

    name: Mapped[str] = mapped_column(String(80), nullable=False)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    color: Mapped[str] = mapped_column(String(7), nullable=False)
