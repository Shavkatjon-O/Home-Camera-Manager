package uz.smartsurveillance.tv.v380

import java.io.ByteArrayOutputStream
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.CountDownLatch
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.TimeUnit
import kotlin.concurrent.thread
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Assume.assumeTrue
import org.junit.Test

class SimulatorTest {
    private fun repositoryRoot(): File? {
        var dir: File? = File(System.getProperty("user.dir") ?: ".").absoluteFile
        while (dir != null) {
            if (File(dir, "docs/protocols/v380.md").isFile) return dir
            dir = dir.parentFile
        }
        return null
    }

    private fun pythonWorks(): Boolean = runCatching {
        val process = ProcessBuilder("python3", "--version").redirectErrorStream(true).start()
        process.inputStream.readBytes()
        process.waitFor(10, TimeUnit.SECONDS) && process.exitValue() == 0
    }.getOrDefault(false)

    private class Recorder : V380Client.Listener {
        val video = ByteArrayOutputStream()
        val audio = LinkedHashMap<Int, ByteArray>()
        val done = CountDownLatch(5)

        override fun onVideo(codec: Codec, data: ByteArray, key: Boolean) {
            video.write(data)
            done.countDown()
        }

        override fun onAudio(type: Int, payload: ByteArray) {
            audio[type] = payload
            done.countDown()
        }
    }

    @Test
    fun clientMatchesTheTranscriptAgainstTheSimulator() {
        val root = repositoryRoot()
        assumeTrue("repository root not found", root != null)
        val simulator = File(root, "tools/devkit/v380/simulator.py")
        assumeTrue("simulator not present", simulator.isFile)
        assumeTrue("python3 not available", pythonWorks())

        val process = ProcessBuilder(
            "python3", simulator.path, "--transcript", "--host", "127.0.0.1", "--port", "0", "--discovery-port", "0",
        ).directory(root).redirectError(ProcessBuilder.Redirect.INHERIT)
            .apply { environment()["PYTHONDONTWRITEBYTECODE"] = "1" }
            .start()
        val lines = LinkedBlockingQueue<String>()
        val reader = thread(isDaemon = true) {
            runCatching { process.inputStream.bufferedReader().forEachLine { lines.put(it) } }
        }
        try {
            val listening = next(lines) { it.contains("\"listening\"") }
            assertNotNull("simulator announced its port", listening)
            val port = Regex("\"port\"\\s*:\\s*(\\d+)").find(listening!!)!!.groupValues[1].toInt()

            val recorder = Recorder()
            val client = V380Client(
                V380Client.Config(
                    host = "127.0.0.1",
                    port = port,
                    deviceId = Transcript.DEVICE_ID,
                    password = Transcript.PASSWORD,
                    stream = StreamKind.Sub,
                    sound = true,
                ),
                recorder,
            )
            val runner = thread { runCatching { client.run() } }
            assertTrue("outputs arrived", recorder.done.await(10, TimeUnit.SECONDS))

            assertEquals(
                "846d743ee62dd231e9c34c22d36635a85c07df298a15d42702050dc63b442387",
                sha256(recorder.video.toByteArray()),
            )
            assertEquals(Transcript.adpcm.hex(), recorder.audio[FrameType.ADPCM]?.hex())
            assertEquals(Transcript.adts.hex(), recorder.audio[FrameType.AAC]?.hex())
            assertEquals(Transcript.alaw.hex(), recorder.audio[FrameType.ALAW]?.hex())
            val pcm = ImaAdpcm.decodeBlock(Transcript.adpcm, 0, 256)
            val bytes = ByteBuffer.allocate(pcm.size * 2).order(ByteOrder.LITTLE_ENDIAN).apply {
                pcm.forEach { putShort(it) }
            }.array()
            assertEquals("5afe464b1e3fe4ebc142904fb62c596a00a70445e1d66541a9835c83878d2232", sha256(bytes))
            val facts = client.facts!!
            assertEquals(Codec.Hevc, facts.codec)
            assertEquals(VideoSize(640, 720), facts.size)
            assertEquals(32, facts.replySize)

            client.move(PtzMove.Left)
            client.move(PtzMove.Stop)
            val first = next(lines) { it.contains("\"control\"") }
            val second = next(lines) { it.contains("\"control\"") }
            client.close()
            runner.join(3000)
            val hex = Regex("\"hex\"\\s*:\\s*\"([0-9a-f]+)\"")
            assertEquals(PtzMove.Left.record().hex(), hex.find(first!!)!!.groupValues[1])
            assertEquals(PtzMove.Stop.record().hex(), hex.find(second!!)!!.groupValues[1])
        } finally {
            process.destroy()
            if (!process.waitFor(5, TimeUnit.SECONDS)) process.destroyForcibly()
            reader.join(2000)
        }
    }

    private fun next(lines: LinkedBlockingQueue<String>, match: (String) -> Boolean): String? {
        val deadline = System.currentTimeMillis() + 10_000
        while (true) {
            val left = deadline - System.currentTimeMillis()
            if (left <= 0) return null
            val line = lines.poll(left, TimeUnit.MILLISECONDS) ?: return null
            if (match(line)) return line
        }
    }
}
