# Python Project Setup — Universal Instructions

> **How to use this file:** When you start a new Python project, hand me this file and tell me:
> 1. The **project name** (e.g. `quicktools`).
> 2. The **app target** — one of: `CLI`, `GUI` (PySide6/PyQt6/Flet), `Web` (FastAPI/Flask/Django),
>    `Library`, or `Data/ML`.
> 3. Any project-specific extras (features, external services, DB, auth, etc.).
>
> I will read the **Shared Foundation** section (always applies) plus the matching **App Variation**
> section, then scaffold the project accordingly.

---

## 0. Quick Answer Template (fill this in when starting)

```text
Project name : <my_project>
App target   : <CLI | GUI | Web | Library | Data/ML>
Python ver   : Python 3.13 (latest stable)  ← default unless told otherwise
Extras       : <optional: features, APIs, DB, auth, etc.>
```

---

## 1. Shared Foundation (applies to EVERY project)

### 1.1 Platform & tooling
- **Python version:** latest stable — **Python 3.13** (pin with `.python-version` / `requires-python`).
- **Package & environment manager:** prefer **`uv`** (fast, all-in-one: venv + resolver + lockfile).
  Acceptable alternatives: **Poetry**, or `pip` + `venv` + `pip-tools`. Never install into system Python.
- **Project metadata:** a single **`pyproject.toml`** (PEP 621) holds dependencies, build config, and
  tool settings. Commit a lockfile (`uv.lock` / `poetry.lock`).
- **Lint + format:** **Ruff** (linter *and* formatter — replaces flake8/isort/black).
- **Type checking:** **mypy** (or Pyright/Pylance) in strict-ish mode. **Type hints are required** on
  all public functions, methods, and class attributes.
- **Pre-commit:** a `.pre-commit-config.yaml` running Ruff + mypy + basic hygiene hooks.

### 1.2 Architecture
Use a **modern, layered, clean architecture** with clear separation of concerns. Use a `src/` layout:

```
src/
  <project>/
    domain/          → entities, value objects, enums, business rules (pure Python, no framework)
    application/     → use cases, service interfaces (Protocols), orchestration
    infrastructure/  → implementations: DB, external APIs, file IO, DI wiring
    <entrypoint>/    → the app/UI layer (CLI, GUI, Web) — thin
tests/
  unit/ integration/
```

- **Business logic lives in its own modules/classes** in `domain` / `application` — never in UI
  callbacks, route handlers, or `__main__`.
- **UI/entrypoint components are separated into their own classes/modules** (one View + one
  ViewModel/Presenter per screen; one router/command module per feature). No god-modules.
- Depend on **abstractions** (`typing.Protocol` / `abc.ABC`), not concrete types, across boundaries.

### 1.3 SOLID & design principles
- **S**ingle Responsibility — one reason to change per class/module.
- **O**pen/Closed — extend via new types/strategies, avoid editing stable code.
- **L**iskov — subtypes honor their base contract.
- **I**nterface Segregation — small, focused `Protocol`s, not one fat interface.
- **D**ependency Inversion — high-level modules depend on abstractions.
- **Build the simplest architecture that meets current requirements.** Prefer a **modular monolith**
  over microservices; add infrastructure (Redis, Celery, message bus, Kubernetes) **only when a
  concrete need exists** — not because a tutorial uses it.

### 1.4 Dependency Injection
- Use **constructor injection** — pass collaborators in via `__init__`; don't construct dependencies
  or reach for globals/singletons inside classes.
- A small composition root (e.g. `infrastructure/container.py` or a `build_services()` factory) wires
  concrete implementations to their `Protocol`s. A DI framework (**`dependency-injector`**,
  **`punq`**) is **optional** — plain factory functions are fine and often clearer.
- Use DI **where it adds value**; don't over-abstract trivial helpers.

### 1.5 Design patterns (use where they genuinely help — do not over-engineer)
- **Repository** for data-access abstraction.
- **Factory** / **Strategy** for interchangeable providers/algorithms.
- **Adapter** to wrap third-party SDKs behind your own `Protocol`.
- **Settings/Options** via a typed settings object (Pydantic `BaseSettings`).
- **MVVM/MVP** for GUI; **router + service** for web; **command** objects for CLI.

### 1.6 Coding conventions
- **Type hints everywhere** (they are Python's "explicit types"). Prefer precise types over `Any`;
  use `list[str]`, `dict[str, int]`, `X | None`. Run mypy/Pyright.
- **Use comprehensions/generators only where they improve clarity.** For complex or side-effecting
  logic prefer an explicit `for` loop; avoid deeply nested one-liners that hurt readability.
- **Case-insensitive string comparison:** use `a.casefold() == b.casefold()` (Unicode-correct) —
  don't compare mixed-case strings directly when case should be ignored.
- **f-strings** for formatting; never `%`/`.format()` for new code.
- **`pathlib.Path`** for filesystem paths, not string concatenation.
- Prefer **`@dataclass`** (or Pydantic models) for data holders; `frozen=True` for value objects.
- One public class/concern per module; module/file names `snake_case`, classes `PascalCase`.
- **Prefer explicit/manual mapping** (a `to_response()` method or a small function) over reflection-
  based mappers.
- **Outbound HTTP calls:** use **`httpx`** (modern, sync **and** async, connection pooling) — preferred
  over **`requests`** (fine for simple synchronous scripts). Wrap third-party APIs behind your own
  `Protocol`/adapter (in `infrastructure`) so the client is swappable and testable; set explicit
  timeouts and reuse a client/session.
- Follow **PEP 8** (enforced by Ruff); public APIs get docstrings.

### 1.7 Configuration & logging
- Configuration via a typed **Pydantic `BaseSettings`** reading environment variables + `.env`
  (local only). Never hardcode secrets.
- Logging via the stdlib **`logging`** module configured once at startup; prefer **structured logging**
  (`structlog` or JSON formatter) with context (request/user/tenant id, operation, duration).
- No `print()` for diagnostics in library code. Never log secrets/tokens/PII.

### 1.8 Testing
- **pytest** + **pytest-cov**. Use **fixtures** and **parametrize**; mock via `unittest.mock` or
  `pytest-mock`.
- Test `domain`/`application` logic thoroughly; entrypoint stays thin.
- **Integration tests** for real DB/API; use **Testcontainers** (or a disposable Docker service) for
  PostgreSQL/Redis where useful.
- Optionally enforce import/layer boundaries with **import-linter** (Domain must not import
  infrastructure/entrypoint).

### 1.9 Required documentation (always create these)
- **`README.md`** — description, features, prerequisites, install/run instructions, project structure,
  configuration, license.
- **`AGENTS.md`** — guidance for AI agents/contributors: architecture, conventions (this file's rules),
  commands (install/lint/type/test/run), "always do / never do", and a roadmap/TODO section.
- **Living software documentation** (`docs/` — e.g. MkDocs Material, or a `DOCUMENTATION.md`) that is
  **kept up to date** whenever behavior, commands, endpoints, or structure change.

### 1.10 Repo hygiene
- Add a Python `.gitignore` (ignore `.venv/`, `__pycache__/`, `*.pyc`, `.pytest_cache/`, `dist/`,
  `build/`, `.mypy_cache/`, `.ruff_cache/`, `publish/`, `.env`).
- Tool config (Ruff, mypy, pytest, coverage) lives in `pyproject.toml`.
- Add a `LICENSE` (ask which; default MIT unless told otherwise).

### 1.11 Standard commands
```bash
uv sync                      # create venv + install deps from lockfile
uv run ruff check . && uv run ruff format .
uv run mypy src
uv run pytest
uv run python -m <project>   # or the app's entry point
```

### 1.12 Build, publish & packaging (required)
- Create a top-level **`publish/`** folder that is **git-ignored**. All release artifacts go here —
  never commit build output.
- **Libraries / packages:** build wheel + sdist with `uv build` (or `python -m build`) into `dist/`;
  publish to PyPI via `twine`/`uv publish` (Trusted Publishing / OIDC where possible).
- **Standalone apps:** produce a self-contained executable with **PyInstaller** (or **Nuitka** /
  **Briefcase** for GUI) so the user needs no Python install. Build into `publish/<platform>/`.
- **Zip each platform build**, named after the target, e.g.
  `publish/<project>-<version>-win-x64.zip`, `...-linux-x64.zip`, `...-macos-arm64.zip`.
- Provide a small **publish script** (`publish.ps1` / `publish.sh`) that builds, zips, and names each
  platform archive. (Cross-platform binaries must be built on each target OS / via CI.)

### 1.13 UI & button conventions (all GUI targets)
- **Buttons must not use trailing ellipsis text** (no `Save...`). Use plain, direct labels
  (`Save`, `Open`, `Export`).
- **Buttons should have an icon where one is available**, paired with (or replacing) the label.
- **Desktop apps use Google Material Symbols icons** (https://fonts.google.com/icons) unless the user
  says otherwise. Icons must recolor with the active light/dark theme.
- Icon-only buttons need tooltips; ensure keyboard focus and adequate contrast in both themes.

### 1.14 Documentation (living — keep it current)
- Every project ships **`README.md`** and **`AGENTS.md`** (see 1.9), plus living `docs/`.
- **Documentation must be kept up to date** — update it in the same change that alters behavior,
  commands, endpoints, or structure.

### 1.15 Local dev environment & deployment tooling
Assume the following are available; if a tool is missing, **suggest installing it (or a listed
alternative)** rather than failing silently:
- **Docker** — containerized local services + reproducible builds. If missing, suggest Docker Desktop
  (alternatives: Podman, Rancher Desktop, OrbStack).
- **PostgreSQL (local)** — default relational DB. If missing, suggest installing Postgres (native
  installer or the `postgres` Docker image).
- **Supabase account** — suggest Supabase (managed Postgres + auth + storage) when it fits.
- **Hosting/going live** — suggest **Hetzner** (cost-effective VPS/cloud) or alternatives (Fly.io,
  Railway, Render, DigitalOcean). Recommend Docker-based deploy behind a TLS reverse proxy
  (Caddy/Traefik/Nginx). **Dokploy** is a good self-hosted PaaS on a Hetzner VPS.

---

## 2. App Variations

Pick the ONE that matches the chosen app target. All still follow the Shared Foundation above.

---

### 2.A — CLI (Console)

- **Framework:** **Typer** (built on Click) for commands/args/options + auto help; or **Click**/
  **argparse** for lighter needs.
- **Output:** **Rich** for tables, prompts, progress, and color. Respect `--no-color` /
  non-interactive mode and honor the terminal's light/dark background (don't hardcode invisible colors).
- **Structure:**
  - `__main__.py` / `cli.py` → build the app, wire services (composition root), register commands.
  - `commands/` → one module/class per command (`export.py`, `sync.py`), each depending on
    `application` services via injection.
  - Command functions contain **no business logic** — parse input, delegate to `application`.
- **Packaging:** expose a console entry point in `pyproject.toml` (`[project.scripts]`); optionally
  ship a PyInstaller binary (see 1.12).
- **Docs:** README documents every command with examples; AGENTS.md lists the command map.

---

### 2.B — GUI (Desktop, cross-platform)

- **Framework — pick based on need:**
  - **PySide6** (official Qt for Python, LGPL) — **preferred** for rich desktop apps.
  - **PyQt6** — mature Qt binding (GPL/commercial).
  - **Flet** — Flutter-based, modern, easy theming (good if you want web/mobile too).
  - **CustomTkinter** — lightweight, simple modern-looking Tkinter apps.
- **Pattern:** **MVVM/MVP**. Windows/widgets are **Views only**; a **ViewModel/Presenter** class holds
  state + commands and calls `application` services via DI. **No business logic in widget callbacks.**
- **Separation:** one screen = one View class/file; shared widgets extracted into their own classes;
  dialogs/file pickers behind an `IDialogService` Protocol.
- **Light/Dark mode toggle (required):**
  - **Qt (PySide6/PyQt6):** use **`qdarktheme`** / **qt-material**, or swap a Fusion palette; expose an
    `IThemeService` + a UI toggle and persist the choice (`QSettings`).
  - **Flet:** set `page.theme_mode = ThemeMode.LIGHT/DARK` from a bound toggle.
  - **CustomTkinter:** `customtkinter.set_appearance_mode("Light"/"Dark")`.
- **Google Material Symbols icons (required):**
  - **Qt:** use **`qtawesome`** (Material Design Icons set) or bundle the Material Symbols SVGs and load
    via `QIcon`/`QSvgRenderer`; tint icons to follow the theme.
  - **Flet:** built-in `ft.Icons.*` (Material) — color follows the theme.
  - Icons recolor correctly in both light and dark.
- **Packaging:** PyInstaller / Nuitka / Briefcase → zipped per-platform build (see 1.12).
- **Docs:** README lists supported OSes + run/build commands; AGENTS.md documents MVVM + theming.

---

### 2.C — Web (API / Web App / SaaS backend)

> For web projects, **ask the user before implementing** the framework and doc-UI choices below —
> do not assume. Default to a **modular monolith** with clean-architecture boundaries.

- **Framework — ASK FIRST, pick one:**
  - **FastAPI** — **preferred** for JSON APIs; async, Pydantic validation, auto OpenAPI.
  - **Flask** — lightweight, sync, flexible.
  - **Django (+ DRF)** — batteries-included, admin, ORM, larger apps.
  - Whichever is chosen: **route handlers stay thin** and delegate to `application` use cases via DI.
- **API documentation UI — ASK FIRST:** FastAPI ships **Swagger UI + ReDoc** automatically; or serve
  **Scalar** over the generated OpenAPI. Django/Flask: use **drf-spectacular** / **flasgger** /
  **apispec**. Always expose the **OpenAPI spec** so third parties can consume/import the API.

**Solution layout (clean architecture):**
```
src/<project>/
  api/             → routers/controllers, middleware, DI wiring, app factory, OpenAPI
  contracts/       → public API model: Pydantic request/response schemas (no domain import)
  application/     → use cases (commands/queries), service Protocols, orchestration
  domain/          → entities, value objects, domain enums, business rules (framework-free)
  persistence/     → DB: SQLAlchemy models, repositories, migrations (Alembic), SQL
  infrastructure/  → email, object storage, PDF, payment, 3rd-party adapters
```
Dependency direction: `api → application → domain`, `api → contracts`; `persistence`/`infrastructure`
`→ application → domain`. **Domain imports nothing framework-related.** **Contracts never import Domain.**

**Pragmatic DDD & organization:**
- Model business concepts as plain classes/`@dataclass` **entities** (identity + behavior) and
  **value objects** (`frozen=True`, hold invariants — e.g. `Money`, `TaxRate`) in `domain/value_objects/`.
  Don't wrap every primitive.
- Aggregate roots are a **modeling rule** (outside code touches the aggregate via its root), not a base
  class.
- Organize `application` **by feature / vertical slice**:
  `application/features/<feature>/{create,update,delete,get,search}.py` with shared bits under
  `application/common/`.
- **CQRS-lite:** command (state-changing) and query (read) objects; a mediator is **optional**.

**Validation strategy (layered):**
- **Input** — **Pydantic** schemas in `contracts` (required fields, types, lengths, formats). No core
  business rules here.
- **Business** — application/domain (entity exists, belongs to tenant, state allows the operation).
- **Database** — constraints (PK/FK/unique/not-null/indexes).

**Data access:**
- **PostgreSQL** via **psycopg (v3)** / **asyncpg**. ORM: **SQLAlchemy 2.x** (typed) with **Alembic**
  migrations; use **SQLModel** if you want Pydantic+SQLAlchemy together. Raw SQL is fine for
  read-heavy/complex queries — **always parameterize**, never f-string user input into SQL.
- Consider **Supabase** for managed Postgres/auth/storage where it fits.
- Serialize **enums as strings** in API responses (`"status": "paid"`, not `2`).

**Multi-tenancy (if multiple tenants/companies):**
- Carry a `tenant_id`/`company_id` on tenant-owned tables; every request establishes tenant context and
  the backend **prevents cross-tenant access**. This is a security requirement, not a UI concern.

**Security & ops — suggest tooling to the user:**
- AuthN/AuthZ (OAuth2/OIDC, JWT via `python-jose`/`authlib`, session auth, or Supabase Auth), HTTPS
  (redirect HTTP→HTTPS), CORS policy, rate limiting (`slowapi`/proxy), secure headers, secrets via env,
  audit logging for important actions, DB backups.
- Security scanning: **`pip-audit`**/`safety` (deps), **`bandit`** (code), Dependabot/CodeQL.
- Reverse proxy / TLS / load balancing: **Caddy** (auto-HTTPS, simplest) initially, or **Nginx** /
  **Traefik** for larger infra.
- Observability: structured logging (`structlog`) with context, **OpenTelemetry**, `/health` endpoint,
  Sentry for error monitoring.
- Server: **Uvicorn** (ASGI) behind **Gunicorn** workers for FastAPI; **Gunicorn** for Flask/Django.
- Background jobs (**Celery**/**RQ**/**Dramatiq** + Redis broker) and caching (**Redis**) only when a
  concrete need appears.

**Consistent error format** (standardize before frontend work; never leak internal exceptions/tracebacks):
```json
{ "code": "company.not_found", "message": "Company was not found.", "details": [] }
```

**Abstractions:** put email, PDF generation, and file/object storage behind Protocols in `application`;
implement in `infrastructure`. Don't store large files in Postgres — use S3-compatible / Hetzner Object
Storage. Call external HTTP APIs with **`httpx`** (explicit timeouts, reused client) behind an adapter.

**Deployment:** containerize with **Docker** (+ `docker-compose` for local API + Postgres + optional
Redis). Deploy to **Hetzner Cloud** via **Dokploy** (or Fly.io/Railway/Render) behind the reverse proxy
with HTTPS. Keep initial infra small.

**Endpoint documentation (required):** **always document every endpoint** — route, method, request/
response schemas, status codes, auth requirements — in code (docstrings / OpenAPI metadata) and in the
living docs, and **export the OpenAPI spec** so third parties can get a copy of the API.

- **Docs:** README covers run/config/DB setup; AGENTS.md documents the chosen framework, doc UI, and
  layer/dependency rules; keep endpoint docs + OpenAPI spec updated as endpoints change.

**Suggested backend build order:** Foundation (project/deps/DI/config) → Domain → Application
(commands/queries/validation/mapping) → Persistence (models/migrations/repositories) → API
(routers/auth/error handling/OpenAPI) → feature functionality → tests (unit/integration) → production
infra (Docker/Dokploy/Hetzner/HTTPS/backups/CI-CD/monitoring) → frontend.

---

### 2.D — Library / Package

- **Layout:** `src/` layout with a single top-level package; public API re-exported from
  `__init__.py`; internal modules prefixed `_`.
- **Typing:** ship a `py.typed` marker (PEP 561) so consumers get your type hints.
- **Build/publish:** `uv build` → wheel + sdist; publish to PyPI (Trusted Publishing/OIDC preferred).
  Semantic versioning; maintain a `CHANGELOG.md`.
- **Docs:** MkDocs Material or Sphinx; document the public API with docstrings + examples.
- **No app entry point / UI** — keep it importable and side-effect-free at import time.

---

### 2.E — Data / ML

- **Env:** `uv`/conda; pin exact versions for reproducibility. Keep notebooks out of the import path.
- **Stack:** `pandas`/`polars`, `numpy`, `scikit-learn`, `matplotlib`/`plotly`; PyTorch/TF only if
  needed. Data validation via **Pandera**/**Pydantic**.
- **Structure:** separate `data/` (git-ignored raw/processed), `notebooks/` (exploration),
  `src/<project>/` (reusable, tested pipeline code). Move logic out of notebooks into tested modules.
- **Reproducibility:** seed RNGs, log parameters/metrics (MLflow/Weights & Biases if warranted),
  version data/artifacts.
- **Serving (if needed):** wrap the model behind a FastAPI endpoint (see 2.C).

---

## 3. Scaffolding Checklist (what I will produce)

When you give me the filled-in template from Section 0, I will:

- [ ] Create the `src/` layout package + `pyproject.toml` (deps, Ruff, mypy, pytest config) + lockfile.
- [ ] Set up the venv (`uv sync`), `.gitignore`, `.pre-commit-config.yaml`, `LICENSE`.
- [ ] Wire a composition root (DI), typed settings (Pydantic), and structured logging.
- [ ] Add the target-specific framework + a working shell (CLI app / main window / app factory).
- [ ] Implement the **light/dark theme toggle** and **Material Symbols icons** (GUI targets).
- [ ] Buttons use icons where available and **no trailing ellipsis** labels (GUI).
- [ ] Add a sample feature slice end-to-end (entrypoint → application service → domain).
- [ ] Add a pytest suite with one passing unit test (+ integration scaffold where relevant).
- [ ] Add a git-ignored **`publish/`** folder + a **publish script** producing zipped, per-platform
      builds (PyInstaller/`uv build`).
- [ ] For Web: confirm framework (FastAPI/Flask/Django) + doc UI first, then document all endpoints +
      export the OpenAPI spec.
- [ ] Generate **`README.md`**, **`AGENTS.md`**, and living `docs/`.
- [ ] Verify it installs, lints, type-checks, tests, and runs.

---

## 4. Always Do / Never Do (quick reference)

**Always**
- Type hints everywhere; run Ruff + mypy.
- `str.casefold()` for case-insensitive comparisons; f-strings; `pathlib`.
- Protocols/ABCs + constructor DI across boundaries (where DI adds value).
- Business logic in `domain`/`application`; entrypoint/UI stays thin.
- One concern per module; `snake_case` modules, `PascalCase` classes.
- Buttons: icons where possible, no trailing ellipsis labels; desktop uses Material Symbols icons.
- Release artifacts go to the git-ignored `publish/` folder, zipped per platform.
- Update README, AGENTS.md, and living docs when changes warrant it; Web: document endpoints.

**Never**
- Business logic in route handlers, widget callbacks, or `__main__`.
- Constructing dependencies/globals that should be injected.
- Hardcoded secrets, or f-stringing untrusted input into SQL.
- `print()` for diagnostics in library code; logging secrets/PII.
- Over-engineered patterns (or premature Redis/Celery/microservices) where a simple module suffices.
- Installing into system Python; committing `.venv/`, build output, or `.env`.
- Implementing a web framework or doc UI without asking the user first.

---

## 5. Recommended packages by task

> Pick the **bold "default"** unless a project has a specific reason to choose otherwise. Add a
> dependency only when the task actually arises — don't install all of these up front.

### 5.1 Data handling / analysis
- **`polars`** — **default** for new work: fast, memory-efficient, lazy engine, expressive API.
- **`pandas`** — ubiquitous, huge ecosystem; choose it for interop/legacy or when a library expects it.
- **`numpy`** — numeric arrays; foundation for the above.
- **`pyarrow`** — Arrow/Parquet IO and zero-copy interchange (backs both pandas and polars).
- **`duckdb`** — in-process SQL over DataFrames/Parquet/CSV; great for analytical queries without a server.
- **`pandera`** — schema validation for DataFrames (pairs well with Pydantic for boundaries).
- **`dask`** — only when data genuinely exceeds memory / needs parallel/distributed compute.

### 5.2 Excel & CSV
- **`openpyxl`** — **default** for `.xlsx` read *and* write (styles, formulas, worksheets).
- **`XlsxWriter`** — write-only, but richer formatting/charts and faster for large writes.
- **`python-calamine`** — very fast reader for `.xlsx`/`.xls`/`.ods` (also the fast pandas engine).
- **`pandas` / `polars`** — `read_excel` / `read_csv` / `write_csv` for bulk tabular IO.
- **stdlib `csv`** — **default** for simple CSV read/write with no extra dependency.
- **`xlwings`** — drive a live Excel app (Windows/macOS) for automation/macros (needs Excel installed).

### 5.3 PDFs — create & manage
- **`reportlab`** — **default for generating PDFs from code** (precise layout, tables, vector, fonts).
- **`pymupdf`** (import `fitz`) — **default for reading/manipulating**: fast render, text/image
  extraction, merge/split, redaction, annotations. (AGPL/commercial — check licensing.)
- **`pypdf`** — pure-Python merge/split/rotate/crop, metadata, basic encryption (permissive license).
- **`pikepdf`** — low-level structural edits, strong encryption/repair (qpdf-based).
- **`pdfplumber`** — best-in-class **text & table extraction** and layout inspection.
- **`fpdf2`** — lightweight PDF generation (simpler alternative to ReportLab).
- **`borb`** — modern, Pythonic PDF create/read library.
- `pdfminer.six` — detailed low-level text extraction (pdfplumber builds on it).

### 5.4 HTML/CSS → PDF
- **`weasyprint`** — **default**: pure-Python, strong modern CSS (print stylesheets, `@page`), no
  browser needed; ideal for invoices/reports from HTML templates (pair with **Jinja2**).
- **`xhtml2pdf`** — lighter, simpler CSS support; good for basic documents.
- **Playwright (headless Chromium)** — pixel-perfect for complex/modern CSS & JS-rendered pages
  (`page.pdf()`); heavier (bundles a browser) but the most accurate.
- `pdfkit` + **wkhtmltopdf** — older wkhtmltopdf wrapper; usable but wkhtmltopdf is largely
  unmaintained — prefer WeasyPrint or Playwright for new work.

### 5.5 CQRS / Mediator
- First choice: a **small hand-rolled in-process command/query bus** — a dict mapping request type →
  handler, resolved via your DI container. Consistent with this guide's "mediator optional" stance and
  usually all a monolith needs.
- **`mediatr`** (mediatr_py) — MediatR-style handlers with **pipeline behaviors** (validation/logging)
  and async; closest feel to .NET MediatR when you want a library.
- **`diator`** — CQRS with commands/queries + an event bus (in-proc or Redis) for event-driven flows.
- `didiator` / `pymediator` — lighter mediator implementations with DI integration.
- Cross-service messaging (only when needed): **FastStream** or **faststream/celery** over a broker —
  not a substitute for an in-process mediator.

### 5.6 Handy extras (commonly useful)
- **Templating:** `jinja2` (HTML/report templates → feed WeasyPrint/email).
- **Dates/tz:** stdlib `zoneinfo`; `python-dateutil` for parsing/recurrence.
- **Money/decimals:** stdlib `decimal` for currency; `money`/`py-moneyed` if you want a Money type.
- **Retries/resilience:** `tenacity`.
- **Images:** `Pillow`.
- **Env/CLI UX:** `python-dotenv` (local `.env`), `rich`/`typer` (CLI), `tqdm` (progress).
