"use client"

import * as React from "react"
import { useRouter, useSearchParams } from "next/navigation"
import { CircleAlertIcon, LockIcon, PlusIcon, ScanFaceIcon, UsersRoundIcon, XIcon } from "lucide-react"
import { toast } from "sonner"

import { useEvents } from "@/components/events/events-provider"
import { ClusterCard, type ClusterActions } from "@/components/people/cluster-card"
import { DeleteClusterDialog, MergeClusterDialog, NameClusterDialog } from "@/components/people/cluster-dialogs"
import { Pager } from "@/components/people/pager"
import { refreshPeopleDirectory } from "@/components/people/people-directory"
import { PersonCard, type PersonActions } from "@/components/people/person-card"
import { DeletePersonDialog, MergePersonDialog, PersonFormDialog } from "@/components/people/person-dialogs"
import { PhotoUploadDialog, usePhotoUpload } from "@/components/people/photo-upload"
import { usePagedQuery } from "@/components/people/use-paged"
import { CardGrid, PageContent, PageFrame } from "@/components/shell/page-frame"
import { Chip, EmptyState, LoadingState } from "@/components/shell/primitives"
import { RoleGate } from "@/components/shell/role-gate"
import { Button } from "@/components/ui/button"
import { ApiError, errorMessage, isAbort } from "@/lib/api"
import { isFaceKind, peopleApi, peopleLabel, personHref, type Cluster, type Person, type Sample } from "@/lib/people"

const PEOPLE_PAGE_SIZE = 24
const CLUSTER_PAGE_SIZE = 12
const LIVE_REFRESH_MS = 10000

const loadPeople = (page: number, signal: AbortSignal) =>
  peopleApi.listPeople({ page, page_size: PEOPLE_PAGE_SIZE }, signal)

const loadClusters = (page: number, signal: AbortSignal) =>
  peopleApi.listClusters({ page, page_size: CLUSTER_PAGE_SIZE }, signal)

function Section({
  title,
  count,
  action,
  children,
}: {
  title: string
  count?: number | null
  action?: React.ReactNode
  children: React.ReactNode
}) {
  return (
    <section className="flex flex-col gap-2">
      <div className="flex min-h-7 items-center justify-between gap-2">
        <div className="flex items-baseline gap-2">
          <h2 className="text-xs text-text-3">{title}</h2>
          {count !== undefined && count !== null ? (
            <span className="font-data text-[11px] text-text-3">{count}</span>
          ) : null}
        </div>
        {action}
      </div>
      {children}
    </section>
  )
}

function LoadError({ title, error, onRetry }: { title: string; error: string; onRetry: () => void }) {
  return (
    <EmptyState icon={<CircleAlertIcon />} title={title} className="min-h-40 rounded-lg border border-hairline">
      <span className="font-data text-xs">{error}</span>
      <Button variant="outline" onClick={onRetry}>
        Try again
      </Button>
    </EmptyState>
  )
}

interface Focused {
  uuid: string
  person: Person | null
  error: string | null
  missing: boolean
}

function PeopleView() {
  const params = useSearchParams()
  const router = useRouter()
  const focus = params.get("person")
  const { subscribe } = useEvents()
  const people = usePagedQuery<Person>("people", loadPeople, PEOPLE_PAGE_SIZE)
  const clusters = usePagedQuery<Cluster>("clusters", loadClusters, CLUSTER_PAGE_SIZE)
  const { refresh: refreshPeople, update: updatePeople } = people
  const { refresh: refreshClusters } = clusters
  const upload = usePhotoUpload()
  const [focused, setFocused] = React.useState<Focused | null>(null)
  const [focusReload, setFocusReload] = React.useState(0)
  const [formOpen, setFormOpen] = React.useState(false)
  const [editing, setEditing] = React.useState<Person | null>(null)
  const [deleting, setDeleting] = React.useState<Person | null>(null)
  const [merging, setMerging] = React.useState<Person | null>(null)
  const [uploadFor, setUploadFor] = React.useState<Person | null>(null)
  const [naming, setNaming] = React.useState<Cluster | null>(null)
  const [mergingCluster, setMergingCluster] = React.useState<Cluster | null>(null)
  const [deletingCluster, setDeletingCluster] = React.useState<Cluster | null>(null)
  const liveTimer = React.useRef(0)

  React.useEffect(() => {
    if (!focus) return
    const controller = new AbortController()
    peopleApi
      .getPerson(focus, controller.signal)
      .then((person) => setFocused({ uuid: focus, person, error: null, missing: false }))
      .catch((err: unknown) => {
        if (isAbort(err)) return
        const missing = err instanceof ApiError && err.status === 404
        setFocused({ uuid: focus, person: null, error: errorMessage(err), missing })
      })
    return () => controller.abort()
  }, [focus, focusReload])

  React.useEffect(() => {
    const unsubscribe = subscribe((event) => {
      const kind: string = event.kind
      if (!isFaceKind(kind) || liveTimer.current) return
      liveTimer.current = window.setTimeout(() => {
        liveTimer.current = 0
        refreshPeople()
        refreshClusters()
      }, LIVE_REFRESH_MS)
    })
    return () => {
      unsubscribe()
      window.clearTimeout(liveTimer.current)
      liveTimer.current = 0
    }
  }, [subscribe, refreshPeople, refreshClusters])

  const shownFocus = focus && focused && focused.uuid === focus ? focused : null

  const replacePerson = React.useCallback(
    (person: Person) => {
      updatePeople((data) => ({
        ...data,
        items: data.items.map((item) => (item.uuid === person.uuid ? person : item)),
      }))
      setFocused((current) => (current && current.uuid === person.uuid ? { ...current, person } : current))
    },
    [updatePeople],
  )

  const clearFocus = () => router.replace("/people/", { scroll: false })

  const personActions: PersonActions = {
    onPhotos: (person, files) => {
      if (upload.running) {
        toast.error("Wait for the photos being added now to finish")
        return
      }
      setUploadFor(person)
      void upload.start(person.uuid, files, replacePerson)
    },
    onEdit: (person) => {
      setEditing(person)
      setFormOpen(true)
    },
    onMerge: (person) => {
      void refreshPeopleDirectory()
      setMerging(person)
    },
    onDelete: (person) => setDeleting(person),
    onRemoveSample: async (person: Person, sample: Sample) => {
      try {
        await peopleApi.deleteSample(person.uuid, sample.uuid)
        replacePerson({
          ...person,
          samples: person.samples.filter((item) => item.uuid !== sample.uuid),
          sample_count: Math.max(0, person.sample_count - 1),
          upload_count: sample.source === "upload" ? Math.max(0, person.upload_count - 1) : person.upload_count,
        })
        toast.success(`Removed a sample of ${person.name}`)
        void refreshPeopleDirectory()
      } catch (err) {
        toast.error(errorMessage(err))
      }
    },
    onShowAll: async (person: Person) => {
      try {
        replacePerson(await peopleApi.getPerson(person.uuid))
      } catch (err) {
        toast.error(errorMessage(err))
      }
    },
  }

  const clusterActions: ClusterActions = {
    onName: (cluster) => {
      void refreshPeopleDirectory()
      setNaming(cluster)
    },
    onMerge: (cluster) => setMergingCluster(cluster),
    onDelete: (cluster) => setDeletingCluster(cluster),
  }

  const openAdd = () => {
    setEditing(null)
    setFormOpen(true)
  }

  const closeUpload = () => {
    setUploadFor(null)
    upload.reset()
    refreshPeople()
    void refreshPeopleDirectory()
  }

  let peopleContent: React.ReactNode
  if (!people.data && people.error) {
    peopleContent = <LoadError title="Cannot load people" error={people.error} onRetry={refreshPeople} />
  } else if (!people.data) {
    peopleContent = <LoadingState label="Loading people" className="min-h-40" />
  } else if (people.data.total === 0) {
    peopleContent = (
      <EmptyState icon={<UsersRoundIcon />} title="No people yet" className="min-h-40 rounded-lg border border-hairline">
        <span>Add someone with a few clear photos of their face, or name one of the unknown faces below.</span>
        <Button variant="outline" onClick={openAdd}>
          <PlusIcon />
          Add person
        </Button>
      </EmptyState>
    )
  } else {
    peopleContent = (
      <>
        <CardGrid>
          {people.data.items.map((person) => (
            <PersonCard
              key={person.uuid}
              person={person}
              highlighted={person.uuid === focus}
              actions={personActions}
            />
          ))}
        </CardGrid>
        {people.data.total > PEOPLE_PAGE_SIZE || people.error ? (
          <Pager
            page={people.page}
            pageSize={PEOPLE_PAGE_SIZE}
            total={people.data.total}
            error={people.error}
            onPage={people.setPage}
            className="pt-1"
          />
        ) : null}
      </>
    )
  }

  let clusterContent: React.ReactNode
  if (!clusters.data && clusters.error) {
    clusterContent = <LoadError title="Cannot load unknown faces" error={clusters.error} onRetry={refreshClusters} />
  } else if (!clusters.data) {
    clusterContent = <LoadingState label="Loading unknown faces" className="min-h-40" />
  } else if (clusters.data.total === 0) {
    clusterContent = (
      <EmptyState icon={<ScanFaceIcon />} title="No unknown faces" className="min-h-40 rounded-lg border border-hairline">
        <span>Faces the cameras cannot match to anyone gather here, grouped by who they look like.</span>
      </EmptyState>
    )
  } else {
    clusterContent = (
      <>
        <CardGrid>
          {clusters.data.items.map((cluster) => (
            <ClusterCard key={cluster.uuid} cluster={cluster} actions={clusterActions} />
          ))}
        </CardGrid>
        {clusters.data.total > CLUSTER_PAGE_SIZE || clusters.error ? (
          <Pager
            page={clusters.page}
            pageSize={CLUSTER_PAGE_SIZE}
            total={clusters.data.total}
            error={clusters.error}
            previousLabel="Newer"
            nextLabel="Older"
            onPage={clusters.setPage}
            className="pt-1"
          />
        ) : null}
      </>
    )
  }

  let focusContent: React.ReactNode = null
  if (focus) {
    if (!shownFocus) {
      focusContent = <LoadingState label="Loading person" className="min-h-40" />
    } else if (shownFocus.person) {
      focusContent = (
        <CardGrid>
          <PersonCard person={shownFocus.person} highlighted actions={personActions} />
        </CardGrid>
      )
    } else if (shownFocus.missing) {
      focusContent = (
        <EmptyState icon={<UsersRoundIcon />} title="Person not found" className="min-h-40 rounded-lg border border-hairline">
          <span>This person was deleted or merged into someone else.</span>
        </EmptyState>
      )
    } else {
      focusContent = (
        <LoadError
          title="Cannot load this person"
          error={shownFocus.error ?? "Something went wrong"}
          onRetry={() => setFocusReload((value) => value + 1)}
        />
      )
    }
  }

  const actions = (
    <Button onClick={openAdd}>
      <PlusIcon />
      <span className="hidden sm:inline">Add person</span>
      <span className="sm:hidden">Add</span>
    </Button>
  )

  return (
    <PageFrame status={people.data ? <Chip>{peopleLabel(people.data.total)}</Chip> : null} actions={actions} contained>
      <main className="@container min-h-0 min-w-0 flex-1 overflow-y-auto">
        <PageContent>
          <p className="flex items-start gap-2 text-[12px] text-text-3">
            <LockIcon aria-hidden className="mt-px size-3.5 shrink-0" />
            Faces are processed and stored only on the servers that run this installation&apos;s analytics. They are
            never sent to third parties, and you can delete them at any time.
          </p>
          {focus ? (
            <Section
              title="Selected person"
              action={
                <Button variant="ghost" size="sm" onClick={clearFocus}>
                  <XIcon />
                  Show everyone
                </Button>
              }
            >
              {focusContent}
            </Section>
          ) : null}
          <Section title="Known people" count={people.data?.total}>
            {peopleContent}
          </Section>
          <Section title="Unknown faces" count={clusters.data?.total}>
            {clusterContent}
          </Section>
        </PageContent>
      </main>
      <PersonFormDialog
        open={formOpen}
        person={editing}
        onOpenChange={(open) => {
          setFormOpen(open)
          if (!open) refreshPeople()
        }}
        onSaved={replacePerson}
      />
      <PhotoUploadDialog person={uploadFor} upload={upload} onClose={closeUpload} />
      <DeletePersonDialog
        person={deleting}
        onOpenChange={(open) => {
          if (!open) setDeleting(null)
        }}
        onDeleted={(person) => {
          refreshPeople()
          if (person.uuid === focus) clearFocus()
        }}
      />
      <MergePersonDialog
        person={merging}
        onOpenChange={(open) => {
          if (!open) setMerging(null)
        }}
        onMerged={(source, target) => {
          refreshPeople()
          if (source.uuid === focus) router.replace(personHref(target.uuid), { scroll: false })
          else if (target.uuid === focus) setFocusReload((value) => value + 1)
        }}
      />
      <NameClusterDialog
        cluster={naming}
        onOpenChange={(open) => {
          if (!open) setNaming(null)
        }}
        onNamed={(cluster, person) => {
          refreshClusters()
          refreshPeople()
          if (person.uuid === focus) setFocusReload((value) => value + 1)
        }}
      />
      <MergeClusterDialog
        cluster={mergingCluster}
        onOpenChange={(open) => {
          if (!open) setMergingCluster(null)
        }}
        onMerged={() => refreshClusters()}
      />
      <DeleteClusterDialog
        cluster={deletingCluster}
        onOpenChange={(open) => {
          if (!open) setDeletingCluster(null)
        }}
        onDeleted={() => refreshClusters()}
      />
    </PageFrame>
  )
}

/** The People page: known people with their face photos, and the unknown faces the cameras grouped. */
export function PeoplePage() {
  return (
    <RoleGate minRole="admin">
      <React.Suspense
        fallback={
          <PageFrame>
            <main className="min-w-0 flex-1">
              <LoadingState label="Loading people" />
            </main>
          </PageFrame>
        }
      >
        <PeopleView />
      </React.Suspense>
    </RoleGate>
  )
}
