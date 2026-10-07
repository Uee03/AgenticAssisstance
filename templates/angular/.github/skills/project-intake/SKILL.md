---
name: project-intake
description: 'Mandatory pre-scaffolding intake for a new Angular project. ALWAYS run this before creating or modifying any file in a new or empty repo — collect app name, app kind, styling, state approach, backend/API, auth, licensing, .gitignore, and hosting, then get explicit confirmation before scaffolding. Use at the very start of any "create / scaffold / set up an Angular project" request.'
---

# Project intake (Angular) — do this before scaffolding

**Best model:** Plan tier (Claude Sonnet 5.5); if already inside a scaffolder agent, stay on its model.

**Hard gate.** Do NOT create files, generate code, add packages, or run commands until every
question below is answered and you have echoed the choices back and received an explicit "yes".
Never assume defaults or "sensible" choices — ask. If the user says "just pick defaults", still show
the filled-in summary and get a single confirmation before building.

## How to run it

1. Ask the questions below **in one message** (grouped) so the user can answer quickly.
2. For anything left blank, state the default you would use and ask them to confirm it.
3. Post the **Intake summary** block with every value filled in.
4. Wait for explicit confirmation. Only then load the matching scaffolding skill and build.

## Questions

1. **App name** — e.g. `billing-web`.
2. **App kind** — SPA · dashboard/admin · marketing site · PWA. SSR/hydration needed (Angular SSR)?
3. **Styling** — CSS or SCSS? Component library (Angular Material / other) or hand-rolled?
4. **State** — signals only (default) · a store library. Routing structure (feature-based)?
5. **Backend / API** — base URL and auth model the app will call (REST · Supabase · GraphQL)?
6. **Auth** — none · token/JWT · OAuth/social · Supabase Auth.
7. **License** — open source (which: MIT / Apache-2.0 / GPL-3.0 / LGPL-3.0) or closed/commercial?
   (See the `foundations` `project-licensing` skill. Never assume MIT.)
8. **.gitignore** — confirm the bundled one is right for Angular.
9. **Hosting** — static host / CDN, Node SSR, or undecided? (offer `foundations` `choosing-hosting`).

## Intake summary (fill in, then confirm)

```text
App name    : <...>
App kind    : <SPA | dashboard | marketing | PWA>  (SSR: <yes|no>)
Styling     : <CSS | SCSS>  (UI lib: <Material | none | ...>)
State/Router: <signals | store>  (routing: feature-based)
Backend/API : <REST | Supabase | GraphQL>  (base URL: <...>)
Auth        : <none | JWT | OAuth | Supabase>
License     : <MIT | Apache-2.0 | GPL-3.0 | LGPL-3.0 | proprietary>
.gitignore  : <confirmed>
Hosting     : <static/CDN | Node SSR | undecided>
```

> Only after the user confirms this summary do you load `scaffolding-angular-app` (and
> `angular-app-architecture`) and begin. Record the confirmed choices in `AGENTS.md` and the
> `README.md`.
