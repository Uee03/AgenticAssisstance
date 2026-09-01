---
name: database-selection
description: 'Helps choose a database for a new app and wire it into a .NET or Python backend — SQLite, PostgreSQL, SQL Server, or Supabase. Use when starting persistence, when the user has not said which database to use, or when deciding between a quick SQLite start and a full Postgres/SQL Server setup.'
---

# Choosing a Database

Backend scaffolding skills (`scaffolding-dotnet-api`, `scaffolding-python-api`, the web-app skills)
reference this. **Before adding any persistence, ask the user which database to use** and confirm the
answer — don't silently default.

## Ask the user

> "Which database should this use? **PostgreSQL** (recommended default for anything that runs as a
> service or will grow), **SQLite** (only for embedded / single-user / desktop / prototype / test),
> **SQL Server** (if your org standardizes on it), or **Supabase** (managed Postgres + Auth + Storage)?"

**Prefer PostgreSQL by default** — even for small apps, running Postgres locally in Docker gives
dev/prod parity and room to grow. Choose **SQLite only** when the app is genuinely embedded,
single-user, or a throwaway prototype/test. Access sits behind a repository interface, so SQLite →
Postgres later is a config + migration change.

## Also ask: how to run it

> "Run the database with **Docker** (recommended — a local Postgres via docker-compose matches
> production), a **managed/hosted** Postgres (Supabase / Neon / provider RDS), or a **native install**?"

Default to Docker for local dev — see the `foundations` bundle's `docker-and-services` skill and the
`sql` bundle's `docker-compose.yml`. SQLite needs none of this (it's just a file).

## Decision guide

| Pick | When | Notes |
|------|------|-------|
| **PostgreSQL** (default) | Web APIs/SaaS and anything that runs as a service or will grow | Rich types (`jsonb`, arrays, `uuid`), strong concurrency; run locally via Docker. See [postgres-conventions](../postgres-conventions/SKILL.md). |
| **SQLite** | Only embedded / single-user / desktop / prototype / tests | Zero server/setup, one file. Not for concurrent multi-user web. See [sqlite-conventions](../sqlite-conventions/SKILL.md). |
| **SQL Server** | Org standard, existing MSSQL estate, Windows/.NET shops that require it | See [sqlserver-conventions](../sqlserver-conventions/SKILL.md). |
| **Supabase** | Want managed Postgres + Auth + Storage + RLS with little ops | It *is* Postgres; add the `supabase` overlay bundle. |

## Keep the choice swappable

Access the database only through a **repository/interface** in the Application layer. The engine is an
Infrastructure/Persistence detail, so starting on SQLite and moving to Postgres later is a config +
migration change, not an app rewrite. Keep SQL parameterized and avoid engine-specific SQL in the
domain/application layers.

## Wiring per stack (after the choice)

- **.NET:** EF Core provider or a driver — `Microsoft.EntityFrameworkCore.Sqlite` / `Npgsql` (Postgres)
  / `Microsoft.Data.SqlClient` (SQL Server). Connection string from config/env; migrations via EF Core.
- **Python:** SQLAlchemy URL — `sqlite+aiosqlite:///app.db`, `postgresql+psycopg://…`, or
  `mssql+pyodbc://…`; migrations via **Alembic**. URL from Pydantic settings (env).

Then follow [sql-migrations](../sql-migrations/SKILL.md) for versioned schema changes and the matching
engine conventions skill.
