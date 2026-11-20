"use client"

import * as React from "react"
import { useRouter, useSearchParams } from "next/navigation"
import { ImageUpIcon } from "lucide-react"
import { toast } from "sonner"

import { PHOTO_ACCEPT } from "@/components/people/photo-upload"
import { AppearanceResults } from "@/components/search/appearance-results"
import type { SimilarTarget } from "@/components/search/result-parts"
import { SearchFiltersBar } from "@/components/search/search-filters"
import {
  EMPTY_FILTERS,
  readSearchState,
  searchHrefFor,
  type Layout,
  type SearchFilters,
  type SearchState,
} from "@/components/search/search-params"
import { SearchResults } from "@/components/search/search-results"
import { SimilarResults, type SimilarSource } from "@/components/search/similar-results"
import { AppFrame } from "@/components/shell/app-frame"
import { LoadingState, Spinner } from "@/components/shell/primitives"
import { Segmented } from "@/components/shell/segmented"
import { useSession } from "@/components/shell/session"
import { Button } from "@/components/ui/button"
import { errorMessage, eventImageUrl } from "@/lib/api"
import { downscalePhoto, peopleApi, sampleCropUrl, type Facets } from "@/lib/people"

const LAYOUT_OPTIONS: { value: Layout; label: string }[] = [
  { value: "list", label: "List" },
  { value: "grid", label: "Grid" },
]

interface PhotoQuery {
  id: number
  data: string
}

function SearchView() {
  const params = useSearchParams()
  const router = useRouter()
  const { cameras } = useSession()
  const state = React.useMemo(() => readSearchState(params), [params])
  const [facets, setFacets] = React.useState<Facets | null>(null)
  const [photo, setPhoto] = React.useState<PhotoQuery | null>(null)
  const [preparing, setPreparing] = React.useState(false)
  const fileRef = React.useRef<HTMLInputElement>(null)
  const photoCount = React.useRef(0)

  React.useEffect(() => {
    const controller = new AbortController()
    peopleApi
      .facets(controller.signal)
      .then(setFacets)
      .catch(() => undefined)
    return () => controller.abort()
  }, [])

  const replace = React.useCallback(
    (next: SearchState) => router.replace(searchHrefFor(next), { scroll: false }),
    [router],
  )

  const changeFilters = (change: Partial<SearchFilters>) =>
    replace({ ...state, filters: { ...state.filters, ...change }, page: 1 })

  const clear = () => replace({ ...state, filters: { ...EMPTY_FILTERS }, page: 1 })

  const changePage = React.useCallback((page: number) => replace({ ...state, page }), [replace, state])

  const changeLayout = (layout: Layout) => replace({ ...state, layout })

  const findSimilar = (target: SimilarTarget) => {
    if (!target.sample && !target.event) return
    setPhoto(null)
    router.push(
      searchHrefFor({
        ...state,
        similar: target.sample ?? null,
        similarEvent: target.sample ? null : (target.event ?? null),
        appearance: null,
      }),
      { scroll: false },
    )
  }

  const findPerson = (eventUuid: string) => {
    setPhoto(null)
    router.push(searchHrefFor({ ...state, similar: null, similarEvent: null, appearance: eventUuid }), {
      scroll: false,
    })
  }

  const back = () => {
    setPhoto(null)
    if (state.similar || state.similarEvent || state.appearance) {
      replace({ ...state, similar: null, similarEvent: null, appearance: null })
    }
  }

  const choosePhoto = () => fileRef.current?.click()

  const searchPhoto = async (file: File) => {
    setPreparing(true)
    try {
      const data = await downscalePhoto(file)
      photoCount.current += 1
      setPhoto({ id: photoCount.current, data })
      if (state.similar || state.similarEvent || state.appearance) {
        replace({ ...state, similar: null, similarEvent: null, appearance: null })
      }
    } catch (err) {
      toast.error(errorMessage(err))
    } finally {
      setPreparing(false)
    }
  }

  const source = React.useMemo<SimilarSource | null>(() => {
    if (photo) return { key: `photo-${photo.id}`, kind: "photo", query: { photo: photo.data }, preview: photo.data }
    if (state.similar) {
      return {
        key: `sample-${state.similar}`,
        kind: "sample",
        query: { sample: state.similar },
        preview: sampleCropUrl(state.similar),
      }
    }
    if (state.similarEvent) {
      return {
        key: `event-${state.similarEvent}`,
        kind: "event",
        query: { event: state.similarEvent },
        preview: eventImageUrl(state.similarEvent, true),
      }
    }
    return null
  }, [photo, state.similar, state.similarEvent])

  const layoutToggle = (
    <Segmented<Layout> label="Layout" value={state.layout} options={LAYOUT_OPTIONS} onChange={changeLayout} />
  )

  const actions = (
    <>
      <input
        ref={fileRef}
        type="file"
        accept={PHOTO_ACCEPT}
        className="hidden"
        aria-label="Photo to search with"
        onChange={(event) => {
          const file = event.target.files?.[0]
          event.target.value = ""
          if (file) void searchPhoto(file)
        }}
      />
      <Button onClick={choosePhoto} disabled={preparing} aria-label="Find similar from a photo">
        {preparing ? <Spinner className="size-3.5 text-primary-foreground" /> : <ImageUpIcon />}
        <span className="hidden lg:inline">Find similar from a photo</span>
        <span className="hidden sm:inline lg:hidden">From a photo</span>
      </Button>
    </>
  )

  return (
    <AppFrame actions={actions}>
      <main className="@container min-h-0 min-w-0 flex-1 overflow-y-auto">
        {state.appearance && !photo ? (
          <AppearanceResults
            key={state.appearance}
            eventUuid={state.appearance}
            layout={state.layout}
            toolbar={layoutToggle}
            onBack={back}
            onFindPerson={findPerson}
          />
        ) : source ? (
          <SimilarResults
            key={source.key}
            source={source}
            layout={state.layout}
            toolbar={layoutToggle}
            onBack={back}
            onFind={findSimilar}
            onAnotherPhoto={choosePhoto}
          />
        ) : (
          <div className="flex min-h-full flex-col">
            <div className="border-b border-hairline px-3 py-3 sm:px-4">
              <SearchFiltersBar
                filters={state.filters}
                facets={facets}
                cameras={cameras}
                onChange={changeFilters}
                onClear={clear}
              />
            </div>
            <div className="min-h-0 flex-1">
              <SearchResults
                filters={state.filters}
                page={state.page}
                layout={state.layout}
                toolbar={layoutToggle}
                onPage={changePage}
                onFind={findSimilar}
                onFindPerson={findPerson}
              />
            </div>
          </div>
        )}
      </main>
    </AppFrame>
  )
}

export function SearchPage() {
  return (
    <React.Suspense
      fallback={
        <AppFrame>
          <main className="min-w-0 flex-1">
            <LoadingState label="Loading search" />
          </main>
        </AppFrame>
      }
    >
      <SearchView />
    </React.Suspense>
  )
}
