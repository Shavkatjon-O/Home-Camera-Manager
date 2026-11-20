"use client"

import * as React from "react"
import Link from "next/link"
import { ArrowLeftIcon, CircleAlertIcon, ImageUpIcon, ScanFaceIcon } from "lucide-react"

import { FaceChip, FaceCrop } from "@/components/people/face-parts"
import { Pager } from "@/components/people/pager"
import { usePagedQuery } from "@/components/people/use-paged"
import { SimilarButton, type SimilarTarget } from "@/components/search/result-parts"
import type { Layout } from "@/components/search/search-params"
import { EmptyState, LoadingState } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"
import { formatMoment } from "@/lib/health"
import { eventHref, formatScore, peopleApi, personHref, type SimilarFace, type SimilarQuery } from "@/lib/people"
import { cn } from "@/lib/utils"

export const SIMILAR_PAGE_SIZE = 48

export interface SimilarSource {
  key: string
  kind: "sample" | "event" | "photo"
  query: SimilarQuery
  preview: string | null
}

function whereOf(face: SimilarFace): string {
  if (face.source === "upload") return "Uploaded photo"
  const parts = [face.camera_name ?? "Removed camera"]
  if (face.view_name && face.view_name !== face.camera_name) parts.push(face.view_name)
  return parts.join(", ")
}

function hrefOf(face: SimilarFace): string | null {
  if (face.event_uuid) return eventHref(face.event_uuid)
  if (face.person_uuid) return personHref(face.person_uuid)
  return null
}

function MaybeLink({ href, className, children }: { href: string | null; className?: string; children: React.ReactNode }) {
  if (!href) return <div className={className}>{children}</div>
  return (
    <Link href={href} className={className}>
      {children}
    </Link>
  )
}

function Score({ value }: { value: number }) {
  return (
    <span className="shrink-0 font-data text-[12px] text-foreground">
      {formatScore(value)}
      <span className="ml-1 text-text-3">similar</span>
    </span>
  )
}

function SimilarCard({ face, onFind }: { face: SimilarFace; onFind: (target: SimilarTarget) => void }) {
  return (
    <li className="relative min-w-0 overflow-hidden rounded-lg border border-hairline bg-surface transition-colors hover:border-hairline-strong">
      <MaybeLink href={hrefOf(face)} className="flex flex-col">
        <FaceCrop
          sample={face.has_crop ? face.sample_uuid : null}
          sizes="(min-width: 1024px) 16vw, 50vw"
          className="w-full rounded-none"
        />
        <div className="flex min-w-0 flex-col gap-1.5 p-2.5">
          <div className="flex min-w-0 items-center justify-between gap-2">
            <FaceChip face={face} className="h-5 px-1.5 text-[10px]" />
            <Score value={face.score} />
          </div>
          <span className="truncate text-[12px] text-text-2">{whereOf(face)}</span>
          <span className="font-data text-[11px] text-text-3">{formatMoment(face.seen_at)}</span>
        </div>
      </MaybeLink>
      <div className="absolute top-2 right-2">
        <SimilarButton target={{ sample: face.sample_uuid }} onFind={onFind} overlay />
      </div>
    </li>
  )
}

function SimilarRow({ face, onFind }: { face: SimilarFace; onFind: (target: SimilarTarget) => void }) {
  return (
    <li className="flex items-center gap-1 border-b border-hairline pr-2 transition-colors hover:bg-surface-2 sm:pr-3">
      <MaybeLink href={hrefOf(face)} className="flex min-w-0 flex-1 items-center gap-3 px-3 py-2 sm:px-4">
        <FaceCrop sample={face.has_crop ? face.sample_uuid : null} sizes="56px" className="size-14" />
        <div className="flex min-w-0 flex-1 flex-col gap-1">
          <div className="flex min-w-0 items-center gap-2">
            <FaceChip face={face} className="h-5 px-1.5 text-[10px]" />
            <Score value={face.score} />
          </div>
          <div className="flex min-w-0 flex-wrap items-center gap-x-2 gap-y-1">
            <span className="min-w-0 truncate text-[12px] text-text-2">{whereOf(face)}</span>
            <span className="font-data text-[12px] text-text-3">{formatMoment(face.seen_at)}</span>
          </div>
        </div>
      </MaybeLink>
      <SimilarButton target={{ sample: face.sample_uuid }} onFind={onFind} />
    </li>
  )
}

export function SimilarResults({
  source,
  layout,
  toolbar,
  onBack,
  onFind,
  onAnotherPhoto,
}: {
  source: SimilarSource
  layout: Layout
  toolbar?: React.ReactNode
  onBack: () => void
  onFind: (target: SimilarTarget) => void
  onAnotherPhoto: () => void
}) {
  const { query } = source
  const load = React.useCallback(
    (page: number, signal: AbortSignal) =>
      peopleApi.findSimilar({ ...query, page, page_size: SIMILAR_PAGE_SIZE }, signal),
    [query],
  )
  const list = usePagedQuery<SimilarFace>(source.key, load, SIMILAR_PAGE_SIZE)
  const data = list.data

  let content: React.ReactNode
  if (!data && list.error) {
    content =
      source.kind === "photo" ? (
        <EmptyState icon={<CircleAlertIcon />} title="This photo cannot be searched">
          <span>{list.error}</span>
          <div className="flex flex-wrap justify-center gap-2">
            <Button variant="outline" onClick={onAnotherPhoto}>
              <ImageUpIcon />
              Choose another photo
            </Button>
            <Button variant="ghost" onClick={onBack}>
              Back to results
            </Button>
          </div>
        </EmptyState>
      ) : (
        <EmptyState icon={<CircleAlertIcon />} title="Cannot find similar faces">
          <span className="font-data text-xs">{list.error}</span>
          <Button variant="outline" onClick={list.refresh}>
            Try again
          </Button>
        </EmptyState>
      )
  } else if (!data) {
    content = <LoadingState label="Comparing faces" />
  } else if (data.total === 0) {
    content = (
      <EmptyState icon={<ScanFaceIcon />} title="No similar faces">
        <span>No stored face is close enough to this one.</span>
      </EmptyState>
    )
  } else {
    content = (
      <div className="flex flex-col">
        {layout === "grid" ? (
          <ul
            aria-label="Similar faces"
            className="grid grid-cols-2 gap-3 p-3 sm:p-4 @xl:grid-cols-3 @3xl:grid-cols-4 @5xl:grid-cols-6"
          >
            {data.items.map((face) => (
              <SimilarCard key={face.sample_uuid} face={face} onFind={onFind} />
            ))}
          </ul>
        ) : (
          <ul aria-label="Similar faces">
            {data.items.map((face) => (
              <SimilarRow key={face.sample_uuid} face={face} onFind={onFind} />
            ))}
          </ul>
        )}
        <Pager
          page={list.page}
          pageSize={SIMILAR_PAGE_SIZE}
          total={data.total}
          error={list.error}
          previousLabel="Closer matches"
          nextLabel="Weaker matches"
          onPage={list.setPage}
          className="px-3 py-3 sm:px-4"
        />
      </div>
    )
  }

  return (
    <div className="flex min-h-full flex-col">
      <div className="flex flex-wrap items-center gap-3 border-b border-hairline px-3 py-3 sm:px-4">
        <Button variant="ghost" size="sm" onClick={onBack}>
          <ArrowLeftIcon />
          Back to results
        </Button>
        <FaceCrop src={source.preview} alt="The face searched for" sizes="40px" className="size-10" />
        <div className="flex min-w-0 flex-col gap-0.5">
          <span className="text-[13px] text-foreground">
            {source.kind === "photo" ? "Faces similar to this photo" : "Faces similar to this face"}
          </span>
          <span className={cn("font-data text-[11px] text-text-3", !data && "invisible")}>
            {data ? (data.total === 1 ? "1 face" : `${data.total} faces`) : "0 faces"}
          </span>
        </div>
        <div className="ml-auto flex items-center gap-2">
          {source.kind === "photo" ? (
            <Button variant="outline" size="sm" onClick={onAnotherPhoto}>
              <ImageUpIcon />
              Another photo
            </Button>
          ) : null}
          {toolbar}
        </div>
      </div>
      <div className="min-h-0 flex-1">{content}</div>
    </div>
  )
}
