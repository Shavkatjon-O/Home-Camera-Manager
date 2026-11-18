export type CameraBrand = "ezviz" | "v380" | "onvif" | "rtsp"

export interface User {
  uuid: string
  username: string
}

export interface CameraStatus {
  online: boolean | null
  checked_at: string | null
  error: string | null
}

export interface CameraStreams {
  main: string
  sub: string | null
}

export interface Camera {
  uuid: string
  name: string
  brand: CameraBrand
  host: string
  rtsp_port: number
  onvif_port: number | null
  username: string | null
  has_password: boolean
  main_path: string
  sub_path: string | null
  ptz_enabled: boolean
  location: string | null
  position: number
  enabled: boolean
  status: CameraStatus
  streams: CameraStreams
  created_at: string
  updated_at: string
}

export interface Page<T> {
  items: T[]
  total: number
  page: number
  page_size: number
}

export type CameraOrder = "created" | "position"

export interface CameraCreate {
  name: string
  brand: CameraBrand
  host: string
  rtsp_port?: number
  onvif_port?: number | null
  username?: string | null
  password?: string | null
  main_path?: string
  sub_path?: string | null
  ptz_enabled?: boolean
  location?: string | null
  enabled?: boolean
}

export type CameraUpdate = Partial<CameraCreate>

export interface PtzVector {
  pan: number
  tilt: number
  zoom: number
}

export interface ScanItem {
  host: string
  open_ports: number[]
  brand: CameraBrand | null
  manufacturer: string | null
  model: string | null
  onvif_port: number | null
  camera_uuid: string | null
}

export interface ScanResult {
  subnet: string
  scanned_at: string
  duration_ms: number
  items: ScanItem[]
}

export interface InspectRequest {
  host: string
  onvif_port: number
  username?: string
  password?: string
}

export interface InspectProfile {
  token: string
  name: string | null
  encoding: string | null
  width: number | null
  height: number | null
  stream_uri: string | null
}

export interface InspectResult {
  manufacturer: string | null
  model: string | null
  firmware: string | null
  profiles: InspectProfile[]
  ptz: boolean
}
