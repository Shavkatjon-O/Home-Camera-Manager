"""Enumerations of the floor plan module."""

from enum import StrEnum


class WallMaterial(StrEnum):
    """Materials a wall can be made of, which set how much it weakens the signal."""

    DRYWALL = "drywall"
    WOOD = "wood"
    GLASS = "glass"
    BRICK = "brick"
    THICK_BRICK = "thick_brick"
    CONCRETE = "concrete"
    REINFORCED_CONCRETE = "reinforced_concrete"
    METAL = "metal"


class AccessPointPreset(StrEnum):
    """Router models a plan can place, or a generic router."""

    ARCHER_C64 = "archer_c64"
    ARCHER_C54 = "archer_c54"
    REYEE_EW300N = "reyee_ew300n"
    GENERIC = "generic"


class Band(StrEnum):
    """Wi-Fi frequency bands, valued by their frequency in GHz."""

    BAND_24 = "2.4"
    BAND_5 = "5"
