"use client"

import * as React from "react"
import { CheckIcon, HomeIcon, PencilIcon, PlayIcon, Trash2Icon, XIcon } from "lucide-react"
import { toast } from "sonner"

import { IconButton } from "@/components/shell/icon-button"
import { Spinner } from "@/components/shell/primitives"
import { Segmented } from "@/components/shell/segmented"
import { useCan } from "@/components/shell/session"
import {
  AlertDialog,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog"
import { Button } from "@/components/ui/button"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Slider } from "@/components/ui/slider"
import { Switch } from "@/components/ui/switch"
import { VideoStream } from "@/components/video/video-stream"
import { api, errorMessage, isAbort } from "@/lib/api"
import { dayRange, localDay } from "@/lib/events"
import { formatMoment, formatSpan } from "@/lib/health"
import type {
  CameraDevice,
  CameraExtras,
  CameraImage,
  CameraMotion,
  CameraPresets,
  CameraRecordings,
  CameraVideo,
  EncoderOptions,
  ImageSettings,
  VideoEncoder,
} from "@/lib/types"

const TV_MAX_WIDTH = 1920
const TV_MAX_HEIGHT = 1088
const SIREN_SECONDS = 5

type Loader<T> = (signal: AbortSignal) => Promise<T>

function useLoad<T>(load: Loader<T>, key: string) {
  const [data, setData] = React.useState<T | null>(null)
  const [error, setError] = React.useState<string | null>(null)
  const fetchData = React.useEffectEvent((signal: AbortSignal) => load(signal))
  React.useEffect(() => {
    const controller = new AbortController()
    fetchData(controller.signal)
      .then((value) => {
        setData(value)
        setError(null)
      })
      .catch((err: unknown) => {
        if (!isAbort(err)) setError(errorMessage(err))
      })
    return () => controller.abort()
  }, [key])
  return { data, setData, error }
}

/** A titled section of the camera page's side panel. */
export function ControlSection({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="flex flex-col gap-3 border-b border-hairline px-4 py-4 last:border-b-0">
      <h2 className="text-xs text-text-3">{title}</h2>
      {children}
    </section>
  )
}

function Note({ children }: { children: React.ReactNode }) {
  return <p className="text-[12px] text-text-3">{children}</p>
}

function ReadOut({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="grid grid-cols-[96px_minmax(0,1fr)] items-baseline gap-3 py-0.5">
      <span className="text-xs text-text-3">{label}</span>
      <span className="min-w-0 font-data text-xs break-all text-foreground">{value}</span>
    </div>
  )
}

function Loading({ data, error, children }: { data: unknown; error: string | null; children: React.ReactNode }) {
  if (data) return <>{children}</>
  if (error) return <Note>{error}</Note>
  return <Spinner />
}

function Confirm({
  open,
  onOpenChange,
  title,
  description,
  action,
  onConfirm,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  title: string
  description: string
  action: string
  onConfirm: () => void
}) {
  return (
    <AlertDialog open={open} onOpenChange={onOpenChange}>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{title}</AlertDialogTitle>
          <AlertDialogDescription>{description}</AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel asChild>
            <Button variant="outline">Cancel</Button>
          </AlertDialogCancel>
          <Button
            onClick={() => {
              onOpenChange(false)
              onConfirm()
            }}
          >
            {action}
          </Button>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}

function useAction() {
  const [busy, setBusy] = React.useState<string | null>(null)
  const run = async (key: string, action: () => Promise<unknown>, success?: string) => {
    setBusy(key)
    try {
      await action()
      if (success) toast.success(success)
      return true
    } catch (err) {
      toast.error(errorMessage(err))
      return false
    } finally {
      setBusy(null)
    }
  }
  return { busy, run }
}

function offsetLabel(seconds: number | null): string {
  if (seconds === null) return "-"
  const rounded = Math.round(seconds)
  if (Math.abs(rounded) < 2) return "In sync"
  return `${formatSpan(Math.abs(rounded))} ${rounded > 0 ? "ahead" : "behind"}`
}

/** The camera's identity and clock, with time sync and reboot for admins. */
export function DeviceSection({ cameraUuid }: { cameraUuid: string }) {
  const { data, setData, error } = useLoad<CameraDevice>((signal) => api.cameraDevice(cameraUuid, signal), cameraUuid)
  const { busy, run } = useAction()
  const canManage = useCan("admin")
  const [confirm, setConfirm] = React.useState<"sync" | "reboot" | null>(null)
  return (
    <ControlSection title="Device">
      <Loading data={data} error={error}>
        {data && !data.supported ? <Note>{data.reason}</Note> : null}
        {data?.supported ? (
          <>
            <div className="flex flex-col">
              <ReadOut label="Manufacturer" value={data.manufacturer ?? "-"} />
              <ReadOut label="Model" value={data.model ?? "-"} />
              <ReadOut label="Firmware" value={data.firmware ?? "-"} />
              <ReadOut label="Serial" value={data.serial ?? "-"} />
              <ReadOut label="Hardware" value={data.hardware_id ?? "-"} />
              <ReadOut label="Camera time" value={formatMoment(data.clock?.camera_utc)} />
              <ReadOut label="Clock" value={offsetLabel(data.clock?.offset_seconds ?? null)} />
              <ReadOut
                label="Time mode"
                value={[data.clock?.mode, data.clock?.timezone].filter(Boolean).join(", ") || "-"}
              />
            </div>
            {canManage ? (
              <div className="flex flex-wrap gap-2">
                <Button variant="outline" size="sm" disabled={busy !== null} onClick={() => setConfirm("sync")}>
                  {busy === "sync" ? <Spinner className="size-3.5" /> : null}
                  Sync time
                </Button>
                {data.can_reboot ? (
                  <Button variant="outline" size="sm" disabled={busy !== null} onClick={() => setConfirm("reboot")}>
                    Reboot
                  </Button>
                ) : null}
              </div>
            ) : null}
          </>
        ) : null}
      </Loading>
      <Confirm
        open={confirm === "sync"}
        onOpenChange={(open) => setConfirm(open ? "sync" : null)}
        title="Sync the camera clock?"
        description="Sets the camera's UTC time to this computer's time. A camera on NTP stays on NTP. A camera whose on-screen time follows its own time zone may show a different local time afterwards."
        action="Sync time"
        onConfirm={() =>
          void run("sync", async () => setData(await api.syncCameraTime(cameraUuid)), "Camera clock synced")
        }
      />
      <Confirm
        open={confirm === "reboot"}
        onOpenChange={(open) => setConfirm(open ? "reboot" : null)}
        title="Reboot the camera?"
        description="The camera stops streaming and recording for a minute or two while it restarts."
        action="Reboot"
        onConfirm={() => void run("reboot", () => api.rebootCamera(cameraUuid), "The camera is restarting")}
      />
    </ControlSection>
  )
}

function optionFor(encoder: VideoEncoder, encoding: string): EncoderOptions | undefined {
  return encoder.options.find((option) => option.encoding.toUpperCase() === encoding.toUpperCase())
}

function EncoderEditor({
  encoder,
  onSave,
  onCancel,
  busy,
}: {
  encoder: VideoEncoder
  onSave: (values: { encoding: string; resolution: string; fps: string; bitrate: string; gop: string }) => void
  onCancel: () => void
  busy: boolean
}) {
  const [encoding, setEncoding] = React.useState(encoder.encoding ?? "")
  const [resolution, setResolution] = React.useState(`${encoder.width}x${encoder.height}`)
  const [fps, setFps] = React.useState(String(encoder.fps ?? ""))
  const [bitrate, setBitrate] = React.useState(String(encoder.bitrate ?? ""))
  const [gop, setGop] = React.useState(String(encoder.gop ?? ""))
  const option = optionFor(encoder, encoding)
  const resolutions = option?.resolutions.map((item) => `${item.width}x${item.height}`) ?? []
  return (
    <div className="flex flex-col gap-2 rounded-md border border-hairline p-2.5">
      {encoder.options.length > 1 ? (
        <Select value={encoding} onValueChange={setEncoding}>
          <SelectTrigger aria-label="Codec">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            {encoder.options.map((item) => (
              <SelectItem key={item.encoding} value={item.encoding}>
                {item.encoding}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      ) : null}
      {resolutions.length > 0 ? (
        <Select value={resolution} onValueChange={setResolution}>
          <SelectTrigger aria-label="Resolution">
            <SelectValue placeholder="Resolution" />
          </SelectTrigger>
          <SelectContent>
            {resolutions.map((item) => (
              <SelectItem key={item} value={item}>
                {item}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      ) : null}
      {option && option.fps_values.length > 0 ? (
        <Select value={fps} onValueChange={setFps}>
          <SelectTrigger aria-label="Frame rate">
            <SelectValue placeholder="Frame rate" />
          </SelectTrigger>
          <SelectContent>
            {option.fps_values.map((item) => (
              <SelectItem key={item} value={String(item)}>
                {item} fps
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      ) : (
        <label className="flex items-center gap-2 text-[12px] text-text-3">
          <span className="w-20">Frame rate</span>
          <Input value={fps} inputMode="decimal" onChange={(event) => setFps(event.target.value)} className="h-8" />
        </label>
      )}
      <label className="flex items-center gap-2 text-[12px] text-text-3">
        <span className="w-20">Bitrate</span>
        <Input value={bitrate} inputMode="numeric" onChange={(event) => setBitrate(event.target.value)} className="h-8" />
        <span className="shrink-0">kbit/s</span>
      </label>
      {option?.bitrate ? (
        <Note>
          {option.bitrate.min} to {option.bitrate.max} kbit/s
        </Note>
      ) : null}
      <label className="flex items-center gap-2 text-[12px] text-text-3">
        <span className="w-20">Key frames</span>
        <Input value={gop} inputMode="numeric" onChange={(event) => setGop(event.target.value)} className="h-8" />
        <span className="shrink-0">frames</span>
      </label>
      <div className="flex gap-2">
        <Button size="sm" disabled={busy} onClick={() => onSave({ encoding, resolution, fps, bitrate, gop })}>
          {busy ? <Spinner className="size-3.5" /> : null}
          Save
        </Button>
        <Button size="sm" variant="ghost" disabled={busy} onClick={onCancel}>
          Cancel
        </Button>
      </div>
    </div>
  )
}

/** The camera's video encoders, editable by admins. */
export function VideoSection({ cameraUuid }: { cameraUuid: string }) {
  const { data, setData, error } = useLoad<CameraVideo>((signal) => api.cameraVideo(cameraUuid, signal), cameraUuid)
  const [editing, setEditing] = React.useState<string | null>(null)
  const { busy, run } = useAction()
  const canManage = useCan("admin")

  const save = (encoder: VideoEncoder, values: { encoding: string; resolution: string; fps: string; bitrate: string; gop: string }) => {
    const [width, height] = values.resolution.split("x").map(Number)
    const body = {
      encoding: values.encoding || undefined,
      width: Number.isFinite(width) ? width : undefined,
      height: Number.isFinite(height) ? height : undefined,
      fps: values.fps ? Number(values.fps) : undefined,
      bitrate: values.bitrate ? Number(values.bitrate) : undefined,
      gop: values.gop ? Number(values.gop) : undefined,
    }
    void run(
      encoder.token,
      async () => {
        setData(await api.updateEncoder(cameraUuid, encoder.token, body))
        setEditing(null)
      },
      "Video settings saved",
    )
  }

  return (
    <ControlSection title="Video">
      <Loading data={data} error={error}>
        {data && !data.supported ? <Note>{data.reason}</Note> : null}
        {data?.supported
          ? data.encoders.map((encoder) => (
              <div key={encoder.token} className="flex flex-col gap-1.5">
                <div className="flex items-center justify-between gap-2">
                  <span className="truncate text-[12px] text-foreground">
                    {encoder.profiles.join(", ") || encoder.name}
                  </span>
                  {canManage && editing !== encoder.token ? (
                    <IconButton label="Edit video settings" size="icon-sm" onClick={() => setEditing(encoder.token)}>
                      <PencilIcon />
                    </IconButton>
                  ) : null}
                </div>
                <span className="font-data text-[11px] text-text-2">
                  {encoder.encoding} {encoder.width}x{encoder.height}, {encoder.fps ?? "-"} fps, {encoder.bitrate ?? "-"}{" "}
                  kbit/s, key frame every {encoder.gop ?? "-"}
                </span>
                {editing === encoder.token ? (
                  <EncoderEditor
                    encoder={encoder}
                    busy={busy === encoder.token}
                    onCancel={() => setEditing(null)}
                    onSave={(values) => save(encoder, values)}
                  />
                ) : null}
              </div>
            ))
          : null}
        {data?.supported ? (
          <Note>
            The TV decodes at most {TV_MAX_WIDTH}x{TV_MAX_HEIGHT}, so a main stream at 1920x1080 plays sharp in TV
            fullscreen.
          </Note>
        ) : null}
      </Loading>
    </ControlSection>
  )
}

const LEVEL_LABELS: Record<string, string> = {
  brightness: "Brightness",
  contrast: "Contrast",
  saturation: "Saturation",
  sharpness: "Sharpness",
}

const IR_LABELS: Record<string, string> = { AUTO: "Auto", ON: "Day", OFF: "Night" }

function LevelSlider({
  label,
  value,
  min,
  max,
  disabled,
  onCommit,
}: {
  label: string
  value: number
  min: number
  max: number
  disabled: boolean
  onCommit: (value: number) => void
}) {
  const [dragging, setDragging] = React.useState<number | null>(null)
  const current = dragging ?? value
  return (
    <div className="flex flex-col gap-1.5">
      <div className="flex items-center justify-between text-[12px]">
        <span className="text-text-3">{label}</span>
        <span className="font-data text-foreground">{Math.round(current)}</span>
      </div>
      <Slider
        aria-label={label}
        min={min}
        max={max}
        step={1}
        value={[current]}
        disabled={disabled}
        onValueChange={(values) => setDragging(values[0])}
        onValueCommit={(values) => {
          setDragging(null)
          onCommit(values[0])
        }}
      />
    </div>
  )
}

/** The camera's image settings, adjustable by admins and read only for others. */
export function ImageSection({ cameraUuid }: { cameraUuid: string }) {
  const { data, setData, error } = useLoad<CameraImage>((signal) => api.cameraImage(cameraUuid, signal), cameraUuid)
  const { busy, run } = useAction()
  const canManage = useCan("admin")
  const locked = busy !== null || !canManage
  const apply = (changes: Partial<ImageSettings>) =>
    void run("image", async () => setData(await api.updateImage(cameraUuid, changes)))
  const settings = data?.settings
  const options = data?.options
  return (
    <ControlSection title="Image">
      <Loading data={data} error={error}>
        {data && !data.supported ? <Note>{data.reason}</Note> : null}
        {settings && options ? (
          <>
            {Object.entries(LEVEL_LABELS).map(([key, label]) => {
              const range = options.levels[key]
              const value = settings[key as keyof ImageSettings]
              if (!range || typeof value !== "number") return null
              return (
                <LevelSlider
                  key={key}
                  label={label}
                  value={value}
                  min={range.min}
                  max={range.max}
                  disabled={locked}
                  onCommit={(next) => apply({ [key]: next })}
                />
              )
            })}
            {options.ir_cut_filter_modes.length > 0 && settings.ir_cut_filter ? (
              <div className="flex items-center justify-between gap-2 text-[12px]">
                <span className="text-text-3">Day and night</span>
                <Segmented<string>
                  label="Day and night"
                  value={settings.ir_cut_filter}
                  options={options.ir_cut_filter_modes.map((mode) => ({
                    value: mode,
                    label: IR_LABELS[mode] ?? mode,
                    disabled: locked,
                  }))}
                  onChange={(mode) => apply({ ir_cut_filter: mode })}
                />
              </div>
            ) : null}
            {options.wdr_modes.length > 0 && settings.wdr_mode ? (
              <div className="flex items-center justify-between gap-2 text-[12px]">
                <span className="text-text-3">Wide dynamic range</span>
                <Switch
                  aria-label="Wide dynamic range"
                  checked={settings.wdr_mode === "ON"}
                  disabled={locked || !options.wdr_modes.includes(settings.wdr_mode === "ON" ? "OFF" : "ON")}
                  onCheckedChange={(checked) => apply({ wdr_mode: checked ? "ON" : "OFF" })}
                />
              </div>
            ) : null}
            {settings.wdr_mode === "ON" && options.wdr_level && typeof settings.wdr_level === "number" ? (
              <LevelSlider
                label="WDR level"
                value={settings.wdr_level}
                min={options.wdr_level.min}
                max={options.wdr_level.max}
                disabled={locked}
                onCommit={(next) => apply({ wdr_level: next })}
              />
            ) : null}
            {options.backlight_modes.length > 0 && settings.backlight_mode ? (
              <div className="flex items-center justify-between gap-2 text-[12px]">
                <span className="text-text-3">Backlight compensation</span>
                <Switch
                  aria-label="Backlight compensation"
                  checked={settings.backlight_mode === "ON"}
                  disabled={locked}
                  onCheckedChange={(checked) => apply({ backlight_mode: checked ? "ON" : "OFF" })}
                />
              </div>
            ) : null}
          </>
        ) : null}
      </Loading>
    </ControlSection>
  )
}

/** The camera's own motion detection, adjustable by admins and read only for others. */
export function MotionSection({ cameraUuid }: { cameraUuid: string }) {
  const { data, setData, error } = useLoad<CameraMotion>((signal) => api.cameraMotion(cameraUuid, signal), cameraUuid)
  const { busy, run } = useAction()
  const canManage = useCan("admin")
  const locked = busy !== null || !canManage
  const apply = (changes: { sensitivity?: number; enabled?: boolean }) =>
    void run("motion", async () => setData(await api.updateMotion(cameraUuid, changes)))
  return (
    <ControlSection title="Motion detection">
      <Loading data={data} error={error}>
        {data && !data.supported ? <Note>{data.reason}</Note> : null}
        {data?.supported ? (
          <>
            {data.enabled !== null ? (
              <div className="flex items-center justify-between gap-2 text-[12px]">
                <span className="text-text-3">
                  Detection {data.enabled ? `on ${data.active_cells} of ${data.cells} cells` : "off"}
                </span>
                <Switch
                  aria-label="Motion detection"
                  checked={data.enabled}
                  disabled={locked}
                  onCheckedChange={(checked) => apply({ enabled: checked })}
                />
              </div>
            ) : null}
            {data.sensitivity !== null && data.sensitivity_range ? (
              <LevelSlider
                label="Sensitivity"
                value={data.sensitivity}
                min={data.sensitivity_range.min}
                max={data.sensitivity_range.max}
                disabled={locked}
                onCommit={(next) => apply({ sensitivity: next })}
              />
            ) : null}
            <Note>The camera rounds sensitivity to its own steps and reports the step it uses.</Note>
          </>
        ) : null}
      </Loading>
    </ControlSection>
  )
}

function PresetRow({
  cameraUuid,
  token,
  name,
  disabled,
  onChanged,
}: {
  cameraUuid: string
  token: string
  name: string
  disabled: boolean
  onChanged: (presets: CameraPresets) => void
}) {
  const [renaming, setRenaming] = React.useState(false)
  const [value, setValue] = React.useState(name)
  const [removing, setRemoving] = React.useState(false)
  const { busy, run } = useAction()
  const canManage = useCan("admin")
  const locked = disabled || busy !== null
  if (renaming && canManage) {
    return (
      <li className="flex items-center gap-1">
        <Input value={value} maxLength={60} onChange={(event) => setValue(event.target.value)} className="h-7 text-[12px]" />
        <IconButton
          label="Save name"
          size="icon-sm"
          disabled={locked || !value.trim()}
          onClick={() =>
            void run("rename", async () => {
              onChanged(await api.renamePreset(cameraUuid, token, value.trim()))
              setRenaming(false)
            })
          }
        >
          <CheckIcon />
        </IconButton>
        <IconButton label="Cancel" size="icon-sm" onClick={() => setRenaming(false)}>
          <XIcon />
        </IconButton>
      </li>
    )
  }
  return (
    <li className="flex items-center gap-1">
      <span className="min-w-0 flex-1 truncate text-[12px] text-foreground">{name}</span>
      <IconButton
        label="Go to preset"
        size="icon-sm"
        disabled={locked}
        onClick={() => void run("goto", () => api.gotoPreset(cameraUuid, token))}
      >
        <PlayIcon />
      </IconButton>
      {canManage ? (
        <IconButton label="Rename" size="icon-sm" disabled={locked} onClick={() => setRenaming(true)}>
          <PencilIcon />
        </IconButton>
      ) : null}
      {canManage ? (
        <IconButton label="Remove" size="icon-sm" disabled={locked} onClick={() => setRemoving(true)}>
          <Trash2Icon />
        </IconButton>
      ) : null}
      <Confirm
        open={removing}
        onOpenChange={setRemoving}
        title={`Remove ${name}?`}
        description="The camera forgets this position."
        action="Remove"
        onConfirm={() => void run("remove", async () => onChanged(await api.removePreset(cameraUuid, token)))}
      />
    </li>
  )
}

/** PTZ presets and the home position: operators go to them, admins also save, rename and remove them. */
export function PresetsSection({ cameraUuid }: { cameraUuid: string }) {
  const { data, setData, error } = useLoad<CameraPresets>((signal) => api.cameraPresets(cameraUuid, signal), cameraUuid)
  const [name, setName] = React.useState("")
  const [settingHome, setSettingHome] = React.useState(false)
  const { busy, run } = useAction()
  const canManage = useCan("admin")
  return (
    <ControlSection title="Presets">
      <Loading data={data} error={error}>
        {data && !data.supported ? <Note>{data.reason}</Note> : null}
        {data?.supported ? (
          <>
            {data.presets.length > 0 ? (
              <ul className="flex flex-col gap-1">
                {data.presets.map((preset) => (
                  <PresetRow
                    key={preset.token}
                    cameraUuid={cameraUuid}
                    token={preset.token}
                    name={preset.name}
                    disabled={busy !== null}
                    onChanged={setData}
                  />
                ))}
              </ul>
            ) : (
              <Note>No presets saved yet.</Note>
            )}
            {data.max_presets && canManage ? (
              <form
                className="flex items-center gap-1.5"
                onSubmit={(event) => {
                  event.preventDefault()
                  if (!name.trim()) return
                  void run("save", async () => {
                    setData(await api.savePreset(cameraUuid, name.trim()))
                    setName("")
                  })
                }}
              >
                <Input
                  value={name}
                  maxLength={60}
                  placeholder="Name this view"
                  onChange={(event) => setName(event.target.value)}
                  className="h-8 text-[12px]"
                />
                <Button type="submit" size="sm" variant="outline" disabled={busy !== null || !name.trim()}>
                  Save
                </Button>
              </form>
            ) : null}
            {data.home_supported ? (
              <div className="flex flex-wrap gap-2">
                <Button
                  size="sm"
                  variant="outline"
                  disabled={busy !== null}
                  onClick={() => void run("home", () => api.gotoHome(cameraUuid))}
                >
                  <HomeIcon />
                  Go home
                </Button>
                {canManage ? (
                  <Button size="sm" variant="ghost" disabled={busy !== null} onClick={() => setSettingHome(true)}>
                    Set home here
                  </Button>
                ) : null}
              </div>
            ) : null}
            {canManage ? <Note>Renaming a preset also stores the current view under it.</Note> : null}
          </>
        ) : null}
      </Loading>
      <Confirm
        open={settingHome}
        onOpenChange={setSettingHome}
        title="Make this view the home position?"
        description="Go home returns the camera to the view it shows now."
        action="Set home"
        onConfirm={() => void run("set-home", () => api.setHome(cameraUuid), "Home position saved")}
      />
    </ControlSection>
  )
}

/** The camera's light and siren, for operators and up. */
export function ExtrasSection({ cameraUuid }: { cameraUuid: string }) {
  const { data, error } = useLoad<CameraExtras>((signal) => api.cameraExtras(cameraUuid, signal), cameraUuid)
  const [sounding, setSounding] = React.useState(false)
  const { busy, run } = useAction()
  if (data && !data.supported) return null
  return (
    <ControlSection title="Light and siren">
      <Loading data={data} error={error}>
        {data?.light ? (
          <div className="flex items-center justify-between gap-2 text-[12px]">
            <span className="text-text-3">Light</span>
            <div className="flex gap-1">
              {(["on", "off", "auto"] as const).map((mode) => (
                <Button
                  key={mode}
                  size="sm"
                  variant="outline"
                  disabled={busy !== null}
                  onClick={() => void run(mode, () => api.setLight(cameraUuid, mode), `Light ${mode}`)}
                >
                  {mode === "on" ? "On" : mode === "off" ? "Off" : "Auto"}
                </Button>
              ))}
            </div>
          </div>
        ) : null}
        {data?.siren ? (
          <div className="flex items-center justify-between gap-2 text-[12px]">
            <span className="text-text-3">Siren</span>
            <div className="flex gap-1">
              <Button size="sm" variant="outline" disabled={busy !== null} onClick={() => setSounding(true)}>
                Sound {SIREN_SECONDS} s
              </Button>
              <Button
                size="sm"
                variant="outline"
                disabled={busy !== null}
                onClick={() => void run("siren-off", () => api.setSiren(cameraUuid, 0), "Siren off")}
              >
                Stop
              </Button>
            </div>
          </div>
        ) : null}
        <Note>The camera does not report the light state, so the buttons send a command without showing the current one.</Note>
      </Loading>
      <Confirm
        open={sounding}
        onOpenChange={setSounding}
        title="Sound the siren?"
        description={`The camera sounds its siren for ${SIREN_SECONDS} seconds.`}
        action="Sound siren"
        onConfirm={() => void run("siren", () => api.setSiren(cameraUuid, SIREN_SECONDS), "Siren on")}
      />
    </ControlSection>
  )
}

function Timeline({
  start,
  end,
  segments,
  onPick,
}: {
  start: number
  end: number
  segments: { start: string; end: string }[]
  onPick: ((moment: Date) => void) | null
}) {
  const span = end - start
  return (
    <div className="flex flex-col gap-1">
      <div
        role={onPick ? "button" : "img"}
        aria-label="Recordings of the day"
        tabIndex={onPick ? 0 : -1}
        className="relative h-6 overflow-hidden rounded-md bg-surface-2"
        onClick={(event) => {
          if (!onPick) return
          const box = event.currentTarget.getBoundingClientRect()
          onPick(new Date(start + ((event.clientX - box.left) / box.width) * span))
        }}
      >
        {segments.map((segment) => {
          const left = Math.max(0, (Date.parse(segment.start) - start) / span) * 100
          const right = Math.min(1, (Date.parse(segment.end) - start) / span) * 100
          return (
            <span
              key={segment.start}
              className="absolute inset-y-0 bg-status-ok/70"
              style={{ left: `${left}%`, width: `${Math.max(0.3, right - left)}%` }}
            />
          )
        })}
      </div>
      <div className="flex justify-between font-data text-[10px] text-text-3">
        <span>00:00</span>
        <span>06:00</span>
        <span>12:00</span>
        <span>18:00</span>
        <span>24:00</span>
      </div>
    </div>
  )
}

function ReplayDialog({
  cameraUuid,
  start,
  onClose,
}: {
  cameraUuid: string
  start: Date | null
  onClose: () => void
}) {
  const [stream, setStream] = React.useState<{ name: string; session: string } | null>(null)
  const [failure, setFailure] = React.useState<string | null>(null)
  React.useEffect(() => {
    if (!start) return
    let session: string | null = null
    let timer = 0
    let cancelled = false
    api
      .startReplay(cameraUuid, start.toISOString())
      .then((replay) => {
        if (cancelled || !replay.stream || !replay.session) return
        session = replay.session
        setStream({ name: replay.stream, session: replay.session })
        const poll = () => {
          api
            .replayStatus(cameraUuid)
            .then((status) => {
              if (cancelled) return
              if (!status.active || status.session !== session) {
                setFailure(status.failure ?? "The replay ended")
                return
              }
              timer = window.setTimeout(poll, 3000)
            })
            .catch(() => undefined)
        }
        timer = window.setTimeout(poll, 3000)
      })
      .catch((err: unknown) => {
        if (!cancelled) setFailure(errorMessage(err))
      })
    return () => {
      cancelled = true
      window.clearTimeout(timer)
      if (session) void api.stopReplay(cameraUuid, session).catch(() => undefined)
      setStream(null)
      setFailure(null)
    }
  }, [cameraUuid, start])
  return (
    <Dialog open={start !== null} onOpenChange={(open) => (open ? undefined : onClose())}>
      <DialogContent className="max-w-3xl">
        <DialogHeader>
          <DialogTitle>Recording from {start ? formatMoment(start.toISOString()) : ""}</DialogTitle>
          <DialogDescription>Played from the camera&apos;s SD card.</DialogDescription>
        </DialogHeader>
        <div className="relative aspect-video overflow-hidden rounded-md bg-black">
          {failure ? (
            <div className="absolute inset-0 flex items-center justify-center p-4 text-center text-[13px] text-white/80">
              {failure}
            </div>
          ) : stream ? (
            <VideoStream stream={stream.name} snapshot={false} retry={false} className="absolute inset-0" />
          ) : (
            <div className="absolute inset-0 flex items-center justify-center">
              <Spinner />
            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>
  )
}

/** Recordings stored on the camera, with replay, for operators and up. */
export function RecordingsSection({ cameraUuid }: { cameraUuid: string }) {
  const [day, setDay] = React.useState(() => localDay(new Date()))
  const range = dayRange(day)
  const { data, error } = useLoad<CameraRecordings>(
    (signal) => api.cameraRecordings(cameraUuid, range ?? {}, signal),
    `${cameraUuid}-${day}`,
  )
  const [replayAt, setReplayAt] = React.useState<Date | null>(null)
  const start = range ? Date.parse(range.from) : 0
  const end = range ? Date.parse(range.to) : 0
  const recorded = data?.segments.reduce((total, segment) => total + Date.parse(segment.end) - Date.parse(segment.start), 0) ?? 0
  return (
    <ControlSection title="Recordings">
      <Loading data={data} error={error}>
        {data && !data.supported ? <Note>{data.reason}</Note> : null}
        {data?.supported && !data.recordings ? <Note>No SD card or nothing recorded on the camera.</Note> : null}
        {data?.supported && data.recordings ? (
          <>
            <Input
              type="date"
              aria-label="Day"
              value={day}
              max={localDay(new Date())}
              onChange={(event) => event.target.value && setDay(event.target.value)}
              className="h-8 font-data text-[12px]"
            />
            <Timeline
              start={start}
              end={end}
              segments={data.segments}
              onPick={data.playback ? (moment) => setReplayAt(moment) : null}
            />
            <Note>
              {data.segments.length > 0
                ? `${formatSpan(recorded / 1000)} recorded in ${data.segments.length} part${data.segments.length === 1 ? "" : "s"}`
                : "Nothing recorded on this day"}
              {data.data_until ? `, latest ${formatMoment(data.data_until)}` : ""}
            </Note>
            {data.playback ? <Note>Click the timeline to play from that time.</Note> : null}
            {!data.playback && data.playback_reason ? <Note>{data.playback_reason}</Note> : null}
          </>
        ) : null}
      </Loading>
      <ReplayDialog cameraUuid={cameraUuid} start={replayAt} onClose={() => setReplayAt(null)} />
    </ControlSection>
  )
}
