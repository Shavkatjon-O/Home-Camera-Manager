"""Rules for photos of a face: reading a data URL and choosing the one face it must hold."""

import base64
import binascii

from app.modules.people.schemas import DetectedFace

PHOTO_TYPES = ("image/jpeg", "image/png", "image/webp")
PHOTO_MAX_BYTES = 12 * 1024 * 1024

FACE_SCORE_MIN = 0.5
FACE_SIZE_MIN = 64.0

UNREADABLE = "The photo could not be read"
NO_FACE = "No face found"
SMALL_FACE = "The face is too small; use a closer photo"


class PhotoRejected(Exception):
    """A photo cannot be used as a face of one person.

    Attributes:
        reason: Why the photo was not used, worded for the user.
    """

    def __init__(self, reason: str):
        """Create the rejection.

        Args:
            reason: Why the photo was not used, worded for the user.
        """
        super().__init__(reason)
        self.reason = reason


def many_faces(count: int) -> str:
    """Word the rejection of a photo with several faces.

    Args:
        count: Number of faces found.

    Returns:
        The reason shown to the user.
    """
    return f"{count} faces found; use a photo of one person"


def decode_photo(data: str) -> tuple[bytes, str]:
    """Read the image of a base64 data URL.

    Args:
        data: Data URL of type image/jpeg, image/png or image/webp.

    Returns:
        The image bytes and their content type.

    Raises:
        PhotoRejected: When the value is not such a data URL, is empty or is over 12 MB.
    """
    header, comma, body = data.partition(",")
    if not comma or not header.startswith("data:") or not header.endswith(";base64"):
        raise PhotoRejected(UNREADABLE)
    content_type = header[len("data:") : -len(";base64")].strip().lower()
    if content_type not in PHOTO_TYPES:
        raise PhotoRejected(UNREADABLE)
    try:
        content = base64.b64decode(body.strip(), validate=True)
    except (binascii.Error, ValueError):
        raise PhotoRejected(UNREADABLE)
    if not content or len(content) > PHOTO_MAX_BYTES:
        raise PhotoRejected(UNREADABLE)
    return content, content_type


def choose_face(faces: list[DetectedFace]) -> DetectedFace:
    """Pick the face of a photo, which must hold exactly one face large enough to recognise.

    Args:
        faces: Faces the analytics service found.

    Returns:
        The one face.

    Raises:
        PhotoRejected: When the photo holds no face, several faces or a face under 64 pixels.
    """
    found = [face for face in faces if face.score >= FACE_SCORE_MIN]
    if not found:
        raise PhotoRejected(NO_FACE)
    if len(found) > 1:
        raise PhotoRejected(many_faces(len(found)))
    face = found[0]
    if face.size < FACE_SIZE_MIN:
        raise PhotoRejected(SMALL_FACE)
    return face
