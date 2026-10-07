---
name: sql-schema-design
description: 'Designs relational schemas — tables, primary/foreign keys, relationships, data types, constraints, and indexes — for PostgreSQL or SQL Server. Use when modeling a database, adding tables/columns, choosing keys or indexes, or reviewing a schema for normalization and integrity.'
---

# Relational Schema Design

**Best model:** Plan tier (Claude Sonnet 5.5) via the Planner.

Engine-agnostic design rules. For engine-specific syntax/types load
[postgres-conventions](../postgres-conventions/SKILL.md) or
[sqlserver-conventions](../sqlserver-conventions/SKILL.md).

## Keys & identity

- Every table has an explicit **primary key**. Prefer a surrogate key:
  - Postgres: `bigint GENERATED ALWAYS AS IDENTITY`, or `uuid` (`gen_random_uuid()`) when IDs must be
    client-generated / non-guessable.
  - SQL Server: `bigint IDENTITY(1,1)`, or `uniqueidentifier` with a sequential default when needed.
- Add a **unique constraint** for each natural/business key (e.g. `email`, `sku`).
- **Foreign keys** for every relationship, with intentional `ON DELETE` (`RESTRICT`/`CASCADE`/`SET NULL`)
  and `ON UPDATE`. Name them explicitly.

## Normalization

- Design to **3rd normal form** by default (no repeating groups, no partial/transitive dependencies).
- **Denormalize deliberately** only for a measured read-performance need — document why.
- Many-to-many → a join table with a composite PK (or surrogate PK + unique on the pair).

## Data types

- Money → `numeric(19,4)` / `decimal(19,4)`. **Never** `float`/`real` for money.
- Timestamps → store **UTC**: `timestamptz` (PG) / `datetime2` (MSSQL). Dates → `date`.
- Text → `text` (PG) / `nvarchar(n)`/`nvarchar(max)` (MSSQL); size sensibly. Booleans → `boolean`/`bit`.
- Enumerations → a lookup table (FK) or a `CHECK`/native enum; expose as **strings** at the API.
- Prefer `NOT NULL` with sensible defaults; make nullability a deliberate decision.

## Constraints & integrity

- Use `CHECK` constraints for invariants (ranges, allowed states); `UNIQUE` for uniqueness; `DEFAULT`
  for standard values. Push data integrity into the DB, not only the app.
- Add `created_at`/`updated_at` (UTC) where auditing matters; consider soft-delete (`deleted_at`) only
  if the domain needs it.

## Indexing

- Index every **foreign key** and the columns used in frequent `WHERE`/`JOIN`/`ORDER BY` predicates.
- Composite index column order = most-selective / equality columns first, range columns last.
- Add covering/filtered indexes for hot queries; don't over-index write-heavy tables. Measure with
  `EXPLAIN`/`EXPLAIN ANALYZE` (PG) or the execution plan (MSSQL).

## Multi-tenancy

- Tenant-owned tables carry `tenant_id`/`company_id` (indexed, part of composite uniques). The
  application must **prevent cross-tenant access** on every query — a security requirement.

## Output

Produce DDL as a migration (see [sql-migrations](../sql-migrations/SKILL.md)), not ad-hoc statements
against a live DB. Include keys, FKs, constraints, and indexes in the same migration as the table.
