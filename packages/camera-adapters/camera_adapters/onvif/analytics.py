"""Motion detection analytics requests, parsers and cell mask encoding for ONVIF devices."""

import base64
import binascii
import copy
from dataclasses import dataclass
from xml.etree.ElementTree import Element
from xml.sax.saxutils import escape

from adapters.onvif.media import whole
from adapters.onvif.soap import child, children, descendant, descendants, local_name, serialize

CELL_ENGINE = "CellMotionEngine"
CELL_DETECTOR = "CellMotionDetector"
SENSITIVITY = "Sensitivity"
ACTIVE_CELLS = "ActiveCells"


@dataclass(frozen=True)
class MotionSetup:
    """Cell motion detection settings of a video analytics configuration.

    Attributes:
        configuration_token: Token of the analytics configuration.
        module: The cell motion engine module, if present.
        rule: The cell motion detector rule, if present.
        sensitivity: Sensitivity of the module.
        columns: Columns of the cell grid.
        rows: Rows of the cell grid.
        active_cells: Packed bit mask of the active cells, base64 encoded.
    """

    configuration_token: str
    module: Element | None
    rule: Element | None
    sensitivity: int | None
    columns: int | None
    rows: int | None
    active_cells: str | None

    @property
    def cells(self) -> int | None:
        """Return the number of cells in the grid.

        Returns:
            Columns times rows, or None when either is unknown.
        """
        if self.columns and self.rows:
            return self.columns * self.rows
        return None


def simple_item(element: Element | None, name: str) -> Element | None:
    """Find a named simple item among an element's parameters.

    Args:
        element: Module or rule element, or None.
        name: Name of the item.

    Returns:
        The item, or None when there is none with that name.
    """
    parameters = child(element, "Parameters")
    for item in children(parameters, "SimpleItem"):
        if item.get("Name") == name:
            return item
    return None


def type_name(element: Element) -> str:
    """Return the type of an element without its namespace prefix.

    Args:
        element: Element with a Type attribute.

    Returns:
        The part of the Type attribute after the last colon, empty when it has none.
    """
    return (element.get("Type") or "").rsplit(":", 1)[-1]


def find_by_type(body: Element, tag: str, kind: str) -> Element | None:
    """Find the first descendant with a tag and a type.

    Args:
        body: Element to search below.
        tag: Local name of the descendants to consider.
        kind: Type name to match, without a namespace prefix.

    Returns:
        The matching element, or None.
    """
    for element in descendants(body, tag):
        if type_name(element) == kind:
            return element
    return None


def analytics_tokens(body: Element) -> list[str]:
    """Collect the analytics configuration tokens from a response.

    Args:
        body: SOAP body of the response.

    Returns:
        The distinct tokens of the VideoAnalyticsConfiguration and Analytics elements, in document order.
    """
    found = []
    for element in body.iter():
        if local_name(element.tag) in ("VideoAnalyticsConfiguration", "Analytics") and element.get("token"):
            if element.get("token") not in found:
                found.append(element.get("token"))
    return found


def parse_setup(token: str, modules: Element | None, rules: Element | None) -> MotionSetup:
    """Read the cell motion settings from analytics modules and rules.

    Args:
        token: Token of the analytics configuration.
        modules: Response of GetAnalyticsModules, or None.
        rules: Response of GetRules, or None.

    Returns:
        The settings, with None for parts the device did not report.
    """
    module = find_by_type(modules, "AnalyticsModule", CELL_ENGINE) if modules is not None else None
    rule = find_by_type(rules, "Rule", CELL_DETECTOR) if rules is not None else None
    sensitivity_item = simple_item(module, SENSITIVITY)
    layout = descendant(module, "CellLayout")
    cells_item = simple_item(rule, ACTIVE_CELLS)
    return MotionSetup(
        configuration_token=token,
        module=module,
        rule=rule,
        sensitivity=whole(sensitivity_item.get("Value")) if sensitivity_item is not None else None,
        columns=whole(layout.get("Columns")) if layout is not None else None,
        rows=whole(layout.get("Rows")) if layout is not None else None,
        active_cells=cells_item.get("Value") if cells_item is not None else None,
    )


def unpack_bits(data: bytes) -> bytes:
    """Decode run-length packed bytes.

    Args:
        data: Packed bytes, where a header below 128 copies the next header plus one bytes and a header above 128
            repeats the next byte 257 minus header times.

    Returns:
        The unpacked bytes.
    """
    result = bytearray()
    position = 0
    while position < len(data):
        header = data[position]
        position += 1
        if header < 128:
            result.extend(data[position : position + header + 1])
            position += header + 1
        elif header > 128:
            if position < len(data):
                result.extend(bytes([data[position]]) * (257 - header))
            position += 1
    return bytes(result)


def pack_bits(data: bytes) -> bytes:
    """Encode bytes as run-length packed bytes, the inverse of unpacking.

    Args:
        data: Bytes to pack.

    Returns:
        The packed bytes.
    """
    result = bytearray()
    position = 0
    while position < len(data):
        run = 1
        while position + run < len(data) and run < 128 and data[position + run] == data[position]:
            run += 1
        if run > 1:
            result.append(257 - run)
            result.append(data[position])
            position += run
            continue
        start = position
        position += 1
        while position < len(data) and position - start < 128:
            if position + 1 < len(data) and data[position] == data[position + 1]:
                break
            position += 1
        result.append(position - start - 1)
        result.extend(data[start:position])
    return bytes(result)


def active_count(value: str | None, cells: int) -> int | None:
    """Count the active cells of a packed cell mask.

    Args:
        value: Base64 encoded packed mask, or None.
        cells: Number of cells in the grid, bits beyond it are ignored.

    Returns:
        The number of active cells, or None when the mask is missing or not valid base64.
    """
    if not value:
        return None
    try:
        raw = unpack_bits(base64.b64decode(value, validate=True))
    except (binascii.Error, ValueError):
        return None
    bits = "".join(f"{byte:08b}" for byte in raw)[:cells]
    return bits.count("1")


def cells_value(cells: int, active: bool) -> str:
    """Build a packed cell mask with every cell on or off.

    Args:
        cells: Number of cells in the grid.
        active: Whether every cell is active.

    Returns:
        The base64 encoded packed mask.
    """
    full, rest = divmod(cells, 8)
    fill = 0xFF if active else 0x00
    raw = bytes([fill]) * full
    if rest:
        raw += bytes([((0xFF << (8 - rest)) & 0xFF) if active else 0])
    return base64.b64encode(pack_bits(raw)).decode()


def with_item(element: Element, name: str, value: str) -> Element:
    """Copy an element with the value of a named simple item changed.

    Args:
        element: Module or rule element.
        name: Name of the item.
        value: New value, ignored when the element has no such item.

    Returns:
        The updated copy, the original is not changed.
    """
    updated = copy.deepcopy(element)
    item = simple_item(updated, name)
    if item is not None:
        item.set("Value", value)
    return updated


def modify_module_body(token: str, module: Element) -> str:
    """Build a ModifyAnalyticsModules request.

    Args:
        token: Token of the analytics configuration.
        module: Module to write.

    Returns:
        The XML of the request body.
    """
    return (
        f"<tan:ModifyAnalyticsModules><tan:ConfigurationToken>{escape(token)}</tan:ConfigurationToken>"
        f"{serialize(module)}</tan:ModifyAnalyticsModules>"
    )


def modify_rule_body(token: str, rule: Element) -> str:
    """Build a ModifyRules request.

    Args:
        token: Token of the analytics configuration.
        rule: Rule to write.

    Returns:
        The XML of the request body.
    """
    return (
        f"<tan:ModifyRules><tan:ConfigurationToken>{escape(token)}</tan:ConfigurationToken>"
        f"{serialize(rule)}</tan:ModifyRules>"
    )


def modules_body(token: str) -> str:
    """Build a GetAnalyticsModules request.

    Args:
        token: Token of the analytics configuration.

    Returns:
        The XML of the request body.
    """
    configuration = f"<tan:ConfigurationToken>{escape(token)}</tan:ConfigurationToken>"
    return f"<tan:GetAnalyticsModules>{configuration}</tan:GetAnalyticsModules>"


def rules_body(token: str) -> str:
    """Build a GetRules request.

    Args:
        token: Token of the analytics configuration.

    Returns:
        The XML of the request body.
    """
    return f"<tan:GetRules><tan:ConfigurationToken>{escape(token)}</tan:ConfigurationToken></tan:GetRules>"
