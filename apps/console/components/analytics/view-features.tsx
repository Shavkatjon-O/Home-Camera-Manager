import * as React from "react"

import { Chip } from "@/components/shell/primitives"
import { Switch } from "@/components/ui/switch"

export interface ViewFeatureValue {
  appearance: boolean
  falls: boolean
  plates: boolean
  follow: boolean
}

interface FeatureRow {
  key: keyof ViewFeatureValue
  label: string
  beta: boolean
  hint: string
}

const ROWS: FeatureRow[] = [
  {
    key: "appearance",
    label: "Re-identification",
    beta: false,
    hint: "Links this view's people to other cameras by their appearance.",
  },
  {
    key: "falls",
    label: "Falls",
    beta: true,
    hint: "Alerts when someone falls and lies still. Meant for indoor views.",
  },
  {
    key: "plates",
    label: "Number plates",
    beta: true,
    hint: "Reads the plates of vehicle events by day. At night the infrared light makes plates unreadable.",
  },
  {
    key: "follow",
    label: "Auto-follow",
    beta: false,
    hint: "Turns the camera to keep a person in view and returns it to where it was after 30 seconds without anyone. Off by default: the camera moves by itself only while this is on.",
  },
]

export function ViewFeatures({
  value,
  moving,
  disabled = false,
  onChange,
}: {
  value: ViewFeatureValue
  moving: boolean
  disabled?: boolean
  onChange: (patch: Partial<ViewFeatureValue>) => void
}) {
  const id = React.useId()
  return (
    <div className="flex flex-col gap-3">
      {ROWS.filter((row) => row.key !== "follow" || moving).map((row) => (
        <div key={row.key} className="flex flex-col gap-1">
          <div className="flex items-center justify-between gap-2 text-[12px]">
            <span className="flex items-center gap-2">
              <label htmlFor={`${id}-${row.key}`} className="text-text-3">
                {row.label}
              </label>
              {row.beta ? <Chip className="h-5 px-1.5 text-[10px]">Beta</Chip> : null}
            </span>
            <Switch
              id={`${id}-${row.key}`}
              checked={value[row.key]}
              disabled={disabled}
              onCheckedChange={(checked) => onChange({ [row.key]: checked })}
            />
          </div>
          <p className="text-[12px] text-text-3">{row.hint}</p>
        </div>
      ))}
    </div>
  )
}
