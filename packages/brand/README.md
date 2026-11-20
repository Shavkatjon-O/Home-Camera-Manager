# Brand

The Smart Surveillance mark and its variants. Every product draws its logo from these files, so the mark has one source.

The mark is an eye drawn as an almond outline with a filled pupil, and a small red dot at its upper right that stands for a live camera. It sits on a 24 by 24 grid with a stroke of 2.

| File | Use |
|---|---|
| mark.svg | The mark on light backgrounds |
| mark-dark.svg | The mark on dark backgrounds |
| mark-mono.svg | One colour, taken from currentColor, for notification icons, favicons and embossing |
| wordmark.svg | The mark with the product name set in Geist SemiBold |
| launcher-foreground.svg | Adaptive launcher icon foreground on a 108 by 108 canvas, with the mark inside the 66 unit safe zone |
| launcher-background.svg | Adaptive launcher icon background |

## Colours

| Name | Light | Dark |
|---|---|---|
| Mark | #171717 | #EDEDED |
| Live dot | #E5484D | #F2555A |
| Icon background | #0A0A0A | #0A0A0A |

## Rules

- Keep the proportions and the stroke; scale the whole mark, never parts of it.
- Leave clear space of at least a quarter of the mark's width around it.
- The live dot is the only colour in the mark; the monochrome variant drops it to the mark's colour.
- The mobile app draws the same paths in code (apps/mobile/lib/core/widgets/logo.dart) and in Android vector drawables (apps/mobile/android/app/src/main/res/drawable). Change them together with these files.
