package uz.home.cameras.tv.data

import kotlinx.serialization.json.Json

val json = Json {
    ignoreUnknownKeys = true
    isLenient = true
    coerceInputValues = true
    explicitNulls = false
    encodeDefaults = true
}

fun parseConfig(text: String): TvConfig {
    val config = json.decodeFromString<TvConfig>(text)
    val cols = config.wall.cols.coerceAtLeast(1)
    val rows = config.wall.rows.coerceAtLeast(1)
    val tiles = config.tiles
        .filter { it.url.isNotBlank() && it.index >= 0 }
        .distinctBy { it.index }
        .sortedBy { it.index }
    return config.copy(wall = config.wall.copy(cols = cols, rows = rows), tiles = tiles)
}

fun parsePairingCreated(text: String): PairingCreated = json.decodeFromString(text)

fun parsePairingStatus(text: String): PairingStatus = json.decodeFromString(text)
