"use client"

import * as React from "react"
import Link from "next/link"
import { ChevronLeftIcon, ChevronRightIcon, CircleAlertIcon, CctvOffIcon, MaximizeIcon, MinimizeIcon } from "lucide-react"
import { toast } from "sonner"

import { AppFrame } from "@/components/shell/app-frame"
import { IconButton } from "@/components/shell/icon-button"
import { Chip, EmptyState, LoadingState } from "@/components/shell/primitives"
import { Segmented } from "@/components/shell/segmented"
import { useSession } from "@/components/shell/session"
import { Button } from "@/components/ui/button"
import { WallTile } from "@/components/wall/wall-tile"
import { WALL_LAYOUTS, wallItems, wallPlan, type WallLayout } from "@/lib/grid"
import { setWallLayout, toggleFullscreen, useFullscreenElement, useWallLayout } from "@/lib/stores"

function useElementSize(element: HTMLElement | null) {
  const [size, setSize] = React.useState({ width: 0, height: 0 })
  React.useEffect(() => {
    if (!element) return
    const observer = new ResizeObserver((entries) => {
      const rect = entries[0]?.contentRect
      if (rect) setSize({ width: rect.width, height: rect.height })
    })
    observer.observe(element)
    return () => observer.disconnect()
  }, [element])
  return size
}

function LayoutPicker({ value, onChange }: { value: WallLayout; onChange: (value: WallLayout) => void }) {
  const index = WALL_LAYOUTS.findIndex((option) => option.value === value)
  const next = WALL_LAYOUTS[(index + 1) % WALL_LAYOUTS.length]
  return (
    <>
      <Segmented
        label="Wall layout"
        value={value}
        options={WALL_LAYOUTS}
        onChange={onChange}
        className="hidden sm:flex"
      />
      <Button
        variant="outline"
        size="sm"
        aria-label={`Wall layout ${WALL_LAYOUTS[index]?.label ?? "Auto"}, switch to ${next.label}`}
        onClick={() => onChange(next.value)}
        className="min-w-11 sm:hidden"
      >
        {WALL_LAYOUTS[index]?.label ?? "Auto"}
      </Button>
    </>
  )
}

export function WallView() {
  const { cameras, loaded, error, refresh } = useSession()
  const layout = useWallLayout()
  const [requestedPage, setRequestedPage] = React.useState(0)
  const [wall, setWall] = React.useState<HTMLElement | null>(null)
  const size = useElementSize(wall)
  const fullscreen = useFullscreenElement()

  const enabled = React.useMemo(() => cameras.filter((camera) => camera.enabled), [cameras])
  const items = React.useMemo(() => wallItems(enabled), [enabled])
  const portrait = size.height > size.width * 1.15
  const grid = React.useMemo(() => wallPlan(layout, items, portrait), [layout, items, portrait])
  const pageCount = Math.max(1, Math.ceil(grid.slots.length / grid.perPage))
  const page = Math.min(requestedPage, pageCount - 1)
  const visible = grid.slots.slice(page * grid.perPage, (page + 1) * grid.perPage)
  const slots = grid.cols * grid.rows

  const changeLayout = (value: WallLayout) => {
    setWallLayout(value)
    setRequestedPage(0)
  }

  const step = React.useCallback(
    (delta: number) => setRequestedPage((current) => (Math.min(current, pageCount - 1) + delta + pageCount) % pageCount),
    [pageCount],
  )

  React.useEffect(() => {
    if (pageCount < 2) return
    const onKey = (event: KeyboardEvent) => {
      const target = event.target as HTMLElement | null
      if (target && (target.isContentEditable || ["INPUT", "TEXTAREA", "SELECT"].includes(target.tagName))) return
      if (event.key === "PageDown" || event.key === "]") step(1)
      if (event.key === "PageUp" || event.key === "[") step(-1)
    }
    window.addEventListener("keydown", onKey)
    return () => window.removeEventListener("keydown", onKey)
  }, [pageCount, step])

  const onFullscreen = async () => {
    const ok = await toggleFullscreen(wall)
    if (!ok) toast.error("Fullscreen is not available in this browser")
  }

  const actions = (
    <>
      {pageCount > 1 ? (
        <div className="flex items-center gap-1">
          <IconButton label="Previous page" size="icon-sm" onClick={() => step(-1)}>
            <ChevronLeftIcon />
          </IconButton>
          <Chip className="hidden sm:inline-flex">
            {page + 1} of {pageCount}
          </Chip>
          <IconButton label="Next page" size="icon-sm" onClick={() => step(1)}>
            <ChevronRightIcon />
          </IconButton>
        </div>
      ) : null}
      <LayoutPicker value={layout} onChange={changeLayout} />
      <IconButton
        label={fullscreen ? "Exit fullscreen" : "Fullscreen"}
        disabled={enabled.length === 0}
        onClick={onFullscreen}
      >
        {fullscreen ? <MinimizeIcon /> : <MaximizeIcon />}
      </IconButton>
    </>
  )

  let content: React.ReactNode
  if (!loaded) {
    content = <LoadingState label="Loading cameras" />
  } else if (error && cameras.length === 0) {
    content = (
      <EmptyState icon={<CircleAlertIcon />} title="Cannot load cameras">
        <span className="font-data text-xs">{error}</span>
        <Button variant="outline" onClick={() => void refresh()}>
          Try again
        </Button>
      </EmptyState>
    )
  } else if (enabled.length === 0) {
    content = (
      <EmptyState
        icon={<CctvOffIcon />}
        title={cameras.length === 0 ? "No cameras yet" : "Every camera is disabled"}
      >
        <span>
          {cameras.length === 0
            ? "Register a camera to see it on the wall."
            : "Enable a camera to see it on the wall."}
        </span>
        <Button asChild variant="outline">
          <Link href="/cameras/">Go to cameras</Link>
        </Button>
      </EmptyState>
    )
  } else {
    content = (
      <div
        className="grid size-full gap-px bg-hairline"
        style={{
          gridTemplateColumns: `repeat(${grid.cols}, minmax(0, 1fr))`,
          gridTemplateRows: `repeat(${grid.rows}, minmax(0, 1fr))`,
          gridAutoFlow: grid.flow,
        }}
      >
        {visible.map((slot, index) =>
          slot ? (
            <WallTile key={slot.key} camera={slot.camera} lens={slot.lens} />
          ) : (
            <div key={`gap-${page}-${index}`} aria-hidden className="bg-black" />
          ),
        )}
        {Array.from({ length: Math.max(0, slots - visible.length) }, (_, index) => (
          <div key={`empty-${index}`} aria-hidden className="bg-black" />
        ))}
      </div>
    )
  }

  return (
    <AppFrame actions={actions}>
      <main ref={setWall} className="relative min-h-0 min-w-0 flex-1 overflow-hidden bg-background">
        {content}
      </main>
    </AppFrame>
  )
}
