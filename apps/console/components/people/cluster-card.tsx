"use client"

import Link from "next/link"
import { MergeIcon, SearchIcon, Trash2Icon, UserRoundCheckIcon } from "lucide-react"

import { CardShell, ReadOut, SampleStrip, SightingList } from "@/components/people/card-parts"
import { ColorDot } from "@/components/people/face-parts"
import { IconButton } from "@/components/shell/icon-button"
import { Chip } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"
import { formatMoment } from "@/lib/health"
import { searchHref, seenTimes, type Cluster } from "@/lib/people"

export interface ClusterActions {
  onName: (cluster: Cluster) => void
  onMerge: (cluster: Cluster) => void
  onDelete: (cluster: Cluster) => void
}

export function ClusterCard({ cluster, actions }: { cluster: Cluster; actions: ClusterActions }) {
  return (
    <CardShell label={cluster.label}>
      <div className="flex items-start justify-between gap-3">
        <div className="flex min-w-0 items-center gap-2">
          <ColorDot color={null} className="size-2.5" />
          <h3 className="truncate text-[14px] text-foreground">{cluster.label}</h3>
          <Chip className="h-5 px-1.5 text-[10px]">{seenTimes(cluster.seen_count)}</Chip>
        </div>
        <div className="-mt-1 -mr-1.5 flex shrink-0 items-center">
          <IconButton label="Merge into another unknown face" size="icon-sm" onClick={() => actions.onMerge(cluster)}>
            <MergeIcon />
          </IconButton>
          <IconButton label="Delete" size="icon-sm" onClick={() => actions.onDelete(cluster)}>
            <Trash2Icon />
          </IconButton>
        </div>
      </div>
      {cluster.samples.length > 0 ? (
        <SampleStrip samples={cluster.samples} owner={cluster.label} />
      ) : (
        <p className="text-[12px] text-text-3">No face crops left.</p>
      )}
      <div className="flex flex-col gap-1.5">
        <ReadOut label="First seen" value={formatMoment(cluster.first_seen_at)} />
        <ReadOut label="Last seen" value={formatMoment(cluster.last_seen_at)} />
      </div>
      <SightingList sightings={cluster.sightings} />
      <div className="flex flex-wrap items-center gap-2">
        <Button variant="outline" size="sm" onClick={() => actions.onName(cluster)}>
          <UserRoundCheckIcon />
          Who is this?
        </Button>
        <Button asChild variant="ghost" size="sm">
          <Link href={searchHref({ cluster: cluster.uuid })}>
            <SearchIcon />
            Search events
          </Link>
        </Button>
      </div>
    </CardShell>
  )
}
