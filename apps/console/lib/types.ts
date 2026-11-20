import type { Face } from "@/lib/people"

export type CameraBrand = "ezviz" | "v380" | "onvif" | "rtsp"

export interface User {
  uuid: string
  username: string
  email?: string
  name?: string
  email_verified?: boolean
  created_at?: string
}

export type SiteKind = "home" | "store" | "office" | "warehouse" | "other"

export type SiteRole = "viewer" | "operator" | "admin" | "owner"

export interface Site {
  uuid: string
  organisation: string
  organisation_name: string
  name: string
  kind: SiteKind
  timezone: string
  position: number
  role: SiteRole
  camera_count: number
  connector_count: number
  created_at: string
  updated_at: string
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
  device_host: string | null
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
  device_host?: string | null
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

export type DeviceKind = "router" | "access_point" | "repeater" | "switch" | "other"

export type LinkKind = "cable" | "wifi_24" | "wifi_5"

export type TargetKind = "device" | "camera"

export type TargetStatus = "up" | "degraded" | "down" | "unknown" | "disabled"

export type HealthRange = "1h" | "24h" | "7d"

export interface LatencyStats {
  avg_ms: number | null
  p50_ms: number | null
  p95_ms: number | null
  max_ms: number | null
}

export interface HealthBucket {
  start: string
  samples: number
  availability: number | null
  latency_ms: number | null
}

export interface OutageBrief {
  uuid: string
  started_at: string
  ended_at: string | null
  duration_seconds: number
  upstream_uuid: string | null
  upstream_name: string | null
}

export interface TargetHealth {
  uuid: string
  kind: TargetKind
  device_kind: DeviceKind | null
  name: string
  host: string
  port: number
  parent_uuid: string | null
  parent_name: string | null
  link: LinkKind | null
  notes: string | null
  enabled: boolean
  status: TargetStatus
  last_sample_at: string | null
  last_error: string | null
  samples: number
  uptime_percent: number | null
  latency: LatencyStats
  outage_count: number
  last_outage: OutageBrief | null
  buckets: HealthBucket[]
}

export interface HealthOverview {
  range: HealthRange
  since: string
  until: string
  bucket_seconds: number
  interval_seconds: number
  targets: TargetHealth[]
}

export interface TargetDetail {
  range: HealthRange
  since: string
  until: string
  bucket_seconds: number
  interval_seconds: number
  target: TargetHealth
}

export interface Outage {
  uuid: string
  target_kind: TargetKind
  target_uuid: string
  target_name: string | null
  started_at: string
  ended_at: string | null
  ongoing: boolean
  duration_seconds: number
  failed_samples: number
  upstream_uuid: string | null
  upstream_name: string | null
  created_at: string
  updated_at: string
}

export interface NetworkDevice {
  uuid: string
  name: string
  kind: DeviceKind
  host: string
  probe_port: number
  parent_uuid: string | null
  parent_name: string | null
  link: LinkKind | null
  notes: string | null
  enabled: boolean
  created_at: string
  updated_at: string
}

export interface NetworkDeviceCreate {
  name: string
  kind: DeviceKind
  host: string
  probe_port?: number
  parent_uuid?: string | null
  link?: LinkKind | null
  notes?: string | null
  enabled?: boolean
}

export type NetworkDeviceUpdate = Partial<NetworkDeviceCreate>

export interface CameraLinkUpdate {
  parent_uuid: string | null
  link: LinkKind | null
}

export interface CameraLink {
  camera_uuid: string
  parent_uuid: string | null
  parent_name: string | null
  link: LinkKind | null
  updated_at: string | null
}

export type EventKind =
  | "motion"
  | "person"
  | "vehicle"
  | "tamper"
  | "storage"
  | "reboot"
  | "intrusion"
  | "line_crossing"
  | "loitering"
  | "crowd"
  | "face_known"
  | "face_unknown"
  | "animal"
  | "object_left"
  | "object_taken"
  | "fall"

export type EventOrigin = "camera" | "analytics"

export type EventSourceState = "connecting" | "live" | "reconnecting" | "unsupported" | "disabled"

export type EventSourceMode = "pullpoint" | "polling" | "none"

export interface CameraEvent {
  uuid: string
  camera_uuid: string
  camera_name: string | null
  kind: EventKind
  source_topic: string
  started_at: string
  ended_at: string | null
  ongoing: boolean
  duration_seconds: number
  camera_time: string | null
  has_snapshot: boolean
  has_thumbnail: boolean
  source: EventOrigin
  label: string | null
  alert: boolean
  view_uuid: string | null
  has_clip: boolean
  details: Record<string, unknown>
  created_at: string
  updated_at: string
  face?: Face | null
}

export type Box = [number, number, number, number]

export interface EventBox {
  object: number
  label: string
  box: Box
  at: number
}

export interface AnalyticsEventDetails {
  view_name: string | null
  profile: string | null
  zone: string | null
  zone_name: string | null
  line: string | null
  line_name: string | null
  direction: "in" | "out" | null
  objects: number[]
  count: number | null
  boxes: EventBox[]
}

export interface EventCounts {
  total: number
  kinds: Record<string, number>
  labels: Record<string, number>
  alerts: number
}

export interface CameraEventSource {
  camera_uuid: string
  camera_name: string
  state: EventSourceState
  mode: EventSourceMode
  endpoint: string | null
  topics: string[]
  kinds: EventKind[]
  conditions: Record<string, boolean>
  connected_at: string | null
  last_message_at: string | null
  error: string | null
}

export interface CameraEventSourceList {
  items: CameraEventSource[]
}

export interface EventStreamHello {
  sources: CameraEventSource[]
  open: CameraEvent[]
}

export interface EventQuery {
  page?: number
  page_size?: number
  camera_uuid?: string
  kind?: EventKind
  label?: string
  plate?: string
  source?: EventOrigin
  from?: string
  to?: string
}

export type EventCountQuery = Omit<EventQuery, "page" | "page_size">

export interface ValueRange {
  min: number
  max: number
}

export interface CameraClock {
  camera_utc: string | null
  server_utc: string
  offset_seconds: number | null
  mode: string | null
  timezone: string | null
  daylight_savings: boolean | null
}

export interface CameraDevice {
  camera_uuid: string
  supported: boolean
  reason: string | null
  endpoint: string | null
  manufacturer: string | null
  model: string | null
  firmware: string | null
  serial: string | null
  hardware_id: string | null
  clock: CameraClock | null
  can_reboot: boolean
}

export interface EncoderOptions {
  encoding: string
  resolutions: { width: number; height: number }[]
  fps_values: number[]
  fps: ValueRange | null
  bitrate: ValueRange | null
  gop: ValueRange | null
  quality: ValueRange | null
  profiles: string[]
}

export interface VideoEncoder {
  token: string
  name: string
  profiles: string[]
  encoding: string | null
  width: number | null
  height: number | null
  fps: number | null
  bitrate: number | null
  gop: number | null
  quality: number | null
  profile: string | null
  options: EncoderOptions[]
}

export interface CameraVideo {
  camera_uuid: string
  supported: boolean
  reason: string | null
  service: string | null
  encoders: VideoEncoder[]
}

export interface EncoderUpdate {
  encoding?: string
  width?: number
  height?: number
  fps?: number
  bitrate?: number
  gop?: number
  profile?: string
}

export interface ImageSettings {
  brightness: number | null
  contrast: number | null
  saturation: number | null
  sharpness: number | null
  ir_cut_filter: string | null
  wdr_mode: string | null
  wdr_level: number | null
  backlight_mode: string | null
  backlight_level: number | null
}

export interface CameraImage {
  camera_uuid: string
  supported: boolean
  reason: string | null
  source_token: string | null
  settings: ImageSettings | null
  options: {
    levels: Record<string, ValueRange>
    ir_cut_filter_modes: string[]
    wdr_modes: string[]
    wdr_level: ValueRange | null
    backlight_modes: string[]
    backlight_level: ValueRange | null
  } | null
}

export interface CameraMotion {
  camera_uuid: string
  supported: boolean
  reason: string | null
  sensitivity: number | null
  sensitivity_range: ValueRange | null
  enabled: boolean | null
  active_cells: number | null
  cells: number | null
}

export interface CameraPreset {
  token: string
  name: string
}

export interface CameraPresets {
  camera_uuid: string
  supported: boolean
  reason: string | null
  endpoint: string | null
  presets: CameraPreset[]
  max_presets: number | null
  home_supported: boolean
}

export interface CameraRecordings {
  camera_uuid: string
  supported: boolean
  reason: string | null
  recordings: number | null
  data_from: string | null
  data_until: string | null
  start: string | null
  end: string | null
  segments: { start: string; end: string }[]
  playback: boolean
  playback_reason: string | null
}

export interface CameraReplay {
  active: boolean
  session: string | null
  stream: string | null
  start: string | null
  failure: string | null
}

export interface CameraExtras {
  camera_uuid: string
  supported: boolean
  reason: string | null
  light: boolean
  siren: boolean
}

export interface CameraAudio {
  camera_uuid: string
  supported: boolean
  reason: string | null
  codec: string | null
}

export type ArmMode = "disarmed" | "home" | "away" | "schedule"

export interface AnalyticsSettings {
  arm_mode: ArmMode
}

export type AnalyticsProfile = "perimeter" | "vehicle" | "identity" | "tamper"

export type LineDirection = "in" | "out" | "both"

export type AlertMode = "off" | "always" | "schedule"

export type ViewPoint = [number, number]

export interface TimeWindow {
  start: string
  end: string
  days: number[]
}

export interface AlertPolicy {
  mode: AlertMode
  schedule: TimeWindow[]
  labels: string[]
}

export type AnimalsMode = "include" | "record" | "exclude"

export interface AnalyticsZone {
  uuid: string
  name: string
  polygon: ViewPoint[]
  whole_view: boolean
  labels: string[]
  min_dwell: number
  loiter_seconds: number
  crowd_count: number
  left_seconds: number
  taken_seconds: number
  object_labels: string[]
  background: boolean
  animals: AnimalsMode
  schedule: TimeWindow[]
  alert: AlertPolicy
  enabled: boolean
  reference: string | null
  suspended: boolean
}

export interface AnalyticsLine {
  uuid: string
  name: string
  points: [ViewPoint, ViewPoint]
  labels: string[]
  direction: LineDirection
  animals: AnimalsMode
  schedule: TimeWindow[]
  alert: AlertPolicy
  enabled: boolean
  reference: string | null
  suspended: boolean
}

export type AnalyticsZoneInput = Omit<AnalyticsZone, "uuid" | "suspended"> & { uuid?: string }

export type AnalyticsLineInput = Omit<AnalyticsLine, "uuid" | "suspended"> & { uuid?: string }

export interface AnalyticsRules {
  zones: AnalyticsZoneInput[]
  lines: AnalyticsLineInput[]
}

export type ViewState = "live" | "stalled" | "disabled"

export type LabelCounts = Record<string, number>

export interface TamperStatus {
  active: string[]
  mean: number
  std: number
  edges: number
  scene: number
}

export interface ViewStatus {
  state: ViewState
  fps: number
  target_fps: number
  latency: { p50_ms?: number; p95_ms?: number }
  objects: number
  events: number
  occupancy: Record<string, LabelCounts>
  entries: Record<string, LabelCounts>
  crossings: Record<string, { in: LabelCounts; out: LabelCounts }>
  tamper: TamperStatus | null
  suspended: string[]
  updated_at: string
}

export interface AnalyticsView {
  uuid: string
  camera_uuid: string
  camera_name: string
  lens: number
  lenses: number
  name: string
  profile: AnalyticsProfile
  enabled: boolean
  fps: number
  tamper: boolean | null
  faces: boolean | null
  moving: boolean
  appearance: boolean
  falls: boolean
  plates: boolean
  follow: boolean
  zones: AnalyticsZone[]
  lines: AnalyticsLine[]
  status: ViewStatus | null
}

export interface AnalyticsViewList {
  items: AnalyticsView[]
}

export type AnalyticsViewUpdate = Partial<
  Pick<AnalyticsView, "name" | "profile" | "enabled" | "fps" | "tamper" | "faces" | "moving" | "appearance" | "falls" | "plates" | "follow">
>

export interface LiveObject {
  track: number
  label: string
  confidence: number
  box: Box
}

export interface LiveObjects {
  view: string
  at: number | null
  objects: LiveObject[]
}

export interface AnalyticsPipeline {
  state: string
  message: string
  restarts: number
}

export interface AnalyticsStatus {
  pipeline: AnalyticsPipeline | null
  gpu: { memory_used_mb?: number; memory_total_mb?: number; utilization_percent?: number }
  updated_at: string | null
  views: Record<string, ViewStatus>
}

export interface ViewSnapshot {
  url: string
  reference: string | null
}
