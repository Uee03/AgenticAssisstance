---
name: scaffolding-angular-app
description: 'Scaffolds a new Angular app (or feature) via the Angular CLI on the latest version, with feature-based structure, routing, theming, and split component files. Use when creating a new Angular project or feature, or when the user mentions building an Angular web app / SPA / dashboard.'
---

# Scaffolding an Angular App

First load [angular-app-architecture](../angular-app-architecture/SKILL.md) and
[angular-components](../angular-components/SKILL.md).

## Step 1 — use the latest Angular via the CLI

```bash
npm create @angular@latest <project-name>     # or: npx @angular/cli@latest new <project-name>
```

When prompted, choose routing = yes and a stylesheet format (**SCSS** recommended). This generates the
latest Angular with standalone components and a `src/` layout. Confirm with `ng version`.

## Step 2 — configure the split-file default (important)

So that **every generated component has separate TS/HTML/CSS files**, do NOT use inline templates or
styles. In `angular.json`, set the component schematic defaults:

```json
"schematics": {
  "@schematics/angular:component": { "inlineTemplate": false, "inlineStyle": false, "style": "scss" }
}
```

Never pass `--inline-template` / `--inline-style`. Every component = `<name>.ts` + `<name>.html` +
`<name>.scss` (or `.css`).

## Step 3 — foundation

- **Structure:** create `app/core/`, `app/shared/`, and `app/features/` (see the architecture skill).
- **Routing:** define lazy-loaded feature routes in `app.routes.ts` (`loadComponent`/`loadChildren`).
- **HTTP:** `provideHttpClient()` in `app.config.ts`; add auth/error interceptors in `core/`.
- **Theme:** implement a light/dark theme toggle (CSS variables or a UI library's theming); persist the
  choice. Buttons show an icon where available and use **no trailing ellipsis** labels.
- **Environment:** put the API base URL / flags in `environments/` — no secrets committed.

## Step 4 — first feature slice

```bash
ng generate component features/<area>/<name>
ng generate service features/<area>/<name>
```

Wire: component (presentation, signals, `inject()` the service) → service (HTTP, exposes signals). Add
a route. Handle loading / data / error / empty states in the template with `@if`/`@for`.

## Step 5 — quality gate

```bash
ng lint        # must be clean
ng test
ng build
```

## Workflow checklist

```
- [ ] 1. Create app with the latest CLI; choose routing + SCSS
- [ ] 2. Set angular.json schematics: inlineTemplate=false, inlineStyle=false (split files always)
- [ ] 3. core/ + shared/ + features/ structure; routing; HttpClient + interceptors; theme toggle
- [ ] 4. First feature: ng generate component + service; wire signals; handle all states
- [ ] 5. ng lint (clean) + ng test + ng build
- [ ] 6. README.md + AGENTS.md
```

## Docs

`README.md` (run/build commands) and `AGENTS.md` (feature structure + state approach). Keep current.
