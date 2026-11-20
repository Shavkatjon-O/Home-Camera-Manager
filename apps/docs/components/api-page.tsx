"use client"

import { createOpenAPIPage } from "fumadocs-openapi/ui"

/**
 * One page of the API reference, rendered from the OpenAPI document. The playground is off, because the site is
 * public and documents a server each installation runs at its own address.
 */
export const OpenAPIPage = createOpenAPIPage({ playground: { enabled: false } })
