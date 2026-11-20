/** A node of a Markdown syntax tree, as far as this plugin reads it. */
interface Node {
  type: string
  url?: string
  value?: string
  children?: Node[]
}

const LOCAL = /^https?:\/\/(localhost|127\.\d+\.\d+\.\d+|0\.0\.0\.0)(:\d+)?(\/|$)/

/**
 * Turn bare addresses of the reader's own machine, such as a default of http://127.0.0.1:8750, back into text.
 * Markdown links every bare web address it finds, but these name a server on the reader's machine, which a
 * documentation site must not link to.
 *
 * @returns The transform, which edits the tree in place.
 */
export function remarkPlainAddresses() {
  const visit = (node: Node) => {
    if (!node.children) return
    node.children = node.children.map((child) => {
      const text = child.children?.length === 1 && child.children[0].type === "text" ? child.children[0].value : null
      if (child.type === "link" && child.url && text === child.url && LOCAL.test(child.url)) {
        return { type: "text", value: text }
      }
      visit(child)
      return child
    })
  }
  return (tree: Node) => visit(tree)
}
