import { readFileSync } from "node:fs"
import { basename, dirname } from "node:path"

import { escape, list, table } from "./markdown.ts"
import { SOURCES, SOURCE_LISTS, fromRoot, locate, locateAll, writeGenerated } from "./sources.ts"

/** A variable the code reads, with what its source says about it. */
interface Setting {
  name: string
  fallback: string | null
  description: string
  reader: string
}

/** A variable compose interpolates. */
interface ComposeUse {
  services: Set<string>
  fallback: string | null
  required: boolean
}

/**
 * Read the Attributes section of a Python class docstring.
 *
 * @param docstring The docstring.
 * @returns Attribute names to their descriptions.
 */
function attributes(docstring: string): Map<string, string> {
  const found = new Map<string, string>()
  const section = /Attributes:\n([\s\S]*)/.exec(docstring)?.[1] ?? ""
  let current = ""
  for (const line of section.split("\n")) {
    const item = /^\s{8}(\w+): (.*)$/.exec(line)
    if (item) {
      current = item[1]
      found.set(current, item[2].trim())
    } else if (current && /^\s{10,}\S/.test(line)) {
      found.set(current, `${found.get(current)} ${line.trim()}`)
    } else if (line.trim() && !/^\s{8}/.test(line)) {
      break
    }
  }
  return found
}

/**
 * Name the component a source file belongs to, such as api for services/api/app/core/config.py.
 *
 * @param path Absolute path.
 * @returns The component's folder relative to the repository root.
 */
function component(path: string): string {
  const relative = fromRoot(path)
  const parts = relative.split("/")
  return parts.length > 2 && ["services", "apps", "tools", "packages"].includes(parts[0])
    ? `${parts[0]}/${parts[1]}`
    : dirname(relative)
}

/**
 * Turn a Python literal default into plain text.
 *
 * @param literal The literal as written.
 * @returns The value, or null when it is empty.
 */
function literal(literal: string): string | null {
  const value = literal.trim().replace(/^["']|["']$/g, "")
  if (value === "True" || value === "False") return value.toLowerCase()
  return value === "" ? null : value
}

/**
 * Read the variables a settings class reads: pydantic settings with an env_prefix, or fields that call an env
 * helper with a variable name.
 *
 * @param path The settings file.
 * @returns The settings it defines.
 */
function readSettings(path: string): Setting[] {
  const source = readFileSync(path, "utf8")
  const reader = component(path)
  const settings: Setting[] = []
  for (const found of source.matchAll(/^class (\w+)(?:\([^)]*\))?:\n\s+"""([\s\S]*?)"""([\s\S]*?)(?=^class |(?![\s\S]))/gm)) {
    const docs = attributes(found[2])
    const body = found[3]
    const prefix = /env_prefix="([^"]*)"/.exec(body)?.[1]
    for (const line of body.split("\n")) {
      const field = /^\s{4}(\w+):\s*[^=\n]+?=\s*(.+)$/.exec(line)
      if (!field) continue
      const [, attribute, value] = field
      const description = docs.get(attribute) ?? ""
      const helper = /\benv\w*\(\s*"([A-Z0-9_]+)"(?:\s*,\s*("[^"]*"|[^)]+))?\)/.exec(value)
      if (helper) {
        settings.push({ name: helper[1], fallback: helper[2] ? literal(helper[2]) : null, description, reader })
        continue
      }
      if (prefix === undefined || attribute === "model_config") continue
      const aliases = [...value.matchAll(/"([a-z0-9_]+)"/g)].map((alias) => alias[1].toUpperCase())
      const fieldDefault = /Field\(\s*default=("[^"]*"|[^,)]+)/.exec(value)?.[1]
      const fallback = literal(fieldDefault ?? value)
      const names = value.includes("AliasChoices") ? aliases : [`${prefix}${attribute}`.toUpperCase()]
      for (const name of names) settings.push({ name, fallback, description, reader })
    }
  }
  return settings
}

/**
 * Read the variables other code reads straight from the environment, such as os.environ.get in a tool.
 *
 * @param path The file.
 * @returns The variables with their defaults.
 */
function readEnvironmentReads(path: string): Setting[] {
  const source = readFileSync(path, "utf8")
  return [...source.matchAll(/os\.environ\.get\(\s*"([A-Z0-9_]+)"(?:\s*,\s*"([^"]*)")?\s*\)/g)].map((found) => ({
    name: found[1],
    fallback: found[2] ? found[2] : null,
    description: "",
    reader: component(path),
  }))
}

/**
 * Read which compose services interpolate each variable, with compose's own defaults and required marks.
 *
 * @param paths The compose files.
 * @returns Uses by variable name.
 */
function readCompose(paths: string[]): Map<string, ComposeUse> {
  const uses = new Map<string, ComposeUse>()
  for (const path of paths) {
    let service = ""
    let inServices = false
    for (const line of readFileSync(path, "utf8").split("\n")) {
      if (/^\S/.test(line)) inServices = line.startsWith("services:")
      const name = /^ {2}([\w.-]+):\s*$/.exec(line)
      if (inServices && name) service = name[1]
      for (const found of line.matchAll(/\$\{([A-Z0-9_]+)(?:(:?-)([^}]*)|(:?\?)[^}]*)?\}/g)) {
        const use = uses.get(found[1]) ?? { services: new Set<string>(), fallback: null, required: false }
        use.services.add(`${service || "top level"} in ${basename(path)}`)
        if (found[2] && found[3] !== undefined && use.fallback === null) use.fallback = found[3] || null
        if (found[4]) use.required = true
        uses.set(found[1], use)
      }
    }
  }
  return uses
}

/**
 * Read an env example file into its variables in order, with the blank-line groups it keeps.
 *
 * @param path The file.
 * @returns Variable names with their example values and group numbers.
 */
function readExample(path: string): { name: string; example: string; group: number }[] {
  const variables: { name: string; example: string; group: number }[] = []
  let group = 0
  for (const line of readFileSync(path, "utf8").split("\n")) {
    if (!line.trim()) {
      group += 1
      continue
    }
    const found = /^([A-Za-z_][A-Za-z0-9_]*)=(.*)$/.exec(line)
    if (found) variables.push({ name: found[1], example: found[2], group })
  }
  return variables
}

/**
 * Write the generated tables of the configuration reference.
 *
 * @returns Number of variables, for the build log.
 */
export function generateConfiguration(): string {
  const examplePath = locate(SOURCES.envExample)
  if (!examplePath) return "skipped"
  const devPath = locate(SOURCES.envDevExample, false)
  const settingsPaths = locateAll(SOURCE_LISTS.settings)
  const readerPaths = locateAll(SOURCE_LISTS.readers, false)
  const composePaths = locateAll(SOURCE_LISTS.compose)

  const settings = [...settingsPaths.flatMap(readSettings), ...readerPaths.flatMap(readEnvironmentReads)]
  const compose = readCompose(composePaths)
  const byName = new Map<string, Setting[]>()
  for (const setting of settings) byName.set(setting.name, [...(byName.get(setting.name) ?? []), setting])

  const describe = (name: string) => {
    const found = byName.get(name) ?? []
    const use = compose.get(name)
    const description = found.find((setting) => setting.description)?.description ?? ""
    const readers = [...new Set(found.map((setting) => setting.reader))]
    const services = use ? [...use.services] : []
    const fallback = found.find((setting) => setting.fallback !== null)?.fallback ?? use?.fallback ?? null
    return {
      description: description || (services.length ? "Interpolated by compose" : "Not read by the code the generator scans"),
      readBy: list([...readers, ...services.map((service) => `compose ${service}`)], "none found"),
      fallback: use?.required ? `required${fallback ? `, ${fallback}` : ""}` : (fallback ?? "empty"),
    }
  }

  const exampleTable = (path: string) =>
    table(
      ["Name", "Example", "Default", "Meaning", "Read by"],
      readExample(path).map((variable) => {
        const info = describe(variable.name)
        return [variable.name, variable.example || "empty", info.fallback, info.description, info.readBy]
      }),
    )

  const listed = new Set([
    ...readExample(examplePath).map((variable) => variable.name),
    ...(devPath ? readExample(devPath).map((variable) => variable.name) : []),
  ])
  const extra = [...byName.entries()]
    .filter(([name]) => !listed.has(name) && name.startsWith("SSS_"))
    .sort(([a], [b]) => a.localeCompare(b))

  const sections = [
    `Generated from ${escape(fromRoot(examplePath))}, the settings in ${escape(list(settingsPaths.map(fromRoot)))} and ${escape(list(composePaths.map(fromRoot)))}. Example is the line in the example file, Default what the code uses when the variable is unset.`,
    "",
    "## Variables in .env.example",
    "",
    exampleTable(examplePath),
  ]
  if (devPath) {
    sections.push("", "## Variables in .env.dev.example", "", `The development kit reads ${escape(fromRoot(devPath))}.`, "", exampleTable(devPath))
  }
  sections.push(
    "",
    "## Settings without an example line",
    "",
    "The code reads these as well; they keep their defaults unless set in the environment or the env file.",
    "",
    table(
      ["Name", "Default", "Meaning", "Read by"],
      extra.map(([name]) => {
        const info = describe(name)
        return [name, info.fallback, info.description, info.readBy]
      }),
    ),
  )
  writeGenerated("configuration.md", sections.join("\n"))
  return `${listed.size} example variables, ${extra.length} further settings`
}
