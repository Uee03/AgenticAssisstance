# AGENTS.md — .NET / C# Project

Guidance for AI agents working in this repository. Read this first, then load the skill that matches
the task. Keep this file current as the project evolves.

## Tech baseline

- **Runtime:** latest .NET (currently **.NET 10**, `net10.0`). Do not downgrade unless told to.
- **Language:** latest C# (`<LangVersion>latest</LangVersion>`), `Nullable` + `ImplicitUsings` enabled.
- **Package mgmt:** central — `Directory.Packages.props` pins versions; `Directory.Build.props` holds
  shared MSBuild props. Solution file uses the `.slnx` format.

## Skills — load the one that matches the task

Skills live in `.github/skills/`. Load a skill when its trigger matches; follow its steps.

| Skill | Use when |
|-------|----------|
| [dotnet-clean-architecture](./.github/skills/dotnet-clean-architecture/SKILL.md) | Designing layers, projects, DI, or deciding where code belongs (applies to every app type) |
| [scaffolding-dotnet-api](./.github/skills/scaffolding-dotnet-api/SKILL.md) | Building a REST/JSON **Web API** or SaaS backend |
| [scaffolding-dotnet-webapp](./.github/skills/scaffolding-dotnet-webapp/SKILL.md) | Building a server-rendered **web app** (Blazor / Razor / MVC) |
| [scaffolding-dotnet-desktop](./.github/skills/scaffolding-dotnet-desktop/SKILL.md) | Building a **Windows desktop** app (WinForms / WPF) |
| [scaffolding-dotnet-crossplatform](./.github/skills/scaffolding-dotnet-crossplatform/SKILL.md) | Building a **cross-platform** app (Avalonia / MAUI) or CLI |

## Agents

- [dotnet-scaffolder](./.github/agents/dotnet-scaffolder.agent.md) — sets up a new solution end-to-end.
- [dotnet-reviewer](./.github/agents/dotnet-reviewer.agent.md) — read-only review against these rules.

Path-scoped coding rules: [.github/instructions/dotnet-conventions.instructions.md](./.github/instructions/dotnet-conventions.instructions.md).

## Architecture (always)

Clean, layered separation. Business logic never lives in UI code-behind, `Program.cs`, or route
handlers. Depend on **interfaces** across layer boundaries. Prefer a **modular monolith**; add
infrastructure (Redis, message bus, background jobs, microservices) only when a concrete need exists.
See the clean-architecture skill for the exact project layout per app type.

## Build & run

```bash
dotnet restore
dotnet build
dotnet test
dotnet run --project src/<Project>.App   # or the API/host project
```

Release builds go to a git-ignored `publish/` folder, zipped per runtime (see the scaffolding skills).

## Project files & scripts (included in this bundle)

- `.editorconfig`, `Directory.Build.props`, `Directory.Packages.props` — code style + central package management.
- `.gitignore` — excludes `publish/` (local builds) and `.key/` (signing keys), among others.
- `.vscode/tasks.json` — run **build / test / run / publish / publish android** from VS Code (Terminal → Run Task).
- `scripts/publish.ps1` + `.sh` — self-contained per-runtime builds → `publish/` (zipped per platform).
- `scripts/build-android.ps1` + `.sh` — MAUI signed AAB → `publish/android/` (keystore in `.key/`, passwords via env vars).
- `.key/README.md` — how to create/use the Android signing keystore (contents git-ignored).

## Always do

- Business logic in `Core`/`Application`/`Domain`; keep UI/endpoints thin.
- Constructor injection via `Microsoft.Extensions.DependencyInjection`; no service locator / `new`-ing deps.
- Explicit types over `var`; braces on all control blocks; `async`/`await` all the way for IO (suffix `Async`).
- Case-insensitive string comparison with `StringComparison.OrdinalIgnoreCase`.
- One public type per file; `record` only for genuine value/immutable semantics.
- GUI buttons: icon where available, **no trailing ellipsis** labels; support light/dark theme + Material Symbols icons.
- Ship `README.md` and keep this `AGENTS.md` updated; document API endpoints + export the OpenAPI spec.
- Parameterize all SQL; read secrets from env / user-secrets.
- At project start, ask **open source vs closed/commercial** and add the matching `LICENSE`; confirm the `.gitignore` (see the `foundations` bundle).

## Never do

- Business logic in `Program.cs`, code-behind, or controllers/endpoints.
- Empty marker base classes (`Entity<T>`, `AuditableEntity`) just to model a concept — use small interfaces.
- AutoMapper/Mapster by default — prefer explicit mapping.
- Hardcoded secrets; string-concatenated SQL; `Console.WriteLine` for diagnostics in library code.
- Premature distributed architecture, or implementing an ASP.NET API style / doc UI / database choice without asking first.
