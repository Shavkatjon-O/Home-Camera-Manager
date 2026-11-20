package uz.smartsurveillance.tv.v380

import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.net.InetSocketAddress
import kotlin.concurrent.thread
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class DiscoveryTest {
    private val reply = "NVDEVRESULT^1^AA:BB:CC:DD:EE:FF^192.168.1.237^255.255.255.0^192.168.1.1^x^x^x^x^x^x^12345678^x"

    @Test
    fun requestAndReplyFollowTheVectors() {
        assertEquals("4e564445565345415243485e313030", Discovery.request().hex())
        assertEquals(
            Found("12345678", "192.168.1.237", "AA:BB:CC:DD:EE:FF", "255.255.255.0", "192.168.1.1"),
            Discovery.parse(reply),
        )
        assertNull(Discovery.parse("NVDEVSEARCH^100"))
        assertNull(Discovery.parse("NVDEVRESULT^1^2"))
    }

    @Test
    fun repliesAreTrimmedAndCollapsedByMac() {
        val camera = DatagramSocket(0, InetAddress.getLoopbackAddress())
        val responder = thread {
            val buffer = ByteArray(64)
            repeat(2) {
                val packet = DatagramPacket(buffer, buffer.size)
                runCatching { camera.receive(packet) }.onFailure { return@thread }
                val text = String(packet.data, 0, packet.length)
                if (text == Discovery.REQUEST) {
                    val answer = reply.replace("^192.168.1.237^", "^ 192.168.1.237 ^").toByteArray()
                    camera.send(DatagramPacket(answer, answer.size, packet.socketAddress))
                    camera.send(DatagramPacket(answer, answer.size, packet.socketAddress))
                }
            }
        }
        val found = Discovery.search(
            targets = listOf(InetSocketAddress(InetAddress.getLoopbackAddress(), camera.localPort)),
            bindPort = 0,
            rounds = 2,
            listenMs = 300,
        )
        camera.close()
        responder.join(2000)
        assertEquals(1, found.size)
        assertEquals("192.168.1.237", found[0].ip)
        assertEquals("12345678", found[0].id)
    }
}
