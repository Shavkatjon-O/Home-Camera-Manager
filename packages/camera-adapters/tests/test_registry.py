import pytest

from camera_adapters import registry as registry_module
from camera_adapters.base import Adapter, AdapterError, Fingerprint, Identity, Streams, Target
from camera_adapters.manifest import CapabilityManifest
from camera_adapters.registry import Registry


class FakeAdapter(Adapter):
    name = "fake"
    priority = 5

    def __init__(self, error=None):
        self.error = error
        self.calls = 0

    def match(self, fingerprint, hints=None):
        return 100 if 9999 in fingerprint.open_ports else 0

    async def identify(self, target):
        self.calls += 1
        if self.error:
            raise AdapterError(self.error, "nope")
        return Identity(adapter=self.name)

    async def streams(self, target, channel=1):
        return Streams(main="/x")

    def manifest(self, identity=None, **known):
        return CapabilityManifest(adapter=self.name)


def test_fingerprints_resolve_to_their_adapters():
    registry = Registry(plugins=False)
    assert registry.resolve(Fingerprint(host="h", open_ports=(554, 8800), v380=True)).adapter.name == "v380"
    assert registry.resolve(Fingerprint(host="h", open_ports=(80, 554, 8000))).adapter.name == "ezviz"
    assert registry.resolve(Fingerprint(host="h", open_ports=(80, 554), onvif_port=80)).adapter.name == "onvif"
    assert registry.resolve(Fingerprint(host="h", open_ports=(554,))).adapter.name == "rtsp"
    assert registry.resolve(Fingerprint(host="h")).adapter.name == "rtsp"


def test_a_catalog_match_lifts_the_vendor_adapter():
    registry = Registry(plugins=False)
    ranked = registry.rank(
        Fingerprint(host="h", open_ports=(80, 554), onvif_port=80, manufacturer="EZVIZ", model="CS-C6N")
    )
    assert ranked[0].adapter.name == "ezviz" and ranked[0].entry.id == "ezviz"


async def test_identify_stops_at_a_refused_login():
    refusing = FakeAdapter(error="unauthorized")
    registry = Registry(adapters=[refusing, *registry_module.builtin_adapters()], plugins=False)
    with pytest.raises(AdapterError) as caught:
        await registry.identify(Target(host="h"), Fingerprint(host="h", open_ports=(9999,)))
    assert caught.value.code == "unauthorized" and refusing.calls == 1


async def test_identify_moves_on_after_other_failures():
    failing = FakeAdapter(error="no_stream")
    working = FakeAdapter()
    working.name = "fake-two"
    working.priority = 1
    registry = Registry(adapters=[failing, working], plugins=False)
    identity, resolution = await registry.identify(Target(host="h"), Fingerprint(host="h", open_ports=(9999,)))
    assert identity.adapter == "fake-two" and resolution.adapter is working and failing.calls == 1


def test_plugins_load_from_entry_points(monkeypatch):
    class Point:
        def __init__(self, name, loaded):
            self.name = name
            self.loaded = loaded

        def load(self):
            return self.loaded

    points = [Point("fake", FakeAdapter), Point("clash", lambda: registry_module.OnvifAdapter()), Point("broken", 3)]
    monkeypatch.setattr(registry_module, "entry_points", lambda group: points)
    registry = Registry()
    assert "fake" in registry.adapters and list(registry.adapters).count("onvif") == 1


def test_an_unknown_adapter_is_refused():
    with pytest.raises(AdapterError):
        Registry(plugins=False).get("nope")
