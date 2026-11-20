package uz.smartsurveillance.tv.v380

import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.NetworkInterface
import java.net.SocketTimeoutException

data class Found(val id: String, val ip: String, val mac: String)

object Discovery {
    private const val SEARCH = "NVDEVSEARCH^100"
    private const val SEND_PORT = 10008
    private const val LISTEN_PORT = 10009

    fun parse(text: String): Found? {
        val parts = text.split('^')
        if (parts.size < 13 || parts[0] != "NVDEVRESULT") return null
        return Found(id = parts[12].trim(), ip = parts[3].trim(), mac = parts[2].trim())
    }

    fun search(tries: Int = 5, windowMs: Int = 300): List<Found> {
        val found = LinkedHashMap<String, Found>()
        DatagramSocket(null).use { socket ->
            socket.reuseAddress = true
            socket.broadcast = true
            socket.bind(InetSocketAddress(LISTEN_PORT))
            val query = SEARCH.toByteArray(Charsets.US_ASCII)
            val targets = broadcastTargets()
            val buffer = ByteArray(2048)
            repeat(tries) {
                for (target in targets) {
                    runCatching { socket.send(DatagramPacket(query, query.size, target, SEND_PORT)) }
                }
                val until = System.currentTimeMillis() + windowMs
                while (true) {
                    val left = until - System.currentTimeMillis()
                    if (left <= 0) break
                    socket.soTimeout = left.toInt()
                    val packet = DatagramPacket(buffer, buffer.size)
                    try {
                        socket.receive(packet)
                    } catch (_: SocketTimeoutException) {
                        break
                    }
                    val text = String(packet.data, 0, packet.length, Charsets.US_ASCII)
                    parse(text)?.let { found.putIfAbsent(it.mac, it) }
                }
            }
        }
        return found.values.toList()
    }

    private fun broadcastTargets(): List<InetAddress> {
        val targets = LinkedHashSet<InetAddress>()
        targets += InetAddress.getByName("255.255.255.255")
        runCatching {
            for (network in NetworkInterface.getNetworkInterfaces()) {
                if (!network.isUp || network.isLoopback) continue
                for (address in network.interfaceAddresses) address.broadcast?.let { targets += it }
            }
        }
        return targets.toList()
    }
}
