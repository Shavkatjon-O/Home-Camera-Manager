"use client"

import { XIcon } from "lucide-react"

import { ColorDot } from "@/components/people/face-parts"
import { MultiSelect, type MultiOption } from "@/components/search/multi-select"
import { hasFilters, type DateMode, type SearchFilters } from "@/components/search/search-params"
import { ToolbarRow } from "@/components/shell/page-frame"
import { Segmented } from "@/components/shell/segmented"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Switch } from "@/components/ui/switch"
import { humanize, kindLabel, type Facets } from "@/lib/people"
import type { Camera } from "@/lib/types"

const ANYONE = "anyone"

const DATE_OPTIONS: { value: DateMode; label: string }[] = [
  { value: "day", label: "Day" },
  { value: "range", label: "Range" },
]

function subjectValue(filters: SearchFilters): string {
  if (filters.person) return `person:${filters.person}`
  if (filters.cluster) return `cluster:${filters.cluster}`
  return ANYONE
}

function withSelected(options: MultiOption[], all: MultiOption[], selected: string[]): MultiOption[] {
  const extra = all.filter(
    (option) => selected.includes(option.value) && !options.some((item) => item.value === option.value),
  )
  return [...options, ...extra]
}

function changeDates(filters: SearchFilters, dates: DateMode): Partial<SearchFilters> {
  if (dates === filters.dates) return {}
  if (dates === "range") {
    return filters.day
      ? { dates, day: "", from: `${filters.day}T00:00`, to: `${filters.day}T23:59` }
      : { dates, day: "" }
  }
  const day = /^\d{4}-\d{2}-\d{2}/.exec(filters.from)?.[0] ?? ""
  return { dates, day, from: "", to: "" }
}

/** The Search page's filters, shown in its page header. */
export function SearchFiltersBar({
  filters,
  facets,
  cameras,
  onChange,
  onClear,
}: {
  filters: SearchFilters
  facets: Facets | null
  cameras: Camera[]
  onChange: (change: Partial<SearchFilters>) => void
  onClear: () => void
}) {
  const cameraOptions: MultiOption[] = cameras.map((camera) => ({ value: camera.uuid, label: camera.name }))
  const cameraNames = new Map(cameras.map((camera) => [camera.uuid, camera.name]))

  const allViews: MultiOption[] = (facets?.views ?? []).map((view) => ({
    value: view.id,
    label: view.name,
    detail: cameraNames.get(view.camera_uuid) === view.name ? null : (cameraNames.get(view.camera_uuid) ?? null),
  }))
  const viewOptions = withSelected(
    filters.camera.length === 0
      ? allViews
      : allViews.filter((option) =>
          filters.camera.includes(facets?.views.find((view) => view.id === option.value)?.camera_uuid ?? ""),
        ),
    allViews,
    filters.view,
  )

  const viewNames = new Map((facets?.views ?? []).map((view) => [view.id, view.name]))
  const shownViews = new Set(viewOptions.map((option) => option.value))
  const inScope = (view: string) => (filters.view.length > 0 ? filters.view.includes(view) : shownViews.has(view))

  const allZones: MultiOption[] = (facets?.zones ?? []).map((zone) => ({
    value: zone.id,
    label: zone.name,
    detail: viewNames.get(zone.view) ?? null,
  }))
  const zoneOptions = withSelected(
    allZones.filter((option) => inScope(facets?.zones.find((zone) => zone.id === option.value)?.view ?? "")),
    allZones,
    filters.zone,
  )

  const allLines: MultiOption[] = (facets?.lines ?? []).map((line) => ({
    value: line.id,
    label: line.name,
    detail: viewNames.get(line.view) ?? null,
  }))
  const lineOptions = withSelected(
    allLines.filter((option) => inScope(facets?.lines.find((line) => line.id === option.value)?.view ?? "")),
    allLines,
    filters.line,
  )

  const kindOptions: MultiOption[] = (facets?.kinds ?? []).map((kind) => ({ value: kind, label: kindLabel(kind) }))
  const labelOptions: MultiOption[] = (facets?.labels ?? []).map((label) => ({ value: label, label: humanize(label) }))

  const people = facets?.people ?? []
  const clusters = facets?.clusters ?? []
  const subject = subjectValue(filters)
  const showSubject = people.length > 0 || clusters.length > 0 || subject !== ANYONE
  const personMissing = Boolean(filters.person && !people.some((person) => person.uuid === filters.person))
  const clusterMissing = Boolean(
    !filters.person && filters.cluster && !clusters.some((cluster) => cluster.uuid === filters.cluster),
  )

  const changeSubject = (value: string) => {
    if (value.startsWith("person:")) onChange({ person: value.slice(7), cluster: null })
    else if (value.startsWith("cluster:")) onChange({ person: null, cluster: value.slice(8) })
    else onChange({ person: null, cluster: null })
  }

  return (
    <ToolbarRow>
      <Segmented<DateMode>
        label="Dates"
        value={filters.dates}
        options={DATE_OPTIONS}
        onChange={(value) => onChange(changeDates(filters, value))}
      />
      {filters.dates === "day" ? (
        <Input
          type="date"
          aria-label="Day"
          value={filters.day}
          onChange={(event) => onChange({ day: event.target.value })}
          className="h-8 w-40 font-data text-[12px]"
        />
      ) : (
        <>
          <Input
            type="datetime-local"
            aria-label="From"
            title="From"
            value={filters.from}
            max={filters.to || undefined}
            onChange={(event) => onChange({ from: event.target.value })}
            className="h-8 w-52 font-data text-[12px]"
          />
          <Input
            type="datetime-local"
            aria-label="To"
            title="To"
            value={filters.to}
            min={filters.from || undefined}
            onChange={(event) => onChange({ to: event.target.value })}
            className="h-8 w-52 font-data text-[12px]"
          />
        </>
      )}
      {cameraOptions.length > 0 ? (
        <MultiSelect
          label="Cameras"
          allLabel="All cameras"
          noun={{ one: "camera", many: "cameras" }}
          options={cameraOptions}
          value={filters.camera}
          onChange={(camera) => onChange({ camera })}
          className="w-40"
        />
      ) : null}
      {allViews.length > 0 ? (
        <MultiSelect
          label="Views"
          allLabel="All views"
          noun={{ one: "view", many: "views" }}
          options={viewOptions}
          value={filters.view}
          onChange={(view) => onChange({ view })}
          className="w-40"
        />
      ) : null}
      {kindOptions.length > 0 ? (
        <MultiSelect
          label="Kinds"
          allLabel="All kinds"
          noun={{ one: "kind", many: "kinds" }}
          options={kindOptions}
          value={filters.kind}
          onChange={(kind) => onChange({ kind })}
          className="w-36"
        />
      ) : null}
      {labelOptions.length > 0 ? (
        <MultiSelect
          label="Labels"
          allLabel="All labels"
          noun={{ one: "label", many: "labels" }}
          options={labelOptions}
          value={filters.label}
          onChange={(label) => onChange({ label })}
          className="w-36"
        />
      ) : null}
      {allZones.length > 0 ? (
        <MultiSelect
          label="Zones"
          allLabel="All zones"
          noun={{ one: "zone", many: "zones" }}
          options={zoneOptions}
          value={filters.zone}
          onChange={(zone) => onChange({ zone })}
          className="w-36"
        />
      ) : null}
      {allLines.length > 0 ? (
        <MultiSelect
          label="Lines"
          allLabel="All lines"
          noun={{ one: "line", many: "lines" }}
          options={lineOptions}
          value={filters.line}
          onChange={(line) => onChange({ line })}
          className="w-36"
        />
      ) : null}
      {showSubject ? (
        <Select value={subject} onValueChange={changeSubject}>
          <SelectTrigger aria-label="Person or unknown face" className="w-44">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value={ANYONE}>Anyone</SelectItem>
            {personMissing ? <SelectItem value={subject}>Selected person</SelectItem> : null}
            {clusterMissing ? <SelectItem value={subject}>Selected unknown face</SelectItem> : null}
            {people.map((person) => (
              <SelectItem key={person.uuid} value={`person:${person.uuid}`}>
                <span className="flex min-w-0 items-center gap-2">
                  <ColorDot color={person.color} />
                  <span className="truncate">{person.name}</span>
                </span>
              </SelectItem>
            ))}
            {clusters.map((cluster) => (
              <SelectItem key={cluster.uuid} value={`cluster:${cluster.uuid}`}>
                <span className="flex min-w-0 items-center gap-2">
                  <ColorDot color={null} />
                  <span className="truncate">{cluster.label}</span>
                </span>
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      ) : null}
      <div className="flex h-8 items-center gap-2 px-1">
        <Switch id="search-alert" checked={filters.alert} onCheckedChange={(alert) => onChange({ alert })} />
        <Label htmlFor="search-alert">Alerts only</Label>
      </div>
      {hasFilters(filters) ? (
        <Button variant="ghost" size="sm" onClick={onClear}>
          <XIcon />
          Clear
        </Button>
      ) : null}
    </ToolbarRow>
  )
}
