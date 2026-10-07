---
name: sqlserver-conventions
description: 'Conventions for writing Microsoft SQL Server (T-SQL) DDL and SQL — naming, schemas, identity keys, datetime2/decimal/nvarchar types, indexes, and safe parameterized query patterns. Use when authoring SQL Server schemas, queries, or stored procedures, or when the database engine is SQL Server.'
---

# SQL Server (T-SQL) Conventions

**Best model:** Act tier (GPT-6.1 Sol) via the Implementer; Plan tier (Claude Sonnet 5.5) via SQL Reviewer for review.

Pair with [sql-schema-design](../sql-schema-design/SKILL.md) for engine-agnostic design.

## Naming

- **PascalCase** for tables/columns is common in SQL Server (`Customers`, `EmailAddress`); pick one
  convention and stay consistent across the database.
- Use **schemas** to group objects (e.g. `Sales.Orders`) instead of `dbo` for everything.
- Explicit constraint/index names: `PK_<Table>`, `FK_<Table>_<Ref>`, `UQ_<Table>_<Cols>`,
  `IX_<Table>_<Cols>`, `CK_<Table>_<Rule>`.

## Types & features

- Keys: `bigint IDENTITY(1,1)` (default) or `uniqueidentifier` with `DEFAULT NEWSEQUENTIALID()` when a
  GUID is required (sequential to reduce index fragmentation).
- Time: `datetime2(3)` in UTC (never the legacy `datetime`). Money: `decimal(19,4)` (not `money`/float).
- Text: `nvarchar(n)` for bounded, `nvarchar(max)` for large; avoid non-Unicode `varchar` unless
  intentional. Booleans: `bit`.
- Semi-structured: `nvarchar(max)` + `ISJSON`/`JSON_VALUE`, or the native `json` type on recent
  versions. Enumerations: a lookup table (FK); expose as strings in the API.

## Query patterns

- **Parameterize** with `@params` (via `sp_executesql` / client parameters) — never build SQL from
  input. Guard against injection everywhere.
- Explicit column lists (no `SELECT *` in application code). `MERGE` cautiously (known edge cases) —
  often an explicit `UPDATE`/`INSERT` upsert is safer.
- Use `SET NOCOUNT ON` in procedures; `TRY...CATCH` with explicit transactions for multi-statement work.
- Case-insensitive compares usually follow the column **collation** (default CI); be explicit with
  `COLLATE` when needed.

## Performance

- Index FKs and hot predicates; review the actual **execution plan**; watch for key lookups (add
  covering `INCLUDE` columns). Use filtered indexes for hot subsets. Keep statistics updated.

## Stored procedures

- Use procedures for genuinely set-based, database-centric logic — not to hold application business
  logic. Keep them parameterized, named consistently, and version-controlled as migrations.
