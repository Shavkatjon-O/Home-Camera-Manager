import { createMDX } from "fumadocs-mdx/next"

const withMDX = createMDX()

const basePath = (process.env.DOCS_BASE_PATH || "").replace(/\/$/, "")
const cpus = Number(process.env.DOCS_BUILD_CPUS) || undefined

/** @type {import("next").NextConfig} */
const config = {
  output: "export",
  trailingSlash: true,
  reactStrictMode: true,
  basePath: basePath || undefined,
  images: { unoptimized: true },
  env: { NEXT_PUBLIC_DOCS_BASE_PATH: basePath },
  experimental: cpus ? { cpus } : undefined,
}

export default withMDX(config)
