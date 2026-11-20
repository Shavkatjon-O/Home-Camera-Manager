"use client"

import * as React from "react"
import { PentagonIcon, TriangleAlertIcon } from "lucide-react"
import { toast } from "sonner"

import { ControlSection } from "@/components/camera/control-sections"
import { Spinner } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Switch } from "@/components/ui/switch"
import {
  PROFILES,
  PROFILE_LABELS,
  VIEW_STATE_LABELS,
  VIEW_STATE_TONES,
  countTotal,
  countsText,
  viewTitle,
} from "@/lib/analytics"
import { api, errorMessage } from "@/lib/api"
import { labelName } from "@/lib/events"
import { formatAgo } from "@/lib/health"
import { useClockSeconds } from "@/lib/stores"
import type { AnalyticsProfile, AnalyticsView, AnalyticsViewUpdate } from "@/lib/types"
import { cn } from "@/lib/utils"

function Note({ children }: { children: React.ReactNode }) {
  return <p className="text-[12px] text-text-3">{children}</p>
}

export function Warning({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex items-start gap-1.5 text-[12px] text-status-warn">
      <TriangleAlertIcon aria-hidden className="mt-px size-3.5 shrink-0" />
      <span className="min-w-0">{children}</span>
    </div>
  )
}

function ReadOut({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="grid grid-cols-[96px_minmax(0,1fr)] items-baseline gap-3 py-0.5">
      <span className="truncate text-xs text-text-3">{label}</span>
      <span className="min-w-0 font-data text-xs break-words text-foreground">{value}</span>
    </div>
  )
}

function plural(count: number, word: string): string {
  return `${count} ${word}${count === 1 ? "" : "s"}`
}

function fpsText(value: number): string {
  return Number.isInteger(value) ? String(value) : value.toFixed(1)
}

function stateLine(view: AnalyticsView, now: number): { tone: string; text: string } {
  if (!view.enabled) return { tone: VIEW_STATE_TONES.disabled, text: "Off" }
  const status = view.status
  if (!status) return { tone: VIEW_STATE_TONES.disabled, text: "Waiting for the analytics service" }
  if (status.state === "live") {
    return {
      tone: VIEW_STATE_TONES.live,
      text: `Live, ${fpsText(status.fps)} of ${fpsText(status.target_fps)} fps, ${plural(status.objects, "object")}`,
    }
  }
  if (status.state === "stalled") {
    return { tone: VIEW_STATE_TONES.stalled, text: `Stalled, last report ${formatAgo(status.updated_at, now)}` }
  }
  return { tone: VIEW_STATE_TONES.disabled, text: VIEW_STATE_LABELS[status.state] }
}

function ViewStatusBlock({ view }: { view: AnalyticsView }) {
  const seconds = useClockSeconds()
  const status = view.enabled ? view.status : null
  const line = stateLine(view, seconds * 1000)
  const suspendedIds = new Set(status?.suspended ?? [])
  const suspended = [
    ...view.zones.filter((zone) => zone.suspended || suspendedIds.has(zone.uuid)).map((zone) => zone.name),
    ...view.lines.filter((item) => item.suspended || suspendedIds.has(item.uuid)).map((item) => item.name),
  ]
  const tamper = status?.tamper?.active ?? []
  return (
    <div className="flex flex-col gap-1.5">
      <div className="flex items-center gap-2 font-data text-[11px] text-text-2">
        <span aria-hidden className={cn("inline-block size-2 shrink-0 rounded-full", line.tone)} />
        <span className="min-w-0">{line.text}</span>
      </div>
      {status && (view.zones.length > 0 || view.lines.length > 0) ? (
        <div className="flex flex-col">
          {view.zones.map((zone) => (
            <ReadOut key={zone.uuid} label={zone.name} value={countsText(status.occupancy[zone.uuid])} />
          ))}
          {view.lines.map((item) => {
            const crossings = status.crossings[item.uuid]
            return (
              <ReadOut
                key={item.uuid}
                label={item.name}
                value={`In ${countTotal(crossings?.in)}, Out ${countTotal(crossings?.out)}`}
              />
            )
          })}
        </div>
      ) : null}
      {view.zones.length === 0 && view.lines.length === 0 ? <Note>No zones or lines yet.</Note> : null}
      {suspended.length > 0 ? (
        <Warning>
          Suspended: the lens no longer shows the scene these zones were drawn on ({suspended.join(", ")}).
        </Warning>
      ) : null}
      {tamper.length > 0 ? <Warning>Tamper: {tamper.map(labelName).join(", ")}</Warning> : null}
    </div>
  )
}

function ViewCard({
  view,
  titled,
  onChange,
  onEdit,
}: {
  view: AnalyticsView
  titled: boolean
  onChange: (view: AnalyticsView) => void
  onEdit: (uuid: string) => void
}) {
  const [busy, setBusy] = React.useState(false)
  const title = viewTitle(view)

  const update = async (changes: AnalyticsViewUpdate) => {
    setBusy(true)
    try {
      onChange(await api.updateAnalyticsView(view.uuid, changes))
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className={cn("flex flex-col gap-2.5", titled && "rounded-md border border-hairline p-2.5")}>
      {titled ? <span className="truncate text-[12px] text-foreground">{title}</span> : null}
      <div className="flex items-center justify-between gap-2 text-[12px]">
        <span className="text-text-3">Detection</span>
        <div className="flex items-center gap-2">
          {busy ? <Spinner className="size-3.5" /> : null}
          <Switch
            aria-label={`Detection, ${title}`}
            checked={view.enabled}
            disabled={busy}
            onCheckedChange={(checked) => void update({ enabled: checked })}
          />
        </div>
      </div>
      <div className="flex items-center justify-between gap-2 text-[12px]">
        <span className="text-text-3">Profile</span>
        <Select
          value={view.profile}
          disabled={busy}
          onValueChange={(value) => void update({ profile: value as AnalyticsProfile })}
        >
          <SelectTrigger aria-label={`Profile, ${title}`} className="w-32">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            {PROFILES.map((profile) => (
              <SelectItem key={profile} value={profile}>
                {PROFILE_LABELS[profile]}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>
      <div className="flex items-center justify-between gap-2 text-[12px]">
        <span className="text-text-3">Moving lens</span>
        <Switch
          aria-label={`Moving lens, ${title}`}
          checked={view.moving}
          disabled={busy}
          onCheckedChange={(checked) => void update({ moving: checked })}
        />
      </div>
      <ViewStatusBlock view={view} />
      <Button variant="outline" size="sm" className="self-start" onClick={() => onEdit(view.uuid)}>
        <PentagonIcon />
        Edit zones
      </Button>
    </div>
  )
}

export function AnalyticsSection({
  views,
  error,
  onChange,
  onEdit,
}: {
  views: AnalyticsView[] | null
  error: string | null
  onChange: (view: AnalyticsView) => void
  onEdit: (uuid: string) => void
}) {
  let body: React.ReactNode
  if (views === null) body = error ? <Note>{error}</Note> : <Spinner />
  else if (views.length === 0) body = <Note>Analytics has no view of this camera yet.</Note>
  else {
    const titled = views.length > 1
    body = (
      <>
        {views.map((view) => (
          <ViewCard key={view.uuid} view={view} titled={titled} onChange={onChange} onEdit={onEdit} />
        ))}
        {views.some((view) => view.moving) ? (
          <Note>Zones on a moving lens pause while the lens shows a different scene from the picture they were drawn on.</Note>
        ) : null}
      </>
    )
  }
  return <ControlSection title="Analytics">{body}</ControlSection>
}
