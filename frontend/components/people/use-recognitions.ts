"use client"

import * as React from "react"

import { useEvents } from "@/components/events/events-provider"
import { resolvePerson, usePeopleDirectory } from "@/components/people/people-directory"

export const RECOGNITION_WINDOW_MS = 8000

export interface Recognition {
  person_uuid: string
  name: string
  color: string
  event_uuid: string
}

interface Hit {
  camera: string
  event: string
  person: string
  at: number
}

export function useRecognitions(cameraUuid: string): Recognition[] {
  const { subscribe } = useEvents()
  const directory = usePeopleDirectory(false)
  const [hits, setHits] = React.useState<Hit[]>([])

  React.useEffect(
    () =>
      subscribe((event) => {
        if (event.camera_uuid !== cameraUuid) return
        const at = Date.now()
        const kind: string = event.kind
        const person =
          kind === "face_known" && typeof event.details.person_uuid === "string" ? event.details.person_uuid : null
        setHits((current) => {
          const kept = current.filter((hit) => hit.event !== event.uuid && at - hit.at < RECOGNITION_WINDOW_MS)
          if (person) return [...kept, { camera: event.camera_uuid, event: event.uuid, person, at }]
          return kept.length === current.length ? current : kept
        })
        if (person) resolvePerson(person)
      }),
    [subscribe, cameraUuid],
  )

  React.useEffect(() => {
    if (hits.length === 0) return
    const oldest = Math.min(...hits.map((hit) => hit.at))
    const timer = window.setTimeout(
      () => {
        const now = Date.now()
        setHits((current) => current.filter((hit) => now - hit.at < RECOGNITION_WINDOW_MS))
      },
      Math.max(0, oldest + RECOGNITION_WINDOW_MS - Date.now()) + 20,
    )
    return () => window.clearTimeout(timer)
  }, [hits])

  return React.useMemo(() => {
    const seen = new Set<string>()
    const result: Recognition[] = []
    for (let index = hits.length - 1; index >= 0; index -= 1) {
      const hit = hits[index]
      if (hit.camera !== cameraUuid || seen.has(hit.person)) continue
      const person = directory.byUuid.get(hit.person)
      if (!person) continue
      seen.add(hit.person)
      result.push({ person_uuid: hit.person, name: person.name, color: person.color, event_uuid: hit.event })
    }
    return result
  }, [hits, directory, cameraUuid])
}
