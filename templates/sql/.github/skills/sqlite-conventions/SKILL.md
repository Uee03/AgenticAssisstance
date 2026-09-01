---
name: sqlite-conventions
description: 'Conventions for using SQLite — the zero-setup, single-file database for quick wins, desktop apps, prototypes, and tests. Use when the app uses SQLite, when the user wants a fast local database with no server, or when embedding a database in a .NET or Python app.'
---

# SQLite Conventions

SQLite is a serverless, single-file database — ideal for **quick wins**: prototypes, CLIs, desktop
apps, single-user tools, and fast/deterministic tests. No Docker, no server. Pair with
[sql-schema-design](../sql-schema-design/SKILL.md); it is **not** for high write-concurrency or
multi-node web workloads — use PostgreSQL there.

## Where the file lives

- Store the `.db` file in a per-user app-data directory at runtime (not in the repo); for tests use a
  temp file or `:memory:`.
- **Git-ignore** database files (`*.db`, `*.sqlite`, `*.sqlite3`) unless a small seed/fixture DB is
  intentionally versioned.

## Connection settings (set these on every connection)

- `PRAGMA foreign_keys = ON;` — SQLite does **not** enforce foreign keys by default.
- `PRAGMA journal_mode = WAL;` — better read/write concurrency for app use.
- `PRAGMA busy_timeout = 5000;` — wait instead of failing on a brief lock.

## Types & schema

- SQLite uses **type affinity** (dynamic typing), not strict types. Declare intent with `INTEGER`,
  `TEXT`, `REAL`, `BLOB`, `NUMERIC`; optionally use `STRICT` tables (modern SQLite) for real type checks.
- Keys: `INTEGER PRIMARY KEY` (aliases the rowid, efficient) or a `TEXT` UUID for non-guessable ids.
- Money: store as `INTEGER` minor units (cents) or `TEXT` decimal — **never float**. Timestamps: store
  UTC as `TEXT` ISO-8601 (`YYYY-MM-DD HH:MM:SSZ`) or `INTEGER` epoch. Booleans: `INTEGER` 0/1.
- Still define explicit primary keys, foreign keys, `NOT NULL`, `UNIQUE`, `CHECK`, and indexes on FKs /
  hot predicates. Use parameterized queries always.

## Wiring per stack

- **.NET:** EF Core `Microsoft.EntityFrameworkCore.Sqlite`, or `Microsoft.Data.Sqlite` for raw ADO.NET.
  Connection string `Data Source=app.db`. Enable FK enforcement (EF does by default). Migrations via EF Core.
- **Python:** stdlib `sqlite3` (set the pragmas above after connect), or SQLAlchemy 2.x with
  `sqlite:///app.db` (sync) / `sqlite+aiosqlite:///app.db` (async). Migrations via **Alembic**
  (note: SQLite has limited `ALTER TABLE`; Alembic uses batch/"move-and-copy" mode for column changes).

## Migrating to Postgres later

Because access sits behind a repository interface and migrations are tool-managed, moving SQLite →
Postgres is mostly a connection-string + provider swap plus re-running migrations. Avoid SQLite-only
SQL in shared layers to keep the move cheap.

## Limitations to remember

- One writer at a time (WAL helps reads); avoid for high-concurrency multi-user web APIs.
- No native network access, users/roles, or server-side RLS — enforce authorization in the app.
