"""Tolerant parser of the label QR codes of EZVIZ and Hik-Connect devices.

The format is guessed from public descriptions: the label carries the serial number, a six-letter verification
code and often the model, separated by line breaks or other separators, sometimes as parameters of a link. No real
label was checked, so the parser accepts the parts in any order and needs the serial with the code, the model or
the vendor's name.
"""

import re
from urllib.parse import parse_qs, urlsplit

from camera_adapters.base import AdapterName, LabelInfo

__all__ = ["parse_ezviz_label"]

MODEL = re.compile(r"^CS-[A-Z0-9][A-Z0-9-]{2,30}$", re.IGNORECASE)
SERIAL = re.compile(r"^[A-Z][A-Z0-9]{7,9}$")
CODE = re.compile(r"^[A-Z]{6}$")
SEPARATORS = re.compile(r"[\r\n\t;,| ]+")
SERIAL_KEYS = ("serial", "sn", "deviceserial", "subserial")
CODE_KEYS = ("code", "verifycode", "validatecode", "safecode")
MODEL_KEYS = ("model", "devicemodel")
HINTS = ("ezviz", "ys7", "hik")


def query_values(text: str) -> dict[str, str]:
    """Read the parameters of a link, if the text is one.

    Args:
        text: The text.

    Returns:
        Lower-case parameter names to their first value.
    """
    parts = urlsplit(text)
    if not parts.scheme or not parts.query:
        return {}
    return {key.lower(): values[0] for key, values in parse_qs(parts.query).items() if values}


def parse_ezviz_label(text: str) -> LabelInfo | None:
    """Read an EZVIZ label.

    Args:
        text: Decoded QR text.

    Returns:
        Serial, verification code and model, or None when the text does not look like an EZVIZ label.
    """
    raw = text.strip()
    if not raw or raw.lower().startswith(("rtsp://", "wifi:")):
        return None
    params = query_values(raw)
    serial = next((params[key].upper() for key in SERIAL_KEYS if key in params), None)
    code = next((params[key] for key in CODE_KEYS if key in params), None)
    model = next((params[key].upper() for key in MODEL_KEYS if key in params), None)
    hinted = any(hint in raw.lower() for hint in HINTS)
    for token in SEPARATORS.split(raw):
        token = token.strip()
        if not token or "://" in token:
            continue
        if model is None and MODEL.match(token):
            model = token.upper()
        elif code is None and CODE.match(token):
            code = token
        elif serial is None and SERIAL.match(token.upper()) and any(character.isdigit() for character in token):
            serial = token.upper()
    if serial is None or (code is None and model is None and not hinted):
        return None
    return LabelInfo(
        adapter=AdapterName.EZVIZ.value,
        format="ezviz_serial_code",
        confirmed=False,
        vendor="EZVIZ",
        model=model,
        serial=serial,
        code=code,
    )
