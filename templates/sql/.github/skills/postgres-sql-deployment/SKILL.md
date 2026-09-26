---
name: postgres-sql-deployment
description: 'SQL-first PostgreSQL (15+) deployment convention — SQL organized by what it changes (idempotent object scripts vs one-off BAU data scripts), applied in a fixed order by a small runner (apply.sh / apply.ps1), and shipped to UAT/Production via GitHub Actions with a BAU journal. Use when setting up or evolving a plain-.sql database project (no ORM migration tool), writing object or BAU scripts, or wiring the CI deploy pipeline.'
---

# PostgreSQL SQL-first Deployment (object + BAU scripts)

An alternative to tool-managed migrations (EF Core/Alembic/Flyway — see
[sql-migrations](../sql-migrations/SKILL.md)): plain `.sql` files organized **by what they change**,
applied in a fixed order by a small runner, deployable via CI to multiple environments. Targets
**PostgreSQL 15+**. The runnable scaffold lives in the bundle's [`database/`](../../../database) folder.

**Rule of thumb:** re-running should change nothing → *object* script; run exactly once → *BAU* script.

## Two kinds of script

| | **Object scripts** (`Tables`, `Functions`, `StoredProcedures`) | **BAU scripts** (`BAU/Pending`) |
|---|---|---|
| Purpose | Schema + programmable objects | One-off **data** changes the app doesn't manage |
| Re-run safe? | **Yes** — written idempotently | **No** — each runs once per database |
| After running | Stay in place (the source of truth) | Journaled (CI) or moved to `Executed/` (local) |

## Folder layout

```
database/
  docker-compose.yml          # local Postgres for dev
  .env                        # POSTGRES_USER/PASSWORD/DB (git-ignored; copy .env.example)
  scripts/
    Tables/            01_*.sql   # CREATE TABLE IF NOT EXISTS + additive ALTERs
    Functions/         01_*.sql   # CREATE OR REPLACE FUNCTION
    StoredProcedures/  01_*.sql   # CREATE OR REPLACE PROCEDURE
    BAU/
      _templates/               # copy-me starting points (never executed)
      Pending/                  # one-off scripts waiting to run
      Executed/                 # local runs archive here (date-prefixed)
    apply.sh                    # Linux/macOS/CI runner
    apply.ps1                   # Windows runner (parity)
```

## Object-script rules (idempotent)

- **Tables:** base object `CREATE TABLE IF NOT EXISTS`; later changes appended as guarded, additive
  `ALTER TABLE ... ADD COLUMN IF NOT EXISTS ...` — never destructive.
- **Functions / Procedures:** always `CREATE OR REPLACE` so re-running is a no-op. Create triggers
  inside a guarded `DO` block (`IF NOT EXISTS (SELECT 1 FROM pg_trigger ...)`).
- **Soft-delete:** data tables get `is_active boolean NOT NULL DEFAULT true`; "delete" = set it
  `false`. Reads filter `WHERE is_active` (EF Core: `entity.HasQueryFilter(f => f.IsActive)`).
- Files run in **filename order** within a folder — use `01_`, `02_`, … prefixes.

## BAU-script rules

- **Naming:** `yyyyMMdd-<ticket>-<what-it-is-for>.sql` (e.g. `20260923-1-update-user-favorite-count.sql`).
- **Transaction + rollback:** wrap in `BEGIN; ... COMMIT;`. Postgres has no T-SQL `TRY/CATCH`; use a
  PL/pgSQL `DO` block with `EXCEPTION WHEN OTHERS THEN ... RAISE;` so any error rolls back.
- **MERGE for multiple rows** (insert / update / deactivate keyed off a source set).
- **`IF EXISTS` check for single rows** — fail loudly on a wrong key.
- **Refuse a no-op:** after the DML, `GET DIAGNOSTICS v_rowcount = ROW_COUNT;` and abort if `0`.
- **Soft-delete over DELETE.** A BAU script is a fixed one-off — parameterize nothing at runtime.
- Start from [`BAU/_templates/single-row.sql`](../../../database/scripts/BAU/_templates/single-row.sql)
  or [`multi-row-merge.sql`](../../../database/scripts/BAU/_templates/multi-row-merge.sql).

## The runner

Applies `Tables → Functions → StoredProcedures → BAU/Pending`, in filename order. Two connection
modes and two BAU-tracking modes:

- **docker** (default): local `docker compose exec` into the `postgres` service.
- **direct** (`--direct` / `--connection` / `$DATABASE_URL`): a local `psql` client → real DB (CI).
- **move-to-`Executed/`** (default, local single DB): archives each applied BAU script date-prefixed.
- **`--journal`**: records applied BAU scripts in `app.bau_script_log` and skips already-applied —
  safe for pipelines and multiple environments.

```bash
./scripts/apply.sh                                  # local docker; archive BAU to Executed/
./scripts/apply.sh --skip-bau                       # object folders only
./scripts/apply.sh --direct --journal               # CI: psql via PG* env vars, journal BAU
./scripts/apply.sh --connection "$DATABASE_URL" --journal
```

Windows parity: `./scripts/apply.ps1 [-SkipBau] [-Direct] [-Connection <url>] [-Journal]`.

## CI/CD (`.github/workflows/db-deploy.yml`)

PRs validate against a throwaway Postgres; `develop` deploys to **UAT**, `master` to **Production**.
Object scripts re-apply every deploy (idempotent); BAU scripts run once per database via the journal.

One-time setup: create GitHub **Environments** `uat` and `production`; add a `DATABASE_URL` secret to
each (a least-privilege migrator user); add **Required reviewers** on `production` to gate the deploy.

## Guardrails

- Least-privilege DB user for the migrator (DDL on the app schema only; not a superuser).
- Snapshot Production before deploy; test on UAT first. **Forward-only** — never edit a BAU script
  after it's journaled; write a new corrective one.
- Statements that can't run in a transaction (e.g. `CREATE INDEX CONCURRENTLY`) go in their own script.
- Secrets stay in GitHub Environment secrets / a secrets manager — never in git.

Pair with [postgres-conventions](../postgres-conventions/SKILL.md) for types/naming and
[sql-schema-design](../sql-schema-design/SKILL.md) for modeling.
