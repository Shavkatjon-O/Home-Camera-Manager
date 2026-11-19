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
    pass


class OnvifFault(OnvifError):
    pass


class OnvifRefused(OnvifError):
    pass


def envelope(body: str, header: str = "") -> bytes:
    used = {prefix: uri for prefix, uri in EXTRA_NAMESPACES.items() if f"<{prefix}:" in body or f"<{prefix}:" in header}
    declarations = " ".join(f'xmlns:{prefix}="{uri}"' for prefix, uri in (NAMESPACES | used).items())
    head = f"<s:Header>{header}</s:Header>" if header else ""
    document = f"<s:Envelope {declarations}>{head}<s:Body>{body}</s:Body></s:Envelope>"
    return f'<?xml version="1.0" encoding="UTF-8"?>{document}'.encode()


def local_name(tag: str) -> str:
    return tag.rsplit("}", 1)[-1]


def child(element: Element | None, name: str) -> Element | None:
    if element is None:
        return None
    for item in element:
        if local_name(item.tag) == name:
            return item
    return None


def children(element: Element | None, name: str) -> list[Element]:
    if element is None:
        return []
    return [item for item in element if local_name(item.tag) == name]


def descendant(element: Element | None, name: str) -> Element | None:
    if element is None:
        return None
    for item in element.iter():
        if item is not element and local_name(item.tag) == name:
            return item
    return None


def descendants(element: Element | None, name: str) -> list[Element]:
    if element is None:
        return []
    return [item for item in element.iter() if item is not element and local_name(item.tag) == name]


def text(element: Element | None) -> str | None:
    if element is None or element.text is None:
        return None
    value = element.text.strip()
    return value or None


def descendant_text(element: Element | None, name: str) -> str | None:
    return text(descendant(element, name))


def fault_message(fault: Element) -> str:
    reason = descendant_text(fault, "Text") or descendant_text(fault, "faultstring")
    if reason:
        return reason
    codes = [text(item) for item in descendants(fault, "Value")]
    codes = [code for code in codes if code]
    if codes:
        return codes[-1]
    return "The device returned a SOAP fault"


def parse_response(content: bytes, status_code: int) -> Element:
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
    if not tag.startswith("{"):
        return tag, None
    uri, _, name = tag[1:].partition("}")
    for prefix, known in (NAMESPACES | EXTRA_NAMESPACES).items():
        if known == uri:
            return f"{prefix}:{name}", None
    return f"x:{name}", uri


def serialize(element: Element) -> str:
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
    return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")
