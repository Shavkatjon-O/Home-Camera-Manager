"use client"

import { useSyncExternalStore } from "react"

import type { AnalyticsEventDetails, Box, CameraEvent, EventBox, EventKind, EventOrigin, EventSourceState } from "@/lib/types"

export const EVENT_KINDS: EventKind[] = [
  "motion",
  "person",
  "vehicle",
  "intrusion",
  "line_crossing",
  "loitering",
  "crowd",
  "face_known",
  "face_unknown",
  "tamper",
  "storage",
  "reboot",
]

export const KIND_LABELS: Record<EventKind, string> = {
  motion: "Motion",
  person: "Person",
  vehicle: "Vehicle",
  intrusion: "Intrusion",
  line_crossing: "Line crossing",
  loitering: "Loitering",
  crowd: "Crowd",
  face_known: "Known face",
  face_unknown: "Unknown face",
  tamper: "Tamper",
  storage: "Storage",
  reboot: "Restart",
}

export const OBJECT_LABELS = ["person", "car", "truck", "bus", "motorcycle", "bicycle", "dog", "cat"]

export const TAMPER_LABELS = ["covered", "blurred", "moved"]

export const EVENT_LABELS = [...OBJECT_LABELS, ...TAMPER_LABELS]

const LABEL_NAMES: Record<string, string> = {
  person: "Person",
  car: "Car",
  truck: "Truck",
  bus: "Bus",
  motorcycle: "Motorcycle",
  bicycle: "Bicycle",
  dog: "Dog",
  cat: "Cat",
  covered: "Covered",
  blurred: "Blurred",
  moved: "Moved",
  vehicle: "Vehicle",
  animal: "Animal",
}

export function labelName(label: string): string {
  const known = LABEL_NAMES[label]
  if (known) return known
  const text = label.replace(/_/g, " ")
  return text.charAt(0).toUpperCase() + text.slice(1)
}

export const ORIGIN_LABELS: Record<EventOrigin, string> = {
  camera: "Camera",
  analytics: "Analytics",
}

function text(value: unknown): string | null {
  return typeof value === "string" && value ? value : null
}

function isBox(value: unknown): value is Box {
  return Array.isArray(value) && value.length === 4 && value.every((item) => typeof item === "number")
}

function eventBoxes(value: unknown): EventBox[] {
  if (!Array.isArray(value)) return []
  return value.flatMap((item) => {
    if (!item || typeof item !== "object") return []
    const entry = item as Record<string, unknown>
    if (!isBox(entry.box)) return []
    return [
      {
        object: typeof entry.object === "number" ? entry.object : 0,
        label: typeof entry.label === "string" ? entry.label : "",
        box: entry.box,
        at: typeof entry.at === "number" ? entry.at : 0,
      },
    ]
  })
}

export function analyticsDetails(event: Pick<CameraEvent, "source" | "details">): AnalyticsEventDetails | null {
  if (event.source !== "analytics") return null
  const details = event.details ?? {}
  const direction = details.direction === "in" || details.direction === "out" ? details.direction : null
  const objects = Array.isArray(details.objects)
    ? details.objects.filter((item): item is number => typeof item === "number")
    : []
  return {
    view_name: text(details.view_name),
    profile: text(details.profile),
    zone: text(details.zone),
    zone_name: text(details.zone_name),
    line: text(details.line),
    line_name: text(details.line_name),
    direction,
    objects,
    count: typeof details.count === "number" ? details.count : null,
    boxes: eventBoxes(details.boxes),
  }
}

export function eventPlace(event: Pick<CameraEvent, "source" | "details">): string | null {
  const details = analyticsDetails(event)
  return details ? (details.zone_name ?? details.line_name) : null
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

const ACTIVITY_KINDS: EventKind[] = ["motion", "person", "vehicle", "intrusion", "crowd"]

export function isActivity(kind: EventKind): boolean {
  return ACTIVITY_KINDS.includes(kind)
}

const TAMPER_TITLES: Record<string, string> = {
  covered: "covered",
  blurred: "blurred",
  moved: "moved",
}

type TitleEvent = Pick<CameraEvent, "kind" | "camera_name"> &
  Partial<Pick<CameraEvent, "label" | "source" | "details" | "face">>

export function eventTitle(event: TitleEvent): string {
  const camera = event.camera_name ?? "A camera"
  const label = event.label ? labelName(event.label) : null
  const details = event.source && event.details ? analyticsDetails({ source: event.source, details: event.details }) : null
  const zone = details?.zone_name ?? null
  const line = details?.line_name ?? null
  switch (event.kind) {
    case "motion":
      return `Motion on ${camera}`
    case "person":
      return `Person on ${camera}`
    case "vehicle":
      return `${label ?? "Vehicle"} on ${camera}`
    case "intrusion":
      return zone ? `${label ?? "Something"} entered ${zone} on ${camera}` : `Intrusion on ${camera}`
    case "line_crossing":
      return line ? `${label ?? "Something"} crossed ${line} on ${camera}` : `Line crossing on ${camera}`
    case "loitering":
      return zone ? `${label ?? "Someone"} loitering in ${zone} on ${camera}` : `Loitering on ${camera}`
    case "crowd":
      return zone ? `Crowd in ${zone} on ${camera}` : `Crowd on ${camera}`
    case "face_known":
      return `${event.face?.person_name ?? "A known person"} on ${camera}`
    case "face_unknown":
      return `${event.face?.cluster_label ?? "An unknown person"} on ${camera}`
    case "tamper": {
      const how = event.label ? TAMPER_TITLES[event.label] : undefined
      return how ? `${camera} view ${how}` : `${camera} view disturbed`
    }
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

const UNSEEN_KEY = "hc-unseen-alerts"
const UNSEEN_LIMIT = 200
const unseenListeners = new Set<() => void>()
let memoryUnseen: string[] = []

function readUnseen(): string[] {
  try {
    const stored = window.localStorage.getItem(UNSEEN_KEY)
    if (stored === null) return memoryUnseen
    const parsed: unknown = JSON.parse(stored)
    return Array.isArray(parsed) ? parsed.filter((item): item is string => typeof item === "string") : memoryUnseen
  } catch {
    return memoryUnseen
  }
}

function writeUnseen(value: string[]) {
  memoryUnseen = value
  try {
    window.localStorage.setItem(UNSEEN_KEY, JSON.stringify(value))
  } catch {}
  unseenListeners.forEach((listener) => listener())
}

function subscribeUnseen(listener: () => void) {
  unseenListeners.add(listener)
  window.addEventListener("storage", listener)
  return () => {
    unseenListeners.delete(listener)
    window.removeEventListener("storage", listener)
  }
}

export function addUnseenAlert(uuid: string) {
  const current = readUnseen()
  if (current.includes(uuid)) return
  writeUnseen([...current, uuid].slice(-UNSEEN_LIMIT))
}

export function clearUnseenAlerts() {
  if (readUnseen().length === 0) return
  writeUnseen([])
}

export function useUnseenAlerts(): number {
  return useSyncExternalStore(subscribeUnseen, () => readUnseen().length, () => 0)
}
