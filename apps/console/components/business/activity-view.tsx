"use client"

import * as React from "react"

import { AuditTable } from "@/components/business/audit-table"
import { PageError, PageLoading, PageRestricted } from "@/components/business/panels"
import { useCurrentSite } from "@/components/business/use-current-site"
import { AppFrame } from "@/components/shell/app-frame"
import { api } from "@/lib/api"
import type { AuditQuery } from "@/lib/types"

/**
 * The activity page: the audit log of the current organisation, for admins and owners.
 *
 * @returns The page inside the application frame.
 */
export function ActivityView() {
  const { site, loaded, error, isManager } = useCurrentSite()
  const organisation = site?.organisation
  const load = React.useCallback(
    (params: AuditQuery, signal: AbortSignal) => api.organisationAudit(organisation ?? "", params, signal),
    [organisation],
  )

  let content: React.ReactNode
  if (!loaded) content = <PageLoading label="Loading activity" />
  else if (error) content = <PageError title="Cannot load activity" message={error} />
  else if (!site) content = <PageRestricted title="No site yet" message="Pair a connector or add a site to see activity." />
  else if (!isManager) content = <PageRestricted title="Activity is restricted" message="Only admins and owners see the activity." />
  else {
    content = <AuditTable load={load} restrictedMessage="Only admins and owners see the activity." />
  }

  return (
    <AppFrame>
      <main className="@container min-h-0 min-w-0 flex-1 overflow-y-auto">{content}</main>
    </AppFrame>
  )
}
