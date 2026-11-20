"use client"

import * as React from "react"
import Image from "next/image"
import Link from "next/link"
import { ArrowUpRightIcon, ImageOffIcon, SearchIcon, UserRoundSearchIcon } from "lucide-react"

import { Chip } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"
import {
  faceCropUrl,
  faceName,
  formatScore,
  personHref,
  safeColor,
  sampleCropUrl,
  searchHref,
  similarHref,
  type Face,
  type FaceIdentity,
} from "@/lib/people"
import { cn } from "@/lib/utils"

export const overlayButton =
  "inline-flex size-7 items-center justify-center rounded-md bg-black/60 text-white/80 transition-colors hover:bg-black/80 hover:text-white disabled:pointer-events-none disabled:opacity-50 [&_svg]:size-3.5"

export function ColorDot({ color, className }: { color: string | null | undefined; className?: string }) {
  const value = safeColor(color)
  return (
    <span
      aria-hidden
      className={cn("inline-block size-2 shrink-0 rounded-full", !value && "bg-status-off", className)}
      style={value ? { backgroundColor: value } : undefined}
    />
  )
}

export function FaceCrop({
  sample,
  src,
  alt = "",
  fit = "cover",
  sizes = "96px",
  className,
}: {
  sample?: string | null
  src?: string | null
  alt?: string
  fit?: "cover" | "contain"
  sizes?: string
  className?: string
}) {
  const url = src ?? (sample ? sampleCropUrl(sample) : null)
  const [failed, setFailed] = React.useState<string | null>(null)
  const shown = url !== null && failed !== url
  return (
    <div className={cn("relative aspect-square shrink-0 overflow-hidden rounded-md bg-surface-2", className)}>
      {shown ? (
        <Image
          src={url}
          alt={alt}
          fill
          sizes={sizes}
          className={fit === "contain" ? "object-contain" : "object-cover"}
          onError={() => setFailed(url)}
        />
      ) : (
        <div
          role={alt ? "img" : undefined}
          aria-label={alt || undefined}
          className="absolute inset-0 flex items-center justify-center text-text-3 [&_svg]:size-4"
        >
          <ImageOffIcon aria-hidden />
        </div>
      )}
    </div>
  )
}

export function FaceChip({ face, className }: { face: FaceIdentity; className?: string }) {
  const known = Boolean(face.person_name)
  return (
    <Chip className={cn("max-w-full min-w-0", className)}>
      <ColorDot color={known ? face.person_color : null} />
      <span className={cn("truncate", known && "text-foreground")}>{faceName(face)}</span>
    </Chip>
  )
}

export function FaceSummary({
  face,
  eventUuid,
  links = true,
  className,
}: {
  face: Face
  eventUuid?: string | null
  links?: boolean
  className?: string
}) {
  const name = faceName(face)
  const similar = face.sample_uuid || eventUuid ? similarHref({ sample: face.sample_uuid, event: eventUuid }) : null
  return (
    <div className={cn("flex min-w-0 items-start gap-3", className)}>
      <FaceCrop src={faceCropUrl(face, eventUuid)} alt={`Face of ${name}`} className="size-16" />
      <div className="flex min-w-0 flex-1 flex-col gap-1.5">
        <FaceChip face={face} className="self-start" />
        <span className="font-data text-[12px] text-text-2">Confidence {formatScore(face.confidence)}</span>
        {links ? (
          <div className="flex flex-wrap gap-1.5">
            {similar ? (
              <Button asChild variant="outline" size="xs">
                <Link href={similar}>
                  <UserRoundSearchIcon />
                  Find similar
                </Link>
              </Button>
            ) : null}
            {face.person_uuid ? (
              <Button asChild variant="outline" size="xs">
                <Link href={personHref(face.person_uuid)}>
                  <ArrowUpRightIcon />
                  Open person
                </Link>
              </Button>
            ) : face.cluster_uuid ? (
              <Button asChild variant="outline" size="xs">
                <Link href={searchHref({ cluster: face.cluster_uuid })}>
                  <SearchIcon />
                  Search events
                </Link>
              </Button>
            ) : null}
          </div>
        ) : null}
      </div>
    </div>
  )
}
