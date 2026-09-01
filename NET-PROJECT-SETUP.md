# .NET C# Project Setup — Universal Instructions

> **How to use this file:** When you start a new .NET C# project, hand me this file and tell me:
> 1. The **project name** (e.g. `QuickTools`).
> 2. The **UI target** — one of: `CLI`, `WinForms`, `Avalonia`, `QT6`, `ASP.NET`.
> 3. Any project-specific extras (features, external services, etc.).
>
> I will read the **Shared Foundation** section (always applies) plus the matching **UI Variation**
> section, then scaffold the project accordingly.

---

## 0. Quick Answer Template (fill this in when starting)

```text
Project name : <MyProject>
UI target    : <CLI | WinForms | Avalonia | QT6 | ASP.NET>
.NET version : .NET 10 (net10.0)  ← default unless told otherwise
Extras       : <optional: features, APIs, DB, auth, etc.>
```

---

## 1. Shared Foundation (applies to EVERY project)

### 1.1 Platform & tooling
- **Target framework:** latest .NET
- **Language version:** latest C# (`<LangVersion>latest</LangVersion>`).
- Enable `<Nullable>enable</Nullable>` and `<ImplicitUsings>enable</ImplicitUsings>`.
- Enable `<TreatWarningsAsErrors>false</TreatWarningsAsErrors>` initially; tighten later if desired.
- Use **central package management**: a `Directory.Packages.props` at the repo root pins all
  NuGet versions; a `Directory.Build.props` holds shared MSBuild properties (nullable, langversion,
  authors, license metadata).

### 1.2 Architecture
Use a **modern, layered, clean architecture** with clear separation of concerns:

```
src/
  <Project>.Core/          → domain models, interfaces, business logic (NO UI, NO framework deps)
  <Project>.Infrastructure/→ implementations: data access, external APIs, file IO, DI wiring
  <Project>.App/ (or .UI)  → the entry point / UI layer (CLI, WinForms, Avalonia, QT6)
tests/
  <Project>.Tests/         → unit tests (xUnit)
```

- **Business logic lives in its own classes** in `.Core` / `.Infrastructure` — never in UI code-behind
  or `Program.cs`.
- **UI components are separated into their own classes** (one View + one ViewModel/Presenter per
  screen/feature; no god-classes).
- Depend on **interfaces**, not concrete types, across layer boundaries.

### 1.3 SOLID & design principles
- **S**ingle Responsibility — one reason to change per class.
- **O**pen/Closed — extend via new types/strategies, avoid editing stable code.
- **L**iskov — subtypes must honor their base contract.
- **I**nterface Segregation — small, focused interfaces (`IReadStore`, `IWriteStore`, not one fat one).
- **D**ependency Inversion — high-level modules depend on abstractions.
- **Build the simplest architecture that meets the current requirements.** Prefer a **modular
  monolith** over microservices; keep boundaries clean so services can be extracted later *if the
  business actually has a distributed-system problem*. Add infrastructure (Redis, message bus,
  background-job engine, Kubernetes, event bus) **only when a concrete need exists** — not because a
  tutorial uses it.

### 1.4 Dependency Injection
- Use **`Microsoft.Extensions.DependencyInjection`** (via `Microsoft.Extensions.Hosting` where a host
  makes sense) — **use DI where it is required/adds value**, not dogmatically for trivial value types
  or one-off helpers.
- Register services in a single composition root (e.g. `ServiceCollectionExtensions.AddAppServices()`).
- Constructor injection only; no service locator, no `new`-ing dependencies inside classes.
- Prefer scoped/transient lifetimes for stateful services, singletons for stateless/shared ones.

### 1.5 Design patterns (use where they genuinely help — do not over-engineer)
- **Repository** for data access abstraction.
- **Factory** / **Abstract Factory** for provider/strategy creation.
- **Strategy** for interchangeable algorithms/providers.
- **Options pattern** (`IOptions<T>`) for configuration.
- **Mediator / Command** only if the app is large enough to warrant it.
- **MVVM** for Avalonia/WinForms; **MVC/Presenter** style for CLI/QT6 where appropriate.

### 1.6 Coding conventions
- **Prefer explicit types over `var`.** Write `List<Customer> customers = ...`, not `var customers`.
- **Use LINQ only where it improves clarity.** For hot paths or simple loops, prefer an explicit
  `foreach`. Avoid deeply chained LINQ that hurts readability.
- **String comparison is case-insensitive by default:** use
  `string.Equals(a, b, StringComparison.OrdinalIgnoreCase)` and
  `StringComparison.OrdinalIgnoreCase` in `Contains`/`StartsWith`/dictionary keys. Never compare
  strings with `==` when case should be ignored.
- **Braces on all control blocks**, even single-line.
- `async`/`await` all the way down for IO; suffix async methods with `Async`.
- One public type per file; file name matches type name.
- Use `readonly` fields and immutable models (`record` types) where practical.
- Prefer `IReadOnlyList<T>` / `IReadOnlyDictionary<T>` on public APIs over mutable collections.
- **Prefer composition over inheritance.** Do not create empty base classes (e.g. a generic
  `Entity<T>` / `AuditableEntity` / `AggregateRoot`) just to represent a concept — use small,
  focused interfaces (`IEntity<TId>`, `IAuditableEntity`) only where they add practical value.
- **Prefer explicit/manual mapping** (extension methods or constructors) over AutoMapper/Mapster.
  Keep feature-specific mapping near the feature; put truly reusable mappers in `Common/Extensions`.
- **Classes by default.** Use `record` only when immutability/value semantics genuinely help; avoid
  `struct`/`record struct` unless a demonstrated performance or domain need justifies it.

### 1.7 Configuration & logging
- Configuration via `appsettings.json` + environment variables (`Microsoft.Extensions.Configuration`).
- Logging via `Microsoft.Extensions.Logging` (console provider minimum). No `Console.WriteLine` for
  diagnostics in library code.
- Never hardcode secrets. Read from environment variables or user-secrets.

### 1.8 Testing
- **xUnit** for unit tests, **FluentAssertions** for readable asserts, **NSubstitute** (or Moq) for
  mocking interfaces.
- Test the `.Core` / `.Infrastructure` logic; UI stays thin enough to need little testing.
- **Integration tests** for real data access / API endpoints; use **Testcontainers** for disposable
  PostgreSQL/Redis where useful.
- **Architecture tests** (e.g. `NetArchTest`) to enforce dependency rules — Domain must not
  reference Infrastructure/API; Application must not reference API; Contracts must not reference Domain.

### 1.9 Required documentation (always create these)
- **`README.md`** — project description, features, prerequisites, build/run instructions, project
  structure, configuration, license.
- **`AGENTS.md`** — guidance for AI agents/contributors: architecture overview, conventions (this
  file's rules), build commands, "always do / never do" list, and a roadmap/TODO section.
- Keep both updated whenever changes warrant it.

### 1.10 Repo hygiene
- Add a proper `.gitignore` (`dotnet new gitignore` or the standard VS template).
- Add a `.editorconfig` enforcing the conventions above (explicit types, braces, ordering).
- Add a `LICENSE` file (ask which license; default to MIT unless told otherwise).
- Solution file: prefer the new `.slnx` format.

### 1.11 Standard build/run commands
```bash
dotnet restore
dotnet build
dotnet test
dotnet run --project src/<Project>.App
```

### 1.12 Build, publish & packaging (required)
- Create a top-level **`publish/`** folder that is **git-ignored** (add `publish/` to `.gitignore`).
  All release builds are produced here — never commit build artifacts.
- Produce release builds into `publish/<runtime-id>/` per target platform.
- **Prefer self-contained, single-file builds** (bundles the runtime so the user needs no .NET
  install). If self-contained is not feasible for the target, a framework-dependent build is OK —
  say so in the README.
  ```bash
  # example per target; --self-contained true where possible
  dotnet publish src/<Project>.App -c Release -r win-x64   --self-contained true \
    -p:PublishSingleFile=true -o publish/win-x64
  dotnet publish src/<Project>.App -c Release -r linux-x64 --self-contained true \
    -p:PublishSingleFile=true -o publish/linux-x64
  dotnet publish src/<Project>.App -c Release -r osx-x64   --self-contained true \
    -p:PublishSingleFile=true -o publish/osx-x64
  ```
- **Zip each platform build**, named after the target it builds for, e.g.
  `publish/<Project>-<version>-win-x64.zip`, `...-linux-x64.zip`, `...-osx-arm64.zip`.
- Provide a small **publish script** (`publish.ps1` and/or `publish.sh`) that builds, zips, and names
  each platform archive, so releases are one command.
- Common runtime IDs: `win-x64`, `win-arm64`, `linux-x64`, `linux-arm64`, `osx-x64`, `osx-arm64`.

### 1.13 UI & button conventions (all GUI targets)
- **Buttons must not use trailing ellipsis text** (no `Save...`, no `Open...`). Use plain, direct
  labels (`Save`, `Open`, `Export`).
- **Buttons should have an icon where one is available**, paired with (or replacing) the label.
- **Desktop apps always use Google Material Symbols icons** (https://fonts.google.com/icons) unless
  the user specifies otherwise. Icons must recolor with the active light/dark theme.
- Keep interactive controls accessible: tooltips for icon-only buttons, keyboard focus, and adequate
  contrast in both themes.

### 1.14 Documentation (living — keep it current)
- Every project ships **`README.md`** and **`AGENTS.md`** (see 1.9).
- Additionally create **living software documentation** for the tool/app being built (a `docs/` folder
  or a `DOCUMENTATION.md`) describing features, usage, configuration, and architecture.
- **Documentation must be kept up to date** — whenever behavior, commands, endpoints, or structure
  change, update the docs in the same change so they stay relevant.

### 1.15 Local dev environment & deployment tooling
Assume the following are available; if a tool is missing, **suggest installing it (or a listed
alternative)** rather than failing silently:
- **Docker** — for containerized local services and reproducible builds. If not installed, suggest
  installing Docker Desktop (or alternatives: Podman, Rancher Desktop, OrbStack on macOS).
- **PostgreSQL (local)** — default relational database. If not installed, suggest installing Postgres
  (native installer, or run via Docker `postgres` image).
- **Supabase account** — suggest using Supabase (managed Postgres + auth + storage) when it fits the
  project (quick auth, hosted DB, realtime, storage) instead of hand-rolling those.
- **Hosting/going live** — when the app should be made available to others, suggest **Hetzner**
  (cost-effective VPS/cloud) or alternatives (Fly.io, Railway, Render, DigitalOcean, Azure/AWS).
  Recommend Docker-based deployment and mention TLS/reverse-proxy (Caddy/Traefik/Nginx).

---

## 2. UI Variations

Pick the ONE that matches the chosen UI target. All of them still follow the Shared Foundation above.

---

### 2.A — CLI (Console)

- **SDK:** `Microsoft.NET.Sdk`, `OutputType=Exe`, `net10.0`.
- **Framework:** use **`System.CommandLine`** for argument parsing, subcommands, options, and help.
- **Host:** use `Host.CreateApplicationBuilder` (Generic Host) so DI, configuration, and logging are
  available exactly like a service app.
- **Structure:**
  - `Program.cs` → build host, register services, wire the root command, invoke.
  - `Commands/` → one class per command (`ExportCommand`, `SyncCommand`), each depending on `.Core`
    services via constructor injection.
  - Command classes contain **no business logic** — they parse input and delegate to `.Core`.
- **Output:** for rich console UX use **`Spectre.Console`** (tables, prompts, progress, colored
  output). Respect a `--no-color` / non-interactive mode.
- **Theme note:** N/A for CLI, but honor the terminal's light/dark background — don't hardcode colors
  that vanish on light terminals; use Spectre's theme-aware styles.
- **Docs:** README documents every command with examples; AGENTS.md lists the command map.

---

### 2.B — WinForms (Windows only)

- **SDK:** `Microsoft.NET.Sdk`, `net10.0-windows`, `<UseWindowsForms>true</UseWindowsForms>`,
  `OutputType=WinExe`.
- **Pattern:** **MVP (Model-View-Presenter)** or lightweight MVVM. Forms are **Views only**:
  - Each form implements an `IView` interface exposing events + properties.
  - A **Presenter** class (in `.Core`/`.App` logic layer) holds the business logic and talks to
    services. **No business logic in the `.cs` code-behind.**
  - Wire Presenters and services through the DI container built at startup in `Program.cs`.
- **Separation:** one form = one file/class; shared UI widgets extracted into their own `UserControl`
  classes; dialogs/message boxes go through an `IDialogService`.
- **Light/Dark mode toggle (required):**
  - Implement an `IThemeService` with `ApplyTheme(ThemeMode mode)` that recolors forms/controls.
  - Prefer a maintained theming library — **`DarkModeForms`** or manual palette application
    (BackColor/ForeColor across the control tree + Win32 immersive dark title bar via
    `DwmSetWindowAttribute`).
  - Persist the chosen theme in settings; expose a toggle in the UI (menu item or switch).
- **Google Material Symbols icons (required):**
  - Download the SVG/PNG icons from https://fonts.google.com/icons (Material Symbols).
  - Preferred: bundle the **Material Symbols variable font** and render glyphs, OR embed SVGs and
    render via **Svg.Skia** / rasterize to `Image`. Simplest reliable path: export the needed icons
    as PNG at multiple DPIs into `Resources/Icons/` and use them on buttons/menus.
  - Icons must recolor with the theme (tint light icons for dark mode and vice versa).
- **Docs:** README build/run (Windows-only note); AGENTS.md documents the MVP contract and theming.

---

### 2.C — Avalonia UI (Cross-platform: Windows / Linux / macOS / mobile)

- **SDK:** Avalonia (latest, **12.x**), `net10.0`. Use the Avalonia MVVM template layout.
- **Pattern:** **MVVM** with **`CommunityToolkit.Mvvm`** (`ObservableObject`,
  `[ObservableProperty]`, `[RelayCommand]`).
  - One **View** (`.axaml` + minimal code-behind) and one **ViewModel** per screen/feature.
  - **ViewModels contain no framework/UI types**; they call `.Core` services via DI.
  - Use a `ViewLocator` to map ViewModels → Views.
  - Enable **compiled bindings** (`AvaloniaUseCompiledBindingsByDefault=true`, `x:DataType` on views).
- **DI:** register services + ViewModels in a composition root; resolve the main window/VM from the
  container at startup (`App.axaml.cs` `OnFrameworkInitializationCompleted`).
- **Dialogs/IO:** abstract behind `IDialogService` / `IStorageService` (wrap Avalonia
  `StorageProvider`) so ViewModels stay testable.
- **Light/Dark mode toggle (required):**
  - Use Avalonia's `FluentTheme` with `RequestedThemeVariant` = `Light` / `Dark`.
  - Provide an `IThemeService` + a UI toggle (button/switch/menu) that flips
    `Application.Current.RequestedThemeVariant` and persists the choice.
  - Define colors via `ThemeVariantScope` / dynamic resources so both variants look correct.
- **Google Material Symbols icons (required):**
  - Preferred: **`Material.Icons.Avalonia`** NuGet (Material Design icon set) via the
    `<icons:MaterialIcon Kind="..." />` control — themeable through foreground brushes.
  - Alternatively embed the Material Symbols SVGs and render with `Avalonia.Svg.Skia`.
  - Icons bind their brush to the theme so they invert correctly in light/dark.
- **Cross-platform heads:** if desktop-only for now, a single `Desktop` head is fine; if mobile is
  planned, split into a shared library + `.Desktop` / `.Android` / `.iOS` heads.
- **Docs:** README lists supported OSes + run commands; AGENTS.md documents MVVM/ViewLocator/theming.

---

### 2.D — QT6 (via C# bindings)

> QT6 is native C++; for a **.NET C#** project use a managed binding. Preferred: **`Qml.Net`**
> (Qt Quick / QML from C#) or **`Avalonia`** if the goal is really just cross-platform XAML. If the
> user truly wants Qt Widgets from C#, note that binding options are limited and confirm the choice.

- **SDK:** `Microsoft.NET.Sdk`, `net10.0`, referencing **`Qml.Net`** (+ `Qml.Net.<runtime>` native
  packages for each OS).
- **Pattern:** **MVVM**. The UI is authored in **QML**; C# provides ViewModels registered as QML
  types (`QmlType`/`[Signal]`/`[NotifySignal]` properties).
  - QML files (`Views/*.qml`) are Views; C# ViewModel classes hold state + commands.
  - **ViewModels call `.Core` services via DI**; no business logic in QML.
  - Register ViewModels with the Qml engine at startup; build the DI container first and resolve VMs.
- **DI:** standard `Microsoft.Extensions.DependencyInjection`; expose resolved ViewModels to QML.
- **Light/Dark mode toggle (required):**
  - Use **Qt Quick Controls 2** theming (`Material` or `Universal` style) and switch
    `Material.theme` between `Light`/`Dark` (or a custom color singleton) from a bound C# property.
  - Provide an `IThemeService` + UI toggle that updates the QML theme property and persists it.
- **Google Material Symbols icons (required):**
  - Bundle the **Material Symbols** font (or SVGs) as Qt resources; render glyphs via a `Text`
    element with the icon font, or `Image`/`IconImage` for SVGs. Color follows the theme.
- **Build/run:** `dotnet run` launches the Qml.Net host that loads the root QML. Document the native
  runtime package per OS.
- **Docs:** README covers Qt runtime prerequisites + per-OS packages; AGENTS.md documents the
  QML↔C# ViewModel contract and theming.

---

### 2.E — ASP.NET (Web API / Web App / SaaS backend)

> For ASP.NET projects, **ask the user before implementing** the API-style and doc-UI choices below —
> do not assume. Default to a **modular monolith** with clean-architecture boundaries.

- **SDK:** `Microsoft.NET.Sdk.Web`, `net10.0`.

**Solution layout (clean architecture — replaces the generic Core/Infrastructure split):**
```
src/
  <Project>.Api            → HTTP host: endpoints/controllers, middleware, DI wiring, OpenAPI
  <Project>.Contracts      → public API model: Requests / Responses / DTOs (NO Domain reference)
  <Project>.Application    → use cases (Commands/Queries), validators, interfaces, orchestration
  <Project>.Domain         → entities, value objects, domain enums, business rules (framework-free)
  <Project>.Persistence    → DB concerns: Npgsql, Dapper, EF Core, repositories, migrations, SQL
  <Project>.Infrastructure → external concerns: email, file/object storage, PDF, payment, 3rd-party
  <Project>.SharedKernel   → cross-cutting primitives (Result, guards, base value-object helper)
tests/
  <Project>.UnitTests / .IntegrationTests / .ArchitectureTests
```
Dependency direction: `Api → Application → Domain`, `Api → Contracts`; `Infrastructure`/`Persistence`
`→ Application → Domain`. **Domain references nothing framework-related** (no ASP.NET, EF, Dapper,
Npgsql, Redis, HTTP). **Contracts never reference Domain** — keeps API model decoupled from internals.

- **API style — ASK FIRST, pick one:**
  - **MVC controllers** — conventional, attribute-routed controllers.
  - **Minimal APIs** — endpoint delegates grouped by feature (`MapGroup`).
  - **FastEndpoints** — REPR-pattern endpoint classes (one class per endpoint).
  - Whichever is chosen: **endpoints stay thin** and delegate to Application use cases via DI.
- **API documentation UI — ASK FIRST, pick one:** **Swagger / Swashbuckle** or **Scalar**. Either
  way, generate an **OpenAPI document** so third parties can consume/import the API.

**Pragmatic DDD & organization:**
- Model business concepts as plain C# **entities** (identity + behavior) and **value objects**
  (defined by value, hold invariants — e.g. `Money`, `Address`, `TaxRate`) in a `Domain/ValueObjects`
  folder. Don't wrap every primitive in a value object.
- Treat aggregate roots as a **modeling rule** (outside code touches the aggregate via its root), not
  a mandatory base class.
- Organize the Application layer **by feature / vertical slice**, not by technical folders:
  `Application/Features/<Feature>/{Create,Update,Delete,Get,Search}` with shared bits under
  `Application/Common/{Interfaces,Behaviors,Exceptions,Extensions}`.
- **CQRS-lite:** use Command (state-changing) and Query (read) objects. A mediator library is
  **optional** — direct handler invocation is fine when clearer.

**Validation strategy (layered):**
- **Input** — `FluentValidation` (required fields, lengths, formats, ranges, collections). Do NOT put
  core business rules here.
- **Business** — Application/Domain (entity exists, belongs to tenant, state allows the operation).
- **Database** — constraints (PK/FK/unique/not-null/indexes).

**Data access:**
- **PostgreSQL** via **Npgsql**. Prefer **Dapper** for read-heavy/SQL-intensive work; use **EF Core**
  selectively (simple CRUD, migrations, change tracking). Both may coexist — just not for the same
  operation without reason. PostgreSQL functions/procedures only where genuinely database-centric.
- **Always parameterize SQL** — never concatenate untrusted input. Consider **Supabase** for managed
  Postgres/auth/storage where it fits.
- Serialize **enums as strings** in API responses (`"status": "Paid"`, not `2`).

**Multi-tenancy (if multiple companies/tenants use the system):**
- Carry a `TenantId`/`CompanyId` on tenant-owned tables; every request must establish tenant context
  and the backend must **prevent cross-tenant data access**. This is a security requirement, not a UI
  concern.

**Security & ops — suggest tooling to the user:**
- AuthN/AuthZ (JWT bearer, ASP.NET Identity, OAuth/OIDC, or Supabase Auth), HTTPS/HSTS (redirect HTTP
  → HTTPS), CORS policy, rate limiting (`Microsoft.AspNetCore.RateLimiting`), secure headers, secrets
  via env vars / user-secrets, audit logging for important actions, database backups.
- Security scanning (OWASP ZAP, `dotnet list package --vulnerable`, Dependabot/CodeQL).
- Reverse proxy / TLS / load balancing: **Caddy** (auto-HTTPS, simplest) initially, or **Nginx** /
  **Traefik** / **YARP** for larger infrastructure.
- Observability: structured logging (Serilog + `Microsoft.Extensions.Logging`) with context
  (request/user/tenant id, operation, duration) — never log secrets/PII; OpenTelemetry; `/health`.
- Background jobs (**Hangfire**) and caching (**Redis**) only when a concrete need appears.

**Consistent error format** (standardize before frontend work; never leak internal exceptions):
```json
{ "code": "company.not_found", "message": "Company was not found.", "details": [] }
```

**Abstractions:** put `IEmailService`, PDF generation, and file/object storage behind interfaces in
Application; implement in Infrastructure. Don't store large files in PostgreSQL — use S3-compatible /
Hetzner Object Storage.

**Deployment:** containerize with **Docker** (+ `docker-compose` for local API + Postgres + optional
Redis). Deploy to **Hetzner Cloud** via **Dokploy** (or Fly.io/Railway/Render) behind the reverse
proxy with HTTPS. Keep initial infra small — don't provision distributed architecture before there
are users.

**Endpoint documentation (required):** **always document every endpoint** — route, method, request/
response DTOs, status codes, auth requirements — in code (XML docs / OpenAPI annotations) and in the
living docs, and **export the OpenAPI spec** so third parties can get a copy of the API.

- **Docs:** README covers run/config/DB setup; AGENTS.md documents the chosen API style, doc UI, and
  layer/dependency rules; keep endpoint docs + OpenAPI spec updated as endpoints change.

**Suggested build order for a backend:** Foundation (solution/projects/DI/config) → Domain → Application
(commands/queries/validators/mapping) → Persistence (schema/migrations/repositories) → API
(endpoints/auth/error handling/OpenAPI) → feature functionality → tests (unit/integration/architecture)
→ production infra (Docker/Dokploy/Hetzner/HTTPS/backups/CI-CD/monitoring) → frontend.

---

## 3. Scaffolding Checklist (what I will produce)

When you give me the filled-in template from Section 0, I will:

- [ ] Create the solution (`.slnx`) and the layered projects (`Core`, `Infrastructure`, UI, `Tests`).
- [ ] Add `Directory.Build.props`, `Directory.Packages.props`, `.editorconfig`, `.gitignore`, `LICENSE`.
- [ ] Wire up DI, configuration, and logging in the composition root.
- [ ] Add the UI-specific framework packages + a working shell (main window/command/root screen).
- [ ] Implement the **light/dark theme toggle** and **Material Symbols icons** (non-CLI targets).
- [ ] Buttons use icons where available and **no trailing ellipsis** labels.
- [ ] Add a sample feature slice end-to-end (View/Command → ViewModel/Presenter → Core service).
- [ ] Add a starter xUnit test project with one passing test.
- [ ] Add a git-ignored **`publish/`** folder + a **publish script** producing zipped, per-platform
      (self-contained where possible) builds.
- [ ] For ASP.NET: confirm API style (MVC/Minimal/FastEndpoints) + doc UI (Swagger/Scalar) first,
      then document all endpoints + export the OpenAPI spec.
- [ ] Generate **`README.md`**, **`AGENTS.md`**, and living software documentation.
- [ ] Verify it builds (`dotnet build`) and runs.

---

## 4. Always Do / Never Do (quick reference)

**Always**
- Explicit types over `var`.
- `StringComparison.OrdinalIgnoreCase` for text comparisons.
- Interfaces + constructor DI across boundaries (where DI adds value).
- Business logic in `.Core`/`.Infrastructure`; UI classes stay thin.
- One type per file; braces everywhere.
- Buttons: icons where possible, no trailing ellipsis labels; desktop uses Material Symbols icons.
- Release builds go to the git-ignored `publish/` folder, zipped per platform.
- Update README, AGENTS.md, and living docs when changes warrant it; ASP.NET: document endpoints.

**Never**
- Business logic in code-behind, `Program.cs`, or QML/XAML.
- `new`-ing dependencies that should be injected.
- Hardcoded secrets or theme-breaking hardcoded colors.
- Over-engineered patterns where a simple class suffices.
- LINQ that hurts readability over a plain loop.
- Commit build artifacts / the `publish/` folder.
- Implement an ASP.NET API style or doc UI without asking the user first.
