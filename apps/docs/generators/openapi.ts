import { mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs"
import { join } from "node:path"
import { generateFiles } from "fumadocs-openapi"
import { createOpenAPI } from "fumadocs-openapi/server"

import { escape, table } from "./markdown.ts"
import { SOURCES, appDir, fromRoot, generatedDir, locate, writeGenerated } from "./sources.ts"

/** Folder of the generated API reference pages, which git ignores. */
export const apiPagesDir = join(appDir, "content/docs/en/reference/api")

/** Folder of the per-operation OpenAPI documents, relative to this app, which lib/openapi.ts reads. */
export const operationsDir = "generated/openapi"

/** The parts of an OpenAPI operation the generator reads. */
interface Operation {
  tags?: string[]
  summary?: string
  description?: string
  operationId?: string
}

/** The parts of an OpenAPI document the generator reads and copies. */
interface Document {
  openapi: string
  info: Record<string, unknown>
  paths: Record<string, Record<string, Operation>>
  components?: { schemas?: Record<string, unknown>; securitySchemes?: Record<string, unknown> }
  [key: string]: unknown
}

/**
 * Turn a tag such as connector-device into a folder title.
 *
 * @param tag The tag.
 * @returns The title.
 */
function title(tag: string): string {
  const text = tag.replace(/[-_]+/g, " ")
  return text.charAt(0).toUpperCase() + text.slice(1)
}

/**
 * Collect the component schemas a value refers to, following references inside them.
 *
 * @param value Any part of the document.
 * @param schemas The document's component schemas.
 * @param found Names collected so far.
 * @returns The names.
 */
function references(value: unknown, schemas: Record<string, unknown>, found = new Set<string>()): Set<string> {
  if (Array.isArray(value)) {
    for (const item of value) references(item, schemas, found)
  } else if (value && typeof value === "object") {
    for (const [key, item] of Object.entries(value)) {
      const name = key === "$ref" && typeof item === "string" ? /^#\/components\/schemas\/(.+)$/.exec(item)?.[1] : undefined
      if (name && !found.has(name)) {
        found.add(name)
        references(schemas[name], schemas, found)
      } else {
        references(item, schemas, found)
      }
    }
  }
  return found
}

/**
 * Split the OpenAPI document of the contracts package into one small document per operation, so each page carries
 * only the schemas it shows, and generate one page per operation, grouped by tag.
 *
 * @returns Number of operations, for the build log.
 */
export async function generateOpenAPI(): Promise<string> {
  const source = locate(SOURCES.openapi)
  if (!source) return "skipped"
  const document = JSON.parse(readFileSync(source, "utf8")) as Document
  const schemas = document.components?.schemas ?? {}

  const outDir = join(appDir, operationsDir)
  rmSync(outDir, { recursive: true, force: true })
  mkdirSync(outDir, { recursive: true })
  const inputs: string[] = []
  const tags = new Map<string, string[][]>()
  for (const [path, methods] of Object.entries(document.paths)) {
    for (const [method, operation] of Object.entries(methods)) {
      const id = operation.operationId ?? `${method}_${path}`.replace(/[^a-zA-Z0-9]+/g, "_")
      const used = references(operation, schemas)
      const part: Document = {
        ...document,
        paths: { [path]: { [method]: operation } },
        components: {
          ...document.components,
          schemas: Object.fromEntries([...used].sort().map((name) => [name, schemas[name]])),
        },
      }
      const file = `${operationsDir}/${id}.json`
      writeFileSync(join(appDir, file), JSON.stringify(part))
      inputs.push(file)
      for (const tag of operation.tags ?? ["other"]) {
        tags.set(tag, [
          ...(tags.get(tag) ?? []),
          [method.toUpperCase(), path, operation.summary ?? "", operation.description ?? ""],
        ])
      }
    }
  }
  writeFileSync(join(generatedDir, "openapi-inputs.json"), `${JSON.stringify(inputs, null, 2)}\n`)

  rmSync(apiPagesDir, { recursive: true, force: true })
  mkdirSync(apiPagesDir, { recursive: true })
  const log = console.log
  console.log = () => {}
  try {
    await generateFiles({
      input: createOpenAPI({ input: inputs }),
      output: apiPagesDir,
      per: "operation",
      groupBy: "tag",
      includeDescription: true,
      addGeneratedComment: false,
    })
  } finally {
    console.log = log
  }

  const names = [...tags.keys()].sort()
  for (const tag of names) {
    writeFileSync(join(apiPagesDir, tag, "meta.json"), `${JSON.stringify({ title: title(tag) }, null, 2)}\n`)
    writeGenerated(
      `api-tags/${tag}.md`,
      [
        `Generated from ${escape(fromRoot(source))}, tag ${escape(tag)}.`,
        "",
        table(["Method", "Path", "Operation", "What it does"], tags.get(tag) ?? []),
      ].join("\n"),
    )
  }
  writeFileSync(
    join(apiPagesDir, "meta.json"),
    `${JSON.stringify({ title: "API reference", icon: "Braces", pages: ["index", ...names] }, null, 2)}\n`,
  )
  writeFileSync(
    join(apiPagesDir, "index.mdx"),
    [
      "---",
      "title: API reference",
      "description: Every route of the platform API, generated from its OpenAPI document.",
      "icon: Braces",
      "---",
      "",
      "<include>../../../../../generated/api-overview.md</include>",
      "",
      "<include>../../../../partials/api.mdx</include>",
      "",
    ].join("\n"),
  )
  writeGenerated(
    "api-overview.md",
    [
      `Generated from ${escape(fromRoot(source))}, version ${escape(String(document.info.version ?? ""))}: ${inputs.length} operations in ${names.length} groups.`,
      "",
      table(
        ["Group", "Operations"],
        names.map((tag) => [title(tag), String(tags.get(tag)?.length ?? 0)]),
      ),
    ].join("\n"),
  )
  return `${inputs.length} operations in ${names.length} groups`
}
