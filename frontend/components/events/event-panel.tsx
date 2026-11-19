"use client"

import * as React from "react"
import Image from "next/image"
import Link from "next/link"
import { ArrowUpRightIcon, ImageOffIcon, XIcon } from "lucide-react"

import { EventDuration, KindChip } from "@/components/events/event-parts"
import { IconButton } from "@/components/shell/icon-button"
import { Button } from "@/components/ui/button"
import { cameraHref } from "@/components/wall/wall-tile"
import { eventImageUrl } from "@/lib/api"
import { eventTitle, topicLabel } from "@/lib/events"
import { formatMoment } from "@/lib/health"
import type { CameraEvent } from "@/lib/types"

interface MessageDetail {
  topic?: string
  operation?: string
  camera_time?: string
  source?: Record<string, string>
  data?: Record<string, string>
  key?: Record<string, string>
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="flex flex-col gap-3 border-b border-hairline px-4 py-4 last:border-b-0">
      <h2 className="text-xs text-text-3">{title}</h2>
      {children}
    </section>
  )
}

function ReadOut({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex items-baseline justify-between gap-3 text-[12px]">
      <span className="shrink-0 text-text-3">{label}</span>
      <span className="min-w-0 truncate text-right font-data text-foreground">{value}</span>
    </div>
  )
}

function items(values: Record<string, string> | undefined): string {
  if (!values) return ""
  return Object.entries(values)
    .map(([name, value]) => `${name}=${value}`)
    .join(", ")
}

function Snapshot({ event }: { event: CameraEvent }) {
  const [failed, setFailed] = React.useState(false)
  if (!event.has_snapshot || failed) {
    return (
      <div className="flex aspect-video items-center justify-center gap-2 rounded-md bg-surface-2 text-[12px] text-text-3">
        <ImageOffIcon aria-hidden className="size-4" />
        {event.has_snapshot ? "Snapshot unavailable" : "No snapshot for this event"}
      </div>
    )
  }
  const url = eventImageUrl(event.uuid)
  return (
    <a href={url} target="_blank" rel="noreferrer" className="relative block aspect-video overflow-hidden rounded-md bg-black">
      <Image src={url} alt={`Snapshot of ${eventTitle(event)}`} fill sizes="360px" className="object-contain" onError={() => setFailed(true)} />
    </a>
  )
}

export function EventPanel({ event, onClose }: { event: CameraEvent; onClose: () => void }) {
  const messages = (Array.isArray(event.details.messages) ? event.details.messages : []) as MessageDetail[]
  const topics = (Array.isArray(event.details.topics) ? event.details.topics : []) as string[]
  const offset = typeof event.details.camera_offset_seconds === "number" ? event.details.camera_offset_seconds : null
  return (
    <div className="flex flex-col">
      <div className="flex items-start justify-between gap-3 border-b border-hairline px-4 py-4">
        <div className="flex min-w-0 flex-col gap-1">
          <h1 className="truncate text-[15px] font-medium text-foreground">{eventTitle(event)}</h1>
          <div className="flex items-center gap-2">
            <KindChip event={event} />
            <EventDuration event={event} />
          </div>
        </div>
        <IconButton label="Close" size="icon-sm" onClick={onClose}>
          <XIcon />
        </IconButton>
      </div>
      <div className="px-4 pt-4">
        <Snapshot key={`${event.uuid}-${event.has_snapshot}`} event={event} />
      </div>
      <Section title="Times">
        <ReadOut label="Started" value={formatMoment(event.started_at)} />
        <ReadOut label="Ended" value={event.ongoing ? "Ongoing" : formatMoment(event.ended_at)} />
        <ReadOut label="Camera time" value={formatMoment(event.camera_time)} />
        {offset !== null && Math.abs(offset) >= 5 ? (
          <p className="text-[12px] text-text-3">
            The camera clock is {Math.abs(Math.round(offset))} s {offset > 0 ? "ahead" : "behind"}; times above use this
            computer&apos;s clock.
          </p>
        ) : null}
        {event.details.capped ? <p className="text-[12px] text-text-3">Closed after the 10 minute limit.</p> : null}
        {event.details.interrupted ? (
          <p className="text-[12px] text-text-3">Closed when the server restarted while it was open.</p>
        ) : null}
      </Section>
      <Section title="Source">
        <ReadOut label="Camera" value={event.camera_name ?? "Removed camera"} />
        <ReadOut label="Topic" value={topicLabel(event.source_topic)} />
        {topics.length > 1 ? <ReadOut label="Topics" value={topics.map(topicLabel).join(", ")} /> : null}
        <Button asChild variant="outline" size="sm" className="self-start">
          <Link href={cameraHref(event.camera_uuid)}>
            <ArrowUpRightIcon />
            Open camera
          </Link>
        </Button>
      </Section>
      {messages.length > 0 ? (
        <Section title="Camera message">
          {messages.map((message, index) => (
            <div key={index} className="flex flex-col gap-1 font-data text-[11px] break-all text-text-2">
              <span className="text-foreground">{message.topic}</span>
              {message.operation ? <span>Operation {message.operation}</span> : null}
              {message.source ? <span>Source {items(message.source)}</span> : null}
              {message.key ? <span>Key {items(message.key)}</span> : null}
              {message.data ? <span>Data {items(message.data)}</span> : null}
            </div>
          ))}
        </Section>
      ) : null}
    </div>
  )
}
