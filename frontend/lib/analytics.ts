"use client"

import { useSyncExternalStore } from "react"

import { api } from "@/lib/api"
import { labelName } from "@/lib/events"
import type {
  AlertMode,
  AlertPolicy,
  AnalyticsLine,
  AnalyticsLineInput,
  AnalyticsProfile,
  AnalyticsView,
  AnalyticsZone,
  AnalyticsZoneInput,
  ArmMode,
  LabelCounts,
  LineDirection,
  TimeWindow,
  ViewPoint,
  ViewState,
} from "@/lib/types"

export const ARM_MODES: ArmMode[] = ["disarmed", "home", "away", "schedule"]

export const ARM_MODE_LABELS: Record<ArmMode, string> = {
  disarmed: "Disarmed",
  home: "Home",
  away: "Away",
  schedule: "Schedule",
}

export const PROFILES: AnalyticsProfile[] = ["perimeter", "vehicle", "identity", "tamper"]

export const PROFILE_LABELS: Record<AnalyticsProfile, string> = {
  perimeter: "Perimeter",
  vehicle: "Vehicle",
  identity: "Identity",
  tamper: "Tamper",
}

export const DIRECTIONS: LineDirection[] = ["in", "out", "both"]

export const DIRECTION_LABELS: Record<LineDirection, string> = {
  in: "In",
  out: "Out",
  both: "Both",
}

export const ALERT_MODES: AlertMode[] = ["off", "always", "schedule"]

export const ALERT_MODE_LABELS: Record<AlertMode, string> = {
  off: "Off",
  always: "Always",
  schedule: "On schedule",
}

export const VIEW_STATE_LABELS: Record<ViewState, string> = {
  live: "Live",
  stalled: "Stalled",
  disabled: "Disabled",
}

export const VIEW_STATE_TONES: Record<ViewState, string> = {
  live: "bg-status-ok",
  stalled: "bg-status-warn",
  disabled: "bg-status-off",
}

export const DAY_NAMES = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

export const CLASS_GROUPS = ["person", "vehicle", "animal"]

export const CLASS_LABELS = ["car", "truck", "bus", "motorcycle", "bicycle", "dog", "cat", "bird", "backpack", "handbag", "suitcase"]

const VEHICLE_LABELS = ["vehicle", "car", "truck", "bus", "motorcycle", "bicycle"]

const ANIMAL_LABELS = ["animal", "dog", "cat", "bird"]

export function labelColor(label: string): string {
  if (label === "person") return "var(--status-warn)"
  if (VEHICLE_LABELS.includes(label)) return "var(--focus)"
  if (ANIMAL_LABELS.includes(label)) return "var(--status-ok)"
  return "#ffffff"
}

export function viewTitle(view: Pick<AnalyticsView, "lens" | "lenses" | "name">): string {
  return view.lenses > 1 && view.lens > 0 ? `Lens ${view.lens}` : view.name
}

export function viewForLens(views: AnalyticsView[], lenses: number, lens: number | null): AnalyticsView | null {
  if (lenses > 1 && lens !== null) return views.find((view) => view.lens === lens + 1) ?? null
  return views.find((view) => view.lens === 0) ?? (views.length === 1 ? views[0] : null)
}

export function countsText(counts: LabelCounts | undefined): string {
  const entries = Object.entries(counts ?? {}).filter(([, value]) => value > 0)
  if (entries.length === 0) return "Empty"
  return entries.map(([label, value]) => `${labelName(label)} ${value}`).join(", ")
}

export function countTotal(counts: LabelCounts | undefined): number {
  return Object.values(counts ?? {}).reduce((sum, value) => sum + value, 0)
}

const armListeners = new Set<() => void>()
let armMode: ArmMode | null = null
let armLoading: Promise<void> | null = null

function notifyArm() {
  armListeners.forEach((listener) => listener())
}

function subscribeArm(listener: () => void) {
  armListeners.add(listener)
  return () => {
    armListeners.delete(listener)
  }
}

export function useArmMode(): ArmMode | null {
  return useSyncExternalStore(subscribeArm, () => armMode, () => null)
}

export function refreshArmMode(): Promise<void> {
  if (armLoading) return armLoading
  armLoading = api
    .analyticsSettings()
    .then((settings) => {
      armMode = settings.arm_mode
      notifyArm()
    })
    .finally(() => {
      armLoading = null
    })
  return armLoading
}

export async function changeArmMode(mode: ArmMode): Promise<ArmMode> {
  const settings = await api.updateAnalyticsSettings({ arm_mode: mode })
  armMode = settings.arm_mode
  notifyArm()
  return settings.arm_mode
}

export type Tool = "select" | "zone" | "line"

export interface DraftZone extends AnalyticsZoneInput {
  key: string
  suspended: boolean
}

export interface DraftLine extends AnalyticsLineInput {
  key: string
  suspended: boolean
}

export type RuleSelection = { kind: "zone" | "line"; key: string } | null

export const WHOLE_VIEW: ViewPoint[] = [
  [0, 0],
  [1, 0],
  [1, 1],
  [0, 1],
]

export const NAME_MAX = 60

function copyWindows(windows: TimeWindow[]): TimeWindow[] {
  return windows.map((item) => ({ start: item.start, end: item.end, days: [...item.days] }))
}

function copyAlert(alert: AlertPolicy): AlertPolicy {
  return { mode: alert.mode, schedule: copyWindows(alert.schedule), labels: [...alert.labels] }
}

export function draftZone(zone: AnalyticsZone): DraftZone {
  return {
    key: zone.uuid,
    uuid: zone.uuid,
    name: zone.name,
    polygon: zone.polygon.map((point) => [point[0], point[1]]),
    whole_view: zone.whole_view,
    labels: [...zone.labels],
    min_dwell: zone.min_dwell,
    loiter_seconds: zone.loiter_seconds,
    crowd_count: zone.crowd_count,
    left_seconds: zone.left_seconds,
    taken_seconds: zone.taken_seconds,
    object_labels: [...zone.object_labels],
    background: zone.background,
    animals: zone.animals,
    schedule: copyWindows(zone.schedule),
    alert: copyAlert(zone.alert),
    enabled: zone.enabled,
    reference: zone.reference,
    suspended: zone.suspended,
  }
}

export function draftLine(line: AnalyticsLine): DraftLine {
  return {
    key: line.uuid,
    uuid: line.uuid,
    name: line.name,
    points: [
      [line.points[0][0], line.points[0][1]],
      [line.points[1][0], line.points[1][1]],
    ],
    labels: [...line.labels],
    direction: line.direction,
    animals: line.animals,
    schedule: copyWindows(line.schedule),
    alert: copyAlert(line.alert),
    enabled: line.enabled,
    reference: line.reference,
    suspended: line.suspended,
  }
}

function defaultAlert(): AlertPolicy {
  return { mode: "always", schedule: [], labels: [] }
}

export function newZone(key: string, name: string, polygon: ViewPoint[], wholeView: boolean): DraftZone {
  return {
    key,
    name,
    polygon,
    whole_view: wholeView,
    labels: [],
    min_dwell: 1,
    loiter_seconds: 0,
    crowd_count: 0,
    left_seconds: 0,
    taken_seconds: 0,
    object_labels: [],
    background: false,
    animals: "record",
    schedule: [],
    alert: defaultAlert(),
    enabled: true,
    reference: null,
    suspended: false,
  }
}

export function newLine(key: string, name: string, points: [ViewPoint, ViewPoint]): DraftLine {
  return {
    key,
    name,
    points,
    labels: [],
    direction: "both",
    animals: "record",
    schedule: [],
    alert: defaultAlert(),
    enabled: true,
    reference: null,
    suspended: false,
  }
}

export function newWindow(): TimeWindow {
  return { start: "22:00", end: "06:00", days: [] }
}

export function nextName(prefix: string, names: string[]): string {
  let index = 1
  while (names.includes(`${prefix} ${index}`)) index += 1
  return `${prefix} ${index}`
}

function round(value: number): number {
  return Math.round(value * 10000) / 10000
}

export function zoneInput(zone: DraftZone, reference: string | null): AnalyticsZoneInput {
  return {
    ...(zone.uuid ? { uuid: zone.uuid } : {}),
    name: zone.name.trim(),
    polygon: zone.polygon.map((point) => [round(point[0]), round(point[1])]),
    whole_view: zone.whole_view,
    labels: zone.labels,
    min_dwell: zone.min_dwell,
    loiter_seconds: zone.loiter_seconds,
    crowd_count: zone.crowd_count,
    left_seconds: zone.left_seconds,
    taken_seconds: zone.taken_seconds,
    object_labels: zone.object_labels,
    background: zone.background,
    animals: zone.animals,
    schedule: zone.schedule,
    alert: zone.alert,
    enabled: zone.enabled,
    reference,
  }
}

export function lineInput(line: DraftLine, reference: string | null): AnalyticsLineInput {
  return {
    ...(line.uuid ? { uuid: line.uuid } : {}),
    name: line.name.trim(),
    points: [
      [round(line.points[0][0]), round(line.points[0][1])],
      [round(line.points[1][0]), round(line.points[1][1])],
    ],
    labels: line.labels,
    direction: line.direction,
    animals: line.animals,
    schedule: line.schedule,
    alert: line.alert,
    enabled: line.enabled,
    reference,
  }
}

export function clamp01(value: number): number {
  return Math.min(1, Math.max(0, value))
}

export function inSide(a: ViewPoint, b: ViewPoint): ViewPoint {
  return [-(b[1] - a[1]), b[0] - a[0]]
}

export function isTime(value: string): boolean {
  return /^([01]\d|2[0-3]):[0-5]\d$/.test(value)
}

export function rulesProblem(zones: DraftZone[], lines: DraftLine[]): string | null {
  for (const zone of zones) {
    if (!zone.name.trim()) return "Every zone needs a name"
    if (zone.polygon.length < 3) return `${zone.name} needs at least 3 points`
    const windows = [...zone.schedule, ...zone.alert.schedule]
    if (windows.some((item) => !isTime(item.start) || !isTime(item.end))) {
      return `${zone.name} has a window without a start or end time`
    }
    if (zone.alert.mode === "schedule" && zone.alert.schedule.length === 0) {
      return `${zone.name} alerts on a schedule without any window`
    }
  }
  for (const line of lines) {
    if (!line.name.trim()) return "Every line needs a name"
    const windows = [...line.schedule, ...line.alert.schedule]
    if (windows.some((item) => !isTime(item.start) || !isTime(item.end))) {
      return `${line.name} has a window without a start or end time`
    }
    if (line.alert.mode === "schedule" && line.alert.schedule.length === 0) {
      return `${line.name} alerts on a schedule without any window`
    }
  }
  return null
}
