"""Schemas of people, their photo uploads and their merging."""

from datetime import datetime
from typing import Annotated
from uuid import UUID

from pydantic import AfterValidator, BaseModel, ConfigDict, Field, StringConstraints, field_validator, model_validator

from .samples import SampleRead, SightingRead

__all__ = [
    "Color",
    "PersonCreate",
    "PersonList",
    "PersonMerge",
    "PersonName",
    "PersonRead",
    "PersonUpdate",
    "PhotoRejection",
    "PhotoUpload",
    "PhotoUploadRequest",
    "PhotoUploadResult",
    "clean_notes",
]

NAME_MAX = 80
NOTES_MAX = 2000
COLOR_PATTERN = r"^#[0-9a-fA-F]{6}$"

PHOTOS_MAX = 10
PHOTO_NAME_MAX = 255
PHOTO_DATA_MAX_CHARS = 16 * 1024 * 1024 + 64

REQUIRED_ON_UPDATE = ("name", "color")

PersonName = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=NAME_MAX)]
Color = Annotated[str, StringConstraints(strip_whitespace=True, pattern=COLOR_PATTERN), AfterValidator(str.lower)]


def clean_notes(value: str | None) -> str | None:
    """Strip notes and turn blank notes into none.

    Args:
        value: Notes as sent, if any.

    Returns:
        The stripped notes, or None when they are missing or blank.
    """
    if value is None:
        return None
    stripped = value.strip()
    return stripped or None


class Strict(BaseModel):
    """Base model that rejects unknown fields and non-finite numbers."""

    model_config = ConfigDict(extra="forbid", allow_inf_nan=False)


class PersonCreate(Strict):
    """Request body that creates a person.

    Attributes:
        name: Name of the person.
        notes: Free notes, if any.
        color: Color as #rrggbb; the next palette color is chosen when it is left out.
    """

    name: PersonName
    notes: str | None = Field(default=None, max_length=NOTES_MAX)
    color: Color | None = None

    @field_validator("notes")
    @classmethod
    def strip_notes(cls, value: str | None) -> str | None:
        """Strip the notes.

        Args:
            value: Notes as sent, if any.

        Returns:
            The stripped notes, or None when blank.
        """
        return clean_notes(value)


class PersonUpdate(Strict):
    """Request body that changes some fields of a person.

    Fields that are left out are kept; notes sent as null are removed.

    Attributes:
        name: New name.
        notes: New notes.
        color: New color as #rrggbb.
    """

    name: PersonName | None = None
    notes: str | None = Field(default=None, max_length=NOTES_MAX)
    color: Color | None = None

    @field_validator("notes")
    @classmethod
    def strip_notes(cls, value: str | None) -> str | None:
        """Strip the notes.

        Args:
            value: Notes as sent, if any.

        Returns:
            The stripped notes, or None when blank.
        """
        return clean_notes(value)

    @model_validator(mode="after")
    def reject_null_required(self):
        """Reject an explicit null for the name or the color.

        Returns:
            The validated update.

        Raises:
            ValueError: When the name or the color was sent as null.
        """
        for field in REQUIRED_ON_UPDATE:
            if field in self.model_fields_set and getattr(self, field) is None:
                raise ValueError(f"{field} cannot be empty")
        return self


class PersonRead(BaseModel):
    """Person with sample counts, the newest samples and the latest sightings.

    Attributes:
        uuid: Public id of the person.
        name: Name of the person.
        notes: Free notes, if any.
        color: Color as #rrggbb.
        sample_count: Number of face samples of the person.
        upload_count: Number of those samples that were uploaded.
        samples: Newest samples, 6 in lists and 24 for one person.
        last_seen_at: When a camera last saw the person, if ever.
        sightings: The 5 latest times a camera saw the person.
        created_at: When the person was created.
        updated_at: When the person last changed.
    """

    uuid: UUID
    name: str
    notes: str | None
    color: str
    sample_count: int
    upload_count: int
    samples: list[SampleRead]
    last_seen_at: datetime | None
    sightings: list[SightingRead]
    created_at: datetime
    updated_at: datetime


class PersonList(BaseModel):
    """One page of people.

    Attributes:
        items: People on the page.
        total: Number of people across all pages.
        page: One-based page number.
        page_size: Number of people per page.
    """

    items: list[PersonRead]
    total: int
    page: int
    page_size: int


class PersonMerge(Strict):
    """Request body that merges one person into another.

    Attributes:
        into: Public id of the person that receives the samples and face events.
    """

    into: UUID


class PhotoUpload(Strict):
    """One photo to enroll.

    Attributes:
        name: File name, used to report a rejection.
        data: The image as a base64 data URL of type image/jpeg, image/png or image/webp.
    """

    name: str = Field(default="", max_length=PHOTO_NAME_MAX)
    data: str = Field(min_length=1, max_length=PHOTO_DATA_MAX_CHARS)


class PhotoUploadRequest(Strict):
    """Request body that enrolls photos of a person.

    Attributes:
        photos: Photos to enroll, each holding one face.
    """

    photos: list[PhotoUpload] = Field(min_length=1, max_length=PHOTOS_MAX)


class PhotoRejection(BaseModel):
    """Photo that could not be enrolled.

    Attributes:
        name: File name of the photo.
        reason: Why the photo was not used.
    """

    name: str
    reason: str


class PhotoUploadResult(BaseModel):
    """Outcome of a photo upload.

    Attributes:
        person: The person after the upload.
        added: Samples created from the accepted photos.
        rejected: Photos that were not used, with the reason.
    """

    person: PersonRead
    added: list[SampleRead]
    rejected: list[PhotoRejection]
