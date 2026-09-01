# AGENTS.md — Python Project

Guidance for AI agents working in this repository. Read this first, then load the skill that matches
the task. Keep this file current as the project evolves.

## Tech baseline

- **Python:** **latest stable**. Fetch it with `uv python install` (downloads the newest CPython from
  the internet); if offline/unavailable, use the newest locally installed (`uv python list`). Pin the
  chosen version in `.python-version` / `requires-python` (the template defaults to 3.13 — bump it).
- **Env & packages:** **`uv`** (venv + resolver + lockfile). Never install into system Python. Single
  `pyproject.toml` (PEP 621); commit `uv.lock`.
- **Lint/format:** **Ruff**. **Types:** **mypy** (strict-ish) — type hints required on all public
  functions, methods, and attributes. Pre-commit runs Ruff + mypy.

## Skills — load the one that matches the task

Skills live in `.github/skills/`. Load a skill when its trigger matches; follow its steps.

| Skill | Use when |
|-------|----------|
| [python-clean-architecture](./.github/skills/python-clean-architecture/SKILL.md) | Designing layers/packages, DI, or deciding where code belongs (every app type) |
| [scaffolding-python-api](./.github/skills/scaffolding-python-api/SKILL.md) | Building a JSON **API** / backend (FastAPI preferred) |
| [scaffolding-python-webapp](./.github/skills/scaffolding-python-webapp/SKILL.md) | Building a server-rendered **web app** (Django / Flask + templates) |
| [scaffolding-python-desktop](./.github/skills/scaffolding-python-desktop/SKILL.md) | Building a **desktop** GUI (PySide6 / Flet / CustomTkinter) |

## Agents

- [python-scaffolder](./.github/agents/python-scaffolder.agent.md) — sets up a new project end-to-end.
- [python-reviewer](./.github/agents/python-reviewer.agent.md) — read-only review against these rules.

Path-scoped coding rules: [.github/instructions/python-conventions.instructions.md](./.github/instructions/python-conventions.instructions.md).

## Architecture (always)

Clean, layered separation with a `src/` layout. Business logic lives in `domain`/`application`, never
in route handlers, widget callbacks, or `__main__`. Depend on **abstractions** (`typing.Protocol` /
`abc.ABC`) across boundaries. Prefer a **modular monolith**; add Redis/Celery/microservices only when
a concrete need exists. See the clean-architecture skill for the exact layout per app type.

## Commands

```bash
uv sync                                      # venv + install from lockfile
uv run ruff check . && uv run ruff format .
uv run mypy src
uv run pytest
uv run python -m <project>                   # or the app entry point
```

Release artifacts go to a git-ignored `publish/` folder (see the scaffolding skills).

## Project files & scripts (included in this bundle)

- `pyproject.toml` (Ruff/mypy/pytest config), `.pre-commit-config.yaml`, `.editorconfig`, `.python-version`.
- `.gitignore` — excludes `.venv/`, caches, `publish/` (local builds), `.key/`, and `.env`.
- `.vscode/tasks.json` — run **sync / lint / format / typecheck / test / run / publish** from VS Code.
- `scripts/publish.ps1` + `.sh` — PyInstaller standalone build → `publish/<platform>/` (zipped).

## Always do

- Type hints everywhere; run Ruff + mypy. Business logic in `domain`/`application`; entrypoint stays thin.
- Constructor injection (pass collaborators via `__init__`); Protocols/ABCs across boundaries.
- `str.casefold()` for case-insensitive comparisons; f-strings; `pathlib.Path` for paths.
- `@dataclass` (or Pydantic) for data holders; `frozen=True` for value objects. One concern per module.
- Outbound HTTP via **`httpx`** (explicit timeouts, reused client) behind an adapter.
- Config via Pydantic `BaseSettings` (env + `.env`); structured logging; secrets from env only.
- GUI buttons: icon where available, **no trailing ellipsis** labels; light/dark theme + Material Symbols icons.
- Ship `README.md` + living `docs/`; keep this `AGENTS.md` updated. Web: document endpoints + export OpenAPI.
- At project start, ask **open source vs closed/commercial** and add the matching `LICENSE`; confirm the `.gitignore` (see the `foundations` bundle).

## Never do

- Business logic in route handlers, widget callbacks, or `__main__`.
- Constructing/globals for things that should be injected; over-abstracting trivial helpers.
- Hardcoded secrets; f-stringing untrusted input into SQL; `print()` for diagnostics in library code.
- Installing into system Python; committing `.venv/`, build output, or `.env`.
- Implementing a web framework, doc UI, or database choice without asking the user first.
