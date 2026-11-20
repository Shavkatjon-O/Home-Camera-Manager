"use client"

import { ChevronLeftIcon, ChevronRightIcon } from "lucide-react"

import { IconButton } from "@/components/shell/icon-button"
import { Chip } from "@/components/shell/primitives"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { formatMoment, formatSpan } from "@/lib/health"
import type { Outage, Page } from "@/lib/types"

export const OUTAGE_PAGE_SIZE = 10

export function OutageLog({
  data,
  error,
  page,
  onPage,
  onSelect,
}: {
  data: Page<Outage> | null
  error: string | null
  page: number
  onPage: (page: number) => void
  onSelect: (uuid: string) => void
}) {
  const total = data?.total ?? 0
  const pageCount = Math.max(1, Math.ceil(total / OUTAGE_PAGE_SIZE))
  const first = total === 0 ? 0 : (page - 1) * OUTAGE_PAGE_SIZE + 1
  const last = Math.min(page * OUTAGE_PAGE_SIZE, total)

  return (
    <section className="flex flex-col gap-2" aria-labelledby="outage-log-title">
      <h2 id="outage-log-title" className="text-xs text-text-3">
        Outage log
      </h2>
      <div className="overflow-x-auto rounded-lg border border-hairline">
        <Table>
          <TableHeader>
            <TableRow className="hover:bg-transparent">
              <TableHead>Target</TableHead>
              <TableHead>Started</TableHead>
              <TableHead>Ended</TableHead>
              <TableHead>Duration</TableHead>
              <TableHead>Caused by</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data && data.items.length > 0 ? (
              data.items.map((outage) => (
                <TableRow key={outage.uuid}>
                  <TableCell>
                    <button
                      type="button"
                      className="max-w-56 truncate text-foreground hover:underline"
                      onClick={() => onSelect(outage.target_uuid)}
                    >
                      {outage.target_name ?? "Removed"}
                    </button>
                  </TableCell>
                  <TableCell className="font-data text-xs text-text-2">{formatMoment(outage.started_at)}</TableCell>
                  <TableCell className="font-data text-xs text-text-2">
                    {outage.ongoing ? <Chip className="text-danger">Ongoing</Chip> : formatMoment(outage.ended_at)}
                  </TableCell>
                  <TableCell className="font-data text-xs text-text-2">{formatSpan(outage.duration_seconds)}</TableCell>
                  <TableCell className="text-text-2">{outage.upstream_name ?? "-"}</TableCell>
                </TableRow>
              ))
            ) : (
              <TableRow className="hover:bg-transparent">
                <TableCell colSpan={5} className="text-center text-[13px] text-text-3">
                  {data ? "No outages recorded" : error ? error : "Loading outages"}
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
      <div className="flex items-center justify-between gap-3">
        <span className="font-data text-[11px] text-text-3">
          {first} to {last} of {total}
          {error && data ? <span className="ml-3 text-danger">{error}</span> : null}
        </span>
        <div className="flex items-center gap-1">
          <IconButton
            label="Newer outages"
            variant="outline"
            size="icon-sm"
            side="top"
            disabled={page <= 1}
            onClick={() => onPage(Math.max(1, page - 1))}
          >
            <ChevronLeftIcon />
          </IconButton>
          <IconButton
            label="Older outages"
            variant="outline"
            size="icon-sm"
            side="top"
            disabled={page >= pageCount}
            onClick={() => onPage(page + 1)}
          >
            <ChevronRightIcon />
          </IconButton>
        </div>
      </div>
    </section>
  )
}
