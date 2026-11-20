"use client"

import * as React from "react"
import { ScanSearchIcon } from "lucide-react"
import { toast } from "sonner"

import { Spinner } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogBody,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Switch } from "@/components/ui/switch"
import { api, errorMessage } from "@/lib/api"
import { BRANDS, BRAND_ORDER } from "@/lib/brands"
import type { Camera, CameraBrand, CameraCreate, CameraUpdate, InspectResult } from "@/lib/types"
import { cn } from "@/lib/utils"

export interface CameraPrefill {
  name?: string
  host?: string
  brand?: CameraBrand | null
  onvif_port?: number | null
}

interface FormState {
  name: string
  brand: CameraBrand
  host: string
  deviceHost: string
  rtspPort: string
  onvifPort: string
  username: string
  password: string
  clearPassword: boolean
  mainPath: string
  subPath: string
  lenses: string
  ptz: boolean | null
  location: string
  enabled: boolean
}

type Field = "name" | "host" | "rtspPort" | "onvifPort" | "mainPath"
type Errors = Partial<Record<Field, string>>

function initialState(camera: Camera | null | undefined, prefill: CameraPrefill | null | undefined): FormState {
  if (camera) {
    return {
      name: camera.name,
      brand: camera.brand,
      host: camera.host,
      deviceHost: camera.device_host ?? "",
      rtspPort: String(camera.rtsp_port),
      onvifPort: camera.onvif_port == null ? "" : String(camera.onvif_port),
      username: camera.username ?? "",
      password: "",
      clearPassword: false,
      mainPath: camera.main_path,
      subPath: camera.sub_path ?? "",
      lenses: String(camera.lenses),
      ptz: camera.ptz_enabled,
      location: camera.location ?? "",
      enabled: camera.enabled,
    }
  }
  return {
    name: prefill?.name ?? "",
    brand: prefill?.brand ?? "ezviz",
    host: prefill?.host ?? "",
    deviceHost: "",
    rtspPort: "",
    onvifPort: prefill?.onvif_port ? String(prefill.onvif_port) : "",
    username: "",
    password: "",
    clearPassword: false,
    mainPath: "",
    subPath: "",
    lenses: "1",
    ptz: null,
    location: "",
    enabled: true,
  }
}

const URI_PATTERN = /^[a-z][a-z0-9+.-]*:\/\/(?:[^@/]*@)?(\[[^\]]+\]|[^/:?#]+)(?::(\d+))?([^#]*)$/i

function splitStreamUri(uri: string | null): { port: number | null; path: string } | null {
  if (!uri) return null
  const match = URI_PATTERN.exec(uri.trim())
  if (!match) return null
  const rest = match[3] || "/"
  return { port: match[2] ? Number(match[2]) : null, path: rest.startsWith("/") ? rest : `/${rest}` }
}

function parsePort(value: string): number | null | "invalid" {
  const text = value.trim()
  if (!text) return null
  if (!/^\d+$/.test(text)) return "invalid"
  const port = Number(text)
  return port >= 1 && port <= 65535 ? port : "invalid"
}

function nullable(value: string): string | null {
  const text = value.trim()
  return text ? text : null
}

function FormField({
  id,
  label,
  error,
  hint,
  className,
  children,
}: {
  id: string
  label: string
  error?: string
  hint?: React.ReactNode
  className?: string
  children: React.ReactNode
}) {
  return (
    <div className={cn("flex min-w-0 flex-col gap-1.5", className)}>
      <Label htmlFor={id}>{label}</Label>
      {children}
      {error ? (
        <p className="text-[12px] text-danger">{error}</p>
      ) : hint ? (
        <p className="text-[12px] text-text-3">{hint}</p>
      ) : null}
    </div>
  )
}

function CameraForm({
  camera,
  prefill,
  onCancel,
  onSaved,
}: {
  camera?: Camera | null
  prefill?: CameraPrefill | null
  onCancel: () => void
  onSaved: (camera: Camera) => void
}) {
  const editing = Boolean(camera)
  const [form, setForm] = React.useState<FormState>(() => initialState(camera, prefill))
  const [errors, setErrors] = React.useState<Errors>({})
  const [formError, setFormError] = React.useState<string | null>(null)
  const [saving, setSaving] = React.useState(false)
  const [detecting, setDetecting] = React.useState(false)
  const [detected, setDetected] = React.useState<InspectResult | null>(null)
  const [detectError, setDetectError] = React.useState<string | null>(null)

  const defaults = BRANDS[form.brand]
  const ptzChecked = form.ptz ?? defaults.ptz ?? false

  const update = <K extends keyof FormState>(key: K, value: FormState[K]) => {
    setForm((current) => ({ ...current, [key]: value }))
    if (key in errors) setErrors((current) => ({ ...current, [key]: undefined }))
  }

  const detect = async () => {
    const host = form.host.trim()
    if (!host) {
      setErrors((current) => ({ ...current, host: "Enter the host first" }))
      return
    }
    const port = parsePort(form.onvifPort)
    if (port === "invalid") {
      setErrors((current) => ({ ...current, onvifPort: "Use a port from 1 to 65535" }))
      return
    }
    const onvifPort = port ?? defaults.onvifPort ?? 80
    setDetecting(true)
    setDetectError(null)
    try {
      const result = await api.inspect({
        host,
        onvif_port: onvifPort,
        username: form.username.trim() || defaults.username || undefined,
        password: form.password || undefined,
      })
      setDetected(result)
      const withUri = result.profiles.filter((profile) => profile.stream_uri)
      const main = splitStreamUri(withUri[0]?.stream_uri ?? null)
      const sub = splitStreamUri(withUri[1]?.stream_uri ?? null)
      if (!main) setDetectError("The device answered but reported no stream address")
      setForm((current) => ({
        ...current,
        onvifPort: current.onvifPort || String(onvifPort),
        rtspPort: main?.port ? String(main.port) : current.rtspPort,
        mainPath: main?.path ?? current.mainPath,
        subPath: sub?.path ?? current.subPath,
        ptz: result.ptz,
      }))
      setErrors((current) => ({ ...current, mainPath: undefined, rtspPort: undefined, onvifPort: undefined }))
    } catch (err) {
      setDetected(null)
      setDetectError(errorMessage(err))
    } finally {
      setDetecting(false)
    }
  }

  const validate = (): Errors => {
    const next: Errors = {}
    if (!form.name.trim()) next.name = "Enter a name"
    if (!form.host.trim()) next.host = "Enter the host"
    const rtsp = parsePort(form.rtspPort)
    if (rtsp === "invalid") next.rtspPort = "Use a port from 1 to 65535"
    if (editing && rtsp === null) next.rtspPort = "Enter the RTSP port"
    if (parsePort(form.onvifPort) === "invalid") next.onvifPort = "Use a port from 1 to 65535"
    if (!form.mainPath.trim() && (editing || defaults.mainRequired)) next.mainPath = "Enter the main stream path"
    return next
  }

  const createBody = (): CameraCreate => {
    const body: CameraCreate = {
      name: form.name.trim(),
      brand: form.brand,
      host: form.host.trim(),
      enabled: form.enabled,
    }
    const rtsp = parsePort(form.rtspPort)
    const onvif = parsePort(form.onvifPort)
    if (typeof rtsp === "number") body.rtsp_port = rtsp
    if (typeof onvif === "number") body.onvif_port = onvif
    if (form.deviceHost.trim()) body.device_host = form.deviceHost.trim()
    if (form.username.trim()) body.username = form.username.trim()
    if (form.password) body.password = form.password
    if (form.mainPath.trim()) body.main_path = form.mainPath.trim()
    if (form.subPath.trim()) body.sub_path = form.subPath.trim()
    if (form.lenses !== "1") body.lenses = Number(form.lenses)
    if (form.ptz !== null) body.ptz_enabled = form.ptz
    if (form.location.trim()) body.location = form.location.trim()
    return body
  }

  const updateBody = (original: Camera): CameraUpdate => {
    const body: CameraUpdate = {}
    const name = form.name.trim()
    const host = form.host.trim()
    const rtsp = parsePort(form.rtspPort)
    const onvif = parsePort(form.onvifPort)
    const deviceHost = nullable(form.deviceHost)
    const username = nullable(form.username)
    const mainPath = form.mainPath.trim()
    const subPath = nullable(form.subPath)
    const location = nullable(form.location)
    if (name !== original.name) body.name = name
    if (form.brand !== original.brand) body.brand = form.brand
    if (host !== original.host) body.host = host
    if (deviceHost !== original.device_host) body.device_host = deviceHost
    if (typeof rtsp === "number" && rtsp !== original.rtsp_port) body.rtsp_port = rtsp
    if (onvif !== "invalid" && onvif !== original.onvif_port) body.onvif_port = onvif
    if (username !== original.username) body.username = username
    if (form.clearPassword) body.password = ""
    else if (form.password) body.password = form.password
    if (mainPath !== original.main_path) body.main_path = mainPath
    if (subPath !== original.sub_path) body.sub_path = subPath
    if (Number(form.lenses) !== original.lenses) body.lenses = Number(form.lenses)
    if (ptzChecked !== original.ptz_enabled) body.ptz_enabled = ptzChecked
    if (location !== original.location) body.location = location
    if (form.enabled !== original.enabled) body.enabled = form.enabled
    return body
  }

  const submit = async (event: React.FormEvent) => {
    event.preventDefault()
    const found = validate()
    setErrors(found)
    if (Object.values(found).some(Boolean)) return
    setFormError(null)
    setSaving(true)
    try {
      if (camera) {
        const body = updateBody(camera)
        if (Object.keys(body).length === 0) {
          onCancel()
          return
        }
        const saved = await api.updateCamera(camera.uuid, body)
        toast.success(`Saved ${saved.name}`)
        onSaved(saved)
      } else {
        const saved = await api.createCamera(createBody())
        toast.success(`Added ${saved.name}`)
        onSaved(saved)
      }
    } catch (err) {
      setFormError(errorMessage(err))
    } finally {
      setSaving(false)
    }
  }

  const passwordHint = camera?.has_password
    ? form.clearPassword
      ? (
          <span>
            The saved password is removed on save.{" "}
            <button type="button" className="text-foreground underline-offset-4 hover:underline" onClick={() => update("clearPassword", false)}>
              Keep it
            </button>
          </span>
        )
      : (
          <span>
            Saved. Leave empty to keep it.{" "}
            <button
              type="button"
              className="text-foreground underline-offset-4 hover:underline"
              onClick={() => {
                update("password", "")
                update("clearPassword", true)
              }}
            >
              Remove
            </button>
          </span>
        )
    : "Stored encrypted and never shown again."

  return (
    <form onSubmit={submit} noValidate className="flex min-h-0 flex-1 flex-col">
      <DialogHeader>
        <DialogTitle>{editing ? "Edit camera" : "Add camera"}</DialogTitle>
        <DialogDescription>{defaults.pathHint}</DialogDescription>
      </DialogHeader>
      <DialogBody className="grid grid-cols-1 gap-x-4 gap-y-4 sm:grid-cols-2">
        <FormField id="camera-name" label="Name" error={errors.name}>
          <Input
            id="camera-name"
            value={form.name}
            onChange={(event) => update("name", event.target.value)}
            placeholder="Front door"
            maxLength={100}
            autoFocus
            aria-invalid={Boolean(errors.name)}
          />
        </FormField>
        <FormField id="camera-location" label="Location">
          <Input
            id="camera-location"
            value={form.location}
            onChange={(event) => update("location", event.target.value)}
            placeholder="Optional"
            maxLength={100}
          />
        </FormField>
        <FormField id="camera-brand" label="Brand">
          <Select value={form.brand} onValueChange={(value) => update("brand", value as CameraBrand)}>
            <SelectTrigger id="camera-brand" className="font-mono text-xs">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {BRAND_ORDER.map((brand) => (
                <SelectItem key={brand} value={brand} className="font-mono text-xs">
                  {BRANDS[brand].label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </FormField>
        <FormField id="camera-host" label="Host" error={errors.host}>
          <Input
            id="camera-host"
            value={form.host}
            onChange={(event) => update("host", event.target.value)}
            placeholder="192.168.1.100"
            className="font-data"
            maxLength={255}
            autoComplete="off"
            spellCheck={false}
            aria-invalid={Boolean(errors.host)}
          />
        </FormField>
        <FormField id="camera-rtsp-port" label="RTSP port" error={errors.rtspPort}>
          <Input
            id="camera-rtsp-port"
            value={form.rtspPort}
            onChange={(event) => update("rtspPort", event.target.value)}
            placeholder="554"
            inputMode="numeric"
            className="font-data"
            aria-invalid={Boolean(errors.rtspPort)}
          />
        </FormField>
        <FormField id="camera-onvif-port" label="ONVIF port" error={errors.onvifPort}>
          <Input
            id="camera-onvif-port"
            value={form.onvifPort}
            onChange={(event) => update("onvifPort", event.target.value)}
            placeholder={defaults.onvifPort ? String(defaults.onvifPort) : "None"}
            inputMode="numeric"
            className="font-data"
            aria-invalid={Boolean(errors.onvifPort)}
          />
        </FormField>
        <FormField id="camera-username" label="Username">
          <Input
            id="camera-username"
            value={form.username}
            onChange={(event) => update("username", event.target.value)}
            placeholder={defaults.username ?? "None"}
            className="font-data"
            maxLength={100}
            autoComplete="off"
            spellCheck={false}
          />
        </FormField>
        <FormField id="camera-password" label="Password" hint={passwordHint}>
          <Input
            id="camera-password"
            type="password"
            value={form.password}
            onChange={(event) => update("password", event.target.value)}
            placeholder={camera?.has_password ? (form.clearPassword ? "Removed on save" : "Saved") : "None"}
            disabled={form.clearPassword}
            autoComplete="new-password"
          />
        </FormField>
        <FormField id="camera-main-path" label="Main path" error={errors.mainPath} className="sm:col-span-2">
          <Input
            id="camera-main-path"
            value={form.mainPath}
            onChange={(event) => update("mainPath", event.target.value)}
            placeholder={defaults.mainPath ?? (defaults.mainRequired ? "/stream1" : "Resolved through ONVIF")}
            className="font-data"
            maxLength={255}
            spellCheck={false}
            aria-invalid={Boolean(errors.mainPath)}
          />
        </FormField>
        <FormField id="camera-sub-path" label="Sub path" className="sm:col-span-2">
          <Input
            id="camera-sub-path"
            value={form.subPath}
            onChange={(event) => update("subPath", event.target.value)}
            placeholder={defaults.subPath ?? (form.brand === "onvif" ? "Resolved through ONVIF" : "None")}
            className="font-data"
            maxLength={255}
            spellCheck={false}
          />
        </FormField>
        <FormField
          id="camera-device-host"
          label="Device address"
          hint="The camera's own address when its stream comes through a bridge, so Discover knows it is added."
          className="sm:col-span-2"
        >
          <Input
            id="camera-device-host"
            value={form.deviceHost}
            onChange={(event) => update("deviceHost", event.target.value)}
            placeholder="None"
            className="font-data"
            maxLength={255}
            autoComplete="off"
            spellCheck={false}
          />
        </FormField>
        <div className="flex flex-col gap-2 rounded-md border border-hairline p-3 sm:col-span-2">
          <div className="flex items-center justify-between gap-3">
            <div className="flex min-w-0 flex-col gap-0.5">
              <span className="text-[13px] text-foreground">Detect from the device</span>
              <span className="text-[12px] text-text-3">
                Reads the ONVIF profiles and fills the paths and PTZ.
              </span>
            </div>
            <Button type="button" variant="outline" size="sm" onClick={detect} disabled={detecting}>
              {detecting ? <Spinner className="size-3.5" /> : <ScanSearchIcon />}
              Detect
            </Button>
          </div>
          {detectError ? <p className="font-mono text-[11px] break-all text-danger">{detectError}</p> : null}
          {detected ? (
            <div className="flex flex-col gap-1 border-t border-hairline pt-2 font-data text-[11px] text-text-2">
              <span>
                {[detected.manufacturer, detected.model, detected.firmware].filter(Boolean).join(", ") ||
                  "Unknown device"}
                {detected.ptz ? ", PTZ" : ""}
              </span>
              {detected.profiles.map((profile) => (
                <span key={profile.token} className="truncate text-text-3">
                  {profile.name || profile.token}: {profile.encoding ?? "?"}
                  {profile.width && profile.height ? ` ${profile.width}x${profile.height}` : ""}
                  {profile.stream_uri ? ` ${splitStreamUri(profile.stream_uri)?.path ?? ""}` : ""}
                </span>
              ))}
            </div>
          ) : null}
        </div>
        <div className="flex items-start justify-between gap-3">
          <div className="flex flex-col gap-0.5">
            <Label htmlFor="camera-lenses" className="text-[13px] text-foreground">
              Lenses
            </Label>
            <span className="text-[12px] text-text-3">Pictures stacked in one frame, 2 for dual-lens cameras</span>
          </div>
          <Select value={form.lenses} onValueChange={(value) => update("lenses", value)}>
            <SelectTrigger id="camera-lenses" className="w-20 font-mono text-xs">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {["1", "2", "3", "4"].map((count) => (
                <SelectItem key={count} value={count} className="font-mono text-xs">
                  {count}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        <div className="flex items-start justify-between gap-3">
          <div className="flex flex-col gap-0.5">
            <Label htmlFor="camera-ptz" className="text-[13px] text-foreground">
              PTZ
            </Label>
            <span className="text-[12px] text-text-3">
              {form.ptz === null && defaults.ptz === null ? "Taken from the device" : "Pan, tilt and zoom controls"}
            </span>
          </div>
          <Switch id="camera-ptz" checked={ptzChecked} onCheckedChange={(value) => update("ptz", value)} />
        </div>
        <div className="flex items-start justify-between gap-3">
          <div className="flex flex-col gap-0.5">
            <Label htmlFor="camera-enabled" className="text-[13px] text-foreground">
              Enabled
            </Label>
            <span className="text-[12px] text-text-3">Streams and shows on the wall</span>
          </div>
          <Switch
            id="camera-enabled"
            checked={form.enabled}
            onCheckedChange={(value) => update("enabled", value)}
          />
        </div>
        {formError ? (
          <p role="alert" className="text-[13px] text-danger sm:col-span-2">
            {formError}
          </p>
        ) : null}
      </DialogBody>
      <DialogFooter>
        <Button type="button" variant="outline" onClick={onCancel} disabled={saving}>
          Cancel
        </Button>
        <Button type="submit" disabled={saving}>
          {saving ? <Spinner className="size-3.5 text-primary-foreground" /> : null}
          {editing ? "Save changes" : "Add camera"}
        </Button>
      </DialogFooter>
    </form>
  )
}

export function CameraFormDialog({
  open,
  onOpenChange,
  camera,
  prefill,
  onSaved,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  camera?: Camera | null
  prefill?: CameraPrefill | null
  onSaved: (camera: Camera) => void
}) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-xl">
        <CameraForm
          camera={camera}
          prefill={prefill}
          onCancel={() => onOpenChange(false)}
          onSaved={(saved) => {
            onSaved(saved)
            onOpenChange(false)
          }}
        />
      </DialogContent>
    </Dialog>
  )
}
