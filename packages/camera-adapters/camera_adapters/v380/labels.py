"""Tolerant parser of the label QR codes of V380 cameras.

The format is guessed from public descriptions: the label carries the camera's numeric device id, alone or as a
parameter of a link of the V380 cloud. No real label was checked, so the parser accepts an id of 8 to 10 digits
alone, one named by an id or device parameter of a link that names V380, or one inside a text that names V380.
"""

import re
from urllib.parse import parse_qs, urlsplit

from camera_adapters.base import AdapterName, LabelInfo

__all__ = ["parse_v380_label"]

DEVICE_ID = re.compile(r"^[0-9]{8,10}$")
EMBEDDED_ID = re.compile(r"(?<![0-9])([0-9]{8,10})(?![0-9])")
ID_KEYS = ("id", "deviceid", "devid", "uid")
HINTS = ("v380", "av380", "macro-video", "macrovideo")


def parse_v380_label(text: str) -> LabelInfo | None:
    """Read a V380 label.

    Args:
        text: Decoded QR text.

    Returns:
        The device id, or None when the text does not look like a V380 label.
    """
    raw = text.strip()
    if not raw:
        return None
    hinted = any(hint in raw.lower() for hint in HINTS)
    device_id = None
    parts = urlsplit(raw)
    if parts.scheme and parts.query:
        if not hinted:
            return None
        params = {key.lower(): values[0] for key, values in parse_qs(parts.query).items() if values}
        device_id = next((params[key] for key in ID_KEYS if key in params and DEVICE_ID.match(params[key])), None)
    if device_id is None and DEVICE_ID.match(raw):
        device_id = raw
    if device_id is None and hinted:
        found = EMBEDDED_ID.search(raw)
        device_id = found.group(1) if found else None
    if device_id is None:
        return None
    return LabelInfo(
        adapter=AdapterName.V380.value,
        format="v380_device_id",
        confirmed=False,
        vendor="Macro-Video V380",
        device_id=device_id,
    )
