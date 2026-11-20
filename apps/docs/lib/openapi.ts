import { readFileSync } from "node:fs"
import { join } from "node:path"
import { createOpenAPI } from "fumadocs-openapi/server"

/**
 * The per-operation OpenAPI documents the generators split from the contracts package, listed in a file they write.
 *
 * @returns Their paths relative to this app.
 */
function inputs(): string[] {
  try {
    return JSON.parse(readFileSync(join(process.cwd(), "generated/openapi-inputs.json"), "utf8")) as string[]
  } catch {
    return []
  }
}

/** The API reference's view of the platform API's OpenAPI document. */
export const openapi = createOpenAPI({
  input: inputs(),
})
