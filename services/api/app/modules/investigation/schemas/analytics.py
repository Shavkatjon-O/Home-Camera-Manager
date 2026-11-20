"""Schemas of the answer of the analytics enrollment endpoint."""

from typing import Annotated

from pydantic import BaseModel, BeforeValidator, ConfigDict, Field

from app.modules.investigation.crops import decode_crop
from app.modules.investigation.embeddings import decode_embedding

__all__ = ["DetectedFace", "Embedding", "EmbedResponse", "JpegCrop"]

Embedding = Annotated[bytes, BeforeValidator(decode_embedding)]
JpegCrop = Annotated[bytes, BeforeValidator(decode_crop)]


class DetectedFace(BaseModel):
    """Face the analytics service found in a photo.

    Attributes:
        box: Face box as left, top, right and bottom in pixels.
        score: Detection score from 0 to 1.
        landmarks: Eye, nose and mouth corner points in pixels.
        size: Size of the face box in pixels.
        quality: Quality score of the face from 0 to 1.
        frontal: How frontal the face is from 0 to 1, if known.
        sharpness: How sharp the face is from 0 to 1, if known.
        embedding: Raw bytes of the normalised embedding.
        crop: JPEG bytes of the 160 by 160 face crop.
    """

    model_config = ConfigDict(extra="ignore", allow_inf_nan=False)

    box: list[float] = Field(min_length=4, max_length=4)
    score: float
    landmarks: list[list[float]] = Field(default_factory=list)
    size: float
    quality: float
    frontal: float | None = None
    sharpness: float | None = None
    embedding: Embedding
    crop: JpegCrop


class EmbedResponse(BaseModel):
    """Answer of the analytics enrollment endpoint.

    Attributes:
        width: Width of the photo in pixels.
        height: Height of the photo in pixels.
        faces: Faces found, largest first.
    """

    model_config = ConfigDict(extra="ignore")

    width: int
    height: int
    faces: list[DetectedFace]
