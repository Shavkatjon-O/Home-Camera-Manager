package uz.home.cameras.tv.pairing

import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import uz.home.cameras.tv.data.Api
import uz.home.cameras.tv.data.ApiException
import uz.home.cameras.tv.player.Backoff

data class PairingState(
    val code: String? = null,
    val status: String? = "Connecting",
)

class PairingController(private val api: Api, private val deviceName: String) {
    private val stateFlow = MutableStateFlow(PairingState())
    val state: StateFlow<PairingState> = stateFlow.asStateFlow()

    private val backoff = Backoff()

    suspend fun run(): String {
        while (true) {
            val pairing = try {
                api.createPairing(deviceName)
            } catch (error: CancellationException) {
                throw error
            } catch (error: Exception) {
                stateFlow.value = PairingState(status = describe(error))
                delay(backoff.next())
                continue
            }
            backoff.reset()
            stateFlow.value = PairingState(code = pairing.code, status = null)
            val token = poll(pairing.id, pairing.code)
            if (token != null) return token
            stateFlow.value = PairingState(status = "Code expired, getting a new one")
        }
    }

    private suspend fun poll(id: String, code: String): String? {
        while (true) {
            delay(POLL_MS)
            val result = try {
                api.pairing(id)
            } catch (error: CancellationException) {
                throw error
            } catch (error: ApiException) {
                if (error.code == 404 || error.code == 410) return null
                stateFlow.value = PairingState(code = code, status = describe(error))
                continue
            } catch (error: Exception) {
                stateFlow.value = PairingState(code = code, status = describe(error))
                continue
            }
            stateFlow.value = PairingState(code = code, status = null)
            when (result.status) {
                "approved" -> return result.token
                "expired" -> return null
            }
        }
    }

    private fun describe(error: Exception): String =
        if (error is ApiException) "Server error ${error.code}" else "Server not reachable"

    private companion object {
        const val POLL_MS = 2000L
    }
}
