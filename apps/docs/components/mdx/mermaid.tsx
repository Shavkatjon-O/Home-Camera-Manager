"use client"

import { useEffect, useId, useState } from "react"
import { useTheme } from "next-themes"

import { cn } from "@/lib/cn"

type MermaidModule = typeof import("mermaid")

type Palette = Record<string, string>

const PALETTES: { light: Palette; dark: Palette } = {
  light: {
    background: "#ffffff",
    primaryColor: "#fafafa",
    primaryBorderColor: "#b5b5b5",
    primaryTextColor: "#171717",
    lineColor: "#6b6b6b",
    secondaryColor: "#f2f2f2",
    tertiaryColor: "#f2f2f2",
    clusterBkg: "#fafafa",
    clusterBorder: "#dcdcdc",
    noteBkgColor: "#f2f2f2",
    noteBorderColor: "#dcdcdc",
    noteTextColor: "#171717",
    actorBkg: "#fafafa",
    actorBorder: "#b5b5b5",
    actorTextColor: "#171717",
    signalColor: "#4d4d4d",
    signalTextColor: "#171717",
  },
  dark: {
    background: "#000000",
    primaryColor: "#161616",
    primaryBorderColor: "#4a4a4a",
    primaryTextColor: "#ededed",
    lineColor: "#a1a1a1",
    secondaryColor: "#0a0a0a",
    tertiaryColor: "#0a0a0a",
    clusterBkg: "#0a0a0a",
    clusterBorder: "#2e2e2e",
    noteBkgColor: "#161616",
    noteBorderColor: "#2e2e2e",
    noteTextColor: "#ededed",
    actorBkg: "#161616",
    actorBorder: "#4a4a4a",
    actorTextColor: "#ededed",
    signalColor: "#a1a1a1",
    signalTextColor: "#ededed",
  },
}

let library: Promise<MermaidModule> | null = null
let queue: Promise<unknown> = Promise.resolve()

/**
 * Load mermaid once per page, on the first diagram that needs it.
 *
 * @returns The library.
 */
function loadLibrary(): Promise<MermaidModule> {
  library ??= import("mermaid")
  return library
}

/**
 * Draw one diagram. Mermaid keeps one global configuration, so drawings run one after another, each with the
 * palette of its theme.
 *
 * @param id Element id mermaid gives the drawing.
 * @param source The diagram's mermaid source.
 * @param dark Whether to draw in the dark palette.
 * @returns The drawing as SVG markup.
 */
function draw(id: string, source: string, dark: boolean): Promise<string> {
  const next = queue.then(async () => {
    const { default: mermaid } = await loadLibrary()
    mermaid.initialize({
      startOnLoad: false,
      securityLevel: "strict",
      theme: "base",
      fontFamily: "var(--font-sans), ui-sans-serif, system-ui, sans-serif",
      themeVariables: { ...PALETTES[dark ? "dark" : "light"], fontSize: "14px" },
    })
    const { svg } = await mermaid.render(id, source)
    return svg
  })
  queue = next.catch(() => undefined)
  return next
}

/**
 * A mermaid diagram in the console's neutral palette. The page ships the diagram's source, which shows until the
 * browser has drawn it and stays when drawing fails, and the drawing follows the light or dark theme.
 *
 * @param props The props.
 * @param props.chart The diagram's mermaid source.
 * @returns The diagram.
 */
export function Mermaid({ chart }: { chart: string }) {
  const id = `diagram-${useId().replace(/[^a-zA-Z0-9]/g, "")}`
  const { resolvedTheme } = useTheme()
  const [drawing, setDrawing] = useState<{ svg: string; key: string } | null>(null)
  const [failed, setFailed] = useState(false)
  const key = `${resolvedTheme ?? "light"}:${chart}`

  useEffect(() => {
    if (!resolvedTheme) return
    let current = true
    draw(id, chart, resolvedTheme === "dark").then(
      (svg) => {
        if (current) {
          setDrawing({ svg, key })
          setFailed(false)
        }
      },
      () => {
        if (current) setFailed(true)
      },
    )
    return () => {
      current = false
    }
  }, [id, chart, key, resolvedTheme])

  const ready = drawing !== null && !failed
  return (
    <figure className="not-prose my-6 overflow-x-auto rounded-lg border bg-fd-card p-4">
      {ready ? (
        <div
          role="img"
          aria-label="Diagram"
          data-diagram-ready={drawing.key === key ? "" : undefined}
          className={cn("flex justify-center [&_svg]:h-auto [&_svg]:max-w-full", drawing.key !== key && "opacity-60")}
          dangerouslySetInnerHTML={{ __html: drawing.svg }}
        />
      ) : (
        <pre className="font-data text-[12px] leading-relaxed whitespace-pre text-fd-muted-foreground">{chart}</pre>
      )}
    </figure>
  )
}
