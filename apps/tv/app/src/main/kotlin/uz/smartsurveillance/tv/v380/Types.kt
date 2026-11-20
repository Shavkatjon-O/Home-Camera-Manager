package uz.smartsurveillance.tv.v380

/**
 * A video codec of a camera stream.
 *
 * @property mime MIME type a platform decoder is created for.
 */
enum class Codec(val mime: String) {
    /** H.264. */
    Avc("video/avc"),

    /** H.265. */
    Hevc("video/hevc"),
}

/**
 * Picture size in pixels.
 *
 * @property width Width.
 * @property height Height.
 */
data class VideoSize(val width: Int, val height: Int)

/**
 * A V380 session failed.
 *
 * @property unreachable The camera did not accept a connection, so its address may have changed.
 * @property refused The camera refused the login or the stream; retry slowly.
 */
class V380Exception(
    message: String,
    val unreachable: Boolean = false,
    val refused: Boolean = false,
    cause: Throwable? = null,
) : Exception(message, cause)

/** Which stream of the camera a session asks for. */
enum class StreamKind(internal val value: Long) {
    /** The high definition main stream. */
    Main(1),

    /** The standard definition sub stream. */
    Sub(0),
}
