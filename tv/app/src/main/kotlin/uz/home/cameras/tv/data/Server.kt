package uz.home.cameras.tv.data

const val DEFAULT_SERVER = "http://192.168.1.219:8750"

fun normalizeServer(input: String): String {
    val value = input.trim().trimEnd('/')
    if (value.isEmpty()) return value
    return if (value.contains("://")) value else "http://$value"
}
