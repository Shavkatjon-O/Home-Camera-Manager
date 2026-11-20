import Link from "next/link"
import {
  ActivityIcon,
  ArrowRightIcon,
  BellRingIcon,
  CctvIcon,
  ChartColumnIcon,
  LayoutGridIcon,
  ScanEyeIcon,
  SearchIcon,
  type LucideIcon,
} from "lucide-react"

import { ProductMap } from "@/components/product-map"
import { systemName } from "@/lib/site"

const FEATURES: { icon: LucideIcon; title: string; text: string; href: string }[] = [
  {
    icon: LayoutGridIcon,
    title: "Live wall",
    text: "Every camera in one grid, one tile per lens, with PTZ, presets, light and siren where the camera has them.",
    href: "guides/console",
  },
  {
    icon: ScanEyeIcon,
    title: "Zones and lines",
    text: "People, vehicles and animals in zones and across directed lines, with dwell, loitering and crowd rules.",
    href: "analytics/zones-and-lines",
  },
  {
    icon: BellRingIcon,
    title: "Arm modes and alerts",
    text: "Disarmed, Home, Away or Schedule decide which events alert, per zone and line policy.",
    href: "analytics/arm-modes",
  },
  {
    icon: SearchIcon,
    title: "Faces and search",
    text: "Known people and unknown clusters, search over every event, and Find this person across cameras.",
    href: "analytics/faces",
  },
  {
    icon: ChartColumnIcon,
    title: "Counts and occupancy",
    text: "Crossings in and out per line by hour and day, and the occupancy of areas bounded by lines.",
    href: "analytics/counts",
  },
  {
    icon: ActivityIcon,
    title: "Tamper and health",
    text: "Covered, blurred, dark or moved views, and probes that name the device behind each outage.",
    href: "analytics/tamper",
  },
]

/**
 * The landing page: what the system is, where to start, the product map and the main features.
 *
 * @param props The props.
 * @param props.params The language of the page.
 * @returns The page.
 */
export default async function HomePage({ params }: PageProps<"/[lang]">) {
  const { lang } = await params
  const docs = `/${lang}/docs`
  return (
    <main className="mx-auto flex w-full max-w-[1120px] flex-col gap-16 px-4 py-12 sm:px-6 sm:py-16">
      <section className="flex flex-col gap-6">
        <span className="inline-flex w-fit items-center gap-2 rounded-md bg-fd-secondary px-2 py-1 font-mono text-[11px] text-fd-muted-foreground">
          <CctvIcon aria-hidden className="size-3.5" />
          Self-hosted video surveillance with its own analytics
        </span>
        <h1 className="max-w-3xl text-3xl font-semibold tracking-tight text-balance sm:text-5xl">{systemName}</h1>
        <p className="max-w-2xl text-[15px] leading-relaxed text-fd-muted-foreground sm:text-base">
          Live cameras in the browser, on a TV and on the phone; PTZ and camera settings over ONVIF; and video
          analytics on an NVIDIA GPU with DeepStream, from zones and lines to faces, counts, tamper and number plates.
          These pages explain how to run it, how each product works and how to extend it.
        </p>
        <div className="flex flex-wrap gap-2">
          <Link
            href={`${docs}/getting-started/self-hosting/`}
            className="inline-flex h-9 items-center gap-1.5 rounded-md bg-fd-primary px-3.5 text-[13px] font-medium text-fd-primary-foreground transition-opacity hover:opacity-90"
          >
            Get started
            <ArrowRightIcon aria-hidden className="size-3.5" />
          </Link>
          <Link
            href={`${docs}/`}
            className="inline-flex h-9 items-center rounded-md border bg-fd-card px-3.5 text-[13px] font-medium transition-colors hover:bg-fd-accent"
          >
            Overview
          </Link>
          <Link
            href={`${docs}/reference/api/`}
            className="inline-flex h-9 items-center rounded-md border bg-fd-card px-3.5 text-[13px] font-medium transition-colors hover:bg-fd-accent"
          >
            API reference
          </Link>
        </div>
      </section>

      <section aria-labelledby="features" className="flex flex-col gap-4">
        <h2 id="features" className="text-lg font-semibold tracking-tight">
          What it does
        </h2>
        <div className="grid grid-cols-1 gap-px overflow-hidden rounded-lg border bg-fd-border sm:grid-cols-2 lg:grid-cols-3">
          {FEATURES.map((feature) => {
            const Icon = feature.icon
            return (
              <Link
                key={feature.title}
                href={`${docs}/${feature.href}/`}
                className="flex flex-col gap-2 bg-fd-background p-5 transition-colors hover:bg-fd-card"
              >
                <Icon aria-hidden className="size-4 text-fd-muted-foreground" />
                <span className="text-[14px] font-medium">{feature.title}</span>
                <span className="text-[13px] leading-relaxed text-fd-muted-foreground">{feature.text}</span>
              </Link>
            )
          })}
        </div>
      </section>

      <section aria-labelledby="products" className="flex flex-col gap-4">
        <div className="flex flex-col gap-1">
          <h2 id="products" className="text-lg font-semibold tracking-tight">
            Product map
          </h2>
          <p className="text-[13px] text-fd-muted-foreground">
            The repository is organised by product: apps people use, services they talk to, and shared packages.
          </p>
        </div>
        <ProductMap lang={lang} />
      </section>
    </main>
  )
}
