"use client"

import * as React from "react"
import Link from "next/link"
import { ChevronRightIcon } from "lucide-react"

import { useEvents } from "@/components/events/events-provider"
import { useSession } from "@/components/shell/session"
import { Button } from "@/components/ui/button"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { api, isAbort } from "@/lib/api"
import { formatClock } from "@/lib/format"
import { TONE_CLASSES, isHealthy, type Tone } from "@/lib/health"
import { useClockSeconds } from "@/lib/stores"
import type { TargetHealth } from "@/lib/types"
import { cn } from "@/lib/utils"

const HEALTH_MS = 30000
const NAMES_SHOWN = 3

function useHealthTargets(): { targets: TargetHealth[] | null; reload: () => void } {
  const [targets, setTargets] = React.useState<TargetHealth[] | null>(null)
  const [tick, setTick] = React.useState(0)

  React.useEffect(() => {
    const refresh = () => {
      if (document.visibilityState === "visible") setTick((value) => value + 1)
    }
    const timer = window.setInterval(refresh, HEALTH_MS)
    document.addEventListener("visibilitychange", refresh)
    return () => {
      window.clearInterval(timer)
      document.removeEventListener("visibilitychange", refresh)
    }
  }, [])

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .healthOverview("1h", controller.signal)
      .then((data) => setTargets(data.targets))
      .catch((err: unknown) => {
        if (!isAbort(err)) setTargets(null)
      })
    return () => controller.abort()
  }, [tick])

  const reload = React.useCallback(() => setTick((value) => value + 1), [])
  return { targets, reload }
}

function Dot({ tone }: { tone: Tone }) {
  return <span aria-hidden className={cn("inline-block size-2 shrink-0 rounded-full", TONE_CLASSES[tone])} />
}

function names(items: { name: string }[]): string {
  const shown = items.slice(0, NAMES_SHOWN).map((item) => item.name)
  const more = items.length - shown.length
  return more > 0 ? `${shown.join(", ")} and ${more} more` : shown.join(", ")
}

function plural(count: number, one: string, many: string): string {
  return `${count} ${count === 1 ? one : many}`
}

function StatusRow({
  href,
  label,
  value,
  detail,
  tone,
  onNavigate,
}: {
  href: string
  label: string
  value: string
  detail?: string | null
  tone: Tone
  onNavigate: () => void
}) {
  return (
    <Link
      href={href}
      onClick={onNavigate}
      className="group flex items-start gap-2.5 rounded-md px-2 py-2 outline-none transition-colors hover:bg-surface-2 focus-visible:bg-surface-2"
    >
      <span className="flex h-[18px] items-center">
        <Dot tone={tone} />
      </span>
      <span className="flex min-w-0 flex-1 flex-col gap-0.5">
        <span className="flex items-baseline justify-between gap-3">
          <span className="text-[13px] text-foreground">{label}</span>
          <span className="font-data text-[11px] whitespace-nowrap text-text-2">{value}</span>
        </span>
        {detail ? <span className="text-[12px] text-text-3">{detail}</span> : null}
      </span>
      <ChevronRightIcon aria-hidden className="mt-0.5 size-3.5 shrink-0 text-text-3 group-hover:text-foreground" />
    </Link>
  )
}

/**
 * The single status control of the top bar: one dot and a short summary of cameras, network health and the event
 * stream, opening a popover with the details and the local time to compare with camera overlays.
 */
export function StatusIndicator() {
  const { cameras, loaded, error } = useSession()
  const { connected } = useEvents()
  const [open, setOpen] = React.useState(false)
  const { targets, reload } = useHealthTargets()
  const seconds = useClockSeconds()

  const enabled = cameras.filter((camera) => camera.enabled)
  const online = enabled.filter((camera) => camera.status.online === true).length
  const offline = enabled.filter((camera) => camera.status.online === false)
  const watched = (targets ?? []).filter((target) => target.enabled)
  const healthy = watched.filter(isHealthy).length
  const down = watched.filter((target) => target.status === "down")
  const failing = watched.filter((target) => target.status === "degraded")
  const unknown = watched.filter((target) => target.status === "unknown").length

  const cameraTone: Tone = error ? "err" : offline.length > 0 ? "err" : enabled.length === 0 ? "off" : online === enabled.length ? "ok" : "off"
  const healthTone: Tone =
    down.length > 0 ? "err" : failing.length > 0 ? "warn" : watched.length > 0 && healthy === watched.length ? "ok" : "off"
  const streamTone: Tone = connected ? "ok" : "warn"

  let tone: Tone = "ok"
  let summary = "All online"
  if (!loaded) {
    tone = "off"
    summary = "Checking"
  } else if (error) {
    tone = "err"
    summary = "Status unavailable"
  } else if (offline.length > 0) {
    tone = "err"
    summary = `${plural(offline.length, "camera", "cameras")} offline`
  } else if (down.length > 0) {
    tone = "err"
    summary = `${plural(down.length, "device", "devices")} down`
  } else if (failing.length > 0) {
    tone = "warn"
    summary = `${plural(failing.length, "device", "devices")} failing`
  } else if (!connected) {
    tone = "warn"
    summary = "Reconnecting"
  } else if (enabled.length === 0) {
    tone = "off"
    summary = "No cameras"
  }

  let cameraDetail: string | null = null
  if (error) cameraDetail = error
  else if (offline.length > 0) cameraDetail = `Offline: ${names(offline)}`

  let healthDetail: string | null = null
  if (down.length > 0) healthDetail = `Down: ${names(down)}`
  else if (failing.length > 0) healthDetail = `Failing: ${names(failing)}`
  else if (unknown > 0) healthDetail = `${plural(unknown, "target", "targets")} without data yet`

  const close = () => setOpen(false)
  const toggle = (next: boolean) => {
    if (next) reload()
    setOpen(next)
  }

  return (
    <Popover open={open} onOpenChange={toggle}>
      <PopoverTrigger asChild>
        <Button variant="outline" aria-label={`Status, ${summary}`} className="gap-2 px-2.5">
          <Dot tone={tone} />
          <span className="hidden lg:inline">{summary}</span>
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-80" aria-label="Status">
        <div className="flex items-center justify-between gap-3 border-b border-hairline px-3 py-2.5">
          <span className="text-[13px] font-medium text-foreground">Status</span>
          <span className="font-data text-[11px] text-text-3" aria-label="Local time">
            {seconds ? formatClock(new Date(seconds * 1000)) : "--:--:--"}
          </span>
        </div>
        <div className="flex flex-col p-1">
          <StatusRow
            href="/cameras/"
            label="Cameras"
            value={enabled.length === 0 ? "None enabled" : `${online} of ${enabled.length} online`}
            detail={cameraDetail}
            tone={cameraTone}
            onNavigate={close}
          />
          <StatusRow
            href="/health/"
            label="Network health"
            value={targets === null ? "Unavailable" : watched.length === 0 ? "Nothing watched" : `${healthy} of ${watched.length} healthy`}
            detail={healthDetail}
            tone={healthTone}
            onNavigate={close}
          />
          <StatusRow
            href="/events/"
            label="Event stream"
            value={connected ? "Live" : "Reconnecting"}
            tone={streamTone}
            onNavigate={close}
          />
        </div>
      </PopoverContent>
    </Popover>
  )
}
