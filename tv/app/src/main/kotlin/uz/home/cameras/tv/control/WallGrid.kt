package uz.home.cameras.tv.control

import kotlin.math.abs

class WallGrid(val cols: Int, val rows: Int, occupied: Collection<Int>) {
    private val cells = occupied.filter { it in 0 until cols * rows }.toSortedSet()

    val first: Int?
        get() = cells.firstOrNull()

    fun col(index: Int): Int = index / rows

    fun row(index: Int): Int = index % rows

    fun contains(index: Int): Boolean = index in cells

    fun move(from: Int, key: Key): Int {
        if (from !in cells) return first ?: from
        val col = col(from)
        val row = row(from)
        return when (key) {
            Key.Up -> (row - 1 downTo 0).map { at(col, it) }.firstOrNull { it in cells } ?: from
            Key.Down -> (row + 1 until rows).map { at(col, it) }.firstOrNull { it in cells } ?: from
            Key.Left -> (col - 1 downTo 0).firstNotNullOfOrNull { nearest(it, row) } ?: from
            Key.Right -> (col + 1 until cols).firstNotNullOfOrNull { nearest(it, row) } ?: from
            else -> from
        }
    }

    private fun at(col: Int, row: Int): Int = col * rows + row

    private fun nearest(col: Int, row: Int): Int? =
        (0 until rows)
            .map { at(col, it) }
            .filter { it in cells }
            .minByOrNull { abs(row(it) - row) }
}
