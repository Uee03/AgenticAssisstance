# SVG optimization, accessibility, and delivery

Reference for the `authoring-svg` skill: how to strip exported cruft, keep SVGs accessible, and
choose how to put them on the page.

## Why optimize

Exports from Figma/Illustrator/Sketch carry metadata, hidden layers, nested groups, and verbose
markup. On an icon-heavy page this bloats payload, slows parsing, and can cause rendering or
accessibility bugs. Clean SVG downloads faster, renders faster, is easier to audit, and is more
compatible. Target **under ~1 KB per icon** and confirm Lighthouse no longer flags it.

## What a raw export vs a clean icon looks like

```svg
<!-- Raw export: metadata, namespaces, nested groups, hardcoded color, fixed size -->
<svg width="24px" height="24px" viewBox="0 0 24 24" version="1.1"
     xmlns="http://www.w3.org/2000/svg">
  <title>Info</title>
  <desc>Created with Figma</desc>
  <g id="Canvas" fill="none">
    <g id="Info">
      <circle cx="12" cy="12" r="10" stroke="#000" stroke-width="2" />
    </g>
  </g>
</svg>

<!-- Cleaned: tight viewBox, no fixed size, currentColor, flat, themeable -->
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
  <circle cx="12" cy="12" r="10" />
</svg>
```

## Manual cleanup checklist

1. **Remove editor metadata:** `<desc>`, tool-generated `<title>`, comments, `<metadata>`, and
   tool-specific attributes (`version`, Figma/Inkscape/Sketch `id`s and namespaces). Keep
   `xmlns="http://www.w3.org/2000/svg"` for standalone files.
2. **Flatten groups:** collapse or delete empty/redundant `<g>` wrappers. Keep a group only when a
   shared `transform`/`fill` or a CSS/JS target needs it.
3. **Use `viewBox`, drop root `width`/`height`:** let CSS/the `<img>` set the display size.
4. **Theme with `currentColor`:** replace hardcoded `#000`/`#fff` on icons with `currentColor` so
   they follow text color. Keep gradients as `<linearGradient>`/`<radialGradient>` referenced by id.
5. **Trim path data:** cut needless decimals (`12.000000` → `12`), merge adjacent paths of the same
   style where it does not hurt readability.
6. **Remove any background `<rect>`** that fills the canvas (it breaks transparency / adds a white box).

## SVGO

SVGO is the standard optimizer. One-off:

```bash
npx svgo input.svg -o output.svg          # or: npm i -g svgo; svgo ...
```

Project config in `svgo.config.js` (or `.mjs`):

```js
module.exports = {
  plugins: [
    { name: 'preset-default',
      params: { overrides: { removeViewBox: false } } }, // never drop viewBox
    'removeDimensions',        // strip root width/height, keep viewBox
    'removeComments',
    'removeMetadata',
    'cleanupNumericValues',    // trim decimal precision
    'convertColors',           // shorten/normalize colors
    'collapseGroups',
    // 'removeTitle', 'removeDesc'  // only if you are NOT relying on them for a11y
  ],
};
```

- `removeViewBox` is **off** in the override above - dropping the viewBox breaks scaling.
- Do not blindly enable `removeTitle`/`removeDesc` on informative icons; they carry accessibility
  info. Safe for purely decorative icons marked `aria-hidden`.
- GUI/automation: **SVGOMG** (jakearchibald.github.io/svgomg) for drag-and-drop with live settings;
  `svgo-loader` (Webpack) or `vite-plugin-svgo` (Vite) to optimize during the build.

## Accessibility patterns

```svg
<!-- Informative: labelled graphic -->
<svg viewBox="0 0 24 24" role="img" aria-labelledby="t1">
  <title id="t1">Download complete</title>
  <path d="..." fill="currentColor" />
</svg>

<!-- Decorative: hidden from assistive tech (text nearby conveys meaning) -->
<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
  <path d="..." fill="currentColor" />
</svg>

<!-- Icon-only button still needs an accessible name -->
<button aria-label="Close">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18"/></svg>
</button>
```

- Prefer a `<title>` + `aria-labelledby`, or `aria-label`, for standalone meaningful icons.
- `focusable="false"` avoids an extra tab stop in some browsers.
- Never remove the `<title>` from a standalone informative icon during optimization.

## Delivery methods

| Method | How | CSS styling / animation | Extra request | Best for |
|--------|-----|--------------------------|---------------|----------|
| **Inline** `<svg>...</svg>` | Paste markup into HTML/JSX/template | Full - style/animate any node, `currentColor` works | No | Icons you theme/animate; most app UI |
| **`<img src>`** | `<img src="logo.svg" alt="...">` | None (opaque); only sizing | Yes (cached) | Static images, logos you do not restyle |
| **CSS `background-image`** | `background: url(icon.svg)` | None; sizing/position only | Yes (cached) | Decorative backgrounds |
| **`<object data>`** | `<object data="art.svg" type="image/svg+xml">` | Via a stylesheet linked inside the SVG | Yes | Self-contained interactive SVG |
| **Sprite** `<symbol>`+`<use>` | Define symbols once, reference by id | Full when inline | One sprite for many icons | Icon sets - fewer requests, cached once |

Inlining increases HTML size by the SVG's weight (another reason to optimize) but removes a request
and unlocks full CSS/JS control. For many icons, a sprite is usually the best trade-off.

### Sprite pattern

```svg
<!-- Define once (hidden), e.g. at the top of the page or a loaded sprite file -->
<svg style="display:none" aria-hidden="true">
  <symbol id="icon-check" viewBox="0 0 16 16"><path d="M4 8l3 3 5-6"/></symbol>
  <symbol id="icon-close" viewBox="0 0 16 16"><path d="M4 4l8 8M12 4l-8 8"/></symbol>
</svg>

<!-- Reference anywhere; color via currentColor -->
<svg width="16" height="16"><use href="#icon-check" /></svg>
```

### Framework inlining

```jsx
// React/JSX: camelCase attributes, {} for numbers
const CheckIcon = (props) => (
  <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" aria-hidden {...props}>
    <path d="M4 8l4 4 6-6" strokeWidth={2} strokeLinecap="round" />
  </svg>
);
```

In Angular/Vue templates, inline SVG works the same as HTML; bind `class`/`[attr.aria-label]` and
style with `currentColor`. Avoid embedding large CSS/JS inside the SVG unless the interaction truly
needs it - keep icons self-contained and small.

## Measuring impact

- Compare before/after file size (aim < 1 KB per icon).
- Run Lighthouse - it flags unoptimized SVGs as oversized images.
- Use DevTools network/paint profiling to confirm faster loads on icon-heavy pages.
