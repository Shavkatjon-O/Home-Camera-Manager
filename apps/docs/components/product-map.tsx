import Link from "next/link"
import {
  FileJsonIcon,
  FlaskConicalIcon,
  MonitorIcon,
  PlugIcon,
  RadioIcon,
  RouterIcon,
  ScanEyeIcon,
  ServerIcon,
  SmartphoneIcon,
  TvIcon,
  type LucideIcon,
} from "lucide-react"

import { Status } from "@/components/mdx/status"
import { cn } from "@/lib/cn"
import { products, type Product } from "@/lib/products"

const ICONS: Record<Product["icon"], LucideIcon> = {
  monitor: MonitorIcon,
  smartphone: SmartphoneIcon,
  tv: TvIcon,
  server: ServerIcon,
  "scan-eye": ScanEyeIcon,
  router: RouterIcon,
  radio: RadioIcon,
  plug: PlugIcon,
  "file-json": FileJsonIcon,
  "flask-conical": FlaskConicalIcon,
}

const GROUPS: { id: Product["group"]; title: string }[] = [
  { id: "apps", title: "Apps" },
  { id: "services", title: "Services" },
  { id: "packages", title: "Packages" },
  { id: "tools", title: "Tools" },
]

/**
 * The map of every product, service and package, grouped as the repository is, each with its folder and status.
 *
 * @param props The props.
 * @param props.lang Language whose pages the cards link to.
 * @param props.className Extra classes.
 * @returns The map.
 */
export function ProductMap({ lang = "en", className }: { lang?: string; className?: string }) {
  return (
    <div className={cn("not-prose flex flex-col gap-8", className)}>
      {GROUPS.map((group) => (
        <section key={group.id} aria-labelledby={`products-${group.id}`} className="flex flex-col gap-3">
          <h3 id={`products-${group.id}`} className="font-mono text-xs text-fd-muted-foreground">
            {group.title}
          </h3>
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
            {products
              .filter((product) => product.group === group.id)
              .map((product) => {
                const Icon = ICONS[product.icon]
                return (
                  <Link
                    key={product.path}
                    href={`/${lang}/docs/${product.href}/`}
                    className="group flex flex-col gap-2 rounded-lg border bg-fd-card p-4 transition-colors hover:border-fd-muted-foreground/40 hover:bg-fd-accent"
                  >
                    <div className="flex items-center gap-2">
                      <Icon aria-hidden className="size-4 shrink-0 text-fd-muted-foreground" />
                      <span className="text-[14px] font-medium text-fd-foreground">{product.name}</span>
                      <Status kind={product.status} className="ml-auto" />
                    </div>
                    <p className="text-[13px] leading-relaxed text-fd-muted-foreground">{product.summary}</p>
                    <span className="font-data text-[11px] text-fd-muted-foreground/80">{product.path}</span>
                  </Link>
                )
              })}
          </div>
        </section>
      ))}
    </div>
  )
}
