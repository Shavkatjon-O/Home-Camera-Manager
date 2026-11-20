"use client"

import * as React from "react"

import { featureLabel, limitLabel, limitText, metricLabel, usageText } from "@/components/business/labels"
import { PageError, PageLoading, PageRestricted } from "@/components/business/panels"
import { CardGrid, PageContent, PageFrame } from "@/components/shell/page-frame"
import { useCan, useSession } from "@/components/shell/session"
import { Chip } from "@/components/shell/primitives"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { api, errorMessage, isAbort } from "@/lib/api"
import type { OrganisationPlan, OrganisationUsage } from "@/lib/types"

const USAGE_DAYS = 30
const COUNTED_LIMITS = ["sites", "cameras", "members"] as const
const RETENTION_LIMITS = ["event_retention_days", "clip_retention_days"] as const

function LimitRow({ name, used, limit }: { name: string; used: number; limit: number | null }) {
  return (
    <TableRow>
      <TableCell>{name}</TableCell>
      <TableCell className="font-data text-xs text-text-2">
        {limit === null ? `${used} used, Unlimited` : `${used} of ${limit}`}
      </TableCell>
    </TableRow>
  )
}

function UsageSection({ usage }: { usage: OrganisationUsage }) {
  const metrics = usage.totals.map((total) => total.metric)
  const days = Array.from(new Set(usage.series.map((point) => point.at))).sort().reverse()
  const value = (at: string, metric: string) =>
    usage.series.find((point) => point.at === at && point.metric === metric)?.value
  return (
    <section className="flex flex-col gap-2" aria-labelledby="usage-title">
      <h2 id="usage-title" className="text-xs text-text-3">
        Usage over the last {USAGE_DAYS} days
      </h2>
      <CardGrid>
        {usage.totals.map((total) => (
          <div key={total.metric} className="flex flex-col gap-1 rounded-lg border border-hairline p-3">
            <span className="text-xs text-text-3">{metricLabel(total.metric)}</span>
            <span className="font-data text-[15px] text-foreground">{usageText(total.metric, total.value)}</span>
          </div>
        ))}
      </CardGrid>
      <div className="overflow-x-auto rounded-lg border border-hairline">
        <Table>
          <TableHeader>
            <TableRow className="hover:bg-transparent">
              <TableHead>Day</TableHead>
              {metrics.map((metric) => (
                <TableHead key={metric}>{metricLabel(metric)}</TableHead>
              ))}
            </TableRow>
          </TableHeader>
          <TableBody>
            {days.length > 0 ? (
              days.map((at) => (
                <TableRow key={at}>
                  <TableCell className="font-data text-xs text-text-2">{at.slice(0, 10)}</TableCell>
                  {metrics.map((metric) => {
                    const amount = value(at, metric)
                    return (
                      <TableCell key={metric} className="font-data text-xs text-text-2">
                        {amount === undefined ? "-" : usageText(metric, amount)}
                      </TableCell>
                    )
                  })}
                </TableRow>
              ))
            ) : (
              <TableRow className="hover:bg-transparent">
                <TableCell colSpan={metrics.length + 1} className="text-center text-[13px] text-text-3">
                  No usage recorded yet
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
    </section>
  )
}

/**
 * The plan and usage page: plan name, limits against usage, features and, for admins, metered usage.
 *
 * @returns The page inside the application frame.
 */
export function PlanView() {
  const { site, sitesLoaded: loaded, sitesError: siteError } = useSession()
  const isManager = useCan("admin")
  const organisation = site?.organisation
  const [plan, setPlan] = React.useState<OrganisationPlan | null>(null)
  const [usage, setUsage] = React.useState<OrganisationUsage | null>(null)
  const [error, setError] = React.useState<string | null>(null)
  const [usageError, setUsageError] = React.useState<string | null>(null)

  React.useEffect(() => {
    if (!organisation) return
    const controller = new AbortController()
    api
      .organisationPlan(organisation, controller.signal)
      .then((data) => {
        setPlan(data)
        setError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setError(errorMessage(err))
      })
    return () => controller.abort()
  }, [organisation])

  React.useEffect(() => {
    if (!organisation || !isManager) return
    const controller = new AbortController()
    api
      .organisationUsage(organisation, USAGE_DAYS, controller.signal)
      .then((data) => {
        setUsage(data)
        setUsageError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setUsageError(errorMessage(err))
      })
    return () => controller.abort()
  }, [organisation, isManager])

  let content: React.ReactNode
  if (!loaded || (organisation && !plan && !error)) content = <PageLoading label="Loading plan" />
  else if (siteError) content = <PageError title="Cannot load plan" message={siteError} />
  else if (!site) content = <PageRestricted title="No site yet" message="Pair a connector or add a site to see the plan." />
  else if (!plan) content = <PageError title="Cannot load plan" message={error ?? "Unknown error"} />
  else {
    content = (
      <PageContent>
        <div className="flex flex-wrap items-center gap-2">
          <h2 className="text-[15px] text-foreground">{plan.plan.name}</h2>
          <Chip>{site.organisation_name}</Chip>
          {plan.suspended ? <Chip className="text-danger">Suspended</Chip> : null}
        </div>
        <section className="flex flex-col gap-2" aria-labelledby="limits-title">
          <h2 id="limits-title" className="text-xs text-text-3">
            Limits and usage
          </h2>
          <div className="overflow-x-auto rounded-lg border border-hairline">
            <Table>
              <TableHeader>
                <TableRow className="hover:bg-transparent">
                  <TableHead>Limit</TableHead>
                  <TableHead>Usage</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {COUNTED_LIMITS.map((key) => (
                  <LimitRow key={key} name={limitLabel(key)} used={plan.usage[key]} limit={plan.plan.limits[key]} />
                ))}
                {RETENTION_LIMITS.map((key) => (
                  <TableRow key={key}>
                    <TableCell>{limitLabel(key)}</TableCell>
                    <TableCell className="font-data text-xs text-text-2">{limitText(plan.plan.limits[key])}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        </section>
        <section className="flex flex-col gap-2" aria-labelledby="features-title">
          <h2 id="features-title" className="text-xs text-text-3">
            Features
          </h2>
          {plan.plan.features.length > 0 ? (
            <div className="flex flex-wrap gap-2">
              {plan.plan.features.map((feature) => (
                <Chip key={feature}>{featureLabel(feature)}</Chip>
              ))}
            </div>
          ) : (
            <p className="text-[13px] text-text-3">This plan has no extra features.</p>
          )}
        </section>
        {isManager ? (
          usage ? (
            <UsageSection usage={usage} />
          ) : usageError ? (
            <p className="text-[13px] text-danger">{usageError}</p>
          ) : (
            <PageLoading label="Loading usage" />
          )
        ) : null}
      </PageContent>
    )
  }

  return (
    <PageFrame contained>
      <main className="@container min-h-0 min-w-0 flex-1 overflow-y-auto">{content}</main>
    </PageFrame>
  )
}
