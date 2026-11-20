"""The data catalog of camera and recorder models, which contributors extend in catalog/models.yaml."""

import os
import re
from dataclasses import dataclass, field
from functools import lru_cache
from pathlib import Path

import yaml

from camera_adapters.base import Fingerprint

__all__ = ["CATALOG_PATH", "CONFIDENCE", "Catalog", "Entry", "load_catalog", "render_path"]

CATALOG_PATH = Path(__file__).resolve().parents[1] / "catalog" / "models.yaml"
CONFIDENCE = ("tested", "documented", "guessed")


@dataclass(frozen=True)
class Entry:
    """One vendor or model family of the catalog.

    Attributes:
        id: Entry id.
        vendor: Vendor name.
        adapter: Adapter that reaches it.
        kind: camera, nvr or dvr.
        confidence: tested, documented or guessed.
        manufacturers: Lower-case parts of the ONVIF manufacturer that identify it.
        models: Patterns of its model names.
        ports: Ports only it opens.
        http_servers: Lower-case parts of its web server banner.
        oui: Hardware address prefixes of its vendor, as six hex digits.
        urls: Stream path templates by stream, with {channel} and {channel02} for the channel number.
        default_ports: Usual ports by service.
        quirks: Behaviour the adapter must allow for.
        pairing: Pairing methods it supports.
    """

    id: str
    vendor: str
    adapter: str
    kind: str = "camera"
    confidence: str = "guessed"
    manufacturers: tuple[str, ...] = ()
    models: tuple[str, ...] = ()
    ports: tuple[int, ...] = ()
    http_servers: tuple[str, ...] = ()
    oui: tuple[str, ...] = ()
    urls: dict[str, str] = field(default_factory=dict)
    default_ports: dict[str, int] = field(default_factory=dict)
    quirks: dict[str, object] = field(default_factory=dict)
    pairing: tuple[str, ...] = ()

    def score(self, fingerprint: Fingerprint) -> int:
        """Score how well a fingerprint fits the entry.

        A model pattern weighs most, then the manufacturer, the web banner, the hardware address prefix and the
        ports only this vendor opens. Ports alone count only when nothing contradicts them.

        Args:
            fingerprint: What is known about the address.

        Returns:
            0 when nothing fits, more the better it fits.
        """
        score = 0
        manufacturer = (fingerprint.manufacturer or "").lower()
        if manufacturer and any(part in manufacturer for part in self.manufacturers):
            score += 40
        if fingerprint.model and any(re.search(pattern, fingerprint.model, re.IGNORECASE) for pattern in self.models):
            score += 50
        banner = (fingerprint.http_server or "").lower()
        if banner and any(part in banner for part in self.http_servers):
            score += 20
        mac = (fingerprint.mac or "").replace(":", "").replace("-", "").upper()
        if mac and any(mac.startswith(prefix) for prefix in self.oui):
            score += 15
        if self.ports and set(self.ports).intersection(fingerprint.open_ports):
            score += 10
        return score

    def hints(self) -> dict:
        """Return what the adapters read from a matching entry.

        Returns:
            The entry's id, adapter, kind, quirks and stream path templates.
        """
        return {"id": self.id, "adapter": self.adapter, "kind": self.kind, "quirks": self.quirks, "urls": self.urls}


def render_path(template: str, channel: int) -> str:
    """Fill a stream path template for a channel.

    Args:
        template: Template with {channel} or {channel02}.
        channel: Channel number from 1.

    Returns:
        The path.
    """
    return template.replace("{channel02}", f"{channel:02d}").replace("{channel}", str(channel))


class Catalog:
    """The loaded catalog.

    Attributes:
        entries: Its entries in file order.
    """

    def __init__(self, entries: list[Entry]):
        """Create the catalog.

        Args:
            entries: Its entries.
        """
        self.entries = entries

    @classmethod
    def from_data(cls, data: dict) -> "Catalog":
        """Build a catalog from its YAML data.

        Args:
            data: The parsed file.

        Returns:
            The catalog.

        Raises:
            ValueError: An entry lacks an id, vendor or adapter, or has an unknown confidence.
        """
        entries = []
        for item in data.get("entries") or []:
            match = item.get("match") or {}
            if not item.get("id") or not item.get("vendor") or not item.get("adapter"):
                raise ValueError(f"Catalog entry {item!r} needs an id, a vendor and an adapter")
            confidence = item.get("confidence", "guessed")
            if confidence not in CONFIDENCE:
                raise ValueError(f"Catalog entry {item['id']} has the unknown confidence {confidence}")
            entries.append(
                Entry(
                    id=str(item["id"]),
                    vendor=str(item["vendor"]),
                    adapter=str(item["adapter"]),
                    kind=str(item.get("kind", "camera")),
                    confidence=confidence,
                    manufacturers=tuple(str(value).lower() for value in match.get("manufacturers") or []),
                    models=tuple(str(value) for value in match.get("models") or []),
                    ports=tuple(int(value) for value in match.get("ports") or []),
                    http_servers=tuple(str(value).lower() for value in match.get("http_servers") or []),
                    oui=tuple(str(value).replace(":", "").upper() for value in match.get("oui") or []),
                    urls={str(key): str(value) for key, value in (item.get("urls") or {}).items()},
                    default_ports={str(key): int(value) for key, value in (item.get("ports") or {}).items()},
                    quirks=dict(item.get("quirks") or {}),
                    pairing=tuple(str(value) for value in item.get("pairing") or []),
                )
            )
        return cls(entries)

    def best(self, fingerprint: Fingerprint) -> tuple[Entry | None, int]:
        """Find the entry that fits a fingerprint best.

        Args:
            fingerprint: What is known about the address.

        Returns:
            The entry and its score, or None and 0 when nothing fits.
        """
        scored = [(entry.score(fingerprint), index, entry) for index, entry in enumerate(self.entries)]
        scored = [item for item in scored if item[0] > 0]
        if not scored:
            return None, 0
        score, _, entry = max(scored, key=lambda item: (item[0], -item[1]))
        return entry, score

    def entry(self, entry_id: str) -> Entry | None:
        """Look up an entry by id.

        Args:
            entry_id: The id.

        Returns:
            The entry, or None.
        """
        return next((entry for entry in self.entries if entry.id == entry_id), None)


@lru_cache
def load_catalog(path: str | None = None) -> Catalog:
    """Load the catalog file, once per path.

    Args:
        path: File to load; SSS_ADAPTER_CATALOG or the packaged catalog when omitted.

    Returns:
        The catalog.
    """
    source = Path(path or os.environ.get("SSS_ADAPTER_CATALOG") or CATALOG_PATH)
    return Catalog.from_data(yaml.safe_load(source.read_text()) or {})
