"use client"

import * as React from "react"
import { toast } from "sonner"

import { ColorPicker } from "@/components/people/color-picker"
import { FaceCrop } from "@/components/people/face-parts"
import { Pager } from "@/components/people/pager"
import { refreshPeopleDirectory, usePeopleDirectory } from "@/components/people/people-directory"
import { ChoiceList, Field } from "@/components/people/person-choices"
import { usePagedQuery } from "@/components/people/use-paged"
import { Spinner } from "@/components/shell/primitives"
import { Segmented } from "@/components/shell/segmented"
import {
  AlertDialog,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogBody,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { errorMessage } from "@/lib/api"
import {
  PERSON_NAME_MAX,
  peopleApi,
  samplesLabel,
  seenTimes,
  type Cluster,
  type ClusterNaming,
  type Person,
  type Sample,
} from "@/lib/people"

export interface ClusterRef {
  uuid: string
  label: string
  seen_count?: number
  samples?: Sample[]
}

type NameMode = "existing" | "new"

const MERGE_PAGE_SIZE = 12

function CropRow({ samples, label }: { samples: Sample[]; label: string }) {
  const shown = samples.slice(0, 8)
  if (shown.length === 0) return null
  return (
    <ul aria-label={`Faces of ${label}`} className="flex flex-wrap gap-2">
      {shown.map((sample) => (
        <li key={sample.uuid}>
          <FaceCrop sample={sample.has_crop ? sample.uuid : null} className="size-12" sizes="48px" />
        </li>
      ))}
    </ul>
  )
}

function NameClusterForm({
  cluster,
  onCancel,
  onBusy,
  onNamed,
}: {
  cluster: ClusterRef
  onCancel: () => void
  onBusy: (busy: boolean) => void
  onNamed: (person: Person) => void
}) {
  const directory = usePeopleDirectory()
  const [mode, setMode] = React.useState<NameMode>("existing")
  const [target, setTarget] = React.useState<string | null>(null)
  const [name, setName] = React.useState("")
  const [color, setColor] = React.useState<string | null>(null)
  const [error, setError] = React.useState<string | null>(null)
  const [saving, setSaving] = React.useState(false)
  const nobody = directory.loaded && directory.people.length === 0
  const shownMode: NameMode = nobody ? "new" : mode

  const submit = async (event: React.FormEvent) => {
    event.preventDefault()
    const body: ClusterNaming = {}
    if (shownMode === "existing") {
      if (!target) {
        setError("Choose who this is")
        return
      }
      body.person = target
    } else {
      const trimmed = name.trim()
      if (!trimmed) {
        setError("Enter a name")
        return
      }
      body.name = trimmed
      if (color) body.color = color
    }
    setError(null)
    setSaving(true)
    onBusy(true)
    try {
      const person = await peopleApi.nameCluster(cluster.uuid, body)
      toast.success(`${cluster.label} is now ${person.name}`)
      void refreshPeopleDirectory()
      onNamed(person)
    } catch (err) {
      setError(errorMessage(err))
    } finally {
      setSaving(false)
      onBusy(false)
    }
  }

  let existing: React.ReactNode = null
  if (shownMode === "existing") {
    existing = directory.loaded ? (
      <ChoiceList
        label="Person"
        value={target}
        onChange={(value) => {
          setTarget(value)
          setError(null)
        }}
        choices={directory.people.map((item) => ({
          value: item.uuid,
          label: item.name,
          color: item.color,
          detail: samplesLabel(item.sample_count),
          crops: [item.sample],
        }))}
      />
    ) : (
      <div className="flex items-center gap-2 text-[13px] text-text-3">
        <Spinner />
        Loading people
      </div>
    )
  }

  return (
    <form onSubmit={submit} noValidate className="flex min-h-0 flex-1 flex-col">
      <DialogHeader>
        <DialogTitle>Who is this?</DialogTitle>
        <DialogDescription>
          {cluster.seen_count !== undefined ? `${cluster.label}, ${seenTimes(cluster.seen_count).toLowerCase()}. ` : ""}
          Every face of {cluster.label} moves to the person you choose, and their past events show that name.
        </DialogDescription>
      </DialogHeader>
      <DialogBody className="flex flex-col gap-4">
        <CropRow samples={cluster.samples ?? []} label={cluster.label} />
        <Segmented<NameMode>
          label="Who"
          value={shownMode}
          onChange={(value) => {
            setMode(value)
            setError(null)
          }}
          options={[
            { value: "existing", label: "Existing person", disabled: nobody },
            { value: "new", label: "New person" },
          ]}
          className="self-start"
        />
        {existing}
        {shownMode === "new" ? (
          <>
            <Field id="cluster-person-name" label="Name">
              <Input
                id="cluster-person-name"
                value={name}
                onChange={(event) => {
                  setName(event.target.value)
                  setError(null)
                }}
                placeholder="Alice"
                maxLength={PERSON_NAME_MAX}
                autoComplete="off"
                autoFocus
              />
            </Field>
            <Field
              label="Color"
              labelId="cluster-person-color"
              hint={color ? undefined : "Left empty, the next free color is picked."}
            >
              <ColorPicker value={color} onChange={setColor} labelledBy="cluster-person-color" />
            </Field>
          </>
        ) : null}
        {error ? (
          <p role="alert" className="text-[13px] text-danger">
            {error}
          </p>
        ) : null}
      </DialogBody>
      <DialogFooter>
        <Button type="button" variant="outline" onClick={onCancel} disabled={saving}>
          Cancel
        </Button>
        <Button type="submit" disabled={saving}>
          {saving ? <Spinner className="size-3.5 text-primary-foreground" /> : null}
          Save
        </Button>
      </DialogFooter>
    </form>
  )
}

export function NameClusterDialog({
  cluster,
  onOpenChange,
  onNamed,
}: {
  cluster: ClusterRef | null
  onOpenChange: (open: boolean) => void
  onNamed: (cluster: ClusterRef, person: Person) => void
}) {
  const [busy, setBusy] = React.useState(false)
  return (
    <Dialog open={cluster !== null} onOpenChange={(open) => !busy && onOpenChange(open)}>
      <DialogContent>
        {cluster ? (
          <NameClusterForm
            key={cluster.uuid}
            cluster={cluster}
            onCancel={() => onOpenChange(false)}
            onBusy={setBusy}
            onNamed={(person) => {
              onNamed(cluster, person)
              onOpenChange(false)
            }}
          />
        ) : null}
      </DialogContent>
    </Dialog>
  )
}

function MergeClusterForm({
  cluster,
  onCancel,
  onBusy,
  onMerged,
}: {
  cluster: Cluster
  onCancel: () => void
  onBusy: (busy: boolean) => void
  onMerged: (target: Cluster) => void
}) {
  const load = React.useCallback(
    (page: number, signal: AbortSignal) => peopleApi.listClusters({ page, page_size: MERGE_PAGE_SIZE }, signal),
    [],
  )
  const list = usePagedQuery<Cluster>("merge-clusters", load, MERGE_PAGE_SIZE)
  const [target, setTarget] = React.useState<string | null>(null)
  const [error, setError] = React.useState<string | null>(null)
  const [saving, setSaving] = React.useState(false)
  const candidates = (list.data?.items ?? []).filter((item) => item.uuid !== cluster.uuid)

  const submit = async () => {
    if (!target) {
      setError("Choose the face to merge into")
      return
    }
    setError(null)
    setSaving(true)
    onBusy(true)
    try {
      const merged = await peopleApi.mergeCluster(cluster.uuid, target)
      toast.success(`Merged ${cluster.label} into ${merged.label}`)
      onMerged(merged)
    } catch (err) {
      setError(errorMessage(err))
    } finally {
      setSaving(false)
      onBusy(false)
    }
  }

  let body: React.ReactNode
  if (!list.data && list.error) {
    body = (
      <div className="flex flex-col items-start gap-2 text-[13px] text-text-3">
        <span className="font-data text-xs">{list.error}</span>
        <Button variant="outline" size="sm" onClick={list.refresh}>
          Try again
        </Button>
      </div>
    )
  } else if (!list.data) {
    body = (
      <div className="flex items-center gap-2 text-[13px] text-text-3">
        <Spinner />
        Loading unknown faces
      </div>
    )
  } else if (list.data.total <= 1 && candidates.length === 0) {
    body = <p className="text-[13px] text-text-3">There is no other unknown face to merge into.</p>
  } else {
    body = (
      <>
        <ChoiceList
          label="Merge into"
          value={target}
          onChange={(value) => {
            setTarget(value)
            setError(null)
          }}
          choices={candidates.map((item) => ({
            value: item.uuid,
            label: item.label,
            detail: seenTimes(item.seen_count),
            crops: item.samples
              .filter((sample) => sample.has_crop)
              .slice(0, 3)
              .map((sample) => sample.uuid),
          }))}
        />
        {list.data.total > MERGE_PAGE_SIZE ? (
          <Pager
            page={list.page}
            pageSize={MERGE_PAGE_SIZE}
            total={list.data.total}
            error={list.error}
            previousLabel="Newer"
            nextLabel="Older"
            onPage={list.setPage}
          />
        ) : null}
      </>
    )
  }

  return (
    <>
      <DialogHeader>
        <DialogTitle>Merge {cluster.label}</DialogTitle>
        <DialogDescription>
          Use this when two unknown faces are the same person. Every face and event of {cluster.label} moves to the
          one you choose, and {cluster.label} is removed.
        </DialogDescription>
      </DialogHeader>
      <DialogBody className="flex flex-col gap-3">
        <CropRow samples={cluster.samples} label={cluster.label} />
        {body}
        {error ? (
          <p role="alert" className="text-[13px] text-danger">
            {error}
          </p>
        ) : null}
      </DialogBody>
      <DialogFooter>
        <Button type="button" variant="outline" onClick={onCancel} disabled={saving}>
          Cancel
        </Button>
        <Button onClick={submit} disabled={saving || candidates.length === 0}>
          {saving ? <Spinner className="size-3.5 text-primary-foreground" /> : null}
          Merge
        </Button>
      </DialogFooter>
    </>
  )
}

export function MergeClusterDialog({
  cluster,
  onOpenChange,
  onMerged,
}: {
  cluster: Cluster | null
  onOpenChange: (open: boolean) => void
  onMerged: (source: Cluster, target: Cluster) => void
}) {
  const [busy, setBusy] = React.useState(false)
  return (
    <Dialog open={cluster !== null} onOpenChange={(open) => !busy && onOpenChange(open)}>
      <DialogContent>
        {cluster ? (
          <MergeClusterForm
            key={cluster.uuid}
            cluster={cluster}
            onCancel={() => onOpenChange(false)}
            onBusy={setBusy}
            onMerged={(target) => {
              onMerged(cluster, target)
              onOpenChange(false)
            }}
          />
        ) : null}
      </DialogContent>
    </Dialog>
  )
}

export function DeleteClusterDialog({
  cluster,
  onOpenChange,
  onDeleted,
}: {
  cluster: Cluster | null
  onOpenChange: (open: boolean) => void
  onDeleted: (cluster: Cluster) => void
}) {
  const [busy, setBusy] = React.useState(false)

  const confirm = async () => {
    if (!cluster) return
    setBusy(true)
    try {
      await peopleApi.deleteCluster(cluster.uuid)
      toast.success(`Deleted ${cluster.label}`)
      onDeleted(cluster)
      onOpenChange(false)
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setBusy(false)
    }
  }

  return (
    <AlertDialog open={cluster !== null} onOpenChange={(open) => !busy && onOpenChange(open)}>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Delete unknown face</AlertDialogTitle>
          <AlertDialogDescription>
            {cluster
              ? `${cluster.label} is removed, and its face samples and face crops are wiped from this computer. Past events stay, without the face pictures.`
              : null}
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel asChild>
            <Button variant="outline" disabled={busy}>
              Cancel
            </Button>
          </AlertDialogCancel>
          <Button variant="destructive" onClick={confirm} disabled={busy}>
            {busy ? <Spinner className="size-3.5 text-white" /> : null}
            Delete
          </Button>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}
