package uz.smartsurveillance.tv.v380

import java.util.Random
import javax.crypto.Cipher
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class CryptoTest {
    private class Case(val password: String, val key: String, val c1: String, val field: String)

    private val cases = listOf(
        Case(
            "secret123",
            "ABCDEFGHIJKLMNOP",
            "877a073e728a8f2612a3d537c9058acf b70716297df9c38a4afd38f7ee8e96d2 b70716297df9c38a4afd38f7ee8e96d2",
            "4142434445464748494a4b4c4d4e4f50 2b82c0e2ca5512945596ae4038203fdb " +
                "6a39ed52bf5232bf033df604f4f0aa9c 6a39ed52bf5232bf033df604f4f0aa9c",
        ),
        Case(
            "admin",
            "0123456789abcdef",
            "cc07381ec8f7df462a4aeb239f5b4098 b70716297df9c38a4afd38f7ee8e96d2 b70716297df9c38a4afd38f7ee8e96d2",
            "30313233343536373839616263646566 5c62f757b324ba63585f8280c2b3a94d " +
                "38a32a3a630f686211ccbf9620cdbbe9 38a32a3a630f686211ccbf9620cdbbe9",
        ),
        Case(
            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV",
            "ZYXWVUTSRQPONMLK",
            "63713533828428669313915490a4ce80 095115bd6eda15f19a07c3f7f42284fe 455bfba38d23911333505c1eed90d58d",
            "5a595857565554535251504f4e4d4c4b 512e4b40a9bd9aadfc0ad8a9fb40a4f5 " +
                "31c3cedaf4479788f9586992e2d02dda 99e4098bbcaf79e051ae083a211fb1ee",
        ),
        Case(
            "",
            "AAAAAAAAAAAAAAAA",
            "b70716297df9c38a4afd38f7ee8e96d2 b70716297df9c38a4afd38f7ee8e96d2 b70716297df9c38a4afd38f7ee8e96d2",
            "41414141414141414141414141414141 6cf3947b67385773ea780edef355f4b3 " +
                "6cf3947b67385773ea780edef355f4b3 6cf3947b67385773ea780edef355f4b3",
        ),
    )

    @Test
    fun passwordFieldsMatchTheVectors() {
        for (case in cases) {
            val key = case.key.toByteArray(Charsets.US_ASCII)
            val field = Crypto.passwordField(case.password, key)
            assertEquals(case.password, unhex(case.field).hex(), field.hex())
            val c1 = Crypto.ecb(key, Cipher.DECRYPT_MODE).doFinal(field, 16, 48)
            assertEquals(unhex(case.c1).hex(), c1.hex())
            assertEquals(case.password, Crypto.password(field))
        }
    }

    @Test
    fun longPasswordsAreTruncatedTo48Bytes() {
        val key = "ABCDEFGHIJKLMNOP".toByteArray()
        val long = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV" + "extra"
        assertArrayEquals(
            Crypto.passwordField("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV", key),
            Crypto.passwordField(long, key),
        )
    }

    @Test
    fun randomKeysUseLettersAndDigitsOnly() {
        val random = Random(7)
        repeat(200) {
            val key = Crypto.randomKey(random)
            assertEquals(16, key.size)
            assertTrue(key.all { it.toInt().toChar().isLetterOrDigit() && it.toInt() < 128 })
        }
    }

    @Test
    fun mediaKeysMatchTheVectors() {
        assertEquals("785634125c79142c46238161f00d8082", Crypto.mediaKey(0x12345678).hex())
        assertEquals("0df0ad0b5c79142c46238161f00d8082", Crypto.mediaKey(0x0badf00d).hex())
        assertEquals("000000005c79142c46238161f00d8082", Crypto.mediaKey(0).hex())
        assertEquals("ffffffff5c79142c46238161f00d8082", Crypto.mediaKey(0xffffffffL).hex())
    }

    @Test
    fun videoDecryptionFollowsTheEightyBytePattern() {
        val encrypted = unhex(
            "ff728780baf02cca26d107363b385c78 70179b658490fa69b6cb09b4c04a48a7 " +
                "bcddff2eb0b0c152743213be149741f1 36367ec8e4224aeb78f9b5583d9b86e0 " +
                "404142434445464748494a4b4c4d4e4f 37c452ec603e6187e0aa3c2768503c66 " +
                "fb962a7798c25cf10ead516fd9d6f15e 6bf4a4cef08dc118ea041849f0dbc0d4 " +
                "c21ce25944f5aa598b3bd0decdef49eb 909192939495",
        )
        val cipher = MediaCipher(Crypto.mediaKey(0x0badf00d), 20)
        val plain = encrypted.copyOf()
        cipher.video(plain)
        assertEquals(counting(150).hex(), plain.hex())
        val again = counting(150)
        cipher.encryptVideo(again)
        assertEquals(encrypted.hex(), again.hex())
    }

    @Test
    fun audioAndVersion21VideoDecryptInWholeBlocks() {
        val encrypted = unhex(
            "ff728780baf02cca26d107363b385c78 70179b658490fa69b6cb09b4c04a48a7 2021222324252627",
        )
        val audio = encrypted.copyOf()
        MediaCipher(Crypto.mediaKey(0x0badf00d), 20).audio(audio)
        assertEquals(counting(40).hex(), audio.hex())
        val video = encrypted.copyOf()
        MediaCipher(Crypto.mediaKey(0x0badf00d), 21).video(video)
        assertEquals(counting(40).hex(), video.hex())
    }

    @Test
    fun shortVideoPayloadsStayClear() {
        val payload = counting(63)
        MediaCipher(Crypto.mediaKey(0x0badf00d), 20).video(payload)
        assertEquals(counting(63).hex(), payload.hex())
    }

    @Test
    fun oldDevicesSendMediaInTheClear() {
        val payload = counting(150)
        MediaCipher.forSession(30, 20, 0x0badf00d).video(payload)
        assertEquals(counting(150).hex(), payload.hex())
    }
}
