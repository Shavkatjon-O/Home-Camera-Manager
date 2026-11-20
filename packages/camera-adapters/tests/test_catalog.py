import pytest

from camera_adapters.base import Fingerprint
from camera_adapters.catalog import CONFIDENCE, Catalog, load_catalog, render_path


def test_the_packaged_catalog_loads_with_valid_entries():
    catalog = load_catalog()
    assert catalog.entries
    ids = [entry.id for entry in catalog.entries]
    assert len(ids) == len(set(ids))
    for entry in catalog.entries:
        assert entry.adapter in {"onvif", "ezviz", "v380", "rtsp"}
        assert entry.confidence in CONFIDENCE
        assert entry.kind in {"camera", "nvr", "dvr"}
        assert entry.urls.get("main", "").startswith("/")


def test_a_model_pattern_picks_its_entry():
    entry, score = load_catalog().best(Fingerprint(host="h", manufacturer="EZVIZ", model="CS-C6N"))
    assert entry.id == "ezviz" and score >= 90


def test_a_recorder_model_picks_the_recorder_entry():
    entry, _ = load_catalog().best(Fingerprint(host="h", manufacturer="Dahua", model="DHI-NVR4104"))
    assert entry.id == "dahua-recorder" and entry.kind == "nvr"


def test_nothing_fits_an_unknown_device():
    assert load_catalog().best(Fingerprint(host="h")) == (None, 0)


def test_path_templates_fill_the_channel():
    assert render_path("/Streaming/Channels/{channel}01", 3) == "/Streaming/Channels/301"
    assert render_path("/h264Preview_{channel02}_main", 1) == "/h264Preview_01_main"


def test_an_entry_needs_an_id_vendor_and_adapter():
    with pytest.raises(ValueError):
        Catalog.from_data({"entries": [{"id": "x", "vendor": "X"}]})
    with pytest.raises(ValueError):
        Catalog.from_data({"entries": [{"id": "x", "vendor": "X", "adapter": "onvif", "confidence": "sure"}]})
