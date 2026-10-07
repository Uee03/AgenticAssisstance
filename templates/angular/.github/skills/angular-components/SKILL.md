---
name: angular-components
description: 'Builds Angular components and directives to the official style guide — separate TS/HTML/CSS files, signals, inject(), inputs/outputs, and native control flow. Use when creating or refactoring an Angular component, directive, or pipe, or when the user asks for a new UI component.'
---

# Angular Components & Directives

**Best model:** Act tier (GPT-6.1 Sol) via the Implementer or a scaffolder agent.

Follows the [Angular style guide](https://angular.dev/style-guide). Always generate with the CLI
(`ng generate component ...`) rather than hand-writing boilerplate.

## Always split into three files

A component is `<name>.ts` + `<name>.html` + `<name>.css`/`.scss` (plus `<name>.spec.ts`), sharing the
base name. Use `templateUrl` and `styleUrl` — **never** inline `template:` or `styles:`.

```ts
// user-profile.ts
@Component({
  selector: 'app-user-profile',
  templateUrl: './user-profile.html',
  styleUrl: './user-profile.scss',
})
export class UserProfile {
  private readonly usersService = inject(UsersService);   // inject(), not constructor params
  readonly userId = input.required<string>();             // signal input, readonly
  readonly saved = output<void>();                        // output, readonly
  protected readonly fullName = computed(() => /* ... */); // template-only members: protected
}
```

## Rules

- **Naming:** hyphenated file names matching the class (`user-profile.ts` ↔ `UserProfile`); tests end
  `.spec.ts`. Avoid generic names (`utils.ts`, `helpers.ts`).
- **DI:** prefer the `inject()` function over constructor parameters.
- **Inputs/outputs/state:** use `input()`/`input.required()`, `output()`, `model()`, and **signals**
  (`signal`, `computed`). Mark Angular-initialized properties `readonly`.
- **Template access:** mark members used only by the template `protected`. Group Angular-specific
  properties (injected deps, inputs, outputs, queries) before methods.
- **Templates:** use native control flow `@if` / `@for` (with `track`) / `@switch`. Keep logic simple —
  move complex logic into `computed()` or methods. Prefer `[class.x]` / `[style.x]` over
  `NgClass`/`NgStyle`. Name event handlers for the action (`(click)="saveUser()"`, not `handleClick()`).
- **Lifecycle:** implement the interface (e.g. `OnInit`); keep hooks small — delegate to well-named methods.
- **Presentation focus:** keep UI-agnostic logic (validation, transforms) out of the component — put it
  in a service or plain function.
- **Directives:** use the app's selector prefix; attribute selectors use camelCase (`[appTooltip]`).

## Styling

- Component styles are scoped by default — keep them in the component's own `.scss`/`.css`.
- Buttons show an icon where available and use **no trailing ellipsis** labels; ensure light/dark theme
  support and adequate contrast; icon-only buttons get an `aria-label`/tooltip.

## After creating

Run `ng lint` (must be clean) and update/keep the co-located `.spec.ts`.
