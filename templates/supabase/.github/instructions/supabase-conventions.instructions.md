---
description: 'Supabase security conventions enforced on Supabase SQL migrations and policies.'
applyTo: 'supabase/**/*.sql'
---

# Supabase SQL / RLS Conventions

- **Enable RLS** (`alter table ... enable row level security`) in the same migration that creates any
  user-data table. A user-data table without RLS + policies is a defect.
- Write **one policy per operation** (`select`/`insert`/`update`/`delete`) and role
  (`authenticated`/`anon`); `using` for visibility, `with check` for writes.
- Scope rows by `auth.uid()` (owner) and/or `tenant_id` (from a membership table or JWT claim); index
  every column used in a policy predicate.
- Never rely on client-side checks for authorization — RLS is the boundary.
- `security definer` functions bypass RLS: scope them tightly and `set search_path`.
- Follow Postgres conventions (snake_case, `timestamptz` UTC, `numeric` money, explicit keys/FKs).
- Manage all schema through migrations committed to git; never edit an already-applied migration.
- The `service_role` key is server-only; anon key for clients. No secrets in SQL or committed files.
