"""Per-brand default settings applied when a camera is created."""

from app.core.exceptions import Unprocessable
from app.modules.cameras.enums import CameraBrand

__all__ = ["BRAND_DEFAULTS", "DEFAULT_RTSP_PORT", "apply_brand_defaults"]

DEFAULT_RTSP_PORT = 554

BRAND_DEFAULTS: dict[CameraBrand, dict[str, object]] = {
    CameraBrand.EZVIZ: {
        "onvif_port": 80,
        "username": "admin",
        "main_path": "/Streaming/Channels/101",
        "sub_path": "/Streaming/Channels/102",
        "ptz_enabled": False,
    },
    CameraBrand.V380: {
        "onvif_port": 8899,
        "main_path": "/live/ch00_0",
        "sub_path": "/live/ch00_1",
        "ptz_enabled": True,
    },
    CameraBrand.ONVIF: {
        "onvif_port": 80,
    },
    CameraBrand.RTSP: {
        "ptz_enabled": False,
    },
}


def apply_brand_defaults(brand: CameraBrand, values: dict) -> dict:
    """Fill the fields a request left unset with the defaults of its brand.

    Args:
        brand: Brand of the camera.
        values: Camera fields from the request; unset ones are None.

    Returns:
        Copy of the values with brand defaults in place of None.

    Raises:
        Unprocessable: The brand is plain RTSP and no main stream path is given.
    """
    result = dict(values)
    for key, value in BRAND_DEFAULTS[brand].items():
        if result.get(key) is None:
            result[key] = value
    if brand == CameraBrand.RTSP and not result.get("main_path"):
        raise Unprocessable("main_path_required", "A main stream path is required for a plain RTSP camera")
    return result
