import { request } from "@/lib/api"

export type CountBucket = "hour" | "day"
export type Crossing = "in" | "out"

export interface CountLine {
  uuid: string
  name: string
  view_uuid: string
  view_name: string
  camera_uuid: string
  camera_name: string
  direction: string
  enabled: boolean
}

export interface CountBucketRow {
  line_uuid: string
  at: string
  label: string
  in: number
  out: number
}

export interface CountTotal {
  line_uuid: string
  in: number
  out: number
  labels: Record<string, { in: number; out: number }>
}

export interface CountsResponse {
  start: string
  end: string
  bucket: CountBucket
  timezone: string
  lines: CountLine[]
  buckets: CountBucketRow[]
  totals: CountTotal[]
}

export interface AreaLine {
  line_uuid: string
  line_name: string
  view_name: string
  entering: Crossing
}

export interface Area {
  uuid: string
  name: string
  occupancy: number
  entered: number
  exited: number
  since: string | null
  reset_at: string | null
  labels: string[]
  lines: AreaLine[]
  updated_at: string
}

export interface AreaInput {
  name: string
  lines: { line_uuid: string; entering: Crossing }[]
  labels: string[]
  reset_at: string | null
}

export const COUNT_LABELS = ["person", "bicycle", "car", "motorcycle", "bus", "truck", "dog", "cat", "bird"]

export const HOURS_PER_DAY = 24
export const DAILY_SPAN = 14

const HOUR_MS = 3600000

function pad(value: number): string {
  return String(value).padStart(2, "0")
}

export function isoWithOffset(date: Date): string {
  const offset = -date.getTimezoneOffset()
  const sign = offset >= 0 ? "+" : "-"
  const abs = Math.abs(offset)
  return (
    `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}` +
    `T${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}` +
    `${sign}${pad(Math.floor(abs / 60))}:${pad(abs % 60)}`
  )
}

export function startOfDay(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate())
}

export function addDays(date: Date, days: number): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate() + days)
}

export function sameDay(left: Date, right: Date): boolean {
  return (
    left.getFullYear() === right.getFullYear() &&
    left.getMonth() === right.getMonth() &&
    left.getDate() === right.getDate()
  )
}

function dayKey(date: Date): string {
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`
}

const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
const WEEKDAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

export function formatDay(date: Date): string {
  return `${WEEKDAYS[date.getDay()]} ${date.getDate()} ${MONTHS[date.getMonth()]} ${date.getFullYear()}`
}

export function formatShortDay(date: Date): string {
  return `${date.getDate()} ${MONTHS[date.getMonth()]}`
}

export function formatHour(hour: number): string {
  return `${pad(hour)}:00`
}

export interface CountsRange {
  start: Date
  end: Date
  bucket: CountBucket
}

export function dayRange(day: Date): CountsRange {
  const start = startOfDay(day)
  return { start, end: addDays(start, 1), bucket: "hour" }
}

export function dailyRange(day: Date): CountsRange {
  const end = addDays(startOfDay(day), 1)
  return { start: addDays(end, -DAILY_SPAN), end, bucket: "day" }
}

export function fetchCounts(range: CountsRange, signal?: AbortSignal): Promise<CountsResponse> {
  const search = new URLSearchParams({
    start: isoWithOffset(range.start),
    end: isoWithOffset(range.end),
    bucket: range.bucket,
  })
  return request<CountsResponse>(`/analytics/counts?${search.toString()}`, { signal })
}

export function fetchAreas(signal?: AbortSignal): Promise<{ items: Area[] }> {
  return request<{ items: Area[] }>("/analytics/areas", { signal })
}

export function createArea(body: AreaInput): Promise<Area> {
  return request<Area>("/analytics/areas", { method: "POST", body })
}

export function updateArea(uuid: string, body: Partial<AreaInput>): Promise<Area> {
  return request<Area>(`/analytics/areas/${encodeURIComponent(uuid)}`, { method: "PATCH", body })
}

export function deleteArea(uuid: string): Promise<void> {
  return request<void>(`/analytics/areas/${encodeURIComponent(uuid)}`, { method: "DELETE" })
}

export function resetArea(uuid: string, occupancy: number): Promise<Area> {
  return request<Area>(`/analytics/areas/${encodeURIComponent(uuid)}/reset`, {
    method: "POST",
    body: { occupancy },
  })
}

export interface Pair {
  in: number
  out: number
}

export interface Series {
  slots: Pair[]
  total: Pair
}

export function emptySeries(length: number): Series {
  return { slots: Array.from({ length }, () => ({ in: 0, out: 0 })), total: { in: 0, out: 0 } }
}

function matches(row: CountBucketRow, lineUuids: Set<string> | null, label: string | null): boolean {
  if (lineUuids && !lineUuids.has(row.line_uuid)) return false
  return label === null || row.label === label
}

export function hourSeries(response: CountsResponse, lineUuids: Set<string> | null, label: string | null): Series {
  const start = Date.parse(response.start)
  const length = Math.max(1, Math.round((Date.parse(response.end) - start) / HOUR_MS))
  const series = emptySeries(length)
  for (const row of response.buckets) {
    if (!matches(row, lineUuids, label)) continue
    const index = Math.floor((Date.parse(row.at) - start) / HOUR_MS)
    if (index < 0 || index >= length) continue
    series.slots[index].in += row.in
    series.slots[index].out += row.out
    series.total.in += row.in
    series.total.out += row.out
  }
  return series
}

export function dayDates(range: CountsRange): Date[] {
  const dates: Date[] = []
  for (let cursor = range.start; cursor < range.end; cursor = addDays(cursor, 1)) dates.push(cursor)
  return dates
}

export function daySeries(
  response: CountsResponse,
  range: CountsRange,
  lineUuids: Set<string> | null,
  label: string | null,
): Series {
  const dates = dayDates(range)
  const series = emptySeries(dates.length)
  const index = new Map(dates.map((date, position) => [dayKey(date), position]))
  for (const row of response.buckets) {
    if (!matches(row, lineUuids, label)) continue
    const position = index.get(dayKey(new Date(row.at)))
    if (position === undefined) continue
    series.slots[position].in += row.in
    series.slots[position].out += row.out
    series.total.in += row.in
    series.total.out += row.out
  }
  return series
}

export function lineTotal(response: CountsResponse, lineUuid: string, label: string | null): Pair {
  const total = response.totals.find((item) => item.line_uuid === lineUuid)
  if (!total) return { in: 0, out: 0 }
  if (label === null) return { in: total.in, out: total.out }
  return total.labels[label] ?? { in: 0, out: 0 }
}

export function presentLabels(response: CountsResponse): string[] {
  const found = new Set<string>()
  for (const total of response.totals) {
    for (const label of Object.keys(total.labels)) found.add(label)
  }
  return COUNT_LABELS.filter((label) => found.has(label)).concat(
    [...found].filter((label) => !COUNT_LABELS.includes(label)).sort(),
  )
}

