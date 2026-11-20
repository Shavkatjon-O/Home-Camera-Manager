import type { CameraBrand } from "@/lib/types"

export interface BrandDefaults {
  label: string
  onvifPort: number | null
  username: string | null
  mainPath: string | null
  subPath: string | null
  ptz: boolean | null
  mainRequired: boolean
  pathHint: string
}

export const BRAND_ORDER: CameraBrand[] = ["ezviz", "v380", "onvif", "rtsp"]

export const BRANDS: Record<CameraBrand, BrandDefaults> = {
  ezviz: {
    label: "EZVIZ",
    onvifPort: 80,
    username: "admin",
    mainPath: "/Streaming/Channels/101",
    subPath: "/Streaming/Channels/102",
    ptz: false,
    mainRequired: false,
    pathHint: "Empty fields take the EZVIZ defaults.",
  },
  v380: {
    label: "V380",
    onvifPort: 8899,
    username: null,
    mainPath: "/live/ch00_0",
    subPath: "/live/ch00_1",
    ptz: true,
    mainRequired: false,
    pathHint: "Empty fields take the V380 defaults.",
  },
  onvif: {
    label: "ONVIF",
    onvifPort: 80,
    username: null,
    mainPath: null,
    subPath: null,
    ptz: null,
    mainRequired: false,
    pathHint: "Empty paths and PTZ are resolved from the device profiles.",
  },
  rtsp: {
    label: "RTSP",
    onvifPort: null,
    username: null,
    mainPath: null,
    subPath: null,
    ptz: false,
    mainRequired: true,
    pathHint: "Plain RTSP needs the main path.",
  },
}

export function brandLabel(brand: CameraBrand | null | undefined): string {
  return brand ? BRANDS[brand].label : "-"
}
