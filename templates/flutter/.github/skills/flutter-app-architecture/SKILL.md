---
name: flutter-app-architecture
description: 'Designs Flutter app structure using MVVM and a feature-first folder layout — Views, ViewModels, Repositories, Services, and an optional domain (use-case) layer. Use when creating a new Flutter app, adding a feature, or deciding where widgets, state, or data-access code belongs.'
---

# Flutter App Architecture (MVVM, feature-first)

Follows the official [Flutter architecture guide](https://docs.flutter.dev/app-architecture/guide).
Scaffolding and state-management skills build on this.

## Two layers + optional domain

- **UI layer**
  - **Views** — widgets. Presentation only: layout, animation, simple show/hide, simple routing.
    All data logic is delegated to the ViewModel.
  - **ViewModels** — hold UI state and most logic; retrieve data from repositories and transform it
    for display; expose **commands** (functions the View calls on user actions). One View ↔ one ViewModel.
- **Data layer**
  - **Repositories** — the single source of truth for a data type; handle caching, retries, refresh,
    error handling; output **domain models**. One repository per data type; repositories never know
    about each other.
  - **Services** — wrap a single data source / API endpoint (REST, platform channel, local file);
    return `Future`/`Stream`; **hold no state**. One service per data source.
- **Optional domain layer** — **use-cases/interactors**. Add only when logic merges multiple
  repositories, is complex, or is reused across ViewModels. Don't add by default (extra boilerplate).

## Feature-first folder layout

```
lib/
  main.dart
  app/                 app widget, theme, router config, DI setup
  core/                shared: constants, theme, extensions, result/error types, widgets
  data/
    services/          <name>_service.dart      (one per data source)
    repositories/      <name>_repository.dart    (one per data type)
    models/            domain models (immutable)
  features/
    <feature>/
      view/            <feature>_screen.dart, widgets/
      view_model/      <feature>_view_model.dart
      (optional) domain/  use_cases/
```

Organize **by feature**, not by technical type. Keep files focused (one concept per file).

## Where code goes — quick decisions

- Rendering / layout / user gestures → **View** (widget).
- UI state, transforming data, command handlers → **ViewModel**.
- Caching, retry, combining/refreshing data, mapping raw → domain model → **Repository**.
- Calling an API / platform channel / file → **Service** (stateless).
- Reused complex logic across ViewModels/repositories → **use-case** (domain layer, optional).

## State, DI & error handling

- Pick **one** state-management + DI approach (see
  [flutter-state-and-packages](../flutter-state-and-packages/SKILL.md)) and use it consistently.
- ViewModels expose immutable state; the View rebuilds reactively. Dispose controllers/subscriptions.
- Model async results with explicit **loading / data / error / empty** states; wrap fallible service
  calls in a `Result`/`Either` type or typed exceptions handled in the repository.

## Testing

- Unit-test ViewModels and repositories (mock services/repositories).
- Widget tests for Views. Keep Views thin so most logic is testable without the widget tree.

## Conventions

See [.github/instructions/flutter-conventions.instructions.md](../../instructions/flutter-conventions.instructions.md)
for enforced Dart/Flutter style (naming, `const`, immutability, no logic in `build`).
