"use client"

import * as React from "react"
import { CircleAlertIcon } from "lucide-react"

import { Spinner } from "@/components/shell/primitives"
import { errorMessage } from "@/lib/api"
import {
  STREAM_ERROR_EVENT,
  frameUrl,
  loadPlayer,
  streamSocketUrl,
  type VideoStreamElement,
} from "@/lib/player"
import { cn } from "@/lib/utils"

const RETRY_MS = 10000
const SNAPSHOT_TIMEOUT_MS = 8000

type Phase = "connecting" | "live" | "error"

const DEFAULT_ASPECT = 16 / 9

export function VideoStream({
  stream,
  snapshot = true,
  compact = false,
  lens = null,
  lenses = 1,
  audio = false,
  retry = true,
  overlay = null,
  className,
}: {
  stream: string
  snapshot?: boolean
  compact?: boolean
  lens?: number | null
  lenses?: number
  audio?: boolean
  retry?: boolean
  overlay?: React.ReactNode
  className?: string
}) {
  const holderRef = React.useRef<HTMLDivElement>(null)
  const [phase, setPhase] = React.useState<Phase>("connecting")
  const [message, setMessage] = React.useState<string | null>(null)
  const [attempt, setAttempt] = React.useState(0)
  const [poster, setPoster] = React.useState<string | null>(null)
  const [frame, setFrame] = React.useState<{ width: number; height: number } | null>(null)
  const snapshotAbort = React.useRef<AbortController | null>(null)

  React.useEffect(() => {
    if (!snapshot) return
    const controller = new AbortController()
    snapshotAbort.current = controller
    const timer = window.setTimeout(() => controller.abort(), SNAPSHOT_TIMEOUT_MS)
    let objectUrl: string | null = null
    fetch(frameUrl(stream), { signal: controller.signal, credentials: "same-origin", cache: "no-store" })
      .then((res) => (res.ok ? res.blob() : null))
      .then((blob) => {
        if (!blob || blob.size === 0 || controller.signal.aborted) return
        objectUrl = URL.createObjectURL(blob)
        setPoster(objectUrl)
      })
      .catch(() => undefined)
      .finally(() => window.clearTimeout(timer))
    return () => {
      controller.abort()
      window.clearTimeout(timer)
      if (objectUrl) URL.revokeObjectURL(objectUrl)
    }
  }, [stream, snapshot])

  React.useEffect(() => {
    const holder = holderRef.current
    if (!holder) return
    let cancelled = false
    let element: VideoStreamElement | null = null
    let video: HTMLVideoElement | null = null
    let retryTimer = 0

    const scheduleRetry = () => {
      window.clearTimeout(retryTimer)
      if (!retry) return
      retryTimer = window.setTimeout(() => {
        setPhase("connecting")
        setAttempt((value) => value + 1)
      }, RETRY_MS)
    }
    const onPlaying = () => {
      window.clearTimeout(retryTimer)
      snapshotAbort.current?.abort()
      setPhase("live")
      setMessage(null)
    }
    const onMetadata = () => {
      if (video && video.videoWidth > 0 && video.videoHeight > 0) {
        setFrame({ width: video.videoWidth, height: video.videoHeight })
      }
    }
    const onEmptied = () => {
      setPhase((current) => (current === "live" ? "connecting" : current))
    }
    const onStreamError = (event: Event) => {
      setPhase("error")
      setMessage((event as CustomEvent<string>).detail || null)
      scheduleRetry()
    }

    loadPlayer()
      .then(() => {
        if (cancelled) return
        element = document.createElement("video-stream") as VideoStreamElement
        element.mode = "mse"
        element.media = audio ? "video,audio" : "video"
        element.background = false
        element.src = streamSocketUrl(stream)
        element.addEventListener(STREAM_ERROR_EVENT, onStreamError)
        holder.appendChild(element)
        video = element.video
        if (video && audio) video.muted = false
        video?.addEventListener("playing", onPlaying)
        video?.addEventListener("emptied", onEmptied)
        video?.addEventListener("loadedmetadata", onMetadata)
        video?.addEventListener("resize", onMetadata)
      })
      .catch((err: unknown) => {
        if (cancelled) return
        setPhase("error")
        setMessage(errorMessage(err))
        scheduleRetry()
      })

    return () => {
      cancelled = true
      window.clearTimeout(retryTimer)
      if (video) {
        video.removeEventListener("playing", onPlaying)
        video.removeEventListener("emptied", onEmptied)
        video.removeEventListener("loadedmetadata", onMetadata)
        video.removeEventListener("resize", onMetadata)
      }
      if (element) {
        element.removeEventListener(STREAM_ERROR_EVENT, onStreamError)
        if (element.video) element.ondisconnect()
        element.remove()
      }
    }
  }, [stream, attempt, audio, retry])

  const showPoster = snapshot && poster !== null && phase !== "live"
  const cropped = lenses > 1 && lens !== null
  const lensIndex = lens ?? 0
  const aspect = frame ? frame.width / (frame.height / lenses) : DEFAULT_ASPECT
  const fullAspect = frame ? frame.width / frame.height : DEFAULT_ASPECT
  const band = cropped ? (lensIndex / (lenses - 1)) * 100 : 0
  const showOverlay = overlay !== null && frame !== null

  return (
    <div
      className={cn("relative overflow-hidden bg-black", className)}
      style={cropped || showOverlay ? { containerType: "size" } : undefined}
    >
      {cropped ? (
        <div className="absolute inset-0 flex items-center justify-center">
          <div
            className="relative overflow-hidden"
            style={{
              width: `min(100cqw, calc(100cqh * ${aspect}))`,
              height: `min(100cqh, calc(100cqw / ${aspect}))`,
            }}
          >
            {showPoster ? (
              <div
                aria-hidden
                className="absolute inset-0 bg-no-repeat"
                style={{
                  backgroundImage: `url(${poster})`,
                  backgroundSize: `100% ${lenses * 100}%`,
                  backgroundPosition: `0% ${band}%`,
                }}
              />
            ) : null}
            <div
              ref={holderRef}
              className="absolute left-0 w-full [&_video]:object-fill"
              style={{ height: `${lenses * 100}%`, top: `${-lensIndex * 100}%` }}
            />
            {showOverlay ? <div className="pointer-events-none absolute inset-0">{overlay}</div> : null}
          </div>
        </div>
      ) : (
        <>
          {showPoster ? (
            <div
              aria-hidden
              className="absolute inset-0 bg-contain bg-center bg-no-repeat"
              style={{ backgroundImage: `url(${poster})` }}
            />
          ) : null}
          <div ref={holderRef} className="absolute inset-0" />
          {showOverlay ? (
            <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
              <div
                className="relative"
                style={{
                  width: `min(100cqw, calc(100cqh * ${fullAspect}))`,
                  height: `min(100cqh, calc(100cqw / ${fullAspect}))`,
                }}
              >
                {overlay}
              </div>
            </div>
          ) : null}
        </>
      )}
      {phase === "connecting" ? (
        <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
          <div className="flex items-center gap-2 rounded-md bg-black/60 px-2.5 py-1.5 font-mono text-[11px] text-white/70">
            <Spinner className="size-3.5 text-white/70" />
            Connecting
          </div>
        </div>
      ) : null}
      {phase === "error" ? (
        <div className="pointer-events-none absolute inset-0 flex items-center justify-center p-4">
          <div className="flex max-w-full flex-col items-center gap-1.5 rounded-md bg-black/70 px-3 py-2 text-center">
            <div className="flex items-center gap-1.5 text-[12px] text-white/90">
              <CircleAlertIcon aria-hidden className="size-3.5 text-status-err" />
              {retry ? "Stream unavailable, retrying" : "Stream unavailable"}
            </div>
            {message && !compact ? (
              <div className="line-clamp-2 max-w-md font-mono text-[11px] break-words text-white/50">{message}</div>
            ) : null}
          </div>
        </div>
      ) : null}
    </div>
  )
}
