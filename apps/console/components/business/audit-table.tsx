"use client"

import * as React from "react"

import { AUDIT_ACTIONS, humanise } from "@/components/business/labels"
import { PageError, PageLoading, PageRestricted } from "@/components/business/panels"
import { Pager } from "@/components/people/pager"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { ApiError, errorMessage, isAbort } from "@/lib/api"
import { formatDateTime } from "@/lib/format"
import type { AuditQuery, AuditRecord, Page } from "@/lib/types"

export const AUDIT_PAGE_SIZE = 50
const ALL_ACTIONS = "all"
const DAY_MS = 86400000

function startOfDay(value: string): string | undefined {
  if (!value) return undefined
  const date = new Date(`${value}T00:00:00`)
  return Number.isNaN(date.getTime()) ? undefined : date.toISOString()
}

function endOfDay(value: string): string | undefined {
  if (!value) return undefined
  const date = new Date(`${value}T00:00:00`)
  return Number.isNaN(date.getTime()) ? undefined : new Date(date.getTime() + DAY_MS).toISOString()
}

/**
 * A filterable, paged table of audit records.
 *
 * @param props - The loader that fetches one page and whether to offer an organisation filter.
 * @returns The filters, the table and the pager.
 */
export function AuditTable({
  load,
  withOrganisation = false,
  restrictedMessage,
}: {
  load: (params: AuditQuery, signal: AbortSignal) => Promise<Page<AuditRecord>>
  withOrganisation?: boolean
  restrictedMessage: string
}) {
  const [action, setAction] = React.useState(ALL_ACTIONS)
  const [from, setFrom] = React.useState("")
  const [to, setTo] = React.useState("")
  const [organisation, setOrganisation] = React.useState("")
  const [page, setPage] = React.useState(1)
  const [reload, setReload] = React.useState(0)
  const [data, setData] = React.useState<Page<AuditRecord> | null>(null)
  const [error, setError] = React.useState<ApiError | Error | null>(null)

  React.useEffect(() => {
    const controller = new AbortController()
    load(
      {
        action: action === ALL_ACTIONS ? undefined : action,
        since: startOfDay(from),
        until: endOfDay(to),
        organisation: withOrganisation && organisation.trim() ? organisation.trim() : undefined,
        page,
        page_size: AUDIT_PAGE_SIZE,
      },
      controller.signal,
    )
      .then((result) => {
        setData(result)
        setError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setError(err instanceof Error ? err : new Error(errorMessage(err)))
      })
    return () => controller.abort()
  }, [load, action, from, to, organisation, page, reload, withOrganisation])

  const changeFilter = (apply: () => void) => {
    apply()
    setPage(1)
  }

  if (error instanceof ApiError && error.status === 403) {
    return <PageRestricted title="Activity is restricted" message={restrictedMessage} />
  }
  if (!data && error) {
    return <PageError title="Cannot load activity" message={error.message} onRetry={() => setReload((value) => value + 1)} />
  }
  if (!data) return <PageLoading label="Loading activity" />

  return (
    <div className="flex flex-col gap-3 p-3 sm:p-4">
      <div className="flex flex-wrap items-end gap-3">
        <label className="flex flex-col gap-1 text-xs text-text-3">
          Action
          <Select value={action} onValueChange={(value) => changeFilter(() => setAction(value))}>
            <SelectTrigger aria-label="Action" className="w-56">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value={ALL_ACTIONS}>All actions</SelectItem>
              {AUDIT_ACTIONS.map((item) => (
                <SelectItem key={item} value={item}>
                  {humanise(item)}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </label>
        <label className="flex flex-col gap-1 text-xs text-text-3">
          From
          <Input
            type="date"
            value={from}
            className="w-40"
            onChange={(event) => changeFilter(() => setFrom(event.target.value))}
          />
        </label>
        <label className="flex flex-col gap-1 text-xs text-text-3">
          To
          <Input
            type="date"
            value={to}
            className="w-40"
            onChange={(event) => changeFilter(() => setTo(event.target.value))}
          />
        </label>
        {withOrganisation ? (
          <label className="flex flex-col gap-1 text-xs text-text-3">
            Organisation id
            <Input
              value={organisation}
              placeholder="All organisations"
              className="w-72"
              onChange={(event) => changeFilter(() => setOrganisation(event.target.value))}
            />
          </label>
        ) : null}
      </div>
      <div className="overflow-x-auto rounded-lg border border-hairline">
        <Table>
          <TableHeader>
            <TableRow className="hover:bg-transparent">
              <TableHead>Time</TableHead>
              <TableHead>Actor</TableHead>
              <TableHead>Action</TableHead>
              <TableHead>Target kind</TableHead>
              <TableHead>Address</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.items.length > 0 ? (
              data.items.map((record) => (
                <TableRow key={record.uuid}>
                  <TableCell className="font-data text-xs text-text-2">{formatDateTime(record.at)}</TableCell>
                  <TableCell className="text-text-2">{record.actor ?? "-"}</TableCell>
                  <TableCell>{humanise(record.action)}</TableCell>
                  <TableCell className="text-text-2">{record.target_kind ? humanise(record.target_kind) : "-"}</TableCell>
                  <TableCell className="font-data text-xs text-text-2">{record.ip ?? "-"}</TableCell>
                </TableRow>
              ))
            ) : (
              <TableRow className="hover:bg-transparent">
                <TableCell colSpan={5} className="text-center text-[13px] text-text-3">
                  No activity recorded
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
      <Pager
        page={data.page}
        pageSize={data.page_size}
        total={data.total}
        error={error?.message}
        previousLabel="Newer activity"
        nextLabel="Older activity"
        onPage={setPage}
      />
    </div>
  )
}
