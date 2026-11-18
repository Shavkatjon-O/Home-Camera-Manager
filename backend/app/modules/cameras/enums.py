from enum import StrEnum


class CameraBrand(StrEnum):
    EZVIZ = "ezviz"
    V380 = "v380"
    ONVIF = "onvif"
    RTSP = "rtsp"


class CameraSort(StrEnum):
    CREATED = "created"
    POSITION = "position"
