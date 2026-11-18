"use client"

import * as React from "react"
import Link from "next/link"
import { useRouter } from "next/navigation"
import { ArrowUpRightIcon, MaximizeIcon, MinimizeIcon } from "lucide-react"
import { toast } from "sonner"

import { StatusDot } from "@/components/shell/primitives"
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"
import { VideoPlaceholder } from "@/components/video/video-placeholder"
import { VideoStream } from "@/components/video/video-stream"
import { toggleFullscreen, useFullscreenElement } from "@/lib/stores"
import type { Camera } from "@/lib/types"
import { cn } from "@/lib/utils"

const tileButton =
  "inline-flex size-7 items-center justify-center rounded-md bg-black/60 text-white/80 transition-colors hover:bg-black/80 hover:text-white [&_svg]:size-3.5"

export function cameraHref(uuid: string): string {
  return `/camera/?id=${encodeURIComponent(uuid)}`
}

export function WallTile({ camera, lens = null }: { camera: Camera; lens?: number | null }) {
  const router = useRouter()
  const [tile, setTile] = React.useState<HTMLDivElement | null>(null)
  const fullscreen = useFullscreenElement()
  const isFullscreen = tile !== null && fullscreen === tile
  const stream = camera.streams.sub ?? camera.streams.main
  const href = cameraHref(camera.uuid)
  const offline = camera.status.online === false

  const onFullscreen = async () => {
    const ok = await toggleFullscreen(tile)
    if (!ok) toast.error("Fullscreen is not available in this browser")
  }

  return (
    <div
      ref={setTile}
      onDoubleClick={() => router.push(href)}
      className="group relative min-h-0 min-w-0 overflow-hidden bg-black select-none"
    >
      {offline ? (
        <VideoPlaceholder title="Camera offline" detail={camera.status.error} />
      ) : (
        <VideoStream stream={stream} compact lens={lens} lenses={camera.lenses} className="absolute inset-0" />
      )}

      <div className="pointer-events-none absolute bottom-2 left-2 flex max-w-[calc(100%-1rem)] items-center gap-2 rounded-md bg-black/60 px-2 py-1">
        <StatusDot online={camera.status.online} />
        <span className="truncate text-[12px] text-white">{camera.name}</span>
        {lens !== null ? <span className="shrink-0 font-mono text-[11px] text-white/55">Lens {lens + 1}</span> : null}
        {camera.location ? (
          <span className="hidden truncate text-[11px] text-white/55 sm:inline">{camera.location}</span>
        ) : null}
      </div>

      <div
        className={cn(
          "absolute top-2 right-2 flex gap-1 opacity-0 transition-opacity group-hover:opacity-100 group-focus-within:opacity-100 pointer-coarse:opacity-100",
          isFullscreen && "opacity-100",
        )}
      >
        <Tooltip>
          <TooltipTrigger asChild>
            <button
              type="button"
              aria-label={isFullscreen ? "Exit fullscreen" : "Fullscreen"}
              onClick={onFullscreen}
              onDoubleClick={(event) => event.stopPropagation()}
              className={tileButton}
            >
              {isFullscreen ? <MinimizeIcon /> : <MaximizeIcon />}
            </button>
          </TooltipTrigger>
          <TooltipContent>{isFullscreen ? "Exit fullscreen" : "Fullscreen"}</TooltipContent>
        </Tooltip>
        <Tooltip>
          <TooltipTrigger asChild>
            <Link
              href={href}
              aria-label="Open camera"
              onDoubleClick={(event) => event.stopPropagation()}
              className={tileButton}
            >
              <ArrowUpRightIcon />
            </Link>
          </TooltipTrigger>
          <TooltipContent>Open camera</TooltipContent>
        </Tooltip>
      </div>
    </div>
  )
}
