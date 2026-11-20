"""PTZ preset and node requests and parsers for ONVIF devices."""

from dataclasses import dataclass
from xml.etree.ElementTree import Element
from xml.sax.saxutils import escape

from app.onvif.media import whole
from app.onvif.soap import child, descendant, descendants, text


@dataclass(frozen=True)
class Preset:
    """A stored PTZ preset position.

    Attributes:
        token: Preset token on the device.
        name: Preset name, the token when the device gives none.
    """

    token: str
    name: str


@dataclass(frozen=True)
class NodeInfo:
    """Capabilities of a PTZ node.

    Attributes:
        max_presets: Maximum number of presets the node stores.
        home_supported: Whether the node supports a home position.
    """

    max_presets: int | None
    home_supported: bool | None


def parse_presets(body: Element) -> list[Preset]:
    """Read the presets from a GetPresets response.

    Args:
        body: SOAP body of the response.

    Returns:
        The presets that carry a token.
    """
    result = []
    for element in descendants(body, "Preset"):
        token = element.get("token")
        if token:
            result.append(Preset(token=token, name=text(child(element, "Name")) or token))
    return result


def parse_node(body: Element) -> NodeInfo:
    """Read the PTZ node capabilities from a GetNodes response.

    Args:
        body: SOAP body of the response.

    Returns:
        The node capabilities, with None fields when the response has no PTZ node.
    """
    node = descendant(body, "PTZNode")
    if node is None:
        return NodeInfo(max_presets=None, home_supported=None)
    home = text(child(node, "HomeSupported"))
    return NodeInfo(
        max_presets=whole(text(child(node, "MaximumNumberOfPresets"))),
        home_supported=None if home is None else home.lower() == "true",
    )


def profile(token: str) -> str:
    """Build the profile token element shared by the PTZ requests.

    Args:
        token: Media profile token.

    Returns:
        The XML element.
    """
    return f"<tptz:ProfileToken>{escape(token)}</tptz:ProfileToken>"


def presets_body(token: str) -> str:
    """Build a GetPresets request.

    Args:
        token: Media profile token.

    Returns:
        The XML of the request body.
    """
    return f"<tptz:GetPresets>{profile(token)}</tptz:GetPresets>"


def set_preset_body(token: str, name: str, preset: str | None = None) -> str:
    """Build a SetPreset request.

    Args:
        token: Media profile token.
        name: Name of the preset.
        preset: Token of an existing preset to overwrite, a new preset is created when omitted.

    Returns:
        The XML of the request body.
    """
    existing = f"<tptz:PresetToken>{escape(preset)}</tptz:PresetToken>" if preset else ""
    return (
        f"<tptz:SetPreset>{profile(token)}<tptz:PresetName>{escape(name)}</tptz:PresetName>{existing}</tptz:SetPreset>"
    )


def remove_preset_body(token: str, preset: str) -> str:
    """Build a RemovePreset request.

    Args:
        token: Media profile token.
        preset: Token of the preset to remove.

    Returns:
        The XML of the request body.
    """
    return (
        f"<tptz:RemovePreset>{profile(token)}<tptz:PresetToken>{escape(preset)}</tptz:PresetToken></tptz:RemovePreset>"
    )


def goto_preset_body(token: str, preset: str) -> str:
    """Build a GotoPreset request.

    Args:
        token: Media profile token.
        preset: Token of the preset to move to.

    Returns:
        The XML of the request body.
    """
    return f"<tptz:GotoPreset>{profile(token)}<tptz:PresetToken>{escape(preset)}</tptz:PresetToken></tptz:GotoPreset>"


def goto_home_body(token: str) -> str:
    """Build a GotoHomePosition request.

    Args:
        token: Media profile token.

    Returns:
        The XML of the request body.
    """
    return f"<tptz:GotoHomePosition>{profile(token)}</tptz:GotoHomePosition>"


def set_home_body(token: str) -> str:
    """Build a SetHomePosition request.

    Args:
        token: Media profile token.

    Returns:
        The XML of the request body.
    """
    return f"<tptz:SetHomePosition>{profile(token)}</tptz:SetHomePosition>"


def nodes_body() -> str:
    """Build a GetNodes request.

    Returns:
        The XML of the request body.
    """
    return "<tptz:GetNodes/>"
