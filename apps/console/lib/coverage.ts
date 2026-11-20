import type { AccessPoint, AccessPointPreset, Band, Wall, WallMaterial } from "@/lib/types"

export const BAND_LABELS: Record<Band, string> = { "2.4": "2.4 GHz", "5": "5 GHz" }

export const REFERENCE_LOSS_DB: Record<Band, number> = { "2.4": 40.0, "5": 47.2 }
export const MIN_DISTANCE_M = 0.5

export const MATERIALS: WallMaterial[] = [
  "drywall",
  "wood",
  "glass",
  "brick",
  "thick_brick",
  "concrete",
  "reinforced_concrete",
  "metal",
]

export const MATERIAL_LABELS: Record<WallMaterial, string> = {
  drywall: "Drywall",
  wood: "Wood",
  glass: "Glass",
  brick: "Brick",
  thick_brick: "Thick brick",
  concrete: "Concrete",
  reinforced_concrete: "Reinforced concrete",
  metal: "Metal",
}

export const WALL_LOSS_DB: Record<WallMaterial, Record<Band, number>> = {
  drywall: { "2.4": 3, "5": 4 },
  wood: { "2.4": 4, "5": 6 },
  glass: { "2.4": 3, "5": 6 },
  brick: { "2.4": 10, "5": 15 },
  thick_brick: { "2.4": 15, "5": 22 },
  concrete: { "2.4": 15, "5": 25 },
  reinforced_concrete: { "2.4": 25, "5": 35 },
  metal: { "2.4": 40, "5": 50 },
}

export const WALL_STYLES: Record<WallMaterial, { color: string; width: number; dash?: string }> = {
  drywall: { color: "#9b9b9b", width: 2 },
  wood: { color: "#a9845a", width: 2.5 },
  glass: { color: "#4fa3c4", width: 2, dash: "6 4" },
  brick: { color: "#c0624a", width: 3.5 },
  thick_brick: { color: "#93432f", width: 5 },
  concrete: { color: "#7d8590", width: 5 },
  reinforced_concrete: { color: "#5f6977", width: 6.5 },
  metal: { color: "#b4bcc6", width: 3.5, dash: "2 3" },
}

export const DEFAULT_MATERIAL: WallMaterial = "brick"

export interface Preset {
  label: string
  band_24: boolean
  band_5: boolean
  power_24_dbm: number
  power_5_dbm: number
}

export const PRESETS: Record<AccessPointPreset, Preset> = {
  archer_c64: { label: "Archer C64", band_24: true, band_5: true, power_24_dbm: 20, power_5_dbm: 23 },
  archer_c54: { label: "Archer C54", band_24: true, band_5: true, power_24_dbm: 20, power_5_dbm: 23 },
  reyee_ew300n: { label: "Reyee EW300N", band_24: true, band_5: false, power_24_dbm: 20, power_5_dbm: 23 },
  generic: { label: "Generic", band_24: true, band_5: true, power_24_dbm: 20, power_5_dbm: 23 },
}

export const PRESET_ORDER: AccessPointPreset[] = ["archer_c64", "archer_c54", "reyee_ew300n", "generic"]

export type Quality = "excellent" | "good" | "fair" | "weak" | "none"

export const QUALITY_LEVELS: { quality: Exclude<Quality, "none">; min: number }[] = [
  { quality: "excellent", min: -55 },
  { quality: "good", min: -67 },
  { quality: "fair", min: -75 },
  { quality: "weak", min: -82 },
]

export const QUALITY_ORDER: Quality[] = ["excellent", "good", "fair", "weak", "none"]

export const QUALITY_LABELS: Record<Quality, string> = {
  excellent: "Excellent",
  good: "Good",
  fair: "Fair",
  weak: "Weak",
  none: "No signal",
}

export const QUALITY_TEXT: Record<Quality, string> = {
  excellent: "#fde725",
  good: "#8fdc5a",
  fair: "#38c9a6",
  weak: "#7f9cf0",
  none: "#ff8589",
}

export const SIGNAL_FLOOR_DBM = -82
export const SIGNAL_CEILING_DBM = -35
export const MEAN_FLOOR_DBM = -100

export const HEAT_ALPHA = 0.62
const HEAT_STOPS = ["#3b528b", "#2c728e", "#21918c", "#28ae80", "#5ec962", "#addc30", "#fde725"]

export interface Point {
  x: number
  y: number
}

export interface Obstacle {
  x1: number
  y1: number
  x2: number
  y2: number
  minX: number
  maxX: number
  minY: number
  maxY: number
  loss: number
}

export interface Emitter {
  index: number
  x: number
  y: number
  power: number
}

export interface CoverageInput {
  width: number
  height: number
  walls: Wall[]
  accessPoints: AccessPoint[]
  band: Band
  exponent: number
}

export interface GridShape {
  cols: number
  rows: number
  cellWidth: number
  cellHeight: number
}

export interface CoverageGrid extends GridShape {
  rssi: Float32Array
  best: Int16Array
}

export interface CoverageStats {
  cells: number
  target: number
  atTarget: number
  quality: Record<Quality, number>
  servedBy: number[]
  meanDbm: number
}

export interface PlacementInput extends CoverageInput {
  target: number
  alongWalls: boolean
}

export interface PlacementMove {
  id: string
  x: number
  y: number
}

export interface PlacementResult {
  moves: PlacementMove[]
  before: number
  after: number
  beforeMeanDbm: number
  afterMeanDbm: number
  candidates: number
  movable: number
}

export function qualityOf(rssi: number): Quality {
  for (const level of QUALITY_LEVELS) {
    if (rssi >= level.min) return level.quality
  }
  return "none"
}

export function qualityRange(quality: Quality): string {
  const index = QUALITY_LEVELS.findIndex((level) => level.quality === quality)
  if (quality === "none") return `below ${SIGNAL_FLOOR_DBM} dBm`
  if (index === 0) return `${QUALITY_LEVELS[0].min} dBm and up`
  return `${QUALITY_LEVELS[index].min} to ${QUALITY_LEVELS[index - 1].min} dBm`
}

export function formatDbm(rssi: number): string {
  return Number.isFinite(rssi) ? `${Math.round(rssi)} dBm` : "No signal"
}

export function formatPercent(fraction: number): string {
  if (!Number.isFinite(fraction)) return "-"
  const value = fraction * 100
  if (value > 0 && value < 1) return "<1%"
  return `${Math.round(value)}%`
}

export function formatMeters(value: number): string {
  return `${value.toFixed(2)} m`
}

function hexToRgb(hex: string): [number, number, number] {
  const value = Number.parseInt(hex.slice(1), 16)
  return [(value >> 16) & 255, (value >> 8) & 255, value & 255]
}

function buildHeatTable(): Uint8ClampedArray {
  const stops = HEAT_STOPS.map(hexToRgb)
  const table = new Uint8ClampedArray(256 * 4)
  for (let i = 0; i < 256; i += 1) {
    const position = (i / 255) * (stops.length - 1)
    const low = Math.min(Math.floor(position), stops.length - 2)
    const t = position - low
    for (let channel = 0; channel < 3; channel += 1) {
      table[i * 4 + channel] = stops[low][channel] + (stops[low + 1][channel] - stops[low][channel]) * t
    }
    table[i * 4 + 3] = Math.round(HEAT_ALPHA * 255)
  }
  return table
}

export const HEAT_TABLE = buildHeatTable()

export function heatIndex(rssi: number): number {
  if (!(rssi >= SIGNAL_FLOOR_DBM)) return -1
  const t = (rssi - SIGNAL_FLOOR_DBM) / (SIGNAL_CEILING_DBM - SIGNAL_FLOOR_DBM)
  return Math.max(0, Math.min(255, Math.round(t * 255)))
}

export function heatColor(rssi: number): string {
  const index = heatIndex(rssi)
  if (index < 0) return "transparent"
  return `rgb(${HEAT_TABLE[index * 4]}, ${HEAT_TABLE[index * 4 + 1]}, ${HEAT_TABLE[index * 4 + 2]})`
}

export function qualityColor(quality: Quality): string {
  const middle: Record<Quality, number> = { excellent: -45, good: -61, fair: -71, weak: -78.5, none: -100 }
  return heatColor(middle[quality])
}

export function wallLength(wall: Wall): number {
  return Math.hypot(wall.x2 - wall.x1, wall.y2 - wall.y1)
}

export function distanceToSegment(px: number, py: number, x1: number, y1: number, x2: number, y2: number): number {
  const dx = x2 - x1
  const dy = y2 - y1
  const lengthSquared = dx * dx + dy * dy
  const t = lengthSquared === 0 ? 0 : Math.max(0, Math.min(1, ((px - x1) * dx + (py - y1) * dy) / lengthSquared))
  return Math.hypot(px - (x1 + t * dx), py - (y1 + t * dy))
}

export function distanceToWall(point: Point, wall: Wall): number {
  return distanceToSegment(point.x, point.y, wall.x1, wall.y1, wall.x2, wall.y2)
}

export function obstaclesFor(walls: Wall[], band: Band): Obstacle[] {
  return walls.map((wall) => ({
    x1: wall.x1,
    y1: wall.y1,
    x2: wall.x2,
    y2: wall.y2,
    minX: Math.min(wall.x1, wall.x2),
    maxX: Math.max(wall.x1, wall.x2),
    minY: Math.min(wall.y1, wall.y2),
    maxY: Math.max(wall.y1, wall.y2),
    loss: WALL_LOSS_DB[wall.material][band],
  }))
}

export function crosses(ax: number, ay: number, bx: number, by: number, obstacle: Obstacle): boolean {
  const dx = bx - ax
  const dy = by - ay
  const d1 = dx * (obstacle.y1 - ay) - dy * (obstacle.x1 - ax)
  const d2 = dx * (obstacle.y2 - ay) - dy * (obstacle.x2 - ax)
  if ((d1 > 0) === (d2 > 0)) return false
  const ex = obstacle.x2 - obstacle.x1
  const ey = obstacle.y2 - obstacle.y1
  const d3 = ex * (ay - obstacle.y1) - ey * (ax - obstacle.x1)
  const d4 = ex * (by - obstacle.y1) - ey * (bx - obstacle.x1)
  return d3 * d4 < 0
}

export function crossingLoss(ax: number, ay: number, bx: number, by: number, obstacles: Obstacle[]): number {
  const minX = Math.min(ax, bx)
  const maxX = Math.max(ax, bx)
  const minY = Math.min(ay, by)
  const maxY = Math.max(ay, by)
  let loss = 0
  for (const obstacle of obstacles) {
    if (obstacle.maxX < minX || obstacle.minX > maxX || obstacle.maxY < minY || obstacle.minY > maxY) continue
    if (crosses(ax, ay, bx, by, obstacle)) loss += obstacle.loss
  }
  return loss
}

export function pathLossDb(distance: number, band: Band, exponent: number): number {
  return REFERENCE_LOSS_DB[band] + 10 * exponent * Math.log10(Math.max(distance, MIN_DISTANCE_M))
}

export function bandEnabled(accessPoint: AccessPoint, band: Band): boolean {
  return band === "2.4" ? accessPoint.band_24 : accessPoint.band_5
}

export function bandPower(accessPoint: AccessPoint, band: Band): number {
  return band === "2.4" ? accessPoint.power_24_dbm : accessPoint.power_5_dbm
}

export function emittersFor(accessPoints: AccessPoint[], band: Band): Emitter[] {
  const emitters: Emitter[] = []
  accessPoints.forEach((accessPoint, index) => {
    if (bandEnabled(accessPoint, band)) {
      emitters.push({ index, x: accessPoint.x, y: accessPoint.y, power: bandPower(accessPoint, band) })
    }
  })
  return emitters
}

export function signalAt(
  emitter: Emitter,
  x: number,
  y: number,
  band: Band,
  exponent: number,
  obstacles: Obstacle[],
): number {
  const distance = Math.hypot(x - emitter.x, y - emitter.y)
  return emitter.power - pathLossDb(distance, band, exponent) - crossingLoss(emitter.x, emitter.y, x, y, obstacles)
}

export function signalFrom(
  accessPoint: AccessPoint,
  point: Point,
  band: Band,
  exponent: number,
  obstacles: Obstacle[],
): number {
  if (!bandEnabled(accessPoint, band)) return Number.NEGATIVE_INFINITY
  const emitter = { index: 0, x: accessPoint.x, y: accessPoint.y, power: bandPower(accessPoint, band) }
  return signalAt(emitter, point.x, point.y, band, exponent, obstacles)
}

export function gridShape(width: number, height: number, cell: number): GridShape {
  const cols = Math.max(1, Math.round(width / cell))
  const rows = Math.max(1, Math.round(height / cell))
  return { cols, rows, cellWidth: width / cols, cellHeight: height / rows }
}

export function cellSizeFor(width: number, height: number, preferred: number, maxCells: number): number {
  return Math.max(preferred, Math.sqrt((width * height) / maxCells))
}

export function computeGrid(input: CoverageInput, cell: number): CoverageGrid {
  const shape = gridShape(input.width, input.height, cell)
  const { cols, rows, cellWidth, cellHeight } = shape
  const rssi = new Float32Array(cols * rows).fill(Number.NEGATIVE_INFINITY)
  const best = new Int16Array(cols * rows).fill(-1)
  const obstacles = obstaclesFor(input.walls, input.band)
  for (const emitter of emittersFor(input.accessPoints, input.band)) {
    for (let row = 0; row < rows; row += 1) {
      const y = (row + 0.5) * cellHeight
      for (let col = 0; col < cols; col += 1) {
        const value = signalAt(emitter, (col + 0.5) * cellWidth, y, input.band, input.exponent, obstacles)
        const index = row * cols + col
        if (value > rssi[index]) {
          rssi[index] = value
          best[index] = emitter.index
        }
      }
    }
  }
  return { ...shape, rssi, best }
}

export function gridStats(grid: CoverageGrid, accessPointCount: number, target: number): CoverageStats {
  const cells = grid.rssi.length
  const counts: Record<Quality, number> = { excellent: 0, good: 0, fair: 0, weak: 0, none: 0 }
  const served = new Array<number>(accessPointCount).fill(0)
  let atTarget = 0
  let sum = 0
  for (let index = 0; index < cells; index += 1) {
    const value = grid.rssi[index]
    if (value >= target) atTarget += 1
    const quality = qualityOf(value)
    counts[quality] += 1
    const owner = grid.best[index]
    if (quality !== "none" && owner >= 0 && owner < accessPointCount) served[owner] += 1
    sum += value > MEAN_FLOOR_DBM ? value : MEAN_FLOOR_DBM
  }
  const share = (count: number) => (cells === 0 ? 0 : count / cells)
  return {
    cells,
    target,
    atTarget: share(atTarget),
    quality: {
      excellent: share(counts.excellent),
      good: share(counts.good),
      fair: share(counts.fair),
      weak: share(counts.weak),
      none: share(counts.none),
    },
    servedBy: served.map(share),
    meanDbm: cells === 0 ? MEAN_FLOOR_DBM : sum / cells,
  }
}

const EVAL_CELL_M = 0.5
const EVAL_CELLS_MAX = 4000

const CANDIDATE_SPACING_M = 0.5
const CANDIDATES_MAX = 2500

const WALL_CLEARANCE_M = 0.15
const WALL_OFFSET_M = 0.3
const ALONG_WALL_M = 0.4
const EDGE_MARGIN_M = 0.1

const REFINE_ROUNDS = 4

function nearAnyWall(point: Point, walls: Wall[], limit: number): boolean {
  return walls.some((wall) => distanceToWall(point, wall) < limit)
}

function insidePlan(point: Point, width: number, height: number): boolean {
  return (
    point.x >= EDGE_MARGIN_M &&
    point.y >= EDGE_MARGIN_M &&
    point.x <= width - EDGE_MARGIN_M &&
    point.y <= height - EDGE_MARGIN_M
  )
}

function gridPoints(width: number, height: number, spacing: number): Point[] {
  const shape = gridShape(width, height, spacing)
  const points: Point[] = []
  for (let row = 0; row < shape.rows; row += 1) {
    for (let col = 0; col < shape.cols; col += 1) {
      points.push({ x: (col + 0.5) * shape.cellWidth, y: (row + 0.5) * shape.cellHeight })
    }
  }
  return points
}

function thin(points: Point[], limit: number): Point[] {
  if (points.length <= limit) return points
  const step = points.length / limit
  return Array.from({ length: limit }, (_, index) => points[Math.floor(index * step)])
}

export function placementCandidates(width: number, height: number, walls: Wall[], alongWalls: boolean): Point[] {
  const spacing = Math.max(CANDIDATE_SPACING_M, Math.sqrt((width * height) / CANDIDATES_MAX))
  const free = gridPoints(width, height, spacing).filter((point) => !nearAnyWall(point, walls, WALL_CLEARANCE_M))
  if (!alongWalls || walls.length === 0) return thin(free, CANDIDATES_MAX)
  const seen = new Set<string>()
  const points: Point[] = []
  const add = (point: Point) => {
    const key = `${Math.round(point.x * 20)}:${Math.round(point.y * 20)}`
    if (seen.has(key)) return
    seen.add(key)
    points.push(point)
  }
  for (const wall of walls) {
    const length = wallLength(wall)
    if (length === 0) continue
    const nx = -(wall.y2 - wall.y1) / length
    const ny = (wall.x2 - wall.x1) / length
    const samples = Math.max(1, Math.round(length / spacing))
    for (let sample = 0; sample < samples; sample += 1) {
      const t = (sample + 0.5) / samples
      const bx = wall.x1 + (wall.x2 - wall.x1) * t
      const by = wall.y1 + (wall.y2 - wall.y1) * t
      for (const side of [-1, 1]) {
        const point = { x: bx + nx * WALL_OFFSET_M * side, y: by + ny * WALL_OFFSET_M * side }
        if (insidePlan(point, width, height) && !nearAnyWall(point, walls, WALL_CLEARANCE_M)) add(point)
      }
    }
  }
  for (const point of free) {
    if (nearAnyWall(point, walls, ALONG_WALL_M)) add(point)
  }
  return points.length > 0 ? thin(points, CANDIDATES_MAX) : thin(free, CANDIDATES_MAX)
}

interface Score {
  covered: number
  sum: number
}

function better(a: Score, b: Score): boolean {
  return a.covered > b.covered || (a.covered === b.covered && a.sum > b.sum + 1e-6)
}

function scoreOf(values: Float32Array, target: number): Score {
  let covered = 0
  let sum = 0
  for (let index = 0; index < values.length; index += 1) {
    const value = values[index]
    if (value >= target) covered += 1
    sum += value > MEAN_FLOOR_DBM ? value : MEAN_FLOOR_DBM
  }
  return { covered, sum }
}

function round2(value: number): number {
  return Math.round(value * 100) / 100
}

export function* placementSteps(input: PlacementInput): Generator<number, PlacementResult, void> {
  const { width, height, walls, accessPoints, band, exponent, target } = input
  const obstacles = obstaclesFor(walls, band)
  const emitters = emittersFor(accessPoints, band)
  const movable = emitters.filter((emitter) => !accessPoints[emitter.index].locked)
  const fixed = emitters.filter((emitter) => accessPoints[emitter.index].locked)

  const shape = gridShape(width, height, cellSizeFor(width, height, EVAL_CELL_M, EVAL_CELLS_MAX))
  const cells = shape.cols * shape.rows
  const xs = new Float32Array(cells)
  const ys = new Float32Array(cells)
  for (let row = 0; row < shape.rows; row += 1) {
    for (let col = 0; col < shape.cols; col += 1) {
      xs[row * shape.cols + col] = (col + 0.5) * shape.cellWidth
      ys[row * shape.cols + col] = (row + 0.5) * shape.cellHeight
    }
  }

  const fill = (sources: Emitter[]) => {
    const values = new Float32Array(cells).fill(Number.NEGATIVE_INFINITY)
    for (const emitter of sources) {
      for (let index = 0; index < cells; index += 1) {
        const value = signalAt(emitter, xs[index], ys[index], band, exponent, obstacles)
        if (value > values[index]) values[index] = value
      }
    }
    return values
  }

  const beforeScore = scoreOf(fill(emitters), target)
  const summary = (score: Score) => ({ share: score.covered / cells, mean: score.sum / cells })
  const before = summary(beforeScore)
  const unchanged = movable.map((emitter) => ({
    id: accessPoints[emitter.index].id,
    x: emitter.x,
    y: emitter.y,
  }))

  if (movable.length === 0) {
    return {
      moves: [],
      before: before.share,
      after: before.share,
      beforeMeanDbm: before.mean,
      afterMeanDbm: before.mean,
      candidates: 0,
      movable: 0,
    }
  }

  const candidates = [
    ...placementCandidates(width, height, walls, input.alongWalls),
    ...movable.map((emitter) => ({ x: emitter.x, y: emitter.y })),
  ]
  const count = candidates.length
  const loss = new Float32Array(count * cells)
  for (let candidate = 0; candidate < count; candidate += 1) {
    const { x, y } = candidates[candidate]
    const offset = candidate * cells
    for (let index = 0; index < cells; index += 1) {
      const distance = Math.hypot(xs[index] - x, ys[index] - y)
      loss[offset + index] = pathLossDb(distance, band, exponent) + crossingLoss(x, y, xs[index], ys[index], obstacles)
    }
    if (candidate % 16 === 15) yield (0.85 * (candidate + 1)) / count
  }

  const base = fill(fixed)

  const evaluate = (background: Float32Array, power: number, candidate: number): Score => {
    const offset = candidate * cells
    let covered = 0
    let sum = 0
    for (let index = 0; index < cells; index += 1) {
      const own = power - loss[offset + index]
      const value = own > background[index] ? own : background[index]
      if (value >= target) covered += 1
      sum += value > MEAN_FLOOR_DBM ? value : MEAN_FLOOR_DBM
    }
    return { covered, sum }
  }

  const bestCandidate = (background: Float32Array, power: number) => {
    let bestIndex = 0
    let bestScore = evaluate(background, power, 0)
    for (let candidate = 1; candidate < count; candidate += 1) {
      const score = evaluate(background, power, candidate)
      if (better(score, bestScore)) {
        bestIndex = candidate
        bestScore = score
      }
    }
    return { index: bestIndex, score: bestScore }
  }

  const merge = (values: Float32Array, power: number, candidate: number) => {
    const offset = candidate * cells
    for (let index = 0; index < cells; index += 1) {
      const own = power - loss[offset + index]
      if (own > values[index]) values[index] = own
    }
  }

  const placement = new Array<number>(movable.length).fill(0)
  const combined = Float32Array.from(base)
  for (let k = 0; k < movable.length; k += 1) {
    placement[k] = bestCandidate(combined, movable[k].power).index
    merge(combined, movable[k].power, placement[k])
    yield 0.85 + (0.05 * (k + 1)) / movable.length
  }

  for (let round = 0; round < REFINE_ROUNDS; round += 1) {
    let changed = false
    for (let k = 0; k < movable.length; k += 1) {
      const background = Float32Array.from(base)
      for (let other = 0; other < movable.length; other += 1) {
        if (other !== k) merge(background, movable[other].power, placement[other])
      }
      const current = evaluate(background, movable[k].power, placement[k])
      const found = bestCandidate(background, movable[k].power)
      if (better(found.score, current)) {
        placement[k] = found.index
        changed = true
      }
    }
    yield 0.9 + (0.1 * (round + 1)) / REFINE_ROUNDS
    if (!changed) break
  }

  const final = Float32Array.from(base)
  movable.forEach((emitter, k) => merge(final, emitter.power, placement[k]))
  const afterScore = scoreOf(final, target)
  if (better(beforeScore, afterScore)) {
    return {
      moves: unchanged,
      before: before.share,
      after: before.share,
      beforeMeanDbm: before.mean,
      afterMeanDbm: before.mean,
      candidates: count,
      movable: movable.length,
    }
  }
  const after = summary(afterScore)
  return {
    moves: movable.map((emitter, k) => ({
      id: accessPoints[emitter.index].id,
      x: round2(candidates[placement[k]].x),
      y: round2(candidates[placement[k]].y),
    })),
    before: before.share,
    after: after.share,
    beforeMeanDbm: before.mean,
    afterMeanDbm: after.mean,
    candidates: count,
    movable: movable.length,
  }
}
