export const FEATURE_LABELS: Record<string, string> = {
  faces: "Face recognition",
  plates: "Number plates",
  appearance_search: "Appearance search",
  journeys: "Journeys",
  falls: "Fall detection",
  objects: "Left and taken objects",
  follow: "PTZ follow",
  telegram_alerts: "Telegram alerts",
}

export const LIMIT_LABELS: Record<string, string> = {
  sites: "Sites",
  cameras: "Cameras",
  members: "Members",
  event_retention_days: "Event retention (days)",
  clip_retention_days: "Clip retention (days)",
}

export const AUDIT_ACTIONS = [
  "sign_in",
  "organisation_create",
  "organisation_update",
  "organisation_delete",
  "ownership_transfer",
  "site_create",
  "site_update",
  "site_delete",
  "member_update",
  "member_remove",
  "invitation_create",
  "invitation_revoke",
  "invitation_accept",
  "camera_create",
  "camera_update",
  "camera_delete",
  "device_pair",
  "connector_claim",
  "connector_update",
  "connector_revoke",
  "camera_control",
  "rules_update",
  "arm_mode_change",
  "alert_channel_link",
  "alert_channel_remove",
  "live_view",
  "clip_view",
  "export",
  "face_enrol",
  "face_delete",
  "faces_consent",
  "admin_plan_change",
  "admin_suspend",
  "admin_restore",
]

/**
 * Turns a snake case key into a sentence case phrase.
 *
 * @param key - A key such as camera_create.
 * @returns The readable phrase, for example Camera create.
 */
export function humanise(key: string): string {
  const text = key.replace(/_/g, " ")
  return text.charAt(0).toUpperCase() + text.slice(1)
}

/**
 * Names a feature for people.
 *
 * @param key - The feature key.
 * @returns The readable feature name.
 */
export function featureLabel(key: string): string {
  return FEATURE_LABELS[key] ?? humanise(key)
}

/**
 * Names a plan limit for people.
 *
 * @param key - The limit key.
 * @returns The readable limit name.
 */
export function limitLabel(key: string): string {
  return LIMIT_LABELS[key] ?? humanise(key)
}

/**
 * Formats a limit value.
 *
 * @param value - The limit, or null for unlimited.
 * @returns The number as text, or Unlimited.
 */
export function limitText(value: number | null | undefined): string {
  return value === null || value === undefined ? "Unlimited" : String(value)
}

/**
 * Formats a metered usage value with its unit.
 *
 * @param metric - The metric key.
 * @param value - The amount.
 * @returns The amount with a unit where the metric has one.
 */
export function usageText(metric: string, value: number): string {
  if (metric === "camera_hours" || metric === "view_hours") return `${value.toFixed(1)} hours`
  if (metric === "clip_bytes") {
    const megabytes = value / (1024 * 1024)
    return megabytes >= 1024 ? `${(megabytes / 1024).toFixed(2)} GB` : `${megabytes.toFixed(1)} MB`
  }
  return Math.round(value).toLocaleString("en-US")
}

/**
 * Names a metered usage metric for people.
 *
 * @param metric - The metric key.
 * @returns The readable metric name.
 */
export function metricLabel(metric: string): string {
  const names: Record<string, string> = {
    camera_hours: "Camera hours",
    view_hours: "View hours",
    events: "Events",
    notifications: "Notifications",
    clip_bytes: "Clip storage",
  }
  return names[metric] ?? humanise(metric)
}
