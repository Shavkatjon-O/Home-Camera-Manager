"""Schemas of the internal endpoints the analytics service calls."""

from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

from app.modules.people.crops import is_relative_inside
from app.modules.people.enums import FaceAction, FaceStatus

from .analytics import Embedding

__all__ = ["FaceCandidate", "FaceResult", "FaceResultAck", "Gallery", "GalleryCluster", "GalleryPerson"]

VIEW_MAX = 120
RELATED_EVENT_MAX = 64
CROP_PATH_MAX = 255


class GalleryPerson(BaseModel):
    """Known person in the gallery the analytics service matches faces against.

    Attributes:
        uuid: Public id of the person.
        name: Name of the person.
        embeddings: Base64 embeddings of the person's best samples.
    """

    uuid: UUID
    name: str
    embeddings: list[str]


class GalleryCluster(BaseModel):
    """Unknown cluster in the gallery.

    Attributes:
        uuid: Public id of the cluster.
        number: Number of the cluster.
        centroid: Base64 embedding of the cluster's normalised mean.
        count: Number of samples the centroid averages.
    """

    uuid: UUID
    number: int
    centroid: str
    count: int


class Gallery(BaseModel):
    """Everything the analytics service needs to recognise faces.

    Attributes:
        version: Digest of the gallery that changes whenever its content changes.
        people: Live people with at least one sample.
        clusters: Live unknown clusters with a centroid.
    """

    version: str
    people: list[GalleryPerson]
    clusters: list[GalleryCluster]


class FaceCandidate(BaseModel):
    """Closest known person of a face that was not recognised with enough confidence.

    Attributes:
        person: Public id of the person.
        score: Similarity to the person from -1 to 1.
    """

    model_config = ConfigDict(extra="ignore", allow_inf_nan=False)

    person: UUID
    score: float


class FaceResult(BaseModel):
    """Decision of the analytics service about who a person track is.

    Attributes:
        id: Id of the face event, chosen by the analytics service.
        action: Whether this opens the face event or changes it.
        camera: Public id of the camera.
        view: Id of the camera view, if any.
        view_name: Name of the camera view, if any.
        track: Tracker id of the person track, if any.
        related_event: Analytics event id of the same track, if any.
        started_at: When the track started, in Unix seconds.
        seen_at: When the face was seen, in Unix seconds.
        status: Whether the face is a known person or unknown.
        person: Public id of the person when known.
        cluster: Public id of the unknown cluster when unknown.
        cluster_new: Whether the analytics service started a new cluster for the face.
        confidence: Recognition confidence, if any.
        candidate: Closest known person when the face stayed unknown, if any.
        embedding: Raw bytes of the track's averaged normalised embedding.
        quality: Quality score of the face from 0 to 1.
        faces: Number of faces averaged into the embedding.
        crop: Crop path relative to the events folder, if a crop was written.
        box: Face box in the frame as fractions of its width and height.
        alert: Whether the face event should alert.
    """

    model_config = ConfigDict(extra="ignore", allow_inf_nan=False)

    id: UUID
    action: FaceAction
    camera: UUID
    view: str | None = Field(default=None, max_length=VIEW_MAX)
    view_name: str | None = Field(default=None, max_length=VIEW_MAX)
    track: int | None = None
    related_event: str | None = Field(default=None, max_length=RELATED_EVENT_MAX)
    started_at: float = Field(gt=0)
    seen_at: float = Field(gt=0)
    status: FaceStatus
    person: UUID | None = None
    cluster: UUID | None = None
    cluster_new: bool = False
    confidence: float | None = None
    candidate: FaceCandidate | None = None
    embedding: Embedding
    quality: float
    faces: int = Field(default=1, ge=0)
    crop: str | None = Field(default=None, max_length=CROP_PATH_MAX)
    box: list[float] | None = Field(default=None, min_length=4, max_length=4)
    alert: bool = False

    @field_validator("crop")
    @classmethod
    def check_crop(cls, value: str | None) -> str | None:
        """Reject a crop path that is absolute or climbs out of the events folder.

        Args:
            value: Crop path as sent, if any.

        Returns:
            The path, or None when it is empty.

        Raises:
            ValueError: When the path is absolute or has parent or empty parts.
        """
        if not value:
            return None
        if not is_relative_inside(value):
            raise ValueError("the crop must be a path inside the events folder")
        return value

    @model_validator(mode="after")
    def owner_given(self):
        """Require the person of a known face and the cluster of an unknown one.

        Returns:
            The validated result.

        Raises:
            ValueError: When a known face has no person, or an unknown face has neither a cluster nor cluster_new.
        """
        if self.status == FaceStatus.KNOWN and self.person is None:
            raise ValueError("a known face needs its person")
        if self.status == FaceStatus.UNKNOWN and self.cluster is None and not self.cluster_new:
            raise ValueError("an unknown face needs its cluster or cluster_new")
        return self


class FaceResultAck(BaseModel):
    """Answer to a stored face result.

    Attributes:
        event: Public id of the face event.
        sample: Public id of the face sample stored for it.
        cluster_number: Number of the unknown cluster, or None for a known face.
    """

    event: UUID
    sample: UUID
    cluster_number: int | None
