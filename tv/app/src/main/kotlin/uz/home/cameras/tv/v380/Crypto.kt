package uz.home.cameras.tv.v380

import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.spec.SecretKeySpec

object Crypto {
    private const val STATIC_KEY = "macrovideo+*#!^@"
    private const val ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    private val random = SecureRandom()

    fun randomKey(): ByteArray = ByteArray(16) { ALPHABET[random.nextInt(ALPHABET.length)].code.toByte() }

    fun password(password: String, randomKey: ByteArray = randomKey()): ByteArray {
        val padded = ByteArray(48)
        val bytes = password.toByteArray(Charsets.US_ASCII)
        bytes.copyInto(padded, 0, 0, minOf(bytes.size, 48))
        val once = cipher(Cipher.ENCRYPT_MODE, STATIC_KEY.toByteArray(Charsets.US_ASCII)).doFinal(padded)
        val twice = cipher(Cipher.ENCRYPT_MODE, randomKey).doFinal(once)
        return randomKey + twice
    }

    fun mediaKey(ticket: Long): ByteArray {
        val key = ByteArray(16)
        key.put32(0, ticket)
        key.put64(4, 0x618123462c14795cL)
        key.put32(12, 0x82800df0L)
        return key
    }

    fun decryptor(key: ByteArray): Cipher = cipher(Cipher.DECRYPT_MODE, key)

    fun encryptor(key: ByteArray): Cipher = cipher(Cipher.ENCRYPT_MODE, key)

    fun decryptVideo(cipher: Cipher, data: ByteArray, offset: Int, length: Int) {
        val blocks = if (length < 64) 0 else (length - 64) / 80 + 1
        if (blocks == 0) return
        val packed = ByteArray(blocks * 64)
        for (i in 0 until blocks) data.copyInto(packed, i * 64, offset + i * 80, offset + i * 80 + 64)
        cipher.doFinal(packed, 0, packed.size, packed, 0)
        for (i in 0 until blocks) packed.copyInto(data, offset + i * 80, i * 64, i * 64 + 64)
    }

    fun decryptAligned(cipher: Cipher, data: ByteArray, offset: Int, length: Int) {
        val aligned = length / 16 * 16
        if (aligned > 0) cipher.doFinal(data, offset, aligned, data, offset)
    }

    private fun cipher(mode: Int, key: ByteArray): Cipher =
        Cipher.getInstance("AES/ECB/NoPadding").apply { init(mode, SecretKeySpec(key, "AES")) }
}
