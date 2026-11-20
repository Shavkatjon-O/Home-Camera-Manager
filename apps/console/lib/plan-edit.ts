import { PRESETS, type Point } from "@/lib/coverage"
import type {
  AccessPoint,
  AccessPointPreset,
  Device,
  FloorPlan,
  FloorPlanUpdate,
  PlanSettings,
  Wall,
  WallMaterial,
} from "@/lib/types"

export interface PlanDoc {
  name: string
  width_m: number
  height_m: number
  walls: Wall[]
  access_points: AccessPoint[]
  devices: Device[]
  settings: PlanSettings
  background_image: string | null
  background_opacity: number
}

export type DocField = keyof PlanDoc

export const DOC_FIELDS: DocField[] = [
  "name",
  "width_m",
  "height_m",
  "walls",
  "access_points",
  "devices",
  "settings",
  "background_image",
  "background_opacity",
]

export type Tool = "select" | "wall" | "room" | "router" | "device"

export type Selection =
  | { kind: "wall"; id: string }
  | { kind: "ap"; id: string }
  | { kind: "device"; id: string }
  | null

export const PLAN_SIZE_MIN_M = 1
export const PLAN_SIZE_MAX_M = 200
export const PLAN_WIDTH_DEFAULT_M = 15
export const PLAN_HEIGHT_DEFAULT_M = 12

export const ENDPOINT_SNAP_M = 0.25
export const ANGLE_SNAP_DEG = 5
export const WALL_MIN_M = 0.1
export const ROOM_MIN_M = 0.2

export const SNAP_OPTIONS = [0.05, 0.1, 0.25, 0.5, 1]

export function docFromPlan(plan: FloorPlan): PlanDoc {
  return {
    name: plan.name,
    width_m: plan.width_m,
    height_m: plan.height_m,
    walls: plan.walls,
    access_points: plan.access_points,
    devices: plan.devices,
    settings: plan.settings,
    background_image: plan.background_image,
    background_opacity: plan.background_opacity,
  }
}

export function changedFields(doc: PlanDoc, saved: PlanDoc): DocField[] {
  return DOC_FIELDS.filter((field) => doc[field] !== saved[field])
}

export function updatePayload(doc: PlanDoc, fields: DocField[]): FloorPlanUpdate {
  const payload: FloorPlanUpdate = {}
  for (const field of fields) {
    if (field === "background_image") payload.background_image = doc.background_image ?? ""
    else Object.assign(payload, { [field]: doc[field] })
  }
  return payload
}

export function pickFields(doc: PlanDoc, fields: DocField[]): Partial<PlanDoc> {
  const picked: Partial<PlanDoc> = {}
  for (const field of fields) Object.assign(picked, { [field]: doc[field] })
  return picked
}

export function clean(value: number): number {
  return Math.round(value * 10000) / 10000
}

export function snapValue(value: number, step: number): number {
  return clean(Math.round(value / step) * step)
}

export function clampToPlan(point: Point, width: number, height: number): Point {
  return {
    x: clean(Math.min(Math.max(point.x, 0), width)),
    y: clean(Math.min(Math.max(point.y, 0), height)),
  }
}

export function snapToGrid(point: Point, step: number, width: number, height: number): Point {
  return clampToPlan({ x: snapValue(point.x, step), y: snapValue(point.y, step) }, width, height)
}

export function wallEndpoints(walls: Wall[], skip?: { id: string; end: 1 | 2 }): Point[] {
  const points: Point[] = []
  for (const wall of walls) {
    if (!(skip && skip.id === wall.id && skip.end === 1)) points.push({ x: wall.x1, y: wall.y1 })
    if (!(skip && skip.id === wall.id && skip.end === 2)) points.push({ x: wall.x2, y: wall.y2 })
  }
  return points
}

export function snapPoint(
  raw: Point,
  options: { step: number; width: number; height: number; endpoints: Point[]; anchor?: Point | null },
): Point {
  let nearest: Point | null = null
  let nearestDistance = ENDPOINT_SNAP_M
  for (const endpoint of options.endpoints) {
    const distance = Math.hypot(endpoint.x - raw.x, endpoint.y - raw.y)
    if (distance <= nearestDistance) {
      nearest = endpoint
      nearestDistance = distance
    }
  }
  if (nearest) return nearest
  let point = { x: snapValue(raw.x, options.step), y: snapValue(raw.y, options.step) }
  const anchor = options.anchor
  if (anchor && (raw.x !== anchor.x || raw.y !== anchor.y)) {
    const angle = (Math.abs(Math.atan2(raw.y - anchor.y, raw.x - anchor.x)) * 180) / Math.PI
    if (angle <= ANGLE_SNAP_DEG || angle >= 180 - ANGLE_SNAP_DEG) point = { x: point.x, y: anchor.y }
    else if (Math.abs(angle - 90) <= ANGLE_SNAP_DEG) point = { x: anchor.x, y: point.y }
  }
  return clampToPlan(point, options.width, options.height)
}

export function newId(prefix: string, taken: { id: string }[]): string {
  const used = new Set(taken.map((item) => item.id))
  for (;;) {
    const id = `${prefix}${Math.random().toString(36).slice(2, 10)}`
    if (!used.has(id)) return id
  }
}

export function nextName(base: string, items: { name: string }[]): string {
  const pattern = new RegExp(`^${base} (\\d+)$`)
  let highest = 0
  for (const item of items) {
    const match = pattern.exec(item.name)
    if (match) highest = Math.max(highest, Number(match[1]))
  }
  return `${base} ${highest + 1}`
}

export function roomWalls(a: Point, b: Point, material: WallMaterial, ids: string[]): Wall[] {
  const left = Math.min(a.x, b.x)
  const right = Math.max(a.x, b.x)
  const top = Math.min(a.y, b.y)
  const bottom = Math.max(a.y, b.y)
  return [
    { id: ids[0], x1: left, y1: top, x2: right, y2: top, material },
    { id: ids[1], x1: right, y1: top, x2: right, y2: bottom, material },
    { id: ids[2], x1: right, y1: bottom, x2: left, y2: bottom, material },
    { id: ids[3], x1: left, y1: bottom, x2: left, y2: top, material },
  ]
}

export function presetFields(preset: AccessPointPreset): Partial<AccessPoint> {
  const values = PRESETS[preset]
  return {
    preset,
    band_24: values.band_24,
    band_5: values.band_5,
    power_24_dbm: values.power_24_dbm,
    power_5_dbm: values.power_5_dbm,
  }
}

export function newAccessPoint(id: string, name: string, point: Point): AccessPoint {
  return {
    id,
    name,
    x: point.x,
    y: point.y,
    preset: "generic",
    band_24: true,
    band_5: true,
    power_24_dbm: PRESETS.generic.power_24_dbm,
    power_5_dbm: PRESETS.generic.power_5_dbm,
    locked: false,
  }
}

export function contentExtent(doc: PlanDoc): Point {
  let x = 0
  let y = 0
  for (const wall of doc.walls) {
    x = Math.max(x, wall.x1, wall.x2)
    y = Math.max(y, wall.y1, wall.y2)
  }
  for (const item of [...doc.access_points, ...doc.devices]) {
    x = Math.max(x, item.x)
    y = Math.max(y, item.y)
  }
  return { x, y }
}

function clampSize(value: number): number {
  return Math.round(Math.min(Math.max(value, PLAN_SIZE_MIN_M), PLAN_SIZE_MAX_M) * 100) / 100
}

export function sizeForImage(doc: PlanDoc, aspect: number): { width_m: number; height_m: number } {
  const extent = contentExtent(doc)
  let width = Math.max(doc.width_m, extent.x)
  let height = width * aspect
  if (height < extent.y) {
    height = extent.y
    width = height / aspect
  }
  if (height > PLAN_SIZE_MAX_M) {
    height = PLAN_SIZE_MAX_M
    width = height / aspect
  }
  if (width > PLAN_SIZE_MAX_M) {
    width = PLAN_SIZE_MAX_M
    height = width * aspect
  }
  return {
    width_m: Math.max(clampSize(width), Math.ceil(extent.x * 100) / 100),
    height_m: Math.max(clampSize(height), Math.ceil(extent.y * 100) / 100),
  }
}

export function fitsPlan(doc: PlanDoc, width: number, height: number): boolean {
  const extent = contentExtent(doc)
  return extent.x <= width + 1e-6 && extent.y <= height + 1e-6
}
