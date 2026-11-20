"""The adapter registry: picks the adapter of a device from its fingerprint and the catalog, by priority.

Third-party adapters plug in through the Python entry point group smart_surveillance.camera_adapters; each entry
point names an Adapter subclass, or a function that returns an Adapter, and its name must not clash with a
built-in adapter.
"""

import logging
from dataclasses import dataclass
from functools import lru_cache
from importlib.metadata import entry_points

from camera_adapters.base import Adapter, AdapterError, Fingerprint, Identity, LabelInfo, Target
from camera_adapters.catalog import Catalog, Entry, load_catalog
from camera_adapters.ezviz.adapter import EzvizAdapter
from camera_adapters.manifest import CapabilityManifest
from camera_adapters.onvif.adapter import OnvifAdapter
from camera_adapters.rtsp.adapter import RtspAdapter
from camera_adapters.v380.adapter import V380Adapter

__all__ = ["ENTRY_POINT_GROUP", "Registry", "Resolution", "builtin_adapters", "default_registry"]

logger = logging.getLogger(__name__)

ENTRY_POINT_GROUP = "smart_surveillance.camera_adapters"
CATALOG_BONUS_CAP = 50


@dataclass(frozen=True)
class Resolution:
    """An adapter that fits a fingerprint.

    Attributes:
        adapter: The adapter.
        score: How well it fits; higher fits better.
        entry: Catalog entry that matched, if any.
    """

    adapter: Adapter
    score: int
    entry: Entry | None = None


def builtin_adapters() -> list[Adapter]:
    """Create the adapters that ship with the package.

    Returns:
        The V380, EZVIZ, ONVIF and RTSP adapters.
    """
    return [V380Adapter(), EzvizAdapter(), OnvifAdapter(), RtspAdapter()]


def plugin_adapters(reserved: set[str]) -> list[Adapter]:
    """Load the adapters other packages register through entry points.

    A plugin that fails to load, is not an adapter or takes a reserved name is skipped with a warning.

    Args:
        reserved: Names already taken.

    Returns:
        The plugins' adapters.
    """
    found = []
    for point in entry_points(group=ENTRY_POINT_GROUP):
        try:
            loaded = point.load()
            adapter = loaded() if callable(loaded) else loaded
        except Exception:
            logger.warning("The camera adapter plugin %s could not be loaded", point.name, exc_info=True)
            continue
        if not isinstance(adapter, Adapter) or not adapter.name or adapter.name in reserved:
            logger.warning("The camera adapter plugin %s is not a valid adapter or reuses a name", point.name)
            continue
        reserved.add(adapter.name)
        found.append(adapter)
    return found


class Registry:
    """The adapters available and the catalog they are chosen with.

    Attributes:
        adapters: Adapters by name.
        catalog: The model catalog.
    """

    def __init__(self, adapters: list[Adapter] | None = None, catalog: Catalog | None = None, plugins: bool = True):
        """Create the registry.

        Args:
            adapters: Adapters to use; the built-in ones when omitted.
            catalog: Catalog to use; the packaged one when omitted.
            plugins: Whether to add the adapters of installed plugins.
        """
        chosen = adapters if adapters is not None else builtin_adapters()
        if plugins:
            chosen = [*chosen, *plugin_adapters({adapter.name for adapter in chosen})]
        self.adapters = {adapter.name: adapter for adapter in chosen}
        self.catalog = catalog if catalog is not None else load_catalog()

    def get(self, name: str) -> Adapter:
        """Look up an adapter by name.

        Args:
            name: Adapter name.

        Returns:
            The adapter.

        Raises:
            AdapterError: No adapter has that name.
        """
        adapter = self.adapters.get(name)
        if adapter is None:
            raise AdapterError("invalid", f"There is no {name} adapter")
        return adapter

    def rank(self, fingerprint: Fingerprint) -> list[Resolution]:
        """Rank the adapters that fit a fingerprint, best first.

        The catalog entry that fits best adds its score to its own adapter, so a model or vendor match lifts the
        vendor adapter above the generic ones.

        Args:
            fingerprint: What is known about the address.

        Returns:
            The fitting adapters, by score and then priority.
        """
        entry, entry_score = self.catalog.best(fingerprint)
        hints = entry.hints() if entry else None
        ranked = []
        for adapter in self.adapters.values():
            score = adapter.match(fingerprint, hints)
            if score <= 0:
                continue
            if entry is not None and entry.adapter == adapter.name:
                score += min(entry_score, CATALOG_BONUS_CAP)
            ranked.append(
                Resolution(
                    adapter=adapter, score=score, entry=entry if entry and entry.adapter == adapter.name else None
                )
            )
        return sorted(ranked, key=lambda item: (item.score, item.adapter.priority), reverse=True)

    def resolve(self, fingerprint: Fingerprint) -> Resolution:
        """Pick the adapter that fits a fingerprint best.

        Args:
            fingerprint: What is known about the address.

        Returns:
            The best fit; the RTSP adapter fits every address.
        """
        ranked = self.rank(fingerprint)
        return ranked[0] if ranked else Resolution(adapter=self.get("rtsp"), score=1)

    def parse_label(self, text: str) -> LabelInfo | None:
        """Read a label QR code with every adapter's parser.

        Labels of a published standard win over the tolerant vendor guesses, and a higher priority wins among
        equals.

        Args:
            text: Decoded QR text.

        Returns:
            What the label says, or None when no adapter reads it.
        """
        found = []
        for adapter in self.adapters.values():
            try:
                label = adapter.parse_label(text)
            except Exception:
                logger.warning("The %s label parser failed", adapter.name, exc_info=True)
                continue
            if label is not None:
                found.append((label.confirmed, adapter.priority, label))
        if not found:
            return None
        return max(found, key=lambda item: (item[0], item[1]))[2]

    async def identify(
        self, target: Target, fingerprint: Fingerprint | None = None, adapter: str | None = None
    ) -> tuple[Identity, Resolution]:
        """Identify a device with the adapter named, or with the fitting adapters in turn.

        A refused login stops the search, since another adapter would be refused the same way.

        Args:
            target: How to reach the device.
            fingerprint: What is known about the address, for ranking.
            adapter: Adapter to use, when the caller knows it.

        Returns:
            The identity and the adapter that produced it.

        Raises:
            AdapterError: No adapter could identify the device; the last adapter's error.
        """
        if adapter is not None:
            chosen = [Resolution(adapter=self.get(adapter), score=0)]
        else:
            chosen = self.rank(fingerprint or Fingerprint(host=target.host))
        failure = AdapterError("unreachable", f"No adapter could reach {target.host}")
        for resolution in chosen:
            try:
                return await resolution.adapter.identify(target), resolution
            except AdapterError as exc:
                if exc.code == "unauthorized":
                    raise
                failure = exc
        raise failure

    def manifest(self, name: str, **known) -> CapabilityManifest:
        """Build the manifest of a camera from what is known without identifying it.

        Args:
            name: Adapter name.
            **known: Facts such as ptz and sub.

        Returns:
            The manifest.
        """
        return self.get(name).manifest(None, **known)


@lru_cache
def default_registry() -> Registry:
    """Return the registry with the built-in adapters, the installed plugins and the packaged catalog.

    Returns:
        The registry, built once.
    """
    return Registry()
