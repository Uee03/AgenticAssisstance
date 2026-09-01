---
name: postgres-conventions
description: 'Conventions for writing PostgreSQL DDL and SQL — snake_case naming, native types (uuid, jsonb, timestamptz, arrays), identity keys, enums, extensions, and safe query patterns. Use when authoring PostgreSQL schemas, queries, or functions, or when the database engine is Postgres.'
---

# PostgreSQL Conventions

Pair with [sql-schema-design](../sql-schema-design/SKILL.md) for engine-agnostic design.

## Naming

- **snake_case** for everything (tables, columns, indexes, constraints). Table names **plural**
  (`customers`), column names singular (`email`).
- Explicit constraint/index names: `pk_<table>`, `fk_<table>_<ref>`, `uq_<table>_<cols>`,
  `ix_<table>_<cols>`, `ck_<table>_<rule>`.
- Use a dedicated schema (e.g. `app`) rather than dumping everything in `public`.

## Types & features

- Keys: `bigint GENERATED ALWAYS AS IDENTITY` (default) or `uuid DEFAULT gen_random_uuid()`
  (from the `pgcrypto` extension) for client/non-guessable IDs.
- Time: `timestamptz` in UTC. Money: `numeric(19,4)`. Text: `text` (no arbitrary `varchar(n)` limits
  unless the domain requires one). Booleans: `boolean`.
- Semi-structured data: `jsonb` (indexable with GIN) — but prefer real columns for queryable fields.
- Enumerations: a **lookup table** (FK) is usually more flexible than a native `enum` type (which is
  hard to alter). Expose values as strings in the API.
- Useful extensions: `pgcrypto` (UUID/crypto), `citext` (case-insensitive text), `pg_trgm` (fuzzy search).

## Query patterns

- **Parameterize** with `$1, $2, ...` (never string-concatenate input).
- Case-insensitive compare: `lower(col) = lower($1)` (index `lower(col)`) or use `citext`.
- Prefer `INSERT ... ON CONFLICT ... DO UPDATE` for upserts; `RETURNING` to get generated values.
- Explicit column lists (no `SELECT *` in application code). Keyset pagination over large `OFFSET`.
- Wrap multi-statement changes in a transaction; use appropriate isolation for concurrent updates.

## Performance

- Index FKs and hot predicates; verify with `EXPLAIN (ANALYZE, BUFFERS)`.
- GIN index for `jsonb`/full-text/`pg_trgm`; partial indexes for filtered hot paths.

## Row Level Security (if used)

- For multi-tenant/Supabase-style setups, `ENABLE ROW LEVEL SECURITY` and add policies rather than
  relying only on app checks. (Supabase specifics live in the `supabase` bundle.)
