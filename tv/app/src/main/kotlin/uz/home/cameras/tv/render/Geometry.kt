package uz.home.cameras.tv.render

data class Box(val x: Float, val y: Float, val w: Float, val h: Float) {
    fun scale(width: Float, height: Float): Box = Box(x * width, y * height, w * width, h * height)
}

data class SceneTile(
    val slot: Int,
    val cameraId: String,
    val key: String?,
    val lens: Int,
    val lenses: Int,
    val cell: Box,
    val aspect: Float,
)

data class Scene(val tiles: List<SceneTile> = emptyList())

object Geometry {
    const val DEFAULT_ASPECT = 16f / 9f

    fun fit(cell: Box, aspect: Float): Box {
        if (cell.w <= 0f || cell.h <= 0f) return cell
        val ratio = if (aspect > 0f && aspect.isFinite()) aspect else DEFAULT_ASPECT
        return if (cell.w / cell.h > ratio) {
            val w = cell.h * ratio
            Box(cell.x + (cell.w - w) / 2f, cell.y, w, cell.h)
        } else {
            val h = cell.w / ratio
            Box(cell.x, cell.y + (cell.h - h) / 2f, cell.w, h)
        }
    }

    fun lensAspect(width: Int, height: Int, lenses: Int): Float {
        if (width <= 0 || height <= 0) return DEFAULT_ASPECT
        return width.toFloat() / (height.toFloat() / lenses.coerceAtLeast(1))
    }

    fun lensRange(lens: Int, lenses: Int): Pair<Float, Float> {
        val count = lenses.coerceAtLeast(1)
        val index = lens.coerceIn(0, count - 1)
        val top = 1f - index.toFloat() / count
        val bottom = 1f - (index + 1).toFloat() / count
        return bottom to top
    }

    fun quad(rect: Box, width: Float, height: Float, lens: Int, lenses: Int): FloatArray {
        val left = rect.x / width * 2f - 1f
        val right = (rect.x + rect.w) / width * 2f - 1f
        val top = 1f - rect.y / height * 2f
        val bottom = 1f - (rect.y + rect.h) / height * 2f
        val (t0, t1) = lensRange(lens, lenses)
        return floatArrayOf(
            left, bottom, 0f, t0,
            right, bottom, 1f, t0,
            left, top, 0f, t1,
            right, top, 1f, t1,
        )
    }
}
