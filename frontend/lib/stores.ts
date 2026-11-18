"use client"

import { useSyncExternalStore } from "react"

import { isWallLayout, type WallLayout } from "@/lib/grid"

const LAYOUT_KEY = "hc-wall-layout"
const layoutListeners = new Set<() => void>()
let memoryLayout: WallLayout = "auto"

function readLayout(): WallLayout {
  try {
    const stored = window.localStorage.getItem(LAYOUT_KEY)
    return isWallLayout(stored) ? stored : memoryLayout
  } catch {
    return memoryLayout
  }
}

function subscribeLayout(listener: () => void) {
  layoutListeners.add(listener)
  window.addEventListener("storage", listener)
  return () => {
    layoutListeners.delete(listener)
    window.removeEventListener("storage", listener)
  }
}

export function setWallLayout(value: WallLayout) {
  memoryLayout = value
  try {
    window.localStorage.setItem(LAYOUT_KEY, value)
  } catch {}
  layoutListeners.forEach((listener) => listener())
}

export function useWallLayout(): WallLayout {
  return useSyncExternalStore(subscribeLayout, readLayout, () => "auto")
}

interface WebkitDocument extends Document {
  webkitFullscreenElement?: Element | null
  webkitExitFullscreen?: () => Promise<void> | void
}

interface WebkitElement extends HTMLElement {
  webkitRequestFullscreen?: () => Promise<void> | void
}

interface WebkitVideo extends HTMLVideoElement {
  webkitEnterFullscreen?: () => void
}

function currentFullscreen(): Element | null {
  const doc = document as WebkitDocument
  return doc.fullscreenElement ?? doc.webkitFullscreenElement ?? null
}

function subscribeFullscreen(listener: () => void) {
  document.addEventListener("fullscreenchange", listener)
  document.addEventListener("webkitfullscreenchange", listener)
  return () => {
    document.removeEventListener("fullscreenchange", listener)
    document.removeEventListener("webkitfullscreenchange", listener)
  }
}

export function useFullscreenElement(): Element | null {
  return useSyncExternalStore(subscribeFullscreen, currentFullscreen, () => null)
}

export async function toggleFullscreen(element: HTMLElement | null): Promise<boolean> {
  if (!element) return false
  const doc = document as WebkitDocument
  const active = currentFullscreen()
  try {
    if (active === element) {
      if (doc.exitFullscreen) await doc.exitFullscreen()
      else await doc.webkitExitFullscreen?.()
      return true
    }
    const target = element as WebkitElement
    if (target.requestFullscreen) {
      await target.requestFullscreen()
      return true
    }
    if (target.webkitRequestFullscreen) {
      await target.webkitRequestFullscreen()
      return true
    }
    const video = element.querySelector("video") as WebkitVideo | null
    if (video?.webkitEnterFullscreen) {
      video.webkitEnterFullscreen()
      return true
    }
  } catch {
    return false
  }
  return false
}

function subscribeClock(listener: () => void) {
  const id = window.setInterval(listener, 250)
  return () => window.clearInterval(id)
}

function clockSnapshot(): number {
  return Math.floor(Date.now() / 1000)
}

export function useClockSeconds(): number {
  return useSyncExternalStore(subscribeClock, clockSnapshot, () => 0)
}
