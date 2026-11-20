"""Password and media encryption of the V380 LAN protocol: AES-128 in ECB mode without padding."""

import secrets
import string

from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

__all__ = [
    "BLOCK",
    "FIXED_KEY",
    "KEY_ALPHABET",
    "MediaCipher",
    "decrypt_blocks",
    "encrypt_blocks",
    "media_key",
    "password_field",
    "random_key",
    "recover_password",
]

BLOCK = 16
FIXED_KEY = b"macrovideo+*#!^@"
KEY_ALPHABET = string.ascii_letters + string.digits
MEDIA_KEY_TAIL = bytes.fromhex("5c79142c46238161f00d8082")

PASSWORD_SIZE = 48
FIELD_SIZE = 64

VIDEO_RUN = 64
VIDEO_PERIOD = 80
WHOLE_BLOCK_VERSION = 21


def encrypt_blocks(key: bytes, data: bytes) -> bytes:
    """Encrypt whole AES blocks.

    Args:
        key: 16-byte key.
        data: Data whose length is a multiple of 16.

    Returns:
        The ciphertext.
    """
    encryptor = Cipher(algorithms.AES(key), modes.ECB()).encryptor()
    return encryptor.update(data) + encryptor.finalize()


def decrypt_blocks(key: bytes, data: bytes) -> bytes:
    """Decrypt whole AES blocks.

    Args:
        key: 16-byte key.
        data: Data whose length is a multiple of 16.

    Returns:
        The plaintext.
    """
    decryptor = Cipher(algorithms.AES(key), modes.ECB()).decryptor()
    return decryptor.update(data) + decryptor.finalize()


def random_key() -> bytes:
    """Draw the per-login random key: 16 letters and digits from a strong source.

    Returns:
        The key as ASCII bytes.
    """
    return "".join(secrets.choice(KEY_ALPHABET) for _ in range(BLOCK)).encode("ascii")


def password_field(password: str, key: bytes | None = None) -> bytes:
    """Build the 64-byte encrypted password field of the login request.

    Args:
        password: The camera password, printable ASCII; longer than 48 bytes is truncated.
        key: The random key, drawn fresh when omitted; tests pass a fixed one.

    Returns:
        The random key followed by the password encrypted with the fixed key and then with the random key.

    Raises:
        ValueError: The password is not printable ASCII, or the key is not 16 letters and digits.
    """
    if any(not 0x20 <= ord(char) <= 0x7E for char in password):
        raise ValueError("A V380 password must be printable ASCII")
    key = random_key() if key is None else key
    if len(key) != BLOCK or any(chr(byte) not in KEY_ALPHABET for byte in key):
        raise ValueError("The random key must be 16 letters and digits")
    plain = password.encode("ascii")[:PASSWORD_SIZE].ljust(PASSWORD_SIZE, b"\0")
    return key + encrypt_blocks(key, encrypt_blocks(FIXED_KEY, plain))


def recover_password(field: bytes) -> bytes:
    """Decrypt a password field the way the camera does.

    Args:
        field: The 64-byte field.

    Returns:
        The 48-byte zero-padded password.
    """
    key = field[:BLOCK]
    return decrypt_blocks(FIXED_KEY, decrypt_blocks(key, field[BLOCK:FIELD_SIZE]))


def media_key(ticket: int) -> bytes:
    """Derive the media key from the login ticket.

    Args:
        ticket: Ticket of the login reply.

    Returns:
        The ticket's four little-endian bytes followed by twelve fixed bytes.
    """
    return (ticket & 0xFFFFFFFF).to_bytes(4, "little") + MEDIA_KEY_TAIL


class MediaCipher:
    """Decrypts and encrypts the media payloads of one session.

    Attributes:
        key: The media key.
        comm_version: Communication version from the stream login reply.
    """

    def __init__(self, key: bytes, comm_version: int = 0):
        """Bind the cipher to a session.

        Args:
            key: The media key.
            comm_version: Communication version; 21 switches video to whole blocks.
        """
        self.key = key
        self.comm_version = comm_version
        self.decryptor = Cipher(algorithms.AES(key), modes.ECB()).decryptor()
        self.encryptor = Cipher(algorithms.AES(key), modes.ECB()).encryptor()

    def whole(self, payload: bytes, decrypt: bool) -> bytes:
        """Process the leading whole blocks of a payload and keep the tail.

        Args:
            payload: The payload.
            decrypt: Whether to decrypt rather than encrypt.

        Returns:
            The processed payload.
        """
        size = len(payload) // BLOCK * BLOCK
        engine = self.decryptor if decrypt else self.encryptor
        return engine.update(payload[:size]) + payload[size:]

    def pattern(self, payload: bytes, decrypt: bool) -> bytes:
        """Process the 64-byte runs at every 80-byte period of a video payload.

        Args:
            payload: The payload.
            decrypt: Whether to decrypt rather than encrypt.

        Returns:
            The processed payload.
        """
        engine = self.decryptor if decrypt else self.encryptor
        out = bytearray(payload)
        offset = 0
        while len(payload) - offset >= VIDEO_RUN:
            out[offset : offset + VIDEO_RUN] = engine.update(payload[offset : offset + VIDEO_RUN])
            offset += VIDEO_PERIOD
        return bytes(out)

    def decrypt_video(self, payload: bytes) -> bytes:
        """Decrypt a video payload.

        Args:
            payload: Media payload after the frame header.

        Returns:
            The plain payload.
        """
        if self.comm_version == WHOLE_BLOCK_VERSION:
            return self.whole(payload, True)
        return self.pattern(payload, True)

    def decrypt_audio(self, payload: bytes) -> bytes:
        """Decrypt an audio payload.

        Args:
            payload: Media payload after the frame header.

        Returns:
            The plain payload.
        """
        return self.whole(payload, True)

    def encrypt_video(self, payload: bytes) -> bytes:
        """Encrypt a video payload the way the camera does.

        Args:
            payload: Plain media payload.

        Returns:
            The encrypted payload.
        """
        if self.comm_version == WHOLE_BLOCK_VERSION:
            return self.whole(payload, False)
        return self.pattern(payload, False)

    def encrypt_audio(self, payload: bytes) -> bytes:
        """Encrypt an audio payload the way the camera does.

        Args:
            payload: Plain media payload.

        Returns:
            The encrypted payload.
        """
        return self.whole(payload, False)
