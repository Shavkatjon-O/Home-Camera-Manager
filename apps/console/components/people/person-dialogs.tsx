"use client"

import * as React from "react"
import { ImagePlusIcon, XIcon } from "lucide-react"
import { toast } from "sonner"

import { ColorPicker } from "@/components/people/color-picker"
import { refreshPeopleDirectory, usePeopleDirectory } from "@/components/people/people-directory"
import { ChoiceList, Field } from "@/components/people/person-choices"
import { PHOTO_ACCEPT, UploadProgress, usePhotoUpload } from "@/components/people/photo-upload"
import { IconButton } from "@/components/shell/icon-button"
import { Spinner } from "@/components/shell/primitives"
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
  PERSON_NOTES_MAX,
  peopleApi,
  samplesLabel,
  sameColor,
  type Person,
  type PersonCreate,
  type PersonUpdate,
} from "@/lib/people"

function fileSize(bytes: number): string {
  if (bytes < 1024 * 1024) return `${Math.max(1, Math.round(bytes / 1024))} KB`
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}

function fileKey(file: File, index: number): string {
  return `${index}-${file.name}-${file.size}-${file.lastModified}`
}

function PhotoPicker({ files, onChange }: { files: File[]; onChange: (files: File[]) => void }) {
  const inputRef = React.useRef<HTMLInputElement>(null)
  return (
    <div className="flex flex-col gap-2">
      <input
        ref={inputRef}
        type="file"
        accept={PHOTO_ACCEPT}
        multiple
        className="hidden"
        aria-label="Photo files"
        onChange={(event) => {
          const chosen = Array.from(event.target.files ?? [])
          event.target.value = ""
          if (chosen.length > 0) onChange([...files, ...chosen])
        }}
      />
      <Button type="button" variant="outline" size="sm" className="self-start" onClick={() => inputRef.current?.click()}>
        <ImagePlusIcon />
        Choose photos
      </Button>
      {files.length > 0 ? (
        <ul aria-label="Chosen photos" className="flex flex-col rounded-md border border-hairline px-2.5">
          {files.map((file, index) => (
            <li
              key={fileKey(file, index)}
              className="flex items-center gap-2 border-b border-hairline py-1.5 text-[12px] last:border-b-0"
            >
              <span className="min-w-0 flex-1 truncate text-foreground">{file.name}</span>
              <span className="shrink-0 font-data text-[11px] text-text-3">{fileSize(file.size)}</span>
              <IconButton
                type="button"
                label="Remove photo"
                size="icon-xs"
                onClick={() => onChange(files.filter((item, position) => position !== index))}
              >
                <XIcon />
              </IconButton>
            </li>
          ))}
        </ul>
      ) : null}
    </div>
  )
}

function PersonForm({
  person,
  onCancel,
  onSubmitted,
}: {
  person: Person | null
  onCancel: () => void
  onSubmitted: (person: Person, files: File[], created: boolean) => void
}) {
  const [name, setName] = React.useState(person?.name ?? "")
  const [notes, setNotes] = React.useState(person?.notes ?? "")
  const [color, setColor] = React.useState<string | null>(person?.color ?? null)
  const [files, setFiles] = React.useState<File[]>([])
  const [nameError, setNameError] = React.useState<string | null>(null)
  const [formError, setFormError] = React.useState<string | null>(null)
  const [saving, setSaving] = React.useState(false)

  const submit = async (event: React.FormEvent) => {
    event.preventDefault()
    const trimmed = name.trim()
    if (!trimmed) {
      setNameError("Enter a name")
      return
    }
    setFormError(null)
    setSaving(true)
    try {
      const cleanNotes = notes.trim() || null
      if (person) {
        const patch: PersonUpdate = {}
        if (trimmed !== person.name) patch.name = trimmed
        if (cleanNotes !== person.notes) patch.notes = cleanNotes
        if (color && !sameColor(color, person.color)) patch.color = color
        if (Object.keys(patch).length === 0) {
          onCancel()
          return
        }
        const saved = await peopleApi.updatePerson(person.uuid, patch)
        onSubmitted(saved, [], false)
      } else {
        const body: PersonCreate = { name: trimmed, notes: cleanNotes }
        if (color) body.color = color
        const created = await peopleApi.createPerson(body)
        onSubmitted(created, files, true)
      }
    } catch (err) {
      setFormError(errorMessage(err))
    } finally {
      setSaving(false)
    }
  }

  return (
    <form onSubmit={submit} noValidate className="flex min-h-0 flex-1 flex-col">
      <DialogHeader>
        <DialogTitle>{person ? `Edit ${person.name}` : "Add person"}</DialogTitle>
        <DialogDescription>
          {person
            ? "The new name shows on every event of this person at once."
            : "A few clear photos of the face, each with this person alone, are enough to start recognising them."}
        </DialogDescription>
      </DialogHeader>
      <DialogBody className="flex flex-col gap-4">
        <Field id="person-name" label="Name" error={nameError}>
          <Input
            id="person-name"
            value={name}
            onChange={(event) => {
              setName(event.target.value)
              setNameError(null)
            }}
            placeholder="Alice"
            maxLength={PERSON_NAME_MAX}
            autoFocus
            autoComplete="off"
            aria-invalid={Boolean(nameError)}
          />
        </Field>
        <Field id="person-notes" label="Notes">
          <Input
            id="person-notes"
            value={notes}
            onChange={(event) => setNotes(event.target.value)}
            placeholder="Optional"
            maxLength={PERSON_NOTES_MAX}
          />
        </Field>
        <Field
          label="Color"
          labelId="person-color"
          hint={person || color ? undefined : "Left empty, the next free color is picked."}
        >
          <ColorPicker value={color} onChange={setColor} labelledBy="person-color" />
        </Field>
        {person ? null : (
          <Field label="Photos" hint="Optional. Use photos with one face each, close and in good light.">
            <PhotoPicker files={files} onChange={setFiles} />
          </Field>
        )}
        {formError ? (
          <p role="alert" className="text-[13px] text-danger">
            {formError}
          </p>
        ) : null}
      </DialogBody>
      <DialogFooter>
        <Button type="button" variant="outline" onClick={onCancel} disabled={saving}>
          Cancel
        </Button>
        <Button type="submit" disabled={saving}>
          {saving ? <Spinner className="size-3.5 text-primary-foreground" /> : null}
          {person ? "Save changes" : files.length > 0 ? "Add person and photos" : "Add person"}
        </Button>
      </DialogFooter>
    </form>
  )
}

export function PersonFormDialog({
  open,
  person,
  onOpenChange,
  onSaved,
}: {
  open: boolean
  person: Person | null
  onOpenChange: (open: boolean) => void
  onSaved: (person: Person) => void
}) {
  const upload = usePhotoUpload()
  const [created, setCreated] = React.useState<Person | null>(null)

  const close = () => {
    if (upload.running) return
    onOpenChange(false)
    setCreated(null)
    upload.reset()
  }

  const submitted = (saved: Person, files: File[], isNew: boolean) => {
    onSaved(saved)
    void refreshPeopleDirectory()
    if (isNew && files.length > 0) {
      setCreated(saved)
      void upload.start(saved.uuid, files, onSaved)
      return
    }
    toast.success(isNew ? `Added ${saved.name}` : `Saved ${saved.name}`)
    onOpenChange(false)
  }

  return (
    <Dialog open={open} onOpenChange={(next) => !next && close()}>
      <DialogContent>
        {open && created ? (
          <UploadProgress name={created.name} upload={upload} onDone={close} />
        ) : open ? (
          <PersonForm key={person?.uuid ?? "new"} person={person} onCancel={close} onSubmitted={submitted} />
        ) : null}
      </DialogContent>
    </Dialog>
  )
}

export function DeletePersonDialog({
  person,
  onOpenChange,
  onDeleted,
}: {
  person: Person | null
  onOpenChange: (open: boolean) => void
  onDeleted: (person: Person) => void
}) {
  const [busy, setBusy] = React.useState(false)

  const confirm = async () => {
    if (!person) return
    setBusy(true)
    try {
      await peopleApi.deletePerson(person.uuid)
      toast.success(`Deleted ${person.name}`)
      void refreshPeopleDirectory()
      onDeleted(person)
      onOpenChange(false)
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setBusy(false)
    }
  }

  return (
    <AlertDialog open={person !== null} onOpenChange={(open) => !busy && onOpenChange(open)}>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Delete person</AlertDialogTitle>
          <AlertDialogDescription>
            {person
              ? `${person.name} is removed, and every face sample and face crop of this person is wiped from this computer. Past events stay, without the face pictures.`
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

function MergePersonForm({
  person,
  onCancel,
  onBusy,
  onMerged,
}: {
  person: Person
  onCancel: () => void
  onBusy: (busy: boolean) => void
  onMerged: (target: Person) => void
}) {
  const directory = usePeopleDirectory()
  const [target, setTarget] = React.useState<string | null>(null)
  const [error, setError] = React.useState<string | null>(null)
  const [saving, setSaving] = React.useState(false)
  const candidates = directory.people.filter((item) => item.uuid !== person.uuid)

  const submit = async () => {
    if (!target) {
      setError("Choose who to merge into")
      return
    }
    setError(null)
    setSaving(true)
    onBusy(true)
    try {
      const merged = await peopleApi.mergePerson(person.uuid, target)
      toast.success(`Merged ${person.name} into ${merged.name}`)
      void refreshPeopleDirectory()
      onMerged(merged)
    } catch (err) {
      setError(errorMessage(err))
    } finally {
      setSaving(false)
      onBusy(false)
    }
  }

  let body: React.ReactNode
  if (!directory.loaded) {
    body = (
      <div className="flex items-center gap-2 text-[13px] text-text-3">
        <Spinner />
        Loading people
      </div>
    )
  } else if (candidates.length === 0) {
    body = <p className="text-[13px] text-text-3">{directory.error ?? "There is nobody else to merge into yet."}</p>
  } else {
    body = (
      <ChoiceList
        label="Merge into"
        value={target}
        onChange={(value) => {
          setTarget(value)
          setError(null)
        }}
        choices={candidates.map((item) => ({
          value: item.uuid,
          label: item.name,
          color: item.color,
          detail: samplesLabel(item.sample_count),
          crops: [item.sample],
        }))}
      />
    )
  }

  return (
    <>
      <DialogHeader>
        <DialogTitle>Merge {person.name}</DialogTitle>
        <DialogDescription>
          Every face sample and face event of {person.name} moves to the person you choose, and {person.name} is
          removed. This cannot be undone.
        </DialogDescription>
      </DialogHeader>
      <DialogBody className="flex flex-col gap-3">
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

export function MergePersonDialog({
  person,
  onOpenChange,
  onMerged,
}: {
  person: Person | null
  onOpenChange: (open: boolean) => void
  onMerged: (source: Person, target: Person) => void
}) {
  const [busy, setBusy] = React.useState(false)
  return (
    <Dialog open={person !== null} onOpenChange={(open) => !busy && onOpenChange(open)}>
      <DialogContent>
        {person ? (
          <MergePersonForm
            key={person.uuid}
            person={person}
            onCancel={() => onOpenChange(false)}
            onBusy={setBusy}
            onMerged={(target) => {
              onMerged(person, target)
              onOpenChange(false)
            }}
          />
        ) : null}
      </DialogContent>
    </Dialog>
  )
}
