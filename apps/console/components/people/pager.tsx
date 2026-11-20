"use client"

import { ChevronLeftIcon, ChevronRightIcon } from "lucide-react"

import { IconButton } from "@/components/shell/icon-button"
import { cn } from "@/lib/utils"

export function Pager({
  page,
  pageSize,
  total,
  error,
  previousLabel = "Previous page",
  nextLabel = "Next page",
  onPage,
  className,
}: {
  page: number
  pageSize: number
  total: number
  error?: string | null
  previousLabel?: string
  nextLabel?: string
  onPage: (page: number) => void
  className?: string
}) {
  const pageCount = Math.max(1, Math.ceil(total / pageSize))
  const first = total === 0 ? 0 : (page - 1) * pageSize + 1
  const last = Math.min(page * pageSize, total)
  return (
    <div className={cn("flex items-center justify-between gap-3", className)}>
      <span className="font-data text-[11px] text-text-3">
        {first} to {last} of {total}
        {error ? <span className="ml-3 text-danger">{error}</span> : null}
      </span>
      <div className="flex items-center gap-1">
        <IconButton
          label={previousLabel}
          variant="outline"
          size="icon-sm"
          side="top"
          disabled={page <= 1}
          onClick={() => onPage(Math.max(1, page - 1))}
        >
          <ChevronLeftIcon />
        </IconButton>
        <IconButton
          label={nextLabel}
          variant="outline"
          size="icon-sm"
          side="top"
          disabled={page >= pageCount}
          onClick={() => onPage(Math.min(pageCount, page + 1))}
        >
          <ChevronRightIcon />
        </IconButton>
      </div>
    </div>
  )
}
