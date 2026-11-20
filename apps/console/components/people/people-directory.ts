"use client"

import { useSyncExternalStore } from "react"

import { errorMessage } from "@/lib/api"
import { listAllPeople, personBrief, type PersonBrief } from "@/lib/people"

export interface PeopleDirectory {
  people: PersonBrief[]
  byUuid: Map<string, PersonBrief>
  loaded: boolean
  error: string | null
}

const STALE_MS = 300000
const MISS_REFRESH_MS = 5000

const EMPTY: PeopleDirectory = { people: [], byUuid: new Map(), loaded: false, error: null }

let current: PeopleDirectory = EMPTY
let loadedAt = 0
let attemptedAt = 0
let inflight: Promise<void> | null = null
const listeners = new Set<() => void>()

function publish(next: PeopleDirectory) {
  current = next
  listeners.forEach((listener) => listener())
}

export function refreshPeopleDirectory(): Promise<void> {
  if (inflight) return inflight
  attemptedAt = Date.now()
  inflight = listAllPeople()
    .then((people) => {
      const briefs = people.map(personBrief).sort((a, b) => a.name.localeCompare(b.name))
      loadedAt = Date.now()
      publish({ people: briefs, byUuid: new Map(briefs.map((item) => [item.uuid, item])), loaded: true, error: null })
    })
    .catch((err: unknown) => {
      publish({ ...current, loaded: true, error: errorMessage(err) })
    })
    .finally(() => {
      inflight = null
    })
  return inflight
}

export function ensurePeopleDirectory() {
  if (Date.now() - loadedAt > STALE_MS && Date.now() - attemptedAt > MISS_REFRESH_MS) void refreshPeopleDirectory()
}

export function resolvePerson(uuid: string) {
  if (current.byUuid.has(uuid)) {
    ensurePeopleDirectory()
    return
  }
  if (Date.now() - attemptedAt < MISS_REFRESH_MS) return
  void refreshPeopleDirectory()
}

function subscribeQuiet(listener: () => void) {
  listeners.add(listener)
  return () => {
    listeners.delete(listener)
  }
}

function subscribeLoading(listener: () => void) {
  listeners.add(listener)
  ensurePeopleDirectory()
  return () => {
    listeners.delete(listener)
  }
}

function snapshot(): PeopleDirectory {
  return current
}

function serverSnapshot(): PeopleDirectory {
  return EMPTY
}

export function usePeopleDirectory(autoload = true): PeopleDirectory {
  return useSyncExternalStore(autoload ? subscribeLoading : subscribeQuiet, snapshot, serverSnapshot)
}
