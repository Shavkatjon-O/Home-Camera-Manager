"use client"

import * as React from "react"

import { AdminConnectors } from "@/components/business/admin-connectors"
import { AdminOrganisations } from "@/components/business/admin-organisations"
import { AuditFilterBar, AuditTable, NO_AUDIT_FILTERS } from "@/components/business/audit-table"
import { PageFrame } from "@/components/shell/page-frame"
import { RoleGate } from "@/components/shell/role-gate"
import { Segmented } from "@/components/shell/segmented"
import { api } from "@/lib/api"
import type { AuditQuery } from "@/lib/types"

type Section = "organisations" | "connectors" | "audit"

const SECTIONS: { value: Section; label: string }[] = [
  { value: "organisations", label: "Organisations" },
  { value: "connectors", label: "Connectors" },
  { value: "audit", label: "Audit log" },
]

const NOT_ADMIN = "Only platform admins see this page."

function loadAudit(params: AuditQuery, signal: AbortSignal) {
  return api.adminAudit(params, signal)
}

/**
 * The platform admin page with organisations, connectors and the audit log of every organisation.
 *
 * @returns The page inside the application frame.
 */
export function AdminView() {
  return (
    <RoleGate platformAdmin>
      <AdminSections />
    </RoleGate>
  )
}

function AdminSections() {
  const [section, setSection] = React.useState<Section>("organisations")
  const [filters, setFilters] = React.useState(NO_AUDIT_FILTERS)
  return (
    <PageFrame
      actions={<Segmented<Section> label="Section" value={section} options={SECTIONS} onChange={setSection} />}
      toolbar={section === "audit" ? <AuditFilterBar value={filters} onChange={setFilters} withOrganisation /> : null}
    >
      <main className="@container min-h-0 min-w-0 flex-1 overflow-y-auto">
        {section === "organisations" ? <AdminOrganisations notAdminMessage={NOT_ADMIN} /> : null}
        {section === "connectors" ? <AdminConnectors notAdminMessage={NOT_ADMIN} /> : null}
        {section === "audit" ? (
          <AuditTable load={loadAudit} filters={filters} withOrganisation restrictedMessage={NOT_ADMIN} />
        ) : null}
      </main>
    </PageFrame>
  )
}
