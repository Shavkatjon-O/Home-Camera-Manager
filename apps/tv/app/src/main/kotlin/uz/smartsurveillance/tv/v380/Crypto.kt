package uz.smartsurveillance.tv.v380

import java.security.SecureRandom
import java.util.Random
import javax.crypto.Cipher
import javax.crypto.spec.SecretKeySpec

/** The password field of the login and the media encryption. */
object Crypto {
    /** Size of the encrypted password field. */
    const val PASSWORD_FIELD_SIZE = 64

    /** Bytes of the password that are sent; longer passwords are truncated. */
    const val PASSWORD_SIZE = 48

    private const val BLOCK = 16
    private val PRINTABLE = 0x20..0x7E
    private const val ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

    private val FIXED_KEY = "macrovideo+*#!^@".toByteArray(Charsets.US_ASCII)
    private val MEDIA_KEY_TAIL = unhex("5c79142c46238161f00d8082")
    private val strong = SecureRandom()

    /**
     * Draws a 16-byte random key of letters and digits.
     *
     * @param random Source of randomness; a cryptographically strong one by default.
     */
    fun randomKey(random: Random = strong): ByteArray =
        ByteArray(BLOCK) { ALPHABET[random.nextInt(ALPHABET.length)].code.toByte() }

    /**
     * Encrypts a password into the 64-byte field of the login request.
     *
     * @param password The password, printable ASCII; its bytes are truncated or zero padded to 48 bytes.
     * @param randomKey The 16-byte key of letters and digits that is sent in the clear before the ciphertext.
     * @throws IllegalArgumentException The password is not printable ASCII.
     */
    fun passwordField(password: String, randomKey: ByteArray): ByteArray {
        require(randomKey.size == BLOCK) { "The random key is 16 bytes" }
        require(printable(password)) { "A V380 password must be printable ASCII" }
        val plain = ByteArray(PASSWORD_SIZE)
        val bytes = password.toByteArray(Charsets.US_ASCII)
        bytes.copyInto(plain, 0, 0, minOf(bytes.size, PASSWORD_SIZE))
        val once = ecb(FIXED_KEY, Cipher.ENCRYPT_MODE).doFinal(plain)
        val twice = ecb(randomKey, Cipher.ENCRYPT_MODE).doFinal(once)
        return randomKey + twice
    }

    /**
     * Tells whether a password can be sent: every character is printable ASCII.
     *
     * @param password The password.
     */
    fun printable(password: String): Boolean = password.all { it.code in PRINTABLE }

    /**
     * Recovers the password from a password field, as a camera does.
     *
     * @param field The 64-byte field.
     * @return The password without its zero padding.
     */
    fun password(field: ByteArray): String {
        require(field.size == PASSWORD_FIELD_SIZE) { "The password field is 64 bytes" }
        val once = ecb(field.copyOfRange(0, BLOCK), Cipher.DECRYPT_MODE).doFinal(field, BLOCK, PASSWORD_SIZE)
        val plain = ecb(FIXED_KEY, Cipher.DECRYPT_MODE).doFinal(once)
        val end = plain.indexOfFirst { it.toInt() == 0 }.let { if (it < 0) plain.size else it }
        return String(plain, 0, end, Charsets.US_ASCII)
    }

    /**
     * Derives the media key from a login ticket.
     *
     * @param ticket The ticket as an unsigned 32-bit value.
     */
    fun mediaKey(ticket: Long): ByteArray {
        val key = ByteArray(BLOCK)
        key.put32(0, ticket)
        MEDIA_KEY_TAIL.copyInto(key, 4)
        return key
    }

    /** Creates an AES-128 cipher in ECB mode without padding. */
    internal fun ecb(key: ByteArray, mode: Int): Cipher =
        Cipher.getInstance("AES/ECB/NoPadding").apply { init(mode, SecretKeySpec(key, "AES")) }
}

/**
 * Decrypts or encrypts media payloads of one session.
 *
 * @param key The media key of the session's ticket, or null when the media is sent in the clear.
 * @param communicationVersion Communication version from the stream login reply.
 */
class MediaCipher(key: ByteArray?, private val communicationVersion: Int) {
    private val decrypt = key?.let { Crypto.ecb(it, Cipher.DECRYPT_MODE) }
    private val encrypt = key?.let { Crypto.ecb(it, Cipher.ENCRYPT_MODE) }

    /** Decrypts a video payload in place, following the communication version. */
    fun video(payload: ByteArray, offset: Int = 0, length: Int = payload.size - offset) =
        apply(decrypt, payload, offset, length, video = true)

    /** Decrypts an audio payload in place. */
    fun audio(payload: ByteArray, offset: Int = 0, length: Int = payload.size - offset) =
        apply(decrypt, payload, offset, length, video = false)

    /** Encrypts a video payload in place, as a camera does. */
    fun encryptVideo(payload: ByteArray, offset: Int = 0, length: Int = payload.size - offset) =
        apply(encrypt, payload, offset, length, video = true)

    /** Encrypts an audio payload in place, as a camera does. */
    fun encryptAudio(payload: ByteArray, offset: Int = 0, length: Int = payload.size - offset) =
        apply(encrypt, payload, offset, length, video = false)

    private fun apply(cipher: Cipher?, data: ByteArray, offset: Int, length: Int, video: Boolean) {
        if (cipher == null) return
        if (video && communicationVersion != WHOLE_BLOCK_VERSION) {
            var at = 0
            while (length - at >= RUN) {
                cipher.doFinal(data, offset + at, RUN, data, offset + at)
                at += PERIOD
            }
        } else {
            val whole = length / BLOCK * BLOCK
            if (whole > 0) cipher.doFinal(data, offset, whole, data, offset)
        }
    }

    /** Session constants. */
    companion object {
        /** Device versions above this one encrypt their media. */
        const val CLEAR_UP_TO_DEVICE_VERSION = 30

        /** Communication version that decrypts video in whole blocks. */
        const val WHOLE_BLOCK_VERSION = 21

        private const val BLOCK = 16
        private const val RUN = 64
        private const val PERIOD = 80

        /** Builds the cipher a session with these versions and ticket needs. */
        fun forSession(deviceVersion: Int, communicationVersion: Int, ticket: Long): MediaCipher =
            MediaCipher(
                if (deviceVersion > CLEAR_UP_TO_DEVICE_VERSION) Crypto.mediaKey(ticket) else null,
                communicationVersion,
            )
    }
}
