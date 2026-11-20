import pytest
from pydantic import ValidationError

from app.core.exceptions import Unprocessable
from app.modules.cameras.enums import CameraBrand
from app.modules.cameras.schemas import CameraCreate, CameraUpdate
from app.modules.cameras.services.defaults import apply_brand_defaults


def create_values(**fields) -> dict:
    return CameraCreate(**fields).model_dump(exclude={"password"})


def test_ezviz_defaults_fill_omitted_fields():
    values = apply_brand_defaults(CameraBrand.EZVIZ, create_values(name="Hall", brand="ezviz", host="192.168.1.104"))
    assert values["onvif_port"] == 80
    assert values["username"] == "admin"
    assert values["main_path"] == "/Streaming/Channels/101"
    assert values["sub_path"] == "/Streaming/Channels/102"
    assert values["ptz_enabled"] is False


def test_explicit_values_win_over_brand_defaults():
    values = apply_brand_defaults(
        CameraBrand.EZVIZ,
        create_values(name="Hall", brand="ezviz", host="cam.local", username="viewer", main_path="Custom/1"),
    )
    assert values["username"] == "viewer"
    assert values["main_path"] == "/Custom/1"
    assert values["sub_path"] == "/Streaming/Channels/102"


def test_v380_defaults():
    values = apply_brand_defaults(CameraBrand.V380, create_values(name="Yard", brand="v380", host="192.168.1.237"))
    assert values["onvif_port"] == 8899
    assert values["main_path"] == "/live/ch00_0"
    assert values["sub_path"] == "/live/ch00_1"
    assert values["ptz_enabled"] is True
    assert values["username"] is None


def test_onvif_defaults_leave_paths_for_discovery():
    values = apply_brand_defaults(CameraBrand.ONVIF, create_values(name="Door", brand="onvif", host="192.168.1.50"))
    assert values["onvif_port"] == 80
    assert values["main_path"] is None
    assert values["ptz_enabled"] is None


def test_rtsp_requires_a_main_path():
    with pytest.raises(Unprocessable) as error:
        apply_brand_defaults(CameraBrand.RTSP, create_values(name="Gate", brand="rtsp", host="192.168.1.60"))
    assert error.value.code == "main_path_required"


def test_rtsp_with_a_main_path_has_no_ptz():
    values = apply_brand_defaults(
        CameraBrand.RTSP, create_values(name="Gate", brand="rtsp", host="192.168.1.60", main_path="/stream")
    )
    assert values["main_path"] == "/stream"
    assert values["ptz_enabled"] is False


def test_create_cleans_text_fields():
    payload = CameraCreate(name="  Hall ", brand="ezviz", host=" Camera.LOCAL ", location="", sub_path="  ")
    assert payload.name == "Hall"
    assert payload.host == "camera.local"
    assert payload.location is None
    assert payload.sub_path is None


def test_create_rejects_a_bad_host():
    with pytest.raises(ValidationError):
        CameraCreate(name="Hall", brand="ezviz", host="rtsp://192.168.1.104")


def test_update_rejects_empty_required_fields_and_allows_clearing_optional_ones():
    with pytest.raises(ValidationError):
        CameraUpdate(name=None)
    with pytest.raises(ValidationError):
        CameraUpdate(main_path="")
    update = CameraUpdate(sub_path="", username="", password="")
    assert update.sub_path is None
    assert update.username is None
    assert update.password == ""
    assert update.model_fields_set == {"sub_path", "username", "password"}
