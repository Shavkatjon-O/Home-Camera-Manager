"use client"

import { useSyncExternalStore } from "react"

import type { CameraEvent, EventKind, EventSourceState } from "@/lib/types"

export const EVENT_KINDS: EventKind[] = ["motion", "person", "vehicle", "tamper", "storage", "reboot"]

export const KIND_LABELS: Record<EventKind, string> = {
  motion: "Motion",
  person: "Person",
  vehicle: "Vehicle",
  tamper: "Tamper",
  storage: "Storage",
  reboot: "Restart",
}

export const SOURCE_LABELS: Record<EventSourceState, string> = {
  connecting: "Connecting",
  live: "Live",
  reconnecting: "Reconnecting",
  unsupported: "Not supported",
  disabled: "Disabled",
}

export const SOURCE_TONES: Record<EventSourceState, string> = {
  connecting: "bg-status-off",
  live: "bg-status-ok",
  reconnecting: "bg-status-warn",
  unsupported: "bg-status-off",
  disabled: "bg-status-off",
}

const ACTIVITY_KINDS: EventKind[] = ["motion", "person", "vehicle"]

export function isActivity(kind: EventKind): boolean {
  return ACTIVITY_KINDS.includes(kind)
}

export function eventTitle(event: Pick<CameraEvent, "kind" | "camera_name">): string {
  const camera = event.camera_name ?? "A camera"
  switch (event.kind) {
    case "motion":
      return `Motion on ${camera}`
    case "person":
      return `Person on ${camera}`
    case "vehicle":
      return `Vehicle on ${camera}`
    case "tamper":
      return `${camera} view disturbed`
    case "storage":
      return `${camera} storage problem`
    case "reboot":
      return `${camera} restarted`
  }
}

function pad(value: number): string {
  return String(value).padStart(2, "0")
}

export function localDay(date: Date): string {
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`
}

export function dayRange(day: string): { from: string; to: string } | null {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(day)
  if (!match) return null
  const start = new Date(Number(match[1]), Number(match[2]) - 1, Number(match[3]))
  if (Number.isNaN(start.getTime())) return null
  const end = new Date(start.getFullYear(), start.getMonth(), start.getDate() + 1)
  return { from: start.toISOString(), to: end.toISOString() }
}

export function topicLabel(topic: string): string {
  const parts = topic.split("/").filter(Boolean)
  const meaningful = parts.filter((part) => !/Service$/.test(part))
  return meaningful.slice(-2).join(" / ") || topic
}

const MUTE_KEY = "hc-event-alerts-muted"
const muteListeners = new Set<() => void>()
let memoryMuted = false

function readMuted(): boolean {
  try {
    const stored = window.localStorage.getItem(MUTE_KEY)
    return stored === null ? memoryMuted : stored === "1"
  } catch {
    return memoryMuted
  }
}

function subscribeMuted(listener: () => void) {
  muteListeners.add(listener)
  window.addEventListener("storage", listener)
  return () => {
    muteListeners.delete(listener)
    window.removeEventListener("storage", listener)
  }
}

export function setAlertsMuted(value: boolean) {
  memoryMuted = value
  try {
    window.localStorage.setItem(MUTE_KEY, value ? "1" : "0")
  } catch {}
  muteListeners.forEach((listener) => listener())
}

export function useAlertsMuted(): boolean {
  return useSyncExternalStore(subscribeMuted, readMuted, () => false)
}
