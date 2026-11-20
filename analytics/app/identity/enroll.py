"""Embedding of uploaded photos for enrollment and face searches.

The backend has no GPU model, so it sends each photo here. The photo is turned upright from its orientation tag,
every face in it is detected, aligned, judged and embedded, and the answer lists them largest first with a display
crop, so the backend can insist on exactly one face and say why a photo was refused.
"""

from __future__ import annotations

import base64
import io

import numpy as np

from app.identity import align, quality
from app.identity.align import ALIGNED_SIZE, CROP_SIZE
from app.identity.gallery import encode_vector
from app.identity.models import FaceModels
from app.identity.settings import IdentitySettings

MAX_BYTES = 12 * 1024 * 1024
MAX_SIDE = 4096
REPORT_SCORE = 0.5
SHRINK_ABOVE = 2.0
JPEG_QUALITY = 90


class PhotoError(ValueError):
    """The photo cannot be read."""


def decode_photo(data: bytes) -> np.ndarray:
    """Decode a photo into upright RGB pixels.

    Args:
        data: JPEG, PNG or WebP bytes.

    Returns:
        Pixels, height by width by 3, uint8, at most MAX_SIDE on the longer side.

    Raises:
        PhotoError: If the bytes are empty, too large or not a readable picture.
    """
    from PIL import Image, ImageOps, UnidentifiedImageError

    if not data:
        raise PhotoError("The photo is empty")
    if len(data) > MAX_BYTES:
        raise PhotoError("The photo is larger than 12 MB")
    try:
        with Image.open(io.BytesIO(data)) as image:
            image = ImageOps.exif_transpose(image).convert("RGB")
            if max(image.size) > MAX_SIDE:
                image.thumbnail((MAX_SIDE, MAX_SIDE), Image.Resampling.LANCZOS)
            return np.asarray(image, dtype=np.uint8).copy()
    except (UnidentifiedImageError, OSError, ValueError) as exc:
        raise PhotoError(f"The photo could not be read: {exc}") from None


def shrink(image: np.ndarray, factor: float) -> np.ndarray:
    """Downscale a picture with antialiasing.

    Args:
        image: Pixels, height by width by 3.
        factor: Output pixels per input pixel, below 1.

    Returns:
        The smaller picture.
    """
    from PIL import Image

    height, width = image.shape[:2]
    size = (max(1, round(width * factor)), max(1, round(height * factor)))
    return np.asarray(Image.fromarray(image).resize(size, Image.Resampling.LANCZOS), dtype=np.uint8)


def jpeg(pixels: np.ndarray) -> str:
    """Encode RGB pixels as a base64 JPEG.

    Args:
        pixels: Pixels, height by width by 3.

    Returns:
        Base64 JPEG bytes.
    """
    from PIL import Image

    buffer = io.BytesIO()
    Image.fromarray(pixels).save(buffer, format="JPEG", quality=JPEG_QUALITY)
    return base64.b64encode(buffer.getvalue()).decode()


def embed_photo(data: bytes, models: FaceModels, settings: IdentitySettings) -> dict:
    """Find and embed every face in a photo.

    A large face is first scaled down with antialiasing to about twice the aligned size, because resampling a big
    face straight to 112 pixels aliases its detail away.

    Args:
        data: Photo bytes.
        models: The face models.
        settings: Face settings.

    Returns:
        The photo's size and its faces with box, score, landmarks, size, quality signals, embedding and crop.

    Raises:
        PhotoError: If the photo cannot be read.
    """
    image = decode_photo(data)
    height, width = image.shape[:2]
    found = sorted(models.detect(image, REPORT_SCORE), key=lambda face: face.height, reverse=True)
    faces, aligned = [], []
    for face in found:
        factor = min(1.0, SHRINK_ABOVE * ALIGNED_SIZE / max(face.height, 1.0))
        source = shrink(image, factor) if factor < 1.0 else image
        landmarks = face.landmarks * factor
        box = tuple(value * factor for value in face.box)
        aligned_face = align.align(source, landmarks)
        crop = align.crop(source, box, CROP_SIZE)
        signals = quality.assess(face.height, face.landmarks, aligned_face, face.score, settings.min_face)
        aligned.append(aligned_face)
        faces.append(
            {
                "box": [round(value, 1) for value in face.box],
                "score": round(face.score, 4),
                "landmarks": [[round(float(x), 1), round(float(y), 1)] for x, y in face.landmarks],
                "size": round(face.height, 1),
                "quality": round(signals.value, 4),
                "frontal": round(signals.frontal, 3),
                "sharpness": round(signals.sharpness, 3),
                "crop": jpeg(crop),
            }
        )
    for item, embedding in zip(faces, models.embed(aligned)):
        item["embedding"] = encode_vector(embedding)
    return {"width": width, "height": height, "faces": faces}


def answer(data: bytes, models: FaceModels, settings: IdentitySettings) -> tuple[int, dict]:
    """Answer one enrollment request.

    Args:
        data: Photo bytes from the request body.
        models: The face models.
        settings: Face settings.

    Returns:
        The HTTP status and the JSON body: 200 with the faces, 400 for an unreadable photo, 503 when the face
        models cannot be loaded.
    """
    try:
        models.load()
    except Exception as exc:
        return 503, {"detail": f"The face models are not loaded: {exc}"}
    try:
        return 200, embed_photo(data, models, settings)
    except PhotoError as exc:
        return 400, {"detail": str(exc)}
