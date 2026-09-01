---
description: 'Flutter/Dart coding conventions enforced on all Dart files.'
applyTo: '**/*.dart'
---

# Dart / Flutter Coding Conventions

- **No business or data logic in widgets.** `build` methods only compose UI; delegate to the ViewModel.
- **One feature = one View + one ViewModel;** organize folders by feature, one concept per file.
- **Immutable state/domain models** (prefer `freezed` / `equatable`); value equality for state.
- **`const` constructors and `const` widgets** wherever possible.
- **Dispose** controllers, streams, and subscriptions in `dispose()`.
- Handle async UI explicitly: distinct **loading / data / error / empty** states.
- Data access only through **Repositories**; API/platform/file calls only in stateless **Services**.
- File names `snake_case.dart`; classes `PascalCase`; members `camelCase`; private members prefixed `_`.
- Keep `flutter analyze` clean; do not suppress lints without a comment explaining why.
- No hardcoded secrets/API keys — load from env config or a backend.
- Prefer extracting large widget subtrees into named widgets over deep nesting.
