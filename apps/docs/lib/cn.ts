import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

/**
 * Join class names and let later Tailwind classes win over earlier ones.
 *
 * @param inputs Class names, lists and condition maps.
 * @returns The merged class string.
 */
export function cn(...inputs: ClassValue[]): string {
  return twMerge(clsx(inputs))
}
