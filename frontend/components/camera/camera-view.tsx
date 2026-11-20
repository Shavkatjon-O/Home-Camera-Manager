"use client"

import * as React from "react"
import Link from "next/link"
import { useSearchParams } from "next/navigation"
import {
  CircleAlertIcon,
  CctvOffIcon,
  MaximizeIcon,
  MinimizeIcon,
  PencilIcon,
  RefreshCwIcon,
  ScanSearchIcon,
  Volume2Icon,
  VolumeXIcon,
} from "lucide-react"
import { toast } from "sonner"

import { AnalyticsSection } from "@/components/analytics/analytics-section"
import { LiveObjects } from "@/components/analytics/live-objects"
import { useAnalyticsViews } from "@/components/analytics/use-analytics-views"
import { ZoneEditor } from "@/components/analytics/zone-editor"
import { CameraDetails } from "@/components/camera/camera-details"
import { CameraEvents } from "@/components/camera/camera-events"
import {
  DeviceSection,
  ExtrasSection,
  ImageSection,
  MotionSection,
  PresetsSection,
  RecordingsSection,
  VideoSection,
} from "@/components/camera/control-sections"
import { PtzPad } from "@/components/camera/ptz-pad"
import { usePtz, usePtzKeyboard } from "@/components/camera/use-ptz"
import { CameraFormDialog } from "@/components/cameras/camera-form-dialog"
import { AppFrame } from "@/components/shell/app-frame"
import { IconButton } from "@/components/shell/icon-button"
import { Chip, EmptyState, LoadingState, Spinner, StatusDot } from "@/components/shell/primitives"
import { Segmented } from "@/components/shell/segmented"
import { useSession } from "@/components/shell/session"
import { Button } from "@/components/ui/button"
import { VideoPlaceholder } from "@/components/video/video-placeholder"
import { VideoStream } from "@/components/video/video-stream"
import { viewForLens } from "@/lib/analytics"
import { ApiError, api, errorMessage, isAbort } from "@/lib/api"
import { toggleFullscreen, useFullscreenElement } from "@/lib/stores"
import type { Camera, CameraAudio } from "@/lib/types"

const POLL_MS = 10000

type Quality = "main" | "sub"

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="flex flex-col gap-3 border-b border-hairline px-4 py-4 last:border-b-0">
      <h2 className="text-xs text-text-3">{title}</h2>
      {children}
    </section>
  )
}

function CameraView({ id }: { id: string }) {
  const { refresh: refreshSession } = useSession()
  const [camera, setCamera] = React.useState<Camera | null>(null)
  const [error, setError] = React.useState<Error | null>(null)
  const [reload, setReload] = React.useState(0)
  const [quality, setQuality] = React.useState<Quality>("main")
  const [lensView, setLensView] = React.useState("all")
  const [speed, setSpeed] = React.useState(0.5)
  const [checking, setChecking] = React.useState(false)
  const [editing, setEditing] = React.useState(false)
  const [player, setPlayer] = React.useState<HTMLDivElement | null>(null)
  const [audio, setAudio] = React.useState<CameraAudio | null>(null)
  const [sound, setSound] = React.useState(false)
  const [showObjects, setShowObjects] = React.useState(false)
  const [editingView, setEditingView] = React.useState<string | null>(null)
  const viewRef = React.useRef<HTMLDivElement>(null)
  const analytics = useAnalyticsViews(id)
  const fullscreen = useFullscreenElement()
  const ptz = usePtz(id, speed)
  const keyboard = usePtzKeyboard(camera?.ptz_enabled ? ptz : null)

  React.useEffect(() => {
    const controller = new AbortController()
    let timer = 0
    const load = async () => {
      try {
        const data = await api.getCamera(id, controller.signal)
        setCamera(data)
        setError(null)
      } catch (err) {
        if (isAbort(err)) return
        setError(err instanceof Error ? err : new Error(errorMessage(err)))
        if (err instanceof ApiError && err.status === 404) return
      }
      if (!controller.signal.aborted) timer = window.setTimeout(load, POLL_MS)
    }
    void load()
    return () => {
      controller.abort()
      window.clearTimeout(timer)
    }
  }, [id, reload])

  React.useEffect(() => {
    const controller = new AbortController()
    api
      .cameraAudio(id, controller.signal)
      .then(setAudio)
      .catch(() => undefined)
    return () => controller.abort()
  }, [id])

  const name = camera?.name
  React.useEffect(() => {
    if (name) document.title = `${name} - Smart Surveillance`
  }, [name])

  const ptzEnabled = camera?.ptz_enabled ?? false
  React.useEffect(() => {
    if (ptzEnabled) viewRef.current?.focus({ preventScroll: true })
  }, [ptzEnabled])

  const check = async () => {
    setChecking(true)
    try {
      const data = await api.checkCamera(id)
      setCamera(data)
      toast.success(data.status.online ? `${data.name} is online` : `${data.name} is offline`)
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setChecking(false)
    }
  }

  const onFullscreen = async () => {
    const ok = await toggleFullscreen(player)
    if (!ok) toast.error("Fullscreen is not available in this browser")
  }

  const hasSub = Boolean(camera?.streams.sub)
  const activeQuality: Quality = quality === "sub" && hasSub ? "sub" : "main"
  const stream = camera ? (activeQuality === "sub" ? camera.streams.sub : camera.streams.main) : null
  const isFullscreen = player !== null && fullscreen === player
  const analyticsViews = analytics.views ?? []
  const detecting = analyticsViews.some((view) => view.enabled)
  const editingZones = editingView ? (analyticsViews.find((view) => view.uuid === editingView) ?? null) : null

  const objectsFor = (lens: number | null): React.ReactNode => {
    if (!showObjects || !detecting || !camera) return null
    const view = viewForLens(analyticsViews, camera.lenses, lens)
    if (!view || !view.enabled) return null
    return <LiveObjects key={view.uuid} viewUuid={view.uuid} />
  }

  if (!camera) {
    const notFound = error instanceof ApiError && error.status === 404
    return (
      <AppFrame>
        <main className="min-w-0 flex-1">
          {notFound ? (
            <EmptyState icon={<CctvOffIcon />} title="Camera not found">
              <span>It may have been deleted.</span>
              <Button asChild variant="outline">
                <Link href="/">Back to the wall</Link>
              </Button>
            </EmptyState>
          ) : error ? (
            <EmptyState icon={<CircleAlertIcon />} title="Cannot load the camera">
              <span className="font-data text-xs">{error.message}</span>
              <Button variant="outline" onClick={() => setReload((value) => value + 1)}>
                Try again
              </Button>
            </EmptyState>
          ) : (
            <LoadingState label="Loading camera" />
          )}
        </main>
      </AppFrame>
    )
  }

  const actions = (
    <>
      <Segmented<Quality>
        label="Stream quality"
        value={activeQuality}
        options={[
          { value: "main", label: "Main" },
          { value: "sub", label: "Sub", disabled: !hasSub },
        ]}
        onChange={setQuality}
      />
      {camera.lenses > 1 ? (
        <Segmented<string>
          label="Lenses"
          value={lensView}
          options={[
            { value: "all", label: camera.lenses === 2 ? "Both" : "All" },
            ...Array.from({ length: camera.lenses }, (_, lens) => ({ value: String(lens), label: `Lens ${lens + 1}` })),
          ]}
          onChange={setLensView}
        />
      ) : null}
      <IconButton
        label={
          detecting
            ? showObjects
              ? "Hide detected objects"
              : "Show detected objects"
            : "Turn on analytics to show detected objects"
        }
        aria-pressed={showObjects && detecting}
        disabled={!detecting || !camera.enabled}
        onClick={() => setShowObjects((value) => !value)}
      >
        <ScanSearchIcon />
      </IconButton>
      <IconButton
        label={
          audio?.supported ? (sound ? "Mute" : "Turn sound on") : (audio?.reason ?? "Sound is not available")
        }
        aria-pressed={sound}
        disabled={!audio?.supported || !camera.enabled}
        onClick={() => setSound((value) => !value)}
      >
        {sound && audio?.supported ? <Volume2Icon /> : <VolumeXIcon />}
      </IconButton>
      <IconButton
        label={isFullscreen ? "Exit fullscreen" : "Fullscreen"}
        disabled={!camera.enabled}
        onClick={onFullscreen}
      >
        {isFullscreen ? <MinimizeIcon /> : <MaximizeIcon />}
      </IconButton>
    </>
  )

  let video: React.ReactNode
  if (!camera.enabled) {
    video = <VideoPlaceholder title="This camera is disabled" detail="Enable it to stream and show it on the wall." />
  } else if (camera.status.online === false) {
    video = <VideoPlaceholder title="Camera offline" detail={camera.status.error} />
  } else if (stream && camera.lenses > 1 && lensView !== "all") {
    const lens = Number(lensView)
    video = (
      <VideoStream
        key={`${stream}-${lens}`}
        stream={stream}
        lens={lens}
        lenses={camera.lenses}
        overlay={objectsFor(lens)}
        className="absolute inset-0"
      />
    )
  } else if (stream && camera.lenses > 1) {
    video = (
      <div className="absolute inset-0 flex flex-col gap-px bg-black landscape:flex-row">
        {Array.from({ length: camera.lenses }, (_, lens) => (
          <VideoStream
            key={`${stream}-${lens}`}
            stream={stream}
            snapshot={false}
            lens={lens}
            lenses={camera.lenses}
            overlay={objectsFor(lens)}
            className="min-h-0 min-w-0 flex-1"
          />
        ))}
      </div>
    )
  } else if (stream) {
    const withSound = sound && Boolean(audio?.supported)
    video = (
      <VideoStream
        key={stream}
        stream={stream}
        audio={withSound}
        overlay={objectsFor(null)}
        className="absolute inset-0"
      />
    )
  }

  return (
    <AppFrame
      actions={actions}
      wideActions
      status={error ? <Chip className="text-danger">Refresh failed</Chip> : null}
    >
      <div
        ref={viewRef}
        tabIndex={-1}
        onKeyDown={keyboard.onKeyDown}
        onKeyUp={keyboard.onKeyUp}
        onBlur={keyboard.onBlur}
        className="flex min-h-0 min-w-0 flex-1 flex-col outline-none focus-visible:shadow-none md:flex-row"
      >
        <main className="relative h-[45dvh] shrink-0 bg-black md:h-auto md:min-h-0 md:min-w-0 md:flex-1">
          <div ref={setPlayer} className="absolute inset-0 bg-black">
            {video}
            <div className="pointer-events-none absolute bottom-2 left-2 flex max-w-[calc(100%-1rem)] items-center gap-2 rounded-md bg-black/60 px-2 py-1">
              <StatusDot online={camera.status.online} />
              <span className="truncate text-[12px] text-white">{camera.name}</span>
              <span className="font-mono text-[11px] text-white/55">{activeQuality === "main" ? "Main" : "Sub"}</span>
            </div>
          </div>
        </main>
        <aside className="flex min-h-0 flex-1 flex-col overflow-y-auto border-t border-hairline md:w-[300px] md:flex-none md:border-t-0 md:border-l">
          <div className="flex items-start justify-between gap-3 border-b border-hairline px-4 py-4">
            <div className="flex min-w-0 flex-col gap-0.5">
              <h1 className="truncate text-[15px] font-medium text-foreground">{camera.name}</h1>
              <span className="truncate text-[12px] text-text-3">{camera.location ?? "No location"}</span>
            </div>
            <div className="flex shrink-0 items-center gap-0.5">
              <IconButton label="Check now" size="icon-sm" disabled={checking} onClick={check}>
                {checking ? <Spinner className="size-3.5" /> : <RefreshCwIcon />}
              </IconButton>
              <IconButton label="Edit" size="icon-sm" onClick={() => setEditing(true)}>
                <PencilIcon />
              </IconButton>
            </div>
          </div>
          {camera.ptz_enabled ? (
            <Section title="PTZ">
              <PtzPad controls={ptz} speed={speed} onSpeedChange={setSpeed} />
            </Section>
          ) : null}
          {camera.ptz_enabled ? <PresetsSection cameraUuid={camera.uuid} /> : null}
          {camera.device_host ? <ExtrasSection cameraUuid={camera.uuid} /> : null}
          <Section title="Events">
            <CameraEvents cameraUuid={camera.uuid} />
          </Section>
          <AnalyticsSection
            views={analytics.views}
            error={analytics.error}
            onChange={analytics.replace}
            onEdit={setEditingView}
          />
          <RecordingsSection cameraUuid={camera.uuid} />
          <VideoSection cameraUuid={camera.uuid} />
          <ImageSection cameraUuid={camera.uuid} />
          <MotionSection cameraUuid={camera.uuid} />
          <DeviceSection cameraUuid={camera.uuid} />
          <Section title="Details">
            <CameraDetails camera={camera} />
          </Section>
        </aside>
      </div>
      {editingZones ? (
        <ZoneEditor
          key={editingZones.uuid}
          view={editingZones}
          onClose={() => setEditingView(null)}
          onSaved={analytics.replace}
        />
      ) : null}
      <CameraFormDialog
        open={editing}
        onOpenChange={setEditing}
        camera={camera}
        onSaved={(saved) => {
          setCamera(saved)
          void refreshSession()
        }}
      />
    </AppFrame>
  )
}

function CameraRoute() {
  const id = useSearchParams().get("id")
  if (!id) {
    return (
      <AppFrame>
        <main className="min-w-0 flex-1">
          <EmptyState icon={<CctvOffIcon />} title="No camera selected">
            <Button asChild variant="outline">
              <Link href="/">Back to the wall</Link>
            </Button>
          </EmptyState>
        </main>
      </AppFrame>
    )
  }
  return <CameraView key={id} id={id} />
}

export function CameraPage() {
  return (
    <React.Suspense
      fallback={
        <AppFrame>
          <main className="min-w-0 flex-1">
            <LoadingState label="Loading camera" />
          </main>
        </AppFrame>
      }
    >
      <CameraRoute />
    </React.Suspense>
  )
}
