---
name: scaffolding-flutter-app
description: 'Scaffolds a new Flutter app (or a new feature) with MVVM feature-first structure, theming, routing, and DI on the latest stable SDK. Use when creating a new Flutter project or adding a feature, or when the user mentions building a Flutter mobile / web / desktop app.'
---

# Scaffolding a Flutter App

**Best model:** Act tier (GPT-6.1 Sol) via the Implementer or a scaffolder agent.

First load [flutter-app-architecture](../flutter-app-architecture/SKILL.md) and
[flutter-state-and-packages](../flutter-state-and-packages/SKILL.md).

## Ask the user first

1. **Target platforms:** Android / iOS / web / Windows / macOS / Linux (any combination).
2. **State management + DI** approach (see the state-and-packages skill) if not already decided.

## Step 1 — use the latest SDK

```bash
flutter upgrade          # get the latest stable SDK + templates
flutter --version        # confirm
```

Do not skip this — the app must be created on the current stable Flutter.

## Step 2 — create the project

```bash
flutter create --org com.example --platforms=android,ios,web <project_name>
```

Adjust `--platforms` to the chosen targets. Then set up the feature-first `lib/` layout from the
architecture skill (`app/`, `core/`, `data/{services,repositories,models}`, `features/<feature>/`).

## Step 3 — foundation

- **Theme (Material 3):** define light + dark `ThemeData`; wire a theme-mode toggle (persist via
  `shared_preferences`); set `MaterialApp.themeMode`.
- **Icons:** use Material Symbols/Icons; buttons show an icon where available and use **no trailing
  ellipsis** labels. Icons follow the theme automatically.
- **Routing:** set up declarative routing (e.g. `go_router`) in `app/`.
- **DI:** register services + repositories + view models via the chosen DI (e.g. `get_it` +
  `injectable`, or Riverpod providers).
- **HTTP:** a typed API client (`dio`/`http`) with a base URL, timeouts, and interceptors, wrapped in
  Services. No secrets in the app.

## Step 4 — first feature slice end-to-end

`features/<feature>/`: a Service (API) → a Repository (source of truth, maps to a domain model in
`data/models/`) → a ViewModel (state + commands) → a View (widget, presentation only). Handle
loading / data / error / empty states in the View.

## Step 5 — quality gate

```bash
dart format .
flutter analyze          # must be clean
flutter test
```

Add unit tests for the ViewModel + repository and a widget test for the View.

## Workflow checklist

```
- [ ] 1. flutter upgrade; confirm version
- [ ] 2. flutter create with chosen platforms; set up feature-first lib/ layout
- [ ] 3. Theme (light/dark + toggle), Material icons, routing, DI, HTTP client
- [ ] 4. First feature slice: Service → Repository → ViewModel → View (all states handled)
- [ ] 5. dart format + flutter analyze (clean) + flutter test; write tests
- [ ] 6. README.md + AGENTS.md; pin package versions
```

## Docs

`README.md` (supported platforms, run/build commands) and `AGENTS.md` (state approach + folder layout).
Keep current.
