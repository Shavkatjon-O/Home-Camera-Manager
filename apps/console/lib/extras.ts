import { request } from "@/lib/api"

export const EXTRA_KIND_LABELS: Record<string, string> = {
  object_left: "Object left",
  object_taken: "Object taken",
  fall: "Fall",
  animal: "Animal",
}

export const BETA_KINDS: string[] = ["fall"]

export const TAMPER_SUBTYPE_LABELS: Record<string, string> = {
  covered: "Covered",
  blurred: "Blurred",
  dark: "Too dark",
  moved: "Moved",
}

export const EXTRA_OBJECT_LABELS: Record<string, string> = {
  bird: "Bird",
  backpack: "Backpack",
  handbag: "Handbag",
  suitcase: "Suitcase",
}

export function kindLabel(kind: string): string | null {
  return EXTRA_KIND_LABELS[kind] ?? null
}

export function isBetaKind(kind: string): boolean {
  return BETA_KINDS.includes(kind)
}

export function tamperLabel(subtype: string): string | null {
  return TAMPER_SUBTYPE_LABELS[subtype] ?? null
}

export interface JourneyStep {
  view_uuid: string
  view_name: string
  camera_uuid: string
  camera_name: string
  track: number | string | null
  started_at: string
  ended_at: string | null
  similarity: number | null
  event_uuid: string | null
}

export interface Journey {
  uuid: string
  description: string
  started_at: string
  ended_at: string | null
  steps: JourneyStep[]
}

export interface SimilarAppearance {
  uuid: string
  view_uuid: string
  view_name: string
  camera_uuid: string
  camera_name: string
  started_at: string
  ended_at: string | null
  similarity: number
  journey_uuid: string | null
  event_uuid: string | null
}

export interface SimilarAppearances {
  query_uuid: string
  items: SimilarAppearance[]
}

export function fetchEventJourney(eventUuid: string, signal?: AbortSignal): Promise<Journey> {
  return request<Journey>(`/analytics/journeys/event/${encodeURIComponent(eventUuid)}`, { signal })
}

export function findSimilarAppearances(
  eventUuid: string,
  options: { limit?: number; start?: string; end?: string; signal?: AbortSignal } = {},
): Promise<SimilarAppearances> {
  const { limit = 20, start, end, signal } = options
  return request<SimilarAppearances>("/analytics/appearances/similar", {
    method: "POST",
    body: { event_uuid: eventUuid, limit, ...(start ? { start } : {}), ...(end ? { end } : {}) },
    signal,
  })
}
