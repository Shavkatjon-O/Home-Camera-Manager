import type { StatusKind } from "@/components/mdx/status"

/** One product or service of the system, as the product map shows it. */
export interface Product {
  /** Name people use for it. */
  name: string
  /** Folder of the repository it lives in. */
  path: string
  /** What it is, in one sentence. */
  summary: string
  /** How far it is. */
  status: StatusKind
  /** Documentation page about it, under the language's docs. */
  href: string
  /** Name of its lucide icon. */
  icon: "monitor" | "smartphone" | "tv" | "server" | "scan-eye" | "router" | "radio" | "plug" | "file-json" | "flask-conical"
  /** Whether people use it directly, or other parts of the system do. */
  group: "apps" | "services" | "packages" | "tools"
}

/** Every product, service and package of the repository, in the order of the product map. */
export const products: Product[] = [
  {
    name: "Console",
    path: "apps/console",
    summary: "The web app: the camera wall, camera control, events, analytics setup, people, search, counts and health.",
    status: "live",
    href: "guides/console",
    icon: "monitor",
    group: "apps",
  },
  {
    name: "Mobile app",
    path: "apps/mobile",
    summary: "The Flutter app for Android, later iOS: sign up, add sites and cameras, watch live, get alerts.",
    status: "beta",
    href: "guides/mobile",
    icon: "smartphone",
    group: "apps",
  },
  {
    name: "TV app",
    path: "apps/tv",
    summary: "An Android TV wall that connects to the cameras on the local Wi-Fi by itself.",
    status: "live",
    href: "guides/tv",
    icon: "tv",
    group: "apps",
  },
  {
    name: "Platform API",
    path: "services/api",
    summary: "The FastAPI backend every app talks to: accounts, organisations, sites, cameras, events and analytics.",
    status: "live",
    href: "reference/api",
    icon: "server",
    group: "services",
  },
  {
    name: "Analytics engine",
    path: "services/analytics",
    summary: "DeepStream on an NVIDIA GPU: detection, tracking, zones and lines, faces, tamper, counts and clips.",
    status: "live",
    href: "analytics",
    icon: "scan-eye",
    group: "services",
  },
  {
    name: "Connector",
    path: "services/connector",
    summary: "One container on a site's network that finds its cameras, keeps their passwords and restreams them.",
    status: "beta",
    href: "guides/connector",
    icon: "router",
    group: "services",
  },
  {
    name: "V380 bridge",
    path: "services/v380-bridge",
    summary: "Turns the V380 LAN protocol into RTSP, ONVIF and a small control API, one container per camera.",
    status: "live",
    href: "cameras/compatibility",
    icon: "radio",
    group: "services",
  },
  {
    name: "Camera adapters",
    path: "packages/camera-adapters",
    summary: "The Python package that identifies, streams and controls each kind of camera, with its model catalog.",
    status: "live",
    href: "contributing/camera-adapter",
    icon: "plug",
    group: "packages",
  },
  {
    name: "Contracts",
    path: "packages/contracts",
    summary: "The API's OpenAPI document, which the mobile client and this reference are generated from.",
    status: "live",
    href: "reference/api",
    icon: "file-json",
    group: "packages",
  },
  {
    name: "Development kit",
    path: "tools/devkit",
    summary: "A simulated site: ONVIF cameras that loop sample videos, for development without real cameras.",
    status: "beta",
    href: "contributing",
    icon: "flask-conical",
    group: "tools",
  },
]
