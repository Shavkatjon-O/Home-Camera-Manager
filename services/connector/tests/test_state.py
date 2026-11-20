import json

from connector_agent.state import CameraEntry, Credentials, Pairing, Store

PAIRING = Pairing("c", "s", "o", "token-value", "agent-key", "central", "stream-secret", 15)


def camera(uuid="00000000-0000-0000-0000-000000000001", password="camera-secret"):
    return CameraEntry(
        uuid=uuid,
        name="Gate",
        brand="onvif",
        host="192.168.1.20",
        rtsp_port=554,
        onvif_port=80,
        main_path="/main",
        sub_path=None,
        credentials=Credentials(username="admin", password=password),
    )


def test_pairing_and_cameras_round_trip_with_their_secrets_sealed(tmp_path):
    store = Store(str(tmp_path))
    store.save_pairing(PAIRING)
    store.save_cameras({"a": camera()})
    raw = (tmp_path / "state.json").read_text() + (tmp_path / "cameras.json").read_text()
    assert "token-value" not in raw and "camera-secret" not in raw and "stream-secret" not in raw
    again = Store(str(tmp_path))
    assert again.pairing() == PAIRING
    assert again.cameras()[camera().uuid].credentials.password == "camera-secret"
    assert oct((tmp_path / "key").stat().st_mode)[-3:] == "600"


def test_a_secret_derives_the_key_and_a_wrong_one_reads_nothing(tmp_path):
    Store(str(tmp_path), "one").save_pairing(PAIRING)
    assert Store(str(tmp_path), "one").pairing() == PAIRING
    assert Store(str(tmp_path), "two").pairing() is None
    assert not (tmp_path / "key").exists()


def test_forgetting_the_pairing_and_unreadable_files(tmp_path):
    store = Store(str(tmp_path))
    store.save_pairing(PAIRING)
    store.save_pairing(None)
    assert store.pairing() is None
    (tmp_path / "cameras.json").write_text(json.dumps([{"uuid": "x"}]))
    assert store.cameras() == {}
