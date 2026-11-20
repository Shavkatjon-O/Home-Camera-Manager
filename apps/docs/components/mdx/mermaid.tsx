"use client"

import { use, useId, useSyncExternalStore } from "react"
import { useTheme } from "next-themes"

const LIGHT = {
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
}

const DARK = {
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
}

const cache = new Map<string, Promise<unknown>>()

function cached<T>(key: string, create: () => Promise<T>): Promise<T> {
  const found = cache.get(key)
  if (found) return found as Promise<T>
  const promise = create()
  cache.set(key, promise)
  return promise
}

function subscribe() {
  return () => {}
}

/**
 * A mermaid diagram drawn in the browser in the site's neutral palette, redrawn when the theme changes.
 *
 * @param props The props.
 * @param props.chart The diagram's mermaid source.
 * @returns The diagram, or nothing before the page hydrates.
 */
export function Mermaid({ chart }: { chart: string }) {
  const client = useSyncExternalStore(
    subscribe,
    () => true,
    () => false,
  )
  if (!client) return null
  return <MermaidDiagram chart={chart} />
}

function MermaidDiagram({ chart }: { chart: string }) {
  const id = useId().replaceAll(":", "")
  const { resolvedTheme } = useTheme()
  const dark = resolvedTheme === "dark"
  const { default: mermaid } = use(cached("mermaid", () => import("mermaid")))

  mermaid.initialize({
    startOnLoad: false,
    securityLevel: "strict",
    fontFamily: "inherit",
    theme: "base",
    themeVariables: { ...(dark ? DARK : LIGHT), fontSize: "14px" },
  })

  const { svg } = use(cached(`${chart}-${dark ? "dark" : "light"}`, () => mermaid.render(`m${id}`, chart)))

  return (
    <div
      className="not-prose my-6 flex justify-center overflow-x-auto rounded-lg border bg-fd-card p-4 [&_svg]:h-auto [&_svg]:max-w-full"
      dangerouslySetInnerHTML={{ __html: svg }}
    />
  )
}
