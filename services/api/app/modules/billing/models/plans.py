"""Database model of a plan."""

from sqlalchemy import Boolean, Integer, String, false, text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["Plan"]


class Plan(BaseModel):
    """A plan an organisation is on: its limits and the features it turns on.

    The catalog in the billing services keeps the rows in step with the code at every start.

    Attributes:
        key: Stable key, such as free or internal.
        name: Name shown to people.
        limits: Limit name to its value; a missing or null value is unlimited.
        features: Feature names the plan turns on.
        public: Whether the plan is offered to customers; internal plans are assigned by platform admins only.
        position: Place in the plan list.
    """

    __tablename__ = "plans"

    key: Mapped[str] = mapped_column(String(30), unique=True, nullable=False)
    name: Mapped[str] = mapped_column(String(60), nullable=False)
    limits: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict, server_default=text("'{}'::jsonb"))
    features: Mapped[list] = mapped_column(JSONB, nullable=False, default=list, server_default=text("'[]'::jsonb"))
    public: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False, server_default=false())
    position: Mapped[int] = mapped_column(Integer, nullable=False, default=0, server_default="0")
