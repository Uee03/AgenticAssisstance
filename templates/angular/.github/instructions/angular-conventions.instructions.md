---
description: 'Angular TypeScript/component conventions enforced on all TypeScript files.'
applyTo: '**/*.ts'
---

# Angular Coding Conventions

- **Always split component files.** A component is `<name>.ts` + `<name>.html` + `<name>.css`/`.scss`
  referenced via `templateUrl` and `styleUrl`. **Never** use inline `template:` or `styles:` in
  `@Component`.
- **Generate with the CLI** (`ng generate component/service/...`); don't hand-write boilerplate.
- **Standalone components** (no NgModules for new code).
- **DI:** prefer the `inject()` function over constructor parameter injection.
- **State:** use **signals** (`signal`, `computed`, `effect`); use `input()`/`input.required()`,
  `output()`, `model()` for component I/O.
- Mark Angular-initialized members (`input`/`output`/`model`/queries) **`readonly`**; mark members used
  only by the template **`protected`**. Group injected deps, inputs, outputs, and queries before methods.
- **Naming:** hyphenated file names matching the TypeScript identifier (`user-profile.ts` ↔
  `UserProfile`); tests end `.spec.ts`; avoid generic names (`utils.ts`, `helpers.ts`, `common.ts`).
- **Organize by feature area**, not by code type; one concept per file; co-locate a component's files
  and its `.spec.ts`.
- Keep components focused on presentation; move validation/transforms into services or functions.
- Prefer real types over `any`; keep `ng lint` clean. No hardcoded secrets/API keys.
