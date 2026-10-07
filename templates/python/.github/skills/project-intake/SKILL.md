---
name: project-intake
description: 'Mandatory pre-scaffolding intake for a new Python project. ALWAYS run this before creating or modifying any file in a new or empty repo — collect project name, app type, framework, doc UI / GUI toolkit, database, auth, licensing, .gitignore, Docker, and hosting, then get explicit confirmation before scaffolding. Use at the very start of any "create / scaffold / set up a Python project" request.'
---

# Project intake (Python) — do this before scaffolding

**Best model:** Plan tier (Claude Sonnet 5.5); if already inside a scaffolder agent, stay on its model.

**Hard gate.** Do NOT create files, generate code, add dependencies, or run commands until every
question below is answered and you have echoed the choices back and received an explicit "yes".
Never assume defaults or "sensible" choices — ask. If the user says "just pick defaults", still show
the filled-in summary and get a single confirmation before building.

## How to run it

1. Ask the questions below **in one message** (grouped) so the user can answer quickly.
2. For anything left blank, state the default you would use and ask them to confirm it.
3. Post the **Intake summary** block with every value filled in.
4. Wait for explicit confirmation. Only then load the matching scaffolding skill and build.

## Questions

1. **Project name** — e.g. `billing`.
2. **App type** — API (JSON) · Web app (server-rendered) · Desktop (GUI) · CLI · library.
3. **Framework / toolkit** (ask only the relevant one):
   - **API:** FastAPI (preferred) · Flask · Django REST. Doc UI comes free via OpenAPI/Swagger.
   - **Web app:** Django · Flask + Jinja2.
   - **Desktop:** PySide6 · Flet · CustomTkinter.
4. **Database** — SQLite · PostgreSQL · SQL Server · Supabase · none (for now).
   If unsure, load the `sql` bundle's `database-selection` skill and ask.
5. **Auth** — none · local · OAuth/OIDC · Supabase Auth. Multi-tenant (per-user / per-org)?
6. **License** — open source (which: MIT / Apache-2.0 / GPL-3.0 / LGPL-3.0) or closed/commercial?
   (See the `foundations` `project-licensing` skill. Never assume MIT.)
7. **.gitignore** — confirm the bundled one is right for this stack.
8. **Docker for local dev?** — yes/no (recommended when a database is involved, for Postgres parity).
9. **Hosting** — where will it run (managed PaaS / VPS / self-hosted Dokploy-Coolify / not yet)?
   If undecided, offer the `foundations` `choosing-hosting` skill.
10. **Python version** — default latest stable; pin in `.python-version` / `requires-python`.

## Intake summary (fill in, then confirm)

```text
Project name : <...>
App type     : <API | Web app | Desktop | CLI | library>
Framework    : <FastAPI|Flask|Django REST | Django|Flask+Jinja | PySide6|Flet|CustomTkinter>
Database     : <SQLite | PostgreSQL | SQL Server | Supabase | none>
Auth         : <none | local | OAuth/OIDC | Supabase>  (tenancy: <none|per-user|per-org>)
License      : <MIT | Apache-2.0 | GPL-3.0 | LGPL-3.0 | proprietary>
.gitignore   : <confirmed>
Docker (dev) : <yes | no>
Hosting      : <PaaS | VPS | Dokploy/Coolify | undecided>
Python       : <latest stable, pinned>
```

> Only after the user confirms this summary do you load the matching `scaffolding-python-*` skill
> (and `python-clean-architecture`) and begin. Record the confirmed choices in `AGENTS.md` and the
> `README.md`.
