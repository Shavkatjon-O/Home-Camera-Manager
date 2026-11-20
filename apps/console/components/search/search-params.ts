import { dayRange } from "@/lib/events"
import type { SearchQuery } from "@/lib/people"

export type DateMode = "day" | "range"

export type Layout = "list" | "grid"

export const LIST_KEYS = ["camera", "view", "kind", "label", "zone", "line"] as const

export type ListKey = (typeof LIST_KEYS)[number]

export interface SearchFilters {
  dates: DateMode
  day: string
  from: string
  to: string
  camera: string[]
  view: string[]
  kind: string[]
  label: string[]
  zone: string[]
  line: string[]
  person: string | null
  cluster: string | null
  alert: boolean
}

export interface SearchState {
  filters: SearchFilters
  page: number
  layout: Layout
  similar: string | null
  similarEvent: string | null
  appearance: string | null
}

export const EMPTY_FILTERS: SearchFilters = {
  dates: "day",
  day: "",
  from: "",
  to: "",
  camera: [],
  view: [],
  kind: [],
  label: [],
  zone: [],
  line: [],
  person: null,
  cluster: null,
  alert: false,
}

interface ParamSource {
  get: (name: string) => string | null
  getAll: (name: string) => string[]
}

function unique(values: string[]): string[] {
  return Array.from(new Set(values.filter(Boolean)))
}

export function readSearchState(params: ParamSource): SearchState {
  const page = Number(params.get("page"))
  const dates: DateMode = params.get("dates") === "range" ? "range" : "day"
  const filters: SearchFilters = {
    dates,
    day: dates === "day" ? (params.get("day") ?? "") : "",
    from: dates === "range" ? (params.get("from") ?? "") : "",
    to: dates === "range" ? (params.get("to") ?? "") : "",
    camera: unique(params.getAll("camera")),
    view: unique(params.getAll("view")),
    kind: unique(params.getAll("kind")),
    label: unique(params.getAll("label")),
    zone: unique(params.getAll("zone")),
    line: unique(params.getAll("line")),
    person: params.get("person") || null,
    cluster: params.get("cluster") || null,
    alert: params.get("alert") === "true",
  }
  return {
    filters,
    page: Number.isInteger(page) && page > 1 ? page : 1,
    layout: params.get("layout") === "grid" ? "grid" : "list",
    similar: params.get("similar") || null,
    similarEvent: params.get("similar_event") || null,
    appearance: params.get("appearance") || null,
  }
}

export function searchHrefFor(state: SearchState): string {
  const search = new URLSearchParams()
  const { filters } = state
  if (filters.dates === "range") {
    search.set("dates", "range")
    if (filters.from) search.set("from", filters.from)
    if (filters.to) search.set("to", filters.to)
  } else if (filters.day) {
    search.set("day", filters.day)
  }
  LIST_KEYS.forEach((key) => filters[key].forEach((value) => search.append(key, value)))
  if (filters.person) search.set("person", filters.person)
  if (filters.cluster) search.set("cluster", filters.cluster)
  if (filters.alert) search.set("alert", "true")
  if (state.page > 1) search.set("page", String(state.page))
  if (state.layout === "grid") search.set("layout", "grid")
  if (state.similar) search.set("similar", state.similar)
  else if (state.similarEvent) search.set("similar_event", state.similarEvent)
  else if (state.appearance) search.set("appearance", state.appearance)
  const text = search.toString()
  return text ? `/search/?${text}` : "/search/"
}

function localMoment(value: string): string | undefined {
  if (!value) return undefined
  const date = new Date(value)
  return Number.isNaN(date.getTime()) ? undefined : date.toISOString()
}

export function filtersQuery(filters: SearchFilters): SearchQuery {
  const range = filters.dates === "day" && filters.day ? dayRange(filters.day) : null
  const query: SearchQuery = {
    from: filters.dates === "range" ? localMoment(filters.from) : range?.from,
    to: filters.dates === "range" ? localMoment(filters.to) : range?.to,
    person: filters.person ?? undefined,
    cluster: filters.cluster ?? undefined,
    alert: filters.alert || undefined,
  }
  LIST_KEYS.forEach((key) => {
    if (filters[key].length > 0) query[key] = filters[key]
  })
  return query
}

export function hasFilters(filters: SearchFilters): boolean {
  return (
    Boolean(filters.day || filters.from || filters.to || filters.person || filters.cluster || filters.alert) ||
    LIST_KEYS.some((key) => filters[key].length > 0)
  )
}
