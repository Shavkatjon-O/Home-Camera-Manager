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


class OnvifError(Exception):
    pass


class OnvifFault(OnvifError):
    pass


def envelope(body: str, header: str = "") -> bytes:
    declarations = " ".join(f'xmlns:{prefix}="{uri}"' for prefix, uri in NAMESPACES.items())
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
