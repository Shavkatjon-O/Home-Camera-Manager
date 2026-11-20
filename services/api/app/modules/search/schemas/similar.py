"""Schemas of the face similarity search."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, model_validator

from app.modules.people.enums import SampleSource
from app.modules.people.schemas.people import PHOTO_DATA_MAX_CHARS

__all__ = ["SimilarPage", "SimilarQuery", "SimilarRead"]

PAGE_SIZE_DEFAULT = 50
PAGE_SIZE_MAX = 200


class SimilarQuery(BaseModel):
    """Request body of a similarity search; exactly one of sample, event and photo is the query.

    Attributes:
        sample: Public id of a face sample to search with.
        event: Public id of a face event whose sample to search with.
        photo: Photo as a base64 data URL holding exactly one face.
        page: One-based page number.
        page_size: Number of results per page.
    """

    model_config = ConfigDict(extra="forbid")

    sample: UUID | None = None
    event: UUID | None = None
    photo: str | None = Field(default=None, min_length=1, max_length=PHOTO_DATA_MAX_CHARS)
    page: int = Field(default=1, ge=1)
    page_size: int = Field(default=PAGE_SIZE_DEFAULT, ge=1, le=PAGE_SIZE_MAX)

    @model_validator(mode="after")
    def one_query(self):
        """Require exactly one query.

        Returns:
            The validated request.

        Raises:
            ValueError: When none or several of sample, event and photo are sent.
        """
        if sum(value is not None for value in (self.sample, self.event, self.photo)) != 1:
            raise ValueError("send exactly one of sample, event and photo")
        return self


class SimilarRead(BaseModel):
    """Stored face sample similar to the query.

    Attributes:
        sample_uuid: Public id of the sample.
        score: Cosine similarity to the query from 0.25 to 1.
        source: Whether the sample was uploaded or seen by a camera.
        seen_at: When the face was seen, or uploaded.
        has_crop: Whether the sample has a crop image.
        person_uuid: Person the sample belongs to, if any.
        person_name: Name of that person, if any.
        person_color: Color of that person, if any.
        cluster_uuid: Unknown cluster the sample belongs to, if any.
        cluster_label: Label of that cluster, if any.
        event_uuid: Face event of the sample, if any.
        camera_uuid: Camera that saw the face, if any.
        camera_name: Name of that camera, if it still exists.
        view_name: Name of the camera view that saw the face, if any.
    """

    sample_uuid: UUID
    score: float
    source: SampleSource
    seen_at: datetime
    has_crop: bool
    person_uuid: UUID | None
    person_name: str | None
    person_color: str | None
    cluster_uuid: UUID | None
    cluster_label: str | None
    event_uuid: UUID | None
    camera_uuid: UUID | None
    camera_name: str | None
    view_name: str | None


class SimilarPage(BaseModel):
    """One page of similar faces.

    Attributes:
        items: Similar samples on the page, most similar first.
        total: Number of similar samples across all pages.
        page: One-based page number.
        page_size: Number of samples per page.
    """

    items: list[SimilarRead]
    total: int
    page: int
    page_size: int
