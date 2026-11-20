"use client"

import * as React from "react"
import Link from "next/link"
import { ImagePlusIcon, MergeIcon, PencilIcon, SearchIcon, Trash2Icon } from "lucide-react"

import { CardShell, ReadOut, SampleStrip, SightingList } from "@/components/people/card-parts"
import { ColorDot } from "@/components/people/face-parts"
import { PHOTO_ACCEPT } from "@/components/people/photo-upload"
import { IconButton } from "@/components/shell/icon-button"
import { Spinner } from "@/components/shell/primitives"
import { Button } from "@/components/ui/button"
import { formatMoment } from "@/lib/health"
import { searchHref, type Person, type Sample } from "@/lib/people"

export interface PersonActions {
  onPhotos: (person: Person, files: File[]) => void
  onEdit: (person: Person) => void
  onMerge: (person: Person) => void
  onDelete: (person: Person) => void
  onRemoveSample: (person: Person, sample: Sample) => Promise<void>
  onShowAll: (person: Person) => Promise<void>
}

function sampleSummary(person: Person): string {
  if (person.sample_count === 0) return "None yet"
  if (person.upload_count === 0) return String(person.sample_count)
  return `${person.sample_count}, ${person.upload_count} from photos`
}

export function PersonCard({
  person,
  highlighted,
  actions,
}: {
  person: Person
  highlighted?: boolean
  actions: PersonActions
}) {
  const inputRef = React.useRef<HTMLInputElement>(null)
  const [removing, setRemoving] = React.useState<string | null>(null)
  const [expanding, setExpanding] = React.useState(false)
  const hidden = Math.max(0, person.sample_count - person.samples.length)

  const remove = async (sample: Sample) => {
    setRemoving(sample.uuid)
    try {
      await actions.onRemoveSample(person, sample)
    } finally {
      setRemoving(null)
    }
  }

  const showAll = async () => {
    setExpanding(true)
    try {
      await actions.onShowAll(person)
    } finally {
      setExpanding(false)
    }
  }

  return (
    <CardShell label={person.name} highlighted={highlighted}>
      <div className="flex items-start justify-between gap-3">
        <div className="flex min-w-0 flex-col gap-1">
          <div className="flex min-w-0 items-center gap-2">
            <ColorDot color={person.color} className="size-2.5" />
            <h3 className="truncate text-[14px] text-foreground">{person.name}</h3>
          </div>
          {person.notes ? <p className="line-clamp-2 text-[12px] text-text-2">{person.notes}</p> : null}
        </div>
        <div className="-mt-1 -mr-1.5 flex shrink-0 items-center">
          <input
            ref={inputRef}
            type="file"
            accept={PHOTO_ACCEPT}
            multiple
            className="hidden"
            aria-label={`Photos of ${person.name}`}
            onChange={(event) => {
              const files = Array.from(event.target.files ?? [])
              event.target.value = ""
              if (files.length > 0) actions.onPhotos(person, files)
            }}
          />
          <IconButton label="Add photos" size="icon-sm" onClick={() => inputRef.current?.click()}>
            <ImagePlusIcon />
          </IconButton>
          <IconButton label="Edit" size="icon-sm" onClick={() => actions.onEdit(person)}>
            <PencilIcon />
          </IconButton>
          <IconButton label="Merge into another person" size="icon-sm" onClick={() => actions.onMerge(person)}>
            <MergeIcon />
          </IconButton>
          <IconButton label="Delete" size="icon-sm" onClick={() => actions.onDelete(person)}>
            <Trash2Icon />
          </IconButton>
        </div>
      </div>
      {person.samples.length > 0 ? (
        <SampleStrip
          samples={person.samples}
          owner={person.name}
          removing={removing}
          onRemove={(sample) => void remove(sample)}
        />
      ) : (
        <p className="text-[12px] text-text-3">No face samples yet. Add a few clear photos of {person.name}.</p>
      )}
      <div className="flex flex-col gap-1.5">
        <ReadOut label="Samples" value={sampleSummary(person)} />
        <ReadOut label="Last seen" value={person.last_seen_at ? formatMoment(person.last_seen_at) : "Never"} />
      </div>
      <SightingList sightings={person.sightings} />
      <div className="flex flex-wrap items-center gap-2">
        <Button asChild variant="outline" size="sm">
          <Link href={searchHref({ person: person.uuid })}>
            <SearchIcon />
            Search events
          </Link>
        </Button>
        {hidden > 0 ? (
          <Button variant="ghost" size="sm" disabled={expanding} onClick={() => void showAll()}>
            {expanding ? <Spinner className="size-3.5" /> : null}
            Show all samples
          </Button>
        ) : null}
      </div>
    </CardShell>
  )
}
