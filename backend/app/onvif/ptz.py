from dataclasses import dataclass
from xml.etree.ElementTree import Element
from xml.sax.saxutils import escape

from app.onvif.media import whole
from app.onvif.soap import child, descendant, descendant_text, descendants, text


@dataclass(frozen=True)
class Preset:
    token: str
    name: str


@dataclass(frozen=True)
class NodeInfo:
    max_presets: int | None
    home_supported: bool | None


def parse_presets(body: Element) -> list[Preset]:
    result = []
    for element in descendants(body, "Preset"):
        token = element.get("token")
        if token:
            result.append(Preset(token=token, name=text(child(element, "Name")) or token))
    return result


def parse_node(body: Element) -> NodeInfo:
    node = descendant(body, "PTZNode")
    if node is None:
        return NodeInfo(max_presets=None, home_supported=None)
    home = text(child(node, "HomeSupported"))
    return NodeInfo(
        max_presets=whole(text(child(node, "MaximumNumberOfPresets"))),
        home_supported=None if home is None else home.lower() == "true",
    )


def parse_preset_token(body: Element) -> str | None:
    return descendant_text(body, "PresetToken")


def profile(token: str) -> str:
    return f"<tptz:ProfileToken>{escape(token)}</tptz:ProfileToken>"


def presets_body(token: str) -> str:
    return f"<tptz:GetPresets>{profile(token)}</tptz:GetPresets>"


def set_preset_body(token: str, name: str, preset: str | None = None) -> str:
    existing = f"<tptz:PresetToken>{escape(preset)}</tptz:PresetToken>" if preset else ""
    return (
        f"<tptz:SetPreset>{profile(token)}<tptz:PresetName>{escape(name)}</tptz:PresetName>{existing}</tptz:SetPreset>"
    )


def remove_preset_body(token: str, preset: str) -> str:
    return (
        f"<tptz:RemovePreset>{profile(token)}<tptz:PresetToken>{escape(preset)}</tptz:PresetToken></tptz:RemovePreset>"
    )


def goto_preset_body(token: str, preset: str) -> str:
    return f"<tptz:GotoPreset>{profile(token)}<tptz:PresetToken>{escape(preset)}</tptz:PresetToken></tptz:GotoPreset>"


def goto_home_body(token: str) -> str:
    return f"<tptz:GotoHomePosition>{profile(token)}</tptz:GotoHomePosition>"


def set_home_body(token: str) -> str:
    return f"<tptz:SetHomePosition>{profile(token)}</tptz:SetHomePosition>"


def nodes_body() -> str:
    return "<tptz:GetNodes/>"
