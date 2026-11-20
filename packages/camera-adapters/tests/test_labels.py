from camera_adapters.ezviz.labels import parse_ezviz_label
from camera_adapters.registry import Registry
from camera_adapters.v380.labels import parse_v380_label


def test_an_ezviz_label_with_lines_is_read_in_any_order():
    label = parse_ezviz_label("ABCDEF\r\nCS-C6N-A0-1C2WFR\r\nE12345678")
    assert (label.serial, label.code, label.model) == ("E12345678", "ABCDEF", "CS-C6N-A0-1C2WFR")
    assert label.adapter == "ezviz" and not label.confirmed


def test_an_ezviz_label_as_link_parameters_is_read():
    label = parse_ezviz_label("https://example.invalid/device?serial=e12345678&code=ABCDEF")
    assert (label.serial, label.code) == ("E12345678", "ABCDEF")


def test_a_text_without_serial_and_code_is_not_an_ezviz_label():
    assert parse_ezviz_label("ABCDEF") is None
    assert parse_ezviz_label("E12345678") is None
    assert parse_ezviz_label("rtsp://192.168.1.20/live") is None


def test_a_v380_device_id_is_read():
    assert parse_v380_label("12345678").device_id == "12345678"
    assert parse_v380_label("https://v380.example.invalid/add?id=1234567890").device_id == "1234567890"
    assert parse_v380_label("V380 device 87654321").device_id == "87654321"


def test_a_v380_parser_refuses_other_links_and_numbers():
    assert parse_v380_label("https://shop.example.invalid/item?id=12345678") is None
    assert parse_v380_label("123") is None


def test_the_registry_prefers_a_confirmed_format():
    registry = Registry(plugins=False)
    assert registry.parse_label("rtsp://192.168.1.20/live").adapter == "rtsp"
    assert registry.parse_label("http://192.168.1.20/onvif/device_service").adapter == "onvif"
    assert registry.parse_label("CS-C6N-A0-1C2WFR\nE12345678\nABCDEF").adapter == "ezviz"
    assert registry.parse_label("12345678").adapter == "v380"
    assert registry.parse_label("not a label") is None
