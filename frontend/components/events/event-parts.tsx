"use client"

import * as React from "react"
import Image from "next/image"
import { BellRingIcon, ImageOffIcon } from "lucide-react"

import { Chip } from "@/components/shell/primitives"
import { eventImageUrl } from "@/lib/api"
import { KIND_LABELS, labelName } from "@/lib/events"
import { formatSpan } from "@/lib/health"
import type { CameraEvent } from "@/lib/types"
import { cn } from "@/lib/utils"

export function KindChip({ event, className }: { event: Pick<CameraEvent, "kind" | "ongoing">; className?: string }) {
  return (
    <Chip
      className={cn(
        "h-5 px-1.5 text-[10px]",
        event.ongoing && "bg-status-err/15 text-status-err",
        className,
      )}
    >
      {KIND_LABELS[event.kind]}
    </Chip>
  )
}

export function LabelChip({
  event,
  className,
}: {
  event: Pick<CameraEvent, "kind" | "label">
  className?: string
}) {
  if (!event.label) return null
  const name = labelName(event.label)
  if (name === KIND_LABELS[event.kind]) return null
  return <Chip className={cn("h-5 px-1.5 text-[10px]", className)}>{name}</Chip>
}

export function AlertMark({ event, className }: { event: Pick<CameraEvent, "alert">; className?: string }) {
  if (!event.alert) return null
  return <BellRingIcon role="img" aria-label="Alert" className={cn("size-3.5 shrink-0 text-status-err", className)} />
}

export function EventDuration({ event }: { event: CameraEvent }) {
  if (event.ongoing) return <span className="font-data text-[12px] text-status-err">Ongoing</span>
  if (event.duration_seconds < 1) return <span className="font-data text-[12px] text-text-3">Instant</span>
  return <span className="font-data text-[12px] text-text-2">{formatSpan(event.duration_seconds)}</span>
}

export function EventThumb({ event, className }: { event: CameraEvent; className?: string }) {
  const [failed, setFailed] = React.useState(false)
  return (
    <div className={cn("relative aspect-video shrink-0 overflow-hidden rounded-md bg-surface-2", className)}>
      {event.has_thumbnail && !failed ? (
        <Image
          src={eventImageUrl(event.uuid, true)}
          alt=""
          fill
          sizes="160px"
          className="object-cover"
          onError={() => setFailed(true)}
        />
      ) : (
        <div className="absolute inset-0 flex items-center justify-center text-text-3 [&_svg]:size-4">
          <ImageOffIcon aria-hidden />
        </div>
      )}
    </div>
  )
}
