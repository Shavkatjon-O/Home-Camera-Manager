"use client"

import * as React from "react"

import { clamp01, labelColor } from "@/lib/analytics"
import type { Box } from "@/lib/types"
import { cn } from "@/lib/utils"

export interface DrawnBox {
  key: string
  box: Box
  label: string
  caption: string
}

const LABEL_FILL = "#ffffff"
const LABEL_HALO = "rgba(0, 0, 0, 0.8)"
const TOP_ROOM = 0.08

function percent(value: number): string {
  return `${(value * 100).toFixed(3)}%`
}

export function FitBox({ aspect, children }: { aspect: number; children: React.ReactNode }) {
  return (
    <div className="pointer-events-none absolute inset-0 flex items-center justify-center" style={{ containerType: "size" }}>
      <div
        className="relative"
        style={{
          width: `min(100cqw, calc(100cqh * ${aspect}))`,
          height: `min(100cqh, calc(100cqw / ${aspect}))`,
        }}
      >
        {children}
      </div>
    </div>
  )
}

export function BoxLayer({ boxes, className }: { boxes: DrawnBox[]; className?: string }) {
  return (
    <svg aria-hidden className={cn("pointer-events-none absolute inset-0 size-full", className)}>
      {boxes.map((item) => {
        const left = clamp01(Math.min(item.box[0], item.box[2]))
        const right = clamp01(Math.max(item.box[0], item.box[2]))
        const top = clamp01(Math.min(item.box[1], item.box[3]))
        const bottom = clamp01(Math.max(item.box[1], item.box[3]))
        const color = labelColor(item.label)
        const inside = top < TOP_ROOM
        return (
          <g key={item.key}>
            <rect
              x={percent(left)}
              y={percent(top)}
              width={percent(right - left)}
              height={percent(bottom - top)}
              fill="none"
              stroke={color}
              strokeWidth={2}
            />
            <text
              x={percent(left)}
              y={percent(top)}
              dx={3}
              dy={inside ? 13 : -4}
              fontSize={11}
              className="font-data"
              fill={LABEL_FILL}
              stroke={LABEL_HALO}
              strokeWidth={3}
              paintOrder="stroke"
              strokeLinejoin="round"
            >
              {item.caption}
            </text>
          </g>
        )
      })}
    </svg>
  )
}
