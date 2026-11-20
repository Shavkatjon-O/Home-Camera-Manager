"""Enumerations and fixed values of the people module."""

from enum import StrEnum


class SampleSource(StrEnum):
    """Where a face sample came from."""

    UPLOAD = "upload"
    EVENT = "event"


class FaceStatus(StrEnum):
    """Whether the analytics service recognised the face of a track as a known person."""

    KNOWN = "known"
    UNKNOWN = "unknown"


class FaceAction(StrEnum):
    """Whether a face result opens a face event or changes one sent before."""

    OPEN = "open"
    UPDATE = "update"


FACE_KNOWN = "face_known"
FACE_UNKNOWN = "face_unknown"
FACE_KINDS = (FACE_KNOWN, FACE_UNKNOWN)

FACE_SOURCE_TOPIC = "analytics/faces"

PERSON_COLORS = (
    "#4f8cff",
    "#45c25f",
    "#f0a92e",
    "#f2555a",
    "#b07cff",
    "#2ec4c4",
    "#ff7ab8",
    "#c2a35a",
)
