---
name: python-clean-architecture
description: 'Designs clean, layered Python solution structure — src layout, domain/application/infrastructure packages, Protocol-based DI, SOLID, and where code belongs. Use when creating a new Python project, adding a package/layer, wiring dependency injection, or deciding which layer a module goes in. Applies to API, web app, and desktop Python apps.'
---

# Python Clean Architecture

Foundation rules for every Python app in this repo. Scaffolding skills (API, web app, desktop) build
on top of this.

## Core principle

Dependencies point **inward**. `domain` knows nothing about frameworks, UI, or infrastructure. Outer
layers depend on inner-layer **abstractions** (`typing.Protocol` / `abc.ABC`), never the reverse.

## Layout — `src/` layout

```
src/
  <project>/
    domain/          entities, value objects, enums, business rules (pure Python, no framework)
    application/     use cases, service interfaces (Protocols), orchestration
    infrastructure/  implementations: DB, external APIs, file IO, DI wiring
    <entrypoint>/    the app/UI layer (api / web / gui / cli) — thin
tests/
  unit/ integration/
```

Web/API projects extend `application`/`infrastructure` with `api/`, `contracts/` (Pydantic
request/response — no domain import), and `persistence/` (SQLAlchemy models, repositories, Alembic).
Dependency direction: `api → application → domain`; `persistence`/`infrastructure → application →
domain`. **Domain imports nothing framework-related. Contracts never import Domain.**

## SOLID (apply pragmatically)

- **S** one reason to change per class/module. **O** extend via new types/strategies. **L** subtypes
  honor the base contract. **I** small focused `Protocol`s, not one fat interface. **D** high-level
  modules depend on abstractions.

## Dependency injection

- **Constructor injection:** pass collaborators via `__init__`; don't construct dependencies or reach
  for globals/singletons inside classes.
- A small composition root (`infrastructure/container.py` or a `build_services()` factory) wires
  concrete implementations to their `Protocol`s. A DI framework (`dependency-injector`, `punq`) is
  optional — plain factory functions are often clearer. Use DI where it adds value.

## Patterns (use where they genuinely help)

Repository (data access) · Factory/Strategy (interchangeable providers) · Adapter (wrap third-party
SDKs behind your own `Protocol`) · typed Settings/Options (Pydantic `BaseSettings`).

## Where code goes — quick decisions

- Pure business rule / entity behavior → **domain**.
- Orchestrating a use case → **application** (a use-case function/class).
- Talking to DB / HTTP / files / SMTP → **infrastructure** (or `persistence`), behind a `Protocol`
  declared in `application`.
- HTTP shape (request/response schema) → **contracts**. UI state (ViewModel/Presenter) → the entrypoint.

## Cross-cutting rules

- Config via Pydantic `BaseSettings` (env + `.env` local only); secrets from env — never hardcoded.
- Logging via stdlib `logging` configured once at startup; prefer structured logging (`structlog`)
  with context. No `print()` for diagnostics in library code.
- Testing: **pytest** + **pytest-cov**; fixtures + parametrize; mock via `unittest.mock`/`pytest-mock`.
  Optionally enforce layer boundaries with **import-linter**.

## Coding conventions

See [.github/instructions/python-conventions.instructions.md](../../instructions/python-conventions.instructions.md)
for the enforced coding style (type hints, casefold, f-strings, pathlib, dataclasses, httpx).
