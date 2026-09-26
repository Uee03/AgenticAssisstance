# AGENTS.md — SQL (PostgreSQL & SQL Server)

Guidance for AI agents doing database work in this repository. This is an **overlay bundle**: drop it
alongside a backend bundle (e.g. `dotnet` or `python`) to add SQL schema, migration, and query
standards. Read this first, then load the skill that matches the task.

## Engines

- **PostgreSQL** — **recommended default** for services and anything that will grow (rich types:
  `jsonb`, arrays, `uuid`, `timestamptz`). Run it locally via Docker for dev/prod parity.
- **SQLite** — only for **embedded / single-user / desktop / prototype / test** cases (zero-setup single file).
- **Microsoft SQL Server** — when the org standardizes on it or an existing system requires it.

**Not sure which to use?** Load [database-selection](./.github/skills/database-selection/SKILL.md) and
**ask the user before adding persistence**. Pick one engine per database; don't target both from the
same schema. The conventions skills below cover each.

## Skills — load the one that matches the task

| Skill | Use when |
|-------|----------|
| [database-selection](./.github/skills/database-selection/SKILL.md) | Choosing which database to use (SQLite/Postgres/SQL Server/Supabase) |
| [sql-schema-design](./.github/skills/sql-schema-design/SKILL.md) | Designing tables, keys, relationships, indexes, data types |
| [sqlite-conventions](./.github/skills/sqlite-conventions/SKILL.md) | Using SQLite (quick-win single-file DB), pragmas, wiring |
| [postgres-conventions](./.github/skills/postgres-conventions/SKILL.md) | Writing PostgreSQL DDL/SQL, choosing PG types/features |
| [sqlserver-conventions](./.github/skills/sqlserver-conventions/SKILL.md) | Writing SQL Server (T-SQL) DDL/SQL, choosing MSSQL types/features |
| [sql-migrations](./.github/skills/sql-migrations/SKILL.md) | Creating/versioning migrations, evolving a schema safely |
| [postgres-sql-deployment](./.github/skills/postgres-sql-deployment/SKILL.md) | SQL-first Postgres deploy: idempotent object scripts + one-off BAU scripts, the `apply` runner, and CI to UAT/Prod |
| [efcore-data-access](./.github/skills/efcore-data-access/SKILL.md) | Accessing SQL from .NET: EF Core (code-first + LINQ), EF Core raw SQL, and standard Dapper/ADO.NET — always parameterized |

## Agents

- [sql-reviewer](./.github/agents/sql-reviewer.agent.md) — read-only review of SQL/DDL/migrations.

Path-scoped rules: [.github/instructions/sql-conventions.instructions.md](./.github/instructions/sql-conventions.instructions.md).

## Local databases

`docker-compose.yml` starts local Postgres and SQL Server. Copy `.env.example` to `.env` (git-ignored)
and set passwords, then use the VS Code tasks (**db up / db down / psql / sqlcmd**) or:

```bash
docker compose up -d postgres        # or: mssql
docker compose down
```

**SQLite needs no server** — it's just a file; skip docker-compose for it (see sqlite-conventions).

CI: `.github/workflows/ci.yml` lints SQL and can apply migrations to a throwaway Postgres. When you
merge this overlay into a backend, fold its CI into that repo's workflow.

## SQL-first deployment (object + BAU scripts)

For a plain-`.sql` Postgres project without an ORM migration tool, the [`database/`](./database)
folder is a self-contained scaffold: idempotent **object scripts** (`Tables` / `Functions` /
`StoredProcedures`) plus one-off **BAU** data scripts, applied in a fixed order by
`scripts/apply.sh` (`apply.ps1` on Windows) and shipped to UAT/Production by
`.github/workflows/db-deploy.yml`. Load
[postgres-sql-deployment](./.github/skills/postgres-sql-deployment/SKILL.md) before writing scripts
or wiring the pipeline. This is an alternative to tool-managed `sql-migrations` — pick one per project.

## Always do

- **Parameterize every query** — never concatenate/interpolate untrusted input into SQL. This is
  non-negotiable (OWASP A03 injection) and applies equally to EF Core raw SQL (`FromSql*`,
  `ExecuteSql*`, `SqlQuery*`), Dapper, and ADO.NET. Dynamic identifiers come from a code allow-list,
  never from input. See [efcore-data-access](./.github/skills/efcore-data-access/SKILL.md).
- All schema changes go through **versioned, forward-only migrations** (never hand-edit prod).
- Explicit primary keys; foreign keys with intentional `ON DELETE`/`ON UPDATE`; `NOT NULL` by default.
- Index foreign keys and common query predicates; add unique constraints for natural keys.
- Store money as `numeric`/`decimal` (never float); timestamps as `timestamptz` (PG) / `datetime2` (MSSQL), in UTC.
- Enums as strings/lookup tables at the API boundary; consistent naming (see the conventions skill).
- SQLite: enable `PRAGMA foreign_keys = ON` (+ WAL) on every connection — FKs are off by default.
- Keep secrets out of SQL and out of git; least-privilege DB users per service.

## Never do

- String-built SQL from user input; `SELECT *` in application queries.
- Destructive migrations without a backup/rollback plan; editing an already-applied migration.
- `float`/`real` for money; storing large blobs in the DB (use object storage).
- Business logic buried in triggers/procedures when it belongs in the application layer (use DB logic
  only where it is genuinely database-centric).
