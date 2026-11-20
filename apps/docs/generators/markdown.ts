/**
 * Escape text for a Markdown paragraph or table cell, so names such as regular expressions stay plain text and
 * addresses such as container defaults do not turn into links.
 *
 * @param text The text.
 * @returns The escaped text.
 */
export function escape(text: string): string {
  return text
    .replace(/[\\`*_[\]<>|{}#]/g, (character) => `\\${character}`)
    .replace(/:\/\//g, "\\://")
    .replace(/\bwww\./g, "www\\.")
    .replace(/\s+/g, " ")
    .trim()
}

/**
 * Build a Markdown table whose cells hold plain text only.
 *
 * @param headers Column titles.
 * @param rows Cell texts per row, escaped here.
 * @returns The table.
 */
export function table(headers: string[], rows: string[][]): string {
  const line = (cells: string[]) => `| ${cells.map((cell) => escape(cell) || " ").join(" | ")} |`
  return [line(headers), `|${headers.map(() => "---").join("|")}|`, ...rows.map(line)].join("\n")
}

/**
 * Join words of an identifier, such as media2_encoding, into a phrase.
 *
 * @param identifier The identifier.
 * @returns The phrase.
 */
export function words(identifier: string): string {
  return identifier.replace(/[_-]+/g, " ").trim()
}

/**
 * Join items into a plain list for a sentence or a table cell.
 *
 * @param items The items.
 * @param empty Text when there are none.
 * @returns The list.
 */
export function list(items: readonly string[], empty = "none"): string {
  return items.length ? items.join(", ") : empty
}
