import { defineI18n } from "fumadocs-core/i18n"

/**
 * Languages of the site. English is written first; Russian and Uzbek join by adding their codes here and their pages
 * under content/docs/ru and content/docs/uz, and a page missing in a language falls back to English.
 */
export const i18n = defineI18n({
  defaultLanguage: "en",
  languages: ["en"],
  parser: "dir",
})

/** A language code of the site. */
export type Language = (typeof i18n.languages)[number]
