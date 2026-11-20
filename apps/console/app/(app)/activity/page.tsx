import type { Metadata } from "next"

import { ActivityView } from "@/components/business/activity-view"

export const metadata: Metadata = { title: "Activity" }

/**
 * Route page for the activity log.
 *
 * @returns The activity view.
 */
export default function ActivityPage() {
  return <ActivityView />
}
