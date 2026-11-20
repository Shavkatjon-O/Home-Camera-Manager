"use client"

import * as React from "react"
import { XIcon } from "lucide-react"

import { AUDIT_ACTIONS, humanise } from "@/components/business/labels"
import { PageError, PageLoading, PageRestricted } from "@/components/business/panels"
import { Pager } from "@/components/people/pager"
import { ToolbarRow } from "@/components/shell/page-frame"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { ApiError, errorMessage, isAbort } from "@/lib/api"
import { formatDateTime } from "@/lib/format"
import type { AuditQuery, AuditRecord, Page } from "@/lib/types"

/** Audit records per page. */
export const AUDIT_PAGE_SIZE = 50
const ALL_ACTIONS = "all"
const DAY_MS = 86400000

/** What an audit log is filtered by: one action or all, a day range and, for platform admins, an organisation. */
export interface AuditFilters {
  action: string
  from: string
  to: string
  organisation: string
}

/** The filters of an unfiltered audit log. */
export const NO_AUDIT_FILTERS: AuditFilters = { action: ALL_ACTIONS, from: "", to: "", organisation: "" }

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

function ActorCell({ record }: { record: AuditRecord }) {
  const primary = record.actor_name ?? record.actor_email ?? record.actor
  const secondary = record.actor_name && record.actor_email ? record.actor_email : null
  if (!primary) return <span className="text-text-3">-</span>
  return (
    <div className="flex min-w-0 flex-col">
      <span className="truncate text-foreground">{primary}</span>
      {secondary ? <span className="truncate font-data text-[11px] text-text-3">{secondary}</span> : null}
    </div>
  )
}

/**
 * The filters of an audit log for a page header's toolbar: the action, the first and last day and, with
 * withOrganisation, an organisation id.
 */
export function AuditFilterBar({
  value,
  onChange,
  withOrganisation = false,
}: {
  value: AuditFilters
  onChange: (value: AuditFilters) => void
  withOrganisation?: boolean
}) {
  const set = (patch: Partial<AuditFilters>) => onChange({ ...value, ...patch })
  const filtered =
    value.action !== ALL_ACTIONS || value.from !== "" || value.to !== "" || (withOrganisation && value.organisation !== "")
  return (
    <ToolbarRow>
      <Select value={value.action} onValueChange={(action) => set({ action })}>
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
      <label className="flex items-center gap-2 text-[12px] text-text-3">
        From
        <Input
          type="date"
          value={value.from}
          className="h-8 w-40 font-data text-[12px]"
          onChange={(event) => set({ from: event.target.value })}
        />
      </label>
      <label className="flex items-center gap-2 text-[12px] text-text-3">
        To
        <Input
          type="date"
          value={value.to}
          className="h-8 w-40 font-data text-[12px]"
          onChange={(event) => set({ to: event.target.value })}
        />
      </label>
      {withOrganisation ? (
        <Input
          aria-label="Organisation id"
          value={value.organisation}
          placeholder="All organisations"
          spellCheck={false}
          autoComplete="off"
          className="h-8 w-72 font-data text-[12px]"
          onChange={(event) => set({ organisation: event.target.value })}
        />
      ) : null}
      {filtered ? (
        <Button variant="ghost" size="sm" onClick={() => onChange(NO_AUDIT_FILTERS)}>
          <XIcon />
          Clear
        </Button>
      ) : null}
    </ToolbarRow>
  )
}

/**
 * A paged table of audit records under the given filters, which the page shows in its header with
 * AuditFilterBar. A change of filters starts again from the newest page.
 */
export function AuditTable({
  load,
  filters,
  withOrganisation = false,
  restrictedMessage,
}: {
  load: (params: AuditQuery, signal: AbortSignal) => Promise<Page<AuditRecord>>
  filters: AuditFilters
  withOrganisation?: boolean
  restrictedMessage: string
}) {
  const [paging, setPaging] = React.useState({ filters, page: 1 })
  const page = paging.filters === filters ? paging.page : 1
  const setPage = (next: number) => setPaging({ filters, page: next })
  const [reload, setReload] = React.useState(0)
  const [data, setData] = React.useState<Page<AuditRecord> | null>(null)
  const [error, setError] = React.useState<ApiError | Error | null>(null)
  const { action, from, to, organisation } = filters

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

  if (error instanceof ApiError && error.status === 403) {
    return <PageRestricted title="Activity is restricted" message={restrictedMessage} />
  }
  if (!data && error) {
    return <PageError title="Cannot load activity" message={error.message} onRetry={() => setReload((value) => value + 1)} />
  }
  if (!data) return <PageLoading label="Loading activity" />

  return (
    <div className="flex flex-col gap-3 p-3 sm:p-4">
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
                  <TableCell>
                    <ActorCell record={record} />
                  </TableCell>
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
