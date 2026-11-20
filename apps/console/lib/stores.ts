"use client"

import { useCallback, useSyncExternalStore } from "react"

import { isWallLayout, type WallLayout } from "@/lib/grid"

const LAYOUT_KEY = "sss-wall-layout"
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

/** Sets the wall layout and remembers it in this browser. */
export function setWallLayout(value: WallLayout) {
  memoryLayout = value
  try {
    window.localStorage.setItem(LAYOUT_KEY, value)
  } catch {}
  layoutListeners.forEach((listener) => listener())
}

/** The wall layout this browser remembers. */
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

/** The element shown fullscreen, or null. */
export function useFullscreenElement(): Element | null {
  return useSyncExternalStore(subscribeFullscreen, currentFullscreen, () => null)
}

/** Shows an element fullscreen, or leaves fullscreen; resolves false when the browser cannot. */
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

/** The current time in whole seconds since the epoch, updated every second; 0 before the page is in a browser. */
export function useClockSeconds(): number {
  return useSyncExternalStore(subscribeClock, clockSnapshot, () => 0)
}

const SIDEBAR_KEY = "sss-sidebar-collapsed"
const sidebarListeners = new Set<() => void>()
let memorySidebar = false

function readSidebar(): boolean {
  try {
    const stored = window.localStorage.getItem(SIDEBAR_KEY)
    return stored === null ? memorySidebar : stored === "1"
  } catch {
    return memorySidebar
  }
}

function subscribeSidebar(listener: () => void) {
  sidebarListeners.add(listener)
  window.addEventListener("storage", listener)
  return () => {
    sidebarListeners.delete(listener)
    window.removeEventListener("storage", listener)
  }
}

/** Collapses the sidebar to its icon rail, or expands it, and remembers the choice in this browser. */
export function setSidebarCollapsed(value: boolean) {
  memorySidebar = value
  try {
    window.localStorage.setItem(SIDEBAR_KEY, value ? "1" : "0")
  } catch {}
  sidebarListeners.forEach((listener) => listener())
}

/** Whether this browser keeps the sidebar collapsed to its icon rail. */
export function useSidebarCollapsed(): boolean {
  return useSyncExternalStore(subscribeSidebar, readSidebar, () => false)
}

/** Whether the viewport matches a media query, following changes; false before the page is in a browser. */
export function useMediaQuery(query: string): boolean {
  const subscribe = useCallback(
    (listener: () => void) => {
      const list = window.matchMedia(query)
      list.addEventListener("change", listener)
      return () => list.removeEventListener("change", listener)
    },
    [query],
  )
  return useSyncExternalStore(subscribe, () => window.matchMedia(query).matches, () => false)
}
