"use client"

import * as React from "react"
import Link from "next/link"
import { XIcon } from "lucide-react"

import { FaceCrop } from "@/components/people/face-parts"
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"
import { formatDateTime } from "@/lib/format"
import { eventHref, similarHref, type Sample, type Sighting } from "@/lib/people"
import { cn } from "@/lib/utils"

const removeButton =
  "absolute top-1 right-1 inline-flex size-5 items-center justify-center rounded-full bg-black/70 text-white/85 opacity-0 transition-opacity hover:bg-black/90 hover:text-white focus-visible:opacity-100 group-hover:opacity-100 group-focus-within:opacity-100 disabled:pointer-events-none disabled:opacity-50 pointer-coarse:opacity-100 [&_svg]:size-3"

export function ReadOut({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex items-baseline justify-between gap-3 text-[12px]">
      <span className="shrink-0 text-text-3">{label}</span>
      <span className="min-w-0 truncate text-right font-data text-foreground">{value}</span>
    </div>
  )
}

function sampleTitle(sample: Sample): string {
  if (sample.source === "upload") return "Uploaded photo"
  const where = [sample.camera_name, sample.view_name && sample.view_name !== sample.camera_name ? sample.view_name : null]
    .filter(Boolean)
    .join(", ")
  const when = sample.seen_at ? formatDateTime(sample.seen_at) : null
  return [where || "Camera", when].filter(Boolean).join(", ")
}

export function SampleStrip({
  samples,
  owner,
  removing,
  onRemove,
}: {
  samples: Sample[]
  owner: string
  removing?: string | null
  onRemove?: (sample: Sample) => void
}) {
  return (
    <ul aria-label={`Face samples of ${owner}`} className="flex flex-wrap gap-2">
      {samples.map((sample) => (
        <li key={sample.uuid} className="group relative">
          <Tooltip>
            <TooltipTrigger asChild>
              <Link
                href={similarHref({ sample: sample.uuid })}
                aria-label={`Find faces similar to this sample of ${owner}`}
                className="block rounded-md"
              >
                <FaceCrop sample={sample.has_crop ? sample.uuid : null} className="size-14" sizes="56px" />
              </Link>
            </TooltipTrigger>
            <TooltipContent>{`${sampleTitle(sample)}. Find similar faces`}</TooltipContent>
          </Tooltip>
          {onRemove ? (
            <button
              type="button"
              aria-label={`Remove this sample of ${owner}`}
              title="Remove sample"
              disabled={removing === sample.uuid}
              onClick={() => onRemove(sample)}
              className={cn(removeButton, removing === sample.uuid && "opacity-100")}
            >
              <XIcon aria-hidden />
            </button>
          ) : null}
        </li>
      ))}
    </ul>
  )
}

export function SightingList({ sightings }: { sightings: Sighting[] }) {
  if (sightings.length === 0) return null
  return (
    <div className="flex flex-col gap-1">
      <h4 className="text-[11px] text-text-3">Latest sightings</h4>
      <ul className="-mx-1.5 flex flex-col">
        {sightings.map((sighting) => (
          <li key={sighting.event_uuid}>
            <Link
              href={eventHref(sighting.event_uuid)}
              className="flex min-w-0 items-center gap-2 rounded-md px-1.5 py-1 text-[12px] transition-colors hover:bg-surface-2"
            >
              <span className="min-w-0 truncate text-foreground">{sighting.camera_name ?? "Removed camera"}</span>
              {sighting.view_name && sighting.view_name !== sighting.camera_name ? (
                <span className="min-w-0 truncate text-text-3">{sighting.view_name}</span>
              ) : null}
              <span className="ml-auto shrink-0 font-data text-[11px] text-text-2">
                {formatDateTime(sighting.seen_at)}
              </span>
            </Link>
          </li>
        ))}
      </ul>
    </div>
  )
}

export function CardShell({
  label,
  highlighted,
  children,
}: {
  label: string
  highlighted?: boolean
  children: React.ReactNode
}) {
  return (
    <article
      aria-label={label}
      className={cn(
        "flex min-w-0 flex-col gap-3 rounded-lg border bg-surface p-4",
        highlighted ? "border-hairline-strong" : "border-hairline",
      )}
    >
      {children}
    </article>
  )
}
