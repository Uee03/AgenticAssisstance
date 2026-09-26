---
description: 'SQL conventions enforced on all .sql files.'
applyTo: '**/*.sql'
---

# SQL Conventions

- **Parameterize** all queries that take input (`$1`/`@param`) — never concatenate/interpolate untrusted values.
- **Injection is the top risk:** the same rule binds application data-access code — EF Core raw SQL
  (`FromSql*`/`ExecuteSql*`/`SqlQuery*`), Dapper, and ADO.NET must use bound parameters, never string
  building; dynamic table/column names come from a code allow-list. See the `efcore-data-access` skill.
- No `SELECT *` in application queries — list columns explicitly.
- Every table: explicit **primary key**; **foreign keys** with intentional `ON DELETE`/`ON UPDATE`;
  `NOT NULL` by default; unique constraints for natural keys; `CHECK` for invariants.
- Money → `numeric`/`decimal` (never float). Timestamps → `timestamptz` (PG) / `datetime2` (MSSQL) in UTC.
- Index foreign keys and frequent `WHERE`/`JOIN`/`ORDER BY` predicates; name indexes/constraints explicitly.
- Naming: snake_case + plural tables (PostgreSQL); the chosen consistent convention (SQL Server).
- Schema changes belong in **versioned migrations**, not ad-hoc statements; never edit an applied migration.
- Multi-tenant tables carry an indexed `tenant_id`/`company_id`; scope every query by it.
- Keep DB logic (triggers/procedures) for genuinely database-centric work, not application business logic.
