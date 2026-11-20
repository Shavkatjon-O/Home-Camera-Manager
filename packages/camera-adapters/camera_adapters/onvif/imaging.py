"""Imaging settings and options requests and parsers for ONVIF devices."""

from dataclasses import dataclass, field
from xml.etree.ElementTree import Element
from xml.sax.saxutils import escape

from camera_adapters.onvif.media import Range, format_number, number, value_range
from camera_adapters.onvif.soap import child, children, descendant, text

LEVELS = ("brightness", "contrast", "saturation", "sharpness")
LEVEL_ELEMENTS = {
    "brightness": "Brightness",
    "contrast": "Contrast",
    "saturation": "ColorSaturation",
    "sharpness": "Sharpness",
}


@dataclass(frozen=True)
class ImagingState:
    """Imaging settings of a video source, with None for settings the device does not report.

    Attributes:
        brightness: Brightness level.
        contrast: Contrast level.
        saturation: Colour saturation level.
        sharpness: Sharpness level.
        ir_cut_filter: Infrared cut filter mode.
        wdr_mode: Wide dynamic range mode.
        wdr_level: Wide dynamic range level.
        backlight_mode: Backlight compensation mode.
        backlight_level: Backlight compensation level.
    """

    brightness: float | None = None
    contrast: float | None = None
    saturation: float | None = None
    sharpness: float | None = None
    ir_cut_filter: str | None = None
    wdr_mode: str | None = None
    wdr_level: float | None = None
    backlight_mode: str | None = None
    backlight_level: float | None = None


@dataclass(frozen=True)
class ImagingOptions:
    """Values a video source accepts for its imaging settings.

    Attributes:
        levels: Setting name to its allowed range, only for ranges with a span.
        ir_cut_filter_modes: Allowed infrared cut filter modes.
        wdr_modes: Allowed wide dynamic range modes.
        wdr_level: Allowed wide dynamic range level range.
        backlight_modes: Allowed backlight compensation modes.
        backlight_level: Allowed backlight compensation level range.
    """

    levels: dict[str, Range] = field(default_factory=dict)
    ir_cut_filter_modes: tuple[str, ...] = ()
    wdr_modes: tuple[str, ...] = ()
    wdr_level: Range | None = None
    backlight_modes: tuple[str, ...] = ()
    backlight_level: Range | None = None


def modes(element: Element | None, name: str) -> tuple[str, ...]:
    """Collect the distinct values of the child elements with a name.

    Args:
        element: Parent element, or None.
        name: Local name of the child elements.

    Returns:
        The non-empty values in document order, without repeats.
    """
    found = []
    for item in children(element, name):
        value = text(item)
        if value and value not in found:
            found.append(value)
    return tuple(found)


def parse_settings(body: Element) -> ImagingState:
    """Read the imaging settings from a GetImagingSettings response.

    Args:
        body: SOAP body of the response.

    Returns:
        The settings, all None when the response has no imaging settings.
    """
    settings = descendant(body, "ImagingSettings")
    if settings is None:
        return ImagingState()
    wdr = child(settings, "WideDynamicRange")
    backlight = child(settings, "BacklightCompensation")
    return ImagingState(
        brightness=number(text(child(settings, "Brightness"))),
        contrast=number(text(child(settings, "Contrast"))),
        saturation=number(text(child(settings, "ColorSaturation"))),
        sharpness=number(text(child(settings, "Sharpness"))),
        ir_cut_filter=text(child(settings, "IrCutFilter")),
        wdr_mode=text(child(wdr, "Mode")),
        wdr_level=number(text(child(wdr, "Level"))),
        backlight_mode=text(child(backlight, "Mode")),
        backlight_level=number(text(child(backlight, "Level"))),
    )


def parse_options(body: Element) -> ImagingOptions:
    """Read the allowed imaging values from a GetOptions response.

    Args:
        body: SOAP body of the response.

    Returns:
        The options, empty when the response has no imaging options.
    """
    options = descendant(body, "ImagingOptions")
    if options is None:
        return ImagingOptions()
    levels = {}
    for key, name in LEVEL_ELEMENTS.items():
        found = value_range(child(options, name))
        if found is not None and found.maximum > found.minimum:
            levels[key] = found
    wdr = child(options, "WideDynamicRange")
    backlight = child(options, "BacklightCompensation")
    return ImagingOptions(
        levels=levels,
        ir_cut_filter_modes=modes(options, "IrCutFilterModes"),
        wdr_modes=modes(wdr, "Mode"),
        wdr_level=value_range(child(wdr, "Level")),
        backlight_modes=modes(backlight, "Mode"),
        backlight_level=value_range(child(backlight, "Level")),
    )


def mode_block(name: str, mode: str | None, level: float | None) -> str:
    """Build the XML of a setting that has a mode and an optional level.

    Args:
        name: Element name of the setting.
        mode: Mode to set.
        level: Level to set, left out when None.

    Returns:
        The XML, or an empty string when the mode is None.
    """
    if mode is None:
        return ""
    level_xml = f"<tt:Level>{format_number(level)}</tt:Level>" if level is not None else ""
    return f"<tt:{name}><tt:Mode>{escape(mode)}</tt:Mode>{level_xml}</tt:{name}>"


def set_body(source_token: str, state: ImagingState) -> str:
    """Build a SetImagingSettings request that is persisted on the device.

    Only the settings that are not None are included.

    Args:
        source_token: Video source token.
        state: Settings to apply.

    Returns:
        The XML of the request body.
    """
    parts = [mode_block("BacklightCompensation", state.backlight_mode, state.backlight_level)]
    for key in ("brightness", "saturation", "contrast"):
        value = getattr(state, key)
        if value is not None:
            parts.append(f"<tt:{LEVEL_ELEMENTS[key]}>{format_number(value)}</tt:{LEVEL_ELEMENTS[key]}>")
    if state.ir_cut_filter is not None:
        parts.append(f"<tt:IrCutFilter>{escape(state.ir_cut_filter)}</tt:IrCutFilter>")
    if state.sharpness is not None:
        parts.append(f"<tt:Sharpness>{format_number(state.sharpness)}</tt:Sharpness>")
    parts.append(mode_block("WideDynamicRange", state.wdr_mode, state.wdr_level))
    return (
        f"<timg:SetImagingSettings><timg:VideoSourceToken>{escape(source_token)}</timg:VideoSourceToken>"
        f"<timg:ImagingSettings>{''.join(parts)}</timg:ImagingSettings>"
        "<timg:ForcePersistence>true</timg:ForcePersistence></timg:SetImagingSettings>"
    )


def settings_body(source_token: str) -> str:
    """Build a GetImagingSettings request.

    Args:
        source_token: Video source token.

    Returns:
        The XML of the request body.
    """
    source = f"<timg:VideoSourceToken>{escape(source_token)}</timg:VideoSourceToken>"
    return f"<timg:GetImagingSettings>{source}</timg:GetImagingSettings>"


def options_body(source_token: str) -> str:
    """Build an imaging GetOptions request.

    Args:
        source_token: Video source token.

    Returns:
        The XML of the request body.
    """
    return f"<timg:GetOptions><timg:VideoSourceToken>{escape(source_token)}</timg:VideoSourceToken></timg:GetOptions>"


def video_sources(body: Element) -> list[str]:
    """Read the video source tokens from a GetVideoSources response.

    Args:
        body: SOAP body of the response.

    Returns:
        The tokens of the VideoSources elements.
    """
    return [
        element.get("token") for element in body.iter() if element.get("token") and element.tag.endswith("VideoSources")
    ]
