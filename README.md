# Project Template Bundles (AI-ready)

Copy-paste starter kits that make any AI coding agent (GitHub Copilot in VS Code, Claude Code,
Cursor, etc.) immediately productive and consistent on a new project. Each bundle teaches the agent
**your architecture, conventions, and scaffolding workflows** through a small, structured set of
files — so you don't re-explain them every conversation.

## What's here

**App bundles** (each is a full project starter for one stack):

| Bundle | Stack | App types covered |
|--------|-------|-------------------|
| [`dotnet/`](./dotnet) | .NET / C# (latest, .NET 10) | API, Web App, Desktop, Cross-platform |
| [`python/`](./python) | Python (latest, 3.13) | API, Web App, Desktop |
| [`flutter/`](./flutter) | Flutter / Dart (latest stable) | Frontend (mobile / web / desktop) |
| [`angular/`](./angular) | Angular (latest, v22) | Frontend (web) |

**Overlay bundles** (drop *alongside* an app bundle to add a capability — they don't stand alone):

| Bundle | Adds | Pair with |
|--------|------|-----------|
| [`foundations/`](./foundations) | Licensing, .gitignore, Docker & services, hosting & deployment (Dokploy/Coolify) | every project |
| [`sql/`](./sql) | SQLite, PostgreSQL & SQL Server standards + a database-selection guide + local Docker DBs | any backend (dotnet, python) |
| [`supabase/`](./supabase) | Supabase Auth, Postgres + RLS, Storage, CLI/migrations | any backend and/or frontend |

## How to use a bundle

1. **Copy the contents** of the chosen bundle (e.g. everything inside `dotnet/`) into the root of
   your new (empty) project folder. You should end up with an `AGENTS.md` and a `.github/` folder at
   the project root.
2. Open the project in your AI-enabled editor.
3. Tell the agent what you're building, e.g. *"Scaffold a new .NET Web API called `Billing`."* The
   agent reads `AGENTS.md`, discovers the matching **skill**, and scaffolds the project to spec.

That's it — the bundle is self-contained and needs no build step.

## How each bundle is organized

Every bundle uses the same layout so agents always know where to look:

```
<bundle>/
├── AGENTS.md                         # Entry point: always-on rules + index of skills/agents
├── .editorconfig / .gitignore / ...  # Ready-made config (language-specific)
├── .vscode/tasks.json                # Runnable build/test/run/publish tasks (Terminal → Run Task)
├── scripts/                          # publish + (where relevant) build-android scripts (.ps1 + .sh)
├── .key/                             # Signing keys (git-ignored; keeps a README) — GUI/mobile bundles
└── .github/
    ├── skills/<skill-name>/SKILL.md  # On-demand workflows (scaffolding, architecture)
    ├── agents/<name>.agent.md        # Specialized personas (scaffolder, reviewer)
    └── instructions/<name>.instructions.md  # Path-scoped rules (applied to matching files)
```

> `publish/` (local release output) and `.key/` (signing keys) are **git-ignored** in every bundle.

| Primitive | Purpose | Loaded |
|-----------|---------|--------|
| **`AGENTS.md`** | Project-wide rules + a map of everything else | Always |
| **Skills** (`SKILL.md`) | Repeatable, on-demand workflows with the "how" for a task | When the task matches the description |
| **Agents** (`*.agent.md`) | Focused personas with restricted tools (e.g. read-only reviewer) | When invoked or delegated |
| **Instructions** (`*.instructions.md`) | Rules scoped to file globs (e.g. all `*.ts`) | When a matching file is in context |

This mirrors [progressive disclosure](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices):
only the small `AGENTS.md` + skill descriptions are always in context; full skill bodies and reference
files load only when relevant, keeping the context window lean.

## Config, build scripts, publish output & signing

Every bundle ships **ready-made config files** so a fresh project builds and lints immediately:

- **.NET:** `.editorconfig`, `Directory.Build.props`, `Directory.Packages.props`, `.gitignore`.
- **Python:** `pyproject.toml` (Ruff/mypy/pytest), `.pre-commit-config.yaml`, `.editorconfig`, `.python-version`, `.gitignore`.
- **Flutter:** `analysis_options.yaml`, `.gitignore`.
- **Angular:** `.editorconfig`, `.prettierrc.json`, `.gitignore`.
- **SQL:** `docker-compose.yml` (local Postgres + SQL Server), `.env.example`.
- **Supabase:** `.env.example` (client-safe vs server-only keys called out).

**Run things from VS Code.** Each bundle has `.vscode/tasks.json` — open **Terminal → Run Task** and pick
`build`, `test`, `run`, `publish`, `publish android (signed aab)`, `db up`, `supabase start`, etc. Tasks
call the cross-platform `scripts/*.ps1` (Windows) / `scripts/*.sh` (macOS/Linux).

**Local builds → `publish/`.** Publish scripts always output to a git-ignored `publish/` folder, zipped
per platform, unless you pass a different path. Nothing build-related is committed.

**Android signing → `.key/`.** For Android builds (Flutter, or .NET MAUI) the keystore lives in a
git-ignored `.key/` folder (only its `README.md` is tracked). Keystore **passwords come from environment
variables** (`ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`) — never hardcoded or committed. The
`build android (signed aab)` task/script produces a signed `.aab` into `publish/android/`. See each
bundle's `.key/README.md`.

**Continuous integration.** Every bundle ships `.github/workflows/ci.yml`: build/lint/test on every
push & PR, plus a **release job on version tags (`v*`)** that runs the publish script and attaches the
zipped artifacts (or signed AAB) to a GitHub Release. The Flutter Android release job needs repo
secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`. The overlay
bundles (`sql`, `supabase`) ship lint/migration-validation workflows — fold them into the backend's CI
when you merge the overlay.

**Choosing a database.** Backends don't assume an engine — the scaffolder asks (and whether to run it
via Docker). **PostgreSQL is the recommended default**; **SQLite** is only for embedded / prototype /
desktop cases; **SQL Server** and **Supabase** are also covered by the `sql` bundle's
`database-selection` skill, which wires each into .NET or Python behind a repository.

**Licensing, .gitignore & hosting.** The `foundations` overlay adds cross-cutting setup: it makes the
scaffolder ask **open source vs closed/commercial** (MIT / Apache-2.0 / GPL-3.0 / LGPL-3.0, or
proprietary) and add the right `LICENSE`, confirm the `.gitignore`, containerize with Docker, and pick
where to host — managed PaaS (Railway/Render/Fly.io), a VPS (Hetzner), or a self-hosted PaaS
(Hetzner + Dokploy/Coolify).

## Combining bundles (backend + web + mobile + database)

Bundles are composable. A product is usually **one app per bundle**, plus overlay bundles for the
database layer. Example: a **.NET backend**, an **Angular web** front end, a **Flutter mobile** app,
and **Supabase** for auth/DB.

### Recommended layouts

**Option A — one repo per app (simplest, most reliable).** Each app is its own repository with its
bundle copied to the root; they communicate over HTTP. Overlay a database bundle onto the backend.

```
acme-api/      ← dotnet bundle at root  (+ sql or supabase overlay merged in)
acme-web/      ← angular bundle at root
acme-mobile/   ← flutter bundle at root
```

Each `.github/` sits at a workspace root, so every tool discovers its skills/agents/instructions
reliably. Open each repo in its own VS Code window (or use a multi-root `.code-workspace` that adds all
three folders — each folder keeps its own bundle).

**Option B — monorepo.** Put each app in a subfolder, each with its **own nested `AGENTS.md`** (the
AGENTS.md standard supports per-folder files that apply to everything beneath them):

```
acme/
├── AGENTS.md            # repo overview: what each app is + how they talk (points to the three below)
├── api/                 # dotnet bundle (AGENTS.md + .github/ + configs)
├── web/                 # angular bundle
└── mobile/              # flutter bundle
```

For a monorepo opened at the root, keep each app's skills/agents/instructions inside **that app's**
`.github/` and rely on nested `AGENTS.md` for always-on rules; if your tool only discovers skills from
the root `.github/`, consolidate them there (the skill names are already stack-prefixed, e.g.
`scaffolding-dotnet-api` vs `scaffolding-angular-app`, so they won't collide).

### Merging an overlay bundle (sql / supabase) into a backend

Overlays don't stand alone — fold them into the app that owns the database (usually the backend):

1. Copy the overlay's `.github/skills/*`, `.github/agents/*`, and `.github/instructions/*` into the
   backend app's `.github/` (names are unique, so they coexist).
2. Copy its root config (`docker-compose.yml` / `.env.example`, `.vscode/tasks.json` tasks) into the
   backend, merging `tasks.json` entries.
3. Add the overlay's **golden rules** to the backend's `AGENTS.md` (a folder has one `AGENTS.md`) — e.g.
   for Supabase: *"anon key on clients, `service_role` server-only, RLS on every user-data table"*; or
   keep the overlay's `AGENTS.md` as `docs/DATABASE.md` and link it from the backend `AGENTS.md`.

### Worked example: .NET API + Angular web + Flutter mobile + Supabase

- **acme-api** = `dotnet` bundle → tell the agent *"scaffold a .NET Web API"* (`scaffolding-dotnet-api`).
  Merge the `supabase` overlay for auth/DB (JWT validation server-side, `service_role` stays here).
- **acme-web** = `angular` bundle → *"scaffold an Angular app"*; add the `supabase` overlay's
  `supabase-auth` skill and use the **anon** key + `@supabase/supabase-js` for sign-in; call the .NET
  API over HTTPS.
- **acme-mobile** = `flutter` bundle → *"scaffold a Flutter app"*; add `supabase-auth`, use
  `supabase_flutter` with the anon key; share the same backend + auth. Ship a signed AAB via the
  `.key/` + `build android (signed aab)` task.
- Shared contract: the API's exported **OpenAPI spec** is the single source of truth both front ends
  code against; **RLS policies** in Supabase are the shared data-security boundary.

Mix and match freely — e.g. Flutter on mobile + Angular on web against one .NET (or Python) API, with
Postgres (`sql`) or Supabase underneath.

## Cross-tool compatibility

- **VS Code / GitHub Copilot** reads `AGENTS.md`, `.github/skills/`, `.github/agents/`, and
  `.github/instructions/` natively.
- **Claude Code / other agents** read `AGENTS.md` and Agent Skills. If your tool expects skills under
  `.claude/skills/` or `.agents/skills/`, copy or symlink `.github/skills/` there.

## Conventions used when authoring these files

- Skill folder name == the `name:` in its frontmatter (kebab-case).
- Descriptions are written in the third person and include trigger keywords ("Use when...").
- Skill bodies stay under ~500 lines; deep detail lives in one-level-deep reference files.
- No secrets, no time-sensitive instructions, forward-slash paths everywhere.

> The long-form source material these bundles distill lives at the repo root:
> [NET-PROJECT-SETUP.md](../NET-PROJECT-SETUP.md) and [PYTHON-PROJECT-SETUP.md](../PYTHON-PROJECT-SETUP.md).
