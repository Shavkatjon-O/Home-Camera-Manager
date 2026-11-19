"use client"

import { Chip } from "@/components/shell/primitives"
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"
import { SOURCE_LABELS, SOURCE_TONES } from "@/lib/events"
import { formatAgo } from "@/lib/health"
import { useClockSeconds } from "@/lib/stores"
import type { CameraEventSource } from "@/lib/types"
import { cn } from "@/lib/utils"

const MODE_LABELS = {
  pullpoint: "ONVIF PullPoint subscription",
  polling: "ONVIF state polling",
  none: "No event channel",
}

export function sourceSummary(source: CameraEventSource, now: number): string {
  if (source.state === "unsupported") return source.error ?? "Events not available from this camera"
  if (source.state === "disabled") return "The camera is disabled"
  const parts = [MODE_LABELS[source.mode]]
  if (source.state === "live") parts.push(`last message ${formatAgo(source.last_message_at, now)}`)
  if (source.error) parts.push(source.error)
  return parts.join(", ")
}

export function SourceChip({ source, className }: { source: CameraEventSource; className?: string }) {
  const seconds = useClockSeconds()
  return (
    <Tooltip>
      <TooltipTrigger asChild>
        <Chip tabIndex={0} className={cn("cursor-default", className)}>
          <span aria-hidden className={cn("inline-block size-2 rounded-full", SOURCE_TONES[source.state])} />
          <span className="text-foreground">{source.camera_name}</span>
          {SOURCE_LABELS[source.state]}
        </Chip>
      </TooltipTrigger>
      <TooltipContent className="max-w-72">{sourceSummary(source, seconds * 1000)}</TooltipContent>
    </Tooltip>
  )
}
