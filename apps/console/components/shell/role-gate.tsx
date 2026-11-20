"use client"

import * as React from "react"
import { LockIcon } from "lucide-react"

import { ROLE_LABELS, hasRole } from "@/components/shell/navigation"
import { PageFrame } from "@/components/shell/page-frame"
import { EmptyState } from "@/components/shell/primitives"
import { useSession } from "@/components/shell/session"
import type { SiteRole } from "@/lib/types"

/**
 * Shows a page only to members whose role at the current site reaches minRole, or only to platform admins. Anyone
 * else, for example someone following an old link, gets the page header and an explanation instead of failing
 * requests.
 */
export function RoleGate({
  minRole,
  platformAdmin: needsPlatformAdmin = false,
  children,
}: {
  minRole?: SiteRole
  platformAdmin?: boolean
  children: React.ReactNode
}) {
  const { role, site, platformAdmin } = useSession()
  const allowed = needsPlatformAdmin ? platformAdmin : hasRole(role, minRole)
  if (allowed) return <>{children}</>
  if (!needsPlatformAdmin && !role) {
    return (
      <PageFrame>
        <main className="min-w-0 flex-1" />
      </PageFrame>
    )
  }

  let title = "This page is for platform admins"
  let detail = "It shows every organisation on this server, so only platform admins open it."
  if (!needsPlatformAdmin && minRole && role) {
    const article = role === "viewer" ? "a" : "an"
    title = `This page needs the ${ROLE_LABELS[minRole].toLowerCase()} role`
    detail = `You are ${article} ${ROLE_LABELS[role].toLowerCase()}${site ? ` at ${site.name}` : ""}. Ask an owner of the organisation if you need it.`
  }
  return (
    <PageFrame>
      <main className="min-w-0 flex-1">
        <EmptyState icon={<LockIcon />} title={title}>
          <span>{detail}</span>
        </EmptyState>
      </main>
    </PageFrame>
  )
}
