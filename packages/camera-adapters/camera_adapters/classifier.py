"""Adapter and ONVIF port guesses for hosts found by a scan."""

from collections.abc import Iterable

from adapters.base import AdapterName

V380_MANUFACTURER = "macro-video"

V380_PORT = 8800
EZVIZ_PORT = 8000
RTSP_PORT = 554

BRAND_ONVIF_PORTS = {
    AdapterName.V380: 8899,
    AdapterName.EZVIZ: 80,
}


def guess_brand(open_ports: Iterable[int], manufacturer: str | None, onvif_port: int | None) -> AdapterName | None:
    """Guess the camera brand from open ports and what the host reported over ONVIF.

    V380 is recognised by its manufacturer name or its own port, EZVIZ by its own port, and any other
    host that answered over ONVIF is an ONVIF camera. A host with only RTSP open is a plain RTSP camera.

    Args:
        open_ports: Ports of the host that accepted a connection.
        manufacturer: Manufacturer the host reported over ONVIF, if any.
        onvif_port: ONVIF port that answered, if any.

    Returns:
        The guessed brand, or None when nothing points to a camera.
    """
    ports = set(open_ports)
    if (manufacturer and V380_MANUFACTURER in manufacturer.lower()) or V380_PORT in ports:
        return AdapterName.V380
    if EZVIZ_PORT in ports:
        return AdapterName.EZVIZ
    if onvif_port is not None:
        return AdapterName.ONVIF
    if RTSP_PORT in ports:
        return AdapterName.RTSP
    return None


def guess_onvif_port(brand: AdapterName | None, open_ports: Iterable[int], onvif_port: int | None) -> int | None:
    """Pick the ONVIF port of a host.

    Args:
        brand: Guessed brand of the host, if any.
        open_ports: Ports of the host that accepted a connection.
        onvif_port: ONVIF port that answered, if any.

    Returns:
        The port that answered, else the brand's usual ONVIF port when it is open, else None.
    """
    if onvif_port is not None:
        return onvif_port
    default = BRAND_ONVIF_PORTS.get(brand) if brand is not None else None
    if default is not None and default in set(open_ports):
        return default
    return None
