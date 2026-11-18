package uz.home.cameras.tv.data

import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class ApiException(val code: Int) : IOException("HTTP $code")

class Api(private val server: String) {
    suspend fun createPairing(deviceName: String): PairingCreated =
        parsePairingCreated(
            request("POST", "/api/v1/tv/pairings", body = json.encodeToString(PairingRequest(deviceName))),
        )

    suspend fun pairing(id: String): PairingStatus =
        parsePairingStatus(request("GET", "/api/v1/tv/pairings/${encode(id)}"))

    suspend fun config(token: String): TvConfig =
        parseConfig(request("GET", "/api/v1/tv/config", token = token))

    suspend fun ptzMove(token: String, cameraUuid: String, move: PtzMove) {
        request("POST", "/api/v1/tv/ptz/${encode(cameraUuid)}/move", token = token, body = json.encodeToString(move))
    }

    suspend fun ptzStop(token: String, cameraUuid: String) {
        request("POST", "/api/v1/tv/ptz/${encode(cameraUuid)}/stop", token = token, body = "")
    }

    private fun encode(value: String): String = URLEncoder.encode(value, "UTF-8").replace("+", "%20")

    private suspend fun request(method: String, path: String, token: String? = null, body: String? = null): String =
        withContext(Dispatchers.IO) {
            val connection = URL(server + path).openConnection() as HttpURLConnection
            try {
                connection.requestMethod = method
                connection.connectTimeout = CONNECT_TIMEOUT_MS
                connection.readTimeout = READ_TIMEOUT_MS
                connection.useCaches = false
                connection.instanceFollowRedirects = false
                connection.setRequestProperty("Accept", "application/json")
                if (token != null) connection.setRequestProperty("Authorization", "Bearer $token")
                if (body != null) {
                    val bytes = body.toByteArray()
                    connection.doOutput = true
                    connection.setRequestProperty("Content-Type", "application/json")
                    connection.setFixedLengthStreamingMode(bytes.size)
                    connection.outputStream.use { it.write(bytes) }
                }
                val code = connection.responseCode
                if (code !in 200..299) throw ApiException(code)
                connection.inputStream.use { it.readBytes().decodeToString() }
            } finally {
                connection.disconnect()
            }
        }

    private companion object {
        const val CONNECT_TIMEOUT_MS = 5000
        const val READ_TIMEOUT_MS = 10000
    }
}
