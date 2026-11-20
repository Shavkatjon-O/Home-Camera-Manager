import type { DeviceKind, HealthBucket, HealthRange, LinkKind, TargetHealth, TargetStatus } from "@/lib/types"

export const RANGE_OPTIONS: { value: HealthRange; label: string }[] = [
  { value: "1h", label: "1 hour" },
  { value: "24h", label: "24 hours" },
  { value: "7d", label: "7 days" },
]

export const RANGE_OPTIONS_SHORT: { value: HealthRange; label: string }[] = [
  { value: "1h", label: "1h" },
  { value: "24h", label: "24h" },
  { value: "7d", label: "7d" },
]

export const DEVICE_KINDS: DeviceKind[] = ["router", "access_point", "repeater", "switch", "other"]

export const DEVICE_KIND_LABELS: Record<DeviceKind, string> = {
  router: "Router",
  access_point: "Access point",
  repeater: "Repeater",
  switch: "Switch",
  other: "Other",
}

export const LINKS: LinkKind[] = ["cable", "wifi_24", "wifi_5"]

export const LINK_LABELS: Record<LinkKind, string> = {
  cable: "Cable",
  wifi_24: "Wi-Fi 2.4 GHz",
  wifi_5: "Wi-Fi 5 GHz",
}

export const STATUS_LABELS: Record<TargetStatus, string> = {
  up: "Up",
  degraded: "Failing",
  down: "Down",
  unknown: "No data",
  disabled: "Disabled",
}

export type Tone = "ok" | "warn" | "err" | "off"

export const TONE_CLASSES: Record<Tone, string> = {
  ok: "bg-status-ok",
  warn: "bg-status-warn",
  err: "bg-status-err",
  off: "bg-status-off",
}

export const STATUS_TONES: Record<TargetStatus, Tone> = {
  up: "ok",
  degraded: "warn",
  down: "err",
  unknown: "off",
  disabled: "off",
}

export function bucketTone(bucket: HealthBucket): Tone {
  if (bucket.availability === null) return "off"
  if (bucket.availability >= 100) return "ok"
  if (bucket.availability <= 0) return "err"
  return "warn"
}

export function linkPhrase(link: LinkKind | null): string | null {
  if (!link) return null
  return link === "cable" ? "cable" : LINK_LABELS[link]
}

export function viaLine(target: Pick<TargetHealth, "parent_name" | "link">): string {
  if (!target.parent_name) return "No upstream device"
  const link = linkPhrase(target.link)
  return link ? `via ${target.parent_name}, ${link}` : `via ${target.parent_name}`
}

export function formatPercent(value: number | null): string {
  if (value === null) return "-"
  if (value >= 100) return "100%"
  if (value <= 0) return "0%"
  return `${Math.min(value, 99.99).toFixed(2)}%`
}

export function formatLatency(value: number | null): string {
  if (value === null) return "-"
  if (value >= 1000) return `${(value / 1000).toFixed(2)} s`
  if (value >= 10) return `${Math.round(value)} ms`
  return `${value.toFixed(1)} ms`
}

export function formatSpan(totalSeconds: number): string {
  const seconds = Math.max(0, Math.round(totalSeconds))
  if (seconds < 60) return `${seconds} s`
  const minutes = Math.floor(seconds / 60)
  if (minutes < 60) {
    const rest = seconds % 60
    return rest ? `${minutes} min ${rest} s` : `${minutes} min`
  }
  const hours = Math.floor(minutes / 60)
  if (hours < 24) {
    const rest = minutes % 60
    return rest ? `${hours} h ${rest} min` : `${hours} h`
  }
  const days = Math.floor(hours / 24)
  const rest = hours % 24
  return rest ? `${days} d ${rest} h` : `${days} d`
}

function pad(value: number): string {
  return String(value).padStart(2, "0")
}

function parse(value: string | null | undefined): Date | null {
  if (!value) return null
  const date = new Date(value)
  return Number.isNaN(date.getTime()) ? null : date
}

export function formatMoment(value: string | null | undefined): string {
  const date = parse(value)
  if (!date) return "-"
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
}

export function formatAxisTime(value: string, range: HealthRange): string {
  const date = parse(value)
  if (!date) return ""
  const clock = `${pad(date.getHours())}:${pad(date.getMinutes())}`
  if (range === "7d") return `${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${clock}`
  return clock
}

export function formatAgo(value: string | null, now: number): string {
  const date = parse(value)
  if (!date) return "never"
  const seconds = Math.max(0, Math.round((now - date.getTime()) / 1000))
  if (seconds < 5) return "just now"
  return `${formatSpan(seconds)} ago`
}

export function isHealthy(target: TargetHealth): boolean {
  return target.status === "up"
}
