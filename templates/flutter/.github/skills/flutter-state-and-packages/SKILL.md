---
name: flutter-state-and-packages
description: 'Guides choosing Flutter state management, routing, dependency injection, and vetted packages, then using them consistently. Use when deciding between Riverpod / Bloc / Provider, picking routing or DI, or selecting third-party Flutter/Dart packages.'
---

# Flutter State Management, DI & Packages

**Best model:** Plan tier (Claude Sonnet 5.5) to choose packages; Act tier (GPT-6.1 Sol) to wire them.

Pick **one** primary state-management approach per app and use it consistently. Prefer well-maintained
packages; browse [Flutter Gems](https://fluttergems.dev/) and pub.dev (check popularity, maintenance,
null-safety, and last-updated).

## State management — choose one

- **Riverpod** — **preferred default** for most new apps: compile-safe, testable, provides DI too.
- **Bloc / flutter_bloc** — for apps that want explicit, event-driven state and strong conventions at
  scale.
- **Provider + ChangeNotifier** — simplest; fine for small apps and matches the guide's basic MVVM.

Whichever is chosen: ViewModels expose **immutable** state; Views watch/rebuild reactively; commands
live on the ViewModel. Don't mix approaches within one app.

## Routing

- **`go_router`** — declarative, URL-based routing (deep links, web URLs, nested routes). Configure in
  `app/`. Keep route definitions centralized.

## Dependency injection

- With **Riverpod**: use providers for services/repositories/view models.
- Otherwise: **`get_it`** (+ optional **`injectable`** for codegen) as a service locator configured at
  startup. Register data sources (Services), Repositories, then ViewModels.

## Commonly useful packages (add only when needed)

| Need | Package |
|------|---------|
| HTTP client | `dio` (interceptors, timeouts) or `http` |
| JSON / models | `freezed` + `json_serializable` (immutable models + codegen) |
| Local key-value | `shared_preferences`; secure: `flutter_secure_storage` |
| Local database | `drift` (SQL, typed) or `isar` / `hive` (NoSQL) |
| Value equality | `equatable` (or `freezed`) |
| Functional results | `dartz` / `fpdart` for `Either`/`Option` (optional) |
| i18n | `intl` + generated localizations |
| Env config | `envied` / `flutter_dotenv` (never commit secrets) |

## Rules

- **Pin versions** in `pubspec.yaml`; run `flutter pub get` and keep `pubspec.lock` committed.
- Prefer immutable models (`freezed`) and value equality (`equatable`) for state/domain models.
- Keep `flutter analyze` clean; enable stricter lints via `flutter_lints` / `very_good_analysis`.
- Wrap third-party SDKs behind your own Service/Repository interface so they're swappable and testable.
- No secrets/API keys hardcoded — load from env config or a backend.
