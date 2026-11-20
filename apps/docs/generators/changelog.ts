import { execFileSync } from "node:child_process"

import { escape } from "./markdown.ts"
import { repoRoot, writeGenerated } from "./sources.ts"

/** One commit, read from git. */
interface Commit {
  hash: string
  date: string
  type: string
  scope: string
  breaking: boolean
  description: string
}

const SECTIONS: { title: string; pick: (commit: Commit) => boolean }[] = [
  { title: "Breaking changes", pick: (commit) => commit.breaking },
  { title: "Features", pick: (commit) => commit.type === "feat" && !commit.breaking },
  { title: "Fixes", pick: (commit) => commit.type === "fix" && !commit.breaking },
  { title: "Performance", pick: (commit) => commit.type === "perf" && !commit.breaking },
  { title: "Reverts", pick: (commit) => commit.type === "revert" && !commit.breaking },
]

const HEADER = /^(\w+)(?:\(([^)]+)\))?(!)?: (.+)$/

/**
 * Read the commits of the checked-out branch that follow Conventional Commits.
 *
 * @returns The commits, newest first.
 */
function readCommits(): Commit[] {
  const output = execFileSync(
    "git",
    ["-C", process.env.DOCS_GIT_DIR || repoRoot, "log", "--no-merges", "--format=%h%x1f%as%x1f%s%x1f%b%x1e"],
    { encoding: "utf8", maxBuffer: 64 * 1024 * 1024 },
  )
  const commits: Commit[] = []
  for (const record of output.split("\x1e")) {
    const [hash, date, subject, body] = record.trim().split("\x1f")
    const header = subject ? HEADER.exec(subject) : null
    if (!hash || !header) continue
    commits.push({
      hash,
      date,
      type: header[1],
      scope: header[2] ?? "",
      breaking: Boolean(header[3]) || /^BREAKING[ -]CHANGE: /m.test(body ?? ""),
      description: header[4],
    })
  }
  return commits
}

/**
 * Write the changelog: features, fixes, performance work, reverts and breaking changes by day, from the commit
 * history, which follows Conventional Commits.
 *
 * @returns Number of entries, for the build log.
 */
export function generateChangelog(): string {
  const commits = readCommits()
  const days = new Map<string, Commit[]>()
  for (const commit of commits) days.set(commit.date, [...(days.get(commit.date) ?? []), commit])
  const lines: string[] = []
  let entries = 0
  for (const [day, dayCommits] of days) {
    const sections = SECTIONS.map((section) => ({ title: section.title, commits: dayCommits.filter(section.pick) })).filter(
      (section) => section.commits.length,
    )
    if (!sections.length) continue
    lines.push(`## ${day}`, "")
    for (const section of sections) {
      lines.push(`### ${section.title}`, "")
      for (const commit of section.commits) {
        entries += 1
        lines.push(`- ${commit.scope ? `${escape(commit.scope)}: ` : ""}${escape(commit.description)} (${commit.hash})`)
      }
      lines.push("")
    }
  }
  writeGenerated(
    "changelog.md",
    [
      `Generated from the commit history: ${entries} entries from ${commits.length} conventional commits. Documentation, style, refactoring, test and build commits are left out unless they break something.`,
      "",
      ...lines,
    ].join("\n"),
  )
  return `${entries} entries`
}
