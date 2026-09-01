# AGENTS.md — Angular Project

Guidance for AI agents working in this Angular repository. Read this first, then load the skill that
matches the task. Keep this file current as the project evolves.

## Tech baseline

- **Angular:** latest (**v22+**). Use the **Angular CLI** (`ng`) for all generation; keep it current.
- **Style:** modern Angular — **standalone components**, **signals**, `inject()` over constructor
  injection, `input()`/`output()`/`model()`, native control flow (`@if`/`@for`/`@switch`).
- Frontend only — this app talks to backends over HTTP; it does not host server logic.

## CRITICAL rule — always split component files

Every component MUST be three separate files sharing the same base name:
`user-profile.ts`, `user-profile.html`, and `user-profile.css` (or `.scss`).
**Never** use an inline `template:` or inline `styles:` in the `@Component` decorator — always
`templateUrl` + `styleUrl`. This is enforced in
[.github/instructions/angular-conventions.instructions.md](./.github/instructions/angular-conventions.instructions.md).

## Skills — load the one that matches the task

Skills live in `.github/skills/`. Load a skill when its trigger matches; follow its steps.

| Skill | Use when |
|-------|----------|
| [angular-app-architecture](./.github/skills/angular-app-architecture/SKILL.md) | Designing feature-based structure, services, routing, state |
| [scaffolding-angular-app](./.github/skills/scaffolding-angular-app/SKILL.md) | Creating a new Angular app or feature via the CLI |
| [angular-components](./.github/skills/angular-components/SKILL.md) | Building components/directives to the style guide (split files, signals) |

## Agents

- [angular-scaffolder](./.github/agents/angular-scaffolder.agent.md) — sets up a new app/feature.
- [angular-reviewer](./.github/agents/angular-reviewer.agent.md) — read-only review against these rules.

## Architecture (always)

Follow the [Angular style guide](https://angular.dev/style-guide): all UI code under `src/`; bootstrap
in `src/main.ts`; **organize by feature area**, not by technical type (no top-level `components/`,
`services/`, `directives/` buckets). One concept per file; group a component's files together. Keep
components focused on presentation; move non-UI logic (validation, transforms) into services/functions.

## Commands

```bash
npm install
ng generate component features/<area>/<name>   # never hand-write component boilerplate
ng serve
ng lint
ng test
ng build
```

## Project files & scripts (included in this bundle)

- `.editorconfig`, `.prettierrc.json` — formatting.
- `.gitignore` — excludes `node_modules/`, `dist/`, `publish/` (local builds), `.env`.
- `.vscode/tasks.json` — run **install / serve / lint / test / build / publish** from VS Code.
- `scripts/publish.ps1` + `.sh` — production build → zipped into `publish/`.

## Always do

- **Split every component into `.ts` + `.html` + `.css`/`.scss`** (via `templateUrl`/`styleUrl`).
- Generate code with `ng generate`; file names hyphenated (`user-profile.ts`), matching the class.
- Standalone components; `inject()` for DI; signals for state; `input()`/`output()`; `@if`/`@for`.
- `readonly` for `input()`/`output()`/`model()`/queries; `protected` for members used only in the template.
- Prefer `[class.x]`/`[style.x]` over `NgClass`/`NgStyle`; name event handlers for what they do (`saveUser()`).
- Buttons: icon where available, **no trailing ellipsis** labels; support light/dark theme.
- Ship `README.md` and keep this `AGENTS.md` updated; keep `ng lint` clean.
- At project start, ask **open source vs closed/commercial** and add the matching `LICENSE`; confirm the `.gitignore` (see the `foundations` bundle).

## Never do

- Inline `template:`/`styles:` in `@Component` — always separate files.
- Business logic in templates or components that belongs in services; complex logic in templates.
- `any` where a real type exists; leaving `ng lint` warnings unaddressed.
- Hardcoded secrets/API keys; top-level `components/`/`services/` type-based folders.
