"use client"

import * as React from "react"
import { ImageOffIcon, Trash2Icon, UploadIcon } from "lucide-react"
import { toast } from "sonner"

import { FieldRow, NumberField, ReadOut, Section, TextField } from "@/components/coverage/fields"
import { Spinner } from "@/components/shell/primitives"
import { Segmented } from "@/components/shell/segmented"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Slider } from "@/components/ui/slider"
import { Switch } from "@/components/ui/switch"
import {
  BAND_LABELS,
  MATERIALS,
  MATERIAL_LABELS,
  PRESETS,
  PRESET_ORDER,
  QUALITY_LABELS,
  QUALITY_ORDER,
  WALL_LOSS_DB,
  WALL_STYLES,
  formatDbm,
  formatMeters,
  formatPercent,
  qualityColor,
  qualityOf,
  qualityRange,
  wallLength,
  type CoverageStats,
  type PlacementResult,
} from "@/lib/coverage"
import {
  PLAN_SIZE_MAX_M,
  PLAN_SIZE_MIN_M,
  SNAP_OPTIONS,
  fitsPlan,
  presetFields,
  sizeForImage,
  type PlanDoc,
} from "@/lib/plan-edit"
import type { AccessPoint, AccessPointPreset, Band, Device, Wall, WallMaterial } from "@/lib/types"

type Update = (doc: PlanDoc) => PlanDoc

const IMAGE_MAX_PX = 2000
const IMAGE_QUALITY = 0.8
const IMAGE_MAX_CHARS = 4_000_000

const ITEM_NAME_MAX = 60
const PLAN_NAME_MAX = 100

export interface Suggestion {
  status: "running" | "done"
  progress: number
  band: Band
  result: PlacementResult | null
  ms: number
}

async function loadImage(file: File): Promise<{ dataUrl: string; aspect: number }> {
  const url = URL.createObjectURL(file)
  try {
    const image = new Image()
    image.src = url
    await image.decode()
    const ratio = Math.min(1, IMAGE_MAX_PX / Math.max(image.naturalWidth, image.naturalHeight))
    const width = Math.max(1, Math.round(image.naturalWidth * ratio))
    const height = Math.max(1, Math.round(image.naturalHeight * ratio))
    const canvas = document.createElement("canvas")
    canvas.width = width
    canvas.height = height
    const context = canvas.getContext("2d")
    if (!context) throw new Error("This browser cannot read images")
    context.fillStyle = "#ffffff"
    context.fillRect(0, 0, width, height)
    context.drawImage(image, 0, 0, width, height)
    let quality = IMAGE_QUALITY
    let dataUrl = canvas.toDataURL("image/jpeg", quality)
    while (dataUrl.length > IMAGE_MAX_CHARS && quality > 0.35) {
      quality -= 0.15
      dataUrl = canvas.toDataURL("image/jpeg", quality)
    }
    if (dataUrl.length > IMAGE_MAX_CHARS) throw new Error("The image is too large even after compression")
    return { dataUrl, aspect: height / width }
  } finally {
    URL.revokeObjectURL(url)
  }
}

function replaceItem<T extends { id: string }>(items: T[], id: string, change: Partial<T>): T[] {
  return items.map((item) => (item.id === id ? { ...item, ...change } : item))
}

function Swatch({ color, hollow }: { color: string; hollow?: boolean }) {
  return (
    <span
      aria-hidden
      className="inline-block size-3 shrink-0 rounded-[3px] border border-hairline-strong"
      style={hollow ? undefined : { background: color, borderColor: color }}
    />
  )
}

function DeleteButton({ label, onClick }: { label: string; onClick: () => void }) {
  return (
    <Button variant="outline" size="sm" onClick={onClick} className="self-start">
      <Trash2Icon />
      {label}
    </Button>
  )
}

function PlanSection({
  doc,
  material,
  onCommit,
  onMaterialChange,
}: {
  doc: PlanDoc
  material: WallMaterial
  onCommit: (update: Update, merge?: string) => void
  onMaterialChange: (material: WallMaterial) => void
}) {
  const fileRef = React.useRef<HTMLInputElement>(null)
  const [loading, setLoading] = React.useState(false)
  const settings = doc.settings

  const upload = async (file: File) => {
    setLoading(true)
    try {
      const { dataUrl, aspect } = await loadImage(file)
      const size = sizeForImage(doc, aspect)
      onCommit((value) => ({ ...value, background_image: dataUrl, ...size }))
      toast.success(`Height set to ${size.height_m} m from the image shape`)
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Cannot read this image")
    } finally {
      setLoading(false)
    }
  }

  return (
    <Section title="Plan">
      <TextField
        id="plan-name"
        label="Name"
        value={doc.name}
        maxLength={PLAN_NAME_MAX}
        onCommit={(name) => onCommit((value) => ({ ...value, name }))}
      />
      <FieldRow>
        <NumberField
          id="plan-width"
          label="Width"
          unit="m"
          value={doc.width_m}
          min={PLAN_SIZE_MIN_M}
          max={PLAN_SIZE_MAX_M}
          validate={(width) => (fitsPlan(doc, width, doc.height_m) ? null : "Items lie beyond this")}
          onCommit={(width_m) => onCommit((value) => ({ ...value, width_m }))}
        />
        <NumberField
          id="plan-height"
          label="Height"
          unit="m"
          value={doc.height_m}
          min={PLAN_SIZE_MIN_M}
          max={PLAN_SIZE_MAX_M}
          validate={(height) => (fitsPlan(doc, doc.width_m, height) ? null : "Items lie beyond this")}
          onCommit={(height_m) => onCommit((value) => ({ ...value, height_m }))}
        />
      </FieldRow>
      <div className="flex flex-col gap-2">
        <Label>Background image</Label>
        <input
          ref={fileRef}
          type="file"
          accept="image/*"
          className="hidden"
          aria-label="Background image file"
          onChange={(event) => {
            const file = event.target.files?.[0]
            event.target.value = ""
            if (file) void upload(file)
          }}
        />
        <div className="flex flex-wrap items-center gap-2">
          <Button variant="outline" size="sm" disabled={loading} onClick={() => fileRef.current?.click()}>
            {loading ? <Spinner className="size-3.5" /> : <UploadIcon />}
            {doc.background_image ? "Replace image" : "Upload image"}
          </Button>
          {doc.background_image ? (
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onCommit((value) => ({ ...value, background_image: null }))}
            >
              <ImageOffIcon />
              Remove image
            </Button>
          ) : null}
        </div>
        <span className="text-[11px] text-text-3">
          A photo of a sketch works. The height follows the image shape, so only the width needs a guess.
        </span>
        {doc.background_image ? (
          <div className="flex flex-col gap-2 pt-1">
            <div className="flex items-center justify-between">
              <span className="text-xs text-text-2">Opacity</span>
              <span className="font-data text-[11px] text-text-3">{formatPercent(doc.background_opacity)}</span>
            </div>
            <Slider
              aria-label="Background opacity"
              min={0}
              max={1}
              step={0.05}
              value={[doc.background_opacity]}
              onValueChange={([background_opacity]) =>
                onCommit((value) => ({ ...value, background_opacity }), "opacity")
              }
            />
          </div>
        ) : null}
      </div>
      <FieldRow>
        <NumberField
          id="plan-exponent"
          label="Path loss exponent"
          value={settings.path_loss_exponent}
          min={1.6}
          max={4}
          onCommit={(path_loss_exponent) =>
            onCommit((value) => ({ ...value, settings: { ...value.settings, path_loss_exponent } }))
          }
        />
        <NumberField
          id="plan-target"
          label="Target"
          unit="dBm"
          value={settings.target_dbm}
          min={-90}
          max={-40}
          onCommit={(target_dbm) => onCommit((value) => ({ ...value, settings: { ...value.settings, target_dbm } }))}
        />
      </FieldRow>
      <span className="-mt-1 text-[11px] text-text-3">
        Exponent 2 is open space; 2.5 to 3.5 fits a furnished home.
      </span>
      <FieldRow>
        <div className="flex min-w-0 flex-col gap-1.5">
          <Label htmlFor="plan-snap">Snap</Label>
          <Select
            value={String(settings.snap_m)}
            onValueChange={(text) =>
              onCommit((value) => ({ ...value, settings: { ...value.settings, snap_m: Number(text) } }))
            }
          >
            <SelectTrigger id="plan-snap" className="font-data">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {SNAP_OPTIONS.map((option) => (
                <SelectItem key={option} value={String(option)} className="font-data">
                  {option < 1 ? `${Math.round(option * 100)} cm` : `${option} m`}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </FieldRow>
      <MaterialSelect id="plan-material" label="New walls" value={material} onChange={onMaterialChange} />
    </Section>
  )
}

function MaterialSelect({
  id,
  label,
  value,
  onChange,
}: {
  id: string
  label: string
  value: WallMaterial
  onChange: (material: WallMaterial) => void
}) {
  return (
    <div className="flex min-w-0 flex-col gap-1.5">
      <Label htmlFor={id}>{label}</Label>
      <Select value={value} onValueChange={(next) => onChange(next as WallMaterial)}>
        <SelectTrigger id={id}>
          <SelectValue />
        </SelectTrigger>
        <SelectContent>
          {MATERIALS.map((material) => (
            <SelectItem key={material} value={material}>
              {MATERIAL_LABELS[material]}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </div>
  )
}

function WallSection({
  wall,
  onCommit,
  onMaterialChange,
  onDelete,
}: {
  wall: Wall
  onCommit: (update: Update) => void
  onMaterialChange: (material: WallMaterial) => void
  onDelete: () => void
}) {
  const loss = WALL_LOSS_DB[wall.material]
  return (
    <Section title="Wall">
      <MaterialSelect
        id="wall-material"
        label="Material"
        value={wall.material}
        onChange={(material) => {
          onMaterialChange(material)
          onCommit((value) => ({ ...value, walls: replaceItem(value.walls, wall.id, { material }) }))
        }}
      />
      <div className="flex flex-col gap-1.5">
        <ReadOut label="Length" value={formatMeters(wallLength(wall))} />
        <ReadOut label="Loss" value={`${loss["2.4"]} dB at 2.4 GHz, ${loss["5"]} dB at 5 GHz`} />
        <ReadOut label="From" value={`${wall.x1.toFixed(2)}, ${wall.y1.toFixed(2)} m`} />
        <ReadOut label="To" value={`${wall.x2.toFixed(2)}, ${wall.y2.toFixed(2)} m`} />
      </div>
      <DeleteButton label="Delete wall" onClick={onDelete} />
    </Section>
  )
}

function RouterSection({
  accessPoint,
  index,
  band,
  stats,
  onCommit,
  onDelete,
}: {
  accessPoint: AccessPoint
  index: number
  band: Band
  stats: CoverageStats | null
  onCommit: (update: Update) => void
  onDelete: () => void
}) {
  const change = (fields: Partial<AccessPoint>) =>
    onCommit((value) => ({ ...value, access_points: replaceItem(value.access_points, accessPoint.id, fields) }))
  const served = stats?.servedBy[index]
  return (
    <Section title="Router">
      <TextField
        id="router-name"
        label="Name"
        value={accessPoint.name}
        maxLength={ITEM_NAME_MAX}
        onCommit={(name) => change({ name })}
      />
      <div className="flex min-w-0 flex-col gap-1.5">
        <Label htmlFor="router-preset">Model</Label>
        <Select
          value={accessPoint.preset}
          onValueChange={(preset) => change(presetFields(preset as AccessPointPreset))}
        >
          <SelectTrigger id="router-preset">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            {PRESET_ORDER.map((preset) => (
              <SelectItem key={preset} value={preset}>
                {PRESETS[preset].label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>
      <FieldRow>
        <div className="flex flex-col gap-3">
          <Label className="justify-between">
            2.4 GHz
            <Switch checked={accessPoint.band_24} onCheckedChange={(band_24) => change({ band_24 })} />
          </Label>
          <NumberField
            id="router-power-24"
            label="Power"
            unit="dBm"
            value={accessPoint.power_24_dbm}
            min={0}
            max={30}
            disabled={!accessPoint.band_24}
            onCommit={(power_24_dbm) => change({ power_24_dbm })}
          />
        </div>
        <div className="flex flex-col gap-3">
          <Label className="justify-between">
            5 GHz
            <Switch checked={accessPoint.band_5} onCheckedChange={(band_5) => change({ band_5 })} />
          </Label>
          <NumberField
            id="router-power-5"
            label="Power"
            unit="dBm"
            value={accessPoint.power_5_dbm}
            min={0}
            max={30}
            disabled={!accessPoint.band_5}
            onCommit={(power_5_dbm) => change({ power_5_dbm })}
          />
        </div>
      </FieldRow>
      <Label className="justify-between">
        Locked for suggestions
        <Switch checked={accessPoint.locked} onCheckedChange={(locked) => change({ locked })} />
      </Label>
      <div className="flex flex-col gap-1.5">
        <ReadOut
          label={`Serves best at ${BAND_LABELS[band]}`}
          value={served === undefined ? "-" : `${formatPercent(served)} of the plan`}
        />
        <ReadOut label="Position" value={`${accessPoint.x.toFixed(2)}, ${accessPoint.y.toFixed(2)} m`} />
      </div>
      <DeleteButton label="Delete router" onClick={onDelete} />
    </Section>
  )
}

function DeviceSection({
  device,
  signals,
  onCommit,
  onDelete,
}: {
  device: Device
  signals: { id: string; name: string; rssi: number }[]
  onCommit: (update: Update) => void
  onDelete: () => void
}) {
  const change = (fields: Partial<Device>) =>
    onCommit((value) => ({ ...value, devices: replaceItem(value.devices, device.id, fields) }))
  const best = signals.reduce((top, entry) => Math.max(top, entry.rssi), Number.NEGATIVE_INFINITY)
  return (
    <Section title="Device">
      <TextField
        id="device-name"
        label="Name"
        value={device.name}
        maxLength={ITEM_NAME_MAX}
        onCommit={(name) => change({ name })}
      />
      <div className="flex flex-col gap-1.5">
        <span className="text-xs text-text-2">Band</span>
        <Segmented<Band>
          label="Device band"
          value={device.band}
          options={[
            { value: "2.4", label: BAND_LABELS["2.4"] },
            { value: "5", label: BAND_LABELS["5"] },
          ]}
          onChange={(band) => change({ band })}
          className="self-start"
        />
      </div>
      <div className="flex flex-col gap-1.5">
        <span className="text-xs text-text-2">Predicted signal</span>
        {signals.length === 0 ? (
          <span className="text-[12px] text-text-3">No routers yet.</span>
        ) : (
          signals.map((entry) => {
            const quality = qualityOf(entry.rssi)
            return (
              <div key={entry.id} className="flex items-baseline justify-between gap-3 text-[12px]">
                <span className={entry.rssi === best && Number.isFinite(best) ? "text-foreground" : "text-text-3"}>
                  {entry.name}
                </span>
                <span className="font-data text-text-2">
                  {Number.isFinite(entry.rssi) ? `${formatDbm(entry.rssi)}, ${QUALITY_LABELS[quality].toLowerCase()}` : "Band off"}
                </span>
              </div>
            )
          })
        )}
      </div>
      <ReadOut label="Position" value={`${device.x.toFixed(2)}, ${device.y.toFixed(2)} m`} />
      <DeleteButton label="Delete device" onClick={onDelete} />
    </Section>
  )
}

function LegendSection() {
  return (
    <Section title="Legend">
      <div className="flex flex-col gap-1.5">
        {QUALITY_ORDER.map((quality) => (
          <div key={quality} className="flex items-center gap-2 text-[12px]">
            <Swatch color={qualityColor(quality)} hollow={quality === "none"} />
            <span className="flex-1 text-foreground">{QUALITY_LABELS[quality]}</span>
            <span className="font-data text-[11px] text-text-3">{qualityRange(quality)}</span>
          </div>
        ))}
      </div>
      <span className="text-[11px] text-text-3">The model assumes open space where no walls are drawn.</span>
      <div className="flex flex-col gap-1.5 pt-1">
        {MATERIALS.map((material) => {
          const style = WALL_STYLES[material]
          return (
            <div key={material} className="flex items-center gap-2 text-[12px]">
              <svg aria-hidden width={18} height={10} className="shrink-0">
                <line
                  x1={1}
                  y1={5}
                  x2={17}
                  y2={5}
                  stroke={style.color}
                  strokeWidth={Math.min(style.width, 6)}
                  strokeDasharray={style.dash}
                />
              </svg>
              <span className="flex-1 text-foreground">{MATERIAL_LABELS[material]}</span>
              <span className="font-data text-[11px] text-text-3">
                {WALL_LOSS_DB[material]["2.4"]} / {WALL_LOSS_DB[material]["5"]} dB
              </span>
            </div>
          )
        })}
        <span className="text-[11px] text-text-3">Wall loss at 2.4 / 5 GHz.</span>
      </div>
    </Section>
  )
}

function StatsSection({
  stats,
  band,
  accessPoints,
}: {
  stats: CoverageStats | null
  band: Band
  accessPoints: AccessPoint[]
}) {
  return (
    <Section title={`Coverage at ${BAND_LABELS[band]}`}>
      {!stats ? (
        <span className="text-[12px] text-text-3">Computing.</span>
      ) : (
        <>
          <div className="flex flex-col gap-0.5">
            <span className="font-data text-[22px] leading-none text-foreground" data-testid="coverage-at-target">
              {formatPercent(stats.atTarget)}
            </span>
            <span className="text-[11px] text-text-3">of the plan at {stats.target} dBm or better</span>
          </div>
          <div className="flex flex-col gap-1.5">
            {QUALITY_ORDER.map((quality) => (
              <div key={quality} className="flex items-center gap-2 text-[12px]">
                <span className="w-16 shrink-0 text-text-2">{QUALITY_LABELS[quality]}</span>
                <span className="relative h-1.5 flex-1 overflow-hidden rounded-full bg-surface-3">
                  <span
                    className="absolute inset-y-0 left-0 rounded-full"
                    style={{
                      width: `${Math.round(stats.quality[quality] * 100)}%`,
                      background: quality === "none" ? "var(--status-off)" : qualityColor(quality),
                    }}
                  />
                </span>
                <span className="w-10 shrink-0 text-right font-data text-[11px] text-text-2">
                  {formatPercent(stats.quality[quality])}
                </span>
              </div>
            ))}
          </div>
          {accessPoints.length > 0 ? (
            <div className="flex flex-col gap-1.5">
              <span className="text-xs text-text-2">Serves best</span>
              {accessPoints.map((accessPoint, index) => (
                <ReadOut
                  key={accessPoint.id}
                  label={accessPoint.name}
                  value={formatPercent(stats.servedBy[index] ?? 0)}
                />
              ))}
            </div>
          ) : null}
        </>
      )}
    </Section>
  )
}

function PlacementSection({
  alongWalls,
  onAlongWallsChange,
  suggestion,
  accessPoints,
  onApply,
  onDiscard,
}: {
  alongWalls: boolean
  onAlongWallsChange: (value: boolean) => void
  suggestion: Suggestion | null
  accessPoints: AccessPoint[]
  onApply: () => void
  onDiscard: () => void
}) {
  const result = suggestion?.result
  return (
    <Section title="Placement">
      <Label className="justify-between">
        Only along walls
        <Switch checked={alongWalls} onCheckedChange={onAlongWallsChange} />
      </Label>
      <span className="-mt-1 text-[11px] text-text-3">
        Keeps suggestions within 0.4 m of a wall, where sockets usually are. Locked routers stay put.
      </span>
      {suggestion?.status === "running" ? (
        <div className="flex items-center gap-2 text-[12px] text-text-2">
          <Spinner className="size-3.5" />
          Searching {formatPercent(suggestion.progress)}
        </div>
      ) : null}
      {suggestion?.status === "done" && result ? (
        <div className="flex flex-col gap-3 rounded-md border border-hairline p-3" data-testid="suggestion">
          {result.movable === 0 ? (
            <span className="text-[12px] text-text-2">
              Nothing to move: every router on {BAND_LABELS[suggestion.band]} is locked.
            </span>
          ) : (
            <>
              <div className="grid grid-cols-2 gap-3">
                <div className="flex flex-col gap-0.5">
                  <span className="text-[11px] text-text-3">Before</span>
                  <span className="font-data text-[18px] leading-none text-text-2" data-testid="suggestion-before">
                    {formatPercent(result.before)}
                  </span>
                </div>
                <div className="flex flex-col gap-0.5">
                  <span className="text-[11px] text-text-3">After</span>
                  <span className="font-data text-[18px] leading-none text-foreground" data-testid="suggestion-after">
                    {formatPercent(result.after)}
                  </span>
                </div>
              </div>
              <div className="flex flex-col gap-1">
                {result.moves.map((move) => {
                  const accessPoint = accessPoints.find((entry) => entry.id === move.id)
                  if (!accessPoint) return null
                  const shift = Math.hypot(move.x - accessPoint.x, move.y - accessPoint.y)
                  return (
                    <ReadOut
                      key={move.id}
                      label={accessPoint.name}
                      value={shift < 0.01 ? "stays" : `moves ${formatMeters(shift)}`}
                    />
                  )
                })}
              </div>
              <span className="font-data text-[11px] text-text-3" data-testid="suggestion-time">
                {BAND_LABELS[suggestion.band]}, {result.candidates} spots, {(suggestion.ms / 1000).toFixed(2)} s
              </span>
            </>
          )}
          <div className="flex items-center gap-2">
            {result.movable > 0 ? (
              <Button variant="outline" size="sm" onClick={onApply}>
                Apply
              </Button>
            ) : null}
            <Button variant="ghost" size="sm" onClick={onDiscard}>
              Discard
            </Button>
          </div>
        </div>
      ) : null}
    </Section>
  )
}

/**
 * The side panel of the plan editor: the selected wall, router or device, the coverage figures and the legend.
 * Read only, it shows the properties without letting them change and leaves out placement suggestions.
 */
export function Inspector({
  doc,
  band,
  selection,
  stats,
  material,
  deviceSignals,
  alongWalls,
  suggestion,
  onCommit,
  onMaterialChange,
  onDelete,
  onAlongWallsChange,
  onApply,
  onDiscard,
  readOnly = false,
}: {
  doc: PlanDoc
  band: Band
  selection: { kind: "wall" | "ap" | "device"; id: string } | null
  stats: CoverageStats | null
  material: WallMaterial
  deviceSignals: (device: Device) => { id: string; name: string; rssi: number }[]
  alongWalls: boolean
  suggestion: Suggestion | null
  onCommit: (update: Update, merge?: string) => void
  onMaterialChange: (material: WallMaterial) => void
  onDelete: () => void
  onAlongWallsChange: (value: boolean) => void
  onApply: () => void
  onDiscard: () => void
  readOnly?: boolean
}) {
  const wall = selection?.kind === "wall" ? doc.walls.find((item) => item.id === selection.id) : undefined
  const apIndex = selection?.kind === "ap" ? doc.access_points.findIndex((item) => item.id === selection.id) : -1
  const device = selection?.kind === "device" ? doc.devices.find((item) => item.id === selection.id) : undefined

  let detail: React.ReactNode
  if (wall) {
    detail = (
      <WallSection key={wall.id} wall={wall} onCommit={onCommit} onMaterialChange={onMaterialChange} onDelete={onDelete} />
    )
  } else if (apIndex >= 0) {
    const accessPoint = doc.access_points[apIndex]
    detail = (
      <RouterSection
        key={accessPoint.id}
        accessPoint={accessPoint}
        index={apIndex}
        band={band}
        stats={stats}
        onCommit={onCommit}
        onDelete={onDelete}
      />
    )
  } else if (device) {
    detail = (
      <DeviceSection
        key={device.id}
        device={device}
        signals={deviceSignals(device)}
        onCommit={onCommit}
        onDelete={onDelete}
      />
    )
  } else {
    detail = <PlanSection doc={doc} material={material} onCommit={onCommit} onMaterialChange={onMaterialChange} />
  }

  const placement = (
    <PlacementSection
      alongWalls={alongWalls}
      onAlongWallsChange={onAlongWallsChange}
      suggestion={suggestion}
      accessPoints={doc.access_points}
      onApply={onApply}
      onDiscard={onDiscard}
    />
  )

  if (readOnly) {
    return (
      <div className="flex flex-col">
        <fieldset disabled className="contents [&_[data-slot=button]]:hidden">
          {detail}
        </fieldset>
        <StatsSection stats={stats} band={band} accessPoints={doc.access_points} />
        <LegendSection />
      </div>
    )
  }

  return (
    <div className="flex flex-col">
      {suggestion ? placement : null}
      {detail}
      <StatsSection stats={stats} band={band} accessPoints={doc.access_points} />
      {suggestion ? null : placement}
      <LegendSection />
    </div>
  )
}
