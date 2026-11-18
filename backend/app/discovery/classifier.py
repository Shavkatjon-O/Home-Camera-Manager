from collections.abc import Iterable

from app.modules.cameras.enums import CameraBrand

V380_MANUFACTURER = "macro-video"

V380_PORT = 8800
EZVIZ_PORT = 8000
RTSP_PORT = 554

BRAND_ONVIF_PORTS = {
    CameraBrand.V380: 8899,
    CameraBrand.EZVIZ: 80,
}


def guess_brand(open_ports: Iterable[int], manufacturer: str | None, onvif_port: int | None) -> CameraBrand | None:
    ports = set(open_ports)
    if (manufacturer and V380_MANUFACTURER in manufacturer.lower()) or V380_PORT in ports:
        return CameraBrand.V380
    if EZVIZ_PORT in ports:
        return CameraBrand.EZVIZ
    if onvif_port is not None:
        return CameraBrand.ONVIF
    if RTSP_PORT in ports:
        return CameraBrand.RTSP
    return None


def guess_onvif_port(brand: CameraBrand | None, open_ports: Iterable[int], onvif_port: int | None) -> int | None:
    if onvif_port is not None:
        return onvif_port
    default = BRAND_ONVIF_PORTS.get(brand) if brand is not None else None
    if default is not None and default in set(open_ports):
        return default
    return None
