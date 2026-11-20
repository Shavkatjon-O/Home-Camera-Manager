/** Name of the product as people see it. */
export const productName = "Smart Surveillance"

/** Full name of the system the site documents. */
export const systemName = "Smart Surveillance System"

/** GitHub owner and repository of the system. */
export const repository = {
  owner: "Shavkatjon-O",
  name: "Smart-Surveillance-System",
  branch: "main",
}

/** Address of the repository on GitHub. */
export const repositoryUrl = `https://github.com/${repository.owner}/${repository.name}`

/** Path prefix the site is served under, such as the repository name on GitHub Pages, without a trailing slash. */
export const basePath = process.env.NEXT_PUBLIC_DOCS_BASE_PATH ?? ""

/**
 * Prefix a site path with the base path, for addresses that bypass the router, such as the search index.
 *
 * @param path Path starting with a slash.
 * @returns The path under the base path.
 */
export function withBasePath(path: string): string {
  return `${basePath}${path}`
}
