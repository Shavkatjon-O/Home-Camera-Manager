/** How the console picks its colours: follow the device, or always light, or always dark. */
export type ThemeChoice = "system" | "light" | "dark"

/** The key in localStorage that keeps this browser's theme choice. */
export const THEME_KEY = "sss-theme"

/** Script for the document head that applies the stored choice before the first paint. */
export const THEME_SCRIPT = `try{var t=localStorage.getItem("${THEME_KEY}");if(t==="light"||t==="dark")document.documentElement.dataset.theme=t}catch(e){}`
