import type { Metadata } from "next"

import { WallView } from "@/components/wall/wall-view"

export const metadata: Metadata = { title: "Wall" }

export default function WallPage() {
  return <WallView />
}
