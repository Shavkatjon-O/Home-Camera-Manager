"""The EZVIZ adapter: ONVIF with EZVIZ's stream paths, encoding report and motion sensitivity quirk."""

from camera_adapters.base import AdapterName, Fingerprint, Identity, LabelInfo, Streams, Target
from camera_adapters.classifier import EZVIZ_PORT
from camera_adapters.ezviz.labels import parse_ezviz_label
from camera_adapters.manifest import CapabilityManifest
from camera_adapters.onvif.adapter import OnvifAdapter

__all__ = ["EzvizAdapter"]


class EzvizAdapter(OnvifAdapter):
    """Reaches EZVIZ cameras, which need Local Service Settings switched on in the EZVIZ app.

    Attributes:
        name: ezviz.
        title: EZVIZ camera.
        priority: Above the generic ONVIF adapter.
    """

    name = AdapterName.EZVIZ.value
    title = "EZVIZ camera"
    priority = 30

    def match(self, fingerprint: Fingerprint, hints: dict | None = None) -> int:
        """Score an EZVIZ camera by its catalog entry or its own port.

        Args:
            fingerprint: What is known about the address.
            hints: Catalog entry that matched, if any.

        Returns:
            60 for an EZVIZ catalog match, 45 for EZVIZ's port, otherwise 0.
        """
        if hints and hints.get("adapter") == self.name:
            return 60
        if EZVIZ_PORT in fingerprint.open_ports and not fingerprint.v380:
            return 45
        return 0

    async def streams(self, target: Target, channel: int = 1) -> Streams:
        """Return the stream paths, EZVIZ's fixed ones when the target gives none.

        Args:
            target: How to reach the camera.
            channel: Channel number, 1 for a camera.

        Returns:
            The paths.
        """
        if target.main_path:
            return Streams(main=target.main_path, sub=target.sub_path, rtsp_port=target.rtsp_port)
        return Streams(main=f"/Streaming/Channels/{channel}01", sub=f"/Streaming/Channels/{channel}02", rtsp_port=554)

    def parse_label(self, text: str) -> LabelInfo | None:
        """Read an EZVIZ label QR code.

        Args:
            text: Decoded QR text.

        Returns:
            What the label says, or None.
        """
        return parse_ezviz_label(text)

    def manifest(self, identity: Identity | None = None, **known) -> CapabilityManifest:
        """Build the manifest: the ONVIF one, with the sub stream every EZVIZ camera has.

        Args:
            identity: The identity, when identified.
            **known: Facts known without identification.

        Returns:
            The manifest.
        """
        return super().manifest(identity, **known).replaced(adapter=self.name, media={"sub": True})
