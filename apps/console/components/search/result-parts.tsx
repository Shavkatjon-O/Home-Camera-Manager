"use client"

import * as React from "react"
import Image from "next/image"
import { ImageOffIcon, UserRoundSearchIcon, UserSearchIcon } from "lucide-react"

import { overlayButton } from "@/components/people/face-parts"
import { IconButton } from "@/components/shell/icon-button"
import { Chip } from "@/components/shell/primitives"
import { useCan } from "@/components/shell/session"
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"
import { cn } from "@/lib/utils"

export interface SimilarTarget {
  sample?: string | null
  event?: string | null
}

/** A small tag on a search result, red for alerts. */
export function TagChip({ tone, className, children }: { tone?: "alert"; className?: string; children: React.ReactNode }) {
  return (
    <Chip className={cn("h-5 px-1.5 text-[10px]", tone === "alert" && "bg-status-err/15 text-status-err", className)}>
      {children}
    </Chip>
  )
}

/** The thumbnail of a search result, with a placeholder when it has none. */
export function ResultImage({
  src,
  fit,
  sizes,
  className,
}: {
  src: string | null
  fit: "cover" | "contain"
  sizes: string
  className?: string
}) {
  const [failed, setFailed] = React.useState<string | null>(null)
  return (
    <div className={cn("relative aspect-video shrink-0 overflow-hidden rounded-md bg-surface-2", className)}>
      {src && failed !== src ? (
        <Image
          src={src}
          alt=""
          fill
          sizes={sizes}
          className={fit === "contain" ? "object-contain" : "object-cover"}
          onError={() => setFailed(src)}
        />
      ) : (
        <div className="absolute inset-0 flex items-center justify-center text-text-3 [&_svg]:size-4">
          <ImageOffIcon aria-hidden />
        </div>
      )}
    </div>
  )
}

/** Starts a search for faces or vehicles that look like this result; shown to admins only. */
export function SimilarButton({
  target,
  onFind,
  overlay,
}: {
  target: SimilarTarget
  onFind: (target: SimilarTarget) => void
  overlay?: boolean
}) {
  const canManage = useCan("admin")
  if (!canManage) return null
  if (overlay) {
    return (
      <Tooltip>
        <TooltipTrigger asChild>
          <button type="button" aria-label="Find similar" onClick={() => onFind(target)} className={overlayButton}>
            <UserRoundSearchIcon />
          </button>
        </TooltipTrigger>
        <TooltipContent>Find similar</TooltipContent>
      </Tooltip>
    )
  }
  return (
    <IconButton label="Find similar" size="icon-sm" onClick={() => onFind(target)}>
      <UserRoundSearchIcon />
    </IconButton>
  )
}

/** Starts a search for other sightings of the person in this result. */
export function FindPersonButton({
  eventUuid,
  onFindPerson,
  overlay,
}: {
  eventUuid: string
  onFindPerson: (eventUuid: string) => void
  overlay?: boolean
}) {
  if (overlay) {
    return (
      <Tooltip>
        <TooltipTrigger asChild>
          <button
            type="button"
            aria-label="Find this person"
            onClick={() => onFindPerson(eventUuid)}
            className={overlayButton}
          >
            <UserSearchIcon />
          </button>
        </TooltipTrigger>
        <TooltipContent>Find this person</TooltipContent>
      </Tooltip>
    )
  }
  return (
    <IconButton label="Find this person" size="icon-sm" onClick={() => onFindPerson(eventUuid)}>
      <UserSearchIcon />
    </IconButton>
  )
}
