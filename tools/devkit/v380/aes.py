"""AES-128 block encryption and decryption in plain Python, so the simulator needs only the standard library."""

__all__ = ["Aes128"]


def xtime(value: int) -> int:
    """Multiply by x in GF(2^8).

    Args:
        value: A byte.

    Returns:
        The product.
    """
    value <<= 1
    return (value ^ 0x11B) if value & 0x100 else value


def multiply(left: int, right: int) -> int:
    """Multiply two bytes in GF(2^8).

    Args:
        left: First byte.
        right: Second byte.

    Returns:
        The product.
    """
    result = 0
    while right:
        if right & 1:
            result ^= left
        left = xtime(left)
        right >>= 1
    return result


def build_boxes() -> tuple[list[int], list[int]]:
    """Compute the S-box and its inverse from the field inverse and the affine transform.

    Returns:
        The S-box and the inverse S-box.
    """
    box = [0] * 256
    for value in range(256):
        inverse = 0
        if value:
            inverse = next(candidate for candidate in range(1, 256) if multiply(value, candidate) == 1)
        result = inverse
        for shift in range(1, 5):
            result ^= ((inverse << shift) | (inverse >> (8 - shift))) & 0xFF
        box[value] = result ^ 0x63
    inverse_box = [0] * 256
    for value, substituted in enumerate(box):
        inverse_box[substituted] = value
    return box, inverse_box


SBOX, INVERSE_SBOX = build_boxes()
TIMES = {factor: [multiply(value, factor) for value in range(256)] for factor in (2, 3, 9, 11, 13, 14)}
ROUNDS = 10


class Aes128:
    """AES-128 with an expanded key, block by block as ECB mode uses it.

    Attributes:
        round_keys: The eleven 16-byte round keys.
    """

    def __init__(self, key: bytes):
        """Expand a key.

        Args:
            key: 16 bytes.

        Raises:
            ValueError: The key is not 16 bytes.
        """
        if len(key) != 16:
            raise ValueError("AES-128 needs a 16-byte key")
        words = [list(key[index : index + 4]) for index in range(0, 16, 4)]
        constant = 1
        for index in range(4, 4 * (ROUNDS + 1)):
            word = list(words[index - 1])
            if index % 4 == 0:
                word = [SBOX[byte] for byte in word[1:] + word[:1]]
                word[0] ^= constant
                constant = xtime(constant)
            words.append([a ^ b for a, b in zip(words[index - 4], word)])
        self.round_keys = [sum(words[4 * number : 4 * number + 4], []) for number in range(ROUNDS + 1)]

    def encrypt_block(self, block: bytes) -> bytes:
        """Encrypt one block.

        Args:
            block: 16 bytes.

        Returns:
            The ciphertext.
        """
        state = [a ^ b for a, b in zip(block, self.round_keys[0])]
        two, three = TIMES[2], TIMES[3]
        for number in range(1, ROUNDS + 1):
            state = [SBOX[byte] for byte in state]
            state = [state[(index + 4 * (index % 4)) % 16] for index in range(16)]
            if number != ROUNDS:
                mixed = []
                for column in range(0, 16, 4):
                    a0, a1, a2, a3 = state[column : column + 4]
                    mixed += [
                        two[a0] ^ three[a1] ^ a2 ^ a3,
                        a0 ^ two[a1] ^ three[a2] ^ a3,
                        a0 ^ a1 ^ two[a2] ^ three[a3],
                        three[a0] ^ a1 ^ a2 ^ two[a3],
                    ]
                state = mixed
            state = [a ^ b for a, b in zip(state, self.round_keys[number])]
        return bytes(state)

    def decrypt_block(self, block: bytes) -> bytes:
        """Decrypt one block.

        Args:
            block: 16 bytes.

        Returns:
            The plaintext.
        """
        state = [a ^ b for a, b in zip(block, self.round_keys[ROUNDS])]
        nine, eleven, thirteen, fourteen = TIMES[9], TIMES[11], TIMES[13], TIMES[14]
        for number in range(ROUNDS - 1, -1, -1):
            state = [state[(index - 4 * (index % 4)) % 16] for index in range(16)]
            state = [INVERSE_SBOX[byte] for byte in state]
            state = [a ^ b for a, b in zip(state, self.round_keys[number])]
            if number:
                mixed = []
                for column in range(0, 16, 4):
                    a0, a1, a2, a3 = state[column : column + 4]
                    mixed += [
                        fourteen[a0] ^ eleven[a1] ^ thirteen[a2] ^ nine[a3],
                        nine[a0] ^ fourteen[a1] ^ eleven[a2] ^ thirteen[a3],
                        thirteen[a0] ^ nine[a1] ^ fourteen[a2] ^ eleven[a3],
                        eleven[a0] ^ thirteen[a1] ^ nine[a2] ^ fourteen[a3],
                    ]
                state = mixed
        return bytes(state)

    def encrypt(self, data: bytes) -> bytes:
        """Encrypt whole blocks one by one.

        Args:
            data: A multiple of 16 bytes.

        Returns:
            The ciphertext.
        """
        return b"".join(self.encrypt_block(data[index : index + 16]) for index in range(0, len(data), 16))

    def decrypt(self, data: bytes) -> bytes:
        """Decrypt whole blocks one by one.

        Args:
            data: A multiple of 16 bytes.

        Returns:
            The plaintext.
        """
        return b"".join(self.decrypt_block(data[index : index + 16]) for index in range(0, len(data), 16))
