from enum import StrEnum


class WallMaterial(StrEnum):
    DRYWALL = "drywall"
    WOOD = "wood"
    GLASS = "glass"
    BRICK = "brick"
    THICK_BRICK = "thick_brick"
    CONCRETE = "concrete"
    REINFORCED_CONCRETE = "reinforced_concrete"
    METAL = "metal"


class AccessPointPreset(StrEnum):
    ARCHER_C64 = "archer_c64"
    ARCHER_C54 = "archer_c54"
    REYEE_EW300N = "reyee_ew300n"
    GENERIC = "generic"


class Band(StrEnum):
    BAND_24 = "2.4"
    BAND_5 = "5"
