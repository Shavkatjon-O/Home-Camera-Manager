import pytest

from adapters.classifier import guess_brand, guess_onvif_port
from adapters.sweep import SubnetError, parse_subnet
from app.modules.cameras.enums import CameraBrand


@pytest.mark.parametrize(
    ("ports", "manufacturer", "onvif_port", "brand"),
    [
        ([554, 8899], "macro-video-soft", 8899, CameraBrand.V380),
        ([554, 8800, 9800], None, None, CameraBrand.V380),
        ([80, 443, 554, 8000], None, 80, CameraBrand.EZVIZ),
        ([80, 554], "Acme", 80, CameraBrand.ONVIF),
        ([554], None, None, CameraBrand.RTSP),
        ([80, 443], None, None, None),
    ],
)
def test_brand_guess(ports, manufacturer, onvif_port, brand):
    assert guess_brand(ports, manufacturer, onvif_port) == brand


def test_onvif_port_prefers_the_answering_port_then_the_brand_default():
    assert guess_onvif_port(CameraBrand.EZVIZ, [80, 554, 8000], 8899) == 8899
    assert guess_onvif_port(CameraBrand.EZVIZ, [80, 554, 8000], None) == 80
    assert guess_onvif_port(CameraBrand.V380, [554, 8800], None) is None
    assert guess_onvif_port(None, [554], None) is None


def test_subnet_parsing():
    assert str(parse_subnet("192.168.1.0/24")) == "192.168.1.0/24"
    assert str(parse_subnet("192.168.1.17/24")) == "192.168.1.0/24"
    assert str(parse_subnet("192.168.1.237/32")) == "192.168.1.237/32"
    with pytest.raises(SubnetError) as too_large:
        parse_subnet("192.168.1.0/23")
    assert too_large.value.code == "subnet_too_large"
    with pytest.raises(SubnetError) as invalid:
        parse_subnet("not-a-subnet")
    assert invalid.value.code == "invalid_subnet"
