import type { NextConfig } from "next"

const devOrigin = process.env.SSS_DEV_ORIGIN || "http://127.0.0.1:8750"

const nextConfig: NextConfig = {
  output: "export",
  trailingSlash: true,
  agentRules: false,
  images: { unoptimized: true },
  ...(process.env.NODE_ENV === "development"
    ? {
        async rewrites() {
          return [
            { source: "/api/:path*", destination: `${devOrigin}/api/:path*` },
            { source: "/go2rtc/:path*", destination: `${devOrigin}/go2rtc/:path*` },
          ]
        },
      }
    : {}),
}

export default nextConfig
