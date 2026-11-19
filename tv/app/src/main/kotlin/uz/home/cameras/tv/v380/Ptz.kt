package uz.home.cameras.tv.v380

enum class PtzMove { Left, Right, Up, Down, Stop }

object Ptz {
    private fun command(pan: Int, tilt: Int): ByteArray = byteArrayOf(
        0xaa.toByte(), 0, 0, 0,
        0xe8.toByte(), 0x03, 0xe8.toByte(), 0x03,
        pan.toByte(), 0x03, tilt.toByte(), 0x03,
        0, 0, 0x01, 0,
    )

    fun packet(move: PtzMove): ByteArray = when (move) {
        PtzMove.Right -> command(0xea, 0xe8)
        PtzMove.Left -> command(0xe9, 0xe8)
        PtzMove.Up -> command(0xe8, 0xeb)
        PtzMove.Down -> command(0xe8, 0xec)
        PtzMove.Stop -> command(0xe8, 0xe8)
    }
}
