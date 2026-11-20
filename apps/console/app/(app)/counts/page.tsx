import type { Metadata } from "next"

import { CountsView } from "@/components/counts/counts-view"

export const metadata: Metadata = { title: "Counts" }

export default function CountsPage() {
  return <CountsView />
}
