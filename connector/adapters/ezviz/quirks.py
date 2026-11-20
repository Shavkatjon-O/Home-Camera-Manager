"""Quirks of EZVIZ cameras that the ONVIF code allows for."""

from adapters.onvif import media

__all__ = ["ENCODER_SERVICES", "SENSITIVITY_MAX", "SENSITIVITY_MIN", "corrected_sensitivity"]

ENCODER_SERVICES = (media.MEDIA2, media.MEDIA1)
SENSITIVITY_MIN = 0
SENSITIVITY_MAX = 100


def corrected_sensitivity(written: int, read_back: int | None) -> int | None:
    """Compensate a motion sensitivity the camera stores off by a fixed step.

    EZVIZ cameras read back one step higher than was written, so writing the value minus the difference once lands
    on the wanted value. Media1 reports their encoding as H264 in its element while they stream H.265, so encoder
    settings are read through Media2 first, as ENCODER_SERVICES orders them.

    Args:
        written: Sensitivity that was written.
        read_back: Sensitivity the camera reports afterwards.

    Returns:
        The value to write once more, or None when the camera already stores the wanted value or the correction
        would leave the range.
    """
    if read_back is None or read_back == written:
        return None
    corrected = written - (read_back - written)
    if SENSITIVITY_MIN <= corrected <= SENSITIVITY_MAX:
        return corrected
    return None
