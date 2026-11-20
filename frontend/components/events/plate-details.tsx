import * as React from "react"

import { Chip } from "@/components/shell/primitives"

interface PlateCandidate {
  text: string
  display: string
  format: "private" | "organisation" | null
  score: number
  reads: number
  weight: number
}

const STATUS_TEXT: Record<string, string> = {
  infrared: "Not read at night: the infrared light glares on the plate.",
  no_plate: "No plate was found on the vehicle.",
  too_small: "The plate was too small to read.",
  unreadable: "The plate could not be read.",
  pending: "Reading the plate.",
}

const FORMAT_LABELS: Record<string, string> = {
  private: "Private",
  organisation: "Organisation",
}

function candidates(details: Record<string, unknown>): PlateCandidate[] {
  const raw = details.plates
  if (!Array.isArray(raw)) return []
  return raw
    .filter((item): item is PlateCandidate => !!item && typeof item === "object" && typeof (item as PlateCandidate).text === "string")
    .sort((a, b) => (b.weight ?? 0) - (a.weight ?? 0) || (b.score ?? 0) - (a.score ?? 0))
}

export function PlateDetails({ details }: { details: Record<string, unknown> }) {
  const hasPlates = Array.isArray(details.plates)
  const status = typeof details.plate_status === "string" ? details.plate_status : null
  if (!hasPlates && status === null) return null
  const list = candidates(details)
  return (
    <section className="flex flex-col gap-3 border-b border-hairline px-4 py-4 last:border-b-0">
      <div className="flex items-center gap-2">
        <h2 className="text-xs text-text-3">Number plate</h2>
        <Chip className="h-5 px-1.5 text-[10px]">Beta</Chip>
      </div>
      {list.length > 0 ? (
        <div className="flex flex-col gap-2">
          {list.map((plate) => (
            <div key={plate.text} className="flex items-baseline justify-between gap-3 text-[12px]">
              <div className="flex min-w-0 flex-col gap-0.5">
                <span className="truncate font-data text-[14px] text-foreground">{plate.display || plate.text}</span>
                {plate.format ? <span className="text-[11px] text-text-3">{FORMAT_LABELS[plate.format]}</span> : null}
              </div>
              <div className="flex shrink-0 items-baseline gap-3 font-data text-text-2">
                <span>{Math.round(plate.score * 100)}%</span>
                <span className="text-text-3">{plate.reads === 1 ? "1 read" : `${plate.reads} reads`}</span>
              </div>
            </div>
          ))}
        </div>
      ) : status ? (
        <p className="text-[12px] text-text-3">{STATUS_TEXT[status] ?? STATUS_TEXT.unreadable}</p>
      ) : null}
    </section>
  )
}
