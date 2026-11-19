package uz.home.cameras.tv.rtsp

import java.security.MessageDigest

data class Response(val status: Int, val reason: String, val headers: Map<String, String>, val body: String) {
    fun header(name: String): String? = headers[name.lowercase()]
}

object Messages {
    fun request(method: String, url: String, cseq: Int, headers: List<Pair<String, String>>): ByteArray {
        val text = buildString {
            append("$method $url RTSP/1.0\r\n")
            append("CSeq: $cseq\r\n")
            append("User-Agent: home-cameras-tv\r\n")
            for ((name, value) in headers) append("$name: $value\r\n")
            append("\r\n")
        }
        return text.toByteArray(Charsets.US_ASCII)
    }

    fun parseHead(lines: List<String>, body: String): Response? {
        val status = lines.firstOrNull() ?: return null
        val parts = status.split(' ', limit = 3)
        if (parts.size < 2 || !parts[0].startsWith("RTSP/")) return null
        val headers = LinkedHashMap<String, String>()
        for (line in lines.drop(1)) {
            val at = line.indexOf(':')
            if (at <= 0) continue
            val name = line.substring(0, at).trim().lowercase()
            val value = line.substring(at + 1).trim()
            headers[name] = headers[name]?.let { "$it, $value" } ?: value
        }
        return Response(parts[1].toIntOrNull() ?: 0, parts.getOrElse(2) { "" }, headers, body)
    }

    fun session(header: String?): String? = header?.substringBefore(';')?.trim()?.takeIf { it.isNotEmpty() }

    fun timeoutSeconds(header: String?): Int? = header?.split(';')
        ?.map { it.trim() }
        ?.firstOrNull { it.startsWith("timeout=", ignoreCase = true) }
        ?.substringAfter('=')?.toIntOrNull()

    fun challenge(header: String): Map<String, String> {
        val result = HashMap<String, String>()
        val scheme = header.substringBefore(' ').trim()
        result["scheme"] = scheme.lowercase()
        val regex = Regex("""(\w+)\s*=\s*(?:"([^"]*)"|([^,\s]+))""")
        for (match in regex.findAll(header.substringAfter(' ', ""))) {
            result[match.groupValues[1].lowercase()] = match.groupValues[2].ifEmpty { match.groupValues[3] }
        }
        return result
    }

    fun digest(challenge: Map<String, String>, method: String, uri: String, user: String, password: String, count: Int, cnonce: String): String {
        val realm = challenge["realm"] ?: ""
        val nonce = challenge["nonce"] ?: ""
        val ha1 = md5("$user:$realm:$password")
        val ha2 = md5("$method:$uri")
        val qop = challenge["qop"]?.split(',')?.map { it.trim() }?.firstOrNull { it == "auth" }
        val nc = "%08x".format(count)
        val response = if (qop != null) md5("$ha1:$nonce:$nc:$cnonce:$qop:$ha2") else md5("$ha1:$nonce:$ha2")
        return buildString {
            append("Digest username=\"$user\", realm=\"$realm\", nonce=\"$nonce\", uri=\"$uri\", response=\"$response\"")
            challenge["opaque"]?.let { append(", opaque=\"$it\"") }
            if (qop != null) append(", qop=$qop, nc=$nc, cnonce=\"$cnonce\"")
            challenge["algorithm"]?.let { append(", algorithm=$it") }
        }
    }

    fun basic(user: String, password: String): String =
        "Basic " + java.util.Base64.getEncoder().encodeToString("$user:$password".toByteArray(Charsets.UTF_8))

    fun md5(text: String): String =
        MessageDigest.getInstance("MD5").digest(text.toByteArray(Charsets.UTF_8)).joinToString("") { "%02x".format(it.toInt() and 0xFF) }
}
