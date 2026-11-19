"""SOAP envelope building, XML navigation helpers and response parsing for ONVIF."""

from xml.etree import ElementTree
from xml.etree.ElementTree import Element

SOAP_NAMESPACE = "http://www.w3.org/2003/05/soap-envelope"

NAMESPACES = {
    "s": SOAP_NAMESPACE,
    "tds": "http://www.onvif.org/ver10/device/wsdl",
    "trt": "http://www.onvif.org/ver10/media/wsdl",
    "tptz": "http://www.onvif.org/ver20/ptz/wsdl",
    "tt": "http://www.onvif.org/ver10/schema",
}

EXTRA_NAMESPACES = {
    "tev": "http://www.onvif.org/ver10/events/wsdl",
    "wsnt": "http://docs.oasis-open.org/wsn/b-2",
    "wsa": "http://www.w3.org/2005/08/addressing",
    "timg": "http://www.onvif.org/ver20/imaging/wsdl",
    "tan": "http://www.onvif.org/ver20/analytics/wsdl",
    "trc": "http://www.onvif.org/ver10/recording/wsdl",
    "tse": "http://www.onvif.org/ver10/search/wsdl",
    "trp": "http://www.onvif.org/ver10/replay/wsdl",
    "tr2": "http://www.onvif.org/ver20/media/wsdl",
}


class OnvifError(Exception):
    """Base error for a failed ONVIF exchange with a device."""

    pass


class OnvifFault(OnvifError):
    """Error raised when the device answers with a SOAP fault."""

    pass


class OnvifRefused(OnvifError):
    """Error raised when the device refuses the connection on the ONVIF port."""

    pass


def envelope(body: str, header: str = "") -> bytes:
    """Wrap a request body in a SOAP envelope.

    Only the optional namespaces whose prefix appears in the body or header are declared.

    Args:
        body: XML of the request inside the SOAP body.
        header: XML placed inside the SOAP header, left out when empty.

    Returns:
        The UTF-8 encoded XML document.
    """
    used = {prefix: uri for prefix, uri in EXTRA_NAMESPACES.items() if f"<{prefix}:" in body or f"<{prefix}:" in header}
    declarations = " ".join(f'xmlns:{prefix}="{uri}"' for prefix, uri in (NAMESPACES | used).items())
    head = f"<s:Header>{header}</s:Header>" if header else ""
    document = f"<s:Envelope {declarations}>{head}<s:Body>{body}</s:Body></s:Envelope>"
    return f'<?xml version="1.0" encoding="UTF-8"?>{document}'.encode()


def local_name(tag: str) -> str:
    """Strip the namespace from an element tag.

    Args:
        tag: Tag in the form "{namespace}name" or "name".

    Returns:
        The tag without its namespace.
    """
    return tag.rsplit("}", 1)[-1]


def child(element: Element | None, name: str) -> Element | None:
    """Find the first direct child element with a local name.

    Args:
        element: Parent element, or None.
        name: Local name to look for.

    Returns:
        The matching child, or None when the parent is None or has no such child.
    """
    if element is None:
        return None
    for item in element:
        if local_name(item.tag) == name:
            return item
    return None


def children(element: Element | None, name: str) -> list[Element]:
    """Collect the direct child elements with a local name.

    Args:
        element: Parent element, or None.
        name: Local name to look for.

    Returns:
        The matching children in document order, empty when the parent is None.
    """
    if element is None:
        return []
    return [item for item in element if local_name(item.tag) == name]


def descendant(element: Element | None, name: str) -> Element | None:
    """Find the first element below another one with a local name.

    Args:
        element: Element to search below, or None.
        name: Local name to look for.

    Returns:
        The first matching descendant in document order, or None.
    """
    if element is None:
        return None
    for item in element.iter():
        if item is not element and local_name(item.tag) == name:
            return item
    return None


def descendants(element: Element | None, name: str) -> list[Element]:
    """Collect every element below another one with a local name.

    Args:
        element: Element to search below, or None.
        name: Local name to look for.

    Returns:
        The matching descendants in document order, empty when the element is None.
    """
    if element is None:
        return []
    return [item for item in element.iter() if item is not element and local_name(item.tag) == name]


def text(element: Element | None) -> str | None:
    """Return the stripped text of an element.

    Args:
        element: Element to read, or None.

    Returns:
        The text, or None when the element is missing or its text is empty.
    """
    if element is None or element.text is None:
        return None
    value = element.text.strip()
    return value or None


def descendant_text(element: Element | None, name: str) -> str | None:
    """Return the stripped text of the first descendant with a local name.

    Args:
        element: Element to search below, or None.
        name: Local name to look for.

    Returns:
        The text, or None when no such descendant has any.
    """
    return text(descendant(element, name))


def fault_message(fault: Element) -> str:
    """Pick a readable message out of a SOAP fault.

    Args:
        fault: The Fault element of the response.

    Returns:
        The fault reason text, else the last fault code value, else a generic message.
    """
    reason = descendant_text(fault, "Text") or descendant_text(fault, "faultstring")
    if reason:
        return reason
    codes = [text(item) for item in descendants(fault, "Value")]
    codes = [code for code in codes if code]
    if codes:
        return codes[-1]
    return "The device returned a SOAP fault"


def parse_response(content: bytes, status_code: int) -> Element:
    """Parse a SOAP response and return its body.

    Args:
        content: Raw response bytes.
        status_code: HTTP status code of the response.

    Returns:
        The SOAP Body element.

    Raises:
        OnvifError: When the content is not a SOAP envelope, has no body or came with an HTTP error status.
        OnvifFault: When the body carries a SOAP fault.
    """
    try:
        root = ElementTree.fromstring(content)
    except ElementTree.ParseError:
        if status_code >= 400:
            raise OnvifError(f"The device answered HTTP {status_code}")
        raise OnvifError("The device did not answer with SOAP")
    if local_name(root.tag) != "Envelope":
        raise OnvifError("The device did not answer with SOAP")
    body = child(root, "Body")
    fault = child(body, "Fault")
    if fault is not None:
        raise OnvifFault(fault_message(fault))
    if status_code >= 400:
        raise OnvifError(f"The device answered HTTP {status_code}")
    if body is None:
        raise OnvifError("The device answered without a SOAP body")
    return body


def prefixed(tag: str) -> tuple[str, str | None]:
    """Turn a namespaced tag into a prefixed name for serialisation.

    Args:
        tag: Tag in the form "{namespace}name" or "name".

    Returns:
        The prefixed name, and the namespace URI that needs declaring when the namespace has no known prefix
        (it is then written with the prefix x), otherwise None.
    """
    if not tag.startswith("{"):
        return tag, None
    uri, _, name = tag[1:].partition("}")
    for prefix, known in (NAMESPACES | EXTRA_NAMESPACES).items():
        if known == uri:
            return f"{prefix}:{name}", None
    return f"x:{name}", uri


def serialize(element: Element) -> str:
    """Serialise an element tree to XML with the prefixes this package declares.

    Args:
        element: Element to serialise.

    Returns:
        The XML text of the element and its children.
    """
    name, unknown = prefixed(element.tag)
    attributes = []
    if unknown:
        attributes.append(f'xmlns:x="{xml_escape(unknown)}"')
    for key, value in element.attrib.items():
        key_name, _ = prefixed(key)
        attributes.append(f'{key_name}="{xml_escape(value)}"')
    opening = " ".join([name, *attributes])
    inner = xml_escape(element.text.strip()) if element.text and element.text.strip() else ""
    inner += "".join(serialize(item) for item in element)
    return f"<{opening}>{inner}</{name}>"


def xml_escape(value: str) -> str:
    """Escape the characters that are special in XML text and attribute values.

    Args:
        value: Text to escape.

    Returns:
        The escaped text.
    """
    return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")
