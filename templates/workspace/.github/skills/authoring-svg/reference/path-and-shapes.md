# SVG paths and basic shapes

Reference for the `authoring-svg` skill: the coordinate system, basic-shape parameters, and the
`<path>` command language. Keep the main file lean; look here when you need exact syntax.

## Coordinate system

- The origin `(0, 0)` is the **top-left**. X grows right, **Y grows down** (the opposite of maths).
- All coordinates are in viewBox user units, not pixels. `viewBox="0 0 24 24"` gives a 24x24 field
  that scales to the rendered size of the `<svg>`.
- The SVG field is conceptually infinite - shapes can sit anywhere - but only the viewBox region is
  visible.

## Basic shapes (full parameters)

```svg
<line   x1="10" y1="10" x2="90" y2="90" stroke="currentColor" stroke-width="2" />
<rect   x="10" y="10" width="80" height="50" rx="8" ry="8" />
<circle cx="50" cy="50" r="40" />
<ellipse cx="50" cy="50" rx="45" ry="30" />
<polygon  points="50,5 90,90 10,90" />          <!-- closed: last point joins first -->
<polyline points="10,80 40,20 70,60 95,10" fill="none" />  <!-- open -->
<text x="10" y="50" font-size="16">Label</text>
```

- `<line>` is invisible without a `stroke` - it has no fill.
- `<rect>` `rx`/`ry` round the corners like `border-radius`; one value mirrors to the other.
- A `<rect>` with `width` or `height` of 0 (or a circle with `r="0"`) is a degenerate shape and does
  not render - it does not collapse to a line.
- `<polygon>` auto-closes back to the first point; `<polyline>` stays open (give it `fill="none"`
  unless you want the implied closing region filled).
- Outline `<text>` to paths for logos and icons so rendering does not depend on a font being present.

## The `<path>` element

`<path d="...">` draws any shape by chaining commands in the `d` attribute. **Uppercase = absolute
coordinates; lowercase = relative** to the current point. Numbers may be separated by spaces or commas.

### Command summary

| Command | Name | Parameters | Effect |
|---------|------|------------|--------|
| `M` / `m` | Move to | `x y` | Lift the pen and move (starts a subpath; no line drawn) |
| `L` / `l` | Line to | `x y` | Straight line to the point |
| `H` / `h` | Horizontal line | `x` | Horizontal line to x |
| `V` / `v` | Vertical line | `y` | Vertical line to y |
| `C` / `c` | Cubic Bézier | `x1 y1 x2 y2 x y` | Curve using two control points |
| `S` / `s` | Smooth cubic | `x2 y2 x y` | Cubic that reflects the previous control point |
| `Q` / `q` | Quadratic Bézier | `x1 y1 x y` | Curve using one control point |
| `T` / `t` | Smooth quadratic | `x y` | Quadratic that reflects the previous control point |
| `A` / `a` | Elliptical arc | `rx ry rot large-arc sweep x y` | Arc of an ellipse to the point |
| `Z` / `z` | Close path | - | Straight line back to the subpath start |

### Worked examples

```svg
<!-- Triangle with straight lines -->
<path d="M 50 10 L 90 90 L 10 90 Z" />

<!-- Rounded tick / check mark -->
<path d="M4 12 l5 5 L20 5" fill="none" stroke="currentColor"
      stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />

<!-- Smooth wave with cubic Béziers -->
<path d="M0 50 C 25 10, 75 90, 100 50" fill="none" stroke="currentColor" />

<!-- Quadratic curve: one control point -->
<path d="M10 80 Q 50 10 90 80" fill="none" stroke="currentColor" />

<!-- Arc: rx ry x-rotation large-arc-flag sweep-flag end-x end-y -->
<path d="M30 50 A 20 20 0 1 1 70 50" fill="none" stroke="currentColor" />
```

### Bézier curves

- **Quadratic (`Q`)** has one control point that both ends pull toward - good for simple arcs.
- **Cubic (`C`)** has two control points (one per end) - more control, S-curves and complex shapes.
- `S`/`T` continue a curve smoothly by reflecting the previous control point, so you give fewer
  numbers; use them for flowing multi-segment curves.

### Arc flags (`A`)

- `rx ry` = ellipse radii; `rot` = x-axis rotation in degrees.
- `large-arc-flag` (0/1) picks the smaller or larger of the two arc sweeps.
- `sweep-flag` (0/1) picks clockwise vs counter-clockwise.
- The four flag/radius combinations give four possible arcs between the same two points - flip the
  flags if the curve bends the wrong way.

## Reusing and transforming

- `<g>` groups elements so a `transform`, `fill`, or `opacity` applies to all of them. Keep groups
  only where they earn their place; flatten the rest when optimizing.
- `transform` supports `translate(x y)`, `scale(s)`, `rotate(deg cx cy)`, `skewX`, `skewY`, `matrix`.
- `<defs>` holds reusable definitions (gradients, clip paths, symbols) that are not drawn directly.
- `<use href="#id" />` clones a defined element - the basis of sprites (see the delivery reference).
- `<clipPath>` clips to a shape; `<mask>` blends with greyscale/alpha. Reference both by `id`.
