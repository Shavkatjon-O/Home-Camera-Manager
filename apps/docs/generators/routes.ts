import { existsSync, readFileSync, readdirSync } from "node:fs"
import { join } from "node:path"

import { escape, list, table } from "./markdown.ts"
import { SOURCES, SOURCE_LISTS, fromConfig, fromRoot, locate, writeGenerated } from "./sources.ts"

/** One route of a FastAPI router file. */
interface Route {
  method: string
  path: string
  body: string
  summary: string
}

/**
 * Read the routes of a FastAPI router file: method, path, request body type and the first line of the docstring.
 *
 * @param file The router file.
 * @param prefix Prefix the application mounts the router under.
 * @returns The routes.
 */
function readRoutes(file: string, prefix: string): Route[] {
  const source = readFileSync(file, "utf8")
  const routes: Route[] = []
  const pattern = /@router\.(get|post|put|patch|delete)\(\s*"([^"]*)"[^\n]*\n(?:@[^\n]*\n)*async def \w+\(([\s\S]*?)\)\s*(?:->[^:]+)?:\s*\n\s+"""([\s\S]*?)"""/g
  for (const found of source.matchAll(pattern)) {
    const [, method, path, parameters, docstring] = found
    const body =
      parameters
        .split(/,(?![^[]*\])/)
        .map((parameter) => /^\s*\w+:\s*([A-Z]\w*)\s*(?:$|,)/.exec(parameter.trim())?.[1])
        .find((type) => type && !/^(Request|Response|UUID)$/.test(type)) ?? ""
    routes.push({
      method: method.toUpperCase(),
      path: `${prefix}${path}`,
      body,
      summary: docstring.trim().split("\n")[0].trim(),
    })
  }
  return routes
}

/**
 * Write the tables of the analytics contract: the internal routes the analytics service calls, and the contract
 * JSON Schemas once the contracts package holds them.
 *
 * @returns Number of routes and schemas, for the build log.
 */
export function generateRoutes(): string {
  const configured = process.env[SOURCE_LISTS.internalRoutes.variable]
  const entries = (configured ? configured.split(",") : SOURCE_LISTS.internalRoutes.fallback).map((entry) => {
    const [prefix, path] = entry.trim().split("=")
    return { prefix, path: fromConfig(path) }
  })
  const missing = entries.filter((entry) => !existsSync(entry.path))
  if (missing.length) {
    throw new Error(
      `[docs] internal-routes: ${missing.map((entry) => entry.path).join(", ")} missing. Set ${SOURCE_LISTS.internalRoutes.variable} to prefix=file pairs.`,
    )
  }
  const routes = entries.flatMap((entry) => readRoutes(entry.path, entry.prefix))
  const files = [...new Set(entries.map((entry) => fromRoot(entry.path)))]
  const sections = [
    `Generated from ${escape(list(files))}.`,
    "",
    table(
      ["Method", "Path", "Body", "What it does"],
      routes.map((route) => [route.method, route.path, route.body || "none", route.summary]),
    ),
  ]

  const schemasDir = locate(SOURCES.contractSchemas, false)
  let schemas = 0
  if (schemasDir) {
    for (const name of readdirSync(schemasDir).filter((file) => file.endsWith(".json")).sort()) {
      const schema = JSON.parse(readFileSync(join(schemasDir, name), "utf8")) as {
        title?: string
        description?: string
        properties?: Record<string, { type?: string | string[]; description?: string; $ref?: string }>
        required?: string[]
      }
      schemas += 1
      sections.push(
        "",
        `### ${escape(schema.title ?? name)}`,
        "",
        `${escape(schema.description ?? "")} Source: ${escape(fromRoot(join(schemasDir, name)))}.`,
        "",
        table(
          ["Field", "Type", "Required", "Meaning"],
          Object.entries(schema.properties ?? {}).map(([field, property]) => [
            field,
            property.$ref ? property.$ref.split("/").pop() ?? "" : [property.type ?? "any"].flat().join(" or "),
            schema.required?.includes(field) ? "yes" : "no",
            property.description ?? "",
          ]),
        ),
      )
    }
  }
  writeGenerated("analytics-contract.md", sections.join("\n"))
  return `${routes.length} internal routes, ${schemas} contract schemas`
}
