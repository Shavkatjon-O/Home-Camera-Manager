"use client"

import * as React from "react"
import { LockIcon, ZoomInIcon, ZoomOutIcon } from "lucide-react"
import { toast } from "sonner"

import { IconButton } from "@/components/shell/icon-button"
import { Button } from "@/components/ui/button"
import {
  HEAT_TABLE,
  QUALITY_TEXT,
  WALL_STYLES,
  bandEnabled,
  formatDbm,
  heatIndex,
  qualityOf,
  type CoverageGrid,
  type Point,
} from "@/lib/coverage"
import {
  ROOM_MIN_M,
  WALL_MIN_M,
  newAccessPoint,
  newId,
  nextName,
  roomWalls,
  snapPoint,
  snapToGrid,
  wallEndpoints,
  type PlanDoc,
  type Selection,
  type Tool,
} from "@/lib/plan-edit"
import type { Band, Device, Wall, WallMaterial } from "@/lib/types"
import { cn } from "@/lib/utils"

interface View {
  scale: number
  ox: number
  oy: number
}

type Update = (doc: PlanDoc) => PlanDoc

type Gesture =
  | { kind: "pan"; start: Point; view: View; moved: boolean; clear: boolean }
  | { kind: "pinch"; distance: number; mid: Point; view: View }
  | { kind: "move"; target: "ap" | "device"; id: string; offset: Point; start: Point; moved: boolean }
  | { kind: "end"; id: string; end: 1 | 2; start: Point; moved: boolean }
  | { kind: "wall"; anchor: Point }
  | { kind: "room"; anchor: Point }
  | { kind: "place"; target: "ap" | "device"; start: Point; world: Point }

type Draft = { kind: "wall" | "room"; a: Point; b: Point } | null

export interface Ghost {
  id: string
  name: string
  from: Point
  to: Point
}

const FIT_PADDING_PX = 28
const SCALE_MIN = 2
const SCALE_MAX = 400
const WHEEL_ZOOM = 0.0015
const BUTTON_ZOOM = 1.3

const CLICK_SLOP_PX = 6
const DRAG_SLOP_PX = 3
const OUTSIDE_TOLERANCE_M = 0.5

const ACCESS_POINTS_MAX = 20
const DEVICES_MAX = 200
const WALLS_MAX = 2000

const SCALE_STEPS = [0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50, 100]
const SCALE_BAR_PX = 110

const MONO_CHAR_PX = 6.7
const LABEL_FILL = "#ffffff"
const LABEL_HALO = "rgba(0, 0, 0, 0.8)"

function clampScale(scale: number): number {
  return Math.min(SCALE_MAX, Math.max(SCALE_MIN, scale))
}

function fitView(size: { width: number; height: number }, width: number, height: number): View {
  if (size.width <= 0 || size.height <= 0) return { scale: 10, ox: 0, oy: 0 }
  const scale = clampScale(
    Math.min((size.width - FIT_PADDING_PX * 2) / width, (size.height - FIT_PADDING_PX * 2) / height),
  )
  return { scale, ox: (size.width - width * scale) / 2, oy: (size.height - height * scale) / 2 }
}

function zoomAt(view: View, point: Point, factor: number): View {
  const scale = clampScale(view.scale * factor)
  const ratio = scale / view.scale
  return { scale, ox: point.x - (point.x - view.ox) * ratio, oy: point.y - (point.y - view.oy) * ratio }
}

function localPoint(event: { clientX: number; clientY: number }, element: HTMLElement): Point {
  const rect = element.getBoundingClientRect()
  return { x: event.clientX - rect.left, y: event.clientY - rect.top }
}

function distance(a: Point, b: Point): number {
  return Math.hypot(a.x - b.x, a.y - b.y)
}

function midpoint(a: Point, b: Point): Point {
  return { x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 }
}

function heatImage(grid: CoverageGrid): HTMLCanvasElement | null {
  const canvas = document.createElement("canvas")
  canvas.width = grid.cols
  canvas.height = grid.rows
  const context = canvas.getContext("2d")
  if (!context) return null
  const image = context.createImageData(grid.cols, grid.rows)
  for (let cell = 0; cell < grid.rssi.length; cell += 1) {
    const index = heatIndex(grid.rssi[cell])
    if (index < 0) continue
    image.data[cell * 4] = HEAT_TABLE[index * 4]
    image.data[cell * 4 + 1] = HEAT_TABLE[index * 4 + 1]
    image.data[cell * 4 + 2] = HEAT_TABLE[index * 4 + 2]
    image.data[cell * 4 + 3] = HEAT_TABLE[index * 4 + 3]
  }
  context.putImageData(image, 0, 0)
  return canvas
}

function gridPath(doc: PlanDoc, view: View): { minor: string; major: string } {
  const step = view.scale >= 8 ? 1 : view.scale >= 2.5 ? 5 : 10
  const left = view.ox
  const top = view.oy
  const right = view.ox + doc.width_m * view.scale
  const bottom = view.oy + doc.height_m * view.scale
  let minor = ""
  let major = ""
  for (let x = step; x < doc.width_m; x += step) {
    const line = `M${(left + x * view.scale).toFixed(1)} ${top.toFixed(1)}V${bottom.toFixed(1)}`
    if (Math.round(x) % (step * 5) === 0) major += line
    else minor += line
  }
  for (let y = step; y < doc.height_m; y += step) {
    const line = `M${left.toFixed(1)} ${(top + y * view.scale).toFixed(1)}H${right.toFixed(1)}`
    if (Math.round(y) % (step * 5) === 0) major += line
    else minor += line
  }
  return { minor, major }
}

function scaleBar(scale: number): { meters: number; pixels: number } {
  let meters = SCALE_STEPS[0]
  for (const step of SCALE_STEPS) {
    if (step * scale <= SCALE_BAR_PX) meters = step
  }
  return { meters, pixels: meters * scale }
}

function moveItem<T extends { id: string; x: number; y: number }>(items: T[], id: string, point: Point): T[] | null {
  const item = items.find((entry) => entry.id === id)
  if (!item || (item.x === point.x && item.y === point.y)) return null
  return items.map((entry) => (entry.id === id ? { ...entry, x: point.x, y: point.y } : entry))
}

function moveEnd(walls: Wall[], id: string, end: 1 | 2, point: Point): Wall[] | null {
  const wall = walls.find((entry) => entry.id === id)
  if (!wall) return null
  const same = end === 1 ? wall.x1 === point.x && wall.y1 === point.y : wall.x2 === point.x && wall.y2 === point.y
  if (same) return null
  return walls.map((entry) => {
    if (entry.id !== id) return entry
    return end === 1 ? { ...entry, x1: point.x, y1: point.y } : { ...entry, x2: point.x, y2: point.y }
  })
}

function Label({ x, y, children }: { x: number; y: number; children: React.ReactNode }) {
  return (
    <text
      x={x}
      y={y}
      fontSize={11}
      className="font-data"
      fill={LABEL_FILL}
      stroke={LABEL_HALO}
      strokeWidth={3}
      paintOrder="stroke"
      strokeLinejoin="round"
    >
      {children}
    </text>
  )
}

export function PlanEditor({
  doc,
  tool,
  band,
  grid,
  selection,
  material,
  ghosts,
  deviceSignals,
  onSelect,
  onCommit,
  onGestureStart,
  onGesturePreview,
  onGestureEnd,
  onDraggingChange,
}: {
  doc: PlanDoc
  tool: Tool
  band: Band
  grid: CoverageGrid | null
  selection: Selection
  material: WallMaterial
  ghosts: Ghost[]
  deviceSignals: Record<string, number>
  onSelect: (selection: Selection) => void
  onCommit: (update: Update) => void
  onGestureStart: () => void
  onGesturePreview: (update: Update) => void
  onGestureEnd: () => void
  onDraggingChange: (dragging: boolean) => void
}) {
  const containerRef = React.useRef<HTMLDivElement>(null)
  const canvasRef = React.useRef<HTMLCanvasElement>(null)
  const heatCache = React.useRef<{ grid: CoverageGrid | null; image: HTMLCanvasElement | null }>({
    grid: null,
    image: null,
  })
  const gesture = React.useRef<Gesture | null>(null)
  const pointers = React.useRef(new Map<number, Point>())
  const [size, setSize] = React.useState({ width: 0, height: 0 })
  const [manualView, setManualView] = React.useState<View | null>(null)
  const [draft, setDraft] = React.useState<Draft>(null)

  const view = manualView ?? fitView(size, doc.width_m, doc.height_m)

  React.useEffect(() => {
    const element = containerRef.current
    if (!element) return
    const observer = new ResizeObserver((entries) => {
      const box = entries[0].contentRect
      setSize({ width: box.width, height: box.height })
    })
    observer.observe(element)
    return () => observer.disconnect()
  }, [])

  React.useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const ratio = window.devicePixelRatio || 1
    const width = Math.max(1, Math.round(size.width * ratio))
    const height = Math.max(1, Math.round(size.height * ratio))
    if (canvas.width !== width) canvas.width = width
    if (canvas.height !== height) canvas.height = height
    const context = canvas.getContext("2d")
    if (!context) return
    context.setTransform(1, 0, 0, 1, 0, 0)
    context.clearRect(0, 0, width, height)
    if (!grid) return
    const cache = heatCache.current
    if (cache.grid !== grid) {
      cache.grid = grid
      cache.image = heatImage(grid)
    }
    if (!cache.image) return
    context.setTransform(ratio, 0, 0, ratio, 0, 0)
    context.imageSmoothingEnabled = true
    context.imageSmoothingQuality = "high"
    context.drawImage(cache.image, view.ox, view.oy, doc.width_m * view.scale, doc.height_m * view.scale)
  }, [grid, size, view.ox, view.oy, view.scale, doc.width_m, doc.height_m])

  const onWheel = React.useEffectEvent((event: WheelEvent) => {
    const element = containerRef.current
    if (!element) return
    event.preventDefault()
    const point = localPoint(event, element)
    const factor = Math.exp(-event.deltaY * WHEEL_ZOOM * (event.deltaMode === 1 ? 16 : 1))
    const fitted = fitView(size, doc.width_m, doc.height_m)
    setManualView((current) => zoomAt(current ?? fitted, point, factor))
  })

  React.useEffect(() => {
    const element = containerRef.current
    if (!element) return
    const listener = (event: WheelEvent) => onWheel(event)
    element.addEventListener("wheel", listener, { passive: false })
    return () => element.removeEventListener("wheel", listener)
  }, [])

  const toWorld = (point: Point): Point => ({
    x: (point.x - view.ox) / view.scale,
    y: (point.y - view.oy) / view.scale,
  })

  const snapOptions = (anchor: Point | null = null, skip?: { id: string; end: 1 | 2 }) => ({
    step: doc.settings.snap_m,
    width: doc.width_m,
    height: doc.height_m,
    endpoints: wallEndpoints(doc.walls, skip),
    anchor,
  })

  const insidePlan = (point: Point) =>
    point.x >= -OUTSIDE_TOLERANCE_M &&
    point.y >= -OUTSIDE_TOLERANCE_M &&
    point.x <= doc.width_m + OUTSIDE_TOLERANCE_M &&
    point.y <= doc.height_m + OUTSIDE_TOLERANCE_M

  const finishDrag = (current: Gesture) => {
    if ((current.kind === "move" || current.kind === "end") && current.moved) {
      onGestureEnd()
      onDraggingChange(false)
    }
  }

  const startPinch = () => {
    const current = gesture.current
    if (current) finishDrag(current)
    setDraft(null)
    const [a, b] = [...pointers.current.values()]
    gesture.current = { kind: "pinch", distance: Math.max(1, distance(a, b)), mid: midpoint(a, b), view }
  }

  const onPointerDown = (event: React.PointerEvent<HTMLDivElement>) => {
    const element = containerRef.current
    if (!element || (event.button !== 0 && event.button !== 1)) return
    try {
      element.setPointerCapture(event.pointerId)
    } catch {}
    const local = localPoint(event, element)
    pointers.current.set(event.pointerId, local)
    if (pointers.current.size === 2) {
      startPinch()
      return
    }
    if (pointers.current.size > 2) return
    const world = toWorld(local)
    if (event.button === 1) {
      event.preventDefault()
      gesture.current = { kind: "pan", start: local, view, moved: true, clear: false }
      return
    }
    const hit = event.target instanceof Element ? event.target.closest("[data-kind]") : null
    const kind = hit?.getAttribute("data-kind") ?? null
    const id = hit?.getAttribute("data-id") ?? ""
    if (tool === "select") {
      if (kind === "ap" || kind === "device") {
        const items: { id: string; x: number; y: number }[] = kind === "ap" ? doc.access_points : doc.devices
        const item = items.find((entry) => entry.id === id)
        if (!item) return
        onSelect({ kind, id })
        gesture.current = {
          kind: "move",
          target: kind,
          id,
          offset: { x: world.x - item.x, y: world.y - item.y },
          start: local,
          moved: false,
        }
        return
      }
      if (kind === "endpoint") {
        gesture.current = { kind: "end", id, end: hit?.getAttribute("data-end") === "2" ? 2 : 1, start: local, moved: false }
        return
      }
      if (kind === "wall") onSelect({ kind: "wall", id })
      gesture.current = { kind: "pan", start: local, view, moved: false, clear: kind !== "wall" }
      return
    }
    if (tool === "wall" || tool === "room") {
      if (!insidePlan(world)) {
        gesture.current = { kind: "pan", start: local, view, moved: false, clear: false }
        return
      }
      const anchor = snapPoint(world, snapOptions())
      gesture.current = { kind: tool, anchor }
      setDraft({ kind: tool, a: anchor, b: anchor })
      return
    }
    gesture.current = { kind: "place", target: tool === "router" ? "ap" : "device", start: local, world }
  }

  const onPointerMove = (event: React.PointerEvent<HTMLDivElement>) => {
    const element = containerRef.current
    if (!element || !pointers.current.has(event.pointerId)) return
    const local = localPoint(event, element)
    pointers.current.set(event.pointerId, local)
    const current = gesture.current
    if (!current) return
    if (current.kind === "pinch") {
      if (pointers.current.size < 2) return
      const [a, b] = [...pointers.current.values()]
      const mid = midpoint(a, b)
      const scale = clampScale((current.view.scale * distance(a, b)) / current.distance)
      const ratio = scale / current.view.scale
      setManualView({
        scale,
        ox: mid.x - (current.mid.x - current.view.ox) * ratio,
        oy: mid.y - (current.mid.y - current.view.oy) * ratio,
      })
      return
    }
    if (current.kind === "pan") {
      const dx = local.x - current.start.x
      const dy = local.y - current.start.y
      if (!current.moved && Math.hypot(dx, dy) < CLICK_SLOP_PX) return
      current.moved = true
      setManualView({ scale: current.view.scale, ox: current.view.ox + dx, oy: current.view.oy + dy })
      return
    }
    if (current.kind === "place") {
      if (distance(local, current.start) >= CLICK_SLOP_PX) {
        gesture.current = { kind: "pan", start: current.start, view, moved: true, clear: false }
        setManualView({ ...view, ox: view.ox + local.x - current.start.x, oy: view.oy + local.y - current.start.y })
      }
      return
    }
    const world = toWorld(local)
    if (current.kind === "wall") {
      setDraft({ kind: "wall", a: current.anchor, b: snapPoint(world, snapOptions(current.anchor)) })
      return
    }
    if (current.kind === "room") {
      setDraft({ kind: "room", a: current.anchor, b: snapPoint(world, snapOptions()) })
      return
    }
    if (!current.moved) {
      if (distance(local, current.start) < DRAG_SLOP_PX) return
      current.moved = true
      onGestureStart()
      onDraggingChange(true)
    }
    if (current.kind === "move") {
      const point = snapToGrid(
        { x: world.x - current.offset.x, y: world.y - current.offset.y },
        doc.settings.snap_m,
        doc.width_m,
        doc.height_m,
      )
      const { id, target } = current
      onGesturePreview((value) => {
        if (target === "ap") {
          const moved = moveItem(value.access_points, id, point)
          return moved ? { ...value, access_points: moved } : value
        }
        const moved = moveItem(value.devices, id, point)
        return moved ? { ...value, devices: moved } : value
      })
      return
    }
    const wall = doc.walls.find((entry) => entry.id === current.id)
    if (!wall) return
    const other = current.end === 1 ? { x: wall.x2, y: wall.y2 } : { x: wall.x1, y: wall.y1 }
    const point = snapPoint(world, snapOptions(other, { id: wall.id, end: current.end }))
    if (distance(point, other) < WALL_MIN_M) return
    const { id, end } = current
    onGesturePreview((value) => {
      const moved = moveEnd(value.walls, id, end, point)
      return moved ? { ...value, walls: moved } : value
    })
  }

  const onPointerUp = (event: React.PointerEvent<HTMLDivElement>) => {
    const element = containerRef.current
    if (!element || !pointers.current.has(event.pointerId)) return
    pointers.current.delete(event.pointerId)
    const current = gesture.current
    if (!current) return
    if (current.kind === "pinch") {
      if (pointers.current.size === 0) gesture.current = null
      return
    }
    gesture.current = null
    const cancelled = event.type === "pointercancel"
    const world = toWorld(localPoint(event, element))
    if (current.kind === "pan") {
      if (!current.moved && current.clear) onSelect(null)
      return
    }
    if (current.kind === "move" || current.kind === "end") {
      finishDrag(current)
      return
    }
    if (current.kind === "wall") {
      setDraft(null)
      if (cancelled) return
      const end = snapPoint(world, snapOptions(current.anchor))
      if (distance(end, current.anchor) < WALL_MIN_M) return
      if (doc.walls.length >= WALLS_MAX) {
        toast.error(`A plan holds at most ${WALLS_MAX} walls`)
        return
      }
      const wall: Wall = {
        id: newId("w", doc.walls),
        x1: current.anchor.x,
        y1: current.anchor.y,
        x2: end.x,
        y2: end.y,
        material,
      }
      onCommit((value) => ({ ...value, walls: [...value.walls, wall] }))
      onSelect({ kind: "wall", id: wall.id })
      return
    }
    if (current.kind === "room") {
      setDraft(null)
      if (cancelled) return
      const corner = snapPoint(world, snapOptions())
      if (Math.abs(corner.x - current.anchor.x) < ROOM_MIN_M || Math.abs(corner.y - current.anchor.y) < ROOM_MIN_M) {
        return
      }
      if (doc.walls.length + 4 > WALLS_MAX) {
        toast.error(`A plan holds at most ${WALLS_MAX} walls`)
        return
      }
      const taken: { id: string }[] = [...doc.walls]
      const ids = [0, 1, 2, 3].map(() => {
        const id = newId("w", taken)
        taken.push({ id })
        return id
      })
      const walls = roomWalls(current.anchor, corner, material, ids)
      onCommit((value) => ({ ...value, walls: [...value.walls, ...walls] }))
      onSelect(null)
      return
    }
    if (cancelled || !insidePlan(current.world)) return
    const point = snapToGrid(current.world, doc.settings.snap_m, doc.width_m, doc.height_m)
    if (current.target === "ap") {
      if (doc.access_points.length >= ACCESS_POINTS_MAX) {
        toast.error(`A plan holds at most ${ACCESS_POINTS_MAX} routers`)
        return
      }
      const accessPoint = newAccessPoint(newId("ap", doc.access_points), nextName("Router", doc.access_points), point)
      onCommit((value) => ({ ...value, access_points: [...value.access_points, accessPoint] }))
      onSelect({ kind: "ap", id: accessPoint.id })
      return
    }
    if (doc.devices.length >= DEVICES_MAX) {
      toast.error(`A plan holds at most ${DEVICES_MAX} devices`)
      return
    }
    const device: Device = {
      id: newId("d", doc.devices),
      name: nextName("Device", doc.devices),
      x: point.x,
      y: point.y,
      band: "2.4",
    }
    onCommit((value) => ({ ...value, devices: [...value.devices, device] }))
    onSelect({ kind: "device", id: device.id })
  }

  const sx = (x: number) => view.ox + x * view.scale
  const sy = (y: number) => view.oy + y * view.scale
  const planWidth = doc.width_m * view.scale
  const planHeight = doc.height_m * view.scale
  const lines = gridPath(doc, view)
  const bar = scaleBar(view.scale)
  const selectedWall =
    tool === "select" && selection?.kind === "wall" ? doc.walls.find((wall) => wall.id === selection.id) : undefined
  const center = { x: size.width / 2, y: size.height / 2 }

  return (
    <div
      ref={containerRef}
      role="application"
      aria-label="Floor plan editor"
      onPointerDown={onPointerDown}
      onPointerMove={onPointerMove}
      onPointerUp={onPointerUp}
      onPointerCancel={onPointerUp}
      onContextMenu={(event) => event.preventDefault()}
      className={cn(
        "relative size-full touch-none overflow-hidden bg-background select-none",
        tool === "wall" || tool === "room" ? "cursor-crosshair" : tool === "select" ? "cursor-default" : "cursor-copy",
      )}
    >
      <div
        className="absolute border border-hairline-strong bg-surface"
        style={{ left: view.ox, top: view.oy, width: planWidth, height: planHeight }}
      />
      {doc.background_image ? (
        <svg aria-hidden className="pointer-events-none absolute inset-0 size-full">
          <image
            href={doc.background_image}
            x={view.ox}
            y={view.oy}
            width={planWidth}
            height={planHeight}
            preserveAspectRatio="none"
            opacity={doc.background_opacity}
          />
        </svg>
      ) : null}
      <canvas ref={canvasRef} aria-hidden className="pointer-events-none absolute inset-0 size-full" />
      <svg className="absolute inset-0 size-full">
        <path d={lines.minor} stroke="var(--border-strong)" strokeOpacity={0.22} strokeWidth={1} fill="none" pointerEvents="none" />
        <path d={lines.major} stroke="var(--border-strong)" strokeOpacity={0.45} strokeWidth={1} fill="none" pointerEvents="none" />
        {doc.walls.map((wall) => {
          const style = WALL_STYLES[wall.material]
          const selected = selection?.kind === "wall" && selection.id === wall.id
          return (
            <g key={wall.id} data-kind="wall" data-id={wall.id}>
              {selected ? (
                <line
                  x1={sx(wall.x1)}
                  y1={sy(wall.y1)}
                  x2={sx(wall.x2)}
                  y2={sy(wall.y2)}
                  stroke="var(--focus)"
                  strokeOpacity={0.6}
                  strokeWidth={style.width + 6}
                  strokeLinecap="round"
                />
              ) : null}
              <line
                x1={sx(wall.x1)}
                y1={sy(wall.y1)}
                x2={sx(wall.x2)}
                y2={sy(wall.y2)}
                stroke={style.color}
                strokeWidth={style.width}
                strokeDasharray={style.dash}
                strokeLinecap={style.dash ? "butt" : "round"}
              />
              <line
                x1={sx(wall.x1)}
                y1={sy(wall.y1)}
                x2={sx(wall.x2)}
                y2={sy(wall.y2)}
                stroke="transparent"
                strokeWidth={14}
              />
            </g>
          )
        })}
        {selectedWall
          ? ([1, 2] as const).map((end) => (
              <circle
                key={end}
                data-kind="endpoint"
                data-id={selectedWall.id}
                data-end={end}
                cx={sx(end === 1 ? selectedWall.x1 : selectedWall.x2)}
                cy={sy(end === 1 ? selectedWall.y1 : selectedWall.y2)}
                r={6}
                fill="var(--surface)"
                stroke="var(--focus)"
                strokeWidth={2}
                className="cursor-move"
              />
            ))
          : null}
        {draft?.kind === "wall" ? (
          <g pointerEvents="none">
            <line
              x1={sx(draft.a.x)}
              y1={sy(draft.a.y)}
              x2={sx(draft.b.x)}
              y2={sy(draft.b.y)}
              stroke={WALL_STYLES[material].color}
              strokeWidth={WALL_STYLES[material].width}
              strokeDasharray="5 4"
            />
            <Label x={sx((draft.a.x + draft.b.x) / 2) + 8} y={sy((draft.a.y + draft.b.y) / 2) - 8}>
              {`${distance(draft.a, draft.b).toFixed(2)} m`}
            </Label>
          </g>
        ) : null}
        {draft?.kind === "room" ? (
          <g pointerEvents="none">
            <rect
              x={sx(Math.min(draft.a.x, draft.b.x))}
              y={sy(Math.min(draft.a.y, draft.b.y))}
              width={Math.abs(draft.b.x - draft.a.x) * view.scale}
              height={Math.abs(draft.b.y - draft.a.y) * view.scale}
              fill="none"
              stroke={WALL_STYLES[material].color}
              strokeWidth={WALL_STYLES[material].width}
              strokeDasharray="5 4"
            />
            <Label x={sx(Math.max(draft.a.x, draft.b.x)) + 8} y={sy(Math.max(draft.a.y, draft.b.y)) + 14}>
              {`${Math.abs(draft.b.x - draft.a.x).toFixed(2)} x ${Math.abs(draft.b.y - draft.a.y).toFixed(2)} m`}
            </Label>
          </g>
        ) : null}
        {ghosts.map((ghost) => (
          <g key={ghost.id} pointerEvents="none">
            <line
              x1={sx(ghost.from.x)}
              y1={sy(ghost.from.y)}
              x2={sx(ghost.to.x)}
              y2={sy(ghost.to.y)}
              stroke="var(--focus)"
              strokeWidth={1.5}
              strokeDasharray="4 4"
            />
            <circle
              cx={sx(ghost.to.x)}
              cy={sy(ghost.to.y)}
              r={11}
              fill="none"
              stroke="var(--focus)"
              strokeWidth={2}
              strokeDasharray="4 3"
            />
            <circle cx={sx(ghost.to.x)} cy={sy(ghost.to.y)} r={4} fill="var(--focus)" />
            <Label x={sx(ghost.to.x) + 16} y={sy(ghost.to.y) + 4}>
              {ghost.name}
            </Label>
          </g>
        ))}
        {doc.devices.map((device) => {
          const rssi = deviceSignals[device.id] ?? Number.NEGATIVE_INFINITY
          const value = formatDbm(rssi)
          const selected = selection?.kind === "device" && selection.id === device.id
          const x = sx(device.x)
          const y = sy(device.y)
          const width = (device.name.length + value.length + 1) * MONO_CHAR_PX + 12
          return (
            <g key={device.id} data-kind="device" data-id={device.id} className={tool === "select" ? "cursor-grab" : undefined}>
              <circle cx={x} cy={y} r={14} fill="transparent" />
              {selected ? <circle cx={x} cy={y} r={10} fill="none" stroke="var(--focus)" strokeWidth={2} /> : null}
              <rect
                x={x - 4.5}
                y={y - 4.5}
                width={9}
                height={9}
                transform={`rotate(45 ${x} ${y})`}
                fill="#ffffff"
                stroke="#000000"
                strokeWidth={1.5}
              />
              <g transform={`translate(${x + 11} ${y - 22})`}>
                <rect width={width} height={18} rx={4} fill="rgba(0, 0, 0, 0.72)" />
                <text x={6} y={12.5} fontSize={11} className="font-data">
                  <tspan fill="#ffffff">{device.name}</tspan>
                  <tspan dx={MONO_CHAR_PX} fill={QUALITY_TEXT[qualityOf(rssi)]}>
                    {value}
                  </tspan>
                </text>
              </g>
            </g>
          )
        })}
        {doc.access_points.map((accessPoint) => {
          const enabled = bandEnabled(accessPoint, band)
          const selected = selection?.kind === "ap" && selection.id === accessPoint.id
          const x = sx(accessPoint.x)
          const y = sy(accessPoint.y)
          return (
            <g
              key={accessPoint.id}
              data-kind="ap"
              data-id={accessPoint.id}
              opacity={enabled ? 1 : 0.5}
              className={tool === "select" ? "cursor-grab" : undefined}
            >
              <circle cx={x} cy={y} r={16} fill="transparent" />
              <circle
                cx={x}
                cy={y}
                r={11}
                fill="none"
                stroke={selected ? "var(--focus)" : "#ffffff"}
                strokeOpacity={selected ? 1 : 0.75}
                strokeWidth={selected ? 2.5 : 1.5}
              />
              <circle cx={x} cy={y} r={4.5} fill="#ffffff" stroke="#000000" strokeWidth={1.5} />
              {accessPoint.locked ? (
                <LockIcon x={x + 6} y={y - 20} width={11} height={11} color="#ffffff" strokeWidth={2.5} />
              ) : null}
              <Label x={x + 16} y={y + 4}>
                {enabled ? accessPoint.name : `${accessPoint.name} (off on this band)`}
              </Label>
            </g>
          )
        })}
      </svg>
      {doc.access_points.length === 0 ? (
        <div className="pointer-events-none absolute inset-x-3 top-3 flex justify-center">
          <div className="max-w-md rounded-md border border-hairline bg-surface/90 px-3 py-2 text-center text-[12px] text-text-2">
            Pick Router and click the plan to see its coverage. Walls are optional and only sharpen the picture.
          </div>
        </div>
      ) : null}
      <div
        className="absolute top-3 right-3 flex items-center gap-0.5 rounded-md border border-hairline bg-surface/90 p-0.5"
        onPointerDown={(event) => event.stopPropagation()}
      >
        <IconButton
          label="Zoom out"
          size="icon-sm"
          side="bottom"
          onClick={() => setManualView(zoomAt(view, center, 1 / BUTTON_ZOOM))}
        >
          <ZoomOutIcon />
        </IconButton>
        <IconButton label="Zoom in" size="icon-sm" side="bottom" onClick={() => setManualView(zoomAt(view, center, BUTTON_ZOOM))}>
          <ZoomInIcon />
        </IconButton>
        <Button variant="ghost" size="sm" onClick={() => setManualView(null)}>
          Fit
        </Button>
      </div>
      <div className="pointer-events-none absolute bottom-3 left-3 flex flex-col items-start gap-1">
        <span className="font-data text-[11px] text-text-2">{bar.meters >= 1 ? `${bar.meters} m` : `${Math.round(bar.meters * 100)} cm`}</span>
        <span className="block h-1.5 border-x border-b border-text-2" style={{ width: bar.pixels }} />
      </div>
    </div>
  )
}
