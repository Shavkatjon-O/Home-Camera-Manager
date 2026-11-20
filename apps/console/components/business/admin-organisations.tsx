"use client"

import * as React from "react"
import { toast } from "sonner"

import { PlanDialog, SuspendDialog } from "@/components/business/organisation-dialogs"
import { PageError, PageLoading, PageRestricted } from "@/components/business/panels"
import { Pager } from "@/components/people/pager"
import { Chip } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { ApiError, api, errorMessage, isAbort } from "@/lib/api"
import { formatDateTime } from "@/lib/format"
import type { AdminOrganisation, Page, PlanChoice, PlanOverrides } from "@/lib/types"

const PAGE_SIZE = 50

function usageText(organisation: AdminOrganisation): string {
  const part = (key: string, label: string) => `${organisation.usage[key] ?? 0} ${label}`
  return `${part("sites", "sites")}, ${part("cameras", "cameras")}, ${part("members", "members")}`
}

/**
 * The organisations of the platform with search, plan changes, overrides, suspend and restore.
 *
 * @param props - The message shown to users who are not platform admins.
 * @returns The organisation table with paging and dialogs.
 */
export function AdminOrganisations({ notAdminMessage }: { notAdminMessage: string }) {
  const [search, setSearch] = React.useState("")
  const [term, setTerm] = React.useState("")
  const [page, setPage] = React.useState(1)
  const [reload, setReload] = React.useState(0)
  const [data, setData] = React.useState<Page<AdminOrganisation> | null>(null)
  const [plans, setPlans] = React.useState<PlanChoice[]>([])
  const [error, setError] = React.useState<ApiError | Error | null>(null)
  const [editing, setEditing] = React.useState<AdminOrganisation | null>(null)
  const [suspending, setSuspending] = React.useState<AdminOrganisation | null>(null)
  const [busy, setBusy] = React.useState<string | null>(null)

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .adminOrganisations({ search: term || undefined, page, page_size: PAGE_SIZE }, controller.signal)
      .then((result) => {
        setData(result)
        setError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setError(err instanceof Error ? err : new Error(errorMessage(err)))
      })
    return () => controller.abort()
  }, [term, page, reload])

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .listPlans(controller.signal)
      .then(({ items }) => setPlans(items))
      .catch(() => undefined)
    return () => controller.abort()
  }, [])

  const refresh = () => setReload((value) => value + 1)

  const savePlan = async (plan: string, overrides: PlanOverrides) => {
    if (!editing) return
    await api.adminUpdateOrganisation(editing.uuid, { plan, overrides })
    setEditing(null)
    refresh()
  }

  const suspend = async (reason: string) => {
    if (!suspending) return
    await api.adminSuspendOrganisation(suspending.uuid, reason)
    setSuspending(null)
    refresh()
  }

  const restore = async (organisation: AdminOrganisation) => {
    setBusy(organisation.uuid)
    try {
      await api.adminRestoreOrganisation(organisation.uuid)
      refresh()
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setBusy(null)
    }
  }

  if (error instanceof ApiError && error.status === 403) {
    return <PageRestricted title="Platform admin only" message={notAdminMessage} />
  }
  if (!data && error) return <PageError title="Cannot load organisations" message={error.message} onRetry={refresh} />
  if (!data) return <PageLoading label="Loading organisations" />

  return (
    <div className="flex flex-col gap-3 p-3 sm:p-4">
      <form
        className="flex flex-wrap items-end gap-2"
        onSubmit={(event) => {
          event.preventDefault()
          setPage(1)
          setTerm(search.trim())
        }}
      >
        <label className="flex min-w-0 flex-1 basis-48 flex-col gap-1 text-xs text-text-3 sm:flex-none">
          Search organisations
          <Input
            value={search}
            className="w-full sm:w-72"
            placeholder="Name"
            onChange={(event) => setSearch(event.target.value)}
          />
        </label>
        <Button type="submit" variant="outline">
          Search
        </Button>
      </form>
      <div className="overflow-x-auto rounded-lg border border-hairline">
        <Table>
          <TableHeader>
            <TableRow className="hover:bg-transparent">
              <TableHead>Name</TableHead>
              <TableHead>Owner</TableHead>
              <TableHead>Plan</TableHead>
              <TableHead>Usage</TableHead>
              <TableHead>State</TableHead>
              <TableHead>Created</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.items.length > 0 ? (
              data.items.map((organisation) => (
                <TableRow key={organisation.uuid}>
                  <TableCell>{organisation.name}</TableCell>
                  <TableCell className="text-text-2">{organisation.owner ?? "-"}</TableCell>
                  <TableCell className="text-text-2">{organisation.plan_name}</TableCell>
                  <TableCell className="font-data text-xs text-text-2">{usageText(organisation)}</TableCell>
                  <TableCell>
                    {organisation.suspended_at ? (
                      <Chip className="text-danger" title={organisation.suspended_reason ?? undefined}>
                        Suspended
                      </Chip>
                    ) : (
                      <Chip>Active</Chip>
                    )}
                  </TableCell>
                  <TableCell className="font-data text-xs text-text-2">{formatDateTime(organisation.created_at)}</TableCell>
                  <TableCell>
                    <div className="flex justify-end gap-1">
                      <Button variant="outline" size="sm" onClick={() => setEditing(organisation)}>
                        Change plan
                      </Button>
                      {organisation.suspended_at ? (
                        <Button
                          variant="outline"
                          size="sm"
                          disabled={busy === organisation.uuid}
                          onClick={() => void restore(organisation)}
                        >
                          Restore
                        </Button>
                      ) : (
                        <Button variant="outline" size="sm" onClick={() => setSuspending(organisation)}>
                          Suspend
                        </Button>
                      )}
                    </div>
                  </TableCell>
                </TableRow>
              ))
            ) : (
              <TableRow className="hover:bg-transparent">
                <TableCell colSpan={7} className="text-center text-[13px] text-text-3">
                  No organisations found
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
      {editing ? <PlanDialog organisation={editing} plans={plans} onSave={savePlan} onClose={() => setEditing(null)} /> : null}
      {suspending ? (
        <SuspendDialog organisation={suspending} onConfirm={suspend} onClose={() => setSuspending(null)} />
      ) : null}
    </div>
  )
}
