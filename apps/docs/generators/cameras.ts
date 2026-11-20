import { existsSync, readFileSync, readdirSync } from "node:fs"
import { join } from "node:path"
import { parse } from "yaml"

import { escape, list, table, words } from "./markdown.ts"
import { SOURCES, fromRoot, locate, writeGenerated } from "./sources.ts"

/** One entry of the model catalog, as catalog/models.yaml writes it. */
interface CatalogEntry {
  id: string
  vendor: string
  adapter: string
  kind?: string
  confidence?: string
  match?: {
    manufacturers?: string[]
    models?: string[]
    ports?: number[]
    http_servers?: string[]
    oui?: string[]
  }
  urls?: Record<string, string>
  ports?: Record<string, number>
  quirks?: Record<string, unknown>
  pairing?: string[]
}

/** The model catalog file. */
interface Catalog {
  version?: number
  confidence?: Record<string, string>
  entries?: CatalogEntry[]
}

/** A label QR format an adapter reads. */
interface LabelFormat {
  id: string
  confirmed: boolean
}

/** What the generator learns about one adapter from its source. */
interface AdapterInfo {
  folder: string
  className: string
  bases: string[]
  name: string
  title: string
  priority: number
  summary: string
  capabilities: string[]
  labels: LabelFormat[]
  labelNote: string
}

const CAPABILITIES: Record<string, string> = {
  ControlCapability: "control",
  ImagingCapability: "imaging",
  EventsCapability: "events",
  PlaybackCapability: "playback",
  MaintenanceCapability: "maintenance",
  ProvisioningCapability: "provisioning",
}

const BASE_CAPABILITIES = ["fingerprint and identify", "media"]

/**
 * Read the first paragraph of a docstring, joined into one line.
 *
 * @param docstring The docstring's text without quotes.
 * @returns The paragraph.
 */
function firstParagraph(docstring: string): string {
  return docstring.trim().split(/\n\s*\n/)[0].replace(/\s+/g, " ").trim()
}

/**
 * Read every adapter class of the adapters package: its name, title, priority, capabilities and label formats.
 *
 * @param root The package folder, such as packages/camera-adapters/camera_adapters.
 * @returns The adapters by class name.
 */
function readAdapters(root: string): Map<string, AdapterInfo> {
  const adapters = new Map<string, AdapterInfo>()
  for (const folder of readdirSync(root, { withFileTypes: true })) {
    if (!folder.isDirectory()) continue
    const file = join(root, folder.name, "adapter.py")
    if (!existsSync(file)) continue
    const source = readFileSync(file, "utf8")
    const found = /^class (\w+)\(([^)]*)\):\n\s+"""([\s\S]*?)"""/m.exec(source)
    if (!found) continue
    const [, className, bases, docstring] = found
    const body = source.slice(found.index)
    const name =
      /^\s+name = AdapterName\.(\w+)\.value/m.exec(body)?.[1]?.toLowerCase() ??
      /^\s+name = "([^"]+)"/m.exec(body)?.[1] ??
      folder.name
    const labels: LabelFormat[] = []
    let labelNote = ""
    for (const path of [file, join(root, folder.name, "labels.py")]) {
      if (!existsSync(path)) continue
      const text = readFileSync(path, "utf8")
      for (const call of text.matchAll(/LabelInfo\(([\s\S]*?)\)\n/g)) {
        const id = /format="([^"]+)"/.exec(call[1])?.[1]
        if (id && !labels.some((label) => label.id === id)) {
          labels.push({ id, confirmed: /confirmed=True/.test(call[1]) })
        }
      }
      if (path.endsWith("labels.py")) {
        const header = /^"""([\s\S]*?)"""/.exec(text)?.[1] ?? ""
        labelNote = header.trim().split(/\n\s*\n/).slice(1).join(" ").replace(/\s+/g, " ").trim()
      }
    }
    adapters.set(className, {
      folder: folder.name,
      className,
      bases: bases.split(",").map((base) => base.trim()),
      name,
      title: /^\s+title = "([^"]+)"/m.exec(body)?.[1] ?? name,
      priority: Number(/^\s+priority = (-?\d+)/m.exec(body)?.[1] ?? 0),
      summary: firstParagraph(docstring),
      capabilities: [],
      labels,
      labelNote,
    })
  }
  const resolve = (info: AdapterInfo, seen: Set<string>): string[] => {
    const own = new Set<string>()
    for (const base of info.bases) {
      if (CAPABILITIES[base]) own.add(CAPABILITIES[base])
      const parent = adapters.get(base)
      if (parent && !seen.has(base)) {
        seen.add(base)
        resolve(parent, seen).forEach((capability) => own.add(capability))
      }
    }
    return Object.values(CAPABILITIES).filter((capability) => own.has(capability))
  }
  for (const info of adapters.values()) info.capabilities = resolve(info, new Set([info.className]))
  return adapters
}

/**
 * Write the generated tables of the camera compatibility and pairing pages.
 *
 * @returns Number of catalog entries and adapters, for the build log.
 */
export function generateCameras(): string {
  const catalogPath = locate(SOURCES.catalog)
  const adaptersPath = locate(SOURCES.adapters)
  if (!catalogPath || !adaptersPath) return "skipped"

  const catalog = parse(readFileSync(catalogPath, "utf8")) as Catalog
  const entries = catalog.entries ?? []
  const adapters = [...readAdapters(adaptersPath).values()].sort((a, b) => b.priority - a.priority)
  const titleOf = (name: string) => adapters.find((adapter) => adapter.name === name)?.title ?? name

  const adapterTable = table(
    ["Adapter", "Reaches", "Priority", "Capabilities", "Label QR formats"],
    adapters.map((adapter) => [
      adapter.name,
      adapter.title,
      String(adapter.priority),
      list([...BASE_CAPABILITIES, ...adapter.capabilities]),
      list(adapter.labels.map((label) => `${label.id} (${label.confirmed ? "confirmed" : "guessed"})`)),
    ]),
  )
  const adapterNotes = adapters
    .map((adapter) => `- ${escape(adapter.name)}: ${escape(adapter.summary)}`)
    .join("\n")

  const confidence = Object.entries(catalog.confidence ?? {})
    .map(([level, meaning]) => `- ${escape(level)}: ${escape(meaning)}`)
    .join("\n")

  const modelTable = table(
    ["Vendor", "Kind", "Adapter", "Confidence", "Pairing methods"],
    entries.map((entry) => [
      entry.vendor,
      entry.kind ?? "camera",
      entry.adapter,
      entry.confidence ?? "guessed",
      list(entry.pairing ?? []),
    ]),
  )

  const details = entries
    .map((entry) => {
      const match = entry.match ?? {}
      const lines = [
        `### ${escape(entry.vendor)}${entry.kind && entry.kind !== "camera" ? ` ${escape(entry.kind.toUpperCase())}` : ""}`,
        "",
        `${escape(titleOf(entry.adapter))} through the ${escape(entry.adapter)} adapter; catalog entry ${escape(entry.id)}, ${escape(entry.confidence ?? "guessed")}.`,
        "",
        table(
          ["Field", "Value"],
          [
            ["ONVIF manufacturer contains", list(match.manufacturers ?? [], "any")],
            ["Model matches", list(match.models ?? [], "any")],
            ["Ports only this vendor opens", list((match.ports ?? []).map(String))],
            ["Web server banner contains", list(match.http_servers ?? [])],
            ["Hardware address prefixes", list(match.oui ?? [])],
            ...Object.entries(entry.urls ?? {}).map(([stream, path]) => [`${words(stream)} stream path`, path]),
            ...Object.entries(entry.ports ?? {}).map(([service, port]) => [`${service.toUpperCase()} port`, String(port)]),
            ["Quirks", list(Object.keys(entry.quirks ?? {}).map(words))],
            ["Pairing methods", list(entry.pairing ?? [])],
          ],
        ),
      ]
      return lines.join("\n")
    })
    .join("\n\n")

  writeGenerated(
    "cameras/adapters.md",
    [
      `Generated from ${escape(fromRoot(adaptersPath))}: ${adapters.length} adapters, highest priority first.`,
      "",
      adapterTable,
      "",
      adapterNotes,
    ].join("\n"),
  )
  writeGenerated(
    "cameras/catalog.md",
    [
      `Generated from ${escape(fromRoot(catalogPath))}, catalog version ${catalog.version ?? 1}, with ${entries.length} entries. The confidence of an entry says how its facts were established:`,
      "",
      confidence,
      "",
      modelTable,
      "",
      "## Entries",
      "",
      details,
    ].join("\n"),
  )

  const methods = new Map<string, string[]>()
  for (const entry of entries) {
    for (const method of entry.pairing ?? []) {
      methods.set(method, [...(methods.get(method) ?? []), `${entry.vendor}${entry.kind && entry.kind !== "camera" ? ` ${entry.kind.toUpperCase()}` : ""}`])
    }
  }
  writeGenerated(
    "cameras/pairing-support.md",
    [
      `Generated from ${escape(fromRoot(catalogPath))} and the adapters' label parsers.`,
      "",
      table(
        ["Method", "Catalog entries that offer it"],
        [...methods.entries()].map(([method, vendors]) => [method, list([...new Set(vendors)])]),
      ),
    ].join("\n"),
  )
  writeGenerated(
    "cameras/label-formats.md",
    [
      table(
        ["Adapter", "Format", "Status"],
        adapters.flatMap((adapter) =>
          adapter.labels.map((label) => [adapter.name, label.id, label.confirmed ? "confirmed: a published format" : "guessed: a tolerant parser, not checked against a real label"]),
        ),
      ),
      "",
      adapters
        .filter((adapter) => adapter.labelNote)
        .map((adapter) => `- ${escape(adapter.name)}: ${escape(adapter.labelNote)}`)
        .join("\n"),
    ].join("\n"),
  )
  return `${entries.length} catalog entries, ${adapters.length} adapters`
}
