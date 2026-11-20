import { docs } from "collections/server"
import { loader } from "fumadocs-core/source"
import { lucideIconsPlugin } from "fumadocs-core/source/lucide-icons"

import { i18n } from "@/lib/i18n"
import { openapi } from "@/lib/openapi"

/** Address under which every documentation page lives, after the language. */
export const docsRoute = "/docs"

/** Every page of the site with its page tree, per language. */
export const source = loader({
  baseUrl: docsRoute,
  i18n,
  source: docs.toFumadocsSource(),
  plugins: [lucideIconsPlugin(), openapi.loaderPlugin()],
})
