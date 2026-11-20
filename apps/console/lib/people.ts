import { eventImageUrl, request } from "@/lib/api"
import { KIND_LABELS } from "@/lib/events"
import type { CameraEvent, EventKind, Page } from "@/lib/types"

export interface PersonColor {
  value: string
  name: string
}

export const PERSON_COLORS: PersonColor[] = [
  { value: "#4f8cff", name: "Blue" },
  { value: "#45c25f", name: "Green" },
  { value: "#f0a92e", name: "Amber" },
  { value: "#f2555a", name: "Red" },
  { value: "#b07cff", name: "Violet" },
  { value: "#2ec4c4", name: "Teal" },
  { value: "#ff7ab8", name: "Pink" },
  { value: "#c2a35a", name: "Sand" },
]

const COLOR_PATTERN = /^#[0-9a-fA-F]{6}$/

export const PERSON_NAME_MAX = 100
export const PERSON_NOTES_MAX = 1000

export type SampleSource = "upload" | "event"

export interface Sample {
  uuid: string
  source: SampleSource
  quality: number | null
  confidence: number | null
  seen_at: string | null
  has_crop: boolean
  event_uuid: string | null
  camera_uuid: string | null
  camera_name: string | null
  view_name: string | null
}

export interface Sighting {
  event_uuid: string
  sample_uuid: string | null
  camera_uuid: string | null
  camera_name: string | null
  view_name: string | null
  seen_at: string
  confidence: number | null
}

export interface Person {
  uuid: string
  name: string
  notes: string | null
  color: string
  sample_count: number
  upload_count: number
  samples: Sample[]
  last_seen_at: string | null
  sightings: Sighting[]
  created_at: string
  updated_at: string
}

export interface PersonCreate {
  name: string
  notes?: string | null
  color?: string
}

export interface PersonUpdate {
  name?: string
  notes?: string | null
  color?: string
}

export interface PhotoUpload {
  name: string
  data: string
}

export interface PhotoRejection {
  name: string
  reason: string
}

export interface PhotoResult {
  person: Person
  added: Sample[]
  rejected: PhotoRejection[]
}

export interface Cluster {
  uuid: string
  number: number
  label: string
  seen_count: number
  first_seen_at: string | null
  last_seen_at: string | null
  samples: Sample[]
  sightings: Sighting[]
  created_at: string
  updated_at: string
}

export interface ClusterNaming {
  person?: string
  name?: string
  color?: string
}

export type FaceStatus = "known" | "unknown"

export interface Face {
  status: FaceStatus
  person_uuid: string | null
  person_name: string | null
  person_color: string | null
  cluster_uuid: string | null
  cluster_label: string | null
  confidence: number | null
  sample_uuid: string | null
  has_crop: boolean
}

export type FaceIdentity = Pick<Face, "person_name" | "person_color" | "cluster_label">

export type FaceEventKind = "face_known" | "face_unknown"

export type SearchKind = EventKind | FaceEventKind

export interface SearchResult extends Omit<CameraEvent, "kind"> {
  kind: SearchKind
  face: Face | null
}

export interface SimilarFace {
  sample_uuid: string
  score: number
  source: SampleSource
  seen_at: string | null
  has_crop: boolean
  person_uuid: string | null
  person_name: string | null
  person_color: string | null
  cluster_uuid: string | null
  cluster_label: string | null
  event_uuid: string | null
  camera_uuid: string | null
  camera_name: string | null
  view_name: string | null
}

export interface SimilarPage {
  items: SimilarFace[]
  total: number
  page: number
  page_size: number
}

export interface SimilarQuery {
  sample?: string
  event?: string
  photo?: string
}

export interface FacetView {
  id: string
  name: string
  camera_uuid: string
}

export interface FacetZone {
  id: string
  name: string
  view: string
}

export interface FacetLine {
  id: string
  name: string
  view: string
}

export interface FacetPerson {
  uuid: string
  name: string
  color: string
}

export interface FacetCluster {
  uuid: string
  label: string
}

export interface Facets {
  kinds: string[]
  labels: string[]
  views: FacetView[]
  zones: FacetZone[]
  lines: FacetLine[]
  people: FacetPerson[]
  clusters: FacetCluster[]
}

export interface SearchQuery {
  from?: string
  to?: string
  camera?: string[]
  view?: string[]
  kind?: string[]
  label?: string[]
  zone?: string[]
  line?: string[]
  person?: string
  cluster?: string
  alert?: boolean
  page?: number
  page_size?: number
}

export interface PageParams {
  page?: number
  page_size?: number
}

export interface PersonBrief {
  uuid: string
  name: string
  color: string
  sample: string | null
  sample_count: number
}

type QueryValue = string | number | boolean | string[] | undefined

function segment(value: string): string {
  return encodeURIComponent(value)
}

function queryString(params: Record<string, QueryValue>): string {
  const search = new URLSearchParams()
  for (const [key, value] of Object.entries(params)) {
    if (value === undefined || value === false) continue
    if (Array.isArray(value)) value.forEach((item) => search.append(key, item))
    else search.set(key, String(value))
  }
  const text = search.toString()
  return text ? `?${text}` : ""
}

export const peopleApi = {
  listPeople: (params: PageParams = {}, signal?: AbortSignal) =>
    request<Page<Person>>(`/people${queryString({ ...params })}`, { signal }),
  getPerson: (uuid: string, signal?: AbortSignal) => request<Person>(`/people/${segment(uuid)}`, { signal }),
  createPerson: (data: PersonCreate) => request<Person>("/people", { method: "POST", body: data }),
  updatePerson: (uuid: string, data: PersonUpdate) =>
    request<Person>(`/people/${segment(uuid)}`, { method: "PATCH", body: data }),
  deletePerson: (uuid: string) => request<void>(`/people/${segment(uuid)}`, { method: "DELETE" }),
  addPhotos: (uuid: string, photos: PhotoUpload[]) =>
    request<PhotoResult>(`/people/${segment(uuid)}/photos`, { method: "POST", body: { photos } }),
  deleteSample: (uuid: string, sampleUuid: string) =>
    request<void>(`/people/${segment(uuid)}/samples/${segment(sampleUuid)}`, { method: "DELETE" }),
  mergePerson: (uuid: string, into: string) =>
    request<Person>(`/people/${segment(uuid)}/merge`, { method: "POST", body: { into } }),

  listClusters: (params: PageParams = {}, signal?: AbortSignal) =>
    request<Page<Cluster>>(`/people/clusters${queryString({ ...params })}`, { signal }),
  nameCluster: (uuid: string, data: ClusterNaming) =>
    request<Person>(`/people/clusters/${segment(uuid)}/name`, { method: "POST", body: data }),
  mergeCluster: (uuid: string, into: string) =>
    request<Cluster>(`/people/clusters/${segment(uuid)}/merge`, { method: "POST", body: { into } }),
  deleteCluster: (uuid: string) => request<void>(`/people/clusters/${segment(uuid)}`, { method: "DELETE" }),

  searchEvents: (params: SearchQuery = {}, signal?: AbortSignal) =>
    request<Page<SearchResult>>(`/search/events${queryString({ ...params })}`, { signal }),
  findSimilar: (query: SimilarQuery & PageParams, signal?: AbortSignal) =>
    request<SimilarPage>("/search/similar", { method: "POST", body: query, signal }),
  facets: (signal?: AbortSignal) => request<Facets>("/search/facets", { signal }),
}

const DIRECTORY_PAGE_SIZE = 100
const DIRECTORY_PAGES = 20

export async function listAllPeople(signal?: AbortSignal): Promise<Person[]> {
  const people: Person[] = []
  for (let page = 1; page <= DIRECTORY_PAGES; page += 1) {
    const result = await peopleApi.listPeople({ page, page_size: DIRECTORY_PAGE_SIZE }, signal)
    people.push(...result.items)
    if (result.items.length === 0 || people.length >= result.total) break
  }
  return people
}

export function personBrief(person: Person): PersonBrief {
  const sample = person.samples.find((item) => item.has_crop) ?? null
  return {
    uuid: person.uuid,
    name: person.name,
    color: person.color,
    sample: sample ? sample.uuid : null,
    sample_count: person.sample_count,
  }
}

export function sampleCropUrl(uuid: string): string {
  return `/api/v1/people/samples/${segment(uuid)}/crop`
}

export function faceCropUrl(face: Pick<Face, "sample_uuid" | "has_crop">, eventUuid?: string | null): string | null {
  if (!face.has_crop) return null
  if (face.sample_uuid) return sampleCropUrl(face.sample_uuid)
  if (eventUuid) return eventImageUrl(eventUuid, true)
  return null
}

export function eventHref(uuid: string): string {
  return `/events/?event=${encodeURIComponent(uuid)}`
}

export function personHref(uuid: string): string {
  return `/people/?person=${encodeURIComponent(uuid)}`
}

export function similarHref(target: { sample?: string | null; event?: string | null }): string {
  if (target.sample) return `/search/?similar=${encodeURIComponent(target.sample)}`
  if (target.event) return `/search/?similar_event=${encodeURIComponent(target.event)}`
  return "/search/"
}

export function searchHref(target: { person?: string | null; cluster?: string | null }): string {
  if (target.person) return `/search/?person=${encodeURIComponent(target.person)}`
  if (target.cluster) return `/search/?cluster=${encodeURIComponent(target.cluster)}`
  return "/search/"
}

export function safeColor(value: string | null | undefined): string | null {
  return value && COLOR_PATTERN.test(value) ? value : null
}

export function sameColor(a: string | null | undefined, b: string | null | undefined): boolean {
  return Boolean(a && b && a.toLowerCase() === b.toLowerCase())
}

const FACE_KIND_LABELS: Record<FaceEventKind, string> = {
  face_known: "Known face",
  face_unknown: "Unknown face",
}

export function isFaceKind(kind: string): kind is FaceEventKind {
  return kind === "face_known" || kind === "face_unknown"
}

export function humanize(value: string): string {
  const text = value.replace(/[_-]+/g, " ").replace(/\s+/g, " ").trim()
  return text ? text.charAt(0).toUpperCase() + text.slice(1) : value
}

export function kindLabel(kind: string): string {
  if (isFaceKind(kind)) return FACE_KIND_LABELS[kind]
  const labels: Record<string, string> = KIND_LABELS
  return labels[kind] ?? humanize(kind)
}

export function faceName(face: FaceIdentity): string {
  return face.person_name ?? face.cluster_label ?? "Unknown face"
}

export function formatScore(value: number | null | undefined): string {
  if (value === null || value === undefined || !Number.isFinite(value)) return "-"
  return `${Math.round(Math.min(1, Math.max(0, value)) * 100)}%`
}

export function seenTimes(count: number): string {
  if (count === 1) return "Seen once"
  return `Seen ${count} times`
}

export function samplesLabel(count: number): string {
  return count === 1 ? "1 sample" : `${count} samples`
}

export function peopleLabel(count: number): string {
  return count === 1 ? "1 person" : `${count} people`
}

export const PHOTO_MAX_PX = 1600
export const PHOTO_QUALITY = 0.9
export const PHOTO_UNREADABLE = "The photo could not be read"

export async function downscalePhoto(file: File, maxPx = PHOTO_MAX_PX): Promise<string> {
  const url = URL.createObjectURL(file)
  try {
    const image = new Image()
    image.decoding = "async"
    image.src = url
    try {
      await image.decode()
    } catch {
      throw new Error(PHOTO_UNREADABLE)
    }
    const sourceWidth = image.naturalWidth
    const sourceHeight = image.naturalHeight
    if (!sourceWidth || !sourceHeight) throw new Error(PHOTO_UNREADABLE)
    const ratio = Math.min(1, maxPx / Math.max(sourceWidth, sourceHeight))
    const width = Math.max(1, Math.round(sourceWidth * ratio))
    const height = Math.max(1, Math.round(sourceHeight * ratio))
    const canvas = document.createElement("canvas")
    canvas.width = width
    canvas.height = height
    const context = canvas.getContext("2d")
    if (!context) throw new Error("This browser cannot prepare photos")
    context.fillStyle = "#ffffff"
    context.fillRect(0, 0, width, height)
    context.imageSmoothingEnabled = true
    context.imageSmoothingQuality = "high"
    context.drawImage(image, 0, 0, width, height)
    return canvas.toDataURL("image/jpeg", PHOTO_QUALITY)
  } finally {
    URL.revokeObjectURL(url)
  }
}
