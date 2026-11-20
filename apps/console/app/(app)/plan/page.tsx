import type { Metadata } from "next"

import { PlanView } from "@/components/business/plan-view"

export const metadata: Metadata = { title: "Plan" }

/**
 * Route page for the plan and usage.
 *
 * @returns The plan view.
 */
export default function PlanPage() {
  return <PlanView />
}
