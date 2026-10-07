---
name: primeng-theming
description: Customize the PrimeNG (Aura) theme for this Angular app — brand colors, light/dark palettes, surfaces, form fields, and per-component overrides — and follow current PrimeNG component usage conventions (e.g. buttons). Use whenever the user asks to change colors, theming, dark mode, the look of PrimeNG components, or how to author PrimeNG buttons. Applies to any modern PrimeNG / PrimeUIX version (v19+).
---

# PrimeNG Theming Skill

**Best model:** Act tier (GPT-6.1 Sol) via the Implementer or a scaffolder agent.

> Applies to **any modern PrimeNG version (v19+)** that uses the design-token theming
> system (`definePreset` + `providePrimeNG`). Package names and a few tokens may differ
> slightly between minor versions — verify against the installed `@primeuix/themes`
> (older builds: `@primeng/themes`) rather than assuming. The **structure and rules
> below are stable across versions.**

## Stack facts (this repo)
- PrimeNG on the **Aura** base preset. Theme package is **`@primeuix/themes`**
  (PrimeNG 19+); older projects use `@primeng/themes` — check `package.json`.
- Custom preset: `src/app/core/theme/uee03-preset.ts` — `definePreset(Aura, { semantic, components })`.
- Wired in `src/app/app.config.ts` via `providePrimeNG({ theme: { preset, options } })`.
- Dark mode is **class based**: `darkModeSelector: '.app-dark'`. The `Theme` service
  (`src/app/core/theme/theme.ts`) toggles `.app-dark` on `<html>`, persists to `localStorage`,
  reads OS `prefers-color-scheme`, and is SSR-safe.
- Tailwind (v4) + `tailwindcss-primeui` share the same tokens.

## Architecture (3 tiers — stable across versions)
1. **Primitive** — raw palettes with no meaning (`indigo.500`, `slate.100`).
2. **Semantic** — named roles mapping to primitives (`primary.color`, `text.color`).
3. **Component** — per-component tokens mapping to semantic (`button.background`).

Every token is exposed as a CSS variable `--p-<token>` (e.g. `primary.color` → `var(--p-primary-color)`).

## Rules (always)
1. Put scheme-specific colors under `semantic.colorScheme.light` / `.dark`.
   **Never use CSS `light-dark()`** — it follows the OS `color-scheme`, not the `.app-dark` class.
2. Shared, non-color settings (radius, motion, spacing) go under `semantic` (top level).
3. To change ONE component only, use `components.<name>` — do not edit global `primary.color`.
4. `surface.0` stays white in both schemes (in dark mode it is the light foreground/text).
5. Values in `{curly.braces}` reference other tokens; raw `hex` / `rgb()` / `color-mix()` allowed.
6. Keep `darkModeSelector` in `providePrimeNG` aligned with the class the app toggles (`.app-dark`).
7. After any change, run `npx ng build` and confirm the SSR build is clean.

## Token map (what to change for X)
- **Rebrand:** `semantic.primary` `50..950`.
- **Button/link color / hover / active / on-color:** `colorScheme.<mode>.primary.color` / `.hoverColor` / `.activeColor` / `.contrastColor`.
- **Body text / muted text:** `colorScheme.<mode>.text.color` / `.mutedColor`.
- **Card/panel bg, hover, borders:** `colorScheme.<mode>.content.background` / `.hoverBackground` / `.borderColor`.
- **Surfaces (neutrals):** `colorScheme.<mode>.surface` `0..950`.
- **Selected item:** `colorScheme.<mode>.highlight.background` / `.color` (+ `focusBackground` / `focusColor`).
- **Inputs:** `colorScheme.<mode>.formField.background` / `.borderColor` / `.focusBorderColor` / `.hoverBorderColor` / `.placeholderColor` / `.filledBackground` / `.disabledBackground`; shared `semantic.formField.paddingX|paddingY|borderRadius`.
- **Roundness / focus ring / motion / opacity / icon size:** `semantic.borderRadius.*`, `semantic.focusRing.*`, `semantic.transitionDuration`, `semantic.disabledOpacity`, `semantic.iconSize`. Global scale: `html { font-size }` in `styles.scss`.
- **Dialog dim / overlay panel:** `colorScheme.<mode>.mask.background`, `colorScheme.<mode>.overlay.popover.background`.
- **Per-component:** `components.<name>.root.*` (e.g. `button.root.borderRadius`) or `components.<name>.colorScheme.light/.dark.<part>.<token>`.

## Example — recolor only the text-button (sun/moon) icon
A text-variant, primary-severity button's icon/label color maps to `button.text.primary.color`:

```ts
components: {
  button: {
    colorScheme: {
      light: { text: { primary: { color: '#e11d48' } } },
      dark:  { text: { primary: { color: '#fbbf24' } } },
    },
  },
},
```

## Verifying tokens for the installed version
Token names are defined by the installed Aura preset. To confirm a token exists in the
current version, inspect the base preset source:
`node_modules/@primeuix/themes/dist/aura/base/index.mjs` (semantic tokens) and
`node_modules/@primeuix/themes/dist/aura/<component>/index.mjs` (component tokens).

## Do NOT
- Use inline `light-dark()` for class-based dark mode, or override component CSS via `::ng-deep`.
- Edit global `primary.color` when only one component should change.
- Assume a token name without checking the installed preset if unsure.

## PrimeNG Buttons (Angular, PrimeNG v21+)

Always use the `[pButton]` directive on a native `<button>` — never the `<p-button>`
component. The `<p-button>` component and the `pButtonLabel` / `pButtonIcon` directives
are deprecated since PrimeNG v21 and will be removed.

Rules:
- Import `ButtonDirective` (or `ButtonModule`) from `primeng/button`.
- Icon = an `<i class="pi pi-...">` child. Label = a text node / `<span>` child placed
  directly inside the host. Do NOT use the `icon=` / `label=` inputs.
- Use the native `(click)` output, never `(onClick)`.
- Icon-only buttons: set `[iconOnly]="true"`; no trailing ellipsis in labels; must work in
  light and dark themes.
- Do NOT use the deprecated `[loading]` input. Drive loading with native `[disabled]`
  plus a spinner icon child (`pi pi-spin pi-spinner`).
- Styling inputs on the directive: `[text]`, `[outlined]`, `[rounded]`, `[raised]`,
  `variant`, `severity`, `size`.

✅ Correct:
```html
<button pButton type="button" [text]="true" (click)="save()">
  <i class="pi pi-check"></i>
  <span>Save</span>
</button>
```

✅ With loading:
```html
<button pButton type="button" [disabled]="saving()" (click)="save()">
  <i [class]="saving() ? 'pi pi-spin pi-spinner' : 'pi pi-check'"></i>
  <span>Save</span>
</button>
```

❌ Deprecated — never generate this:
```html
<p-button icon="pi pi-check" label="Save" [text]="true" (onClick)="save()" />
```
