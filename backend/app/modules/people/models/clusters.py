"""Model of a cluster of faces that no known person matched."""

from datetime import datetime

from sqlalchemy import DateTime, Integer, LargeBinary
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["UnknownCluster"]


class UnknownCluster(BaseModel):
    """Group of face samples the analytics service judged to be one unknown person.

    Attributes:
        number: Number shown as Unknown N, never reused.
        centroid: Normalised mean of the embeddings of the cluster's samples, if it has any.
        seen_count: Number of face events attributed to the cluster.
        first_seen_at: When the cluster's first face was seen.
        last_seen_at: When the cluster's latest face was seen.
    """

    __tablename__ = "unknown_clusters"

    number: Mapped[int] = mapped_column(Integer, nullable=False, unique=True)
    centroid: Mapped[bytes | None] = mapped_column(LargeBinary(2048), nullable=True)
    seen_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)

    first_seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    last_seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
