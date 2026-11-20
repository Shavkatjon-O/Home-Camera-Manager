package uz.smartsurveillance.tv.v380

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class CryptoTest {
    @Test
    fun mediaKeyEmbedsTheTicket() {
        assertEquals("785634125c79142c46238161f00d8082", Crypto.mediaKey(0x12345678L).hex())
    }

    @Test
    fun passwordMatchesTheReferenceEncryption() {
        val random = "ABCDEFGHIJKLMNOP".toByteArray()
        val encrypted = Crypto.password("secret123", random)
        assertEquals(64, encrypted.size)
        assertArrayEquals(random, encrypted.copyOfRange(0, 16))
        assertEquals(
            "2b82c0e2ca5512945596ae4038203fdb6a39ed52bf5232bf033df604f4f0aa9c6a39ed52bf5232bf033df604f4f0aa9c",
            encrypted.copyOfRange(16, 64).hex(),
        )
    }

    @Test
    fun randomKeysAreAlphanumeric() {
        val key = Crypto.randomKey()
        assertEquals(16, key.size)
        assertTrue(key.all { it.toInt().toChar().isLetterOrDigit() })
    }

    @Test
    fun videoDecryptsSixtyFourOfEveryEightyBytes() {
        val key = Crypto.mediaKey(987654321L)
        val plain = ByteArray(250) { (it * 7).toByte() }
        val data = plain.copyOf()
        val encryptor = Crypto.encryptor(key)
        var at = 0
        while (at + 64 <= data.size) {
            encryptor.doFinal(data, at, 64, data, at)
            at += 80
        }
        assertTrue(!data.copyOfRange(0, 64).contentEquals(plain.copyOfRange(0, 64)))
        assertArrayEquals(plain.copyOfRange(64, 80), data.copyOfRange(64, 80))
        Crypto.decryptVideo(Crypto.decryptor(key), data, 0, data.size)
        assertArrayEquals(plain, data)
    }

    @Test
    fun alignedDecryptLeavesTheTail() {
        val key = Crypto.mediaKey(42L)
        val plain = ByteArray(263) { it.toByte() }
        val data = plain.copyOf()
        Crypto.encryptor(key).doFinal(data, 0, 256, data, 0)
        Crypto.decryptAligned(Crypto.decryptor(key), data, 0, data.size)
        assertArrayEquals(plain, data)
    }
}
