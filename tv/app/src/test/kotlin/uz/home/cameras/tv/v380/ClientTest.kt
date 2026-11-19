package uz.home.cameras.tv.v380

import java.io.DataInputStream
import java.net.InetAddress
import java.net.ServerSocket
import java.util.concurrent.CopyOnWriteArrayList
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class ClientTest {
    private val ticket = 0x0BADF00DL
    private val deviceId = 12345678L

    private fun fragment(type: Int, total: Int, index: Int, payload: ByteArray): ByteArray {
        val header = ByteArray(12)
        header[0] = 0x7F
        header[1] = type.toByte()
        header.put16(3, total)
        header.put16(5, index)
        header.put16(7, payload.size)
        return header + payload
    }

    private fun inner(body: ByteArray): ByteArray {
        val head = ByteArray(16)
        head.put32(0, 1)
        head.put16(6, 15)
        head.put64(8, 1_000L)
        return head + body
    }

    @Test
    fun logsInDecryptsFramesAndSendsPtz() {
        val key = Crypto.mediaKey(ticket)
        val video = byteArrayOf(0, 0, 0, 1, 0x40, 0x01, 0x0C) + ByteArray(300) { (it * 3).toByte() }
        val encryptedVideo = video.copyOf()
        var at = 0
        while (at + 64 <= encryptedVideo.size) {
            Crypto.encryptor(key).doFinal(encryptedVideo, at, 64, encryptedVideo, at)
            at += 80
        }
        val audio = ByteArray(256) { (it + 1).toByte() }
        val encryptedAudio = audio.copyOf()
        Crypto.encryptor(key).doFinal(encryptedAudio, 0, 256, encryptedAudio, 0)
        val received = CopyOnWriteArrayList<ByteArray>()
        val ptz = CountDownLatch(1)
        val server = ServerSocket(0, 5, InetAddress.getLoopbackAddress())
        val camera = Thread {
            server.accept().use { auth ->
                val request = ByteArray(520)
                DataInputStream(auth.getInputStream()).readFully(request)
                received += request
                val reply = ByteArray(256)
                reply.put32(0, 1168)
                reply.put32(4, 1001)
                reply[12] = 32
                reply.put32(13, ticket)
                auth.getOutputStream().write(reply)
            }
            server.accept().use { stream ->
                val input = DataInputStream(stream.getInputStream())
                val login = ByteArray(256)
                input.readFully(login)
                received += login
                val reply = ByteArray(32)
                reply.put32(0, 401)
                reply.put32(4, 1001)
                reply.put16(8, 20)
                reply.put32(10, 640)
                reply.put32(14, 720)
                stream.getOutputStream().write(reply)
                val start = ByteArray(256)
                input.readFully(start)
                received += start
                val whole = inner(encryptedVideo)
                val out = stream.getOutputStream()
                out.write(fragment(0x28, 2, 0, whole.copyOfRange(0, 200)))
                out.write(fragment(0x28, 2, 1, whole.copyOfRange(200, whole.size)))
                out.write(fragment(0x16, 1, 0, inner(encryptedAudio)))
                out.flush()
                val move = ByteArray(16)
                input.readFully(move)
                received += move
                ptz.countDown()
                Thread.sleep(200)
            }
        }
        camera.start()
        val videos = CopyOnWriteArrayList<MediaFrame>()
        val audios = CopyOnWriteArrayList<MediaFrame>()
        var opened: Session? = null
        val frames = CountDownLatch(2)
        lateinit var client: Client
        client = Client("127.0.0.1", server.localPort, deviceId, "admin", "pw", hd = false, audio = true, listener = object : ClientListener {
            override fun onSession(session: Session) {
                opened = session
            }

            override fun onBytes(count: Int) = Unit

            override fun onVideo(frame: MediaFrame) {
                videos += frame
                frames.countDown()
            }

            override fun onAudio(frame: MediaFrame) {
                audios += frame
                frames.countDown()
                client.send(Ptz.packet(PtzMove.Left))
            }
        })
        val runner = Thread { runCatching { client.run() } }
        runner.start()
        assertTrue(frames.await(5, TimeUnit.SECONDS))
        assertTrue(ptz.await(5, TimeUnit.SECONDS))
        client.close()
        runner.join(3000)
        camera.join(3000)
        server.close()
        val session = opened!!
        assertEquals(32, session.version)
        assertEquals(640L, session.width)
        assertTrue(session.encrypted)
        assertEquals(1167L, received[0].u32(0))
        assertEquals(deviceId, received[0].u32(13))
        assertEquals(301L, received[1].u32(0))
        assertEquals(ticket, received[1].u32(14))
        assertEquals(4097L, received[1].u32(22))
        assertEquals(0L, received[1].u32(26))
        assertEquals(303L, received[2].u32(0))
        assertArrayEquals(Ptz.packet(PtzMove.Left), received[3])
        assertArrayEquals(video, videos.single().payload)
        assertTrue(videos.single().key)
        assertArrayEquals(audio, audios.single().payload)
        assertEquals(0x16, audios.single().type)
    }

    @Test
    fun reportsUnreachableAndRefused() {
        val closed = ServerSocket(0, 1, InetAddress.getLoopbackAddress())
        val port = closed.localPort
        closed.close()
        val listener = object : ClientListener {
            override fun onSession(session: Session) = Unit
            override fun onBytes(count: Int) = Unit
            override fun onVideo(frame: MediaFrame) = Unit
            override fun onAudio(frame: MediaFrame) = Unit
        }
        val unreachable = runCatching { Client("127.0.0.1", port, 1, "admin", "pw", false, false, listener).run() }.exceptionOrNull()
        assertTrue(unreachable is V380Exception && unreachable.unreachable)
        val server = ServerSocket(0, 1, InetAddress.getLoopbackAddress())
        val camera = Thread {
            server.accept().use { auth ->
                DataInputStream(auth.getInputStream()).readFully(ByteArray(520))
                val reply = ByteArray(256)
                reply.put32(0, 1168)
                reply.put32(4, 1012)
                auth.getOutputStream().write(reply)
            }
        }
        camera.start()
        val refused = runCatching { Client("127.0.0.1", server.localPort, 1, "admin", "bad", false, false, listener).run() }.exceptionOrNull()
        camera.join(3000)
        server.close()
        assertTrue(refused is V380Exception && refused.refused)
        assertEquals("Wrong password", refused!!.message)
    }
}
