"""Schema of the face shown with a face event."""

from uuid import UUID

from pydantic import BaseModel

from app.modules.investigation.enums import FaceStatus

__all__ = ["FaceRead"]


class FaceRead(BaseModel):
    """Who a face event shows, resolved from the people tables when it is read.

    Attributes:
        status: Whether the face is a known person or unknown.
        person_uuid: Public id of the person, if known.
        person_name: Name of the person, if they still exist.
        person_color: Color of the person, if they still exist.
        cluster_uuid: Public id of the unknown cluster, if any.
        cluster_label: Label of the cluster, Unknown N, if it exists.
        confidence: Recognition confidence, if any.
        sample_uuid: Face sample stored for the event, if it still exists.
        has_crop: Whether a crop of the face is stored.
    """

    status: FaceStatus
    person_uuid: UUID | None
    person_name: str | None
    person_color: str | None
    cluster_uuid: UUID | None
    cluster_label: str | None
    confidence: float | None
    sample_uuid: UUID | None
    has_crop: bool
