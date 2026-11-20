package uz.smartsurveillance.tv.v380

import java.io.ByteArrayOutputStream
import java.io.DataInputStream
import java.io.InputStream
import java.net.InetAddress
import java.net.ServerSocket
import java.net.Socket
import java.util.Collections
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import kotlin.concurrent.thread
import org.junit.After
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test

class ClientTest {
    private class FakeCamera(
        val loginResult: Int = 1001,
        val streamResult: Int = 1001,
        val splitReply: Boolean = false,
        val garbageBefore: Int = 0,
        val media: Boolean = true,
        val cutAfter: Int = -1,
    ) {
        val server = ServerSocket(0, 4, InetAddress.getLoopbackAddress())
        val controls: MutableList<String> = Collections.synchronizedList(ArrayList())
        val passwords: MutableList<String> = Collections.synchronizedList(ArrayList())
        val keys: MutableList<ByteArray> = Collections.synchronizedList(ArrayList())
        val streamLogins: MutableList<ByteArray> = Collections.synchronizedList(ArrayList())
        val ended = CountDownLatch(1)
        val worker = thread(isDaemon = true) { serve() }

        val port: Int get() = server.localPort

        private fun readExactly(input: InputStream, count: Int): ByteArray {
            val out = ByteArray(count)
            DataInputStream(input).readFully(out)
            return out
        }

        private fun serve() {
            try {
                server.accept().use { login ->
                    val request = readExactly(login.getInputStream(), Records.LOGIN_SIZE)
                    val field = request.copyOfRange(81, 145)
                    keys += field.copyOfRange(0, 16)
                    passwords += Crypto.password(field)
                    val reply = ByteArray(256)
                    reply.put32(0, 1168)
                    reply.put32(4, loginResult.toLong())
                    reply.put8(12, Transcript.DEVICE_VERSION)
                    reply.put32(13, Transcript.TICKET)
                    login.getOutputStream().write(reply)
                    login.getInputStream().read()
                }
                if (loginResult != 1001) return
                server.accept().use { stream -> stream(stream) }
            } catch (_: Exception) {
            } finally {
                ended.countDown()
            }
        }

        private fun stream(socket: Socket) {
            val input = socket.getInputStream()
            val output = socket.getOutputStream()
            streamLogins += readExactly(input, 256)
            val reply = ByteArray(32)
            reply.put32(0, 401)
            reply.put32(4, streamResult.toLong())
            reply.put16(8, Transcript.COMMUNICATION_VERSION)
            reply.put32(10, 640)
            reply.put32(14, 720)
            if (splitReply) {
                output.write(reply, 0, 10)
                output.flush()
                Thread.sleep(100)
                output.write(reply, 10, 22)
            } else {
                output.write(reply)
            }
            output.flush()
            if (streamResult == -11) {
                input.read()
                return
            }
            readExactly(input, 256)
            if (media) {
                val bytes = ByteArray(garbageBefore) { 0x7F } + Transcript.media()
                if (cutAfter >= 0) {
                    output.write(bytes, 0, cutAfter)
                    output.flush()
                    return
                }
                output.write(bytes)
                output.flush()
            }
            while (true) {
                val record = ByteArray(16)
                var at = 0
                while (at < 16) {
                    val read = input.read(record, at, 16 - at)
                    if (read < 0) return
                    at += read
                }
                controls += record.hex()
            }
        }

        fun close() {
            runCatching { server.close() }
        }
    }

    private class Recorder : V380Client.Listener {
        val video = ByteArrayOutputStream()
        val keys = ArrayList<Boolean>()
        val audio = LinkedHashMap<Int, ByteArray>()
        var session: SessionFacts? = null
        var codec: Codec? = null
        val done = CountDownLatch(5)

        override fun onSession(facts: SessionFacts) {
            session = facts
        }

        override fun onVideo(codec: Codec, data: ByteArray, key: Boolean) {
            this.codec = codec
            video.write(data)
            keys += key
            done.countDown()
        }

        override fun onAudio(type: Int, payload: ByteArray) {
            audio[type] = payload
            done.countDown()
        }
    }

    private val cameras = ArrayList<FakeCamera>()

    @After
    fun closeCameras() = cameras.forEach { it.close() }

    private fun camera(fake: FakeCamera) = fake.also { cameras += it }

    private fun config(port: Int, password: String = Transcript.PASSWORD, silenceMs: Int = 15000) = V380Client.Config(
        host = "127.0.0.1",
        port = port,
        deviceId = Transcript.DEVICE_ID,
        password = password,
        stream = StreamKind.Sub,
        sound = true,
        silenceMs = silenceMs,
    )

    private fun start(client: V380Client): Pair<Thread, Array<Throwable?>> {
        val error = arrayOfNulls<Throwable>(1)
        val runner = thread {
            try {
                client.run()
            } catch (failure: Throwable) {
                error[0] = failure
            }
        }
        return runner to error
    }

    @Test
    fun transcriptMediaHasItsHash() {
        val media = Transcript.media()
        assertEquals(1408, media.size)
        assertEquals("62c3176aabc395eda85c9930b48bf1d64c5f76c3f53b14f6bdf134264bad17c0", sha256(media))
        val first = unhex(
            "7f280003000000c800000000 0100000000000f000068e5cf8b010000 15f44809".replace(" ", ""),
        )
        assertEquals(first.hex(), media.copyOf(first.size).hex())
    }

    @Test
    fun clientProducesTheTranscriptOutputs() {
        val fake = camera(FakeCamera())
        val recorder = Recorder()
        val client = V380Client(config(fake.port), recorder)
        val (runner, error) = start(client)
        assertTrue("outputs arrived", recorder.done.await(5, TimeUnit.SECONDS))
        assertEquals("secret123", fake.passwords.single())
        assertTrue(fake.keys.single().all { it.toInt().toChar().isLetterOrDigit() })
        assertArrayEquals(Records.streamLogin(Transcript.DEVICE_ID, Transcript.TICKET, StreamKind.Sub, true), fake.streamLogins.single())
        assertEquals(531, recorder.video.size())
        assertEquals("846d743ee62dd231e9c34c22d36635a85c07df298a15d42702050dc63b442387", sha256(recorder.video.toByteArray()))
        assertEquals(listOf(true, false), recorder.keys)
        assertEquals(listOf(FrameType.ADPCM, FrameType.AAC, FrameType.ALAW), recorder.audio.keys.toList())
        assertEquals(Transcript.adpcm.hex(), recorder.audio[FrameType.ADPCM]!!.hex())
        assertEquals(Transcript.adts.hex(), recorder.audio[FrameType.AAC]!!.hex())
        assertEquals(Transcript.alaw.hex(), recorder.audio[FrameType.ALAW]!!.hex())
        assertEquals(Codec.Hevc, recorder.codec)
        assertEquals(32, recorder.session!!.deviceVersion)
        assertEquals(20, recorder.session!!.communicationVersion)
        assertEquals(32, recorder.session!!.replySize)
        val facts = client.facts!!
        assertEquals(Codec.Hevc, facts.codec)
        assertEquals(VideoSize(640, 720), facts.size)
        assertEquals(15, facts.frameRate)
        client.move(PtzMove.Left)
        client.move(PtzMove.Stop)
        Thread.sleep(300)
        client.close()
        runner.join(3000)
        assertFalse(runner.isAlive)
        assertEquals(null, error[0])
        assertTrue(fake.ended.await(3, TimeUnit.SECONDS))
        assertEquals(listOf(PtzMove.Left.record().hex(), PtzMove.Stop.record().hex()), fake.controls.toList())
    }

    @Test
    fun closingDuringAMoveSendsAStop() {
        val fake = camera(FakeCamera())
        val recorder = Recorder()
        val client = V380Client(config(fake.port), recorder)
        val (runner, _) = start(client)
        assertTrue(recorder.done.await(5, TimeUnit.SECONDS))
        client.move(PtzMove.Up)
        assertTrue(client.isMoving)
        client.close()
        runner.join(3000)
        assertTrue(fake.ended.await(3, TimeUnit.SECONDS))
        assertEquals(listOf(PtzMove.Up.record().hex(), PtzMove.Stop.record().hex()), fake.controls.toList())
    }

    @Test
    fun aReplyInTwoSegmentsIsReadWhole() {
        val fake = camera(FakeCamera(splitReply = true))
        val recorder = Recorder()
        val client = V380Client(config(fake.port), recorder)
        val (runner, _) = start(client)
        assertTrue(recorder.done.await(5, TimeUnit.SECONDS))
        assertEquals(32, recorder.session!!.replySize)
        client.close()
        runner.join(3000)
    }

    @Test
    fun lostFramingIsRecoveredByScanning() {
        val fake = camera(FakeCamera(garbageBefore = 30))
        val recorder = Recorder()
        val client = V380Client(config(fake.port), recorder)
        val (runner, _) = start(client)
        assertTrue(recorder.done.await(5, TimeUnit.SECONDS))
        assertEquals("846d743ee62dd231e9c34c22d36635a85c07df298a15d42702050dc63b442387", sha256(recorder.video.toByteArray()))
        client.close()
        runner.join(3000)
    }

    @Test
    fun aWrongPasswordIsARefusal() {
        val fake = camera(FakeCamera(loginResult = 1012))
        val client = V380Client(config(fake.port, password = "wrong"), Recorder())
        try {
            client.run()
            fail("expected a refusal")
        } catch (error: V380Exception) {
            assertTrue(error.refused)
            assertFalse(error.unreachable)
            assertEquals("Wrong password", error.message)
        }
        assertEquals("wrong", fake.passwords.single())
    }

    @Test
    fun aStreamRefusalIsReported() {
        val fake = camera(FakeCamera(streamResult = -11))
        val client = V380Client(config(fake.port), Recorder())
        try {
            client.run()
            fail("expected a refusal")
        } catch (error: V380Exception) {
            assertTrue(error.refused)
        }
    }

    @Test
    fun silenceEndsTheSession() {
        val fake = camera(FakeCamera(media = false))
        val client = V380Client(config(fake.port, silenceMs = 400), Recorder())
        try {
            client.run()
            fail("expected a timeout")
        } catch (error: V380Exception) {
            assertFalse(error.refused)
            assertTrue(error.message!!.startsWith("No media"))
        }
    }

    @Test
    fun aConnectionClosedInsideAFrameEndsTheSession() {
        val fake = camera(FakeCamera(cutAfter = 300))
        val recorder = Recorder()
        val client = V380Client(config(fake.port), recorder)
        try {
            client.run()
            fail("expected the session to end")
        } catch (error: V380Exception) {
            assertFalse(error.unreachable)
        }
        assertEquals(0, recorder.video.size())
        assertNotNull(recorder.session)
    }

    @Test
    fun aClosedPortIsUnreachable() {
        val port = ServerSocket(0, 1, InetAddress.getLoopbackAddress()).use { it.localPort }
        val client = V380Client(config(port).copy(connectTimeoutMs = 1000), Recorder())
        try {
            client.run()
            fail("expected an unreachable camera")
        } catch (error: V380Exception) {
            assertTrue(error.unreachable)
        }
    }

    @Test
    fun soundIsIgnoredWhenNotAskedFor() {
        val fake = camera(FakeCamera())
        val recorder = Recorder()
        val client = V380Client(config(fake.port).copy(sound = false), recorder)
        val (runner, _) = start(client)
        val deadline = System.currentTimeMillis() + 5000
        while (recorder.keys.size < 2 && System.currentTimeMillis() < deadline) Thread.sleep(20)
        assertEquals(2, recorder.keys.size)
        assertTrue(recorder.audio.isEmpty())
        client.close()
        runner.join(3000)
    }
}
