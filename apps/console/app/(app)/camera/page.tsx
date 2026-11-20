import type { Metadata } from "next"

import { CameraPage } from "@/components/camera/camera-view"

export const metadata: Metadata = { title: "Camera" }

export default function Page() {
  return <CameraPage />
}
