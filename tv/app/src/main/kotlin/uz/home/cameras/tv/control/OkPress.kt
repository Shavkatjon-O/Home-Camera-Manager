package uz.home.cameras.tv.control

class OkPress(private val longRepeats: Int = 10) {
    private var pressed = false
    private var longFired = false

    fun down(repeatCount: Int, longPress: Boolean): Boolean {
        if (repeatCount == 0) {
            pressed = true
            longFired = false
            return false
        }
        if (pressed && !longFired && (longPress || repeatCount >= longRepeats)) {
            longFired = true
            return true
        }
        return false
    }

    fun up(): Boolean {
        val short = pressed && !longFired
        pressed = false
        longFired = false
        return short
    }
}
