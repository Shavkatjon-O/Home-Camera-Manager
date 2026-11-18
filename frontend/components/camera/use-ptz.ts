"use client"

import * as React from "react"
import { toast } from "sonner"

import type { PtzControls } from "@/components/camera/ptz-pad"
import { api, errorMessage } from "@/lib/api"
import type { PtzVector } from "@/lib/types"

function scaled(direction: PtzVector, speed: number): PtzVector {
  const round = (value: number) => Math.round(Math.max(-1, Math.min(1, value * speed)) * 100) / 100
  return { pan: round(direction.pan), tilt: round(direction.tilt), zoom: round(direction.zoom) }
}

export function usePtz(uuid: string, speed: number): PtzControls {
  const queue = React.useRef<Promise<void>>(Promise.resolve())
  const moving = React.useRef(false)
  const speedRef = React.useRef(speed)

  React.useEffect(() => {
    speedRef.current = speed
  }, [speed])

  const enqueue = React.useCallback((task: () => Promise<void>) => {
    queue.current = queue.current.then(task).catch((err: unknown) => {
      toast.error(errorMessage(err), { id: "ptz-error" })
    })
  }, [])

  const start = React.useCallback(
    (direction: PtzVector) => {
      moving.current = true
      const vector = scaled(direction, speedRef.current)
      enqueue(() => api.ptzMove(uuid, vector))
    },
    [enqueue, uuid],
  )

  const stop = React.useCallback(() => {
    if (!moving.current) return
    moving.current = false
    enqueue(() => api.ptzStop(uuid))
  }, [enqueue, uuid])

  const halt = React.useCallback(() => {
    moving.current = false
    enqueue(() => api.ptzStop(uuid))
  }, [enqueue, uuid])

  React.useEffect(
    () => () => {
      if (moving.current) {
        moving.current = false
        void api.ptzStop(uuid).catch(() => undefined)
      }
    },
    [uuid],
  )

  return React.useMemo(() => ({ start, stop, halt }), [start, stop, halt])
}

const KEY_DIRECTIONS: Record<string, PtzVector> = {
  ArrowUp: { pan: 0, tilt: 1, zoom: 0 },
  ArrowDown: { pan: 0, tilt: -1, zoom: 0 },
  ArrowLeft: { pan: -1, tilt: 0, zoom: 0 },
  ArrowRight: { pan: 1, tilt: 0, zoom: 0 },
  "+": { pan: 0, tilt: 0, zoom: 1 },
  "=": { pan: 0, tilt: 0, zoom: 1 },
  "-": { pan: 0, tilt: 0, zoom: -1 },
}

function isEditable(target: EventTarget | null): boolean {
  if (!(target instanceof HTMLElement)) return false
  if (target.isContentEditable) return true
  if (["INPUT", "TEXTAREA", "SELECT"].includes(target.tagName)) return true
  return target.getAttribute("role") === "slider"
}

export function usePtzKeyboard(controls: PtzControls | null) {
  const pressed = React.useRef(new Set<string>())

  const apply = React.useCallback(() => {
    if (!controls) return
    const sum = { pan: 0, tilt: 0, zoom: 0 }
    pressed.current.forEach((key) => {
      const direction = KEY_DIRECTIONS[key]
      sum.pan += direction.pan
      sum.tilt += direction.tilt
      sum.zoom += direction.zoom
    })
    const clamp = (value: number) => Math.max(-1, Math.min(1, value))
    const vector = { pan: clamp(sum.pan), tilt: clamp(sum.tilt), zoom: clamp(sum.zoom) }
    if (vector.pan === 0 && vector.tilt === 0 && vector.zoom === 0) controls.stop()
    else controls.start(vector)
  }, [controls])

  const onKeyDown = React.useCallback(
    (event: React.KeyboardEvent) => {
      if (!controls || !(event.key in KEY_DIRECTIONS) || isEditable(event.target)) return
      if (event.altKey || event.ctrlKey || event.metaKey) return
      event.preventDefault()
      if (event.repeat || pressed.current.has(event.key)) return
      pressed.current.add(event.key)
      apply()
    },
    [apply, controls],
  )

  const onKeyUp = React.useCallback(
    (event: React.KeyboardEvent) => {
      if (!pressed.current.has(event.key)) return
      pressed.current.delete(event.key)
      apply()
    },
    [apply],
  )

  const onBlur = React.useCallback(
    (event: React.FocusEvent) => {
      if (event.currentTarget.contains(event.relatedTarget as Node | null)) return
      if (pressed.current.size === 0) return
      pressed.current.clear()
      controls?.stop()
    },
    [controls],
  )

  return { onKeyDown, onKeyUp, onBlur }
}
