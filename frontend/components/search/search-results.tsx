"use client"

import * as React from "react"
import Link from "next/link"
import { CircleAlertIcon, TextSearchIcon } from "lucide-react"

import { Pager } from "@/components/people/pager"
import { FaceChip } from "@/components/people/face-parts"
import { ResultImage, SimilarButton, TagChip, type SimilarTarget } from "@/components/search/result-parts"
import { filtersQuery, hasFilters, type Layout, type SearchFilters } from "@/components/search/search-params"
import { EmptyState, LoadingState, Spinner } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"
import { errorMessage, eventImageUrl, isAbort } from "@/lib/api"
import { formatMoment } from "@/lib/health"
import { eventHref, faceCropUrl, kindLabel, peopleApi, type SearchQuery, type SearchResult } from "@/lib/people"
import type { Page } from "@/lib/types"

export const RESULTS_PAGE_SIZE = 48

function imageOf(result: SearchResult): { src: string | null; fit: "cover" | "contain" } {
  if (result.face) return { src: faceCropUrl(result.face, result.uuid), fit: "contain" }
  return { src: result.has_thumbnail ? eventImageUrl(result.uuid, true) : null, fit: "cover" }
}

function targetOf(result: SearchResult): SimilarTarget | null {
  if (!result.face) return null
  return { sample: result.face.sample_uuid, event: result.uuid }
}

function viewOf(result: SearchResult): string | null {
  const view = result.details.view_name
  return typeof view === "string" && view && view !== result.camera_name ? view : null
}

function ResultRow({ result, onFind }: { result: SearchResult; onFind: (target: SimilarTarget) => void }) {
  const image = imageOf(result)
  const target = targetOf(result)
  const view = viewOf(result)
  return (
    <li className="flex items-center gap-1 border-b border-hairline pr-2 transition-colors hover:bg-surface-2 sm:pr-3">
      <Link href={eventHref(result.uuid)} className="flex min-w-0 flex-1 items-center gap-3 px-3 py-2 sm:px-4">
        <ResultImage src={image.src} fit={image.fit} sizes="160px" className="w-24 sm:w-32" />
        <div className="flex min-w-0 flex-1 flex-col gap-1">
          <div className="flex min-w-0 items-center gap-2">
            <span className="truncate text-[13px] text-foreground">{result.camera_name ?? "Removed camera"}</span>
            <TagChip>{kindLabel(result.kind)}</TagChip>
            {result.details.alert === true ? <TagChip tone="alert">Alert</TagChip> : null}
          </div>
          <div className="flex min-w-0 flex-wrap items-center gap-x-2 gap-y-1">
            {result.face ? <FaceChip face={result.face} className="h-5 px-1.5 text-[10px]" /> : null}
            <span className="font-data text-[12px] text-text-2">{formatMoment(result.started_at)}</span>
            {view ? <span className="min-w-0 truncate text-[12px] text-text-3">{view}</span> : null}
          </div>
        </div>
      </Link>
      {target ? <SimilarButton target={target} onFind={onFind} /> : null}
    </li>
  )
}

function ResultCard({ result, onFind }: { result: SearchResult; onFind: (target: SimilarTarget) => void }) {
  const image = imageOf(result)
  const target = targetOf(result)
  return (
    <li className="relative min-w-0 overflow-hidden rounded-lg border border-hairline bg-surface transition-colors hover:border-hairline-strong">
      <Link href={eventHref(result.uuid)} className="flex flex-col">
        <ResultImage
          src={image.src}
          fit={image.fit}
          sizes="(min-width: 1024px) 25vw, 50vw"
          className="w-full rounded-none"
        />
        <div className="flex min-w-0 flex-col gap-1.5 p-2.5">
          <div className="flex min-w-0 items-center gap-2">
            <span className="truncate text-[13px] text-foreground">{result.camera_name ?? "Removed camera"}</span>
            <TagChip>{kindLabel(result.kind)}</TagChip>
          </div>
          {result.face ? <FaceChip face={result.face} className="h-5 self-start px-1.5 text-[10px]" /> : null}
          <span className="font-data text-[11px] text-text-2">{formatMoment(result.started_at)}</span>
        </div>
      </Link>
      {result.details.alert === true ? (
        <TagChip tone="alert" className="pointer-events-none absolute top-2 left-2">
          Alert
        </TagChip>
      ) : null}
      {target ? (
        <div className="absolute top-2 right-2">
          <SimilarButton target={target} onFind={onFind} overlay />
        </div>
      ) : null}
    </li>
  )
}

export function SearchResults({
  filters,
  page,
  layout,
  toolbar,
  onPage,
  onFind,
}: {
  filters: SearchFilters
  page: number
  layout: Layout
  toolbar?: React.ReactNode
  onPage: (page: number) => void
  onFind: (target: SimilarTarget) => void
}) {
  const key = React.useMemo(
    () => JSON.stringify({ ...filtersQuery(filters), page, page_size: RESULTS_PAGE_SIZE }),
    [filters, page],
  )
  const [reload, setReload] = React.useState(0)
  const [result, setResult] = React.useState<{ key: string; data: Page<SearchResult> } | null>(null)
  const [error, setError] = React.useState<string | null>(null)
  const goToPage = React.useEffectEvent((next: number) => onPage(next))

  React.useEffect(() => {
    const controller = new AbortController()
    const requested = JSON.parse(key) as SearchQuery
    peopleApi
      .searchEvents(requested, controller.signal)
      .then((data) => {
        if (data.items.length === 0 && data.total > 0 && (requested.page ?? 1) > 1) {
          goToPage(Math.max(1, Math.ceil(data.total / RESULTS_PAGE_SIZE)))
          return
        }
        setResult({ key, data })
        setError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setError(errorMessage(err))
      })
    return () => controller.abort()
  }, [key, reload])

  const data = result?.data ?? null
  const loading = result !== null && result.key !== key && !error

  if (!data && error) {
    return (
      <EmptyState icon={<CircleAlertIcon />} title="Cannot search events">
        <span className="font-data text-xs">{error}</span>
        <Button variant="outline" onClick={() => setReload((value) => value + 1)}>
          Try again
        </Button>
      </EmptyState>
    )
  }
  if (!data) return <LoadingState label="Searching events" />
  if (data.total === 0 && !loading) {
    return (
      <EmptyState icon={<TextSearchIcon />} title="No events found">
        <span>
          {hasFilters(filters)
            ? "Nothing matches these filters."
            : "Events appear here as soon as a camera reports motion, a person or a face."}
        </span>
      </EmptyState>
    )
  }

  return (
    <div className="flex flex-col">
      <div className="flex h-12 items-center gap-2 border-b border-hairline px-3 sm:px-4">
        <span className="font-data text-[11px] text-text-3">
          {data.total === 1 ? "1 event" : `${data.total} events`}
        </span>
        {loading ? <Spinner className="size-3.5" /> : null}
        {toolbar ? <div className="ml-auto">{toolbar}</div> : null}
      </div>
      {layout === "grid" ? (
        <ul aria-label="Events" className="grid grid-cols-2 gap-3 p-3 sm:p-4 @2xl:grid-cols-3 @4xl:grid-cols-4 @6xl:grid-cols-5">
          {data.items.map((item) => (
            <ResultCard key={item.uuid} result={item} onFind={onFind} />
          ))}
        </ul>
      ) : (
        <ul aria-label="Events">
          {data.items.map((item) => (
            <ResultRow key={item.uuid} result={item} onFind={onFind} />
          ))}
        </ul>
      )}
      <Pager
        page={page}
        pageSize={RESULTS_PAGE_SIZE}
        total={data.total}
        error={error}
        previousLabel="Newer"
        nextLabel="Older"
        onPage={onPage}
        className="px-3 py-3 sm:px-4"
      />
    </div>
  )
}
