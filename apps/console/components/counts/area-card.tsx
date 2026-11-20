"use client"

import { PencilIcon, SlidersHorizontalIcon, Trash2Icon } from "lucide-react"

import { Chip } from "@/components/shell/primitives"
import { IconButton } from "@/components/shell/icon-button"
import { useCan } from "@/components/shell/session"
import { formatDateTime } from "@/lib/format"
import { labelName } from "@/lib/events"
import type { Area } from "@/lib/counts"

function Figure({ label, value }: { label: string; value: number }) {
  return (
    <div className="flex min-w-0 flex-col gap-0.5">
      <span className="font-data text-[13px] text-foreground">{value}</span>
      <span className="text-[11px] text-text-3">{label}</span>
    </div>
  )
}

/**
 * One area with how many are inside and the lines that bound it. Operators set the occupancy; admins also edit and
 * delete the area.
 */
export function AreaCard({
  area,
  onEdit,
  onDelete,
  onSet,
}: {
  area: Area
  onEdit: (area: Area) => void
  onDelete: (area: Area) => void
  onSet: (area: Area) => void
}) {
  const since = area.since ? formatDateTime(area.since) : null
  const canOperate = useCan("operator")
  const canManage = useCan("admin")
  return (
    <article
      aria-label={`${area.name} occupancy`}
      data-testid="counts-area"
      className="flex min-w-0 flex-col gap-3 rounded-lg border border-hairline bg-surface p-4"
    >
      <div className="flex items-start justify-between gap-3">
        <div className="flex min-w-0 flex-col gap-1">
          <span className="truncate text-[14px] text-foreground">{area.name}</span>
          <span className="truncate text-[12px] text-text-2">
            {area.labels.length === 0 ? "Every label" : area.labels.map(labelName).join(", ")}
          </span>
        </div>
        <div className="flex shrink-0 flex-col items-end gap-0.5">
          <span className="font-data text-[22px] leading-none text-foreground">{area.occupancy}</span>
          <span className="text-[11px] text-text-3">inside now</span>
        </div>
      </div>
      <div className="grid grid-cols-2 gap-3">
        <Figure label="Entered" value={area.entered} />
        <Figure label="Exited" value={area.exited} />
      </div>
      <p className="font-data text-[11px] text-text-3">
        {area.reset_at ? `Resets daily at ${area.reset_at}` : "Never resets"}
        {since ? `, counting since ${since}` : ""}
      </p>
      <div className="flex flex-wrap gap-1.5">
        {area.lines.length === 0 ? (
          <span className="text-[12px] text-text-3">No lines bound</span>
        ) : (
          area.lines.map((line) => (
            <Chip key={line.line_uuid} title={line.view_name}>
              {line.line_name}
              <span className="text-foreground">{line.entering === "in" ? "In enters" : "Out enters"}</span>
            </Chip>
          ))
        )}
      </div>
      {canOperate ? (
        <div className="flex items-center justify-end gap-1">
          <IconButton label={`Set occupancy of ${area.name}`} size="icon-sm" onClick={() => onSet(area)}>
            <SlidersHorizontalIcon />
          </IconButton>
          {canManage ? (
            <IconButton label={`Edit ${area.name}`} size="icon-sm" onClick={() => onEdit(area)}>
              <PencilIcon />
            </IconButton>
          ) : null}
          {canManage ? (
            <IconButton label={`Delete ${area.name}`} size="icon-sm" onClick={() => onDelete(area)}>
              <Trash2Icon />
            </IconButton>
          ) : null}
        </div>
      ) : null}
    </article>
  )
}
