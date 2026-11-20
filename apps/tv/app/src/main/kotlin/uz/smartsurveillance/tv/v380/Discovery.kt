package uz.smartsurveillance.tv.v380

import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.Inet4Address
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.NetworkInterface
import java.net.SocketAddress
import java.net.SocketTimeoutException

/**
 * A camera that answered a LAN search.
 *
 * @property id Device id as decimal text.
 * @property ip IPv4 address the camera reports.
 * @property mac MAC address as text.
 * @property mask Subnet mask.
 * @property gateway Default gateway.
 */
data class Found(val id: String, val ip: String, val mac: String, val mask: String, val gateway: String)

/** UDP broadcast search for V380 cameras on the local network. */
object Discovery {
    /** Port the cameras listen on for searches. */
    const val SEARCH_PORT = 10008

    /** Port the client binds, which covers cameras that answer to a fixed port. */
    const val REPLY_PORT = 10009

    /** The search request text, sent without a terminator. */
    const val REQUEST = "NVDEVSEARCH^100"

    private const val REPLY_TAG = "NVDEVRESULT"
    private const val MIN_FIELDS = 13
    private const val ROUNDS = 5
    private const val LISTEN_MS = 280

    /** The bytes of the search request. */
    fun request(): ByteArray = REQUEST.toByteArray(Charsets.US_ASCII)

    /**
     * Reads one reply.
     *
     * @return The camera, or null when the text is not a valid reply.
     */
    fun parse(text: String): Found? {
        val fields = text.split('^').map { it.trim() }
        if (fields.size < MIN_FIELDS || fields[0] != REPLY_TAG) return null
        val id = fields[12]
        if (id.isEmpty() || id.any { !it.isDigit() } || fields[3].isEmpty()) return null
        return Found(id = id, ip = fields[3], mac = fields[2], mask = fields[4], gateway = fields[5])
    }

    /**
     * Searches the local network, collapsing duplicate replies by MAC address.
     *
     * @param targets Where to send the search; the limited broadcast and every directed broadcast by default.
     * @param bindPort Local port to bind; 0 picks any port.
     * @param rounds Number of send and listen rounds.
     * @param listenMs Time to listen after each send.
     */
    fun search(
        targets: List<SocketAddress> = broadcasts(),
        bindPort: Int = REPLY_PORT,
        rounds: Int = ROUNDS,
        listenMs: Int = LISTEN_MS,
    ): List<Found> {
        val found = LinkedHashMap<String, Found>()
        DatagramSocket(null).use { socket ->
            socket.reuseAddress = true
            socket.broadcast = true
            socket.bind(InetSocketAddress(bindPort))
            val request = request()
            val buffer = ByteArray(2048)
            repeat(rounds) {
                for (target in targets) runCatching { socket.send(DatagramPacket(request, request.size, target)) }
                val until = System.currentTimeMillis() + listenMs
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
                    val reply = parse(String(packet.data, packet.offset, packet.length, Charsets.US_ASCII)) ?: continue
                    found.putIfAbsent(reply.mac.uppercase().ifEmpty { reply.id }, reply)
                }
            }
        }
        return found.values.toList()
    }

    /** The limited broadcast address and the directed broadcast address of every IPv4 interface. */
    fun broadcasts(): List<SocketAddress> {
        val out = LinkedHashSet<InetAddress>()
        out += InetAddress.getByName("255.255.255.255")
        runCatching {
            for (nic in NetworkInterface.getNetworkInterfaces()) {
                if (!nic.isUp || nic.isLoopback) continue
                for (address in nic.interfaceAddresses) {
                    val broadcast = address.broadcast
                    if (address.address is Inet4Address && broadcast != null) out += broadcast
                }
            }
        }
        return out.map { InetSocketAddress(it, SEARCH_PORT) }
    }
}
