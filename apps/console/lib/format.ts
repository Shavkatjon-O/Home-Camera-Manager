function pad(value: number): string {
  return String(value).padStart(2, "0")
}

function parse(value: string | null | undefined): Date | null {
  if (!value) return null
  const date = new Date(value)
  return Number.isNaN(date.getTime()) ? null : date
}

export function formatClock(date: Date): string {
  return `${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
}

export function formatDateTime(value: string | null | undefined): string {
  const date = parse(value)
  if (!date) return "-"
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}`
}

export function formatTime(value: string | null | undefined): string {
  const date = parse(value)
  return date ? formatClock(date) : "-"
}

export function formatDuration(ms: number): string {
  if (ms < 1000) return `${Math.round(ms)} ms`
  return `${(ms / 1000).toFixed(1)} s`
}

export function statusLabel(online: boolean | null): string {
  if (online === true) return "Online"
  if (online === false) return "Offline"
  return "Unknown"
}
