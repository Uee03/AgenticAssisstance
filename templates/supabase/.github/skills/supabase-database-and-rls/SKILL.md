---
name: supabase-database-and-rls
description: 'Designs Supabase Postgres schema via migrations and writes/reviews Row Level Security (RLS) policies. Use when creating tables in Supabase, enabling RLS, writing access policies, or securing data by user/tenant. Every user-data table must have RLS enabled with explicit policies.'
---

# Supabase Database & Row Level Security

**Best model:** Act tier (GPT-6.1 Sol) to write policies; Plan tier (Claude Sonnet 5.5) to review them.

Supabase is PostgreSQL — follow the `sql` bundle's schema-design + Postgres conventions + migration
rules. This skill adds the **RLS** layer, which is Supabase's core security boundary.

## Enable RLS on every user-data table

RLS is off by default on new tables and, once enabled, **denies all access until a policy allows it**.
Enable it in the same migration that creates the table:

```sql
create table public.notes (
  id         bigint generated always as identity primary key,
  user_id    uuid not null default auth.uid() references auth.users (id),
  title      text not null,
  body       text,
  created_at timestamptz not null default now()
);
alter table public.notes enable row level security;
```

## Policy patterns

Write **one policy per operation** (`select`/`insert`/`update`/`delete`) and role (`authenticated`,
`anon`). `using` filters visible rows; `with check` validates written rows.

```sql
-- Owner-only access
create policy "notes select own" on public.notes
  for select to authenticated using (user_id = auth.uid());
create policy "notes insert own" on public.notes
  for insert to authenticated with check (user_id = auth.uid());
create policy "notes update own" on public.notes
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "notes delete own" on public.notes
  for delete to authenticated using (user_id = auth.uid());
```

- **Multi-tenant:** filter by `tenant_id` derived from a membership table or a JWT claim
  (`auth.jwt() ->> 'tenant_id'`); index `tenant_id`.
- **Role/permission checks:** join a `memberships`/`roles` table inside the policy, or read a custom
  JWT claim. Keep helper logic in `security definer` functions **carefully** (they bypass RLS — scope
  them tightly and `set search_path`).
- **Public read:** a `for select to anon using (true)` policy only where data is truly public.

## Performance

- Index every column used in a policy predicate (`user_id`, `tenant_id`) — policies run on every row.
- Keep policy expressions simple; wrap `auth.uid()` in `(select auth.uid())` to help the planner cache it.

## Testing policies (do this)

- Verify with different roles: as `anon`, as the owning user, and as a different user. Confirm a user
  cannot read/modify another user's/tenant's rows.
- Add regression tests (SQL or app-level) for critical policies; re-test after schema changes.

## Rules

- No user-data table without RLS enabled + explicit policies. Never disable RLS to "make it work".
- Manage all of this through **migrations** committed to git, not Studio edits in production.
- `service_role` bypasses RLS — only ever use it server-side.
