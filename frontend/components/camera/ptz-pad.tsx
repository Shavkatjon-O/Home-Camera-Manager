"use client"

import * as React from "react"
import {
  ArrowDownIcon,
  ArrowDownLeftIcon,
  ArrowDownRightIcon,
  ArrowLeftIcon,
  ArrowRightIcon,
  ArrowUpIcon,
  ArrowUpLeftIcon,
  ArrowUpRightIcon,
  SquareIcon,
  ZoomInIcon,
  ZoomOutIcon,
} from "lucide-react"

import { Slider } from "@/components/ui/slider"
import type { PtzVector } from "@/lib/types"
import { cn } from "@/lib/utils"

export interface PtzControls {
  start: (direction: PtzVector) => void
  stop: () => void
  halt: () => void
}

const PAD: { label: string; direction: PtzVector; icon: React.ComponentType<{ className?: string }> }[] = [
  { label: "Up and left", direction: { pan: -1, tilt: 1, zoom: 0 }, icon: ArrowUpLeftIcon },
  { label: "Up", direction: { pan: 0, tilt: 1, zoom: 0 }, icon: ArrowUpIcon },
  { label: "Up and right", direction: { pan: 1, tilt: 1, zoom: 0 }, icon: ArrowUpRightIcon },
  { label: "Left", direction: { pan: -1, tilt: 0, zoom: 0 }, icon: ArrowLeftIcon },
  { label: "Right", direction: { pan: 1, tilt: 0, zoom: 0 }, icon: ArrowRightIcon },
  { label: "Down and left", direction: { pan: -1, tilt: -1, zoom: 0 }, icon: ArrowDownLeftIcon },
  { label: "Down", direction: { pan: 0, tilt: -1, zoom: 0 }, icon: ArrowDownIcon },
  { label: "Down and right", direction: { pan: 1, tilt: -1, zoom: 0 }, icon: ArrowDownRightIcon },
]

const ZOOM: { label: string; direction: PtzVector; icon: React.ComponentType<{ className?: string }> }[] = [
  { label: "Zoom out", direction: { pan: 0, tilt: 0, zoom: -1 }, icon: ZoomOutIcon },
  { label: "Zoom in", direction: { pan: 0, tilt: 0, zoom: 1 }, icon: ZoomInIcon },
]

const padButton =
  "inline-flex items-center justify-center rounded-md border border-input bg-transparent text-text-2 transition-colors select-none touch-none hover:border-hairline-strong hover:bg-surface-2 hover:text-foreground active:bg-surface-3 active:text-foreground data-[held=true]:bg-surface-3 data-[held=true]:text-foreground [&_svg]:size-4"

function HoldButton({
  label,
  direction,
  controls,
  className,
  children,
}: {
  label: string
  direction: PtzVector
  controls: PtzControls
  className?: string
  children: React.ReactNode
}) {
  const [held, setHeld] = React.useState(false)
  const press = () => {
    setHeld(true)
    controls.start(direction)
  }
  const release = () => {
    if (!held) return
    setHeld(false)
    controls.stop()
  }
  return (
    <button
      type="button"
      aria-label={label}
      title={label}
      data-held={held}
      onPointerDown={(event) => {
        if (event.pointerType === "mouse" && event.button !== 0) return
        event.preventDefault()
        press()
      }}
      onPointerUp={release}
      onPointerLeave={release}
      onPointerCancel={release}
      onKeyDown={(event) => {
        if (event.key !== "Enter" && event.key !== " ") return
        event.preventDefault()
        event.stopPropagation()
        if (!event.repeat) press()
      }}
      onKeyUp={(event) => {
        if (event.key !== "Enter" && event.key !== " ") return
        event.stopPropagation()
        release()
      }}
      onBlur={release}
      onContextMenu={(event) => event.preventDefault()}
      className={cn(padButton, className)}
    >
      {children}
    </button>
  )
}

export function PtzPad({
  controls,
  speed,
  onSpeedChange,
}: {
  controls: PtzControls
  speed: number
  onSpeedChange: (value: number) => void
}) {
  const cells = [...PAD.slice(0, 4), null, ...PAD.slice(4)]
  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-start gap-4">
        <div className="grid grid-cols-3 gap-1.5">
          {cells.map((cell) =>
            cell ? (
              <HoldButton
                key={cell.label}
                label={cell.label}
                direction={cell.direction}
                controls={controls}
                className="size-11"
              >
                <cell.icon />
              </HoldButton>
            ) : (
              <button
                key="stop"
                type="button"
                aria-label="Stop"
                title="Stop"
                onClick={controls.halt}
                className={cn(padButton, "size-11")}
              >
                <SquareIcon className="size-3.5" />
              </button>
            ),
          )}
        </div>
        <div className="flex flex-col gap-1.5">
          {[...ZOOM].reverse().map((cell) => (
            <HoldButton
              key={cell.label}
              label={cell.label}
              direction={cell.direction}
              controls={controls}
              className="size-11"
            >
              <cell.icon />
            </HoldButton>
          ))}
        </div>
      </div>
      <div className="flex flex-col gap-2">
        <div className="flex items-center justify-between text-xs">
          <span className="text-text-3">Speed</span>
          <span className="font-data text-text-2">{speed.toFixed(1)}</span>
        </div>
        <Slider
          aria-label="Speed"
          min={0.1}
          max={1}
          step={0.1}
          value={[speed]}
          onValueChange={(value) => onSpeedChange(Math.round((value[0] ?? 0.5) * 10) / 10)}
        />
      </div>
      <p className="text-[12px] text-text-3">
        Hold a direction to move. Arrow keys and plus or minus work while the view has focus.
      </p>
    </div>
  )
}
