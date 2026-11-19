import type {
  Camera,
  CameraAudio,
  CameraDevice,
  CameraExtras,
  CameraImage,
  CameraMotion,
  CameraPresets,
  CameraRecordings,
  CameraReplay,
  CameraVideo,
  CameraCreate,
  CameraEvent,
  CameraEventSourceList,
  CameraLink,
  CameraLinkUpdate,
  CameraOrder,
  CameraUpdate,
  EncoderUpdate,
  EventQuery,
  FloorPlan,
  FloorPlanCreate,
  FloorPlanSummary,
  FloorPlanUpdate,
  HealthOverview,
  HealthRange,
  ImageSettings,
  InspectRequest,
  InspectResult,
  NetworkDevice,
  NetworkDeviceCreate,
  NetworkDeviceUpdate,
  Outage,
  Page,
  PtzVector,
  ScanResult,
  TargetDetail,
  User,
} from "@/lib/types"

export class ApiError extends Error {
  status: number
  code: string

  constructor(status: number, code: string, message: string) {
    super(message)
    this.name = "ApiError"
    this.status = status
    this.code = code
  }
}

interface RequestOptions {
  method?: "GET" | "POST" | "PUT" | "PATCH" | "DELETE"
  body?: unknown
  signal?: AbortSignal
  redirectOn401?: boolean
  keepalive?: boolean
}

export const LOGIN_PATH = "/login/"

export function redirectToLogin() {
  if (typeof window === "undefined") return
  const { pathname, search } = window.location
  if (pathname.startsWith(LOGIN_PATH)) return
  const next = encodeURIComponent(pathname + search)
  window.location.replace(`${LOGIN_PATH}?next=${next}`)
}

function messageFromDetail(detail: unknown): { code?: string; message?: string } {
  if (typeof detail === "string") return { message: detail }
  if (Array.isArray(detail)) {
    const first = detail[0] as { loc?: unknown[]; msg?: string } | undefined
    if (!first?.msg) return {}
    const field = Array.isArray(first.loc) ? first.loc.filter((p) => p !== "body").join(".") : ""
    return { code: "validation_error", message: field ? `${field}: ${first.msg}` : first.msg }
  }
  if (detail && typeof detail === "object") {
    const d = detail as { code?: unknown; message?: unknown }
    return {
      code: typeof d.code === "string" ? d.code : undefined,
      message: typeof d.message === "string" ? d.message : undefined,
    }
  }
  return {}
}

async function parseError(res: Response): Promise<ApiError> {
  let code = `http_${res.status}`
  let message = `Request failed with status ${res.status}`
  try {
    const data = (await res.json()) as { detail?: unknown }
    const parsed = messageFromDetail(data?.detail)
    if (parsed.code) code = parsed.code
    if (parsed.message) message = parsed.message
  } catch {
    if (res.status === 502 || res.status === 503 || res.status === 504) {
      message = "The server is not responding"
    }
  }
  return new ApiError(res.status, code, message)
}

export async function request<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const { method = "GET", body, signal, redirectOn401 = true, keepalive } = options
  const headers: Record<string, string> = { Accept: "application/json" }
  if (body !== undefined) headers["Content-Type"] = "application/json"
  let res: Response
  try {
    res = await fetch(`/api/v1${path}`, {
      method,
      headers,
      body: body === undefined ? undefined : JSON.stringify(body),
      credentials: "same-origin",
      cache: "no-store",
      signal,
      keepalive,
    })
  } catch (error) {
    if (error instanceof DOMException && error.name === "AbortError") throw error
    throw new ApiError(0, "network_error", "Cannot reach the server")
  }
  if (res.status === 401 && redirectOn401) {
    redirectToLogin()
    throw await parseError(res)
  }
  if (!res.ok) throw await parseError(res)
  if (res.status === 204) return undefined as T
  const text = await res.text()
  return (text ? JSON.parse(text) : undefined) as T
}

export function errorMessage(error: unknown): string {
  if (error instanceof ApiError) return error.message
  if (error instanceof Error) return error.message
  return "Something went wrong"
}

export function isAbort(error: unknown): boolean {
  return error instanceof DOMException && error.name === "AbortError"
}

function query(params: Record<string, string | number | undefined>): string {
  const search = new URLSearchParams()
  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined) search.set(key, String(value))
  }
  const text = search.toString()
  return text ? `?${text}` : ""
}

function cameraPath(uuid: string): string {
  return `/cameras/${encodeURIComponent(uuid)}`
}

export const api = {
  login: (username: string, password: string) =>
    request<User>("/auth/login", {
      method: "POST",
      body: { username, password },
      redirectOn401: false,
    }),
  logout: () => request<void>("/auth/logout", { method: "POST", redirectOn401: false }),
  me: (redirectOn401 = true, signal?: AbortSignal) =>
    request<User>("/auth/me", { redirectOn401, signal }),

  listCameras: (
    params: { page?: number; page_size?: number; order?: CameraOrder } = {},
    signal?: AbortSignal,
  ) => request<Page<Camera>>(`/cameras${query(params)}`, { signal }),
  getCamera: (uuid: string, signal?: AbortSignal) =>
    request<Camera>(`/cameras/${encodeURIComponent(uuid)}`, { signal }),
  createCamera: (data: CameraCreate) =>
    request<Camera>("/cameras", { method: "POST", body: data }),
  updateCamera: (uuid: string, data: CameraUpdate) =>
    request<Camera>(`/cameras/${encodeURIComponent(uuid)}`, { method: "PATCH", body: data }),
  deleteCamera: (uuid: string) =>
    request<void>(`/cameras/${encodeURIComponent(uuid)}`, { method: "DELETE" }),
  reorderCameras: (uuids: string[]) =>
    request<void>("/cameras/order", { method: "PUT", body: { uuids } }),
  checkCamera: (uuid: string) =>
    request<Camera>(`/cameras/${encodeURIComponent(uuid)}/check`, { method: "POST" }),
  ptzMove: (uuid: string, vector: PtzVector) =>
    request<void>(`/cameras/${encodeURIComponent(uuid)}/ptz/move`, {
      method: "POST",
      body: vector,
    }),
  ptzStop: (uuid: string) =>
    request<void>(`/cameras/${encodeURIComponent(uuid)}/ptz/stop`, { method: "POST" }),

  scan: (subnet?: string) =>
    request<ScanResult>("/discovery/scan", {
      method: "POST",
      body: subnet ? { subnet } : {},
    }),
  inspect: (data: InspectRequest) =>
    request<InspectResult>("/discovery/inspect", { method: "POST", body: data }),

  listFloorPlans: (params: { page?: number; page_size?: number } = {}, signal?: AbortSignal) =>
    request<Page<FloorPlanSummary>>(`/floorplans${query(params)}`, { signal }),
  getFloorPlan: (uuid: string, signal?: AbortSignal) =>
    request<FloorPlan>(`/floorplans/${encodeURIComponent(uuid)}`, { signal }),
  createFloorPlan: (data: FloorPlanCreate) =>
    request<FloorPlan>("/floorplans", { method: "POST", body: data }),
  updateFloorPlan: (uuid: string, data: FloorPlanUpdate, keepalive = false) =>
    request<FloorPlan>(`/floorplans/${encodeURIComponent(uuid)}`, { method: "PATCH", body: data, keepalive }),
  deleteFloorPlan: (uuid: string) =>
    request<void>(`/floorplans/${encodeURIComponent(uuid)}`, { method: "DELETE" }),

  cameraDevice: (uuid: string, signal?: AbortSignal) => request<CameraDevice>(`${cameraPath(uuid)}/device`, { signal }),
  syncCameraTime: (uuid: string) => request<CameraDevice>(`${cameraPath(uuid)}/device/sync-time`, { method: "POST" }),
  rebootCamera: (uuid: string) => request<void>(`${cameraPath(uuid)}/device/reboot`, { method: "POST" }),
  cameraVideo: (uuid: string, signal?: AbortSignal) => request<CameraVideo>(`${cameraPath(uuid)}/video`, { signal }),
  updateEncoder: (uuid: string, token: string, data: EncoderUpdate) =>
    request<CameraVideo>(`${cameraPath(uuid)}/video/${encodeURIComponent(token)}`, { method: "PUT", body: data }),
  cameraImage: (uuid: string, signal?: AbortSignal) => request<CameraImage>(`${cameraPath(uuid)}/image`, { signal }),
  updateImage: (uuid: string, data: Partial<ImageSettings>) =>
    request<CameraImage>(`${cameraPath(uuid)}/image`, { method: "PATCH", body: data }),
  cameraMotion: (uuid: string, signal?: AbortSignal) => request<CameraMotion>(`${cameraPath(uuid)}/motion`, { signal }),
  updateMotion: (uuid: string, data: { sensitivity?: number; enabled?: boolean }) =>
    request<CameraMotion>(`${cameraPath(uuid)}/motion`, { method: "PATCH", body: data }),
  cameraPresets: (uuid: string, signal?: AbortSignal) =>
    request<CameraPresets>(`${cameraPath(uuid)}/presets`, { signal }),
  savePreset: (uuid: string, name: string) =>
    request<CameraPresets>(`${cameraPath(uuid)}/presets`, { method: "POST", body: { name } }),
  renamePreset: (uuid: string, token: string, name: string) =>
    request<CameraPresets>(`${cameraPath(uuid)}/presets/${encodeURIComponent(token)}`, { method: "PATCH", body: { name } }),
  removePreset: (uuid: string, token: string) =>
    request<CameraPresets>(`${cameraPath(uuid)}/presets/${encodeURIComponent(token)}`, { method: "DELETE" }),
  gotoPreset: (uuid: string, token: string) =>
    request<void>(`${cameraPath(uuid)}/presets/${encodeURIComponent(token)}/goto`, { method: "POST" }),
  gotoHome: (uuid: string) => request<void>(`${cameraPath(uuid)}/home/goto`, { method: "POST" }),
  setHome: (uuid: string) => request<void>(`${cameraPath(uuid)}/home/set`, { method: "POST" }),
  cameraRecordings: (uuid: string, range: { from?: string; to?: string } = {}, signal?: AbortSignal) =>
    request<CameraRecordings>(`${cameraPath(uuid)}/recordings${query(range)}`, { signal }),
  replayStatus: (uuid: string, signal?: AbortSignal) => request<CameraReplay>(`${cameraPath(uuid)}/replay`, { signal }),
  startReplay: (uuid: string, start: string, session?: string | null) =>
    request<CameraReplay>(`${cameraPath(uuid)}/replay`, { method: "POST", body: { start, session: session ?? null } }),
  stopReplay: (uuid: string, session?: string | null) =>
    request<void>(`${cameraPath(uuid)}/replay${query({ session: session ?? undefined })}`, {
      method: "DELETE",
      keepalive: true,
    }),
  cameraExtras: (uuid: string, signal?: AbortSignal) => request<CameraExtras>(`${cameraPath(uuid)}/extras`, { signal }),
  setLight: (uuid: string, mode: "on" | "off" | "auto") =>
    request<void>(`${cameraPath(uuid)}/extras/light`, { method: "POST", body: { mode } }),
  setSiren: (uuid: string, seconds: number) =>
    request<void>(`${cameraPath(uuid)}/extras/siren`, { method: "POST", body: { seconds } }),
  cameraAudio: (uuid: string, signal?: AbortSignal) => request<CameraAudio>(`${cameraPath(uuid)}/audio`, { signal }),

  listEvents: (params: EventQuery = {}, signal?: AbortSignal) =>
    request<Page<CameraEvent>>(`/events${query({ ...params })}`, { signal }),
  getEvent: (uuid: string, signal?: AbortSignal) =>
    request<CameraEvent>(`/events/${encodeURIComponent(uuid)}`, { signal }),
  eventSources: (signal?: AbortSignal) => request<CameraEventSourceList>("/events/sources", { signal }),

  healthOverview: (range: HealthRange, signal?: AbortSignal) =>
    request<HealthOverview>(`/health/overview${query({ range })}`, { signal }),
  healthTarget: (uuid: string, range: HealthRange, signal?: AbortSignal) =>
    request<TargetDetail>(`/health/targets/${encodeURIComponent(uuid)}${query({ range })}`, { signal }),
  listOutages: (
    params: { page?: number; page_size?: number; target_uuid?: string } = {},
    signal?: AbortSignal,
  ) => request<Page<Outage>>(`/health/outages${query(params)}`, { signal }),
  createNetworkDevice: (data: NetworkDeviceCreate) =>
    request<NetworkDevice>("/health/devices", { method: "POST", body: data }),
  updateNetworkDevice: (uuid: string, data: NetworkDeviceUpdate) =>
    request<NetworkDevice>(`/health/devices/${encodeURIComponent(uuid)}`, { method: "PATCH", body: data }),
  deleteNetworkDevice: (uuid: string) =>
    request<void>(`/health/devices/${encodeURIComponent(uuid)}`, { method: "DELETE" }),
  setCameraLink: (cameraUuid: string, data: CameraLinkUpdate) =>
    request<CameraLink>(`/health/camera-links/${encodeURIComponent(cameraUuid)}`, { method: "PUT", body: data }),
}

export const EVENT_STREAM_URL = "/api/v1/events/stream"

export function eventImageUrl(uuid: string, thumbnail = false): string {
  return `/api/v1/events/${encodeURIComponent(uuid)}/${thumbnail ? "thumbnail" : "snapshot"}`
}
