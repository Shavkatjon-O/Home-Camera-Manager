"use client"

import * as React from "react"
import Image from "next/image"
import { ImageOffIcon, UserRoundSearchIcon } from "lucide-react"

import { overlayButton } from "@/components/people/face-parts"
import { IconButton } from "@/components/shell/icon-button"
import { Chip } from "@/components/shell/primitives"
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"
import { cn } from "@/lib/utils"

export interface SimilarTarget {
  sample?: string | null
  event?: string | null
}

export function TagChip({ tone, className, children }: { tone?: "alert"; className?: string; children: React.ReactNode }) {
  return (
    <Chip className={cn("h-5 px-1.5 text-[10px]", tone === "alert" && "bg-status-err/15 text-status-err", className)}>
      {children}
    </Chip>
  )
}

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

export function SimilarButton({
  target,
  onFind,
  overlay,
}: {
  target: SimilarTarget
  onFind: (target: SimilarTarget) => void
  overlay?: boolean
}) {
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
