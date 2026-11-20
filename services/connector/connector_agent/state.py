"""The agent's state on disk: its pairing credentials and the cameras with their encrypted credentials."""

import base64
import hashlib
import json
import os
import threading
from dataclasses import asdict, dataclass, field
from pathlib import Path

from cryptography.fernet import Fernet, InvalidToken

__all__ = ["CameraEntry", "Credentials", "Pairing", "Store", "fernet_for"]

KEY_FILE = "key"
STATE_FILE = "state.json"
CAMERAS_FILE = "cameras.json"


def fernet_for(state_dir: Path, secret: str) -> Fernet:
    """Build the cipher of the store.

    Args:
        state_dir: State folder.
        secret: Text to derive the key from; empty uses a key file in the state folder, created on first use.

    Returns:
        The cipher.
    """
    if secret:
        return Fernet(base64.urlsafe_b64encode(hashlib.sha256(secret.encode()).digest()))
    path = state_dir / KEY_FILE
    if not path.exists():
        state_dir.mkdir(parents=True, exist_ok=True)
        descriptor = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(descriptor, "wb") as handle:
            handle.write(Fernet.generate_key())
    return Fernet(path.read_bytes().strip())


@dataclass
class Pairing:
    """What the connector received when it was paired.

    Attributes:
        connector: Public id of the connector.
        site: Public id of its site.
        organisation: Public id of the organisation.
        token: Token for the connector's calls to the backend.
        agent_key: Key central sends on its calls to the agent.
        stream_username: RTSP user central signs in to go2rtc with.
        stream_password: Its password.
        heartbeat_interval: Seconds between heartbeats.
    """

    connector: str
    site: str
    organisation: str
    token: str
    agent_key: str
    stream_username: str
    stream_password: str
    heartbeat_interval: int = 30


@dataclass
class Credentials:
    """Secrets of a camera, kept only on the connector.

    Attributes:
        username: Camera login.
        password: Camera password.
        device_id: Device id of a V380 camera.
    """

    username: str | None = None
    password: str | None = None
    device_id: str | None = None


@dataclass
class CameraEntry:
    """A camera the connector serves.

    Attributes:
        uuid: Camera id; go2rtc names its streams by it.
        name: Display name.
        brand: Adapter name.
        host: Address on the site's network, or of the bridge that speaks for it.
        rtsp_port: RTSP port.
        onvif_port: Control port, if any.
        main_path: Main stream path.
        sub_path: Sub stream path, if any.
        enabled: Whether to stream it.
        channel: Channel of the camera on its device, which PTZ addresses.
        credentials: Its secrets.
    """

    uuid: str
    name: str
    brand: str
    host: str
    rtsp_port: int
    onvif_port: int | None
    main_path: str
    sub_path: str | None
    enabled: bool = True
    channel: int = 1
    credentials: Credentials = field(default_factory=Credentials)


class Store:
    """Reads and writes the state files, encrypting every secret.

    Attributes:
        directory: State folder.
        cipher: Cipher of the secrets.
        lock: Lock serialising writes.
    """

    def __init__(self, directory: str, secret: str = ""):
        """Open the store, creating its folder and key when needed.

        Args:
            directory: State folder.
            secret: Text the key is derived from; empty keeps a key file.
        """
        self.directory = Path(directory)
        self.directory.mkdir(parents=True, exist_ok=True)
        self.cipher = fernet_for(self.directory, secret)
        self.lock = threading.Lock()

    def seal(self, value: dict) -> str:
        """Encrypt a mapping.

        Args:
            value: The mapping.

        Returns:
            The token text.
        """
        return self.cipher.encrypt(json.dumps(value).encode()).decode()

    def unseal(self, token: str) -> dict:
        """Decrypt a mapping.

        Args:
            token: The token text.

        Returns:
            The mapping, empty when the key no longer fits.
        """
        try:
            return json.loads(self.cipher.decrypt(token.encode()))
        except (InvalidToken, ValueError):
            return {}

    def write(self, name: str, data) -> None:
        """Write a state file atomically with owner-only permissions.

        Args:
            name: File name.
            data: JSON data.
        """
        path = self.directory / name
        temporary = path.with_suffix(".tmp")
        descriptor = os.open(temporary, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
        with os.fdopen(descriptor, "w") as handle:
            json.dump(data, handle, indent=2)
        os.replace(temporary, path)

    def read(self, name: str, default):
        """Read a state file.

        Args:
            name: File name.
            default: Value when the file is missing or unreadable.

        Returns:
            The JSON data.
        """
        try:
            return json.loads((self.directory / name).read_text())
        except (OSError, ValueError):
            return default

    def pairing(self) -> Pairing | None:
        """Load the pairing.

        Returns:
            The pairing, or None while the connector is not paired.
        """
        data = self.read(STATE_FILE, {})
        if not data.get("sealed"):
            return None
        try:
            return Pairing(**self.unseal(data["sealed"]))
        except TypeError:
            return None

    def save_pairing(self, pairing: Pairing | None) -> None:
        """Store or forget the pairing.

        Args:
            pairing: The pairing, or None to forget it.
        """
        with self.lock:
            self.write(STATE_FILE, {"sealed": self.seal(asdict(pairing))} if pairing else {})

    def cameras(self) -> dict[str, CameraEntry]:
        """Load the cameras.

        Returns:
            Camera id to camera, with decrypted credentials.
        """
        result = {}
        for item in self.read(CAMERAS_FILE, []):
            secret = Credentials(**(self.unseal(item.pop("sealed", "")) or {}))
            try:
                result[item["uuid"]] = CameraEntry(**item, credentials=secret)
            except TypeError:
                continue
        return result

    def save_cameras(self, cameras: dict[str, CameraEntry]) -> None:
        """Store the cameras, sealing their credentials.

        Args:
            cameras: Camera id to camera.
        """
        rows = []
        for camera in cameras.values():
            row = asdict(camera)
            row["sealed"] = self.seal(row.pop("credentials"))
            rows.append(row)
        with self.lock:
            self.write(CAMERAS_FILE, rows)
