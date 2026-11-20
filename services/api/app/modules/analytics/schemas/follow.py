"""Schemas of the PTZ commands the analytics service's follow controller sends."""

from typing import Literal

from pydantic import BaseModel, Field

__all__ = ["PtzHomeIn", "PtzMoveIn"]


class PtzMoveIn(BaseModel):
    """A continuous move.

    Attributes:
        pan: Pan speed from -1 to 1, positive to the right.
        tilt: Tilt speed from -1 to 1, positive upwards.
    """

    pan: float = Field(ge=-1, le=1)
    tilt: float = Field(ge=-1, le=1)


class PtzHomeIn(BaseModel):
    """Save or return to the position follow started from.

    Attributes:
        action: save stores the current position, return goes back to it.
    """

    action: Literal["save", "return"]
