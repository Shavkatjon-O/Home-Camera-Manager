"use client"

import * as React from "react"
import { ArrowLeftRightIcon, CheckIcon, PlusIcon, Trash2Icon, TriangleAlertIcon } from "lucide-react"

import { Warning } from "@/components/analytics/analytics-section"
import { IconButton } from "@/components/shell/icon-button"
import { Chip } from "@/components/shell/primitives"
import { Segmented } from "@/components/shell/segmented"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Switch } from "@/components/ui/switch"
import {
  ALERT_MODES,
  ALERT_MODE_LABELS,
  CLASS_GROUPS,
  CLASS_LABELS,
  DAY_NAMES,
  DIRECTIONS,
  DIRECTION_LABELS,
  NAME_MAX,
  WHOLE_VIEW,
  newWindow,
  type DraftLine,
  type DraftZone,
  type RuleSelection,
} from "@/lib/analytics"
import { labelName } from "@/lib/events"
import type { AlertMode, AlertPolicy, LineDirection, TimeWindow, ViewPoint } from "@/lib/types"
import { cn } from "@/lib/utils"

const SECONDS_MAX = 86400
const COUNT_MAX = 1000

function Note({ children }: { children: React.ReactNode }) {
  return <p className="text-[12px] text-text-3">{children}</p>
}

function ToggleChip({
  pressed,
  onClick,
  children,
}: {
  pressed: boolean
  onClick: () => void
  children: React.ReactNode
}) {
  return (
    <button
      type="button"
      aria-pressed={pressed}
      onClick={onClick}
      className={cn(
        "inline-flex h-6 items-center gap-1 rounded-md bg-chip px-2 font-data text-[11px] whitespace-nowrap text-text-2 transition-colors hover:text-foreground",
        pressed && "bg-surface-3 text-foreground",
      )}
    >
      {pressed ? <CheckIcon aria-hidden className="size-3" /> : null}
      {children}
    </button>
  )
}

function toggle<T>(values: T[], value: T): T[] {
  return values.includes(value) ? values.filter((item) => item !== value) : [...values, value]
}

function LabelChips({
  label,
  hint,
  value,
  onChange,
}: {
  label: string
  hint: string
  value: string[]
  onChange: (value: string[]) => void
}) {
  const known = [...CLASS_GROUPS, ...CLASS_LABELS]
  const extra = value.filter((item) => !known.includes(item))
  return (
    <div className="flex flex-col gap-1.5">
      <span className="text-[12px] text-text-3">{label}</span>
      <div role="group" aria-label={label} className="flex flex-wrap gap-1">
        {[...known, ...extra].map((item) => (
          <ToggleChip key={item} pressed={value.includes(item)} onClick={() => onChange(toggle(value, item))}>
            {labelName(item)}
          </ToggleChip>
        ))}
      </div>
      <Note>{hint}</Note>
    </div>
  )
}

function NumberRow({
  id,
  label,
  unit,
  value,
  min,
  max,
  integer = false,
  hint,
  onChange,
}: {
  id: string
  label: string
  unit: string
  value: number
  min: number
  max: number
  integer?: boolean
  hint?: string
  onChange: (value: number) => void
}) {
  const [draft, setDraft] = React.useState<string | null>(null)
  const text = draft ?? String(value)
  const parsed = Number(text.trim())
  const valid =
    text.trim() !== "" && Number.isFinite(parsed) && parsed >= min && parsed <= max && (!integer || Number.isInteger(parsed))

  const commit = () => {
    if (draft === null) return
    if (valid && parsed !== value) onChange(parsed)
    setDraft(null)
  }

  return (
    <div className="flex flex-col gap-1">
      <div className="flex items-center gap-2 text-[12px] text-text-3">
        <label htmlFor={id} className="min-w-0 flex-1">
          {label}
        </label>
        <Input
          id={id}
          value={text}
          inputMode={integer ? "numeric" : "decimal"}
          autoComplete="off"
          aria-invalid={draft !== null && !valid ? true : undefined}
          onChange={(event) => setDraft(event.target.value)}
          onBlur={commit}
          onKeyDown={(event) => {
            if (event.key === "Enter") commit()
            if (event.key === "Escape") setDraft(null)
          }}
          className="h-8 w-20 font-data"
        />
        <span className="w-14 shrink-0">{unit}</span>
      </div>
      {draft !== null && !valid ? (
        <span className="text-[11px] text-danger">
          {integer ? "A whole number" : "A number"} from {min} to {max}
        </span>
      ) : hint ? (
        <Note>{hint}</Note>
      ) : null}
    </div>
  )
}

function SwitchRow({
  label,
  checked,
  onChange,
}: {
  label: string
  checked: boolean
  onChange: (checked: boolean) => void
}) {
  return (
    <div className="flex items-center justify-between gap-2 text-[12px]">
      <span className="text-text-3">{label}</span>
      <Switch aria-label={label} checked={checked} onCheckedChange={onChange} />
    </div>
  )
}

function WindowsEditor({
  id,
  label,
  hint,
  windows,
  onChange,
}: {
  id: string
  label: string
  hint: string
  windows: TimeWindow[]
  onChange: (windows: TimeWindow[]) => void
}) {
  const change = (index: number, changes: Partial<TimeWindow>) =>
    onChange(windows.map((item, position) => (position === index ? { ...item, ...changes } : item)))
  return (
    <div className="flex flex-col gap-2">
      <div className="flex items-center justify-between gap-2">
        <span className="text-[12px] text-text-3">{label}</span>
        <Button variant="ghost" size="xs" onClick={() => onChange([...windows, newWindow()])}>
          <PlusIcon />
          Add window
        </Button>
      </div>
      {windows.length === 0 ? <Note>{hint}</Note> : null}
      {windows.map((item, index) => (
        <div key={index} className="flex flex-col gap-2 rounded-md border border-hairline p-2">
          <div className="flex items-center gap-1.5">
            <Input
              id={`${id}-${index}-start`}
              type="time"
              aria-label="Start"
              value={item.start}
              aria-invalid={item.start ? undefined : true}
              onChange={(event) => change(index, { start: event.target.value })}
              className="h-8 min-w-0 flex-1 font-data text-[12px]"
            />
            <span className="shrink-0 text-[12px] text-text-3">to</span>
            <Input
              id={`${id}-${index}-end`}
              type="time"
              aria-label="End"
              value={item.end}
              aria-invalid={item.end ? undefined : true}
              onChange={(event) => change(index, { end: event.target.value })}
              className="h-8 min-w-0 flex-1 font-data text-[12px]"
            />
          </div>
          <div role="group" aria-label="Days" className="flex flex-wrap gap-1">
            {DAY_NAMES.map((day, value) => (
              <ToggleChip
                key={day}
                pressed={item.days.includes(value)}
                onClick={() => change(index, { days: toggle(item.days, value).sort((a, b) => a - b) })}
              >
                {day}
              </ToggleChip>
            ))}
          </div>
          <div className="flex items-center justify-between gap-2">
            <Note>
              {item.days.length === 0 ? "Every day" : "On the days picked"}
              {item.start && item.end && item.end <= item.start ? ", running past midnight" : ""}
            </Note>
            <IconButton
              label="Remove window"
              size="icon-sm"
              side="left"
              onClick={() => onChange(windows.filter((_, position) => position !== index))}
            >
              <Trash2Icon />
            </IconButton>
          </div>
        </div>
      ))}
    </div>
  )
}

function AlertEditor({
  id,
  alert,
  onChange,
}: {
  id: string
  alert: AlertPolicy
  onChange: (alert: AlertPolicy) => void
}) {
  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap items-center justify-between gap-2 text-[12px]">
        <span className="text-text-3">Alert</span>
        <Segmented<AlertMode>
          label="Alert"
          value={alert.mode}
          options={ALERT_MODES.map((mode) => ({ value: mode, label: ALERT_MODE_LABELS[mode] }))}
          onChange={(mode) => onChange({ ...alert, mode })}
        />
      </div>
      {alert.mode === "schedule" ? (
        <WindowsEditor
          id={`${id}-alert`}
          label="Alert windows"
          hint="Add the times when this raises alerts in the Schedule arm mode."
          windows={alert.schedule}
          onChange={(schedule) => onChange({ ...alert, schedule })}
        />
      ) : null}
      {alert.mode !== "off" ? (
        <LabelChips
          label="Alert for"
          hint="Any object raises an alert when none is picked."
          value={alert.labels}
          onChange={(labels) => onChange({ ...alert, labels })}
        />
      ) : null}
    </div>
  )
}

function NameField({ id, value, onChange }: { id: string; value: string; onChange: (value: string) => void }) {
  return (
    <div className="flex flex-col gap-1.5">
      <Label htmlFor={id}>Name</Label>
      <Input
        id={id}
        value={value}
        maxLength={NAME_MAX}
        autoComplete="off"
        aria-invalid={value.trim() ? undefined : true}
        onChange={(event) => onChange(event.target.value)}
      />
    </div>
  )
}

function SuspendedNote() {
  return (
    <Warning>
      Suspended: the lens no longer shows the scene this was drawn on. Turn the lens back, or redraw it on this picture and
      save.
    </Warning>
  )
}

function ZoneSettings({
  zone,
  onChange,
  onRemove,
}: {
  zone: DraftZone
  onChange: (changes: Partial<DraftZone>) => void
  onRemove: () => void
}) {
  const id = `zone-${zone.key}`
  return (
    <div className="flex flex-col gap-3 rounded-md border border-hairline p-3">
      {zone.suspended ? <SuspendedNote /> : null}
      <NameField id={`${id}-name`} value={zone.name} onChange={(name) => onChange({ name })} />
      <SwitchRow label="Enabled" checked={zone.enabled} onChange={(enabled) => onChange({ enabled })} />
      <SwitchRow
        label="Whole view"
        checked={zone.whole_view}
        onChange={(checked) =>
          onChange(
            checked
              ? { whole_view: true, polygon: WHOLE_VIEW.map((point): ViewPoint => [point[0], point[1]]) }
              : { whole_view: false },
          )
        }
      />
      <LabelChips
        label="Objects"
        hint="Any object counts when none is picked."
        value={zone.labels}
        onChange={(labels) => onChange({ labels })}
      />
      <NumberRow
        id={`${id}-dwell`}
        label="Minimum dwell"
        unit="seconds"
        value={zone.min_dwell}
        min={0}
        max={SECONDS_MAX}
        hint="Time inside before an intrusion opens."
        onChange={(min_dwell) => onChange({ min_dwell })}
      />
      <NumberRow
        id={`${id}-loiter`}
        label="Loitering after"
        unit="seconds"
        value={zone.loiter_seconds}
        min={0}
        max={SECONDS_MAX}
        hint="0 turns loitering off."
        onChange={(loiter_seconds) => onChange({ loiter_seconds })}
      />
      <NumberRow
        id={`${id}-crowd`}
        label="Crowd from"
        unit="objects"
        value={zone.crowd_count}
        min={0}
        max={COUNT_MAX}
        integer
        hint="0 turns crowd events off."
        onChange={(crowd_count) => onChange({ crowd_count })}
      />
      <WindowsEditor
        id={`${id}-schedule`}
        label="Active"
        hint="Always active when no window is added."
        windows={zone.schedule}
        onChange={(schedule) => onChange({ schedule })}
      />
      <AlertEditor id={id} alert={zone.alert} onChange={(alert) => onChange({ alert })} />
      <Button variant="outline" size="sm" className="self-start" onClick={onRemove}>
        <Trash2Icon />
        Delete zone
      </Button>
    </div>
  )
}

function LineSettings({
  line,
  onChange,
  onRemove,
}: {
  line: DraftLine
  onChange: (changes: Partial<DraftLine>) => void
  onRemove: () => void
}) {
  const id = `line-${line.key}`
  return (
    <div className="flex flex-col gap-3 rounded-md border border-hairline p-3">
      {line.suspended ? <SuspendedNote /> : null}
      <NameField id={`${id}-name`} value={line.name} onChange={(name) => onChange({ name })} />
      <SwitchRow label="Enabled" checked={line.enabled} onChange={(enabled) => onChange({ enabled })} />
      <div className="flex flex-col gap-1.5">
        <div className="flex flex-wrap items-center justify-between gap-2 text-[12px]">
          <span className="text-text-3">Events for crossings</span>
          <Segmented<LineDirection>
            label="Events for crossings"
            value={line.direction}
            options={DIRECTIONS.map((direction) => ({ value: direction, label: DIRECTION_LABELS[direction] }))}
            onChange={(direction) => onChange({ direction })}
          />
        </div>
        <div className="flex flex-wrap items-center justify-between gap-2">
          <Note>The arrow on the picture points to the in side. Every crossing is counted.</Note>
          <Button
            variant="outline"
            size="sm"
            onClick={() => onChange({ points: [line.points[1], line.points[0]] })}
          >
            <ArrowLeftRightIcon />
            Swap direction
          </Button>
        </div>
      </div>
      <LabelChips
        label="Objects"
        hint="Any object counts when none is picked."
        value={line.labels}
        onChange={(labels) => onChange({ labels })}
      />
      <WindowsEditor
        id={`${id}-schedule`}
        label="Active"
        hint="Always active when no window is added."
        windows={line.schedule}
        onChange={(schedule) => onChange({ schedule })}
      />
      <AlertEditor id={id} alert={line.alert} onChange={(alert) => onChange({ alert })} />
      <Button variant="outline" size="sm" className="self-start" onClick={onRemove}>
        <Trash2Icon />
        Delete line
      </Button>
    </div>
  )
}

function ItemRow({
  name,
  enabled,
  suspended,
  selected,
  onSelect,
}: {
  name: string
  enabled: boolean
  suspended: boolean
  selected: boolean
  onSelect: () => void
}) {
  return (
    <button
      type="button"
      aria-expanded={selected}
      onClick={onSelect}
      className={cn(
        "flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-left transition-colors hover:bg-surface-2",
        selected && "bg-surface-3 hover:bg-surface-3",
      )}
    >
      <span className="min-w-0 flex-1 truncate text-[13px] text-foreground">{name.trim() || "Unnamed"}</span>
      {suspended ? (
        <TriangleAlertIcon role="img" aria-label="Suspended" className="size-3.5 shrink-0 text-status-warn" />
      ) : null}
      {enabled ? null : <Chip className="h-5 px-1.5 text-[10px]">Off</Chip>}
    </button>
  )
}

export function RulePanel({
  zones,
  lines,
  selection,
  onSelect,
  onZone,
  onLine,
  onRemove,
}: {
  zones: DraftZone[]
  lines: DraftLine[]
  selection: RuleSelection
  onSelect: (selection: RuleSelection) => void
  onZone: (key: string, changes: Partial<DraftZone>) => void
  onLine: (key: string, changes: Partial<DraftLine>) => void
  onRemove: (selection: NonNullable<RuleSelection>) => void
}) {
  const listRef = React.useRef<HTMLDivElement>(null)
  const selectedKey = selection ? `${selection.kind}-${selection.key}` : null

  React.useEffect(() => {
    if (!selectedKey) return
    const row = listRef.current?.querySelector(`[data-item="${CSS.escape(selectedKey)}"]`)
    row?.scrollIntoView({ block: "nearest" })
  }, [selectedKey])

  const pick = (kind: "zone" | "line", key: string) =>
    onSelect(selection?.kind === kind && selection.key === key ? null : { kind, key })

  return (
    <div ref={listRef} className="flex flex-col">
      <section className="flex flex-col gap-2 border-b border-hairline px-4 py-4">
        <h2 className="text-xs text-text-3">Zones</h2>
        {zones.length === 0 ? <Note>Draw a zone on the picture, or add a whole view zone.</Note> : null}
        {zones.map((zone) => {
          const selected = selection?.kind === "zone" && selection.key === zone.key
          return (
            <div key={zone.key} data-item={`zone-${zone.key}`} className="flex flex-col gap-2">
              <ItemRow
                name={zone.name}
                enabled={zone.enabled}
                suspended={zone.suspended}
                selected={selected}
                onSelect={() => pick("zone", zone.key)}
              />
              {selected ? (
                <ZoneSettings
                  zone={zone}
                  onChange={(changes) => onZone(zone.key, changes)}
                  onRemove={() => onRemove({ kind: "zone", key: zone.key })}
                />
              ) : null}
            </div>
          )
        })}
      </section>
      <section className="flex flex-col gap-2 px-4 py-4">
        <h2 className="text-xs text-text-3">Lines</h2>
        {lines.length === 0 ? <Note>Draw a line where crossings should count, such as a gate or a door.</Note> : null}
        {lines.map((line) => {
          const selected = selection?.kind === "line" && selection.key === line.key
          return (
            <div key={line.key} data-item={`line-${line.key}`} className="flex flex-col gap-2">
              <ItemRow
                name={line.name}
                enabled={line.enabled}
                suspended={line.suspended}
                selected={selected}
                onSelect={() => pick("line", line.key)}
              />
              {selected ? (
                <LineSettings
                  line={line}
                  onChange={(changes) => onLine(line.key, changes)}
                  onRemove={() => onRemove({ kind: "line", key: line.key })}
                />
              ) : null}
            </div>
          )
        })}
      </section>
    </div>
  )
}
