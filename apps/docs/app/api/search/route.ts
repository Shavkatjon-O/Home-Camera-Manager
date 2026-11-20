import { createFromSource } from "fumadocs-core/search/server"

import { source } from "@/lib/source"

/** The search index is built once at build time and served as a static file. */
export const revalidate = false

/** The exported search index of every language, which the search dialog downloads. */
export const { staticGET: GET } = createFromSource(source)
