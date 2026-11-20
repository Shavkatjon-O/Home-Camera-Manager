"""The RTSP adapter: a camera known only by its stream address."""

from urllib.parse import urlsplit

from adapters.base import Adapter, AdapterError, AdapterName, Channel, Fingerprint, Identity, LabelInfo, Streams, Target
from adapters.manifest import CapabilityManifest, MediaManifest
from adapters.rtsp.describe import describe, parse_url

__all__ = ["DEFAULT_RTSP_PORT", "RtspAdapter", "stream_url"]

DEFAULT_RTSP_PORT = 554


def stream_url(target: Target, path: str | None = None) -> str:
    """Build the stream address of a target without credentials.

    Args:
        target: The target.
        path: Path to use instead of the target's main path.

    Returns:
        The address.

    Raises:
        AdapterError: The target names neither an address nor a path.
    """
    if target.url and path is None:
        return parse_url(target.url)[2]
    chosen = path or target.main_path
    if not chosen:
        raise AdapterError("invalid", "Give the stream address or its path")
    if not chosen.startswith("/"):
        chosen = f"/{chosen}"
    return f"rtsp://{target.host}:{target.rtsp_port or DEFAULT_RTSP_PORT}{chosen}"


class RtspAdapter(Adapter):
    """Reaches any camera given by an RTSP address.

    Attributes:
        name: rtsp.
        title: RTSP stream.
        priority: The lowest, since every camera with a stream fits.
    """

    name = AdapterName.RTSP.value
    title = "RTSP stream"
    priority = 0

    def match(self, fingerprint: Fingerprint, hints: dict | None = None) -> int:
        """Score a host with the RTSP port open as a weak fit.

        Args:
            fingerprint: What is known about the address.
            hints: Catalog entry that matched, if any.

        Returns:
            10 with port 554 open, otherwise 1, since an address can always be tried.
        """
        return 10 if DEFAULT_RTSP_PORT in fingerprint.open_ports else 1

    async def identify(self, target: Target) -> Identity:
        """Check the stream and describe it.

        Args:
            target: The stream address, or the host with its main path.

        Returns:
            One channel with the stream.

        Raises:
            AdapterError: The stream does not answer or refuses the login.
        """
        url = stream_url(target)
        info = await describe(url, target.username, target.password, target.timeout)
        path = urlsplit(url).path or "/"
        query = urlsplit(url).query
        main_path = f"{path}?{query}" if query else path
        sub_path = target.sub_path if not target.url else None
        channel = Channel(index=1, name="Stream", main_path=main_path, sub_path=sub_path, encoding=info.codec)
        identity = Identity(adapter=self.name, rtsp_port=urlsplit(url).port or DEFAULT_RTSP_PORT, channels=(channel,))
        return Identity(**{**identity.__dict__, "manifest": self.manifest(identity, audio=info.audio)})

    async def streams(self, target: Target, channel: int = 1) -> Streams:
        """Return the stream the target names.

        Args:
            target: The target.
            channel: Channel number, always 1.

        Returns:
            The paths.
        """
        url = stream_url(target)
        parts = urlsplit(url)
        main = f"{parts.path}?{parts.query}" if parts.query else parts.path
        return Streams(main=main or "/", sub=target.sub_path, rtsp_port=parts.port or DEFAULT_RTSP_PORT)

    def parse_label(self, text: str) -> LabelInfo | None:
        """Read a label that carries an RTSP address.

        Args:
            text: Decoded QR text.

        Returns:
            The address as a label, or None for another text.
        """
        value = text.strip()
        if not value.lower().startswith(("rtsp://", "rtsps://")):
            return None
        try:
            host, port, clean, _, _ = parse_url(value)
        except AdapterError:
            return None
        return LabelInfo(adapter=self.name, format="rtsp_url", confirmed=True, host=host, port=port, url=clean)

    def manifest(self, identity: Identity | None = None, **known) -> CapabilityManifest:
        """Build the manifest of a plain stream: media only.

        Args:
            identity: The identity, when checked.
            **known: sub when a sub path is known, audio when the stream carries sound.

        Returns:
            The manifest.
        """
        channels = identity.channels if identity else ()
        codecs = tuple(sorted({item.encoding for item in channels if item.encoding}))
        sub = any(item.sub_path for item in channels) if channels else bool(known.get("sub"))
        return CapabilityManifest(
            adapter=self.name,
            identify=False,
            media=MediaManifest(main=True, sub=sub, audio=bool(known.get("audio")), codecs=codecs),
        )
