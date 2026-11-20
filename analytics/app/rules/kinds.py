"""Event kinds added after the first rules engine: objects left and taken, falls and animals.

They complete app.rules.model.EventKind. An Event carrying one of them works everywhere an event goes, because the
event's plain form uses the kind's value.
"""

from __future__ import annotations

from enum import StrEnum


class ExtraKind(StrEnum):
    """Kinds of events the newer analytics stages produce."""

    OBJECT_LEFT = "object_left"
    OBJECT_TAKEN = "object_taken"
    FALL = "fall"
    ANIMAL = "animal"
