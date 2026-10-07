---
name: project-intake
description: 'Mandatory pre-scaffolding intake for a new Flutter/Dart project. ALWAYS run this before creating or modifying any file in a new or empty repo — collect project name, target platforms, state-management/DI approach, backend/API, auth, licensing, and .gitignore, then get explicit confirmation before scaffolding. Use at the very start of any "create / scaffold / set up a Flutter project" request.'
---

# Project intake (Flutter) — do this before scaffolding

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

1. **App name** — e.g. `billing_app` (lower_snake_case for the Dart package).
2. **Target platforms** — Android · iOS · web · Windows · macOS · Linux (pick all that apply).
3. **State management & DI** — Riverpod · Bloc · Provider (see `flutter-state-and-packages`).
4. **Backend / data source** — REST API · Supabase · Firebase · local only. Base URL / project?
5. **Auth** — none · email-password · OAuth/social · Supabase Auth.
6. **Theming** — Material 3 light/dark (default) or a specific brand theme?
7. **License** — open source (which: MIT / Apache-2.0 / GPL-3.0 / LGPL-3.0) or closed/commercial?
   (See the `foundations` `project-licensing` skill. Never assume MIT.)
8. **.gitignore** — confirm the bundled one is right for Flutter.
9. **Android release signing** — needed now? (keystore in git-ignored `.key/`, passwords via env vars).

## Intake summary (fill in, then confirm)

```text
App name    : <...>
Platforms   : <Android | iOS | web | Windows | macOS | Linux>
State/DI    : <Riverpod | Bloc | Provider>
Backend     : <REST | Supabase | Firebase | local>  (endpoint/project: <...>)
Auth        : <none | email-password | OAuth | Supabase>
Theming     : <Material 3 light/dark | custom>
License     : <MIT | Apache-2.0 | GPL-3.0 | LGPL-3.0 | proprietary>
.gitignore  : <confirmed>
Android sign: <yes | no>
```

> Only after the user confirms this summary do you load `scaffolding-flutter-app` (and
> `flutter-app-architecture`) and begin. Record the confirmed choices in `AGENTS.md` and the
> `README.md`.
