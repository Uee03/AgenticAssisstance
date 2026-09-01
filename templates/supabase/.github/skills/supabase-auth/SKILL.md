---
name: supabase-auth
description: 'Adds authentication with Supabase Auth — email/password and OAuth providers, sessions/JWT, and integrating auth.uid() with Row Level Security. Use when implementing sign-up/sign-in, social login, session handling, or protecting data by user in a Supabase app.'
---

# Supabase Auth

Supabase Auth issues a JWT containing the user id (`auth.uid()`) and role. That JWT is what RLS
policies use to authorize row access — auth and the database are tightly linked.

## Client vs server

- **Clients** (browser/mobile) sign users in with the **anon** key; the SDK stores the session and
  attaches the JWT to every request, so RLS sees `auth.uid()`.
- **Servers** that must act as any user use the `service_role` key (bypasses RLS) — keep it server-side
  and apply your own authorization. Prefer honoring RLS by forwarding the user's JWT when possible.

## Common flows

- **Email/password:** `signUp` / `signInWithPassword`; enable email confirmation for production.
- **OAuth providers** (Google, GitHub, Apple, …): configure in the dashboard; `signInWithOAuth`.
- **Magic link / OTP:** `signInWithOtp` for passwordless.
- **Sessions:** SDKs auto-refresh tokens; subscribe to `onAuthStateChange` to react to sign-in/out.

## Integrate with RLS

Policies key off the authenticated user:

```sql
-- users can read/write only their own rows
create policy "own rows - select" on public.notes
  for select to authenticated using (user_id = auth.uid());
create policy "own rows - insert" on public.notes
  for insert to authenticated with check (user_id = auth.uid());
```

Set `user_id` columns to `default auth.uid()` (or set it server-side) so inserts are attributable.
See [supabase-database-and-rls](../supabase-database-and-rls/SKILL.md) for policy patterns.

## Per-framework wiring

- **Angular:** wrap the client in an `AuthService`; expose the session as a signal; add a route guard
  that checks the session; attach the client to HTTP calls (SDK does this automatically).
- **Flutter:** initialize `supabase_flutter` in `main()`; gate routes on `onAuthStateChange`; store
  nothing sensitive locally beyond what the SDK manages.
- **.NET/Python backend:** validate the Supabase JWT (JWKS / shared secret) in middleware; derive the
  user/tenant from claims; enforce authorization server-side.

## Rules

- Never expose `service_role` to a client. Enforce authorization with **RLS**, not just UI guards.
- Confirm emails / rate-limit auth endpoints in production; use HTTPS everywhere.
- Store roles/permissions in a table or JWT claims; keep RLS policies the single source of truth for row access.
