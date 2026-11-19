"""Pipeline profiles a view can select.

A profile states which stages run for a view. Every detecting profile shares the one detector engine and the
tracker; profiles differ in the labels they keep, whether rules run and whether the view is watched for tampering.
The identity profile reserves the face stage, which a later stage adds after the tracker.
"""

from __future__ import annotations

from dataclasses import dataclass

from app.rules.model import ANIMALS, VEHICLES

PEOPLE = frozenset({"person"})


@dataclass(frozen=True)
class Profile:
    """Stages one view runs.

    Attributes:
        name: Profile name used in configuration.
        detect: Runs the shared detector and the tracker.
        labels: Labels kept from the detector; other objects are dropped before the rules.
        rules: Evaluates zones, lines and rules.
        tamper: Watches the picture for covering, blur and scene changes by default.
        faces: Runs the face stage after the tracker once it exists.
    """

    name: str
    detect: bool
    labels: frozenset[str]
    rules: bool
    tamper: bool
    faces: bool = False


PROFILES: dict[str, Profile] = {
    "perimeter": Profile(
        name="perimeter",
        detect=True,
        labels=PEOPLE | ANIMALS | VEHICLES | frozenset({"bicycle"}),
        rules=True,
        tamper=True,
    ),
    "vehicle": Profile(
        name="vehicle",
        detect=True,
        labels=VEHICLES | frozenset({"bicycle"}),
        rules=True,
        tamper=True,
    ),
    "identity": Profile(
        name="identity",
        detect=True,
        labels=PEOPLE,
        rules=True,
        tamper=False,
        faces=True,
    ),
    "tamper": Profile(
        name="tamper",
        detect=False,
        labels=frozenset(),
        rules=False,
        tamper=True,
    ),
}
