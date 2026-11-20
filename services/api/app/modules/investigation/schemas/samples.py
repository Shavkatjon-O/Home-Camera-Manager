"""Schemas of face samples and of the sightings they record."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

from app.modules.investigation.enums import SampleSource

__all__ = ["SampleRead", "SightingRead"]


class SampleRead(BaseModel):
    """Face sample of a person or of an unknown cluster.

    Attributes:
        uuid: Public id of the sample.
        source: Whether the sample was uploaded or seen by a camera.
        quality: Quality score of the face from 0 to 1.
        confidence: Recognition confidence of a camera sample, if any.
        seen_at: When the face was seen, or uploaded.
        has_crop: Whether the sample has a crop image.
        event_uuid: Face event the sample was taken from, if any.
        camera_uuid: Camera that saw the face, if any.
        camera_name: Name of that camera, if it still exists.
        view_name: Name of the camera view that saw the face, if any.
    """

    uuid: UUID
    source: SampleSource
    quality: float
    confidence: float | None
    seen_at: datetime
    has_crop: bool
    event_uuid: UUID | None
    camera_uuid: UUID | None
    camera_name: str | None
    view_name: str | None


class SightingRead(BaseModel):
    """One time a camera saw a person or an unknown cluster.

    Attributes:
        event_uuid: Face event of the sighting.
        sample_uuid: Face sample stored for the sighting.
        camera_uuid: Camera that saw the face.
        camera_name: Name of that camera, if it still exists.
        view_name: Name of the camera view that saw the face, if any.
        seen_at: When the face was seen.
        confidence: Recognition confidence, if any.
    """

    event_uuid: UUID | None
    sample_uuid: UUID
    camera_uuid: UUID | None
    camera_name: str | None
    view_name: str | None
    seen_at: datetime
    confidence: float | None
