"""Animal labels and the policy that decides what animals do in a zone or on a line.

Dogs, cats and birds produce animal events instead of intrusions. A zone or line chooses whether animals produce
events that may alert, events that never alert, or no events at all. By default they are recorded and never alert,
in every arm mode, so a cat crossing the yard at night no longer wakes the owner.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum

ANIMALS = frozenset({"dog", "cat", "bird"})


class AnimalMode(StrEnum):
    """What animals do in a zone or on a line."""

    INCLUDE = "include"
    RECORD = "record"
    EXCLUDE = "exclude"


def is_animal(label: str) -> bool:
    """Tell whether a label is an animal.

    Args:
        label: Canonical label such as cat.

    Returns:
        True for dog, cat and bird.
    """
    return label in ANIMALS


@dataclass(frozen=True)
class AnimalPolicy:
    """What animals do in one zone or on one line.

    Attributes:
        mode: include lets animals produce events that may alert, record produces events that never alert, and
            exclude produces no events for animals at all.
    """

    mode: AnimalMode = AnimalMode.RECORD

    @classmethod
    def from_dict(cls, data: dict | None) -> AnimalPolicy:
        """Build the policy from a zone or line configuration.

        Args:
            data: The zone or line mapping; its animals key holds include, record or exclude.

        Returns:
            The policy, record when the key is missing or empty.

        Raises:
            ValueError: If the animals value is not one of the three modes.
        """
        value = (data or {}).get("animals") or AnimalMode.RECORD
        return cls(mode=AnimalMode(value))

    def produces(self, label: str) -> bool:
        """Tell whether an object of a label produces events.

        Args:
            label: Canonical label.

        Returns:
            False only for animals when animals are excluded.
        """
        return not (is_animal(label) and self.mode == AnimalMode.EXCLUDE)

    def may_alert(self, label: str) -> bool:
        """Tell whether an event of a label may raise an alert, before the arm mode and alert policy decide.

        Args:
            label: Canonical label.

        Returns:
            False for animals unless they are included; True for every other label.
        """
        return not is_animal(label) or self.mode == AnimalMode.INCLUDE
