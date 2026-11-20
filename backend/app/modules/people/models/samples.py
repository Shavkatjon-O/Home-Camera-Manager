"""Model of a face sample, the embedding of one face of a person or of an unknown cluster."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import BigInteger, CheckConstraint, DateTime, Float, ForeignKey, LargeBinary, String, Uuid
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

__all__ = ["FaceSample"]


class FaceSample(BaseModel):
    """Face with its embedding, owned by exactly one person or one unknown cluster.

    Attributes:
        person_id: Person the face belongs to, if known.
        cluster_id: Unknown cluster the face belongs to, if no person.
        source: Whether the face was uploaded or seen by a camera.
        embedding: The 512 float32 values of the normalised embedding as 2048 bytes.
        crop_path: Crop image path relative to the events folder, if any.
        quality: Quality score of the face from 0 to 1.
        confidence: Recognition confidence of a camera face, if any.
        event_uuid: Face event the sample belongs to, if seen by a camera.
        camera_uuid: Camera that saw the face, if any.
        view: Id of the camera view that saw the face, if any.
        view_name: Name of that view, if any.
        track_id: Tracker id of the person track, if any.
        seen_at: When the face was seen, or uploaded.
        details: Further facts about the face as a stored JSON object.
    """

    __tablename__ = "face_samples"
    __table_args__ = (CheckConstraint("(person_id IS NULL) <> (cluster_id IS NULL)", name="one_owner"),)

    person_id: Mapped[int | None] = mapped_column(BigInteger, ForeignKey("people.id"), nullable=True, index=True)
    cluster_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("unknown_clusters.id"), nullable=True, index=True
    )
    source: Mapped[str] = mapped_column(String(10), nullable=False)

    embedding: Mapped[bytes] = mapped_column(LargeBinary(2048), nullable=False)
    crop_path: Mapped[str | None] = mapped_column(String(255), nullable=True)
    quality: Mapped[float] = mapped_column(Float, nullable=False)
    confidence: Mapped[float | None] = mapped_column(Float, nullable=True)

    event_uuid: Mapped[UUID | None] = mapped_column(Uuid(as_uuid=True), nullable=True, index=True)
    camera_uuid: Mapped[UUID | None] = mapped_column(Uuid(as_uuid=True), nullable=True)
    view: Mapped[str | None] = mapped_column(String(120), nullable=True)
    view_name: Mapped[str | None] = mapped_column(String(120), nullable=True)
    track_id: Mapped[int | None] = mapped_column(BigInteger, nullable=True)

    seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)

    details: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
