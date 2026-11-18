package uz.home.cameras.tv.data

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class TvConfig(
    val wall: WallConfig,
    val tiles: List<TileConfig> = emptyList(),
)

@Serializable
data class WallConfig(
    val url: String,
    val cols: Int = 1,
    val rows: Int = 1,
)

@Serializable
data class TileConfig(
    val index: Int,
    val label: String = "",
    @SerialName("camera_uuid") val cameraUuid: String = "",
    @SerialName("camera_name") val cameraName: String = "",
    val lens: Int? = null,
    val ptz: Boolean = false,
    val url: String,
) {
    val title: String
        get() = cameraName.ifBlank { label }

    val lensLabel: String?
        get() = lens?.let { "Lens ${it + 1}" }
}

@Serializable
data class PairingRequest(
    @SerialName("device_name") val deviceName: String,
)

@Serializable
data class PairingCreated(
    val id: String,
    val code: String,
    @SerialName("expires_at") val expiresAt: String? = null,
)

@Serializable
data class PairingStatus(
    val status: String,
    val token: String? = null,
)

@Serializable
data class PtzMove(
    val pan: Float = 0f,
    val tilt: Float = 0f,
    val zoom: Float = 0f,
)
