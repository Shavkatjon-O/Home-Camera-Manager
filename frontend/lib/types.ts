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
  lenses: number
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
  lenses?: number
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

export type WallMaterial =
  | "drywall"
  | "wood"
  | "glass"
  | "brick"
  | "thick_brick"
  | "concrete"
  | "reinforced_concrete"
  | "metal"

export type AccessPointPreset = "archer_c64" | "archer_c54" | "reyee_ew300n" | "generic"

export type Band = "2.4" | "5"

export interface Wall {
  id: string
  x1: number
  y1: number
  x2: number
  y2: number
  material: WallMaterial
}

export interface AccessPoint {
  id: string
  name: string
  x: number
  y: number
  preset: AccessPointPreset
  band_24: boolean
  band_5: boolean
  power_24_dbm: number
  power_5_dbm: number
  locked: boolean
}

export interface Device {
  id: string
  name: string
  x: number
  y: number
  band: Band
}

export interface PlanSettings {
  path_loss_exponent: number
  target_dbm: number
  snap_m: number
}

export interface FloorPlanSummary {
  uuid: string
  name: string
  width_m: number
  height_m: number
  walls: Wall[]
  access_points: AccessPoint[]
  devices: Device[]
  settings: PlanSettings
  has_background: boolean
  background_opacity: number
  created_at: string
  updated_at: string
}

export interface FloorPlan extends FloorPlanSummary {
  background_image: string | null
}

export interface FloorPlanCreate {
  name: string
  width_m: number
  height_m: number
  walls?: Wall[]
  access_points?: AccessPoint[]
  devices?: Device[]
  settings?: PlanSettings
  background_image?: string | null
  background_opacity?: number
}

export interface FloorPlanUpdate {
  name?: string
  width_m?: number
  height_m?: number
  walls?: Wall[]
  access_points?: AccessPoint[]
  devices?: Device[]
  settings?: PlanSettings
  background_image?: string
  background_opacity?: number
}
