---
name: angular-app-architecture
description: 'Designs Angular app structure per the official style guide — src layout, feature-based folders, services, routing, and signal-based state. Use when creating a new Angular app, adding a feature area, organizing folders, or deciding where components, services, or state belong.'
---

# Angular App Architecture (feature-based)

**Best model:** Plan tier (Claude Sonnet 5.5) via the Planner or a reviewer agent.

Follows the [Angular style guide](https://angular.dev/style-guide). Scaffolding and component skills
build on this.

## Project structure

- **All UI code lives under `src/`**; non-UI config/scripts live outside `src/`.
- **Bootstrap in `src/main.ts`** (the single entry point).
- **Organize by feature area**, not by code type:

```
src/
  main.ts
  app/
    app.ts / app.html / app.css       app root component (split files)
    app.config.ts                     providers (router, http, etc.)
    app.routes.ts                     top-level routes (lazy-load features)
    core/                             app-wide singletons: interceptors, guards, base services
    shared/                           reusable UI: components, directives, pipes
    features/
      <area>/
        <sub-area>/
          <name>.ts / <name>.html / <name>.css
          <name>.spec.ts
          <name>-service.ts           feature service(s)
```

Avoid top-level `components/`, `services/`, `directives/` buckets. **One concept per file.** Group a
component's TS/HTML/CSS/spec together in the same directory. Split further into sub-directories as a
feature grows.

## Layering

- **Components** — presentation. Keep them focused on the UI; move validation, data transforms, and
  reusable logic into services or plain functions.
- **Services** — data access (HTTP), shared state, and business/UI-agnostic logic. Provided in `root`
  or at a feature route. Inject with `inject()`.
- **Routing** — lazy-load feature routes (`loadComponent` / `loadChildren`) from `app.routes.ts`;
  co-locate each feature's routes with the feature.

## State

- Prefer **signals** for local/component and shared service state (`signal`, `computed`, `effect`).
- For server data, use a service that exposes signals (or `resource()`/`httpResource` where suitable);
  keep templates simple and derive with `computed()`.
- Add a heavier state library only if the app truly needs it — don't reach for it by default.

## HTTP & config

- Use `HttpClient` (provided via `provideHttpClient`) inside services; add interceptors in `core/` for
  auth/error handling. Base API URL and flags come from `environments/` — **no secrets in the app**.

## Testing

- Unit-test services and component logic; each component has a co-located `.spec.ts`. Keep components
  thin so logic is testable.

## Conventions

See [.github/instructions/angular-conventions.instructions.md](../../instructions/angular-conventions.instructions.md)
for enforced style — **always split component files (TS/HTML/CSS)**, hyphenated names, `inject()`,
signals, `readonly`/`protected`, native control flow.
