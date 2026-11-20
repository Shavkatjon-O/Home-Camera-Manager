"""Enumerations of the camera registry module."""

from enum import StrEnum


class CameraBrand(StrEnum):
    """Camera brands the registry knows, each with its own defaults and stream setup."""

    EZVIZ = "ezviz"
    V380 = "v380"
    ONVIF = "onvif"
    RTSP = "rtsp"


class CameraSort(StrEnum):
    """Orders in which the camera list can be returned."""

    CREATED = "created"
    POSITION = "position"
