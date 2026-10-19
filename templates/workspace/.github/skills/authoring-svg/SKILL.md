---
name: authoring-svg
description: Hand-writes clean, scalable, accessible SVG - icons, logos, illustrations, charts, and spinners - with a tight viewBox, currentColor theming, correct accessibility, and SVGO optimization. Use when the user wants to create, edit, clean up, optimize, or animate an SVG, build an icon set or sprite, fix a logo that renders too small or with a white box, or embed inline SVG in HTML/JSX/Angular.
---

# Authoring SVG

**Best model:** Act tier (GPT-6.1 Sol) via the SVG Designer or Implementer when writing or editing files; Plan tier (Claude Sonnet 5.5) for designing an icon system or sprite strategy; Quick tier (GPT-6 Luna) for a one-off icon tweak.

SVG is XML: an illustration described as drawing instructions, not pixels. Because each shape is a
DOM node, you can style and animate SVG with the same CSS/JS you already use - which is why **inline
SVG written by hand** is usually better than a single opaque `<path>` exported from a design tool.
Write SVGs in a `.svg` file (or inline in a component), keep them readable, then optimize on the way out.

## Workflow

Copy this checklist and tick items as you go:

```
SVG progress:
- [ ] 1. State the goal, target size(s), and delivery method (inline / <img> / sprite)
- [ ] 2. Set a tight viewBox around the artwork; drop fixed width/height
- [ ] 3. Draw with the simplest primitives; name/group only what CSS or JS must target
- [ ] 4. Theme with fill/stroke = currentColor; add accessibility (title or aria-hidden)
- [ ] 5. Optimize (SVGO / manual cleanup) and verify it still renders crisp at the target sizes
```

1. Decide the **delivery method** first (see [reference/optimization-and-delivery.md](reference/optimization-and-delivery.md));
   it changes how you write the file. Inline for styling/animation; `<img>`/CSS background for a
   static image; a `<symbol>`/`<use>` sprite for an icon set.
2. Choose a single **artboard size** for a family of graphics (e.g. `0 0 24 24` for icons) so they
   scale uniformly and nothing clips.
3. Build from the smallest set of shapes (table below). Reach for `<path>` only when a primitive
   cannot express the shape. See [reference/path-and-shapes.md](reference/path-and-shapes.md).
4. Keep it themeable and accessible, then run it through SVGO before shipping.

## viewBox is the heart of it

`viewBox="min-x min-y width height"` defines an internal coordinate system. With it, shapes stop
using raw pixels and scale to whatever size the `<svg>` is rendered at - crisp at 16px or 1600px.

- **Prefer `viewBox` over fixed `width`/`height`.** Set the display size in CSS (or the `<img>`),
  and the art fits any context. A hardcoded `width`/`height` on the root locks the size.
- **Crop tight.** The viewBox should hug the artwork. Extra empty space is the #1 reason a logo
  renders tiny - the tool scales the whole canvas, including invisible padding. Trim it
  (e.g. svgcrop.com) or fix the viewBox so the art fills most of the canvas.
- **No background rectangle.** A `<rect>` filling the canvas creates a white box and kills
  transparency. Remove it unless the design truly needs a background.
- The first two viewBox numbers pan; the last two zoom. In practice keep them static so the image
  shows the same thing at every size.

## Basic shapes

| Shape | Key attributes |
|-------|----------------|
| `<line>` | `x1 y1 x2 y2` + `stroke` (invisible without a stroke) |
| `<rect>` | `x y width height`, optional `rx`/`ry` for rounded corners |
| `<circle>` | `cx cy r` |
| `<ellipse>` | `cx cy rx ry` |
| `<polygon>` | `points="x1,y1 x2,y2 ..."` (auto-closes to the first point) |
| `<polyline>` | `points="..."` (open, not closed) |
| `<path>` | `d="..."` - any shape via line/curve/arc commands |
| `<text>` | `x y` + text content (outline to paths for logos to avoid font issues) |

A 2D shape with a zero width or height ("degenerate") does not render. Stroke is drawn centered on
the path edge, straddling inside and outside, and this is not configurable.

```svg
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
     stroke-linecap="round" stroke-linejoin="round" role="img" aria-label="Info">
  <circle cx="12" cy="12" r="10" />
  <line x1="12" y1="8" x2="12" y2="12" />
  <line x1="12" y1="16" x2="12" y2="16" />
</svg>
```

## Fills, strokes, and theming

Shapes are painted with `fill`, outlined with `stroke`, or both. These are **presentational
attributes** that double as CSS properties, so you can set them inline or in a stylesheet, and
animate them with transitions.

- **`fill="currentColor"` / `stroke="currentColor"`** makes the icon inherit the surrounding text
  `color`, so one SVG themes itself anywhere. Prefer this over hardcoded hex for icons.
- Useful stroke properties: `stroke-width`, `stroke-linecap` (`butt`/`round`/`square`),
  `stroke-linejoin`, `stroke-dasharray` (dash, gap), and `stroke-dashoffset`.
- **Line-drawing animation:** set `stroke-dasharray` to the path length (read it with
  `element.getTotalLength()` or override with the `pathLength` attribute) and animate
  `stroke-dashoffset` from that length to 0 to make a shape "draw itself". For a seamless marching
  loop, set the offset equal to dash + gap.
- Keep complex color out of the file: export flat art in a single color and apply color via CSS;
  for gradients, define a `<linearGradient>`/`<radialGradient>` with an id and reference it.

## Accessibility

- **Informative** icon/graphic: give the `<svg>` `role="img"` and a label - either `aria-label="..."`
  or a `<title>` as the first child (referenced by `aria-labelledby`). Add `<desc>` for longer detail.
- **Decorative** icon (next to visible text): add `aria-hidden="true"` and remove the title so screen
  readers skip it. Never strip the title from a standalone informative icon.
- When used in a `<button>`/link with no visible text, the control still needs an accessible name.

## Authoring and optimization notes

- **Write by hand when you want to animate or theme individual parts.** Design tools tend to flatten
  everything into one `<path>`, which is hard to target. For complex illustrations, a tool is fine -
  then clean the export.
- **Keep it readable.** Whitespace, newlines, and commas in `points`/`d` are "superfluous" per the
  spec but gzip removes the cost - readable SVG helps the next developer. Minify only as a build step.
- **Name/class only what you must target.** Give the root a meaningful `id`/`class`; add classes to
  the specific shapes CSS or JS will control. Flatten unnecessary `<g>` groups.
- **Optimize on export:** drop editor metadata (`<desc>`, Figma/Illustrator `<title>`, comments,
  `id`/`version`/tool namespaces), collapse groups, trim path-data precision, and remove root
  `width`/`height` (keep `viewBox`). Run SVGO (`npx svgo in.svg -o out.svg`) or SVGOMG; aim for
  under ~1 KB per icon. Full plugin list, config, and pitfalls in
  [reference/optimization-and-delivery.md](reference/optimization-and-delivery.md).

## Common pitfalls

- Logo looks tiny → oversized viewBox / invisible padding. Crop the canvas; do not just upscale.
- White box behind a "transparent" logo → a background `<rect>` or a PNG wrapped in an SVG. Remove it.
- Icon will not change color from CSS → it has hardcoded `fill`/`stroke`; switch to `currentColor`.
- Blurry when scaled → a raster image embedded via `<image>`; it is not a true vector.
- Shape vanished → zero width/height, or a 2D shape collapsed to one dimension (degenerate).
- Over-precise numbers (`12.000000`) and deep group nesting bloat the file; both are safe to strip.

See the references for the `<path>` command language, basic-shape parameters, SVGO configuration,
accessibility patterns, and the full delivery comparison.
