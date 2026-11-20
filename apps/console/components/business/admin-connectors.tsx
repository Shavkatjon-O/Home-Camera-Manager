"use client"

import * as React from "react"

import { PageError, PageLoading, PageRestricted } from "@/components/business/panels"
import { Pager } from "@/components/people/pager"
import { Chip } from "@/components/shell/primitives"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { ApiError, api, errorMessage, isAbort } from "@/lib/api"
import { formatDateTime } from "@/lib/format"
import type { AdminConnector, Page } from "@/lib/types"

const PAGE_SIZE = 50

/**
 * The connectors of every organisation, most recently seen first.
 *
 * @param props - The message shown to users who are not platform admins.
 * @returns The connector table with paging.
 */
export function AdminConnectors({ notAdminMessage }: { notAdminMessage: string }) {
  const [page, setPage] = React.useState(1)
  const [reload, setReload] = React.useState(0)
  const [data, setData] = React.useState<Page<AdminConnector> | null>(null)
  const [error, setError] = React.useState<ApiError | Error | null>(null)

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .adminConnectors({ page, page_size: PAGE_SIZE }, controller.signal)
      .then((result) => {
        setData(result)
        setError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setError(err instanceof Error ? err : new Error(errorMessage(err)))
      })
    return () => controller.abort()
  }, [page, reload])

  if (error instanceof ApiError && error.status === 403) {
    return <PageRestricted title="Platform admin only" message={notAdminMessage} />
  }
  if (!data && error) {
    return <PageError title="Cannot load connectors" message={error.message} onRetry={() => setReload((value) => value + 1)} />
  }
  if (!data) return <PageLoading label="Loading connectors" />

  return (
    <div className="flex flex-col gap-3 p-3 sm:p-4">
      <div className="overflow-x-auto rounded-lg border border-hairline">
        <Table>
          <TableHeader>
            <TableRow className="hover:bg-transparent">
              <TableHead>Name</TableHead>
              <TableHead>Organisation</TableHead>
              <TableHead>Site</TableHead>
              <TableHead>Version</TableHead>
              <TableHead>Mode</TableHead>
              <TableHead>State</TableHead>
              <TableHead>Last seen</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.items.length > 0 ? (
              data.items.map((connector) => (
                <TableRow key={connector.uuid}>
                  <TableCell>{connector.name}</TableCell>
                  <TableCell className="text-text-2">{connector.organisation_name ?? "-"}</TableCell>
                  <TableCell className="text-text-2">{connector.site_name ?? "-"}</TableCell>
                  <TableCell className="font-data text-xs text-text-2">{connector.version ?? "-"}</TableCell>
                  <TableCell className="text-text-2">{connector.mode === "tunnel" ? "Tunnel" : "Direct"}</TableCell>
                  <TableCell>
                    {connector.revoked_at ? (
                      <Chip className="text-danger">Revoked</Chip>
                    ) : connector.online ? (
                      <Chip>Online</Chip>
                    ) : (
                      <Chip>Offline</Chip>
                    )}
                  </TableCell>
                  <TableCell className="font-data text-xs text-text-2">{formatDateTime(connector.last_seen_at)}</TableCell>
                </TableRow>
              ))
            ) : (
              <TableRow className="hover:bg-transparent">
                <TableCell colSpan={7} className="text-center text-[13px] text-text-3">
                  No connectors yet
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
        previousLabel="Previous page"
        nextLabel="Next page"
        onPage={setPage}
      />
    </div>
  )
}
