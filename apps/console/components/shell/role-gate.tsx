"use client"

import * as React from "react"
import { LockIcon } from "lucide-react"

import { ROLE_LABELS } from "@/components/shell/navigation"
import { PageFrame } from "@/components/shell/page-frame"
import { EmptyState } from "@/components/shell/primitives"
import { useCan, useSession } from "@/components/shell/session"
import type { SiteRole } from "@/lib/types"

/**
 * Shows a page only to members whose role at the current site reaches minRole. Anyone else, for example someone
 * following an old link, gets the page header and an explanation of the role it needs instead of failing requests.
 */
export function RoleGate({ minRole, children }: { minRole: SiteRole; children: React.ReactNode }) {
  const allowed = useCan(minRole)
  const { role, site } = useSession()
  if (allowed) return <>{children}</>
  if (!role) {
    return (
      <PageFrame>
        <main className="min-w-0 flex-1" />
      </PageFrame>
    )
  }
  const article = role === "viewer" ? "a" : "an"
  return (
    <PageFrame>
      <main className="min-w-0 flex-1">
        <EmptyState icon={<LockIcon />} title={`This page needs the ${ROLE_LABELS[minRole].toLowerCase()} role`}>
          <span>
            You are {article} {ROLE_LABELS[role].toLowerCase()}
            {site ? ` at ${site.name}` : ""}. Ask an owner of the organisation if you need it.
          </span>
        </EmptyState>
      </main>
    </PageFrame>
  )
}
