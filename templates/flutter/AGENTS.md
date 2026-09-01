# AGENTS.md — Flutter / Dart Project

Guidance for AI agents working in this Flutter repository. Read this first, then load the skill that
matches the task. Keep this file current as the project evolves.

## Tech baseline

- **Flutter:** latest stable. **Before scaffolding, run `flutter upgrade`** so the SDK and templates
  are current, then verify with `flutter --version`. Use the latest stable Dart that ships with it.
- **State/DI:** choose one primary approach and stick to it (see the state-and-packages skill).
- Frontend only — this app talks to backends over HTTP; it does not host server logic.

## Skills — load the one that matches the task

Skills live in `.github/skills/`. Load a skill when its trigger matches; follow its steps.

| Skill | Use when |
|-------|----------|
| [flutter-app-architecture](./.github/skills/flutter-app-architecture/SKILL.md) | Designing layers/features, MVVM, deciding where code belongs |
| [scaffolding-flutter-app](./.github/skills/scaffolding-flutter-app/SKILL.md) | Creating a new Flutter app or adding a feature |
| [flutter-state-and-packages](./.github/skills/flutter-state-and-packages/SKILL.md) | Choosing state management, routing, DI, and vetted packages |

## Agents

- [flutter-scaffolder](./.github/agents/flutter-scaffolder.agent.md) — sets up a new app/feature.
- [flutter-reviewer](./.github/agents/flutter-reviewer.agent.md) — read-only review against these rules.

Path-scoped coding rules: [.github/instructions/flutter-conventions.instructions.md](./.github/instructions/flutter-conventions.instructions.md).

## Architecture (always)

Separation of concerns via **MVVM** with two layers ([Flutter guide](https://docs.flutter.dev/app-architecture/guide)):

- **UI layer:** **Views** (widgets — presentation only) + **ViewModels** (state + logic, expose
  commands). One View ↔ one ViewModel.
- **Data layer:** **Repositories** (single source of truth for a data type; caching, retries,
  transforms to domain models) + **Services** (wrap one data source / API endpoint; hold no state).
- **Optional domain layer:** add **use-cases/interactors** only when logic spans multiple repositories,
  is complex, or is reused — not by default.

Organize **by feature**, not by technical type. Widgets contain no business logic.

## Commands

```bash
flutter upgrade                 # run first, keep SDK current
flutter pub get
dart format .
flutter analyze                 # must be clean
flutter test
flutter run
```

## Project files & scripts (included in this bundle)

- `analysis_options.yaml` — strict lints (`flutter analyze` must stay clean).
- `.gitignore` — excludes `build/`, `publish/` (local builds), `.key/` + Android signing (`*.jks`, `key.properties`), `.env`.
- `.vscode/tasks.json` + `launch.json` — run **upgrade / analyze / test / run / build apk / build android (signed aab) / publish** from VS Code.
- `scripts/build-android.ps1` + `.sh` — signed AAB → `publish/android/` (keystore in `.key/`, passwords via env vars).
- `scripts/publish.ps1` + `.sh` — build web/desktop/apk → `publish/<target>/` (zipped).
- `.key/README.md` + `key.properties.example` — Android signing setup (keys git-ignored).

## Always do

- Views are presentation-only; all data logic lives in ViewModels; data access behind Repositories.
- One feature = one View + one ViewModel; organize folders by feature.
- Immutable state models; `const` constructors where possible; dispose controllers/subscriptions.
- Handle loading / error / empty states explicitly in the UI.
- Buttons: icon where available, **no trailing ellipsis** labels; support light/dark theme (Material 3).
- Prefer vetted packages ([Flutter Gems](https://fluttergems.dev/)); pin versions; run `flutter analyze` clean.
- Ship `README.md` and keep this `AGENTS.md` updated.
- At project start, ask **open source vs closed/commercial** and add the matching `LICENSE`; confirm the `.gitignore` (see the `foundations` bundle).

## Never do

- Business/data logic inside widgets (`build`), or network calls directly in the UI.
- God widgets/files; deeply nested widget trees instead of extracted widgets.
- Mixing multiple state-management approaches; leaving `flutter analyze` warnings unaddressed.
- Hardcoded secrets/API keys in the app.
